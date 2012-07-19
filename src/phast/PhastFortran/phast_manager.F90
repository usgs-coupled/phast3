SUBROUTINE phast_manager
  ! ... The top level routine for the manager process that manages the simulation
  ! ...     and does the groundwater flow calculation.
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE mcb
  USE mcc
  USE mcc_m
  USE mcch, ONLY: f1name, f2name, f3name, version_name, comp_name
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
  USE mpi_mod
  USE mpi_struct_arrays
  USE print_control_mod
  USE XP_module
  IMPLICIT NONE
  include "IPhreeqc.f90.inc"
  REAL(KIND=kdp) :: deltim_dummy
  INTEGER :: stop_msg, print_restart_flag
  CHARACTER(LEN=130) :: logline1
  INTEGER :: i
  INTERFACE
     FUNCTION RM_create() RESULT(iout)
       IMPLICIT NONE
       INTEGER :: iout
     END FUNCTION RM_create
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

  CALL openf
  CALL read1              ! ... Read fundamental information, dimensioning data
  CALL read1_distribute

  ! make IPhreeqc for phreeqc_main
  ipp_phrq_id = RM_CreateIPhreeqcPhast()
  IF (ipp_phrq_id.LT.0) THEN
     STOP
  END IF
  ! make a reaction module
  rm_id = RM_create(ipp_phrq_id)
  IF (rm_id.LT.0) THEN
     STOP
  END IF

  !... Call phreeqc, find number of components
  CALL phreeqc_main(solute, f1name, f2name, f3name, mpi_tasks, mpi_myself)
  
#ifdef SKIP_REWRITE_PHAST

  CALL on_error_cleanup_and_exit

  !... Call init1
  CALL init1
  CALL error1
  IF(errexi) GO TO 50
  CALL write1
  CALL set_component_map

  ! ... Read the time invariant data
  CALL read2
  CALL init2_1
  ! ... Tranfer data to workers
  CALL group2_distribute

  ! ... Create transporters
  CALL create_transporters

  CALL init2_2
  CALL error2
#if defined(HDF5_CREATE)
  CALL hdf_write_invariant(mpi_myself)
  CALL hdf_begin_time_step
#endif
  !
  ! ...  Initialize chemistry 
  ! 
  IF(solute) THEN

#if defined(USE_MPI)
     CALL worker_get_indexes(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, naxes, nxyz,  &
          x_node, y_node, z_node, cnvtmi, transient_fresur, steady_flow, pv0,  &
          rebalance_method_f, volume, tort, npmz, &
          exchange_units, surface_units, ssassemblage_units,  &
          ppassemblage_units, gasphase_units, kinetics_units)
#endif
     CALL store_c_pointers(indx_sol1_ic, x_node, y_node, z_node)
     CALL forward_and_back(indx_sol1_ic, naxes, nx, ny, nz)  
     !CALL distribute_initial_conditions(indx_sol1_ic, indx_sol2_ic, ic_mxfrac,  &
     !     exchange_units, surface_units, ssassemblage_units,  &
     !     ppassemblage_units, gasphase_units, kinetics_units,  &
     !     pv0, volume)
     CALL RM_distribute_initial_conditions(rm_id, &
	indx_sol1_ic,		& ! 7 x nxyz end-member 1 
	indx_sol2_ic,		& ! 7 x nxyz end-member 2
	ic_mxfrac,		& ! 7 x nxyz fraction of end-member 1
	exchange_units,	& ! water (1) or rock (2)
	surface_units,		& ! water (1) or rock (2)
	ssassemblage_units,	& ! water (1) or rock (2)		
	ppassemblage_units,  & ! water (1) or rock (2)
	gasphase_units,	& ! water (1) or rock (2)
	kinetics_units	)	  ! water (1) or rock (2)

     CALL uz_init(transient_fresur)
#if defined(USE_MPI)
     CALL collect_from_nonroot(c, nxyz) ! stores data for transport
#else
     CALL pack_for_hst(c,nxyz)
#endif
  ENDIF        ! ... solute
  CALL error4
  ! ... write2_1 must be called after distribute_initial_conditions and equilibrate
  ! ... Write initial condition results 
  CALL write2_1
  IF(errexi) GO TO 50 
  !
  ! ...  Calculate steady flow
  !
  IF(steady_flow) THEN
     CALL simulate_ss_flow          ! ... calls read3 and init3
     CALL init3_distribute
  ENDIF

  IF(errexe .OR. errexi) GO TO 50
  !
  ! ...  Initial equilibrate
  !
  IF (solute) THEN
     ! ... Equilibrate the initial conditions for component concentrations
     WRITE(logline1,'(a)') 'Equilibration of cells for initial conditions.'
     CALL logprt_c(logline1)
     CALL screenprt_c(logline1)
     print_restart_flag = 0 
     stop_msg = 0
     deltim_dummy = 0._kdp
     CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time_phreeqc,deltim_dummy,prslmi,  &
          cnvtmi,frac_icchem,iprint_chem,iprint_xyz,  &
          prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f,  &
          print_restart_flag, pv, pv0, steady_flow, volume)
     CALL init2_3        
  ENDIF
  !
  ! ...  Write initial results
  !
  CALL write2_2
  IF (steady_flow) THEN
     CALL write3
     CALL write4
  ENDIF
#if defined(HDF5_CREATE)
  CALL hdf_end_time_step          ! ... Print HDF head and velocity fields
#endif
  !   
  ! ... distribute  initial p and c_w to workers from manager
  !
  CALL flow_distribute
!!$  CALL p_distribute

  IF(errexe .OR. errexi) GO TO 50
  !
  ! ...  Transient loop
  !    
  IF(solute .OR. .NOT.steady_flow) THEN
     logline1 = 'Beginning transient simulation.'
     CALL screenprt_c(logline1)
     CALL logprt_c(' ')
     CALL logprt_c(logline1)
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
        ! ...     simulation section

        DO WHILE(time*one_plus_eps >= timchg)     ! ... skip past data blocks until
           ! ...         restart time is reached
           CALL read3
           CALL init3

           CALL time_parallel(2)
           CALL init3_distribute
           CALL time_parallel(3)
           IF(thru) EXIT      ! ... Normal exit from time step loop
           CALL error3
           CALL write3
           IF(errexi) EXIT
        END DO
        CALL time_parallel(4)
        CALL thru_distribute
        CALL time_parallel(5)
        IF (thru) EXIT        ! ... second step of exit

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
           CALL write5
           EXIT
        END IF
20      CALL timestep
        CALL write6           ! ... print conductance values
        IF(.NOT.steady_flow) THEN
           CALL asmslp
           CALL time_parallel(6)
           CALL flow_distribute
           CALL time_parallel(7)
        ENDIF
        CALL time_parallel(8)
        IF (solute) THEN
           logline1 =  '     Beginning solute-transport calculation.'
           CALL logprt_c(logline1)
           CALL screenprt_c(logline1)
           DO i = 1, ns
              logline1 =  '          '//comp_name(i)
              CALL logprt_c(logline1)
              CALL screenprt_c(logline1)
           ENDDO
        ENDIF

        ! ...  At this point, worker and manager do transport calculations
        IF (local_ns > 0) THEN 
           DO i = 1, local_ns
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
              IF(errexe .OR. errexi) EXIT
           ENDDO
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
        !
        ! ... Done with transport for time step
        !
#if defined(HDF5_CREATE)
        CALL hdf_begin_time_step
#endif
        ! ... Equilibrate the solutions with PHREEQC
        ! ... This is the connection to the equilibration step after transport
        CALL time_parallel(11)        
        IF (solute) THEN
           stop_msg = 0
           WRITE(logline1,'(a)') '     Beginning chemistry calculation.'
           CALL logprt_c(logline1)
           CALL screenprt_c(logline1)
           CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time,deltim,prslmi,cnvtmi,  &
                frac,iprint_chem,iprint_xyz,prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f,  &
                print_restart%print_flag_integer, pv, pv0, steady_flow, volume)
        ENDIF
        CALL time_parallel(12)
        CALL sumcal2
        CALL time_parallel(13)
        CALL write5
        IF (.NOT.steady_flow) THEN
           CALL write4
        ENDIF
#if defined(HDF5_CREATE)
        CALL hdf_end_time_step
#endif            
        CALL update_print_flags          ! ... Update times for next printouts
        !
        !  Save values for next time step
        !
        CALL time_step_save

        IF(errexe) EXIT
        IF(prcpd) CALL dump_hst
        !
        ! ... Done with chemistry for time step
        !
     ENDDO
  ENDIF

50 CONTINUE
  !
  ! ...  Cleanup and shutdown
  !
  logline1 = 'Done with transient flow and transport simulation.'
  CALL logprt_c(logline1)
  CALL screenprt_c(logline1)
  IF(errexe .OR. errexi) THEN
     logline1 = 'ERROR exit.'
     CALL logprt_c(logline1)
     CALL screenprt_c(logline1)
  END IF
#ifdef USE_MPI
  CALL MPI_BARRIER(MPI_COMM_WORLD, ierrmpi)
  PRINT *, 'Flow and Transport Simulation Completed; exit manager process ', mpi_myself
#endif
  CALL terminate_phast
#endif
END SUBROUTINE phast_manager
SUBROUTINE time_parallel(i)
INTEGER :: i
#if defined(USE_MPI)
USE mpi_mod
IMPLICIT none
integer :: ierr
DOUBLE PRECISION t
DOUBLE PRECISION, DIMENSION(0:15), save :: times
DOUBLE PRECISION, save :: time_flow=0, time_transfer, time_transport, time_chemistry
DOUBLE PRECISION, save :: cum_flow=0, cum_transfer=0, cum_transport=0, cum_chemistry
CHARACTER(LEN=130) :: logline

    t = MPI_WTIME()

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
        CALL logprt_c(logline)
        CALL screenprt_c(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time transport:          ", time_transport, " Cumulative:", cum_transport
        CALL logprt_c(logline)
        CALL screenprt_c(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Transport data transfer: ", time_transfer, " Cumulative:", cum_transfer
        CALL logprt_c(logline)
        CALL screenprt_c(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time chemistry:          ", time_chemistry, " Cumulative:", cum_chemistry
        CALL logprt_c(logline)
        CALL screenprt_c(logline)       
    endif

#endif
END SUBROUTInE time_parallel
#ifdef SKIP
SUBROUTINE phast_manager
  ! ... The top level routine for the manager process that manages the simulation
  ! ...     and does the groundwater flow calculation.
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE mcb
  USE mcc
  USE mcc_m
  USE mcch, ONLY: f1name, f2name, f3name, version_name, comp_name
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
  USE mpi_mod
  USE mpi_struct_arrays
  USE print_control_mod
  USE XP_module
  IMPLICIT NONE
  REAL(KIND=kdp) :: deltim_dummy
  INTEGER :: stop_msg, print_restart_flag
  CHARACTER(LEN=130) :: logline1
  INTEGER :: i
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: phast_manager.F90,v 1.6 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
#ifdef USE_MPI
  PRINT *, 'Starting manager process ', mpi_myself
#endif
  errexi=.FALSE.
  errexe=.FALSE.

  CALL openf
  CALL read1              ! ... Read fundamental information, dimensioning data
  CALL read1_distribute

  !... Call phreeqc, find number of components
  CALL phreeqc_main(solute, f1name, f2name, f3name, mpi_tasks, mpi_myself)
  CALL on_error_cleanup_and_exit

  !... Call init1
  CALL init1
  CALL error1
  IF(errexi) GO TO 50
  CALL write1
  CALL set_component_map

  ! ... Read the time invariant data
  CALL read2
  CALL init2_1
  ! ... Tranfer data to workers
  CALL group2_distribute

  ! ... Create transporters
  CALL create_transporters

  CALL init2_2
  CALL error2
#if defined(HDF5_CREATE)
  CALL hdf_write_invariant(mpi_myself)
  CALL hdf_begin_time_step
#endif
  !
  ! ...  Initialize chemistry 
  ! 
  IF(solute) THEN

#if defined(USE_MPI)
     CALL worker_get_indexes(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, naxes, nxyz,  &
          x_node, y_node, z_node, cnvtmi, transient_fresur, steady_flow, pv0,  &
          rebalance_method_f, volume, tort, npmz, &
          exchange_units, surface_units, ssassemblage_units,  &
          ppassemblage_units, gasphase_units, kinetics_units)
#endif
     CALL store_c_pointers(indx_sol1_ic, x_node, y_node, z_node)
     CALL forward_and_back(indx_sol1_ic, naxes, nx, ny, nz)  
     CALL distribute_initial_conditions(indx_sol1_ic, indx_sol2_ic, ic_mxfrac,  &
          exchange_units, surface_units, ssassemblage_units,  &
          ppassemblage_units, gasphase_units, kinetics_units,  &
          pv0, volume)
     CALL uz_init(transient_fresur)
#if defined(USE_MPI)
     CALL collect_from_nonroot(c, nxyz) ! stores data for transport
#else
     CALL pack_for_hst(c,nxyz)
#endif
  ENDIF        ! ... solute
  CALL error4
  ! ... write2_1 must be called after distribute_initial_conditions and equilibrate
  ! ... Write initial condition results 
  CALL write2_1
  IF(errexi) GO TO 50 
  !
  ! ...  Calculate steady flow
  !
  IF(steady_flow) THEN
     CALL simulate_ss_flow          ! ... calls read3 and init3
     CALL init3_distribute
  ENDIF

  IF(errexe .OR. errexi) GO TO 50
  !
  ! ...  Initial equilibrate
  !
  IF (solute) THEN
     ! ... Equilibrate the initial conditions for component concentrations
     WRITE(logline1,'(a)') 'Equilibration of cells for initial conditions.'
     CALL logprt_c(logline1)
     CALL screenprt_c(logline1)
     print_restart_flag = 0 
     stop_msg = 0
     deltim_dummy = 0._kdp
     CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time_phreeqc,deltim_dummy,prslmi,  &
          cnvtmi,frac_icchem,iprint_chem,iprint_xyz,  &
          prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f,  &
          print_restart_flag, pv, pv0, steady_flow, volume)
     CALL init2_3        
  ENDIF
  !
  ! ...  Write initial results
  !
  CALL write2_2
  IF (steady_flow) THEN
     CALL write3
     CALL write4
  ENDIF
#if defined(HDF5_CREATE)
  CALL hdf_end_time_step          ! ... Print HDF head and velocity fields
#endif
  !   
  ! ... distribute  initial p and c_w to workers from manager
  !
  CALL flow_distribute
!!$  CALL p_distribute

  IF(errexe .OR. errexi) GO TO 50
  !
  ! ...  Transient loop
  !    
  IF(solute .OR. .NOT.steady_flow) THEN
     logline1 = 'Beginning transient simulation.'
     CALL screenprt_c(logline1)
     CALL logprt_c(' ')
     CALL logprt_c(logline1)
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
        ! ...     simulation section

        DO WHILE(time*one_plus_eps >= timchg)     ! ... skip past data blocks until
           ! ...         restart time is reached
           CALL read3
           CALL init3

           CALL time_parallel(2)
           CALL init3_distribute
           CALL time_parallel(3)
           IF(thru) EXIT      ! ... Normal exit from time step loop
           CALL error3
           CALL write3
           IF(errexi) EXIT
        END DO
        CALL time_parallel(4)
        CALL thru_distribute
        CALL time_parallel(5)
        IF (thru) EXIT        ! ... second step of exit

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
           CALL write5
           EXIT
        END IF
20      CALL timestep
        CALL write6           ! ... print conductance values
        IF(.NOT.steady_flow) THEN
           CALL asmslp
           CALL time_parallel(6)
           CALL flow_distribute
           CALL time_parallel(7)
        ENDIF
        CALL time_parallel(8)
        IF (solute) THEN
           logline1 =  '     Beginning solute-transport calculation.'
           CALL logprt_c(logline1)
           CALL screenprt_c(logline1)
           DO i = 1, ns
              logline1 =  '          '//comp_name(i)
              CALL logprt_c(logline1)
              CALL screenprt_c(logline1)
           ENDDO
        ENDIF

        ! ...  At this point, worker and manager do transport calculations
        IF (local_ns > 0) THEN 
           DO i = 1, local_ns
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
              IF(errexe .OR. errexi) EXIT
           ENDDO
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
        !
        ! ... Done with transport for time step
        !
#if defined(HDF5_CREATE)
        CALL hdf_begin_time_step
#endif
        ! ... Equilibrate the solutions with PHREEQC
        ! ... This is the connection to the equilibration step after transport
        CALL time_parallel(11)        
        IF (solute) THEN
           stop_msg = 0
           WRITE(logline1,'(a)') '     Beginning chemistry calculation.'
           CALL logprt_c(logline1)
           CALL screenprt_c(logline1)
           CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time,deltim,prslmi,cnvtmi,  &
                frac,iprint_chem,iprint_xyz,prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f,  &
                print_restart%print_flag_integer, pv, pv0, steady_flow, volume)
        ENDIF
        CALL time_parallel(12)
        CALL sumcal2
        CALL time_parallel(13)
        CALL write5
        IF (.NOT.steady_flow) THEN
           CALL write4
        ENDIF
#if defined(HDF5_CREATE)
        CALL hdf_end_time_step
#endif            
        CALL update_print_flags          ! ... Update times for next printouts
        !
        !  Save values for next time step
        !
        CALL time_step_save

        IF(errexe) EXIT
        IF(prcpd) CALL dump_hst
        !
        ! ... Done with chemistry for time step
        !
     ENDDO
  ENDIF

50 CONTINUE
  !
  ! ...  Cleanup and shutdown
  !
  logline1 = 'Done with transient flow and transport simulation.'
  CALL logprt_c(logline1)
  CALL screenprt_c(logline1)
  IF(errexe .OR. errexi) THEN
     logline1 = 'ERROR exit.'
     CALL logprt_c(logline1)
     CALL screenprt_c(logline1)
  END IF
#ifdef USE_MPI
  CALL MPI_BARRIER(MPI_COMM_WORLD, ierrmpi)
  PRINT *, 'Flow and Transport Simulation Completed; exit manager process ', mpi_myself
#endif
  CALL terminate_phast

END SUBROUTINE phast_manager
SUBROUTINE time_parallel(i)
#if defined(USE_MPI)
USE mpi_mod
IMPLICIT none
integer :: i, ierr
DOUBLE PRECISION t
DOUBLE PRECISION, DIMENSION(0:15), save :: times
DOUBLE PRECISION, save :: time_flow=0, time_transfer, time_transport, time_chemistry
DOUBLE PRECISION, save :: cum_flow=0, cum_transfer=0, cum_transport=0, cum_chemistry
CHARACTER(LEN=130) :: logline

    t = MPI_WTIME()

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
        CALL logprt_c(logline)
        CALL screenprt_c(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time transport:          ", time_transport, " Cumulative:", cum_transport
        CALL logprt_c(logline)
        CALL screenprt_c(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Transport data transfer: ", time_transfer, " Cumulative:", cum_transfer
        CALL logprt_c(logline)
        CALL screenprt_c(logline)
        write (logline,"(t6,a25, f12.2,a17, f13.2)") "Time chemistry:          ", time_chemistry, " Cumulative:", cum_chemistry
        CALL logprt_c(logline)
        CALL screenprt_c(logline)       
    endif

#endif
END SUBROUTInE time_parallel
#endif 