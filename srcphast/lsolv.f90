SUBROUTINE lsolv(ra,rr,w)
  ! ... Solves the lower triangular matrix equation, L*w=rr
  USE machine_constants, ONLY: kdp
  USE mcs
  IMPLICIT NONE
  REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: ra
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: rr
  REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: w
  !
  REAL(KIND=kdp) :: s
  INTEGER :: j, jcol, jj, k
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: lsolv.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  w(1) = rr(1)
  DO  k=2,nbn
     s = rr(k)
     DO  jj=1,cirl(1,k)
        j = cirl(jj+1,k)
        jcol = cir(j,k)
        s = s-ra(j,k)*w(jcol)
     END DO
     w(k) = s
  END DO
END SUBROUTINE lsolv
