#if defined(USE_MPI)
#include 'mpi_fix_case.h'
#endif
SUBROUTINE timestep_worker
#if defined(USE_MPI)
  ! ... Calculates the change in time step for automatic time step control
  ! ...      or print time control
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE mcc
  USE mcch, ONLY: unittm
  USE mcp
  USE mcv
!$$  USE mcv_w
  USE mcw
!$$  USE mcw_w
#if defined(USE_MPI)
  USE mpi_mod
  USE mpi_struct_arrays
#endif
  USE print_control_mod
  IMPLICIT NONE
  INTRINSIC NINT
  REAL(KIND=kdp) :: adc, adp, adt, uctc, udtim, uptc, utime, uttc, udeltim, utimchg
  INTEGER :: itime_m, jtime_m
  CHARACTER(LEN=130) :: logline1, logline0='    '
  INTEGER :: int_real_type, mpi_array_type
  INTEGER, DIMENSION(2) :: array_recv_i
  REAL(KIND=kdp), DIMENSION(2) :: array_recv_r
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: timestep_worker.F90,v 1.1 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Update time step counter
  if (.not. xp_group) return
  itime = itime+1
  jtime = jtime+1
  ! *** receive itime, jtime from manager
  int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
  CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager,  &
       world, ierrmpi)
  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  itime_m = array_recv_i(1); jtime_m = array_recv_i(2)
  CALL MPI_BCAST(deltim, 1, MPI_DOUBLE_PRECISION, manager, world, ierrmpi)
  CALL MPI_BCAST(time, 1, MPI_DOUBLE_PRECISION, manager, world, ierrmpi)

!!$  deltim = array_recv_r(1); time = array_recv_r(2)
  utime=cnvtmi*(time+deltim)*one_plus_eps
!!$  IF(itime /= itime_m .OR. jtime /= jtime_m) THEN
  IF(itime /= itime_m) THEN
     PRINT *, 'Unsynchronized time step, process: ', mpi_myself
     PRINT *, 'itime_worker, itime_manager: ', itime, itime_m
     STOP
  END IF
#endif
END SUBROUTINE timestep_worker
