#if defined(USE_MPI)
#include "mpi_fix_case.h"
#endif
! ... $Id: init3_xfer.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $
SUBROUTINE init3_distribute
  ! ... Send or receive data from transient read3 group 
  USE mcc              ! ... get sizes from modules
  USE mcv
  USE XP_module, ONLY: Transporter, xp_list
  IMPLICIT NONE
  INTEGER :: i
  !     ------------------------------------------------------------------
  !...
  IF (.NOT. solute) RETURN
  IF (.NOT. xp_group) RETURN

#if defined (USE_MPI)
  IF (mpi_tasks > 1) THEN
     IF (xp_group) THEN
        IF (mpi_myself == 0) THEN
           CALL init3_bcast_m
        ELSE
           CALL init3_bcast_w
        ENDIF
     ENDIF
     IF (thru) RETURN

     DO i = 1, ns
        IF (component_map(i) > 0) THEN
           IF (mpi_myself == component_map(i)) THEN
              CALL XP_init3_xfer(xp_list(local_component_map(i)))
           ENDIF
        ENDIF
     ENDDO

     IF (mpi_myself == 0) THEN
        CALL init3_xfer_m
     ENDIF
  ENDIF

#endif 
! end USE_MPI

  IF (thru) RETURN
  DO i = 1, ns
     IF (component_map(i) == 0 .AND. mpi_myself == 0) THEN
        CALL XP_init3_set(xp_list(local_component_map(i)))
     ENDIF
  ENDDO
END SUBROUTINE init3_distribute

SUBROUTINE thru_distribute
#if defined(USE_MPI)
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcv
  USE mcw
  USE mpi_mod
  USE mpi_struct_arrays
  IMPLICIT NONE
  INTEGER :: int_real_type
  INTEGER, DIMENSION(2) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(2) :: array_bcst_r
  !--------------------------------------------------------------------------
  !
  if (solute) then
     IF (mpi_myself == 0) THEN
        array_bcst_i(1) = 0
        IF (thru) array_bcst_i(1) = 1 
     ENDIF
     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     ! ... NOTE: broadcast to all processes, not just xp_world
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager,  &
          MPI_COMM_WORLD, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)
     IF (mpi_myself > 0) THEN
        thru = .FALSE.
        IF (array_bcst_i(1) == 1) thru = .TRUE.
     ENDIF
  endif
#endif
END SUBROUTINE thru_distribute

SUBROUTINE init3_bcast_m
  ! ... Send group 3 data from manager to workers
#if defined(USE_MPI)
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcv
  USE mcw
  USE mpi_mod
  USE mpi_struct_arrays
  IMPLICIT NONE
  INTEGER :: int_real_type
  INTEGER, DIMENSION(2) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(2) :: array_bcst_r
  !--------------------------------------------------------------------------
  !
  IF (.NOT. solute) RETURN

!!$! read flags from read3
  ! *** 1 broadcast thru
  array_bcst_i(1) = 0
  IF (thru) array_bcst_i(1) = 1 

  int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
  CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager,  &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)
  IF(thru) RETURN

  ! ... 2 receive the flag for rdwtd
  IF(nwel > 0) THEN
     array_bcst_i(1) = 0
     IF (rdwtd) array_bcst_i(1) = 1
     CALL MPI_BCAST(array_bcst_i, 1, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  !*** 3 broadcast rdspbc, rdscbc
  IF(nsbc > 0) THEN
     array_bcst_i(1) = 0
     IF (rdspbc) array_bcst_i(1) = 1
     array_bcst_i(2) = 0
     IF (rdscbc) array_bcst_i(2) = 1
     CALL MPI_BCAST(array_bcst_i, 2, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  ! *** 4 broadcast rdflxq, rdflxs
  IF(nfbc > 0) THEN
     array_bcst_i(1) = 0
     IF (rdflxq) array_bcst_i(1) = 1
     array_bcst_i(2) = 0
     IF (rdflxs) array_bcst_i(2) = 1
     CALL MPI_BCAST(array_bcst_i, 2, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  ! *** 5 broadcast rdlbc
  IF(nlbc > 0) THEN
     array_bcst_i(1) = 0
     IF (rdlbc) array_bcst_i(1) = 1
     CALL MPI_BCAST(array_bcst_i, 1, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  ! *** 6 broadcast rdrbc
  IF(nrbc > 0) THEN
     array_bcst_i(1) = 0
     IF (rdrbc) array_bcst_i(1) = 1
     CALL MPI_BCAST(array_bcst_i, 1, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  ! *** 7 broadcast rdcalc
  array_bcst_i(1) = 0
  IF (rdcalc) array_bcst_i(1) = 1
  CALL MPI_BCAST(array_bcst_i, 1, MPI_INTEGER, manager, &
       world, ierrmpi)

  ! ... Data for all workers from init3
  IF(rdwtd) THEN
     ! *** 1 broadcast qwv
     CALL MPI_BCAST(qwv, SIZE(qwv), MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)
  ENDIF

  IF(rdspbc .OR. rdscbc) THEN
     ! *** 3 broadcast psbc
     CALL MPI_BCAST(psbc, nsbc_seg, MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)

     IF(fresur) THEN
        ! *** 5 broadcast frac
        CALL MPI_BCAST(frac, nxyz, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)
     END IF
  ENDIF

  ! ... 6 broadcast the pointer array to the free surface cells
  CALL MPI_BCAST(mfsbc, nxy, MPI_INTEGER, manager, &
       world, ierrmpi)


  IF(rdflxq) THEN
     ! ... 7 broadcast qfflx
     CALL MPI_BCAST(qfflx, nfbc_seg, MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)
  END IF

  IF(rdlbc) THEN
     ! *** 9 broadcast philbc
     CALL MPI_BCAST(philbc, nlbc_seg, MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)
  END IF

  ! ... River leakage b.c.
  IF(rdrbc) THEN
     ! *** 11 broadcast phirbc
     CALL MPI_BCAST(phirbc, nrbc_seg, MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)
  END IF

  ! *** 13 broadcast deltim, timchg
  array_bcst_r(1) = deltim; array_bcst_r(2) = timchg
  int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
  CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

#endif 
! end USE_MPI
END SUBROUTINE init3_bcast_m

SUBROUTINE init3_bcast_w
  ! ... Receive group 3 data from workers to manager
#if defined(USE_MPI)
  ! ... Receives time varying b.c. rate data at each time of b.c. change, TIMCHG
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcp
  USE mcv
  USE mcw
  USE mpi_mod
  USE mpi_struct_arrays
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTEGER :: ls
  INTEGER, SAVE :: ntd=0
  INTEGER :: int_real_type
  INTEGER, DIMENSION(2) :: array_recv_i
  REAL(KIND=kdp), DIMENSION(2) :: array_recv_r
  CHARACTER(LEN=130) :: logline1
  !     ------------------------------------------------------------------
  !
!!$! Read Flags From Read3
  Int_real_type = Mpi_struct_array(Array_recv_i,Array_recv_r)
  CALL MPI_BCAST(Array_recv_i, 1, Int_real_type, Manager,  &
       World, Ierrmpi)
  CALL MPI_TYPE_FREE(Int_real_type,Ierrmpi)

  Thru = .FALSE.
  IF (Array_recv_i(1) == 1) Thru = .TRUE.

  IF(Thru) RETURN

  ntd = ntd+1
  !***** Progress output message
  WRITE(logline1,'(a,i2)') 'Receiving transient data for simulation: Set ',ntd
  CALL logprt_c(logline1)

  ! ... 2 receive the flag for rdwtd
  IF(nwel > 0) THEN
     ! ... receive the flag for rdwtd
     CALL MPI_BCAST(array_recv_i, 1, MPI_INTEGER, manager, &
          world, ierrmpi)
     rdwtd = .FALSE.
     IF (array_recv_i(1) == 1) rdwtd = .TRUE.
  END IF

  !*** 3 broadcast rdspbc, rdscbc
  IF(nsbc > 0) THEN
     ! ... Receive specified pressure b.c. and assoc concentration
     CALL MPI_BCAST(array_recv_i, 2, MPI_INTEGER, manager, &
          world, ierrmpi)
     rdspbc = .FALSE.
     IF (array_recv_i(1) == 1) rdspbc = .TRUE.
     rdscbc = .FALSE.
     IF (array_recv_i(2) == 1) rdscbc = .TRUE.
  END IF

  ! *** 4 broadcast rdflxq, rdflxs
  IF(nfbc > 0) THEN
     ! ... Receive specified fluid flux b.c.
     ! ...      volumetric fluxes
     CALL MPI_BCAST(array_recv_i, 2, MPI_INTEGER, manager, &
          world, ierrmpi)
     rdflxq = .FALSE.
     IF (array_recv_i(1) == 1) rdflxq = .TRUE.
     ! ... Solute diffusive fluxes for no flow b.c.
     ! ... Specified solute flux b.c.
     rdflxs = .FALSE.
     IF (array_recv_i(2) == 1) rdflxs = .TRUE.
  END IF

  ! *** 5 broadcast rdlbc
  IF(nlbc > 0) THEN
     CALL MPI_BCAST(array_recv_i, 1, MPI_INTEGER, manager, &
          world, ierrmpi)
     rdlbc = .FALSE.
     IF (array_recv_i(1) == 1) rdlbc = .TRUE.
  END IF

  ! *** 6 broadcast rdrbc
  IF(nrbc > 0) THEN
     CALL MPI_BCAST(array_recv_i, 1, MPI_INTEGER, manager, &
          world, ierrmpi)
     rdrbc = .FALSE.
     IF (array_recv_i(1) == 1) rdrbc = .TRUE.
  END IF

  ! *** 7 broadcast rdcalc
  CALL MPI_BCAST(array_recv_i, 1, MPI_INTEGER, manager, &
       world, ierrmpi)
  rdcalc = .FALSE.
  IF (array_recv_i(1) == 1) rdcalc = .TRUE.

  ! ... Data calculated in init3 for from? all workers 

  IF(tmunit > 1) CALL XP_etom2(xp)
  ! ... Well data
  IF(rdwtd) THEN
     ! *** 1 broadcast qwv
     CALL MPI_BCAST(qwv, SIZE(qwv), MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)
  END IF
  ! ... Specified value b.c.
  IF(rdspbc .OR. rdscbc) THEN
     ! ... Load the mass fractions for
     ! ...      specified pressure nodes into the b.c. arrays
     ! *** 3 broadcast psbc
     CALL MPI_BCAST(psbc, nsbc_seg, MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)

     IF(fresur) THEN
        ! *** 5 broadcast frac
        CALL MPI_BCAST(frac, nxyz, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)
     END IF
  END IF

  ! ... 6 broadcast the pointer array to the free surface cells
  CALL MPI_BCAST(mfsbc, nxy, MPI_INTEGER, manager, &
       world, ierrmpi)

  ! ... Specified flux b.c.
  IF(rdflxq) THEN
     ! ... 7 broadcast qfflx
     CALL MPI_BCAST(qfflx, nfbc_seg, MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)
     DO  ls=1,nfbc_seg
        denfbc(ls) = den0
     END DO
  END IF

  ! ... Aquifer leakage b.c.
  IF(rdlbc) THEN
     ! *** 9 broadcast philbc
     CALL MPI_BCAST(philbc, nlbc_seg, MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)
     DO  ls=1,nlbc_seg
        denlbc(ls) = den0
        vislbc(ls) = vis0
     END DO
  END IF

  ! ... River leakage b.c.
  IF(rdrbc) THEN
     ! *** 11 broadcast phirbc
     CALL MPI_BCAST(phirbc, nrbc_seg, MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi)
     DO  ls=1,nrbc_seg
        denrbc(ls) = den0
        visrbc(ls) = vis0
     END DO
  END IF

  ! ... Drain leakage b.c.
  visdbc = vis0

  ! ... Calculation information
  IF(rdcalc) THEN
     deltim_sav = 0._kdp
     autots = .FALSE.
     IF(autots) THEN
        ! ... If automatic time step, set the default controls if necessary
        ! ...      This will never be with this phast version
        IF(dptas <= 0.) dptas=5.e4_kdp
        IF(dttas <= 0.) dttas=5._kdp
        IF(dtimmn <= 0.) dtimmn=1.e4_kdp
        IF(dtimmx <= 0.) dtimmx=1.e7_kdp
        deltim = dtimmn
     END IF
  END IF

  ! *** 13 broadcast deltim, timchg
  int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
  CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager, &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  jtime = 0
  deltim = array_recv_r(1); timchg = array_recv_r(2)
#endif 
! end USE_MPI
END SUBROUTINE init3_bcast_w

SUBROUTINE init3_xfer_m
  ! ... Send calculated transient group 3 data to workers
#if defined(USE_MPI)
  USE machine_constants, ONLY: bgreal, kdp
  USE mcb
  USE mcb_m
  USE mcc
  USE mcv
  USE mcw
  USE mcw_m
  USE mpi_mod
  USE mpi_struct_arrays
  IMPLICIT NONE
  INTEGER :: iis, tag
  !--------------------------------------------------------------------------
  IF (.NOT. solute) RETURN

  tag = 0
  DO iis=1,ns
     IF (component_map(iis) > 0) THEN 
        IF(rdwtd) THEN
           ! *** 2 send cwkt concentration array to worker processes; only 1 iis to each worker
           ! ... Send iis component of cwkt array to worker iis using nonblocking MPI send.
           CALL MPI_SEND(cwkt(:,iis), nwel, MPI_DOUBLE_PRECISION, &
                component_map(iis), tag, world, ierrmpi)
        ENDIF

        IF(rdspbc .OR. rdscbc) THEN
           ! *** 4 send csbc concentration array to worker processes
           ! ... Send iis component of csbc array to worker iis using nonblocking
           ! ...   MPI send.
           CALL MPI_SEND(csbc(:,iis), nsbc_seg, MPI_DOUBLE_PRECISION, &
                component_map(iis), tag, world, ierrmpi)
        ENDIF

        IF(rdflxq) THEN
           ! *** 8 send cfbc concentration array to worker processes
           ! ... Send iis component of cfbc array to worker iis using nonblocking
           ! ...   MPI send.
           CALL MPI_SEND(cfbc(:,iis), nfbc_seg, MPI_DOUBLE_PRECISION, &
                component_map(iis), tag, world, ierrmpi)
        ENDIF

        IF(rdlbc) THEN
           ! *** 10 send clbc concentration array to worker processes
           ! ... Send iis component of clbc array to worker iis using nonblocking
           ! ...   MPI send.
           CALL MPI_SEND(clbc(:,iis), nlbc_seg, MPI_DOUBLE_PRECISION, &
                component_map(iis), tag, world, ierrmpi)
        ENDIF

        ! ... River leakage b.c.
        IF(rdrbc) THEN
           ! *** 12 send crbc concentration array to worker processes
           ! ... Send iis component of crbc array to worker iis using nonblocking
           ! ...   MPI send.
           CALL MPI_SEND(crbc(:,iis), nrbc_seg, MPI_DOUBLE_PRECISION, &
                component_map(iis), tag, world, ierrmpi)
        ENDIF
     ENDIF
  ENDDO
#endif 
! end USE_MPI
END SUBROUTINE init3_xfer_m

SUBROUTINE XP_init3_xfer(xp)
  ! ... Receives time varying b.c. rate data at each time of b.c. change, TIMCHG
#if defined(USE_MPI)
  USE mcb
  USE mcc
  USE mcw
  USE mpi_mod
  USE mpi_struct_arrays
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTEGER :: iwel, tag
  !     ------------------------------------------------------------------
  !...
  ! ... Convert the data to S.I. time units if necessary
  IF(tmunit > 1) CALL XP_etom2(xp)

  ! ... Well data
  tag = 0
  IF(rdwtd) THEN
     ! *** 2 send cwkt concentration array to worker processes; only 1 iis to each worker
     CALL MPI_RECV(xp%cwkt, nwel, MPI_DOUBLE_PRECISION, manager,  &
          tag, world, MPI_STATUS_IGNORE, ierrmpi)
     DO  iwel=1,nwel
        IF(wqmeth(iwel) == 12 .OR. wqmeth(iwel) == 13) THEN
           xp%cwkts(iwel) = xp%cwkt(iwel)
        END IF
     END DO
  END IF

  ! ... Specified value b.c.
  IF(rdspbc .OR. rdscbc) THEN
     ! *** 4 send csbc concentration array to worker processes
     CALL MPI_RECV(xp%csbc, nsbc_seg, MPI_DOUBLE_PRECISION, manager,  &
          tag, world, MPI_STATUS_IGNORE, ierrmpi)
  END IF

  ! ... Specified flux b.c.
  IF(rdflxq) THEN
     ! *** 8 send cfbc concentration array to worker processes
     CALL MPI_RECV(xp%cfbc, nfbc_seg, MPI_DOUBLE_PRECISION, manager, &
          tag, world, MPI_STATUS_IGNORE, ierrmpi)
  END IF

  ! ... Aquifer leakage b.c.
  IF(rdlbc) THEN
     ! *** 10 send clbc concentration array to worker processes
     CALL MPI_RECV(xp%clbc, nlbc_seg, MPI_DOUBLE_PRECISION, manager, &
          tag, world, MPI_STATUS_IGNORE, ierrmpi)
  END IF

  ! ... River leakage b.c.
  IF(rdrbc) THEN
     ! *** 12 send crbc concentration array to worker processes
     CALL MPI_RECV(xp%crbc, nrbc_seg, MPI_DOUBLE_PRECISION, manager, &
          tag, world, MPI_STATUS_IGNORE, ierrmpi)
  END IF
#endif 
! end USE_MPI
END SUBROUTINE XP_init3_xfer

SUBROUTINE XP_init3_set(xp)
  ! ... Loads transporter derived type with calculated or selected group 3 data
  USE machine_constants, ONLY: bgreal, kdp
!!$  USE mcb
  USE mcb_m
  USE mcc
  USE mcw
  USE mcw_m
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTEGER :: iis, iwel
  !     ------------------------------------------------------------------
  !...
  iis = xp%iis_no
  ! ... Convert the data to S.I. time units if necessary
  IF(tmunit > 1) CALL XP_etom2(xp)

  IF(rdwtd) THEN
     ! *** 2 send cwkt concentration array to worker processes; only 1 iis to each worker
     ! ... Send iis component of cwkt array to worker iis using nonblocking MPI send.
     xp%cwkt = cwkt(:,iis)
     DO  iwel=1,nwel
        IF(wqmeth(iwel) == 12 .OR. wqmeth(iwel) == 13) THEN
           xp%cwkts(iwel) = xp%cwkt(iwel)
        ENDIF
     ENDDO
  END IF

  IF(rdspbc .OR. rdscbc) THEN
     ! *** 4 send csbc concentration array to worker processes
     ! ... Send iis component of csbc array to worker iis using nonblocking
     ! ...   MPI send.
     xp%csbc = csbc(:,iis)
  ENDIF

  IF(rdflxq) THEN
     ! *** 8 send cfbc concentration array to worker processes
     ! ... Send iis component of cfbc array to worker iis using nonblocking
     ! ...   MPI send.
     xp%cfbc = cfbc(:,iis)
  ENDIF

  IF(rdlbc) THEN
     ! *** 10 send clbc concentration array to worker processes
     ! ... Send iis component of clbc array to worker iis using nonblocking
     ! ...   MPI send.
     xp%clbc = clbc(:,iis)
  ENDIF

  ! ... River leakage b.c.
  IF(rdrbc) THEN
     ! *** 12 send crbc concentration array to worker processes
     ! ... Send iis component of crbc array to worker iis using nonblocking
     ! ...   MPI send.
     xp%crbc = crbc(:,iis)
  ENDIF
END SUBROUTINE XP_init3_set


