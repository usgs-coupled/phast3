PROGRAM phast
  ! ... A three dimensional flow and solute transport code based
  ! ...      upon finite differences and fully coupled equation system
  ! ... Based upon HST3D Version 2.0
  ! ... Release 1.0
  ! ... File Usage:
  ! ...      FUTRM - Monitor screen {standard output} and
  ! ...                  keyboard {standard input}
  ! ...      FUINS  - Input without comments
  ! ...      FULP  - Output to line printer
  ! ...      FUPLT - Output temporal plot file
  ! ...      FUORST - Output checkpoint dump file for restart
  ! ...      FUIRST - Input restart file from checkpoint dump
  ! ...      FUINC  - Input file with comments
  ! ...      FURDE  - Read echo of input data
  ! ...      FUPMAP  - Pressure, temperature, mass fraction for
  ! ...                    plotter or monitor screen maps
  ! ...      FUVMAP  - Velocity components for vector plots
  ! ...      FUP  - Pressure field
  ! ...      FUT  - Temperature field
  ! ...      FUC  - Concentration field
  ! ...      FUVEL  - Velocity field
  ! ...      FUWEL  - Well output
  ! ...      FUBAL  - Balance tables
  ! ...      FUKD  - Conductance fields
  ! ...      FUBCF  - Boundary condition flow rates
  ! ...      FUD  - Density field
  ! ...      FUVS  - Viscosity field
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE mcb, ONLY: adj_wr_ratio, transient_fresur
  USE mcc
  USE mcch, ONLY: f1name, f2name, f3name, version_name
  USE mcg, ONLY: naxes, nx, ny, nz, nxyz
  USE mcn, ONLY: x_node, y_node, z_node
  USE mcp
  USE mcv
  USE mcw
!  USE print_control_mod
  IMPLICIT NONE
  REAL(kind=kdp) :: time_phreeqc, utime, utimchg
  REAL(KIND=kdp) :: deltim_dummy
  INTEGER :: mpi_tasks, mpi_myself, stop_msg
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Extract the version name for the header
  version_name = ' 1.1 '
  !...
  errexi=.FALSE.
  errexe=.FALSE.
  mpi_myself = 0
#if defined(USE_MPI)
  CALL init_mpi(mpi_tasks, mpi_myself)
#endif
  ! ... Start of execution
  CALL openf
  ! ... Read memory allocation data
  CALL read1
  CALL phreeqc_main(solute, f1name, f2name, f3name, mpi_tasks, mpi_myself)
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
     time_phreeqc = 0.d0  
#if defined(HDF5_CREATE)
     CALL hdf_write_invariant(mpi_myself)
#endif
     IF (mpi_myself == 0) THEN
#if defined(HDF5_CREATE)
        CALL hdf_begin_time_step
#endif
     END IF
     IF(solute) THEN  
        CALL forward_and_back(indx_sol1_ic, naxes, nx, ny, nz)  
        CALL distribute_initial_conditions(indx_sol1_ic, indx_sol2_ic, mxfrac)
        CALL uz_init(transient_fresur)
        CALL pack_for_hst(c,nxyz)
     ENDIF
     IF (mpi_myself == 0) THEN
        CALL error4
     ENDIF
  ENDIF
! write2_1 must be called before ss flow calculation
! write2_1 must be called after distribute_initial_conditions and equilibrate
  CALL write2_1
  IF(errexi) GO TO 50
  IF (mpi_myself == 0) THEN
    IF(steady_flow) CALL simulate_ss_flow  ! ... Solve flow equation to steady state to obtain i.c.
    IF(errexe .OR. errexi) GO TO 50
  ENDIF
  IF (solute) THEN
     ! ... Equilibrate the initial conditions for component concentrations
     IF (mpi_myself == 0) THEN
        WRITE(*,3201) 'Equilibration of cells for initial conditions.'
3201    FORMAT(/a)
        WRITE(logline1,'(a)') 'Equilibration of cells for initial conditions.'
        CALL logprt_c(logline1)
     ENDIF
     ! moved equilibrate before write2_1, where initial conditions are printed to O.comps
     ! but equilibrate needs to be called after ss calculation for correct frac
     CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time_phreeqc,deltim_dummy,prslmi,  &
           cnvtmi,frac_icchem,iprint_chem,iprint_xyz, &
           prf_chem_phrqi,stop_msg,prhdfci,adj_wr_ratio)
     stop_msg = 0
     deltim_dummy = 0._kdp
     CALL init2_3
  ENDIF
  IF (mpi_myself == 0) THEN
     CALL write2_2
     IF (steady_flow) THEN
        CALL write3
        CALL write4
     ENDIF
#if defined(HDF5_CREATE)
     CALL hdf_end_time_step          ! ... Print HDF head and velocity fields
#endif
  END IF
  IF(errexe .OR. errexi) GO TO 50
  ! ... Terminate if only steady-state flow is desired
  IF(solute .OR. .NOT.steady_flow) THEN
     ! ... The transient loop
     IF (mpi_myself == 0) THEN          ! Root only
        logline1 = 'Beginning transient simulation.'
        WRITE(*,3001) TRIM(logline1)
3001    FORMAT(/a)  
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
20         CALL timstp
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
              WRITE(*,'(tr5,a)') 'Beginning chemistry calculation.'
              WRITE(logline1,'(a)') '     Beginning chemistry calculation.'
              CALL logprt_c(logline1)
              CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time,deltim,prslmi,cnvtmi,  &
                   frac,iprint_chem,iprint_xyz,prf_chem_phrqi,stop_msg,prhdfci,adj_wr_ratio)
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
     ELSE
        DO
           IF (solute) THEN
              CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time,deltim,prslmi,cnvtmi,  &
                   frac,iprint_chem,iprint_xyz,prf_chem_phrqi,stop_msg,prhdfci,adj_wr_ratio)
              IF (stop_msg == 1) EXIT
           ELSE
              EXIT
           ENDIF
        ENDDO
     ENDIF
  ENDIF
  !..  IF(chkptd) CALL dump_hst     !***may be in wrong place
50 CONTINUE
  IF (mpi_myself == 0) THEN
     logline1 = 'Done with transient simulation.'
     WRITE(*,3001) TRIM(logline1)
     CALL logprt_c(logline1)
     IF(errexe .OR. errexi) THEN
        logline1 = 'ERROR exit.'
        WRITE(*,3001) TRIM(logline1)
        CALL logprt_c(logline1)
     END IF
  ENDIF
  CALL terminate_phast(mpi_myself)
  IF (mpi_myself == 0) THEN
     STOP 'Simulation Completed'
  ELSE
     STOP
  ENDIF
END PROGRAM phast
