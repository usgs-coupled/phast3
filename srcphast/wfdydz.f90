SUBROUTINE wfdydz(zwk,yy,dyy)
  ! ... Calculates the two o.d.e.'s for the well riser pressure
  ! ...      and temperature at a given z location along the riser
  USE machine_constants, ONLY: kdp
  USE mcc
  USE mcp
  USE mcw
  USE phys_const
  IMPLICIT NONE
  REAL(kind=kdp), INTENT(IN) :: zwk
  REAL(kind=kdp), DIMENSION(2), INTENT(IN) :: yy
  REAL(kind=kdp), DIMENSION(2), INTENT(OUT) :: dyy
  !
  EXTERNAL viscos
  REAL(KIND=kdp) :: viscos
  REAL(KIND=kdp) :: c11, c12, c21, c22, det, ffphl, frfac, lgren,  &
       pwrk, qhwrk, ren, tambk, twrk, velwrk, y1, yo
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: wfdydz.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  pwrk=yy(1)
  IF(heat) THEN
     twrk=yy(2)
     tambk=dtadzw*zwk+tambi
     qhwrk=qhfac*(tambk-twrk)
  END IF
  denwrk=den0+denp*(pwrk-p0)+dent*(twrk-t0)+denc*c00
  velwrk=4.*qwr/(denwrk*pi*wridt*wridt)
  ! ... Reynolds number for pipe flow
  ren=ABS(velwrk)*wridt*denwrk/viscos(pwrk,twrk,c00)
  IF(errexe) RETURN
  ! ... Calculate the friction factor for riser pipe (Vennard(1961),Chp.9
  ! ...   EOD - Roughness factor/pipe diameter
  lgren=LOG10(ren)
  ! ... Laminar flow Re<2100
  IF(lgren <= 3.3) THEN
     frfac=64./ren
     ! ... Transition flow
  ELSE IF(lgren <= 3.6) THEN
     frfac=10.**(260.67+lgren*(-228.62+lgren*(66.307-6.3944*lgren)))
     ! ... Turbulent flow (smooth to wholly rough)
  ELSE IF(lgren <= 7.0) THEN
     yo = 2.0*LOG10(1./eod) + 1.14
     y1=yo - 2.0*LOG10(1. + 9.28*yo/(eod*ren))
10   IF(ABS((y1-yo)/y1) <= .001_kdp) GO TO 20
     yo = y1
     y1=1.14 - 2.0*LOG10(eod + 9.28*yo/ren)
     GO TO 10
20   frfac =1./(y1*y1)
  ELSE
     ! ... Turbulent flow, high Reynolds number (LGREN>7)(wholly rough)
     ! ...      (Vennard Eq.202)
     frfac=1./(1.14-2.0*LOG10(eod))**2
  END IF
  frfac=frfac*.25
  ffphl=velwrk*velwrk*frfac/wridt
  c11=cpf
  c12=-dent*velwrk*velwrk
  c21=-dent*twrk/denwrk
  c22=denp*velwrk*velwrk-1./denwrk
  det=c11*c22-c21*c12
  b1=gcosth+ffphl
  b2=qhwrk+ffphl
  IF(heat) THEN
     dyy(1)=(c11*b1+c12*b2)/det
     dyy(2)=(c21*b1+c22*b2)/det
  ELSE
     dyy(1)=b1/c22
     dyy(2)=0.
  END IF
END SUBROUTINE wfdydz
