! ... Module file used for definition of mpi parameters and inclusion of
! ...      mpi header files
! ... This module is used by both manager and worker programs
! ... $Id: mpi_mod.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $
MODULE mpi_mod
#if defined(USE_MPI)
  IMPLICIT NONE
  SAVE
  INCLUDE 'mpif.h' 

  INTEGER :: manager=0, world
  INTEGER :: ierrmpi
  INTEGER :: mpi_xp_group, mpi_xp_comm

CONTAINS  

  SUBROUTINE get_mpi_filename(fname)
    USE mcc
    IMPLICIT NONE
    CHARACTER(LEN=*), INTENT(inout) :: fname
    CHARACTER(LEN=30) :: char_10
    !-------------------------------------------------------------------------------
#if defined(MERGE_FILES)
    IF (mpi_myself == 0) RETURN
#endif

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
  ! ... Purpose: delete non-root files -- called if MERGE_FILES is defined
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


