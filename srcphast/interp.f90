FUNCTION interp(ndim,xarg,yarg,nx,ny,xs,ys,fs,erflg) RESULT (interp_val)
  ! ... Linear 1-d interpolation  or
  ! ...    linear 2-d interpolation using 4-point bivariate formula
  ! ... XS and YS must be in algebraic ascending order
  ! ... If XARG is outside the range of data, extrapolation is done
  ! ...      for one dimensional invocation
  ! ... IF XARG,YARG point is outside the range, routine returns erflg
  ! ...      set to true, for two dimensional invocation
  USE machine_constants, ONLY: bgint, kdp
!  USE f_units
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: ndim
  REAL(KIND=kdp), INTENT(IN) :: xarg, yarg
  INTEGER, INTENT(IN) :: nx, ny
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: xs, ys
  REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: fs
  LOGICAL, INTENT(INOUT) :: erflg
  REAL(KIND=kdp) :: interp_val
  !
  REAL(KIND=kdp) :: a1, a2
  INTEGER :: i, j
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF(ndim == 2) THEN
     IF(xarg < xs(1).OR.xarg > xs(nx) .OR.yarg < ys(1).OR.yarg > ys(ny)) THEN
        erflg=.TRUE.
        WRITE(logline1,9001) xarg,' or ',yarg,' is outside table range in INTERP'
9001    FORMAT(1PG11.4,a,1PG11.4,a)
        call errprt_c(logline1)
        interp_val = REAL(bgint,KIND=kdp)
        RETURN
     END IF
  END IF
  ! ... Find x location
  i=1
10 IF(xs(i) > xarg) GO TO 20
  i=i+1
  IF(i <= nx) GO TO 10
  i=nx
20 j=1
  ! ... Find y location
  IF(ndim == 2) THEN
30   IF(ys(j) > yarg) GO TO 40
     j=j+1
     IF(j <= ny) GO TO 30
     j=ny
  END IF
40 a1=(xarg-xs(i-1))/(xs(i)-xs(i-1))
  IF(ndim == 1) THEN
     a2=1.d0
     j=1
  ELSE IF(ndim == 2) THEN
     a2=(yarg-ys(j-1))/(ys(j)-ys(j-1))
  END IF
  interp_val = (1._kdp-a1)*(1._kdp-a2)*fs(i-1,j-1)+a2*(1._kdp-a1)*fs(i-1,j)+  &
       a1*(1._kdp-a2)*fs(i,j-1)+a1*a2*fs(i,j)
END FUNCTION interp
