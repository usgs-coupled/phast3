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
    IMPLICIT NONE 
    SAVE
    INCLUDE 'RM_interface_F.f90.inc'
    INTERFACE
        INTEGER FUNCTION set_fdtmth
        END FUNCTION set_fdtmth
    END INTERFACE
    CHARACTER(LEN=130) :: logline1
    INTEGER :: i, a_err
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
        CALL write4
    ENDIF
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
            CALL time_parallel(1)
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
            DO WHILE(time*one_plus_eps >= timchg)          ! skip past data blocks until
                ! ...         restart time is reached
                CALL read3
                CALL init3
                CALL time_parallel(2)                      ! only for timing
                CALL init3_distribute
                CALL time_parallel(3)
                IF(thru) EXIT                              ! Normal exit from time step loop
                CALL error3
                CALL write3
                IF(errexi) EXIT
            END DO  
            CALL time_parallel(4)
            CALL time_parallel(5)
            IF (thru) then
                status = RM_MpiWorkerBreak(rm_id)          ! stop loop in worker
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
                CALL time_parallel(6)
                CALL flow_distribute
                CALL time_parallel(7)
            ENDIF
            CALL time_parallel(8)
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
            CALL time_parallel(9)
            CALL sbc_gather
            CALL c_gather
            CALL time_parallel(10)
            IF (steady_flow) THEN
                CALL sumcal1_manager
            ELSE
                CALL sumcal1
            ENDIF
            IF(tsfail .AND. .NOT.errexe) GO TO 20
            !
            ! ... React cells with PhreeqcRM, process and write results
            !
            CALL time_parallel(11) 
            CALL TimeStepRM                                ! Run cells in Reaction Module, return concentrations
            CALL time_parallel(12)
            CALL sumcal2                                   ! Calculate summary fluxes
            CALL time_parallel(13)
            CALL write5                                    ! Write results
            IF(przf_xyzt .AND. .NOT.steady_flow) THEN  
                CALL zone_flow_write_heads
            ENDIF
	        CALL zone_flow_write_chem()
            IF (.NOT.steady_flow) THEN
                CALL write4
            ENDIF
            IF (prhdfii == 1) THEN
                CALL write_hdf_intermediate     
            ENDIF
            
            CALL update_print_flags                        ! Update times for next printouts
            CALL time_step_save                            ! Save values for next time step 

            IF(errexe) EXIT
            IF(prcpd) CALL dump_hst                        ! not functional        
        ENDDO                                              ! End transient time step
    ENDIF                                                  ! End transient loop
50  CONTINUE   ! ... Exit, could be error

    ! ...  Cleanup and shutdown
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
	CALL FH_FinalizeFiles();
    IF (solute) THEN  
        if (RM_Destroy(rm_id) < 0) then
            write (*,*) 'RM_Destroy failed.'
        endif
    ENDIF
    status = RM_CloseFiles(rm_id)

    ! ... Cleanup PHAST
    CALL terminate_phast
END SUBROUTINE phast_manager

SUBROUTINE time_parallel(i)
    USE mcc, only: rm_id
#if defined(USE_MPI)
USE mpi_mod
USE mpi
#endif
IMPLICIT none   
    INCLUDE "RM_interface_F.f90.inc"
integer :: i, ierr
DOUBLE PRECISION t
DOUBLE PRECISION, DIMENSION(0:15), save :: times
DOUBLE PRECISION, save :: time_flow=0, time_transfer, time_transport, time_chemistry
DOUBLE PRECISION, save :: cum_flow=0, cum_transfer=0, cum_transport=0, cum_chemistry
CHARACTER(LEN=130) :: logline
  INTEGER :: status
#ifndef USE_MPI
INTEGER t_ticks, clock_rate, clock_max
#endif

#if defined(USE_MPI)
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
    if (i == 13) then
        ! C_distribute + p_distribute
        time_transfer = times(1) - times(0)
        
        ! logic for read3
        if (times(2) > 0) then
            time_flow = times(2) - times(1)
            ! init3_distribute
            time_transfer = time_transfer + (times(3) - times(2))
            time_flow = time_flow + (times(4) - times(3))
        else
            time_flow = times(4) - times(1)
        endif
        
        ! thru distribute
        time_transfer = time_transfer + (times(5) - times(4))
        
        ! not steady flow
        if (times(6) > 0) then
            time_flow = time_flow + (times(6) - times(5))
            time_transfer = time_transfer + (times(7) - times(6))
            time_flow = time_flow + (times(8) - times(7))
        else
            time_flow = time_flow + (times(8) - times(5))
        endif
                
        ! transport
        time_transport = times(9) - times(8)
        time_transfer = time_transfer + (times(10) - times(9))
        time_flow = time_flow + (times(11) - times(10))
        time_chemistry = times(12) - times(11)
        time_flow = time_flow + (times(13) - times(12))
        
        cum_flow = cum_flow + time_flow
        cum_transport = cum_transport + time_transport
        cum_transfer = cum_transfer + time_transfer
        cum_chemistry = cum_chemistry + time_chemistry
        
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time flow:               ", time_flow, " Cumulative:", cum_flow
        status = RM_LogMessage(rm_id, logline)
        status = RM_ScreenMessage(rm_id, logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time transport:          ", time_transport, " Cumulative:", cum_transport
        status = RM_LogMessage(rm_id, logline)
        status = RM_ScreenMessage(rm_id, logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Transport data transfer: ", time_transfer, " Cumulative:", cum_transfer
        status = RM_LogMessage(rm_id, logline)
        status = RM_ScreenMessage(rm_id, logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time chemistry:          ", time_chemistry, " Cumulative:", cum_chemistry
        status = RM_LogMessage(rm_id, logline)
        status = RM_ScreenMessage(rm_id, logline)  
    endif
END SUBROUTINE time_parallel

SUBROUTINE transport_component(i)
    USE mcc, ONLY: cylind, errexe, errexi, rm_id
    USE mcw, ONLY: nwel
    USE XP_module,  ONLY: xp_list
    IMPLICIT none
    INTEGER :: i
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
    
SUBROUTINE transport_component_thread(i)
    USE mcc, ONLY: mpi_myself, cylind, errexe, errexi, rm_id
    USE mcw, ONLY: nwel
    USE XP_module, ONLY: xp_list, XP_init_thread, XP_free_thread
    IMPLICIT none
    INTEGER :: i
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
    IMPLICIT NONE
    SAVE
    INCLUDE 'RM_interface_F.f90.inc'
    INTERFACE
        INTEGER FUNCTION set_components() 
        END FUNCTION set_components
    END INTERFACE
    INTEGER i, a_err, status
  
    IF (solute) THEN  
        ! ... make a reaction module; makes instances of IPhreeqc and IPhreeqcPhast with same rm_id
#ifdef USE_MPI  
        rm_id = RM_Create(nxyz, world_comm)      
#else
        rm_id = RM_Create(nxyz, nthreads)
#endif        
        IF (rm_id.LT.0) THEN
            STOP
        END IF
        nthreads = RM_GetThreadCount(rm_id)
        status = RM_SetErrorHandlerMode(rm_id, 2)   ! exit
        status = RM_SetPrintChemistryOn(rm_id, 0, 1, 0) 
        status = RM_SetFilePrefix(rm_id, f3name)
        status = RM_OpenFiles(rm_id)
        status = RM_LoadDatabase(rm_id, f2name);
        !... Call phreeqc, find number of components; f1name, chem.dat; f2name, database; f3name, prefix
        status = RM_LogMessage(rm_id, "Initial PHREEQC run.") 
        status = RM_ScreenMessage(rm_id, "Initial PHREEQC run.")  
        status = RM_RunFile(rm_id, 1, 1, 1, f1name) 
        ! Set components
        status = set_components()       
        status = RM_LogMessage(rm_id, "Done with Initial PHREEQC run.")
        status = RM_ScreenMessage(rm_id, "Done with Initial PHREEQC run.")
    ENDIF
END SUBROUTINE CreateRM
  
SUBROUTINE InitialEquilibrationRM 
    USE machine_constants, ONLY: kdp
    USE mcc, ONLY:               iprint_xyz, prcphrqi, prf_chem_phrqi, prhdfci, rm_id, solute, steady_flow
    USE mcg, ONLY:               grid2chem, nxyz
    USE mcn, ONLY:               x_node, y_node, z_node
    USE mcp, ONLY:               pv
    USE mcv, ONLY:               c, frac, sat, time_phreeqc
    USE hdf_media_m, ONLY:       pr_hdf_media
    IMPLICIT NONE
    SAVE
    INCLUDE 'RM_interface_F.f90.inc' 
    DOUBLE PRECISION :: deltim_dummy
    CHARACTER(LEN=130) :: logline1
    INTEGER :: stop_msg, status, i
    
    ! ...  Initial equilibrate
    IF (solute) THEN
        deltim_dummy = 0._kdp
        ! ... Equilibrate the initial conditions for component concentrations
        WRITE(logline1,'(a)') 'Equilibration of cells for initial conditions.'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
        stop_msg = 0
        deltim_dummy = 0._kdp
        status = RM_SetPoreVolume(rm_id, pv(1))
        sat = 1.0
        do i = 1, nxyz
            if (frac(i) <= 0.0) then
                sat(i) = 0.0
            endif
        enddo
        status = RM_SetSaturation(rm_id, sat(1))
        status = RM_SetPrintChemistryOn(rm_id, prf_chem_phrqi, 0, 0)
	    status = 0
	    if (prhdfci .ne. 0 .or. prcphrqi .ne. 0) status = 1
        status = RM_SetSelectedOutputOn(rm_id, status)
        status = RM_SetTime(rm_id, time_phreeqc) 
        status = RM_SetTimeStep(rm_id, deltim_dummy) 
        status = RM_SetConcentrations(rm_id, c(1,1))
        status = RM_RunCells(rm_id)    
        CALL FH_WriteFiles(rm_id, prhdfci,  pr_hdf_media, prcphrqi, &
	        iprint_xyz(1), 0);  
    ENDIF       
END SUBROUTINE InitialEquilibrationRM
    
SUBROUTINE InitializeRM 
    USE mcc, ONLY:               iprint_xyz, prcphrqi, prhdfci, rm_id, solute
    USE mcb, ONLY:  fresur
    USE mcc, ONLY:  iprint_chem,iprint_xyz, prcphrqi, prhdfci, rebalance_fraction_f, rebalance_method_f, rm_id, solute, steady_flow
    USE mcch, ONLY: num_restart_files, restart_files
    USE mcg, ONLY:  grid2chem, nxyz
    USE mcn, ONLY:  x_node, y_node, z_node, pv0, volume
    USE mcp, ONLY:  cnvtmi
    USE mcv, ONLY:  c, frac, indx_sol1_ic, indx_sol2_ic, ic_mxfrac 
    USE mcv_m, ONLY: exchange_units, gasphase_units, kinetics_units, ppassemblage_units, ssassemblage_units, surface_units

    IMPLICIT NONE
    SAVE
    INCLUDE 'RM_interface_F.f90.inc'
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
        status = RM_SetPoreVolume(rm_id, pv0(1))
        !status = RM_SetPoreVolumeZero(rm_id, pv0(1))
        !status = RM_SetSaturation(rm_id, sat(1))
        status = RM_SetPrintChemistryMask(rm_id, iprint_chem(1))
	    status = 0
        if (prhdfci .ne. 0 .or. prcphrqi .ne. 0) status = 1
        status = RM_SetSelectedOutputOn(rm_id, status)
        if (fresur .and. .not. steady_flow) then
            ipartition_uz_solids = 1
        else
            ipartition_uz_solids = 0
        endif
        !status = RM_SetPartitionUZSolids(rm_id, ipartition_uz_solids)
        status = RM_SetCellVolume(rm_id, volume(1))
        status = RM_SetRebalanceFraction(rm_id, rebalance_fraction_f)
        status = RM_SetRebalanceByCell(rm_id, rebalance_method_f)

        ! ... Define mapping from 3D domain to chemistry
        CALL CreateMappingFortran(indx_sol1_ic)
        status = RM_CreateMapping(rm_id, grid2chem(1))        
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
            ic1_reordered(1,1),           & ! Fortran nxyz x 7 end-member 1 
            ic2_reordered(1,1),           & ! Fortran nxyz x 7 end-member 2
            f1_reordered(1,1))              ! Fortran nxyz x 7 fraction of end-member 1   
        
        CALL process_restart_files
        status = RM_GetConcentrations(rm_id, c(1,1))      
        
        DEALLOCATE (ic1_reordered, ic2_reordered, f1_reordered, &
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array deallocation failed: InitializeRM"  
            STOP
        ENDIF
    ENDIF        ! ... solute
END SUBROUTINE InitializeRM
    
SUBROUTINE TimeStepRM    
    USE mcc, ONLY:               iprint_xyz, rm_id, solute
    USE mcc_m, ONLY:             prcphrq, prhdfc
    USE mcg, ONLY:               grid2chem, nxyz
    USE mcn, ONLY:               x_node, y_node, z_node
    USE mcp, ONLY:               pv
    USE mcv,  ONLY:              c, deltim, frac, indx_sol1_ic, sat, time
    USE hdf_media_m, ONLY:       pr_hdf_media
    USE print_control_mod, ONLY: print_force_chemistry, print_hdf_chemistry, print_restart
    IMPLICIT NONE
    SAVE
    INCLUDE 'RM_interface_F.f90.inc' 
    INTEGER stop_msg, status, i
    CHARACTER(LEN=130) :: logline1
    
    stop_msg = 0
    IF (solute) THEN
        WRITE(logline1,'(a)') '     Beginning chemistry calculation.'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
        status = RM_SetPoreVolume(rm_id, pv(1))
        sat = 1.0
        do i = 1, nxyz
            if (frac(i) <= 0.0) then
                sat(i) = 0.0
            endif
        enddo
        status = RM_SetSaturation(rm_id, sat(1))
        
        status = RM_SetPrintChemistryOn(rm_id, print_force_chemistry%print_flag_integer, 0, 0)
	    status = 0
        if (prhdfc .ne. 0 .or. prcphrq .ne. 0) status = 1
        status = RM_SetSelectedOutputOn(rm_id, status)
        
        status = RM_SetTime(rm_id, time) 
        status = RM_SetTimeStep(rm_id, deltim) 
        status = RM_SetConcentrations(rm_id, c(1,1))
        status = RM_RunCells(rm_id)  
        status = RM_GetConcentrations(rm_id, c(1,1))
        
        CALL FH_WriteFiles(rm_id, prhdfc, pr_hdf_media, prcphrq, &
            iprint_xyz(1), print_restart%print_flag_integer) 
    ENDIF    ! ... Done with chemistry    
END SUBROUTINE TimeStepRM   
    
INTEGER FUNCTION set_components 
    USE mcc, ONLY:               mpi_myself, rm_id, solute
    USE mcch, ONLY:              comp_name
    USE mcv, ONLY:               ns
    USE mpi_mod
    IMPLICIT NONE 
    SAVE
    INCLUDE 'RM_interface_F.f90.inc'  
    integer method, a_err, i, status
    
#ifdef USE_MPI    
    if (mpi_myself == 0) then
        CALL MPI_BCAST(METHOD_SETCOMPONENTS, 1, MPI_INTEGER, manager, world_comm, ierrmpi)  
    endif
#endif    
    ns = RM_FindComponents(rm_id)
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
INTEGER FUNCTION process_restart_files 
    USE mcc, ONLY: mpi_myself, rm_id
    USE mcch
    USE mcg
    USE mcn
    USE mcv
    USE mpi_mod
    IMPLICIT NONE 
    INTEGER :: i
#ifdef USE_MPI  
    if (mpi_myself == 0) then
        CALL MPI_BCAST(METHOD_PROCESSRESTARTFILES, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
    endif
#endif 
    DO i = 1, num_restart_files
        CALL FH_SetRestartName(restart_files(i))
    ENDDO
    CALL FH_SetPointers(x_node(1), y_node(1), z_node(1), indx_sol1_ic(1,1), frac(1), grid2chem(1))
    CALL FH_ProcessRestartFiles(rm_id, &
	        indx_sol1_ic(1,1),            &
	        indx_sol2_ic(1,1),            & 
	        ic_mxfrac(1,1))
    process_restart_files = 0
    END FUNCTION process_restart_files 
    
INTEGER FUNCTION set_fdtmth
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
    
INTEGER FUNCTION run_transport
    USE mcc, ONLY: mpi_myself, rm_id
    USE mcs, ONLY: nthreads
    USE mcv, ONLY: local_ns
    USE mpi_mod
    IMPLICIT NONE 
    INTEGER :: i
#ifdef USE_MPI  
    if (mpi_myself == 0) then
        CALL MPI_BCAST(METHOD_RUNTRANSPORT, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
    endif 
#endif 
    CALL TM_transport(rm_id, local_ns, nthreads)
    run_transport = 0
END FUNCTION run_transport    
    
SUBROUTINE convert_to_moles(id, c, n)
    IMPLICIT NONE 
    INCLUDE "RM_interface_F.f90.inc"
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
        status = RM_GetGfw(id, gfw(1))
        DO i = 1, n        
            DO k = 1, ncomps    
                ! kg/kgs * 1000 / gfw = mol/kgs
                c(i,k) = c(i,k) * 1000.0 / gfw(k)
            ENDDO
        ENDDO
        DEALLOCATE (gfw)
    ENDIF
    
END SUBROUTINE convert_to_moles  