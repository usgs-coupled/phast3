SUBROUTINE stonb(c,j,incj)
  ! ... Spaces forward or back to next non-blank character in C
  ! ... RS is considered a blank
  IMPLICIT NONE
  CHARACTER(LEN=*), INTENT(IN) :: c
  INTEGER, INTENT(INOUT) :: j
  INTEGER, INTENT(IN) :: incj
  !
  CHARACTER(LEN=1), PARAMETER :: sp=' '
  INTEGER :: ncol
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: stonb.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  ncol = len(c)
10 IF(j > ncol .OR. j < 1 .OR. c(j:j) /= sp) GO TO 20
  j=j+incj
  GO TO 10
20 RETURN
END SUBROUTINE stonb
