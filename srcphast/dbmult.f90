SUBROUTINE dbmult(x,y)
  ! ... Multiplies diag_A*Y for the black nodes
  USE machine_constants, ONLY: kdp
  USE mcm
  USE mcs
  IMPLICIT NONE
  REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: x
  REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: y
  !
  INTEGER :: i, j
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  DO  i=1,nbn
     j = i+nrn
     x(i) = y(i)*va(7,j)
  END DO
END SUBROUTINE dbmult
