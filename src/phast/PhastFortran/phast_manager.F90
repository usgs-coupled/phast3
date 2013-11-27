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
    INCLUDE 'RM_interface.f90.inc'
    CHARACTER(LEN=130) :: logline1
    INTEGER :: i, a_err
    INTEGER status
    !     ------------------------------------------------------------------

    !...

    errexi=.FALSE.
    errexe=.FALSE.
!
! ... static data, group 1
!
    CALL openf
    CALL read1              ! ... Read fundamental information, dimensioning data
    CALL read1_distribute
    
    ! Create Reaction Module(s)
    CALL CreateRM
    ! ... Map components to processes for transport calculations
    CALL set_component_map

    !... Call init1
    CALL init1
    CALL error1
    IF(errexi) GO TO 50
    CALL write1
!
! ... time-invariant data, group 2
!    
    CALL read2
    CALL init2_1
    !pv0 = pv                           ! geometric pv
    CALL group2_distribute             ! Tranfer data to workers
  
    ! ... Create transporters
    CALL create_transporters

    CALL init2_2
    !IF (.NOT.steady_flow) THEN
    !    pv0 = pv                       ! pressure corrected pv
    !ENDIF
    CALL error2

    ! ...  Initialize Reaction Module
    CALL InitializeRM
 
    CALL error4
    ! ... write2_1 must be called after distribute_initial_conditions and equilibrate
    ! ... Write initial condition results 
    CALL write2_1

    IF(errexi) GO TO 50 

    ! ... Calculate steady flow
    IF(steady_flow) THEN
        CALL simulate_ss_flow          ! ... calls read3 and init3
        CALL init3_distribute
    ENDIF

    ! ... Write zone flows 
    CALL zone_flow_write_heads

    IF(errexe .OR. errexi) GO TO 50

    ! ... Use Reaction Module to equilbrate cells    
    CALL InitialEquilibrationRM

    IF (solute) THEN
        CALL TM_zone_flow_write_chem(print_zone_flows_xyzt%print_flag_integer)
        CALL init2_3        
    ENDIF

    ! ...  Write initial results
    CALL write2_2
    IF (steady_flow) THEN
        CALL write3
        CALL write4
    ENDIF

    ! ... distribute  initial p and c_w to workers from manager
    CALL flow_distribute

    IF(errexe .OR. errexi) GO TO 50
!
! ...  Transient loop
!
    IF(solute .OR. .NOT.steady_flow) THEN
        logline1 = 'Beginning transient simulation.'
        CALL RM_LogScreenMessage(logline1)
        fdtmth = fdtmth_tr     ! ... set time differencing method to transient
        DO
            CALL time_parallel(0)
            CALL c_distribute
            CALL p_distribute
            CALL time_parallel(1)
            IF (.NOT. steady_flow) THEN
                CALL coeff_flow
                CALL rhsn_flow
            ENDIF
                CALL sumcal0_manager

            ! ... Read the transient data, if necessary. The first block was read by the steady flow 
            ! ... simulation section
            
            DO WHILE(time*one_plus_eps >= timchg)     ! ... skip past data blocks until
                ! ...         restart time is reached
                CALL read3
                CALL init3
                CALL time_parallel(2)                 ! ... only for timing
                CALL init3_distribute
                CALL time_parallel(3)
                IF(thru) EXIT                         ! ... Normal exit from time step loop
                CALL error3
                CALL write3
                IF(errexi) EXIT
            END DO                
            CALL time_parallel(4)
            CALL thru_distribute
            CALL time_parallel(5)
            IF (thru) EXIT        ! ... second step of exit

            ! ... Calculate transient flow
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

            ! ... Check for errors
            IF(errexe) THEN
                CALL write5
                EXIT
            END IF
20          CALL timestep
            CALL write6           ! ... print conductance values

            ! .... Send transient flow to workers
            IF(.NOT.steady_flow) THEN
                CALL asmslp_flow
                CALL time_parallel(6)
                CALL flow_distribute
                CALL time_parallel(7)
            ENDIF
            CALL time_parallel(8)

            ! ... At this point, worker and manager do transport calculations
            IF (solute) THEN
                logline1 =  '     Beginning solute-transport calculation.'
                CALL RM_LogScreenMessage(logline1)
                DO i = 1, ns
                    logline1 =  '          '//comp_name(i)
                    CALL RM_LogScreenMessage(logline1)
                ENDDO
            ENDIF
            IF (local_ns > 0) THEN 
                CALL TM_transport(rm_id, local_ns, nthreads)
            ENDIF

            IF(errexe .OR. errexi) GO TO 50
#if defined USE_MPI      
            if (solute) CALL MPI_Barrier(world, ierrmpi)
#endif
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
            ! ... Done with transport for time step

            ! ... Equilibrate the solutions with PHREEQC
            ! ... This is the connection to the equilibration step after transport
            CALL time_parallel(11) 
            
            ! ... Run cells in Reaction Module
            CALL TimeStepRM

            CALL time_parallel(12)
            CALL sumcal2
            CALL time_parallel(13)
            CALL write5
            IF(przf_xyzt .AND. .NOT.steady_flow) THEN  
                CALL zone_flow_write_heads
            ENDIF
            CALL TM_zone_flow_write_chem(print_zone_flows_xyzt%print_flag_integer)
            IF (.NOT.steady_flow) THEN
                CALL write4
            ENDIF

            IF (prhdfii == 1) THEN
                CALL write_hdf_intermediate     
            ENDIF
            
            CALL update_print_flags          ! ... Update times for next printouts

            ! ... Save values for next time step
            CALL time_step_save

            IF(errexe) EXIT
            IF(prcpd) CALL dump_hst        
        ENDDO  ! ... End transient loop
    ENDIF
50  CONTINUE   ! ... Exit, could be error

    ! ...  Cleanup and shutdown
    CALL RM_LogScreenMessage('Done with transient flow and transport simulation.')
    IF(errexe .OR. errexi) CALL RM_LogScreenMessage('ERROR exit.')

#ifdef USE_MPI
    CALL MPI_Barrier(MPI_COMM_WORLD, ierrmpi)
    CALL RM_LogScreenMessage('Exit manager process.')
#endif

    ! ... Cleanup reaction module
	CALL FinalizeFiles();
    IF (solute) THEN  
        if (RM_Destroy(rm_id) < 0) CALL RM_error(rm_id)     
    ENDIF
    CALL RM_CloseFiles()

    ! ... Cleanup PHAST
    CALL terminate_phast
END SUBROUTINE phast_manager

SUBROUTINE time_parallel(i)
#if defined(USE_MPI)
USE mpi_mod
USE mpi
#endif
IMPLICIT none   
integer :: i, ierr
DOUBLE PRECISION t
DOUBLE PRECISION, DIMENSION(0:15), save :: times
DOUBLE PRECISION, save :: time_flow=0, time_transfer, time_transport, time_chemistry
DOUBLE PRECISION, save :: cum_flow=0, cum_transfer=0, cum_transport=0, cum_chemistry
CHARACTER(LEN=130) :: logline
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
        CALL RM_LogScreenMessage(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time transport:          ", time_transport, " Cumulative:", cum_transport
        CALL RM_LogScreenMessage(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Transport data transfer: ", time_transfer, " Cumulative:", cum_transfer
        CALL RM_LogScreenMessage(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time chemistry:          ", time_chemistry, " Cumulative:", cum_chemistry
        CALL RM_LogScreenMessage(logline)     
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
    IF(errexe .OR. errexi) CALL RM_error(rm_id)
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
    IF(errexe .OR. errexi) CALL RM_error(rm_id)
    END SUBROUTINE transport_component_thread
    
SUBROUTINE CreateRM 
    USE mcc,  ONLY: rm_id, solute
    USE mcch, ONLY: f1name, f2name, f3name, comp_name
    USE mcg,  ONLY: nxyz
    USE mcs,  ONLY: nthreads
    USE mcv,  ONLY: ns
    IMPLICIT NONE
    SAVE
    INCLUDE 'RM_interface.f90.inc'
    INTEGER i, a_err, status
    
    ! ... make a reaction module; makes instances of IPhreeqc and IPhreeqcPhast with same rm_id
    rm_id = RM_Create(nxyz, nthreads)
    IF (rm_id.LT.0) THEN
        STOP
    END IF
    
    status = RM_LoadDatabase(rm_id, f2name);
    status = RM_OpenFiles(rm_id, f3name)
  
    !... Call phreeqc, find number of components; f1name, chem.dat; f2name, database; f3name, prefix
    IF (solute) THEN
        CALL RM_LogScreenMessage("Initial PHREEQC run.")  
        status = RM_InitialPhreeqcRun(rm_id, f1name) 
        ! Set components
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
        CALL RM_LogScreenMessage("Done with Initial PHREEQC run.")
    ENDIF
END SUBROUTINE CreateRM
  
SUBROUTINE InitialEquilibrationRM 
    USE machine_constants, ONLY: kdp
    USE mcc, only: iprint_xyz, prcphrqi, prf_chem_phrqi, prhdfci, rm_id, solute, steady_flow
    USE mcg, only: grid2chem
    USE mcn, only: x_node, y_node, z_node
    USE mcp, only: pv
    USE mcv, only: c, frac, time_phreeqc
    USE hdf_media_m, only: pr_hdf_media
    IMPLICIT NONE
    SAVE
    INCLUDE 'RM_interface.f90.inc' 
    DOUBLE PRECISION :: deltim_dummy
    CHARACTER(LEN=130) :: logline1
    INTEGER :: stop_msg
    
    ! ...  Initial equilibrate
    IF (solute) THEN
        deltim_dummy = 0._kdp
        ! ... Equilibrate the initial conditions for component concentrations
        WRITE(logline1,'(a)') 'Equilibration of cells for initial conditions.'
        CALL RM_LogScreenMessage(logline1)
        stop_msg = 0
        deltim_dummy = 0._kdp
        CALL RM_SetPoreVolume(rm_id, pv(1))
        CALL RM_SetSaturation(rm_id, frac(1))
        CALL RM_set_printing(rm_id, prf_chem_phrqi, prhdfci, 0)
        CALL RM_RunCells(      &
            rm_id,              &
            time_phreeqc,       &        ! time_hst
            deltim_dummy,       &        ! time_step
            c(1,1),             &        ! fraction
            stop_msg) 
        CALL WriteFiles(rm_id, prhdfci, prcphrqi,  pr_hdf_media, &
	        x_node(1), y_node(1), z_node(1), iprint_xyz(1), &
	        frac(1), grid2chem(1)); 
    ENDIF       
END SUBROUTINE InitialEquilibrationRM
    
SUBROUTINE InitializeRM 
    USE mcb, only: fresur
    USE mcc, only: iprint_chem, rebalance_fraction_f, rebalance_method_f, rm_id, solute, steady_flow
    USE mcch, only: num_restart_files, restart_files
    USE mcg, only: grid2chem
    USE mcn, only: x_node, y_node, z_node, pv0, volume
    USE mcp, only: cnvtmi
    USE mcv, only: c, indx_sol1_ic, indx_sol2_ic, ic_mxfrac 

    IMPLICIT NONE
    SAVE
    INCLUDE 'RM_interface.f90.inc'
    INTERFACE
        SUBROUTINE CreateMappingFortran(ic)
            implicit none
            INTEGER, DIMENSION(:,:), ALLOCATABLE, INTENT(INOUT) :: ic
        END SUBROUTINE CreateMappingFortran
    END INTERFACE
    INTEGER i, status
    INTEGER ifresur, isteady_flow
    
    ifresur = fresur
    isteady_flow = steady_flow   
    IF(solute) THEN

        ! ... Send data to threads or workers
        
        CALL RM_SetInputUnits (rm_id, 3, 1, 1, 1, 1, 1, 1)
        CALL RM_set_nodes(rm_id, x_node(1), y_node(1), z_node(1))
        CALL RM_SetTimeConversion(rm_id, cnvtmi)
        CALL RM_SetPoreVolumeZero(rm_id, pv0(1))
        CALL RM_set_print_chem_mask(rm_id, iprint_chem(1))
        CALL RM_set_free_surface(rm_id, ifresur)
        CALL RM_set_steady_flow(rm_id, isteady_flow)
        CALL RM_SetCellVolume(rm_id, volume(1))
        CALL RM_SetRebalance(rm_id, rebalance_method_f, rebalance_fraction_f)

        ! ... Define mapping from 3D domain to chemistry
        CALL CreateMappingFortran(indx_sol1_ic)
        status = RM_CreateMapping(rm_id, grid2chem(1))
        
        DO i = 1, num_restart_files
            CALL RM_send_restart_name(rm_id, restart_files(i))
        ENDDO

        ! ... Distribute chemistry initial conditions
        status = RM_distribute_initial_conditions_mix(rm_id, &
            indx_sol1_ic(1,1),           & ! 7 x nxyz end-member 1 
            indx_sol2_ic(1,1),           & ! 7 x nxyz end-member 2
            ic_mxfrac(1,1))                ! 7 x nxyz fraction of end-member 1

        ! collect solutions at manager for transport
        CALL RM_Module2Concentrations(rm_id, c(1,1))
    ENDIF        ! ... solute
END SUBROUTINE InitializeRM
    
SUBROUTINE TimeStepRM    
    USE mcc, only: iprint_xyz, prcphrqi, prhdfci, rm_id, solute
    USE mcg, only: grid2chem
    USE mcn, only: x_node, y_node, z_node
    USE mcp, only: pv
    USE mcv, only: c, deltim, frac, time
    USE hdf_media_m,       ONLY: pr_hdf_media
    USE print_control_mod, only: print_force_chemistry, print_hdf_chemistry, print_restart
    IMPLICIT NONE
    SAVE
    INCLUDE 'RM_interface.f90.inc' 
    INTEGER stop_msg
    CHARACTER(LEN=130) :: logline1
    
    stop_msg = 0
    IF (solute) THEN
        WRITE(logline1,'(a)') '     Beginning chemistry calculation.'
        CALL RM_LogScreenMessage(logline1)
        CALL RM_SetPoreVolume(rm_id, pv(1))
        CALL RM_SetSaturation(rm_id, frac(1))
        CALL RM_set_printing(rm_id,                     &
            print_force_chemistry%print_flag_integer,   & 
            print_hdf_chemistry%print_flag_integer,     & 
            print_restart%print_flag_integer)
        CALL RM_RunCells(                               &
            rm_id,                                      &
            time,                                       &        ! time_hst
            deltim,                                     &        ! time_step_hst
            c(1,1),                                     &        ! fraction
            stop_msg) 
        CALL WriteFiles(rm_id, prhdfci, prcphrqi,  pr_hdf_media, &
            x_node(1), y_node(1), z_node(1), iprint_xyz(1), &
            frac(1), grid2chem(1)) 

    ENDIF    ! ... Done with chemistry    
END SUBROUTINE TimeStepRM    