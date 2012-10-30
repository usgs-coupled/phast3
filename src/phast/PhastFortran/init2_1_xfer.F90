#if defined(USE_MPI)
#include "mpi_fix_case.h"
#endif
! ... $Id: init2_1_xfer.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $
SUBROUTINE init2_1_xfer_m
! ... Transfer calculated group 2 parameters to worker processes
#if defined(USE_MPI)
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcb2_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcm
  USE mcm_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcs
  USE mcs2
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m
  USE phys_const
  USE reorder_mod
  USE mpi_mod
  USE mpi_struct_arrays
  IMPLICIT NONE
  INTEGER, DIMENSION(2) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(3) :: array_bcst_r
  INTEGER :: int_real_type, mpi_array_type
  !     ------------------------------------------------------------------
  !...
  IF (.NOT. solute .OR. .NOT. xp_group) RETURN

  !*** 1 broadcast gx, gy, gz
  ! ... Load the scalar variables
  array_bcst_r(1) = gx; array_bcst_r(2) = gy; array_bcst_r(3) = gz
  int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
  CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager,  &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  ! *** 2 broadcast xd_mask
  CALL MPI_BCAST(xd_mask, SIZE(xd_mask), MPI_INTEGER, manager, &
       world, ierrmpi)

  ! *** 3 broadcast arx, ary, arz
  ! ... create MPI structure for three real arrays
  mpi_array_type=mpi_struct_array(arx, ary, arz)
  ! ... broadcast real arrays to workers
  CALL MPI_BCAST(arx, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  ! *** 4 broadcast pv, pmcv     ***** calculated in init2.1, sumcal
  ! ... create MPI structure for two real arrays
  mpi_array_type=mpi_struct_array(pv, pmcv)
  ! ... broadcast real arrays to workers
  CALL MPI_BCAST(pv, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  ! *** 5 broadcast ibc
  CALL MPI_BCAST(ibc, nxyz, MPI_INTEGER, manager, &
       world, ierrmpi)

  IF(nwel > 0) THEN
     ! *** 6 broadcast wi
     CALL MPI_BCAST(wi, SIZE(wi), MPI_DOUBLE_PRECISION, manager,  &
          world, ierrmpi)  
  ENDIF

  ! ... Specified flux b.c.
  IF(nfbc > 0) THEN   
     ! *** 7 broadcast flux_seg_m, flux_seg_first, flux_seg_last
     ! ... create MPI structure for three integer arrays
     mpi_array_type=mpi_struct_array(flux_seg_m, flux_seg_first, flux_seg_last)
     ! ... broadcast integer arrays to workers
     CALL MPI_BCAST(flux_seg_m, 1, mpi_array_type, manager,  &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)  
  ENDIF

  ! ... Aquifer leakage
  IF(nlbc > 0) THEN 
     ! *** 8 broadcast leak_seg_m, leak_seg_first, leak_seg_last
     ! ... create MPI structure for three integer arrays
     mpi_array_type=mpi_struct_array(leak_seg_m, leak_seg_first, leak_seg_last)
     ! ... broadcast integer arrays to workers
     CALL MPI_BCAST(leak_seg_m, 1, mpi_array_type, manager,  &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi) 
  ENDIF

  ! ... River leakage
  IF(nrbc > 0) THEN  
     ! *** 9 broadcast river_seg_m, river_seg_first, river_seg_last
     ! ***       mrseg_bot, mrbc_bot, mrbc_top
     ! ... create MPI structure for 6 integer arrays
     mpi_array_type=mpi_struct_array(river_seg_m, river_seg_first, river_seg_last,  &
          mrseg_bot, mrbc_bot, mrbc_top)
     ! ... broadcast integer arrays to workers
     CALL MPI_BCAST(river_seg_m, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)  
  ENDIF

  ! ... Drain leakage
  IF(ndbc > 0) THEN  
     ! *** 10 broadcast drain_seg_m, drain_seg_first, drain_seg_last, mdseg_bot, mdbc_bot
     ! ... create MPI structure for 6 integer arraysd
     mpi_array_type=mpi_struct_array(drain_seg_m, drain_seg_first, drain_seg_last,  &
          mdseg_bot, mdbc_bot)
     ! ... broadcast integer arrays to workers
     CALL MPI_BCAST(drain_seg_m, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
  ENDIF

  ! *** 11 broadcast cin
  CALL MPI_BCAST(cin, SIZE(cin), MPI_INTEGER, manager, &
       world, ierrmpi)

  IF(slmeth == 1) THEN  
     ! *** 12 broadcast ind, mrno, mord, ip1, ip1r, ipenv
     ! ... create MPI structure for 6 integer arrays
     mpi_array_type=mpi_struct_array(ind, mrno, mord, ip1, ip1r, ipenv)
     ! ... broadcast integer arrays to workers
     CALL MPI_BCAST(ind, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 13 broadcast ci
     CALL MPI_BCAST(ci, SIZE(ci), MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 14 broadcast cir, cirh, cirl
     ! ... create MPI structure for three integer 2-D arrays
     mpi_array_type=mpi_struct_array(cir, cirh, cirl)
     ! ... broadcast integer 2-D arrays to workers
     CALL MPI_BCAST(cir, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! ... 15 broadcast nrn, nbn
     ! ... Load the scalar variables
     array_bcst_i(1) = nrn; array_bcst_i(2) = nbn
     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager,  &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)
  ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN 

     ! *** 16 broadcast ind, mrno, mord
     ! ... create MPI structure for three integer arrays
     mpi_array_type=mpi_struct_array(ind, mrno, mord)
     ! ... broadcast integer arrays to workers
     CALL MPI_BCAST(ind, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 17 broadcast ci
     CALL MPI_BCAST(ci, SIZE(ci), MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 18 broadcast cir, cirh, cirl
     ! ... create MPI structure for three integer 2-D arrays
     mpi_array_type=mpi_struct_array(cir, cirh)
     ! ... broadcast integer 2-D arrays to workers
     CALL MPI_BCAST(cir, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 18.1 broadcast cir1, mar1
     ! ... create MPI structure for three integer 2-D arrays
     mpi_array_type=mpi_struct_array(cirl, mar1)
     ! ... broadcast integer 2-D arrays to workers
     CALL MPI_BCAST(cirl, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! ... 19 broadcast nrn, nbn
     ! ... Load the scalar variables
     array_bcst_i(1) = nrn; array_bcst_i(2) = nbn
     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager,  &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)
  ENDIF

  ! *** 20 broadcast frac, frac_icchem
  ! ... create MPI structure for two real arrays
  mpi_array_type=mpi_struct_array(frac, frac_icchem)
  ! ... broadcast real arrays to workers
  CALL MPI_BCAST(frac, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  ! *** 21 broadcast mfsbc
  CALL MPI_BCAST(mfsbc, nxy, MPI_INTEGER, manager, &
       world, ierrmpi) 

#endif
END SUBROUTINE init2_1_xfer_m

SUBROUTINE init2_1_xfer_w
  ! ... Receive calculated group 2 data from workers
#if defined(USE_MPI)
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcs
  USE mcs2
  USE mcv
  USE mcw
  USE phys_const
  USE mpi_mod
  USE mpi_struct_arrays
  USE reorder_mod
  IMPLICIT NONE
  INTEGER :: a_err, nr, i, mt, ipmz
  INTEGER :: int_real_type, mpi_array_type
  INTEGER, DIMENSION(2) :: array_recv_i
  REAL(KIND=kdp), DIMENSION(3) :: array_recv_r
  INTEGER, DIMENSION(8) :: iisd=(/7,8,5,6,3,4,1,2/)
  LOGICAL :: all_dry, some_dry
  !     ------------------------------------------------------------------
  ! ...
  IF (.NOT. solute .OR. .NOT. xp_group) RETURN
  nr=nx
  ! ... convert the data to s.i. time units if necessary
  ! ...      even if an error abort is set
!!$ IF(tmunit > 1) CALL etom1_trans
  IF(cylind) THEN  
     ! ...    case of cylindrical grid - single well exclusive of
     ! ...       observation wells
     ! ...      heterogeneous in z only
     y(1) = 0._kdp  
     DO  i=1,nr-1  
        rm(i) = (x(i+1) - x(i))/LOG(x(i+1)/x(i))  
     END DO
     orenpr = 13  
  ENDIF

  !*** 1 broadcast gx, gy, gz
  ! ... receive gx, gy, gz
  int_real_type = MPI_struct_array(array_recv_i,array_recv_r)
  CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  gx = array_recv_r(1); gy = array_recv_r(2); gz = array_recv_r(3)

  ! ... Import the mask for cross dispersion calculation
  ! ...     identifying inactive neighbor nodes: mcg
  ALLOCATE (xd_mask(0:nx+1,0:ny+1,0:nz+1),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: init2_1_xfer_w, number 1"  
     STOP
  ENDIF

  ! *** 2 broadcast xd_mask   
  CALL MPI_BCAST(xd_mask, SIZE(xd_mask), MPI_INTEGER, manager, &
       world, ierrmpi)
  IF(errexi) RETURN
  IF(paatm <= 0._kdp) paatm = 1.01325e5_kdp
  den0 = denf0  
  denp = 0._kdp  
  dent = 0._kdp  
  denc = 0._kdp
  vis0 = ABS(visfac)
  ! ... Allocate geometry information: mcg 
  ALLOCATE (arx(nxyz), ary(nxyz), arz(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: init2_1_xfer_w, number 2"
     STOP
  ENDIF
  ! ... Allocate parameter arrays: mcp
  ! ...      conductance, capacitance arrays
  ALLOCATE (tx(nxyz), ty(nxyz), tz(nxyz), tfx(nxyz), tfy(nxyz), tfz(nxyz),  &
       tsx(nxyz), tsy(nxyz), tsz(nxyz), tsxy(nxyz), tsxz(nxyz), tsyx(nxyz), tsyz(nxyz),  &
       tszx(nxyz), tszy(nxyz),  &
       pv(nxyz), pmcv(nxyz), pmhv(1), pmchv(1), pvk(1),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: init2_1_xfer_w, number 3"
     STOP
  ENDIF
  pvk = 0._kdp
  pmchv = 0._kdp
  pmhv = 0._kdp

  ! *** 3 broadcast arx, ary, arz    
  ! ... receive arx, ary, arz arrays
  mpi_array_type = mpi_struct_array(arx, ary, arz)
  ! ... receive broadcast of real arrays
  CALL MPI_BCAST(arx, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  ! *** 4 broadcast pv, pmcv     ***** calculated in init2.1, sumcal    
  ! ... receive pv, pmcv arrays
  mpi_array_type = mpi_struct_array(pv, pmcv)
  ! ... receive broadcast of real arrays
  CALL MPI_BCAST(pv, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  ! *** 5 broadcast ibc    
  ! ... receive ibc array
  ! ... receive broadcast of integer array
  CALL MPI_BCAST(ibc, nxyz, MPI_INTEGER, manager, &
       world, ierrmpi)

  IF(nwel > 0) THEN
     ! ... Allocate more well arrays: mcw
     ALLOCATE (iw(nwel), jw(nwel), wi(nwel,nz),  &
          qwlyr(nwel,nz), qflyr(nwel,nz), dqwdpl(nwel,nz),  &
          denwk(nwel,nz), pwk(nwel,nz), twk(1,1), udenw(nz),  &
          dpwkt(nwel), tfw(nz),  &
          qwm(nwel), qwv(nwel), qwv_n(nwel), qhw(1),  &
          pwsurs(nwel), pwkt(nwel),  &
          rhsw(nz), vaw(7,nz),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: init2_1_xfer_w, number 7"  
        STOP
     ENDIF
     dpwkt = 0
     qwv = 0
     qwv_n = 0
     pwsurs = 0._kdp
     qflyr = 0._kdp
     !!$        qslyr = 0._kdp
     !!$        qsw = 0._kdp
     qwm = 0._kdp
     qwv = 0._kdp

     ! *** 6 broadcast wi        
     ! ... Import the well index factors
     CALL MPI_BCAST(wi, SIZE(wi), MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)
  END IF

  ! ... Specified value b.c.
  IF(nsbc > 0) THEN  
     ! ... Allocate specified value b.c. arrays: mcb
     ALLOCATE (qfsbc(nsbc), qhsbc(1),  &
          fracnp(nsbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2_1_xfer_w, number 9, svbc"  
        STOP
     ENDIF
     qfsbc = 0.0_kdp
  ENDIF

  ! ... Specified flux b.c.
  IF(nfbc > 0) THEN
     ! ... Allocate specified flux b.c. arrays: mcb
     ALLOCATE (qffbc(nfbc), qfbcv(nfbc), qhfbc(1),  &
          flux_seg_m(nfbc), flux_seg_first(nfbc), flux_seg_last(nfbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2_1_xfer_w, number 13, flux"  
        STOP
     ENDIF
     qffbc = 0.0_kdp
     ! *** 7 broadcast flux_seg_m, flux_seg_first, flux_seg_last
     ! ... receive the flux index structure; first and last segments per flux cell
     mpi_array_type = mpi_struct_array(flux_seg_m,flux_seg_first,flux_seg_last)
     ! ... receive broadcast of integer arrays
     CALL MPI_BCAST(flux_seg_m, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
     ! ... Zero the arrays for flux b.c.
     !        qsflx = 0._kdp
  ENDIF

  ! ... Aquifer leakage
  IF(nlbc > 0) THEN  
     ! ... Allocate leakage b.c. arrays: mcb
     ALLOCATE (qflbc(nlbc),  & 
          leak_seg_m(nlbc), leak_seg_first(nlbc), leak_seg_last(nlbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2_1_xfer_w, number 15, leak"  
        STOP
     ENDIF
     qflbc = 0
     ! *** 8 broadcast leak_seg_m, leak_seg_first, leak_seg_last
     ! ... receive the leakage index structure; first and last segments per leakage cell
     mpi_array_type = mpi_struct_array(leak_seg_m,leak_seg_first,leak_seg_last)
     ! ... receive broadcast of integer arrays
     CALL MPI_BCAST(leak_seg_m, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
     ! ... Zero the arrays for aquifer leakage
     albc = 0._kdp          ! ***??? needed here???
  ENDIF

  ! ... River leakage
  IF(nrbc > 0) THEN
     ! ... Allocate river leakage b.c. arrays: mcb
     ALLOCATE (qfrbc(nrbc), &
          river_seg_m(nrbc), river_seg_first(nrbc), river_seg_last(nrbc),  &
          mrbc_bot(nrbc), mrbc_top(nrbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2_1_xfer_w, number 17, river"  
        STOP
     ENDIF
     qfrbc = 0.0_kdp

     ! *** 9 broadcast river_seg_m, river_seg_first, river_seg_last
     ! ***       mrseg_bot, mrbc_bot, mrbc_top
     ! ... receive the river index structure; first and last segments per river cell
     mpi_array_type = mpi_struct_array(river_seg_m,river_seg_first,river_seg_last, &
          mrseg_bot,mrbc_bot,mrbc_top)
     ! ... receive broadcast of integer arrays
     CALL MPI_BCAST(river_seg_m, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
     ! ... Zero the arrays for river leakage
     arbc = 0._kdp          ! **** needed here???
  ENDIF

  ! ... Drain leakage
  IF(ndbc > 0) THEN
     ! ... Allocate drain b.c. arrays: mcb
     ALLOCATE (qfdbc(ndbc), &
          drain_seg_m(ndbc), drain_seg_first(ndbc), drain_seg_last(ndbc),  &
          mdbc_bot(ndbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2_1_xfer_w, number 19, drain"  
        STOP
     ENDIF
     qfdbc = 0.0_kdp

     ! *** 10 broadcast drain_seg_m, drain_seg_first, drain_seg_last
     ! ***       mdseg_bot, mdbc_bot       
     ! ... receive the drain index structure; first and last segments per drain cell
     mpi_array_type = mpi_struct_array(drain_seg_m,drain_seg_first,drain_seg_last, &
          mdseg_bot, mdbc_bot)
     ! ... receive broadcast of integer arrays
     CALL MPI_BCAST(drain_seg_m, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
     ! ... Zero the arrays for drain leakage
     adbc = 0._kdp
  ENDIF

  ! ... Import cell connection list for natural numbering
  ! ... Allocate solver space: mcs
  ALLOCATE (cin(6,nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN
     PRINT *, "array allocation failed: init2_1_xfer_w, number 22"
     STOP
  ENDIF

  ! *** 11 broadcast cin    
  ! *** receive cin
  CALL MPI_BCAST(cin, SIZE(cin), MPI_INTEGER, manager, &
       world, ierrmpi)

  IF(slmeth == 1) THEN
     ! ... Allocate solver arrays: mcs
     ALLOCATE (ind(nxyz), mrno(nxyz), mord(nxyz),  &
          ip1(nxyzh), ip1r(nxyzh), ipenv(nxyzh+2),  &
          ci(6,nxyz), cir(lrcgd1,nxyzh), cirh(lrcgd2,nxyzh), cirl(lrcgd2,nxyzh),  &
          STAT = a_err)
     IF (a_err /= 0) THEN
        PRINT *, "array allocation failed: init2_1_xfer_w, number 24"
        STOP
     ENDIF

     ! *** 12 broadcast ind, mrno, mord, ip1, ip1r, ipenv
     ! ... receive d4 cell reordering for reduced matrix, ra
     mpi_array_type = mpi_struct_array(ind,mrno,mord,ip1,ip1r,ipenv)
     ! ... receive broadcast of integer arrays
     CALL MPI_BCAST(ind, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 13 broadcast ci       
     CALL MPI_BCAST(ci, SIZE(ci), MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 14 broadcast cir, cirh, cirl     
     mpi_array_type = mpi_struct_array(cir,cirh,cirl)
     ! ... receive broadcast of integer 2-D arrays
     CALL MPI_BCAST(cir, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! ... 15 broadcast nrn, nbn
     ! ... receive nrn, nbn
     int_real_type = MPI_struct_array(array_recv_i,array_recv_r)
     CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)
     nrn = array_recv_i(1); nbn = array_recv_i(2)

     ! ... allocate space for the solver
     ! ... allocate space for the solver: mcs2
     ALLOCATE(diagra(nbn), envlra(ipenv(nbn+1)), envura(ipenv(nbn+1)),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2_1_xfer_w, number 25"
        STOP
     ENDIF

  ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN
     ! ... Allocate solver arrays: mcs
     ALLOCATE (ind(nxyz), mrno(nxyz), mord(nxyz), ci(6,nxyz), cir(lrcgd1,nxyzh), &
          cirh(lrcgd2,nxyzh), cirl(lrcgd2,nxyzh), &
          STAT = a_err)
     IF (a_err /= 0) THEN
        PRINT *, "array allocation failed: init2_1_xfer_w, number 26"
        STOP
     ENDIF

     ! *** 16 broadcast ind, mrno, mord
     ! ... receive red-black or d4z cell reordering for reduced matrix, ra
     mpi_array_type=mpi_struct_array(ind,mrno,mord)
     ! ... receive broadcast of integer arrays
     CALL MPI_BCAST(ind, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 17 broadcast ci 
     CALL MPI_BCAST(ci, SIZE(ci), MPI_INTEGER, manager, &
          world, ierrmpi)

     ! *** 18 broadcast cir, cirh          
     mpi_array_type = mpi_struct_array(cir,cirh)
     ! ... receive broadcast of integer 2-D arrays
     CALL MPI_BCAST(cir, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! *** 18.1 broadcast cir1, mar1
     mpi_array_type=mpi_struct_array(cirl, mar1)
     ! ... broadcast integer 2-D arrays to workers
     CALL MPI_BCAST(cirl, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     ! ... 19 broadcast nrn, nbn    
     ! ... receive nrn, nbn
     int_real_type = MPI_struct_array(array_recv_i,array_recv_r)
     CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)
     nrn = array_recv_i(1); nbn = array_recv_i(2)

     ! ... allocate space for the solver: mcs2
     ALLOCATE(ap(nrn,0:nsdr), bbp(nbn,0:nsdr), ra(lrcgd1,nbn), rr(nrn), sss(nbn),  &
          xx(nxyz), ww(nrn), zz(nbn), sumfil(nbn),  &
          STAT = a_err)
     IF (a_err /= 0) THEN
        PRINT *, "array allocation failed: init2_1_xfer_w, number 27"
        STOP
     ENDIF

  ENDIF
  ! ... allocate space for the assembly of difference equations: mcm
  ALLOCATE(va(7,nxyz), rhs(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: init2_1_xfer_w, number 28"
     STOP
  ENDIF

  ! ... Allocate more solver arrays: mcs
  ALLOCATE(diagc(nxyz), diagr(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: init2_1_xfer_w, number 29"
     STOP
  ENDIF

  ident_diagc = .TRUE.       !***** flag for diagnostic; column scaling
  ! ... Allocate free surface, water table arrays: mcb and mg2_m
  ALLOCATE (mfsbc(nxy), &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: init2_1_xfer_w, number 30"  
     STOP
  ENDIF

  ! *** 20 broadcast frac, frac_icchem   
  ! ... initial conditions
  ! ... receive the initial condition fraction of cell that is saturated
  mpi_array_type = mpi_struct_array(frac,frac_icchem)
  ! ... receive broadcast of real arrays
  CALL MPI_BCAST(frac, 1, mpi_array_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

  ! *** 21 broadcast mfsbc  
  ! ... receive the pointer to the free-surface cells
  CALL MPI_BCAST(mfsbc, nxy, MPI_INTEGER, manager, &
       world, ierrmpi)

  all_dry = .TRUE.
  some_dry = .FALSE.
  DO mt=1,nxy
     IF(mfsbc(mt) /= 0) all_dry = .FALSE.
     IF(mfsbc(mt) == 0) some_dry = .TRUE.
  END DO
  IF (all_dry) ierr(40) = .TRUE.
  IF (some_dry) THEN
     !**     CALL warnprt_c('One or more columns are dry.')
  ENDIF

  IF(crosd) THEN
     ! ... cancel cross-dispersive term calculation if all
     ! ...      alpha_l equal alpha_t
     crosd = .FALSE.
     DO ipmz=1,npmz  
        IF(ABS(alphl(ipmz) - alphth(ipmz)) > 1.e-6_kdp) crosd = .TRUE.
        IF(ABS(alphl(ipmz) - alphtv(ipmz)) > 1.e-6_kdp) crosd = .TRUE.
     END DO
  ENDIF
  fdtmth_tr = fdtmth     ! ... save the input time difference weight
  time = timrst*cnvtm
  deltim_sav = 0._kdp
  itime = 0
  ! ... Set timchg to zero to force the first READ3 read in
  timchg = 0._kdp
  ! ... Set steady flow convergence flag even if no steady i.c. to
  ! ...      be computed
  converge_ss = .FALSE.
  pv0 = pv
  time_phreeqc = time
#endif
END SUBROUTINE init2_1_xfer_w
