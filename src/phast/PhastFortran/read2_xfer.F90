! ... $Id: read2_xfer.F90,v 1.1 2013/09/19 20:41:58 klkipp Exp $
SUBROUTINE group2_distribute
  USE mcc
  USE mcv
  USE mpi_mod
  IMPLICIT NONE
  !-------------------------------------------------------------------------------
  IF (.NOT. solute .OR. .NOT. xp_group) RETURN
#if defined(USE_MPI)
  IF (mpi_myself == 0) THEN
     CALL MPI_BCAST(METHOD_GROUP2DISTRIBUTE, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
     CALL read2_xfer_m
     CALL init2_1_xfer_m
  ELSE
     CALL read2_xfer_w
     CALL init2_1_xfer_w
  ENDIF
#endif
END SUBROUTINE group2_distribute

SUBROUTINE read2_xfer_m  
#if defined(USE_MPI)
  ! ... Transfers data read from the Read2 data group to the workers
  USE f_units
  USE mcb
  USE mcb_m
  USE mcb2_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcs
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m
  USE rewi_mod
  USE hdf_media_m
  USE mpi_mod
  IMPLICIT NONE
  INTEGER, DIMENSION(4) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(10) :: array_bcst_r
  !     ------------------------------------------------------------------

  ! *** 0 broadcast npmz  
  !array_bcst_i(1) = npmz
    CALL MPI_BCAST(npmz, 1, MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

  ! *** 1 broadcast x, y, z
  ! ... create MPI structure for three real arrays
    CALL MPI_BCAST(x(1), nx, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    CALL MPI_BCAST(y(1), ny, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    CALL MPI_BCAST(z(1), nz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    
  ! *** 1.1 broadcast x_node, y_node, z_node
  ! ... create MPI structure for three real arrays
    CALL MPI_BCAST(x_node(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    CALL MPI_BCAST(y_node(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    CALL MPI_BCAST(z_node(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)

  !*** 2 broadcast bp, p0, w0, denf0, visfac, paatm, dm, t0, p0h, t0h
  array_bcst_r(1) = bp; array_bcst_r(2) = p0; array_bcst_r(3) = w0
  array_bcst_r(4) = denf0; array_bcst_r(5) = visfac; array_bcst_r(6) = paatm
  array_bcst_r(7) = dm; array_bcst_r(8) = t0
  array_bcst_r(9) = p0h; array_bcst_r(10) = t0h
  CALL MPI_BCAST(array_bcst_r(1), 10, MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

  !*** 3 broadcast        i1z(npmz), i2z(npmz), j1z(npmz), j2z(npmz), k1z(npmz), k2z(npmz)
  ! ... create MPI structure for 6 integer arrays
    CALL MPI_BCAST(i1z(1), SIZE(i1z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(i2z(1), SIZE(i2z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(j1z(1), SIZE(j1z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(j2z(1), SIZE(j2z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(k1z(1), SIZE(k1z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)    
    CALL MPI_BCAST(k2z(1), SIZE(k2z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi) 

  !*** 4 broadcast poros, abpm, tort
  ! ... create MPI structure for two real arrays
    CALL MPI_BCAST(poros(1), SIZE(poros), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(abpm(1), SIZE(abpm), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(tort(1), SIZE(tort), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

  !*** 5 broadcast alphl, alphth, alphtv
  ! ... create MPI structure for three real arrays
    CALL MPI_BCAST(alphl(1), SIZE(alphl), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(alphth(1), SIZE(alphth), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(alphtv(1), SIZE(alphtv), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

  IF(nwel > 0) THEN  
     ! ... Well bore location and structural data
     ! ... Allocate scratch space for well data   

     ! *** 6 broadcast wqmeth, nkswel
     ! ... create MPI structure for 2 integer arrays
    CALL MPI_BCAST(wqmeth(1), SIZE(wqmeth), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(nkswel(1), SIZE(nkswel), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

     ! *** 7 broadcast wbod, wfrac
     ! ... create MPI structure for two real arrays
    CALL MPI_BCAST(wbod(1), SIZE(wbod), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(wfrac(1), SIZE(wfrac), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

     ! *** 8 broadcast mwel
     ! ... broadcast of integer 2-D array
     CALL MPI_BCAST(mwel(1,1), SIZE(mwel), MPI_INTEGER, manager, &
          xp_comm, ierrmpi) 
         
     ! *** 8a broadcast wrid, wrangl
     ! ... create MPI structure for two real arrays
    CALL MPI_BCAST(wrid(1), SIZE(wrid), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(wrangl(1), SIZE(wrangl), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
           
  ENDIF
  IF(nsbc > 0) THEN      
     ! *** 9 broadcast nsbc_seg, nsbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = nsbc_seg; array_bcst_i(2) = nsbc_cells
     CALL MPI_BCAST(array_bcst_i(1), 2, MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

     !*** 10 broadcast msbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(msbc(1), nsbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi) 
  ENDIF

  ! ... Specified flux b.c.
  IF(nfbc > 0) THEN 
     ! *** 11 broadcast  nfbc_seg, nfbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = nfbc_seg; array_bcst_i(2) = nfbc_cells
     CALL MPI_BCAST(array_bcst_i(1), 2, MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

     ! *** 12 broadcast mfbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(mfbc(1), nfbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 13 broadcast ifacefbc, areafbc
     ! ... create MPI structure for one integer & one real array
    CALL MPI_BCAST(ifacefbc(1), SIZE(ifacefbc), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(areafbc(1), SIZE(areafbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)  
  ENDIF

  ! ... Aquifer leakage b.c.
  IF(nlbc > 0) THEN     
     ! *** 14 broadcast  nlbc_seg, nlbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = nlbc_seg; array_bcst_i(2) = nlbc_cells
    CALL MPI_BCAST(array_bcst_i(1), 2, MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

     ! *** 15 broadcast mlbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(mlbc(1), nlbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 16 broadcast ifacelbc, arealbc
     ! ... create MPI structure for one integer & one real array
    CALL MPI_BCAST(ifacelbc(1), SIZE(ifacelbc), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(arealbc(1), SIZE(arealbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

     ! *** 17 broadcast klbc, bblbc, zelbc
     ! ... create MPI structure for three real arrays
    CALL MPI_BCAST(klbc(1), SIZE(klbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(bblbc(1), SIZE(bblbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(zelbc(1), SIZE(zelbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi) 
  ENDIF

  ! ... River b.c. 
  IF(nrbc > 0) THEN     
     ! *** 18 broadcast  nrbc_seg, nrbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = nrbc_seg; array_bcst_i(2) = nrbc_cells
     CALL MPI_BCAST(array_bcst_i(1), 2, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 19 broadcast mrbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(mrbc(1), nrbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 20 broadcast mrseg_bot,  arearbc
     ! ... create MPI structure for one integer & one real array
    CALL MPI_BCAST(mrseg_bot(1), SIZE(mrseg_bot), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(arearbc(1), SIZE(arearbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

     ! *** 21 broadcast krbc, bbrbc, zerbc
     ! ... create MPI structure for three real arrays
    CALL MPI_BCAST(krbc(1), SIZE(krbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(bbrbc(1), SIZE(bbrbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(zerbc(1), SIZE(zerbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)  
  ENDIF

  ! ... Drain b.c. 
  IF(ndbc > 0) THEN 
     ! *** 22 broadcast  ndbc_seg, ndbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = ndbc_seg; array_bcst_i(2) = ndbc_cells
     CALL MPI_BCAST(array_bcst_i(1), 2, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 23 broadcast mdbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(mdbc(1), ndbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 24 broadcast mdseg_bot,  areadbc
     ! ... create MPI structure for one integer & one real array
    CALL MPI_BCAST(mdseg_bot(1), SIZE(mdseg_bot), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(areadbc(1), SIZE(areadbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

     ! *** 25 broadcast kdbc, bbdbc, zedbc
     ! ... create MPI structure for three real arrays
    CALL MPI_BCAST(kdbc(1), SIZE(kdbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(bbdbc(1), SIZE(bbdbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(zedbc(1), SIZE(zedbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
  ENDIF

  ! *** 26 broadcast fresur, temp_logical
  ! ... Load the scalar variables
  array_bcst_i(1) = 0
  IF (fresur) array_bcst_i(1) = 1
  !array_bcst_i(2) = 0
  !IF (temp_logical) array_bcst_i(2) = 1
  array_bcst_i(2) = adj_wr_ratio
     CALL MPI_BCAST(array_bcst_i(1), 2, MPI_INTEGER, manager, &
          xp_comm, ierrmpi) 

  ! *** 27 broadcast fdsmth, fdtmth, crosd
  array_bcst_r(1) = fdsmth; array_bcst_r(2) = fdtmth
  array_bcst_i(1) = 0
  IF (crosd) array_bcst_i(1) = 1
     CALL MPI_BCAST(array_bcst_i(1), 1, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)
     CALL MPI_BCAST(array_bcst_r(1), 2, MPI_DOUBLE_PRECISION, manager, &
          xp_comm, ierrmpi)    

  IF(slmeth == 3 .OR. slmeth == 5) THEN
     ! *** broadcast 28 idir, milu, nsdr,  maxit2, epsslv  
     array_bcst_i(1) = idir
     array_bcst_i(2) = 0
     IF(milu) array_bcst_i(2) = 1
     array_bcst_i(3) = nsdr
     array_bcst_i(4) = maxit2
     array_bcst_r(1) = epsslv
     CALL MPI_BCAST(array_bcst_i(1), 4, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)
     CALL MPI_BCAST(epsslv, 1, MPI_DOUBLE_PRECISION, manager, &
          xp_comm, ierrmpi)
  END IF

#endif
END SUBROUTINE read2_xfer_m

SUBROUTINE read2_xfer_w  
#if defined(USE_MPI)
  ! ... Receives all the data that are time invariant during the simulation
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcs
  USE mcv
  USE mcw
  USE mg2_m
  USE mpi_mod
  USE PhreeqcRM
  IMPLICIT NONE
  INTEGER :: a_err
  INTEGER :: nr
  CHARACTER(LEN=130) :: logline1
  INTEGER :: status
  INTEGER, DIMENSION(1:4) :: array_recv_i
  REAL(KIND=kdp), DIMENSION(1:10) :: array_recv_r
  !     ------------------------------------------------------------------
  !...
  if (.not. xp_group) return
  nr = nx
  WRITE(logline1,'(a)') 'Receiving static data for flow and transport simulation'
  status = RM_LogMessage(rm_id, logline1)

  ! *** 0 broadcast npmz
  ! ... receive broadcast of b.c. integer counts
    CALL MPI_BCAST(npmz, 1, MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

!  npmz = array_recv_i(1)

  ! *** 1 broadcast x, y, z
!  IF(.NOT.cylind) THEN
     ! ... 1 Receive aquifer description - spatial mesh data
     ! ...      rectangular coordinates
    CALL MPI_BCAST(x(1), nx, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    CALL MPI_BCAST(y(1), ny, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    CALL MPI_BCAST(z(1), nz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    
  ! *** 1.1 broadcast x_node, y_node, z_node
  ! ... create MPI structure for three real arrays
    CALL MPI_BCAST(x_node(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    CALL MPI_BCAST(y_node(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    CALL MPI_BCAST(z_node(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)    

  !*** 2 broadcast bp, p0, w0, denf0, visfac, paatm, dm, t0, p0h, t0h
  CALL MPI_BCAST(array_recv_r(1), 10, MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

  bp = array_recv_r(1); p0 = array_recv_r(2); w0 = array_recv_r(3)
  denf0 = array_recv_r(4); visfac = array_recv_r(5); paatm = array_recv_r(6)
  dm = array_recv_r(7); t0 = array_recv_r(8)
  p0h = array_recv_r(9); t0h = array_recv_r(10)

  ! ... Porous media physical properties
  ! ...      Porous media zones
  ! ... Allocate the parameter arrays: mcp
  ALLOCATE (rcppm(1),  &
       abpm(npmz), alphl(npmz), alphth(npmz), alphtv(npmz), poros(npmz), tort(npmz), &
       STAT = a_err)
  IF(a_err /= 0) THEN  
     PRINT * , "array allocation failed: read2_w, point 2"
     STOP
  ENDIF
  ! ... Allocate region geometry information: mcg
  ALLOCATE(i1z(npmz), i2z(npmz), j1z(npmz), j2z(npmz), k1z(npmz), k2z(npmz), &
       STAT = a_err)
  IF(a_err /= 0) THEN  
     PRINT * , "array allocation failed: read2_w, point 4"
     STOP
  ENDIF

  !*** 3 broadcast        i1z(npmz), i2z(npmz), j1z(npmz), j2z(npmz), k1z(npmz), k2z(npmz)
    CALL MPI_BCAST(i1z(1), SIZE(i1z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(i2z(1), SIZE(i2z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(j1z(1), SIZE(j1z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(j2z(1), SIZE(j2z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(k1z(1), SIZE(k1z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)    
    CALL MPI_BCAST(k2z(1), SIZE(k2z), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

  !*** 4 broadcast poros, abpm, tort  
  ! ... Permeability; not needed
  ! ... Porosity & porous media compressibilities
    CALL MPI_BCAST(poros(1), SIZE(poros), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(abpm(1), SIZE(abpm), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(tort(1), SIZE(tort), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

  !*** 5 broadcast alphl, alphth, alphtv   
  ! ... Dispersivities for solute
    CALL MPI_BCAST(alphl(1), SIZE(alphl), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(alphth(1), SIZE(alphth), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(alphtv(1), SIZE(alphtv), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

  ! ... Well bore model information
  IF(nwel > 0) THEN  
     ! ... allocate and load the final well arrays: mcw
     ALLOCATE (welidno(nwel), xw(nwel), yw(nwel), wbod(nwel), wqmeth(nwel),  &
          mwel(nwel,nz), wcfl(nwel,nz), wcfu(nwel,nz), zwb(nwel), zwt(nwel),  &
          dwb(nwel), dwt(nwel),  &
          wfrac(nwel), nkswel(nwel), &
          wrid(nwel), wrangl(nwel), &
          wrruf(nwel), &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2_w, point 6"  
        STOP  
     ENDIF

     ! *** 6 broadcast wqmeth, nkswel        
     ! ... Well bore location and structural data
     ! ... Read well completion cells and screen lengths in lower and upper parts
     ! ... no well riser calculations allowed in phast
    CALL MPI_BCAST(wqmeth(1), SIZE(wqmeth), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(nkswel(1), SIZE(nkswel), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

     ! *** 7 broadcast wbod, wfrac
    CALL MPI_BCAST(wbod(1), SIZE(wbod), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(wfrac(1), SIZE(wfrac), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

     ! *** 8 broadcast mwel      
     ! ... receive broadcast of integer 2-D array
     CALL MPI_BCAST(mwel(1,1), SIZE(mwel), MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 8a broadcast wrid, wrangl
    CALL MPI_BCAST(wrid(1), SIZE(wrid), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(wrangl(1), SIZE(wrangl), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

  ENDIF
  ! ... Boundary conditions
  ! ... Specified p,t,or c b.c.
  IF(nsbc > 0) THEN
     ! *** 9 broadcast nsbc_seg, nsbc_cells
     ! ... receive broadcast of b.c. integer counts
     CALL MPI_BCAST(array_recv_i(1), 2, MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

     nsbc_seg = array_recv_i(1); nsbc_cells = array_recv_i(2)
     nsbc = nsbc_cells
     ! ... Allocate specified value b.c. arrays: mcb and mcb_w
     ALLOCATE (msbc(nsbc_seg),  &
          psbc(nsbc_seg), psbc_n(nsbc_seg),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2_w, svbc.2"  
        STOP
     ENDIF
     psbc = 0
     psbc_n = 0
     !*** 10 broadcast msbc
     ! ... receive broadcast of integer array
     CALL MPI_BCAST(msbc(1), nsbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)
  ENDIF

  ! ... Specified flux b.c.
  IF(nfbc > 0) THEN
     ! *** 11 broadcast  nfbc_seg, nfbc_cells       
     ! ... receive broadcast of b.c. integer counts
     CALL MPI_BCAST(array_recv_i(1), 2, MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

     nfbc_seg = array_recv_i(1); nfbc_cells = array_recv_i(2)
     nfbc = nfbc_cells

     ! ... Allocate specified flux b.c. arrays: mcb and mcb_w
     ALLOCATE (mfbc(nfbc_seg), ifacefbc(nfbc_seg), areafbc(nfbc_seg),  &
          qfflx(nfbc_seg), qfflx_n(nfbc_seg), denfbc(nfbc_seg), &
          STAT = a_err)
     IF (a_err /= 0) THEN
        PRINT *, "array allocation failed: read2_w, flux.2"
        STOP
     ENDIF
     qfflx = 0.0_kdp         ! set in init2_1
     qfflx_n = 0.0_kdp
     ! *** 12 broadcast mfbc     
     ! ... receive broadcast of integer array
     CALL MPI_BCAST(mfbc(1), nfbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 13 broadcast ifacefbc, areafbc   
    CALL MPI_BCAST(ifacefbc(1), SIZE(ifacefbc), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(areafbc(1), SIZE(areafbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
  ENDIF

  ! ... Aquifer leakage b.c.
  IF(nlbc > 0) THEN
     ! *** 14 broadcast  nlbc_seg, nlbc_cells   
     ! ... receive broadcast of b.c. integer counts
    CALL MPI_BCAST(array_recv_i(1), 2, MPI_INTEGER, manager, &
        xp_comm, ierrmpi)

     nlbc_seg = array_recv_i(1); nlbc_cells = array_recv_i(2)
     nlbc = nlbc_cells

     ! ... Allocate leakage b.c. arrays: mcb and mcb_w
     ALLOCATE (mlbc(nlbc_seg), ifacelbc(nlbc_seg), arealbc(nlbc_seg),  &
          albc(nlbc_seg), blbc(nlbc_seg),  &
          klbc(nlbc_seg), bblbc(nlbc_seg), zelbc(nlbc_seg), &
          philbc(nlbc_seg), philbc_n(nlbc_seg), denlbc(nlbc_seg), vislbc(nlbc_seg),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2_w, leak.2"  
        STOP
     ENDIF
!!$     philbc = 0.0_kdp
!!$     philbc_n = 0.0_kdp

     ! *** 15 broadcast mlbc     
     ! ... receive broadcast of integer array
     CALL MPI_BCAST(mlbc(1), nlbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 16 broadcast ifacelbc, arealbc
    CALL MPI_BCAST(ifacelbc(1), SIZE(ifacelbc), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(arealbc(1), SIZE(arealbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

     ! *** 17 broadcast klbc, bblbc, zelbc
    CALL MPI_BCAST(klbc(1), SIZE(klbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(bblbc(1), SIZE(bblbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(zelbc(1), SIZE(zelbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
  ENDIF
  ! ... River b.c. 
  IF(nrbc > 0) THEN
     ! *** 18 broadcast  nrbc_seg, nrbc_cells 
     ! ... receive broadcast of b.c. integer counts
     CALL MPI_BCAST(array_recv_i(1), 2, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     nrbc_seg = array_recv_i(1); nrbc_cells = array_recv_i(2)
     nrbc = nrbc_cells

     ! ... Allocate river leakage b.c. arrays: mcb and mcb_w
     ALLOCATE (mrbc(nrbc_seg), arearbc(nrbc_seg),  &
          arbc(nrbc_seg), brbc(nrbc_seg),  &
          krbc(nrbc_seg), bbrbc(nrbc_seg), zerbc(nrbc_seg),  &
          mrseg_bot(nrbc_seg),  &
          phirbc(nrbc_seg), phirbc_n(nrbc_seg), denrbc(nrbc_seg), visrbc(nrbc_seg),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2_w, river.2"  
        STOP
     ENDIF
!!$     phirbc = 0.0_kdp
!!$     phirbc_n = 0.0_kdp

     ! *** 19 broadcast mrbc
     ! ... receive broadcast of integer array
     CALL MPI_BCAST(mrbc(1), nrbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 20 broadcast mrseg_bot,  arearbc   
    CALL MPI_BCAST(mrseg_bot(1), SIZE(mrseg_bot), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(arearbc(1), SIZE(arearbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)     

     ! *** 21 broadcast krbc, bbrbc, zerbc
    CALL MPI_BCAST(krbc(1), SIZE(krbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(bbrbc(1), SIZE(bbrbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(zerbc(1), SIZE(zerbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
  ENDIF

  ! ... Drain b.c. 
  IF(ndbc > 0) THEN
     ! *** 22 broadcast  ndbc_seg, ndbc_cells
     ! ... receive broadcast of b.c. integer counts
     CALL MPI_BCAST(array_recv_i(1), 2, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ndbc_seg = array_recv_i(1); ndbc_cells = array_recv_i(2)
     ndbc = ndbc_cells

     ! ... Allocate drain b.c. arrays: mcb and mcb_w
     ALLOCATE (mdbc(ndbc_seg), areadbc(ndbc_seg),  &
          adbc(ndbc_seg), bdbc(ndbc_seg),  &
          kdbc(ndbc_seg), bbdbc(ndbc_seg), zedbc(ndbc_seg),  &
          mdseg_bot(ndbc_seg),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2_w, drain.2"  
        STOP
     ENDIF

     ! *** 23 broadcast mdbc
     ! ... receive broadcast of integer array
     CALL MPI_BCAST(mdbc(1), ndbc_seg, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)

     ! *** 24 broadcast mdseg_bot,  areadbc
    CALL MPI_BCAST(mdseg_bot(1), SIZE(mdseg_bot), MPI_INTEGER, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(areadbc(1), SIZE(areadbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)

     ! *** 25 broadcast kdbc, bbdbc, zedbc
    CALL MPI_BCAST(kdbc(1), SIZE(kdbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(bbdbc(1), SIZE(bbdbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
    CALL MPI_BCAST(zedbc(1), SIZE(zedbc), MPI_DOUBLE_PRECISION, manager, &
        xp_comm, ierrmpi)
  ENDIF

  ! *** 26 broadcast fresur, adj_wr_ratio
     CALL MPI_BCAST(array_recv_i(1), 2, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)
  fresur = .FALSE.
  IF (array_recv_i(1) .ne. 0) fresur = .TRUE.
  adj_wr_ratio = array_recv_i(2)

  ! *** 27 broadcast fdsmth, fdtmth, crosd
     CALL MPI_BCAST(array_recv_i(1), 1, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)
     CALL MPI_BCAST(array_recv_r(1), 2, MPI_DOUBLE_PRECISION, manager, &
          xp_comm, ierrmpi)

  fdsmth = array_recv_r(1); fdtmth = array_recv_r(2)
  crosd = .FALSE.
  IF (array_recv_i(1) == 1) crosd = .TRUE.

  IF(slmeth == 3 .OR. slmeth == 5) THEN
     ! *** broadcast 28 idir, milu, nsdr,  maxit2, epsslv
     CALL MPI_BCAST(array_recv_i(1), 4, MPI_INTEGER, manager, &
          xp_comm, ierrmpi)
     CALL MPI_BCAST(array_recv_r(1), 1, MPI_DOUBLE_PRECISION, manager, &
          xp_comm, ierrmpi)
     idir = array_recv_i(1)
     milu = .FALSE.
     IF(array_recv_i(2) == 1) milu = .TRUE.
     nsdr = array_recv_i(3)
     maxit2 = array_recv_i(4)
     epsslv = array_recv_r(1)
  ENDIF
#endif
END SUBROUTINE read2_xfer_w
