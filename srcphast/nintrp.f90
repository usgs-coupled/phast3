FUNCTION nintrp(xarg,nx,xs,erflg)
  ! ... Linear 1-d interpolation
  ! ... XS must be in algebraic ascending order
  ! ... If XARG is outside the range, a zero index is returned
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  REAL(KIND=kdp), INTENT(IN) :: xarg
  INTEGER, INTENT(IN) :: nx
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: xs
  LOGICAL, INTENT(INOUT) :: erflg
  INTEGER :: nintrp
  !
  INTRINSIC ABS, NINT
  REAL(KIND=kdp) :: a1, xarga
  INTEGER :: i
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: nintrp.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  xarga=xarg
  IF(xarg < 0.5*(xs(1)+xs(nx))) xarga=xarg+1.e-6_kdp*ABS(xs(nx)-xs(1))+1.e-6_kdp
  IF(xarg > 0.5*(xs(1)+xs(nx))) xarga=xarg-1.e-6_kdp*ABS(xs(nx)-xs(1))-1.e-6_kdp 
  IF(nx == 1.OR.xarga < xs(1).OR.xarga > xs(nx)) THEN
     erflg=.TRUE.
     nintrp=0
     RETURN
  END IF
  ! ... Find x location
  i=2
10 IF(xs(i) > xarga) GO TO 20
  i=i+1
  IF(i <= nx) GO TO 10
  i=nx
20 a1=(xarga-xs(i-1))/(xs(i)-xs(i-1))
  nintrp=NINT(a1)+i-1
END FUNCTION nintrp
