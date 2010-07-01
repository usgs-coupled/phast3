MODULE mpi_mod
#if defined USE_MPI
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! mpimod.F90
  !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! ... $Id$
#if defined(LAHEY_F95) || defined(NO_UNDERSCORES)
#define MPI_INIT_      MPI_INIT
#define MPI_COMM_SIZE_ MPI_COMM_SIZE
#define MPI_COMM_RANK_ MPI_COMM_RANK
#endif

  IMPLICIT NONE
  INTEGER :: g_mpi_tasks
  INTEGER :: g_mpi_myself

CONTAINS

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!  ! init_mpi
!!!!  !
!!!!  ! Preconditions:
!!!!  !   none
!!!!  !
!!!!  ! Postconditions:
!!!!  !   g_mpi_tasks and g_mpi_myself are valid
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!  SUBROUTINE init_mpi(mpi_tasks, mpi_myself)
!!!!    IMPLICIT NONE
!!!!!MS$ NOFREEFORM
!!!!      INCLUDE 'mpif.h'
!!!!!MS$ FREEFORM
!!!!#if defined(_WIN32)
!!!!    !MS$ ATTRIBUTES Default :: mpi_dup_fn    
!!!!    !MS$ ATTRIBUTES Default :: mpi_null_delete_fn    
!!!!    !MS$ ATTRIBUTES Default :: mpi_null_copy_fn    
!!!!    !MS$ ATTRIBUTES Default :: mpi_comm_dup_fn    
!!!!    !MS$ ATTRIBUTES Default :: mpi_comm_null_delete_fn
!!!!    !MS$ ATTRIBUTES Default :: mpi_comm_null_copy_fn
!!!!    !MS$ ATTRIBUTES Default :: mpi_win_dup_fn
!!!!    !MS$ ATTRIBUTES Default :: mpi_win_null_delete_fn
!!!!    !MS$ ATTRIBUTES Default :: mpi_win_null_copy_fn
!!!!    !MS$ ATTRIBUTES Default :: mpi_type_dup_fn
!!!!    !MS$ ATTRIBUTES Default :: mpi_type_null_delete_fn
!!!!    !MS$ ATTRIBUTES Default :: mpi_type_null_copy_fn
!!!!    !MS$ ATTRIBUTES Default :: mpi_conversion_fn_null
!!!!#endif
!!!!    INTERFACE
!!!!       SUBROUTINE MPI_INIT_(ierror)
!!!!#if defined(_WIN32)
!!!!         !MS$ ATTRIBUTES Default :: MPI_INIT
!!!!#endif
!!!!         INTEGER ierror
!!!!       END SUBROUTINE MPI_INIT_
!!!!       SUBROUTINE MPI_COMM_SIZE_(comm, size, ierror)
!!!!#if defined(_WIN32)
!!!!         !MS$ ATTRIBUTES Default :: MPI_COMM_SIZE
!!!!#endif
!!!!         INTEGER :: comm
!!!!         INTEGER :: size
!!!!         INTEGER :: ierror
!!!!       END SUBROUTINE MPI_COMM_SIZE_
!!!!       SUBROUTINE MPI_COMM_RANK_(comm, rank, ierror)
!!!!#if defined(_WIN32)
!!!!         !MS$ ATTRIBUTES Default :: MPI_COMM_RANK
!!!!#endif
!!!!         INTEGER :: comm
!!!!         INTEGER :: rank
!!!!         INTEGER :: ierror
!!!!       END SUBROUTINE MPI_COMM_RANK_
!!!!    END INTERFACE
!!!!
!!!!    INTEGER, INTENT(OUT) :: mpi_tasks
!!!!    INTEGER, INTENT(OUT) :: mpi_myself
!!!!    INTEGER :: my_mpi_error
!!!!
!!!!    CALL MPI_INIT_(my_mpi_error)
!!!!    IF (my_mpi_error /= 0) THEN
!!!!       WRITE(*,*) "MPI_INIT failed."
!!!!       STOP "Stopping."
!!!!    ENDIF
!!!!    CALL MPI_COMM_SIZE_(MPI_COMM_WORLD, mpi_tasks, my_mpi_error)
!!!!    IF (my_mpi_error /= 0) THEN
!!!!       WRITE(*,*) "MPI_COMM_SIZE failed."
!!!!       STOP "Stopping."
!!!!    ENDIF
!!!!    CALL MPI_COMM_RANK_(MPI_COMM_WORLD, mpi_myself, my_mpi_error)
!!!!    IF (my_mpi_error /= 0) THEN
!!!!       WRITE(*,*) "MPI_COMM_RANK failed."
!!!!       STOP "Stopping."
!!!!    ENDIF
!!!!    g_mpi_tasks = mpi_tasks
!!!!    g_mpi_myself = mpi_myself
!!!!  END SUBROUTINE init_mpi

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! get_mpi_filename
  !
  ! Purpose: prepend process id to file name  -- called if USE_MPI is defined
  !          if MERGE_FILES is defined root process filename is unchanged
  !
  ! Preconditions:
  !   fname contains enough space to prepend integer process id
  !
  ! Postconditions:
  !   TODO
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  SUBROUTINE get_mpi_filename(fname)
    IMPLICIT NONE
    CHARACTER(LEN=*), INTENT(inout) :: fname
    CHARACTER(LEN=30) :: char_10

#if defined(MERGE_FILES)
    IF (g_mpi_myself == 0) RETURN
#endif

    WRITE(char_10,*) g_mpi_myself
    char_10 = ADJUSTL(char_10)
    char_10 = TRIM(char_10)
    IF (LEN_TRIM(fname(1:LEN_TRIM(fname))//'.'//char_10) > LEN(fname)) THEN
       WRITE(*,*) 'Filename too long:' , fname(1:LEN_TRIM(fname))//'.'//char_10
       STOP "Stopping."
    ENDIF
    fname=fname(1:LEN_TRIM(fname))//'.'//char_10
  END SUBROUTINE get_mpi_filename

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! update_status
  !
  ! Purpose: delete non-root files -- called if MERGE_FILES is defined
  !
  ! Preconditions:
  !   none
  !
  ! Postconditions:
  !   ST(1-40) array is set to 'DELETE' for all non-root processes
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  SUBROUTINE update_status(ST)
    IMPLICIT NONE
    CHARACTER(LEN=6), DIMENSION(40), INTENT(INOUT) :: ST
    INTEGER :: i

    IF (g_mpi_myself == 0) RETURN
    DO i=1,40
       ST(i) = 'DELETE'
    END DO
  END SUBROUTINE update_status

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! ltrim (similar to ADJUSTL)
  !
  ! Purpose: remove spaces from beginning of string
  !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!$SUBROUTINE ltrim(STRING)
!!$  IMPLICIT NONE
!!$  CHARACTER (LEN=*) STRING
!!$  INTEGER i
!!$
!!$  DO i=1, LEN_TRIM(STRING) - 1
!!$    IF (STRING(1:1) .EQ. ' ') THEN
!!$      STRING = STRING(2:)
!!$    ELSE
!!$      EXIT
!!$    ENDIF
!!$ END DO
!!$END SUBROUTINE ltrim
#endif    /* USE_MPI */
END MODULE mpi_mod
