SUBROUTINE phast_root(mpi_tasks, mpi_myself)
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE mcb, ONLY: adj_wr_ratio, transient_fresur
  USE mcc
  USE mcch, ONLY: f1name, f2name, f3name, version_name
  USE mcg, ONLY: naxes, nx, ny, nz, nxyz
  USE mcn, ONLY: x_node, y_node, z_node
  USE mcp
  USE mcs
  USE mcv
  USE mcw
  USE print_control_mod
!!$#if defined(USE_MPI)
!!$  USE mpi_mod
!!$#endif
!  USE print_control_mod
  IMPLICIT NONE
  INTEGER, INTENT(inout) :: mpi_myself, mpi_tasks
  REAL(kind=kdp) :: time_phreeqc
  REAL(KIND=kdp) :: deltim_dummy
  INTEGER :: stop_msg
  INTEGER :: print_restart_flag
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: phast_root.F90,v 1.1 2007/01/19 19:35:56 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  !...
  errexi=.FALSE.
  errexe=.FALSE.
  ! ... Start of execution
  CALL openf
  ! ... Read memory allocation data
  CALL read1
  CALL pc_initialize
#ifdef USE_MPI
   CALL slave_get_solute(solute, nx, ny, nz)
#endif
  CALL phreeqc_main(solute, f1name, f2name, f3name, mpi_tasks, mpi_myself)
  CALL on_error_cleanup_and_exit
  IF(.NOT.restrt) CALL init1
  CALL error1
  IF(errexi) GO TO 50
  CALL write1
  IF(.NOT.restrt) THEN
  ! ... Read the time invariant data
     CALL read2
     CALL init2_1
     CALL init2_2
     CALL error2
!     time_phreeqc = 0.d0 
     time_phreeqc = time
#if defined(HDF5_CREATE)
     CALL hdf_write_invariant(mpi_myself)
#endif
#if defined(HDF5_CREATE)
     CALL hdf_begin_time_step
#endif
     IF(solute) THEN  
#ifdef USE_MPI
        CALL slave_get_indexes(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, naxes, nxyz, &
            x_node, y_node, z_node, cnvtmi, transient_fresur)
#endif
        CALL forward_and_back(indx_sol1_ic, naxes, nx, ny, nz)  
        CALL distribute_initial_conditions(indx_sol1_ic, indx_sol2_ic, ic_mxfrac)
        CALL uz_init(transient_fresur)
#ifdef USE_MPI
        CALL collect_from_nonroot(c, nxyz) ! stores data for transport
#else
        CALL pack_for_hst(c,nxyz)
#endif
     ENDIF
     CALL error4
  ENDIF
! write2_1 must be called before ss flow calculation
! write2_1 must be called after distribute_initial_conditions and equilibrate
  CALL write2_1
  IF(errexi) GO TO 50
!
!  Calculate steady flow
!
  IF(steady_flow) CALL simulate_ss_flow  ! ... Solve flow equation to steady state to obtain i.c.
  IF(errexe .OR. errexi) GO TO 50
!
!  Initial equilibrate
!
  IF (solute) THEN
     ! ... Equilibrate the initial conditions for component concentrations
!     WRITE(logline1,3201) 'Equilibration of cells for initial conditions.'
!3201 FORMAT(/a)
     WRITE(logline1,'(a)') 'Equilibration of cells for initial conditions.'
     CALL logprt_c(logline1)
     CALL screenprt_c(logline1)
     ! moved equilibrate before write2_1, where initial conditions are printed to O.comps
     ! but equilibrate needs to be called after ss calculation for correct frac
     print_restart_flag = 0 
     stop_msg = 0
     deltim_dummy = 0._kdp
     CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time_phreeqc,deltim_dummy,prslmi,  &
           cnvtmi,frac_icchem,iprint_chem,iprint_xyz, &
           prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f, &
           print_restart_flag)
     CALL init2_3
  ENDIF
!
!  Write initial results
!
  CALL write2_2
  IF (steady_flow) THEN
     CALL write3
     CALL write4
  ENDIF
#if defined(HDF5_CREATE)
  CALL hdf_end_time_step          ! ... Print HDF head and velocity fields
#endif
  IF(errexe .OR. errexi) GO TO 50
!
!  Transient loop
!
  IF(solute .OR. .NOT.steady_flow) THEN
     logline1 = 'Beginning transient simulation.'
     CALL screenprt_c(logline1)
!     WRITE(*,3001) TRIM(logline1)
!3001 FORMAT(/a)  
     CALL logprt_c(' ')
     CALL logprt_c(logline1)
     fdtmth = fdtmth_trans     ! ... set time differencing method to transient
     DO
        CALL coeff
        CALL rhsn
        ! ... Read the transient data, if necessary
        IF (time*one_plus_eps >= timchg) THEN
           CALL read3
           IF(thru) EXIT      ! ... Normal exit from time step loop
           CALL init3
           CALL error3
           CALL write3
           IF(errexi) EXIT
        END IF
        IF(nwel > 0) THEN
           IF(cylind) THEN
              CALL wellsc
           ELSE
              CALL wellsr
           END IF
        END IF
        CALL aplbce
        IF(errexe) THEN
           CALL write5
           EXIT
        END IF
20      CALL timstp
        CALL write6      ! ... print conductance values
        IF(.NOT.steady_flow) CALL asmslp
        CALL asmslc
        CALL sumcal1
        IF(tsfail .AND. .NOT.errexe) GO TO 20
#if defined(HDF5_CREATE)
        CALL hdf_begin_time_step
#endif
        ! ... Equilibrate the solutions with PHREEQC
        ! ... This is the connection to the equilibration step after transport
        IF (solute) THEN
           stop_msg = 0
!           WRITE(*,'(tr5,a)') 'Beginning chemistry calculation.'
           WRITE(logline1,'(a)') '     Beginning chemistry calculation.'
           CALL logprt_c(logline1)
           CALL screenprt_c(logline1)
           CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time,deltim,prslmi,cnvtmi,  &
                frac,iprint_chem,iprint_xyz,prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f, &
                print_restart%print_flag_integer)
        ENDIF
        CALL sumcal2
        CALL write5
        CALL write4                      ! ... Calculate and print velocity fields if requested
#if defined(HDF5_CREATE)
        CALL hdf_end_time_step
#endif
        CALL update_print_flags          ! ... Update times for next printouts
        IF(errexe) EXIT
        IF(prcpd) CALL dump_hst
     ENDDO
  ENDIF
  !..  IF(chkptd) CALL dump_hst     !***may be in wrong place
50 CONTINUE
!
!  Cleanup and stop
!
  logline1 = 'Done with transient simulation.'
!  WRITE(*,3001) TRIM(logline1)
  CALL logprt_c(logline1)
  CALL screenprt_c(logline1)
  IF(errexe .OR. errexi) THEN
     logline1 = 'ERROR exit.'
!     WRITE(*,3001) TRIM(logline1)
     CALL logprt_c(logline1)
     CALL screenprt_c(logline1)
  END IF
! *** special diagnostic message ***
  IF(col_scale) then
     if (ident_diagc) THEN
        logline1 = '***INFORMATION: all column scaling was unnecessary.'
!        WRITE(*,3001) TRIM(logline1)
        CALL logprt_c(logline1)
        CALL screenprt_c(logline1)
     else
        logline1 = '***INFORMATION: column scaling was necessary!'
!        WRITE(*,3001) TRIM(logline1)
        CALL logprt_c(logline1)
        CALL screenprt_c(logline1)
     endif
  END IF
  CALL terminate_phast(mpi_myself)
  STOP 'Simulation Completed'
END SUBROUTINE phast_root
