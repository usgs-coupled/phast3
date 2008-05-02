MODULE interpolate_mod
  ! ... One dimensional and two dimensional interpolation in a table of values
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  INTERFACE interp
     MODULE PROCEDURE interp1d, interp2d
  END INTERFACE
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=85), PRIVATE :: ident_string=  &
       '$RCSfile: interpolate_mod.f90,v $//$Revision: 1.1 $//$Date: 2008/04/07 20:47:21 $'

CONTAINS

  FUNCTION interp1d(xarg, nx, xs, fs) RESULT (interp_val)
    ! ... Linear 1-d interpolation 
    ! ... XS must be in algebraic ascending order
    ! ... If XARG is outside the range of data, extrapolation is done
    REAL(KIND=kdp), INTENT(IN) :: xarg
    INTEGER, INTENT(IN) :: nx
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: xs
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: fs
    REAL(KIND=kdp) :: interp_val
    !
    INTEGER :: i
    REAL(KIND=kdp) :: a1
    ! ----------------------------------------------------------------------------
    !...
    ! ... Find location of xarg in table
    DO i=1,nx
       IF(xs(i) > xarg) EXIT
    END DO
    i = max(i,2)
    a1 = (xarg-xs(i-1))/(xs(i)-xs(i-1))
    interp_val = (1._kdp-a1)*fs(i-1) + a1*fs(i)
  END FUNCTION interp1d

  FUNCTION interp2d(xarg,yarg,nx,ny,xs,ys,fs,erflg) RESULT (interp_val)
    ! ... Linear 2-d interpolation using 4-point bivariate formula
    ! ... XS and YS must be in algebraic ascending order
    ! ... IF XARG,YARG point is outside the range, routine returns erflg
    ! ...      set to true
    USE f_units
    REAL(KIND=kdp), INTENT(IN) :: xarg, yarg
    INTEGER, INTENT(IN) :: nx, ny
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: xs, ys
    REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: fs
    LOGICAL, INTENT(INOUT) :: erflg
    REAL(KIND=kdp) :: interp_val
    !
    INTEGER :: i, j
    REAL(KIND=kdp) :: a1, a2
    ! ----------------------------------------------------------------------------
    !...
    IF(xarg < xs(1).OR.xarg > xs(nx) .OR.yarg < ys(1).OR.yarg > ys(ny)) THEN
       erflg = .true.
       WRITE(fuclog,9001) xarg,' or ',yarg,' is outside table range in INTERP'
9001   FORMAT(/tr30,1PG11.4,a,1PG11.4,a)
       interp_val = HUGE(0._kdp)
       RETURN
    END IF
    ! ... Find x location
    i=1
10  IF(xs(i) > xarg) GO TO 20
    i=i+1
    IF(i <= nx) GO TO 10
    i=nx
20  CONTINUE
    j=1
    ! ... Find y location
30  IF(ys(j) > yarg) GO TO 40
    j=j+1
    IF(j <= ny) GO TO 30
    j=ny
40  a1=(xarg-xs(i-1))/(xs(i)-xs(i-1))
    a2=(yarg-ys(j-1))/(ys(j)-ys(j-1))
    interp_val = (1._kdp-a1)*(1._kdp-a2)*fs(i-1,j-1)+a2*(1._kdp-a1)*fs(i-1,j)+  &
         a1*(1._kdp-a2)*fs(i,j-1)+a1*a2*fs(i,j)
  END FUNCTION interp2d

END MODULE interpolate_mod
