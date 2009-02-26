SUBROUTINE vpsv(x,y,z,s,n)
  ! ... Calculates a vector plus a scalar times a vector
  ! ...      x=y+s*z
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: x
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: y, z
  REAL(KIND=kdp), INTENT(IN) :: s
  INTEGER, INTENT(IN) :: n
  !
  INTEGER :: i
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  DO  i=1,n
     x(i) = y(i)+s*z(i)
  END DO
END SUBROUTINE vpsv
