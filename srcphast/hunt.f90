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
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
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
10   jhi=jlo+inc
     IF(jhi > n)THEN
        jhi=n+1
     ELSE IF(x >= xx(jhi).EQV.ascnd)THEN
        jlo=jhi
        inc=inc+inc
        GO TO 10
     END IF
  ELSE
     jhi=jlo
20   jlo=jhi-inc
     IF(jlo < 1)THEN
        jlo=0
     ELSE IF(x < xx(jlo).EQV.ascnd)THEN
        jhi=jlo
        inc=inc+inc
        GO TO 20
     END IF
  END IF
30 IF(jhi-jlo > 1) THEN
     jm=(jhi+jlo)/2
     IF(x > xx(jm).EQV.ascnd)THEN
        jlo=jm
     ELSE
        jhi=jm
     END IF
     GO TO 30
  END IF
END SUBROUTINE hunt
