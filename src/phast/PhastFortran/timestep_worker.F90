SUBROUTINE timestep_worker
#if defined(USE_MPI)
  ! ... Calculates the change in time step for automatic time step control
  ! ...      or print time control
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE mcc
  USE mcch, ONLY: unittm
  USE mcp
  USE mcv
  USE mcw
#if defined(USE_MPI)
  USE mpi_mod
#endif
  USE print_control_mod
  IMPLICIT NONE
  INTRINSIC NINT
  REAL(KIND=kdp) :: adc, adp, adt, uctc, udtim, uptc, utime, uttc, udeltim, utimchg
  INTEGER :: itime_m, jtime_m
  CHARACTER(LEN=130) :: logline1, logline0='    '
  INTEGER, DIMENSION(2) :: array_recv_i
  REAL(KIND=kdp), DIMENSION(2) :: array_recv_r
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: timestep_worker.F90,v 1.1 2013/09/19 20:41:58 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Update time step counter
  if (.not. xp_group) return
  itime = itime+1
  jtime = jtime+1
  ! *** receive itime, jtime from manager
    CALL MPI_BCAST(array_recv_i(1), 2, MPI_INTEGER, manager,  &
        world, ierrmpi)

  itime_m = array_recv_i(1); jtime_m = array_recv_i(2)
  CALL MPI_BCAST(deltim, 1, MPI_DOUBLE_PRECISION, manager, world, ierrmpi)
  CALL MPI_BCAST(time, 1, MPI_DOUBLE_PRECISION, manager, world, ierrmpi)

  utime=cnvtmi*(time+deltim)*one_plus_eps
  IF(itime /= itime_m) THEN
     PRINT *, 'Unsynchronized time step, process: ', mpi_myself
     PRINT *, 'itime_worker, itime_manager: ', itime, itime_m
     STOP
  END IF
#endif
END SUBROUTINE timestep_worker
