SUBROUTINE usolv(yy,ra,w)
  ! ... Solves the upper triangular matrix equation, U*YY=W
  ! ... The black-node equations
  USE machine_constants, ONLY: kdp
  USE mcs
  IMPLICIT NONE
  REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: yy
  REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: ra
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: w
  !
  REAL(KIND=kdp) :: s
  INTEGER :: j, jcol, jj, k
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  yy(nbn) = w(nbn)/ra(10,nbn)
  DO  k=nbn-1,1,-1
     s = w(k)
     DO  jj=1,cirh(1,k)
        j = cirh(jj+1,k)
        jcol = cir(j,k)
        s = s - ra(j,k)*yy(jcol)
     END DO
     yy(k) = s/ra(10,k)
  END DO
END SUBROUTINE usolv
