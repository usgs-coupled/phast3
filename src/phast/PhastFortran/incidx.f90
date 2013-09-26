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
  !
  REAL(KIND=kdp) :: eps, x1m, x2p
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: incidx.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  !  eps=1.d-6*(x2-x1)+1.d-6
  !  eps = max(eps,abs(x1*1e-7))
  !  eps = max(eps,abs(x2*1e-7))
  eps=1.d-7*(xs(nx)-xs(1))+1.d-10
  x1m=x1-eps
  x2p=x2+eps
  IF(x1m > x2p.OR.x1m > xs(nx).OR.x2p < xs(1)) THEN
     erflg=.TRUE.
     i1=0
     i2=0
     RETURN
  END IF
  i1=1
  i2=nx
  CALL hunt(xs,nx,x1m,i1)
  CALL hunt(xs,nx,x2p,i2)
  i1=i1+1

CONTAINS

  SUBROUTINE hunt(xx,n,x,jlo)
    ! ... From Numerical Recipes, p.91
    ! ... Given array XX of length N, and given X, returns value JLO
    ! ...      such that X is between XX(JLO) and XX(JLO+1).
    ! ...      X may equal XX(JLO)
    ! ...      XX must be monotonic increasing or decreasing.
    USE machine_constants, ONLY: kdp
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: xx
    INTEGER, INTENT(IN) :: n
    REAL(KIND=kdp), INTENT(IN) :: x
    INTEGER, INTENT(INOUT) :: jlo
    !
    INTEGER :: inc, jhi, jm
    LOGICAL :: ascnd
    !     ------------------------------------------------------------------
    !...
    ascnd=xx(n) >= xx(1)
    IF(jlo <= 0.OR.jlo > n)THEN
       jlo=0
       jhi=n+1
       GO TO 30
    END IF
    inc=1
    IF(x >= xx(jlo).EQV.ascnd)THEN
10     jhi=jlo+inc
       IF(jhi > n)THEN
          jhi=n+1
       ELSE IF(x >= xx(jhi).EQV.ascnd)THEN
          jlo=jhi
          inc=inc+inc
          GO TO 10
       END IF
    ELSE
       jhi=jlo
20     jlo=jhi-inc
       IF(jlo < 1)THEN
          jlo=0
       ELSE IF(x < xx(jlo).EQV.ascnd)THEN
          jhi=jlo
          inc=inc+inc
          GO TO 20
       END IF
    END IF
30  IF(jhi-jlo > 1) THEN
       jm=(jhi+jlo)/2
       IF(x > xx(jm).EQV.ascnd)THEN
          jlo=jm
       ELSE
          jhi=jm
       END IF
       GO TO 30
    END IF
  END SUBROUTINE hunt


END SUBROUTINE incidx
