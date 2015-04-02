SUBROUTINE phast_manager
    ! ... The top level routine for the manager process that manages the simulation
    ! ...     and does the groundwater flow calculation.
    USE machine_constants, ONLY: kdp, one_plus_eps
    USE mcb
    USE mcc
    USE mcc_m
    USE mcch, ONLY: f1name, f2name, f3name, version_name, comp_name,  &
        restart_files, num_restart_files
    USE mcch_m
    USE mcg, ONLY: naxes, nx, ny, nz, nxyz, npmz, grid2chem
    USE mcm
    USE mcm_m
    USE mcn, ONLY: pv0
    USE mcp
    USE mcs
    USE mcv
    USE mcv_m
    USE mcw
    USE hdf_media_m,       ONLY: pr_hdf_media
#ifdef USE_MPI
    USE mpi_mod
#endif
    USE print_control_mod
    USE XP_module, ONLY: Transporter
  USE PhreeqcRM
  IMPLICIT NONE
    SAVE
    INTERFACE
        INTEGER FUNCTION set_fdtmth()
        END FUNCTION set_fdtmth
        
        INTEGER FUNCTION set_components() 
        END FUNCTION set_components

	SUBROUTINE FH_FinalizeFiles() BIND(C, NAME='FH_FinalizeFiles')
	   USE ISO_C_BINDING
           IMPLICIT NONE
        END SUBROUTINE FH_FinalizeFiles
	SUBROUTINE FH_WriteFiles(ihdf, imedia, ixyz, iprint_xyz, print_restart) BIND(C, NAME='FH_WriteFiles')
	   USE ISO_C_BINDING
           IMPLICIT NONE
           INTEGER(kind=C_INT), INTENT(in) :: ihdf, imedia, ixyz, print_restart
           INTEGER(kind=C_INT), INTENT(in) :: iprint_xyz(*)
        END SUBROUTINE FH_WriteFiles

    END INTERFACE
    CHARACTER(LEN=130) :: logline1
    INTEGER :: i, a_err, j
    INTEGER :: ihdf, imedia, ixyz
    INTEGER status
    !     ------------------------------------------------------------------
    errexi=.FALSE.
    errexe=.FALSE.
!
! ... static data, group 1
!
    CALL openf
    CALL read1                                             ! Read fundamental information, dimensioning data
    CALL read1_distribute                                  ! Distribute for MPI
    CALL CreateRM                                          ! Create Reaction Module(s)
    ! Set components
    status = set_components()                              ! make component list on Fortran side   
    CALL set_component_map                                 ! Map components to thread/process for parallel transport calculations
    CALL init1                                             ! Initialize and allocate arrays, root and workers
    CALL error1                                            ! Check for errors
    IF(errexi) GO TO 50
    CALL write1
!
! ... time-invariant data, group 2
!    
    CALL read2                                             ! Read time invariant data
    CALL init2_1                                           ! Read time invariant data (root)
    CALL group2_distribute                                 ! Distribute for MPI
    CALL create_transporters                               ! Create transporters for each component
    CALL init2_2                                           ! Initialize (root)
    IF (.NOT.steady_flow) pv0 = pv                         ! pressure corrected pv
    CALL error2                                            ! Check for errors
    IF(errexi) GO TO 50 
!
! ...  Initialize Reaction Module
!
    CALL InitializeRM                                      ! Initializes RM, runs file, distributes initial conditions
    CALL error4                                            ! Check for errors
                                                           ! write2_1 must be called after distribute_initial_conditions and equilibrate
    CALL write2_1                                          ! Write initial condition results 
    IF(errexe .OR. errexi) GO TO 50
!    
! ... Calculate steady flow
!
    IF(steady_flow) THEN
        CALL simulate_ss_flow                              ! calls read3 and init3
        IF(errexe .OR. errexi) GO TO 50
        CALL init3_distribute                              ! Distribute for MPI
    ENDIF
    CALL zone_flow_write_heads                             ! Write zone flows 
!
! ... Use Reaction Module to equilbrate cells  
!
    CALL InitialEquilibrationRM
	CALL zone_flow_write_chem()
    IF (solute) THEN
        CALL init2_3        
    ENDIF
!
! ... Write initial results, distribute flow results  
!
    CALL write2_2                             
    IF (steady_flow) THEN
        CALL write3
        CALL write4                                       ! calls calc_velocity
    ENDIF
    imedia = 0
    if (pr_hdf_media) imedia = 1
    CALL FH_WriteFiles(prhdfci,  imedia, prcphrqi, & ! Needs to be after calc_velocity    
        iprint_xyz, 0) 
    CALL flow_distribute                                  ! distribute  initial p and c_w to workers from manager
    IF(errexe .OR. errexi) GO TO 50
!
! ...  Transient loop
!
    IF(solute .OR. .NOT.steady_flow) THEN
        logline1 = 'Beginning transient simulation.'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
        fdtmth = fdtmth_tr                                ! set time differencing method to transient
        status = set_fdtmth()                             ! send differencing method to workers
        DO
            CALL time_parallel(0)                         ! Timing
            CALL c_distribute
            CALL p_distribute
            CALL time_parallel(1)                         ! 1 - 0, flow and transport communication
            IF (.NOT. steady_flow) THEN
                CALL coeff_flow
                CALL rhsn
            ELSE
                CALL rhsn_manager
            ENDIF
            !
            ! ... Read the transient data, if necessary. The first block was read by the steady flow 
            ! ... simulation section
            ! 
            CALL time_parallel(2)                          ! 2 - 1, flow
            DO WHILE(time*one_plus_eps >= timchg)          ! skip past data blocks until
                ! ...         restart time is reached
                CALL read3
                CALL init3                      ! only for timing
                CALL init3_distribute
                IF(thru) EXIT                              ! Normal exit from time step loop
                CALL error3
                CALL write3
                IF(errexi) EXIT
            END DO  
            CALL time_parallel(3)                          ! 3 - 2, flow and transport communication
            IF (thru) then
                EXIT                                       ! ... second step of exit
            endif
            !
            ! ... Root calculates transient flow
            !
            IF (.NOT. steady_flow) THEN
                IF (nwel > 0) THEN
                    IF (cylind) THEN
                        CALL wellsc
                    ELSE
                        CALL wellsr
                    ENDIF
                ENDIF
                CALL aplbce_flow
            ENDIF
            IF(errexe) THEN
                CALL write5                                ! Check for errors
                EXIT
            END IF
20          CALL timestep                                  ! Update time step
            CALL write6                                    ! print conductance values
            !
            ! .... Send transient flow to workers
            !
            IF(.NOT.steady_flow) THEN
                CALL asmslp_flow
            ENDIF
            CALL time_parallel(4)                          ! 4 - 3, flow
            IF(.NOT.steady_flow) THEN
                CALL flow_distribute
            ENDIF
            CALL time_parallel(5)                          ! 5 - 4, flow communication
            !
            ! ... Root and workers do transport calculations
            !
            IF (solute) THEN
                logline1 =  '     Beginning solute-transport calculation.'
                status = RM_LogMessage(rm_id, logline1)
                status = RM_ScreenMessage(rm_id, logline1)
                DO i = 1, ns
                    logline1 =  '          '//comp_name(i)
                    status = RM_LogMessage(rm_id, logline1)
                    status = RM_ScreenMessage(rm_id, logline1)
                ENDDO
            ENDIF           
            CALL run_transport         
            IF(errexe .OR. errexi) GO TO 50
            !
            ! Gather results from workers to root, process results
            !
            CALL time_parallel(6)                          ! 6 - 5, transport
            CALL sbc_gather
            CALL c_gather
            CALL time_parallel(7)                          ! 7 - 6, transport communication
            IF (steady_flow) THEN
                CALL sumcal1_manager
            ELSE
                CALL sumcal1
            ENDIF
            IF(tsfail .AND. .NOT.errexe) GO TO 20
            !
            ! ... React cells with PhreeqcRM, process and write results
            !
            CALL time_parallel(8)                          ! 8 - 7, sumcal
            CALL TimeStepRM                                ! Run cells in Reaction Module, return concentrations

            CALL time_parallel(14)                         ! new time
            CALL sumcal2                                   ! Calculate summary fluxes
            CALL time_parallel(15)                         ! 15 - 14, sumcal
            CALL write5                                    ! Write results
            IF(przf_xyzt .AND. .NOT.steady_flow) THEN  
                CALL zone_flow_write_heads
            ENDIF
	        CALL zone_flow_write_chem()
            IF (.NOT.steady_flow) THEN
                CALL write4                                 ! calc_velocity called
            ENDIF
            ! write files
            ihdf = 0
            if (prhdfc .or. (prhdfhi .ne. 0) .or. (prhdfvi .ne. 0)) ihdf = 1
            imedia = 0
            if (pr_hdf_media) imedia = 1 
            ixyz = 0
            if (prcphrq) ixyz = 1        
            CALL FH_WriteFiles(ihdf, imedia, ixyz, &
                iprint_xyz, print_restart%print_flag_integer)   ! Needs to be after calc_velocity                                                         ! calc_velocity needs to be called before write_hdf (FH_WriteFiles)
            IF (prhdfii == 1) THEN
                CALL write_hdf_intermediate     
            ENDIF
            CALL update_print_flags                        ! Update times for next printouts
            CALL time_step_save                            ! Save values for next time step 

            IF(errexe) EXIT
            IF(prcpd) CALL dump_hst                        ! not functional   
            CALL time_parallel(16)                         ! 16 - 15, write files 
        ENDDO                                              ! End transient time step
    ENDIF                                                  ! End transient loop
50  CONTINUE   ! ... Exit, could be error

    ! ...  Cleanup and shutdown
    status = RM_MpiWorkerBreak(rm_id)          ! stop loop in worker
    status = RM_LogMessage(rm_id, 'Done with transient flow and transport simulation.')
    status = RM_ScreenMessage(rm_id, 'Done with transient flow and transport simulation.')
    IF(errexe .OR. errexi) then
        status = RM_LogMessage(rm_id, 'ERROR exit.')
        status = RM_ScreenMessage(rm_id, 'ERROR exit.')
    endif

#ifdef USE_MPI
    CALL MPI_Barrier(MPI_COMM_WORLD, ierrmpi)
    status = RM_LogMessage(rm_id, 'Exit manager process.')
    status = RM_ScreenMessage(rm_id, 'Exit manager process.')
#endif

    ! ... Cleanup reaction module
    CALL FH_FinalizeFiles() 
    status = RM_CloseFiles(rm_id)
    if (RM_Destroy(rm_id) < 0) then
        write (*,*) 'RM_Destroy failed.'
    endif

    ! ... Cleanup PHAST
    CALL terminate_phast
#ifdef USE_MPI
    if (solute .and. xp_group) then
        CALL MPI_COMM_FREE(mpi_xp_comm, ierrmpi)
    endif
#endif
END SUBROUTINE phast_manager

SUBROUTINE time_parallel(i)
    USE mcc, only: rm_id, solute
    USE mpi_mod
  USE PhreeqcRM
  IMPLICIT NONE
    integer :: i, ierr
    DOUBLE PRECISION t
    DOUBLE PRECISION, DIMENSION(0:16), save :: times
    DOUBLE PRECISION, save :: time_flow=0d0, time_transfer=0d0, time_transport=0d0, time_chemistry=0d0, time_chemistry_transfer=0d0
    DOUBLE PRECISION, save :: cum_flow=0d0, cum_transfer=0d0, cum_transport=0d0, cum_chemistry=0d0, cum_chemistry_transfer=0d0
    DOUBLE PRECISION, save :: c1=0d0, c2=0d0, c3=0d0, c4=0.0d0
    CHARACTER(LEN=130) :: logline
    INTEGER :: status
#ifndef USE_MPI
    INTEGER t_ticks, clock_rate, clock_max
#endif

#if defined(USE_MPI)
    !CALL Timing_barrier()
    t = MPI_Wtime()
#else    
    call SYSTEM_CLOCK(t_ticks, clock_rate, clock_max)
    t = real(t_ticks) / real(clock_rate)
#endif    
    if (i == 0) then
        times = -1.0
        times(0) = t
    else
        times(i) = t
    endif
    if (i == 16) then
! 1 - 0, flow and transport communication
        time_transfer = times(1) - times(0)
! 2 - 1, flow
        time_flow = times(2) - times(1)
! 3 - 2, flow and transport communication
        time_transfer = time_transfer + (times(3) - times(2))
! 4 - 3, flow
        time_flow = time_flow + (times(2) - times(1))
! 5 - 4, flow communication
        time_transfer = time_transfer + (times(5) - times(4))
! 6 - 5, transport
        time_transport = times(6) - times(5)
! 7 - 6, transport communication
        time_transfer = time_transfer + (times(7) - times(6))
! 8 - 7, sumcal
        time_transport = time_transport + (times(8) - times(7))
! 9, new time
! 10 - 9 chemistry communication
        time_chemistry_transfer = times(10) - times(9)
! 11 - 10 run cells
        time_chemistry = times(11) - times(10)
! 12 - 11 chemistry communication
        time_chemistry_transfer = time_chemistry_transfer + (times(12) - times(11))
! 13 - 12 chemistry files
        time_chemistry_transfer = time_chemistry_transfer + (times(13) - times(12))
! 14, new time
! 15 - 14, sumcal
        time_transport = time_transport + (times(15) - times(14))
! 16 - 15, write files    
        time_chemistry_transfer = time_chemistry_transfer + (times(16) - times(15))    

        
        cum_flow = cum_flow + time_flow
        cum_transport = cum_transport + time_transport
        cum_transfer = cum_transfer + time_transfer
        cum_chemistry = cum_chemistry + time_chemistry
        cum_chemistry_transfer = cum_chemistry_transfer + time_chemistry_transfer
        
        write (logline,"(t6,a26, f12.2,a17, f13.2)") "Time flow:                ", time_flow, " Cumulative:", cum_flow
        status = RM_LogMessage(rm_id, logline)
        status = RM_ScreenMessage(rm_id, logline)
        write (logline,"(t6,a26, f12.2,a17, f13.2)") "Time transport:           ", time_transport, " Cumulative:", cum_transport
        status = RM_LogMessage(rm_id, logline)
        status = RM_ScreenMessage(rm_id, logline)
        write (logline,"(t6,a26, f12.2,a17, f13.2)") "Time flow/trans messages: ", &
               time_transfer, " Cumulative:", cum_transfer
        status = RM_LogMessage(rm_id, logline)
        status = RM_ScreenMessage(rm_id, logline)
        if (solute) then
            write (logline,"(t6,a26, f12.2,a17, f13.2)") "Time chemistry:           ", &
            time_chemistry, " Cumulative:", cum_chemistry
            status = RM_LogMessage(rm_id, logline)
            status = RM_ScreenMessage(rm_id, logline) 
            write (logline,"(t6,a26, f12.2,a17, f13.2)") "Time chemistry messages:  ", &
            time_chemistry_transfer, " Cumulative:", cum_chemistry_transfer
            status = RM_LogMessage(rm_id, logline)
            status = RM_ScreenMessage(rm_id, logline)  

            c1 = c1 + times(10) - times(9)
            write (logline,"(t16,a26, f12.2,a17, f13.2)") "Chemistry send:     ", &
            times(10) - times(9), " Cumulative:", c1
            status = RM_LogMessage(rm_id, logline)
            status = RM_ScreenMessage(rm_id, logline) 

            c2 = c2 + (times(12) - times(11))
            write (logline,"(t16,a26, f12.2,a17, f13.2)") "Chemistry receive:  ", &
            (times(12) - times(11)), " Cumulative:", c2
            status = RM_LogMessage(rm_id, logline)
            status = RM_ScreenMessage(rm_id, logline) 

            c3 = c3 + (times(13) - times(12)) 
            write (logline,"(t16,a26, f12.2,a17, f13.2)") "Files 3:            ", &
            (times(13) - times(12)), " Cumulative:", c3
            status = RM_LogMessage(rm_id, logline)
            status = RM_ScreenMessage(rm_id, logline) 

            c4 = c4 + (times(16) - times(15))
            write (logline,"(t16,a26, f12.2,a17, f13.2)") "Other files:        ", &
            (times(16) - times(15)), " Cumulative:", c3
            status = RM_LogMessage(rm_id, logline)
            status = RM_ScreenMessage(rm_id, logline)
        endif
        
    endif
END SUBROUTINE time_parallel
SUBROUTINE transport_component(i) BIND(C, NAME='transport_component')
    USE ISO_C_BINDING
    USE mcc, ONLY: cylind, errexe, errexi, rm_id
    USE mcw, ONLY: nwel
    USE XP_module,  ONLY: xp_list
    IMPLICIT none
    INTEGER(kind=C_INT) :: i
    CALL coeff_trans
    CALL XP_rhsn(xp_list(i))
    IF(nwel > 0) THEN
        IF(cylind) THEN
            CALL XP_wellsc(xp_list(i))
        ELSE
            CALL XP_wellsr(xp_list(i))
        END IF
    END IF
    CALL XP_aplbce(xp_list(i))
    CALL XP_asmslc(xp_list(i))
    CALL XP_sumcal1(xp_list(i))
    IF(errexe .OR. errexi) write (*,*) "transport_component failed."
END SUBROUTINE transport_component
    
SUBROUTINE transport_component_thread(i) BIND(C, NAME='transport_component_thread')
    USE ISO_C_BINDING
    USE mcc, ONLY: mpi_myself, cylind, errexe, errexi, rm_id
    USE mcw, ONLY: nwel
    USE XP_module, ONLY: xp_list, XP_init_thread, XP_free_thread
    IMPLICIT none
    INTEGER(kind=C_INT) :: i
    CALL XP_init_thread(xp_list(i))
    CALL XP_coeff_trans_thread(xp_list(i))
    CALL XP_rhsn_thread(xp_list(i))
    IF(nwel > 0) THEN
        IF(cylind) THEN
            CALL XP_wellsc_thread(xp_list(i))
        ELSE
            CALL XP_wellsr_thread(xp_list(i))
        END IF
    END IF
    CALL XP_aplbce_thread(xp_list(i))
    CALL XP_asmslc_thread(xp_list(i))
    CALL XP_sumcal1(xp_list(i))
    CALL XP_free_thread(xp_list(i))
    IF(errexe .OR. errexi) write(*,*) "transport_component_thread failed."
END SUBROUTINE transport_component_thread
    
SUBROUTINE CreateRM 
    USE mcc,  ONLY: rm_id, solute
    USE mcch, ONLY: f1name, f2name, f3name, comp_name
    USE mcg,  ONLY: nxyz
    USE mcs,  ONLY: nthreads
    USE mcv,  ONLY: ns
    USE mpi_mod
    USE PhreeqcRM
    IMPLICIT NONE
    SAVE 
    INTEGER i, a_err, status
    CHARACTER*32 string

    ! ... make a reaction module, makes instances of IPhreeqc and IPhreeqcPhast with same rm_id
#ifdef USE_MPI  
    rm_id = RM_Create(nxyz, world_comm)      
#else
    rm_id = RM_Create(nxyz, nthreads)
#endif 
    status = RM_SetFilePrefix(rm_id, f3name)
    status = RM_OpenFiles(rm_id)  
    IF (solute) THEN         
        IF (rm_id.LT.0) THEN
            STOP
        END IF
        status = RM_SetComponentH2O(rm_id, 1)
        nthreads = RM_GetThreadCount(rm_id)
        status = RM_SetErrorHandlerMode(rm_id, 2)   ! exit
        status = RM_SetPrintChemistryOn(rm_id, 0, 1, 0) 
        status = RM_UseSolutionDensityVolume(rm_id, 0)
        status = RM_LoadDatabase(rm_id, f2name)
        !... Call phreeqc, find number of components, f1name, chem.dat, f2name, database, f3name, prefix
        status = RM_LogMessage(rm_id, "Initial PHREEQC run.") 
        status = RM_ScreenMessage(rm_id, "Initial PHREEQC run.")  
        status = RM_RunFile(rm_id, 1, 1, 1, f1name) 
        ! end of line needs care in Fortran
        string = 'DELETE; -all' // char(0)
        status = RM_RunString(rm_id, 1, 0, 1, trim(string))
        if (status .ne. 0) stop "Failed DELETE in CreateRM"
        status = RM_FindComponents(rm_id)    
        status = RM_LogMessage(rm_id, "Done with Initial PHREEQC run.")
        status = RM_ScreenMessage(rm_id, "Done with Initial PHREEQC run.")
    ENDIF
END SUBROUTINE CreateRM
  
SUBROUTINE InitialEquilibrationRM 
    USE machine_constants, ONLY: kdp
    USE mcc, ONLY:               iprint_xyz, prcphrqi, prf_chem_phrqi, prhdfci, rm_id, solute, steady_flow
    USE mcg, ONLY:               grid2chem, nxyz
    USE mcn, ONLY:               x_node, y_node, z_node, phreeqc_density, pv0, por, volume
    USE mcp, ONLY:               pv
    USE mcv, ONLY:               c, frac, sat, time_phreeqc
    USE hdf_media_m, ONLY:       pr_hdf_media
    USE PhreeqcRM
    IMPLICIT NONE
    SAVE
    DOUBLE PRECISION :: deltim_dummy
    CHARACTER(LEN=130) :: logline1
    INTEGER :: stop_msg, status, i !, imedia
    
    ! ...  Initial equilibrate
    IF (solute) THEN
        deltim_dummy = 0._kdp
        ! ... Equilibrate the initial conditions for component concentrations
        WRITE(logline1,'(a)') 'Equilibration of cells for initial conditions.'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
        stop_msg = 0
        deltim_dummy = 0._kdp
        ! Set porosity
        do i = 1, nxyz
            if (volume(i) .ne. 0.0d0) then
                por(i) = pv0(i)/volume(i)
            else
                por(i) = 1.0d0
            endif
        enddo
        status = RM_SetPorosity(rm_id, por)

        sat = 1.0
        do i = 1, nxyz
            if (frac(i) <= 0.0) then
                sat(i) = 0.0
            endif
        enddo
        status = RM_SetSaturation(rm_id, sat)
        status = RM_SetPrintChemistryOn(rm_id, prf_chem_phrqi, 0, 0)
	    status = 0
	    if (prhdfci .ne. 0 .or. prcphrqi .ne. 0) status = 1
        status = RM_SetSelectedOutputOn(rm_id, status)
        status = RM_SetTime(rm_id, time_phreeqc) 
        status = RM_SetTimeStep(rm_id, deltim_dummy) 
        status = RM_SetConcentrations(rm_id, c)
        status = RM_RunCells(rm_id)     
        !status = RM_GetConcentrations(rm_id, c(1,1))
        status = RM_GetConcentrations(rm_id, c)
        !status = RM_GetDensity(rm_id, phreeqc_density(1))
        !status = RM_SetDensity(rm_id, phreeqc_density(1))
    ENDIF  
    !imedia = 0
    !if (pr_hdf_media) imedia = 1
    !CALL FH_WriteFiles(rm_id, prhdfci,  imedia, prcphrqi, &
	   ! iprint_xyz(1), 0)       
END SUBROUTINE InitialEquilibrationRM
    
SUBROUTINE InitializeRM 
    USE mcc, ONLY:               iprint_xyz, prcphrqi, prhdfci, rm_id, solute
    USE mcb, ONLY:  fresur
    USE mcc, ONLY:  iprint_chem,iprint_xyz, prcphrqi, prhdfci, rebalance_fraction_f, rebalance_method_f, rm_id, solute, steady_flow
    USE mcch, ONLY: num_restart_files, restart_files
    USE mcg, ONLY:  grid2chem, nxyz
    USE mcn, ONLY:  x_node, y_node, z_node, pv0, volume, por
    USE mcp, ONLY:  cnvtmi
    USE mcv, ONLY:  c, frac, indx_sol1_ic, indx_sol2_ic, ic_mxfrac 
    USE mcv_m, ONLY: exchange_units, gasphase_units, kinetics_units, ppassemblage_units, ssassemblage_units, surface_units

    USE PhreeqcRM
    IMPLICIT NONE
    SAVE
    INTERFACE    
        SUBROUTINE CreateMappingFortran(ic)
            implicit none
            INTEGER, DIMENSION(:,:), ALLOCATABLE, INTENT(INOUT) :: ic
        END SUBROUTINE CreateMappingFortran
    END INTERFACE
    INTEGER a_err, i, j, status
    INTEGER ipartition_uz_solids
    INTEGER, DIMENSION(:,:), ALLOCATABLE :: ic1_reordered, ic2_reordered
    DOUBLE PRECISION, DIMENSION(:,:), ALLOCATABLE :: f1_reordered
    DOUBLE PRECISION, DIMENSION(:), ALLOCATABLE :: rv
 
    IF(solute) THEN

        ! ... Send data to threads or workers
        status = RM_SetUnitsSolution(rm_id, 3)
        status = RM_SetUnitsExchange(rm_id, exchange_units)
        status = RM_SetUnitsGasPhase(rm_id, gasphase_units)
        status = RM_SetUnitsKinetics(rm_id, kinetics_units)
        status = RM_SetUnitsPPassemblage(rm_id, ppassemblage_units)
        status = RM_SetUnitsSSassemblage(rm_id, ssassemblage_units)
        status = RM_SetUnitsSurface(rm_id, surface_units)            
        status = RM_SetTimeConversion(rm_id, cnvtmi)

        allocate (rv(nxyz))
        rv = 1.0
        status = RM_SetRepresentativeVolume(rm_id, rv)
        deallocate(rv)
        status = RM_SetPrintChemistryMask(rm_id, iprint_chem)
	    status = 0
        if (prhdfci .ne. 0 .or. prcphrqi .ne. 0) status = 1
        status = RM_SetSelectedOutputOn(rm_id, status)
        !if (fresur .and. .not. steady_flow) then
        if (fresur) then
            ipartition_uz_solids = 1
        else
            ipartition_uz_solids = 0
        endif
        !ipartition_uz_solids = 0
        status = RM_SetPartitionUZSolids(rm_id, ipartition_uz_solids)
 
        ! Set porosity
        do i = 1, nxyz
            if (volume(i) .ne. 0.0d0) then
                por(i) = pv0(i)/volume(i)
            else
                por(i) = 1.0d0
            endif
        enddo
        status = RM_SetPorosity(rm_id, por)
        
        status = RM_SetRebalanceFraction(rm_id, rebalance_fraction_f)
        status = RM_SetRebalanceByCell(rm_id, rebalance_method_f)

        ! ... Define mapping from 3D domain to chemistry
        CALL CreateMappingFortran(indx_sol1_ic)
        status = RM_CreateMapping(rm_id, grid2chem)    
        
        ! Set Basic callback for cell_volume, cell_saturation, cell_porosity, and cell_pore_volume
        CALL register_basic_callback_fortran()
        
        ! ... Make arrays in the correct order
        ALLOCATE(ic1_reordered(nxyz,7), ic2_reordered(nxyz,7), f1_reordered(nxyz,7),   &
        STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: InitializeRM"  
            STOP
        ENDIF
        DO i = 1, nxyz
            do j = 1, 7
                ic1_reordered(i,j) = indx_sol1_ic(j,i)
                ic2_reordered(i,j) = indx_sol2_ic(j,i)
                f1_reordered(i,j) = ic_mxfrac(j,i)
            enddo
        enddo
          
        ! ... Distribute chemistry initial conditions
        status = RM_InitialPhreeqc2Module(rm_id, &
            ic1_reordered,           & ! Fortran nxyz x 7 end-member 1 
            ic2_reordered,           & ! Fortran nxyz x 7 end-member 2
            f1_reordered)              ! Fortran nxyz x 7 fraction of end-member 1   
        
        CALL process_restart_files()
        status = RM_GetConcentrations(rm_id, c)          
        
        DEALLOCATE (ic1_reordered, ic2_reordered, f1_reordered, &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array deallocation failed: InitializeRM"  
            STOP
        ENDIF
            ENDIF        ! ... solute
END SUBROUTINE InitializeRM
    
SUBROUTINE TimeStepRM    
    USE mcb, ONLY:               fresur
    USE mcc, ONLY:               iprint_xyz, rm_id, solute, steady_flow
    USE mcc_m, ONLY:             prcphrq, prhdfc
    USE mcg, ONLY:               grid2chem, nxyz
    USE mcn, ONLY:               x_node, y_node, z_node, phreeqc_density, volume, por
    USE mcp, ONLY:               pv
    USE mcv,  ONLY:              c, deltim, frac, indx_sol1_ic, sat, time, ns
    USE hdf_media_m, ONLY:       pr_hdf_media
    USE print_control_mod, ONLY: print_force_chemistry, print_hdf_chemistry, print_restart
    USE PhreeqcRM
    IMPLICIT NONE
    SAVE
    INTEGER stop_msg, status, i, j !, ihdf, ixyz, imedia
    CHARACTER(LEN=130) :: logline1
    
    stop_msg = 0
    IF (solute) THEN
        CALL time_parallel(9)                                     ! 9 new time
        WRITE(logline1,'(a)') '     Beginning chemistry calculation.'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
        if (.not.steady_flow) then
          
            do i = 1, nxyz
                if (volume(i) .ne. 0.0d0) then
                    por(i) = pv(i)/volume(i)
                else
                    por(i) = 1.0d0
                endif
            enddo
            status = RM_SetPorosity(rm_id, por)            
        endif
        if (fresur.and.(.not.steady_flow)) then
            sat = frac
            do i = 1, nxyz
                if (frac(i) <= 0.0) then
                    sat(i) = 0.0
                else if (frac(i) > 1.0) then
                    sat(i) = 1.0
                endif
            enddo
            status = RM_SetSaturation(rm_id, sat)
        endif
        status = RM_SetPrintChemistryOn(rm_id, print_force_chemistry%print_flag_integer, 0, 0)
	    status = 0
        if (prhdfc .or. prcphrq) status = 1
        status = RM_SetSelectedOutputOn(rm_id, status)
        
        status = RM_SetTime(rm_id, time) 
        status = RM_SetTimeStep(rm_id, deltim) 
        status = RM_SetConcentrations(rm_id, c)
        CALL time_parallel(10)                                    ! 10 - 9 chemistry communication
        status = RM_RunCells(rm_id)  
        CALL time_parallel(11)                                    ! 11 - 10 run cells
        status = RM_GetConcentrations(rm_id, c)
        !status = RM_GetDensity(rm_id, phreeqc_density(1))
        !status = RM_SetDensity(rm_id, phreeqc_density(1))
        CALL time_parallel(12)                                    ! 12 - 11 chemistry communication
    ENDIF    ! ... Done with chemistry    
    !ihdf = 0
    !if (prhdfc) ihdf = 1
    !imedia = 0
    !if (pr_hdf_media) imedia = 1 
    !ixyz = 0
    !if (prcphrq) ixyz = 1        
    !CALL FH_WriteFiles(rm_id, ihdf, imedia, ixyz, &
    !    iprint_xyz(1), print_restart%print_flag_integer) 
    CALL time_parallel(13)                                    ! 13 - 12 chemistry files
END SUBROUTINE TimeStepRM   
    
INTEGER FUNCTION set_components()
    USE mcc, ONLY:               mpi_myself, rm_id, solute
    USE mcch, ONLY:              comp_name
    USE mcv, ONLY:               ns
    USE mpi_mod
    USE PhreeqcRM
    IMPLICIT NONE
    SAVE
    integer method, a_err, i, status
    ! makes the list of components on the Fortran side.
#ifdef USE_MPI    
    if (mpi_myself == 0) then
        CALL MPI_BCAST(METHOD_SETCOMPONENTS, 1, MPI_INTEGER, manager, world_comm, ierrmpi)  
    endif
#endif    
    !ns = RM_FindComponents(rm_id)
    ns = RM_GetComponentCount(rm_id)
    ALLOCATE(comp_name(ns),  & 
    STAT = a_err)
    IF (a_err /= 0) THEN
        PRINT *, "Array allocation failed: phast_manager, point 0"  
        STOP
    ENDIF
    DO i = 1, ns
        comp_name(i) = ' '
        status = RM_GetComponent(rm_id, i, comp_name(i))
    ENDDO  
    set_components = 0
END FUNCTION set_components 
SUBROUTINE process_restart_files()
    USE mcc, ONLY: mpi_myself, rm_id
    USE mcch
    USE mcg
    USE mcn
    USE mcv
    USE mpi_mod
    USE ISO_C_BINDING
    IMPLICIT NONE 
    INTERFACE
	SUBROUTINE FH_SetPhreeqcRM(rm_id) BIND(C, NAME='FH_SetPhreeqcRM')
	   USE ISO_C_BINDING
           IMPLICIT NONE
           INTEGER(kind=C_INT), INTENT(in) :: rm_id
        END SUBROUTINE FH_SetPhreeqcRM
	SUBROUTINE FH_SetNodes(x_node, y_node, z_node) BIND(C, NAME='FH_SetNodes')
	   USE ISO_C_BINDING
           IMPLICIT NONE
           REAL(kind=C_DOUBLE), INTENT(in) :: x_node(*), y_node(*), z_node(*)
        END SUBROUTINE FH_SetNodes
	SUBROUTINE FH_ProcessRestartFiles(indx_sol1_ic,            &
 	        indx_sol2_ic,            & 
	        ic_mxfrac) &
           BIND(C, NAME='FH_ProcessRestartFiles')
	   USE ISO_C_BINDING
           IMPLICIT NONE
           INTEGER(kind=C_INT), INTENT(in) :: indx_sol1_ic(*), indx_sol2_ic(*)
           REAL(kind=C_DOUBLE), INTENT(in) :: ic_mxfrac(*)
        END SUBROUTINE FH_ProcessRestartFiles
	SUBROUTINE FH_SetRestartName(string) BIND(C, NAME='FH_SetRestartName')
	   USE ISO_C_BINDING
           IMPLICIT NONE
           CHARACTER(kind=C_CHAR), INTENT(in) :: string(*)
        END SUBROUTINE FH_SetRestartName

    END INTERFACE
    INTEGER :: i
#ifdef USE_MPI  
    if (mpi_myself == 0) then
        CALL MPI_BCAST(METHOD_PROCESSRESTARTFILES, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
    endif
#endif 
    CALL FH_SetPhreeqcRM(rm_id)
    DO i = 1, num_restart_files
        CALL FH_SetRestartName(trim(restart_files(i))//C_NULL_CHAR)
    ENDDO
    !CALL FH_SetPointers(x_node(1), y_node(1), z_node(1), indx_sol1_ic(1,1), frac(1), grid2chem(1))
    CALL FH_SetNodes(x_node, y_node, z_node)
    CALL FH_ProcessRestartFiles(&
	        indx_sol1_ic,            &
	        indx_sol2_ic,            & 
	        ic_mxfrac)
    END SUBROUTINE process_restart_files 
    
INTEGER FUNCTION set_fdtmth()
    USE mcc, ONLY: mpi_myself
    USE mcp
    USE mpi_mod
    IMPLICIT NONE 
    INTEGER :: i
#ifdef USE_MPI  
    if (mpi_myself == 0) then
        CALL MPI_BCAST(METHOD_SETFDTMTH, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
    endif
    CALL MPI_BCAST(fdtmth, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
#endif 
    set_fdtmth = 0
    END FUNCTION set_fdtmth 
    
SUBROUTINE run_transport
    USE mcc, ONLY: mpi_myself, rm_id
    USE mcs, ONLY: nthreads
    USE mcv, ONLY: local_ns
    USE mpi_mod
    IMPLICIT NONE 
    INTERFACE
        SUBROUTINE TM_transport(rm_id, local_ns, nthreads) &
			BIND(C, NAME='TM_transport')
	    USE ISO_C_BINDING
            IMPLICIT NONE
            INTEGER(KIND=C_INT), INTENT(in) :: rm_id, local_ns, nthreads
        END SUBROUTINE TM_transport
    END INTERFACE
    INTEGER :: i
#ifdef USE_MPI  
    if (mpi_myself == 0) then
        CALL MPI_BCAST(METHOD_RUNTRANSPORT, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
    endif 
#endif 
    CALL TM_transport(rm_id, local_ns, nthreads)
END SUBROUTINE run_transport    
    
SUBROUTINE convert_to_moles(id, c, n)
    USE PhreeqcRM
    IMPLICIT NONE
    DOUBLE PRECISION, INTENT(inout), DIMENSION(:,:) :: c
    INTEGER, INTENT(in) :: id, n
    DOUBLE PRECISION, DIMENSION(:), ALLOCATABLE :: gfw
    INTEGER :: a_err, i, k, ncomps, status
    
    ! converts c from kg/kgs to mol/kgs
    ncomps = RM_GetComponentCount(id)
    if (ncomps > 0) then
        ALLOCATE (gfw(ncomps),  &
        STAT = a_err)
        IF (a_err /= 0) THEN  
            PRINT *, "Array allocation failed: convert_to_moles"
            STOP
        ENDIF 
        status = RM_GetGfw(id, gfw)
        DO i = 1, n        
            DO k = 1, ncomps    
                ! kg/kgs * 1000 / gfw = mol/kgs
                c(i,k) = c(i,k) * 1000.0 / gfw(k)
            ENDDO
        ENDDO
        DEALLOCATE (gfw)
    ENDIF
    
END SUBROUTINE convert_to_moles  
SUBROUTINE Timing_barrier()
    USE mcc, ONLY: mpi_myself, solute
    USE mpi_mod
    IMPLICIT NONE 
    INTEGER :: i
    if (solute) then
#ifdef USE_MPI  
        if (mpi_myself == 0) then
            CALL MPI_BCAST(METHOD_TIMINGBARRIER, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
        endif 
        CALL MPI_BARRIER(world_comm, ierrmpi)
#endif 
    endif
    END SUBROUTINE Timing_barrier  
    
REAL(kind=C_DOUBLE) FUNCTION my_basic_fortran_callback(x1, x2, str, l) BIND(C, name='my_basic_fortran_callback')
    USE ISO_C_BINDING
    USE PhreeqcRM
    USE mcv, only : frac
    USE mcc, only : rm_id
    USE mcn, only : volume, pv0
    IMPLICIT none
    INTERFACE
        Pure Function to_lower (str) Result (string)
            Character(*), Intent(In) :: str
            Character(LEN(str))      :: string 
        end function to_lower
    END INTERFACE

    REAL(kind=C_DOUBLE),    INTENT(in)        :: x1, x2
    CHARACTER(kind=C_CHAR), INTENT(in)        :: str(*)
    INTEGER(kind=C_INT),    INTENT(in), value :: l
    character(100) fstr

    INTEGER :: list(4), i, j
    INTEGER :: size=4, rm_cell_number
    
    do i = 1, l
        fstr(i:i) = str(i)
    enddo
    fstr = to_lower(fstr)
	rm_cell_number = DINT(x1)
    my_basic_fortran_callback = -999.9
	if (rm_cell_number .ge. 0 .and. rm_cell_number < RM_GetChemistryCellCount(rm_id)) then
		if (RM_GetBackwardMapping(rm_id, rm_cell_number, list, size) .eq. 0) then
            j = list(1)+1
			if (fstr(1:l) .eq. "cell_volume") then
				my_basic_fortran_callback = volume(j) * 1000.
            else if (fstr(1:l) .eq. "cell_pore_volume") then
				my_basic_fortran_callback = pv0(j) * 1000.0  
            else if (fstr(1:l) .eq. "cell_saturation") then
				my_basic_fortran_callback = frac(j)
            else if (fstr(1:l) .eq. "cell_porosity") then
                if (volume(j) .gt. 0.0d0) then
				    my_basic_fortran_callback = pv0(j) / volume(j) 
                else
                    my_basic_fortran_callback = 0.0d0
                endif
            endif
        endif
    endif
END FUNCTION my_basic_fortran_callback
Pure Function to_lower (str) Result (string)

!   ==============================
!   Changes a string to lower case
!   ==============================

    Implicit None
    Character(*), Intent(In) :: str
    Character(LEN(str))      :: string

    Integer :: ic, i

    Character(26), Parameter :: cap = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    Character(26), Parameter :: low = 'abcdefghijklmnopqrstuvwxyz'

!   Lower case each letter if it is upper case
    string = str
    do i = 1, LEN_TRIM(str)
        ic = INDEX(cap, str(i:i))
        if (ic > 0) string(i:i) = low(ic:ic)
    end do

End Function to_lower

SUBROUTINE register_basic_callback_fortran()
    USE IPhreeqc
    USE PhreeqcRM
    USE mpi_mod
    USE mcc, only : rm_id
    USE ISO_C_BINDING
    implicit none
    INTERFACE
        REAL(kind=C_DOUBLE) FUNCTION my_basic_fortran_callback(x1, x2, str, l) BIND(C)
            USE ISO_C_BINDING
            IMPLICIT none
            REAL(kind=C_DOUBLE), INTENT(in)           :: x1, x2
            CHARACTER(kind=C_CHAR), INTENT(in)        :: str(*)
            INTEGER(kind=C_INT),    INTENT(in), value :: l
        END FUNCTION my_basic_fortran_callback   
    END INTERFACE    

	integer status 
    integer i, j, mpi_myself, method
    
    mpi_myself = RM_GetMpiMyself(rm_id)
    
#ifdef USE_MPI    
	if (mpi_myself == 0) then
		method = METHOD_REGISTERBASICCALLBACK;
		CALL MPI_Bcast(method, 1, MPI_INT, 0, MPI_COMM_WORLD, status)
    endif
#endif 
    do i = 1, RM_GetThreadCount(rm_id) + 2
		j = RM_GetIPhreeqcId(rm_id, i-1)
		j = SetBasicFortranCallback(j, my_basic_fortran_callback)
    enddo
END SUBROUTINE register_basic_callback_fortran