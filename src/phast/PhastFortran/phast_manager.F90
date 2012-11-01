#ifdef USE_MPI
#include "mpi_fix_case.h"
#endif
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
    USE mcg, ONLY: naxes, nx, ny, nz, nxyz, npmz
    USE mcm
    USE mcm_m
    USE mcn, ONLY: x_node, y_node, z_node, pv0, volume
    USE mcp
    USE mcs
    USE mcv
    USE mcv_m
    USE mcw
#ifdef USE_MPI
    USE mpi_mod
    USE mpi_struct_arrays
#endif
    USE print_control_mod
    USE XP_module, ONLY: Transporter
    IMPLICIT NONE 
    SAVE
    REAL(KIND=kdp) :: deltim_dummy
    INTEGER :: stop_msg, print_restart_flag, ipp_err
    CHARACTER(LEN=130) :: logline1
    INTEGER :: i, a_err
    INTERFACE
        FUNCTION RM_create(nthreads) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: nthreads
            INTEGER :: iout
        END FUNCTION RM_create
        FUNCTION RM_destroy(id) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: iout
        END FUNCTION RM_destroy
        FUNCTION RM_find_components(id) RESULT(iout)
            IMPLICIT NONE
            INTEGER :: id
            INTEGER :: iout
        END FUNCTION RM_find_components
        SUBROUTINE RM_log_screen_prt(str) 
            IMPLICIT NONE
            CHARACTER :: str
        END SUBROUTINE RM_log_screen_prt
#ifdef USE_MPI
        SUBROUTINE worker_get_indexes(indx_sol1_ic, indx_sol2_ic, &
            mxfrac, naxes, nxyz, &
            x_node, y_node, z_node, &
            cnvtmi, transient_fresur, &
            steady_flow, pv0, &
            rebalance_method_f, volume, tort, npmz, &
            exchange_units, surface_units, ssassemblage_units, &
            ppassemblage_units, gasphase_units, kinetics_units, &
            mpi_myself)
            USE machine_constants, ONLY: kdp
            IMPLICIT NONE
            INTEGER :: indx_sol1_ic 
            INTEGER :: indx_sol2_ic 
            REAL(KIND=kdp) :: mxfrac
            INTEGER :: naxes 
            INTEGER :: nxyz    
            REAL(KIND=kdp) x_node 
            REAL(KIND=kdp) y_node
            REAL(KIND=kdp) z_node 
            REAL(KIND=kdp) cnvtmi 
            INTEGER :: transient_fresur 
            LOGICAL :: steady_flow 
            REAL(KIND=kdp) :: pv0 
            INTEGER :: rebalance_method_f          
            REAL(KIND=kdp) :: volume 
            REAL(KIND=kdp) :: tort
            INTEGER :: npmz 
            INTEGER :: exchange_units 
            INTEGER :: surface_units 
            INTEGER :: ssassemblage_units 
            INTEGER :: ppassemblage_units 
            INTEGER :: gasphase_units
            INTEGER :: kinetics_units
            INTEGER :: mpi_myself
        END SUBROUTINE worker_get_indexes
#endif
    END INTERFACE
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: phast_manager.F90,v 1.6 2011/01/29 00:18:54 klkipp Exp klkipp $'
    !     ------------------------------------------------------------------

    !...
#ifdef USE_MPI
    PRINT *, 'Starting manager process ', mpi_myself
#endif
    errexi=.FALSE.
    errexe=.FALSE.

    ! ... static data
    CALL openf
    CALL read1              ! ... Read fundamental information, dimensioning data
    CALL read1_distribute

    ! ... make a reaction module; makes instances of IPhreeqc and IPhreeqcPhast with same rm_id
    rm_id = RM_create(nthreads)
    IF (rm_id.LT.0) THEN
        STOP
    END IF

    !... only root opens files
    CALL RM_open_files(solute, f3name)
  
    !... Call phreeqc, find number of components; f1name, chem.dat; f2name, database; f3name, prefix
    IF (solute) THEN
        CALL RM_log_screen_prt("Initial PHREEQC run.")  
        CALL RM_initial_phreeqc_run(rm_id, f2name, f1name, f3name)
        ! Set components
        ns = RM_find_components(rm_id)
        ALLOCATE(comp_name(ns),  & 
            STAT = a_err)
        IF (a_err /= 0) THEN
            PRINT *, "Array allocation failed: phast_manager, point 0"  
            STOP
        ENDIF
        DO i = 1, ns
            comp_name(i) = ' '
            CALL RM_get_component(rm_id, i, comp_name(i))
        ENDDO   
        CALL RM_log_screen_prt("Done with Initial PHREEQC run.")
    ENDIF

    ipp_err = 0
    !TODO CALL on_error_cleanup_and_exit

    !... Call init1
    CALL init1
    CALL error1
    IF(errexi) GO TO 50
    CALL write1
  
    ! ... Map components to processes for transport calculations
    CALL set_component_map

    ! ... Read the time invariant data
    CALL read2
    CALL init2_1
    pv0 = pv                           ! geometric pv
    CALL group2_distribute             ! Tranfer data to workers
  
    ! ... Create transporters
    CALL create_transporters

    ! ... Finish time invariant data
    CALL init2_2
    IF (.NOT.steady_flow) THEN
        pv0 = pv                       ! pressure corrected pv
    ENDIF
    CALL error2

#if defined(HDF5_CREATE)
    CALL hdf_write_invariant(mpi_myself)
    CALL hdf_begin_time_step
#endif

    ! ...  Initialize chemistry 
    IF(solute) THEN

#if defined(USE_MPI)
        ! ... Send data to workers
        CALL worker_get_indexes(indx_sol1_ic(1,1), indx_sol2_ic(1,1), ic_mxfrac(1,1), naxes(1), nxyz,  &
        x_node(1), y_node(1), z_node(1), cnvtmi, transient_fresur, steady_flow, pv0(1),  &
        rebalance_method_f, volume(1), tort(1), npmz, &
        exchange_units, surface_units, ssassemblage_units,  &
        ppassemblage_units, gasphase_units, kinetics_units, &
        mpi_myself)
#endif

        ! ... Send data to threads or workers
        CALL RM_pass_data(rm_id,        &
            fresur,                      &
            steady_flow,                 &
            nx, ny, nz,                  &
            cnvtmi,                      &
            x_node, y_node, z_node,      &
            pv0,                         &
            volume,                      &
            iprint_chem,                 &
            iprint_xyz,                  &
            rebalance_fraction_f,        &
            c,                           &
            mpi_myself,                  &
            mpi_tasks)

        ! ... Define mapping from 3D domain to chemistry
        CALL RM_forward_and_back(rm_id, indx_sol1_ic, naxes) 
        DO i = 1, num_restart_files
            CALL RM_send_restart_name(rm_id, restart_files(i))
        ENDDO

        ! ... Distribute chemistry initial conditions
        CALL RM_distribute_initial_conditions(rm_id, &
            indx_sol1_ic,           & ! 7 x nxyz end-member 1 
            indx_sol2_ic,           & ! 7 x nxyz end-member 2
            ic_mxfrac,              & ! 7 x nxyz fraction of end-member 1
            exchange_units,         & ! water (1) or rock (2)
            surface_units,          & ! water (1) or rock (2)
            ssassemblage_units,     & ! water (1) or rock (2)		
            ppassemblage_units,     & ! water (1) or rock (2)
            gasphase_units,         & ! water (1) or rock (2)
            kinetics_units)	          ! water (1) or rock (2) 

        ! collect solutions at manager for transport
        CALL RM_solutions2fractions(rm_id)
    ENDIF        ! ... solute

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

    ! ...  Initial equilibrate
    IF (solute) THEN
        ! ... Equilibrate the initial conditions for component concentrations
        WRITE(logline1,'(a)') 'Equilibration of cells for initial conditions.'
        CALL RM_log_screen_prt(logline1)
        print_restart_flag = 0 
        stop_msg = 0
        deltim_dummy = 0._kdp
        CALL RM_run_cells(     &
            rm_id,              &
            prslmi,             &        ! prslm
            prf_chem_phrqi,     &        ! print_chem
            prcphrqi,           &        ! print_xyz
            prhdfci,            &        ! print_hdf
            print_restart_flag, &        ! print_restart
            time_phreeqc,       &        ! time_hst
            deltim_dummy,       &        ! time_step_hst
            c,                  &        ! fraction
            frac,               &        ! frac
            pv,                 &        ! pv 
            nxyz,               &
            ns,                 &
            stop_msg) 
        CALL RM_zone_flow_write_chem(print_zone_flows_xyzt%print_flag_integer)
        CALL init2_3        
    ENDIF   ! End solute

    ! ...  Write initial results
    CALL write2_2
    IF (steady_flow) THEN
        CALL write3
        CALL write4
    ENDIF
#if defined(HDF5_CREATE)
    CALL hdf_end_time_step          ! ... Print HDF head and velocity fields
#endif

    ! ... distribute  initial p and c_w to workers from manager
    CALL flow_distribute

    IF(errexe .OR. errexi) GO TO 50

    ! ...  Transient loop
    IF(solute .OR. .NOT.steady_flow) THEN
        logline1 = 'Beginning transient simulation.'
        CALL RM_log_screen_prt(logline1)
        fdtmth = fdtmth_tr     ! ... set time differencing method to transient
        DO
            CALL time_parallel(0)
            CALL c_distribute
            CALL p_distribute
            CALL time_parallel(1)
            IF (.NOT. steady_flow) THEN
                CALL coeff_flow
                CALL rhsn
            ELSE
                CALL rhsn_manager
            ENDIF

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
                CALL asmslp
                CALL time_parallel(6)
                CALL flow_distribute
                CALL time_parallel(7)
            ENDIF
            CALL time_parallel(8)

            ! ... At this point, worker and manager do transport calculations
            IF (solute) THEN
                logline1 =  '     Beginning solute-transport calculation.'
                CALL RM_log_screen_prt(logline1)
                DO i = 1, ns
                    logline1 =  '          '//comp_name(i)
                    CALL RM_log_screen_prt(logline1)
                ENDDO
            ENDIF
            IF (local_ns > 0) THEN 
                CALL RM_transport(rm_id, local_ns)
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
#if defined(HDF5_CREATE)
            CALL hdf_begin_time_step
#endif

            ! ... Equilibrate the solutions with PHREEQC
            ! ... This is the connection to the equilibration step after transport
            CALL time_parallel(11) 
    
            IF (solute) THEN
                WRITE(logline1,'(a)') '     Beginning chemistry calculation.'
                CALL RM_log_screen_prt(logline1)
                stop_msg = 0
                CALL RM_run_cells(      &
                    rm_id,              &
                    prslmi,             &        ! prslm
                    prf_chem_phrqi,     &        ! print_chem
                    prcphrqi,           &        ! print_xyz
                    prhdfci,            &        ! print_hdf
                    print_restart_flag, &        ! print_restart
                    time,               &        ! time_hst
                    deltim,             &        ! time_step_hst
                    c,                  &        ! fraction
                    frac,               &        ! frac
                    pv,                 &        ! pv 
                    nxyz,               &
                    ns,                 &
                    stop_msg) 
            ENDIF    ! ... Done with chemistry

            CALL time_parallel(12)
            CALL sumcal2
            CALL time_parallel(13)
            CALL write5
            IF(przf_xyzt .AND. .NOT.steady_flow) THEN  
                CALL zone_flow_write_heads
            ENDIF
            CALL RM_zone_flow_write_chem(print_zone_flows_xyzt%print_flag_integer)
            IF (.NOT.steady_flow) THEN
                CALL write4
            ENDIF
#if defined(HDF5_CREATE)
            CALL hdf_end_time_step
            IF (prhdfii == 1) THEN
                CALL write_hdf_intermediate     
            ENDIF
#endif            
            CALL update_print_flags          ! ... Update times for next printouts

            ! ... Save values for next time step
            CALL time_step_save

            IF(errexe) EXIT
            IF(prcpd) CALL dump_hst        
        ENDDO  ! ... End transient loop
    ENDIF
50  CONTINUE   ! ... Exit, could be error

    ! ...  Cleanup and shutdown
    CALL RM_log_screen_prt('Done with transient flow and transport simulation.')
    IF(errexe .OR. errexi) CALL RM_log_screen_prt('ERROR exit.')

#ifdef USE_MPI
    CALL MPI_Barrier(MPI_COMM_WORLD, ierrmpi)
    PRINT *, 'Flow and Transport Simulation Completed; exit manager process ', mpi_myself
#endif

    ! ... Cleanup reaction module
    IF (solute) THEN  
        if (RM_destroy(rm_id) < 0) CALL RM_error(rm_id)     
    ENDIF
    CALL RM_close_files(solute)

    ! ... Cleanup PHAST
    CALL terminate_phast
END SUBROUTINE phast_manager

SUBROUTINE time_parallel(i)
#if defined(USE_MPI)
USE mpi_mod
USE mpi
IMPLICIT none   
integer :: i, ierr
DOUBLE PRECISION t
DOUBLE PRECISION, DIMENSION(0:15), save :: times
DOUBLE PRECISION, save :: time_flow=0, time_transfer, time_transport, time_chemistry
DOUBLE PRECISION, save :: cum_flow=0, cum_transfer=0, cum_transport=0, cum_chemistry
CHARACTER(LEN=130) :: logline

    t = MPI_Wtime()

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
        CALL RM_log_screen_prt(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time transport:          ", time_transport, " Cumulative:", cum_transport
        CALL RM_log_screen_prt(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Transport data transfer: ", time_transfer, " Cumulative:", cum_transfer
        CALL RM_log_screen_prt(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time chemistry:          ", time_chemistry, " Cumulative:", cum_chemistry
        CALL RM_log_screen_prt(logline)     
    endif

#endif
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
