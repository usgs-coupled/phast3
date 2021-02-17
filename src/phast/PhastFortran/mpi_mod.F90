! ... Module file used for definition of mpi parameters and inclusion of
! ...      mpi header files
! ... This module is used by both manager and worker programs
MODULE mpi_mod
#if defined(USE_MPI)
  IMPLICIT NONE
  INCLUDE 'mpif.h'
  SAVE
  INTEGER :: manager=0, xp_comm, world_comm
  INTEGER :: ierrmpi
  INTEGER :: mpi_xp_group, mpi_xp_comm
  INTEGER :: METHOD_SETCOMPONENTS          = 1000, &
             METHOD_WORKERINIT1            = 1001, & 
             METHOD_SETCOMPONENTMAP        = 1002, &
             METHOD_GROUP2DISTRIBUTE       = 1003, &
             METHOD_CREATETRANSPORTERS     = 1004, &
             METHOD_PROCESSRESTARTFILES    = 1005, &
             METHOD_INIT3DISTRIBUTE        = 1006, &
             METHOD_FLOWDISTRIBUTE         = 1008, &
             METHOD_SETFDTMTH              = 1009, &
             METHOD_CDISTRIBUTE            = 1010, &
             METHOD_PDISTRIBUTE            = 1011, &
             METHOD_TIMESTEPWORKER         = 1012, &
             METHOD_RUNTRANSPORT           = 1013, &
             METHOD_SBCGATHER              = 1014, &
             METHOD_CGATHER                = 1015, &
             METHOD_TIMESTEPSAVE           = 1016, &
             METHOD_TIMINGBARRIER          = 1017, &
             METHOD_REGISTERBASICCALLBACK  = 1018, &
             METHOD_CALLBACKDISTRIBUTESTATIC= 1019, &
             METHOD_CALLBACKDISTRIBUTEFRAC = 1020
  
  
CONTAINS  

  SUBROUTINE get_mpi_filename(fname)
    USE mcc
    IMPLICIT NONE
    CHARACTER(LEN=*), INTENT(inout) :: fname
    CHARACTER(LEN=30) :: char_10
    !-------------------------------------------------------------------------------

    IF (mpi_myself == 0) RETURN

    WRITE(char_10,*) mpi_myself
    char_10 = ADJUSTL(char_10)
    char_10 = TRIM(char_10)
    IF (LEN_TRIM(fname(1:LEN_TRIM(fname))//'.'//char_10) > LEN(fname)) THEN
       WRITE(*,*) 'Filename too long:' , fname(1:LEN_TRIM(fname))//'.'//char_10
       STOP "Stopping."
    ENDIF
    fname=fname(1:LEN_TRIM(fname))//'.'//char_10
  END SUBROUTINE get_mpi_filename

  SUBROUTINE update_status(st)
  ! ... Purpose: delete non-root files -- called if MERGE_FILES is defined // MERGE_FILES is OBSOLETE
  ! ... Preconditions:
  ! ...   none
  ! ... Postconditions:
  ! ...   st(1-40) array is set to 'DELETE' for all non-root processes
    USE mcc
    IMPLICIT NONE
    CHARACTER(LEN=6), DIMENSION(40), INTENT(INOUT) :: st
    INTEGER :: i
    !-------------------------------------------------------------------------------
    IF (mpi_myself == 0) RETURN
    DO i=1,40
       st(i) = 'DELETE'
    END DO
  END SUBROUTINE update_status

#endif    /* USE_MPI */  
END MODULE mpi_mod


