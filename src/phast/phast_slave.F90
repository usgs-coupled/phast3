SUBROUTINE phast_slave(mpi_tasks, mpi_myself)
  USE machine_constants, ONLY: kdp
  USE mcb, ONLY: adj_wr_ratio, transient_fresur
  USE mcc
  USE mcch, ONLY: f1name, f2name, f3name
  USE mcg, ONLY: naxes, nx, ny, nz, nxyz
  USE mcn, ONLY: x_node, y_node, z_node, pv0, volume
  USE mcp
  USE mcv
  USE mcw
  USE print_control_mod
!!$  USE mpi_mod
  IMPLICIT NONE
  INTEGER, INTENT(INOUT) :: mpi_myself, mpi_tasks
!!$  REAL(KIND=kdp) :: time_phreeqc, utime, utimchg
  REAL(KIND=kdp) :: time_phreeqc
  REAL(KIND=kdp) :: deltim_dummy
  INTEGER :: stop_msg
  INTEGER :: print_restart_flag
!!$  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: phast_slave.F90,v 1.1 2009/05/07 19:46:55 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Extract the version name for the header
  !...
  ! ... Start of execution
  !call mysleep(mpi_myself*100)
  CALL openf
  ! ... Read memory allocation data
  !  CALL read1
  ! ... Broadcast data from root to replace read1
  CALL slave_get_solute(solute, nx, ny, nz) 

  CALL phreeqc_main(solute, f1name, f2name, f3name, mpi_tasks, mpi_myself)
  CALL on_error_cleanup_and_exit
  ! ... Allocates space
  CALL slave_init1
!  time_phreeqc = 0.d0  
  time_phreeqc = time

#if defined(HDF5_CREATE)
     CALL hdf_write_invariant(mpi_myself)
#endif

  IF(solute) THEN
     CALL slave_get_indexes(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, naxes, nxyz, &
          x_node, y_node, z_node, cnvtmi, transient_fresur, steady_flow, pv0, &
          rebalance_method_f, volume)
     CALL forward_and_back(indx_sol1_ic, naxes, nx, ny, nz)  
     CALL distribute_initial_conditions(indx_sol1_ic, indx_sol2_ic, ic_mxfrac,&
                exchange_units, surface_units, ssassemblage_units,&
                ppassemblage_units, gasphase_units, kinetics_units,&
                pv0, volume)
     CALL uz_init(transient_fresur)
     CALL collect_from_nonroot(c, nxyz) ! stores data for transport
     ! ... Equilibrate the initial conditions for component concentrations
     ! moved equilibrate before write2_1, where initial conditions are printed to O.comps
     ! but equilibrate needs to be called after ss calculation for correct frac
     adj_wr_ratio = 1
     print_restart_flag = 0 
     CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time_phreeqc,deltim_dummy,prslmi,  &
           cnvtmi,frac_icchem,iprint_chem,iprint_xyz, &
           prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f, &
           print_restart_flag, pv, pv0, steady_flow, volume)
     stop_msg = 0
     deltim_dummy = 0._kdp
     ! ... The transient loop
     DO
           CALL equilibrate(c,nxyz,prcphrqi,x_node,y_node,z_node,time,deltim,prslmi,cnvtmi,  &
                frac,iprint_chem,iprint_xyz,prf_chem_phrqi,stop_msg,prhdfci,rebalance_fraction_f, &
                print_restart%print_flag_integer, pv, pv0, steady_flow, volume)
           IF (stop_msg == 1) EXIT
     ENDDO
  ENDIF
  CALL slave_closef
  STOP
END subroutine phast_slave

SUBROUTINE slave_init1  
  ! ... Initializes dimensions, unit labels, conversion factors
  USE f_units, ONLY: print_rde
  USE mcch
  USE mcb
  USE mcc
  USE mcg
!!$  USE mcm
  USE mcn
  USE mcp, only: pv
!!$  USE mct
  USE mcv
!!$  USE mcw, ONLY: totwsi, totwsp, tqwsi, tqwsp, u10
  IMPLICIT NONE
  INTEGER :: a_err, da_err, iis, nsa
  CHARACTER(LEN=10), DIMENSION(:), ALLOCATABLE :: ucomp_name
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: phast_slave.F90,v 1.1 2009/05/07 19:46:55 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Allocate scratch space for component names
  ! ... Start phreeqec and count number of components
  !      CALL PHREEQC_MAIN(SOLUTE, F1NAME, F2NAME, F3NAME)
  ALLOCATE (ucomp_name(100), &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: slave_init1 1"  
     STOP  
  ENDIF
  ucomp_name = " "
  IF (solute) CALL count_all_components (ns, ucomp_name)  
  ! ... Allocate component arrays
  nsa = MAX(ns,1)
  ! ... Allocate dependent variable arrays
  nxy = nx * ny  
  nxyz = nxy * nz  
  
  ALLOCATE (iprint_chem(nxyz), iprint_xyz(nxyz), &
       x(nx), y(ny), z(nz), x_node(nxyz), y_node(nxyz), z_node(nxyz),  &
       ibc(nxyz), pv0(nxyz), pv(nxyz), volume(nxyz), &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: slave_init1 2"  
     STOP  
  ENDIF
  ALLOCATE (comp_name(nsa), &
       indx_sol1_ic(7,nxyz), indx_sol2_ic(7,nxyz), &
       frac(nxyz), frac_icchem(nxyz),  &
       c(nxyz,nsa), &
!$$       ic_mxfrac(7,nxyz), bc_mxfrac(7,nxyz), &
       ic_mxfrac(7,nxyz), &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: slave_init1 3"  
     STOP  
  ENDIF
  IF (solute) THEN  
     DO  iis = 1,ns  
        comp_name(iis) = ucomp_name(iis)
     END DO
  ENDIF
  ! ... Zero the output record counters
  nrsttp = 0  
  nmapr = 0  
  ! ... Zero the output time plane counters
  ntprbcf = 0
  ntprcpd = 0
  ntprgfb = 0
  ntprzf = 0
  ntprzf_tsv = 0
  ntprzf_heads = 0
  ntprkd = 0
  ntprmapcomp = 0
  ntprmaphead = 0
  ntprmapv = 0
  ntprhdfv = 0
  ntprhdfh = 0
  ntprp = 0
  ntprc = 0
  ntprvel = 0
  ntprwel = 0
  ntprtem = 0
  prt_kd = .false.
  print_rde = .false.
  DEALLOCATE (ucomp_name, &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: slave_init1"  
     STOP  
  ENDIF
END SUBROUTINE slave_init1

SUBROUTINE slave_closef
  ! ... Closes and deletes files and writes indices of time values
  ! ...      at which dependent variables have been saved
  ! ... Also deallocates the arrays
  USE f_units
  USE mcb
  USE mcc
  USE mcch
!!$  USE mcg
!!$  USE mcm
  USE mcn
  USE mcp
!!$  USE mcs
!!$  USE mcs2
!!$  USE mct
  USE mcv
!!$  USE mcw
!!$  USE mg2, ONLY: qfbcv, hdprnt, uzelb, uklb, uxx, hwt
  USE mpi_mod
  IMPLICIT NONE
!!$  INTEGER, INTENT(IN) :: mpi_myself
  CHARACTER(LEN=6), DIMENSION(40) :: st
  INTEGER :: a_err  
  INTEGER :: da_err
!!$  CHARACTER(LEN=130) :: logline1, logline2, logline3
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: phast_slave.F90,v 1.1 2009/05/07 19:46:55 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Close and delete the stripped input file
  !CLOSE(fuins,STATUS='DELETE')  
  CALL MYCLOSE(fuins,'DELETE')  
  ! ... delete the read echo 'furde' file upon successful completion

  CALL update_status(st)
  ! ... Close the files
!  IF(print_rde) CLOSE(furde,status='delete')  
!  CLOSE(fuorst, status = st(fuorst))  
!  CLOSE(fulp, status = st(fulp))  
!  CLOSE(fup, status = st(fup)) 
!  CLOSE(fuwt, status = st(fuwt)) 
!  CLOSE(fuc, status = st(fuc))  
!  CLOSE(fuvel, status = st(fuvel))  
!  CLOSE(fuwel, status = st(fuwel))  
!  CLOSE(fubal, status = st(fubal))  
!  CLOSE(fukd, status = st(fukd))  
!  CLOSE(fubcf, status = st(fubcf))  
!  CLOSE(fuzf, status = st(fuzf))  
!  CLOSE(fuzf_tsv, status = st(fuzf_tsv))
!  CLOSE(fuplt, status = st(fuplt))  
!  CLOSE(fupmap, status = st(fupmap))  
!  CLOSE(fupmp2, status = st(fupmp2))
!  CLOSE(fupmp3, status = st(fupmp2))  
!  CLOSE(fuvmap, status = st(fuvmap))  
!!!$  close(fupzon, status = st(fupzon))  
!!!$  close(fubnfr, status = st(fubcf))  
!  CLOSE(fuich, status = st(fuich))

  IF(print_rde) CALL MYCLOSE(furde, 'delete')  
  CALL MYCLOSE(fuorst, st(fuorst))  
  CALL MYCLOSE(fulp, st(fulp))  
  CALL MYCLOSE(fup, st(fup)) 
  CALL MYCLOSE(fuwt, st(fuwt)) 
  CALL MYCLOSE(fuc, st(fuc))  
  CALL MYCLOSE(fuvel, st(fuvel))  
  CALL MYCLOSE(fuwel, st(fuwel))  
  CALL MYCLOSE(fubal, st(fubal))  
  CALL MYCLOSE(fukd, st(fukd))  
  CALL MYCLOSE(fubcf, st(fubcf))  
  CALL MYCLOSE(fuzf, st(fuzf))  
  CALL MYCLOSE(fuzf_tsv, st(fuzf_tsv))
  CALL MYCLOSE(fuplt, st(fuplt))  
  CALL MYCLOSE(fupmap, st(fupmap))  
  CALL MYCLOSE(fupmp2, st(fupmp2))
  CALL MYCLOSE(fupmp3, st(fupmp2))  
  CALL MYCLOSE(fuvmap, st(fuvmap))  
  CALL MYCLOSE(fuich, st(fuich))

  ! ... Close files and free memory in phreeqc
  CALL phreeqc_free(solute)  
  ! ... Deallocate the arrays
  ! ...      Deallocate mesh arrays
  DEALLOCATE (iprint_chem, iprint_xyz, &
     x, y, z, x_node, y_node, z_node,  &
    ibc, pv0, pv, volume, &
    STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array deallocation failed slave_closef: 1"  
     STOP  
  ENDIF
  DEALLOCATE (comp_name, &
       indx_sol1_ic, indx_sol2_ic, &
       frac, frac_icchem,  &
       c, &
!$$       ic_mxfrac, bc_mxfrac, &
       ic_mxfrac, &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array deallocation failed slave_closef: 2"  
     STOP  
  ENDIF
END SUBROUTINE slave_closef
