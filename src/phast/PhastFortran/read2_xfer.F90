#include 'mpi_fix_case.h'
! ... $Id: read2_xfer.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $
SUBROUTINE group2_distribute
  USE mcc
  USE mcv
  IMPLICIT NONE
  !-------------------------------------------------------------------------------
  IF (.NOT. solute .OR. .NOT. xp_group) RETURN
#if defined(USE_MPI)
  IF (mpi_myself == 0) THEN
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
  USE mpi_struct_arrays
  IMPLICIT NONE
  INTEGER :: int_real_type, mpi_array_type
  INTEGER, DIMENSION(4) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(10) :: array_bcst_r
  !     ------------------------------------------------------------------

  ! *** 0 broadcast npmz  
  array_bcst_i(1) = npmz
  int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
  CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi) 

  ! *** 1 broadcast x, y, z
  ! ... create MPI structure for three real arrays
  mpi_array_type=mpi_struct_array(x, y, z)
  ! ... broadcast real arrays to workers
  CALL MPI_BCAST(x, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  !*** 2 broadcast bp, p0, w0, denf0, visfac, paatm, dm, t0, p0h, t0h
  array_bcst_r(1) = bp; array_bcst_r(2) = p0; array_bcst_r(3) = w0
  array_bcst_r(4) = denf0; array_bcst_r(5) = visfac; array_bcst_r(6) = paatm
  array_bcst_r(7) = dm; array_bcst_r(8) = t0
  array_bcst_r(9) = p0h; array_bcst_r(10) = t0h
  int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
  CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  !*** 3 broadcast        i1z(npmz), i2z(npmz), j1z(npmz), j2z(npmz), k1z(npmz), k2z(npmz)
  ! ... create MPI structure for 6 integer arrays
  mpi_array_type=mpi_struct_array(i1z, i2z, j1z, j2z, k1z, k2z)
  ! ... broadcast integer arrays to workers
  CALL MPI_BCAST(i1z, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)  

  !*** 4 broadcast poros, abpm
  ! ... create MPI structure for two real arrays
  mpi_array_type=mpi_struct_array(poros, abpm)
  ! ... broadcast real arrays to workers
  CALL MPI_BCAST(poros, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  !*** 5 broadcast alphl, alphth, alphtv
  ! ... create MPI structure for three real arrays
  mpi_array_type=mpi_struct_array(alphl, alphth, alphtv)
  ! ... broadcast real arrays to workers
  CALL MPI_BCAST(alphl, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi) 

  IF(nwel > 0) THEN  
     ! ... Well bore location and structural data
     ! ... Allocate scratch space for well data   

     ! *** 6 broadcast wqmeth, nkswel
     ! ... create MPI structure for 2 integer arrays
     mpi_array_type=mpi_struct_array(wqmeth, nkswel)
     ! ... broadcast integer arrays to workers
     CALL MPI_BCAST(wqmeth, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 7 broadcast wbod, wfrac
     ! ... create MPI structure for two real arrays
     mpi_array_type=mpi_struct_array(wbod, wfrac)
     ! ... broadcast real arrays to workers
     CALL MPI_BCAST(wbod, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 8 broadcast mwel
     ! ... broadcast of integer 2-D array
     CALL MPI_BCAST(mwel, SIZE(mwel), MPI_INTEGER, manager, &
          world, ierrmpi)    
  ENDIF
  IF(nsbc > 0) THEN      
     ! *** 9 broadcast nsbc_seg, nsbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = nsbc_seg; array_bcst_i(2) = nsbc_cells
     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

     !*** 10 broadcast msbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(msbc, nsbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi) 
  ENDIF

  ! ... Specified flux b.c.
  IF(nfbc > 0) THEN 
     ! *** 11 broadcast  nfbc_seg, nfbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = nfbc_seg; array_bcst_i(2) = nfbc_cells
     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

     ! *** 12 broadcast mfbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(mfbc, nfbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 13 broadcast ifacefbc, areafbc
     ! ... create MPI structure for one integer & one real array
     mpi_array_type=mpi_struct_array(ifacefbc, areafbc)
     ! ... broadcast integer and real arrays to workers
     CALL MPI_BCAST(ifacefbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)    
  ENDIF

  ! ... Aquifer leakage b.c.
  IF(nlbc > 0) THEN     
     ! *** 14 broadcast  nlbc_seg, nlbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = nlbc_seg; array_bcst_i(2) = nlbc_cells

     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

     ! *** 15 broadcast mlbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(mlbc, nlbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 16 broadcast ifacelbc, arealbc
     ! ... create MPI structure for one integer & one real array
     mpi_array_type=mpi_struct_array(ifacelbc, arealbc)
     ! ... broadcast integer and real arrays to workers
     CALL MPI_BCAST(ifacelbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 17 broadcast klbc, bblbc, zelbc
     ! ... create MPI structure for three real arrays
     mpi_array_type=mpi_struct_array(klbc, bblbc, zelbc)
     ! ... broadcast real arrays to workers
     CALL MPI_BCAST(klbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi) 
  ENDIF

  ! ... River b.c. 
  IF(nrbc > 0) THEN     
     ! *** 18 broadcast  nrbc_seg, nrbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = nrbc_seg; array_bcst_i(2) = nrbc_cells

     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

     ! *** 19 broadcast mrbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(mrbc, nrbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 20 broadcast mrseg_bot,  arearbc
     ! ... create MPI structure for one integer & one real array
     mpi_array_type=mpi_struct_array(mrseg_bot, arearbc)
     ! ... broadcast integer and real arrays to workers
     CALL MPI_BCAST(mrseg_bot, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 21 broadcast krbc, bbrbc, zerbc
     ! ... create MPI structure for three real arrays
     mpi_array_type=mpi_struct_array(krbc, bbrbc, zerbc)
     ! ... broadcast real arrays to workers
     CALL MPI_BCAST(krbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)   
  ENDIF

  ! ... Drain b.c. 
  IF(ndbc > 0) THEN 
     ! *** 22 broadcast  ndbc_seg, ndbc_cells
     ! ... Load the scalar variables
     array_bcst_i(1) = ndbc_seg; array_bcst_i(2) = ndbc_cells

     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

     ! *** 23 broadcast mdbc
     ! ...  broadcast of integer array
     CALL MPI_BCAST(mdbc, ndbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 24 broadcast mdseg_bot,  areadbc
     ! ... create MPI structure for one integer & one real array
     mpi_array_type=mpi_struct_array(mdseg_bot, areadbc)
     ! ... broadcast integer and real arrays to workers
     CALL MPI_BCAST(mdseg_bot, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 25 broadcast kdbc, bbdbc, zedbc
     ! ... create MPI structure for three real arrays
     mpi_array_type=mpi_struct_array(kdbc, bbdbc, zedbc)
     ! ... broadcast real arrays to workers
     CALL MPI_BCAST(kdbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi) 
  ENDIF

  ! *** 26 broadcast fresur, temp_logical
  ! ... Load the scalar variables
  array_bcst_i(1) = 0
  IF (fresur) array_bcst_i(1) = 1
  !array_bcst_i(2) = 0
  !IF (temp_logical) array_bcst_i(2) = 1
  array_bcst_i(2) = adj_wr_ratio

  int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
  CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)  

  ! *** 27 broadcast fdsmth, fdtmth, crosd
  array_bcst_r(1) = fdsmth; array_bcst_r(2) = fdtmth
  array_bcst_i(1) = 0
  IF (crosd) array_bcst_i(1) = 1

  int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
  CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)     

  IF(slmeth == 3 .OR. slmeth == 5) THEN
     ! *** broadcast 28 idir, milu, nsdr,  maxit2, epsslv  
     array_bcst_i(1) = idir
     array_bcst_i(2) = 0
     IF(milu) array_bcst_i(2) = 1
     array_bcst_i(3) = nsdr
     array_bcst_i(4) = maxit2
     array_bcst_r(1) = epsslv

     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)
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
  USE mcw
  USE mg2_m
  USE mpi_mod
  USE mpi_struct_arrays
  IMPLICIT NONE
  INTEGER :: a_err
  INTEGER :: nr
  CHARACTER(LEN=130) :: logline1
  INTEGER :: int_real_type, mpi_array_type
  INTEGER, DIMENSION(1:4) :: array_recv_i
  REAL(KIND=kdp), DIMENSION(1:10) :: array_recv_r
  ! ... set string for use with rcs ident command
  CHARACTER(LEN=80) :: ident_string='$Id: read2_xfer.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  nr = nx
  WRITE(logline1,'(a)') 'Receiving static data for flow and transport simulation'
  CALL logprt_c(logline1)

  ! *** 0 broadcast npmz
  ! ... receive broadcast of b.c. integer counts
  int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
  CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  npmz = array_recv_i(1)

  ! *** 1 broadcast x, y, z
  IF(.NOT.cylind) THEN
     ! ... 1 Receive aquifer description - spatial mesh data
     ! ...      rectangular coordinates
     mpi_array_type = mpi_struct_array(x,y,z)
     ! ... receive broadcast of real arrays
     CALL MPI_BCAST(x, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
  ELSE  
     ! ... Cylindrical r-z grid - single well
     mpi_array_type = mpi_struct_array(x,z)
     ! ... receive broadcast of real arrays
     CALL MPI_BCAST(x, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
     ny = 1  
     y(1) = 0._kdp
  ENDIF

  !*** 2 broadcast bp, p0, w0, denf0, visfac, paatm, dm, t0, p0h, t0h
  int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
  CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  bp = array_recv_r(1); p0 = array_recv_r(2); w0 = array_recv_r(3)
  denf0 = array_recv_r(4); visfac = array_recv_r(5); paatm = array_recv_r(6)
  dm = array_recv_r(7); t0 = array_recv_r(8)
  p0h = array_recv_r(9); t0h = array_recv_r(10)

  ! ... Porous media physical properties
  ! ...      Porous media zones
  ! ... Allocate the parameter arrays: mcp
  ALLOCATE (rcppm(1),  &
       abpm(npmz), alphl(npmz), alphth(npmz), alphtv(npmz), poros(npmz), & ! tort(npmz), &
       STAT = a_err)
  IF(a_err /= 0) THEN  
     PRINT * , "array allocation failed: read2_w, point 2"
     STOP
  ENDIF
  ! ... Allocate region geometry information: mcg
  ALLOCATE(i1z(npmz), i2z(npmz), j1z(npmz), j2z(npmz), k1z(npmz), k2z(npmz),  &
       STAT = a_err)
  IF(a_err /= 0) THEN  
     PRINT * , "array allocation failed: read2_w, point 4"
     STOP
  ENDIF

  !*** 3 broadcast        i1z(npmz), i2z(npmz), j1z(npmz), j2z(npmz), k1z(npmz), k2z(npmz)
  mpi_array_type = mpi_struct_array(i1z,i2z,j1z,j2z,k1z,k2z)
  ! ... receive broadcast of integer arrays
  CALL MPI_BCAST(i1z, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  !*** 4 broadcast poros, abpm   
  ! ... Permeability; not needed
  ! ... Porosity & porous media compressibilities
  mpi_array_type = mpi_struct_array(poros,abpm)
  ! ... receive broadcast of real arrays
  CALL MPI_BCAST(poros, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  !*** 5 broadcast alphl, alphth, alphtv   
  ! ... Dispersivities for solute
  mpi_array_type = mpi_struct_array(alphl,alphth,alphtv)
  ! ... receive broadcast of real arrays
  CALL MPI_BCAST(alphl, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)


  ! ... Well bore model information
  IF(nwel > 0) THEN  
     ! ... allocate and load the final well arrays: mcw
     ALLOCATE (welidno(nwel), xw(nwel), yw(nwel), wbod(nwel), wqmeth(nwel),  &
          mwel(nwel,nz), wcfl(nwel,nz), wcfu(nwel,nz), zwb(nwel), zwt(nwel),  &
          dwb(nwel), dwt(nwel),  &
          wfrac(nwel), nkswel(nwel),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2_w, point 6"  
        STOP  
     ENDIF

     ! *** 6 broadcast wqmeth, nkswel        
     ! ... Well bore location and structural data
     ! ... Read well completion cells and screen lengths in lower and upper parts
     ! ... no well riser calculations allowed in phast
     mpi_array_type = mpi_struct_array(wqmeth, nkswel)
     ! ... receive broadcast of integer arrays
     CALL MPI_BCAST(wqmeth, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 7 broadcast wbod, wfrac
     mpi_array_type = mpi_struct_array(wbod, wfrac)
     ! ... receive broadcast of real arrays
     CALL MPI_BCAST(wbod, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 8 broadcast mwel      
     ! ... receive broadcast of integer 2-D array
     CALL MPI_BCAST(mwel, SIZE(mwel), MPI_INTEGER, manager, &
          world, ierrmpi)
  ENDIF
  ! ... Boundary conditions
  ! ... Specified p,t,or c b.c.
  IF(nsbc > 0) THEN
     ! *** 9 broadcast nsbc_seg, nsbc_cells
     ! ... receive broadcast of b.c. integer counts
     int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
     CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

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
     CALL MPI_BCAST(msbc, nsbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi)
  ENDIF

  ! ... Specified flux b.c.
  IF(nfbc > 0) THEN
     ! *** 11 broadcast  nfbc_seg, nfbc_cells       
     ! ... receive broadcast of b.c. integer counts
     int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
     CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

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
     CALL MPI_BCAST(mfbc, nfbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 13 broadcast ifacefbc, areafbc   
     mpi_array_type = mpi_struct_array(ifacefbc,areafbc)   
     ! ... receive broadcast of integer and real arrays
     CALL MPI_BCAST(ifacefbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
  ENDIF

  ! ... Aquifer leakage b.c.
  IF(nlbc > 0) THEN
     ! *** 14 broadcast  nlbc_seg, nlbc_cells   
     ! ... receive broadcast of b.c. integer counts
     int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
     CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

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
     CALL MPI_BCAST(mlbc, nlbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 16 broadcast ifacelbc, arealbc
     mpi_array_type = mpi_struct_array(ifacelbc,arealbc)
     ! ... receive broadcast of integer and real arrays
     CALL MPI_BCAST(ifacelbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)


     ! *** 17 broadcast klbc, bblbc, zelbc
     mpi_array_type = mpi_struct_array(klbc,bblbc,zelbc)
     ! ... receive broadcast of real arrays
     CALL MPI_BCAST(klbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
  ENDIF
  ! ... River b.c. 
  IF(nrbc > 0) THEN
     ! *** 18 broadcast  nrbc_seg, nrbc_cells 
     ! ... receive broadcast of b.c. integer counts
     int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
     CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

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
     CALL MPI_BCAST(mrbc, nrbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 20 broadcast mrseg_bot,  arearbc           
     mpi_array_type = mpi_struct_array(mrseg_bot,arearbc)
     ! ... receive broadcast of integer and real arrays
     CALL MPI_BCAST(mrseg_bot, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 21 broadcast krbc, bbrbc, zerbc
     mpi_array_type = mpi_struct_array(krbc,bbrbc,zerbc)
     ! ... receive broadcast of real arrays
     CALL MPI_BCAST(krbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
  ENDIF

  ! ... Drain b.c. 
  IF(ndbc > 0) THEN
     ! *** 22 broadcast  ndbc_seg, ndbc_cells
     ! ... receive broadcast of b.c. integer counts
     int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
     CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

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
     CALL MPI_BCAST(mdbc, ndbc_seg, MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 24 broadcast mdseg_bot,  areadbc
     mpi_array_type = mpi_struct_array(mdseg_bot,areadbc)
     ! ... receive broadcast of integer and real arrays
     CALL MPI_BCAST(mdseg_bot, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 25 broadcast kdbc, bbdbc, zedbc
     mpi_array_type = mpi_struct_array(kdbc,bbdbc,zedbc)
     ! ... receive broadcast of real arrays
     CALL MPI_BCAST(kdbc, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
  ENDIF

  ! *** 26 broadcast fresur, adj_wr_ratio
  int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
  CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  fresur = .FALSE.
  IF (array_recv_i(1) == 1) fresur = .TRUE.
  !temp_logical = .false.
  !if (array_recv_i(2) == 1) temp_logical = .true.
  adj_wr_ratio = array_recv_i(2)

!!$  transient_fresur = .false.
!!$  if (array_recv_i(3) == 1) transient_fresur = .true.

  ! *** 27 broadcast fdsmth, fdtmth, crosd
  int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
  CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  fdsmth = array_recv_r(1); fdtmth = array_recv_r(2)
  crosd = .FALSE.
  IF (array_recv_i(1) == 1) crosd = .TRUE.

  IF(slmeth == 3 .OR. slmeth == 5) THEN
     ! *** broadcast 28 idir, milu, nsdr,  maxit2, epsslv    
     int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
     CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

     idir = array_recv_i(1)
     milu = .FALSE.
     IF(array_recv_i(2) == 1) milu = .TRUE.
     nsdr = array_recv_i(3)
     maxit2 = array_recv_i(4)
     epsslv = array_recv_r(1)
  ENDIF
#endif
END SUBROUTINE read2_xfer_w
