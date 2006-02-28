SUBROUTINE incidx(x1,x2,nx,xs,i1,i2,erflg)
  ! ... Given X1 and X2, finds I1 and I2 indices of XS, where
  ! ...     [XS(I1),XS(I2)] is the range of XS contained between
  ! ...     X1 and X2.
  ! ... X1,X2,XS must be in algebraic ascending order and monotonic
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  REAL(KIND=KDP), INTENT(IN) :: x1, x2
  INTEGER, INTENT(IN) :: nx
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: xs
  INTEGER, INTENT(OUT) :: i1, i2
  LOGICAL, INTENT(INOUT) :: erflg
  INTERFACE
     SUBROUTINE hunt(xx,n,x,jlo)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: xx
       INTEGER, INTENT(IN) :: n
       REAL(kind=kdp), INTENT(IN) :: x
       INTEGER, INTENT(INOUT) :: jlo
     END SUBROUTINE hunt
  END INTERFACE
  !
  REAL(KIND=kdp) :: eps, x1m, x2p
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
!  eps=1.d-6*(x2-x1)+1.d-6
!  eps = max(eps,abs(x1*1e-7))
!  eps = max(eps,abs(x2*1e-7))
  eps=1.d-7*(xs(nx)-xs(1))+1.d-10
  x1m=x1-eps
  x2p=x2+eps
  IF(x1m > x2p.OR.x1m > xs(nx).OR.x2p < xs(1)) THEN
     erflg=.true.
     i1=0
     i2=0
     RETURN
  END IF
  i1=1
  i2=nx
  CALL hunt(xs,nx,x1m,i1)
  CALL hunt(xs,nx,x2p,i2)
  i1=i1+1
END SUBROUTINE incidx
