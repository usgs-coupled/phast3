SUBROUTINE XP_welris_thread(iwel,iwfss,uqwmr,xp)
  ! ... Well riser  pressure and temperature calculations
  ! ... Calculates bottom of well riser pressure for injection well or
  ! ...       surface pressure for production well and associated
  ! ...       temperatures
  USE machine_constants, ONLY: kdp
  USE f_units, ONLY: fuwel
  USE mcc, ONLY: heat, errexe, rm_id
  USE mcc_m, ONLY: prtwel
  USE mcch, ONLY: dots, dash
  USE mcch_m, ONLY: 
  USE mcp, ONLY: gz
  USE mcp_m, ONLY: 
  USE mcv, ONLY: time
  USE mcv_m, ONLY: 
  USE mcw, ONLY: wrid, wfrac, wrruf, tatwr, tabwr, wrisl, qhfac, &
    wbod, htcwr, kthwr, dthawr, kthawr
  USE mcw_m, ONLY: 
  USE phys_const
  USE XP_module, ONLY: Transporter
  USE PhreeqcRM
  IMPLICIT NONE
  !INCLUDE "RM_interface_F.f90.inc"
  TYPE (Transporter) :: xp
  INTEGER, INTENT(IN) :: iwel
  INTEGER, INTENT(IN) :: iwfss
  REAL(KIND=kdp), INTENT(IN) :: uqwmr
  !
  REAL(KIND=kdp) :: dzw, fcj, htcu, ilnxi, tambk, timed, utime, xi, zwk
  REAL(KIND=kdp), DIMENSION(2) :: dyy, yy, yyerr, yymax
  INTEGER :: jstart, k, kflag
  LOGICAL :: erflg
  INTEGER, PARAMETER :: kmax=200
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4, logline5
  REAL(KIND=kdp) :: gcosth
  integer :: status
  !     ------------------------------------------------------------------
  !...
  ! ... Initialize
  erflg=.FALSE.
  kflag=0
  gcosth=gz*COS(xp%wrangl(iwel))
  xp%wridt=wrid(iwel)
  ! ... Distance along riser is positive upward
  ! ... xp%qwr>0 is production

  xp%qwr=uqwmr/wfrac(iwel)
  xp%eod=wrruf(iwel)/wrid(iwel)
  xp%eod=MAX(xp%eod,1.25e-5_kdp/wrid(iwel))
  xp%dtadzw=(tatwr(iwel)-tabwr(iwel))/wrisl(iwel)
  IF(xp%dzmin <= 0.) xp%dzmin=.01*wrisl(iwel)
  zwk=0.d0
  ! ... IWFSS=+1 for production well
  IF(iwfss == -1) zwk=wrisl(iwel)
  dzw=iwfss*wrisl(iwel)/10.
  yy(1)=xp%p00
  yy(2)=xp%t00
  yymax(1)=1._kdp
  yymax(2)=1._kdp
  xp%tambi=tabwr(iwel)
  qhfac=0.d0
  IF(heat) THEN
     ! ... Calculate parameters for heat transfer to surrounding medium
     ! ...      at current time level
     ! ... Can not handle time = 0 so set to .1 s
     utime=MAX(time,0.1D0)
     timed=4.*dthawr(iwel)*utime/(wbod(iwel)*wbod(iwel))
     IF(timed <= 1._kdp) THEN
        fcj=1./SQRT(pi*timed)+.5-.25*SQRT(timed/pi)+.125*timed
     ELSE IF(timed >= 3.6_kdp) THEN
        xi=1.260*timed
        ilnxi=1./LOG(xi)
        fcj=2.*ilnxi*(1.+ilnxi*(-.5772+ilnxi*(-1.3118+ilnxi*(.2520  &
             +ilnxi*(3.9969+ilnxi*(5.0637+ilnxi))))))+1.2610*ilnxi  &
             *ilnxi*(1.-1.1544*ilnxi)/timed-2.*(ilnxi**3)/timed
     ELSE
        fcj=.3223*timed+.7257
     END IF
     htcu=2./(wrid(iwel)*htcwr(iwel))+(wbod(iwel)-wrid(iwel))/  &
          (2.*kthwr(iwel))+1./(kthawr(iwel)*fcj)
     qhfac=pi*wrid(iwel)/(htcu*xp%qwr)
     tambk=xp%dtadzw*zwk+xp%tambi
  END IF
  IF(prtwel) THEN
     WRITE(fuwel,2001) iwel,xp%p00,xp%t00,xp%qwr
2001 FORMAT(//tr20, 'Integration of Pressure and Temperature in Well',  &
          ' Riser  -- Well No. ',i3/tr20,60('-')/tr25,  &
          'Inlet Pressure (Pa)  .............',1PG10.3/tr25,  &
          'Inlet Temperature (Deg.C) ........',0PF10.1/tr25,  &
          'Total Fluid Flow Rate (kg/s) .....',1PG10.2)
     WRITE(logline1,5001) 'Integration of Pressure and Temperature in Well',  &
          ' Riser  -- Well No. ',iwel
5001 FORMAT(2a,i3)
     WRITE(logline2,5002) dash
5002 FORMAT(a60)
     WRITE(logline3,5003) 'Inlet Pressure (Pa)  .............',xp%p00  
5003 FORMAT(a,1pg10.3)
     WRITE(logline4,5004) 'Inlet Temperature (Deg.C) ........',xp%t00
5004 FORMAT(a,0pf10.1)
     WRITE(logline5,5005) 'Total Fluid Flow Rate (kg/s) .....',xp%qwr
5005 FORMAT(a,1pg10.2)
    status = RM_LogMessage(rm_id, logline1)
    status = RM_LogMessage(rm_id, logline2)
    status = RM_LogMessage(rm_id, logline3)
    status = RM_LogMessage(rm_id, logline4)
    status = RM_LogMessage(rm_id, logline5)
     WRITE(fuwel,2002)  'Distance    Well Riser    Well Riser  ',  &
          'Porous Medium', 'along Well   Pressure   Temperature   Temperature',  &
          '(m)           (Pa)       (Deg.C)        (Deg.C)',dash
2002 FORMAT(/tr20,2A/tr20,a/tr20,a/tr20,a60)
     WRITE(logline1,5006) 'Distance    Well Riser    Well Riser  ',  &
          'Porous Medium', 'along Well   Pressure   Temperature   Temperature',  &
          '(m)           (Pa)       (Deg.C)        (Deg.C)', dots
5006 FORMAT(2a)
     WRITE(logline2,5006) 'along Well   Pressure   Temperature   Temperature'
     WRITE(logline3,5006) '(m)           (Pa)       (Deg.C)        (Deg.C)'
     WRITE(logline4,5007) dash
5007 FORMAT(a60)
    status = RM_LogMessage(rm_id, logline1)
    status = RM_LogMessage(rm_id, logline2)
    status = RM_LogMessage(rm_id, logline3)
    status = RM_LogMessage(rm_id, logline4)
     WRITE(fuwel,2003) zwk,xp%p00,xp%t00,tambk
2003 FORMAT(tr15,f10.2,1PG15.3,2(0PF10.1))
     WRITE(logline1,5008) zwk,xp%p00,xp%t00,tambk
5008 FORMAT(f10.2,1PG15.3,2(0PF10.1))
  END IF
  jstart=1
  k=1
10 CALL bsode_thread(zwk,yy,dyy,dzw,yymax,yyerr,kflag,jstart,xp)
  IF(kflag > 0) THEN
     errexe=.TRUE.
     WRITE(fuwel,9001) 'Well Riser Integration Step Reached ',  &
          'Minimum DZ Without Reaching Desired Accuracy'
9001 FORMAT(/tr10,2A)
     WRITE(logline1,5001) 'Well Riser Integration Step Reached ',  &
          'Minimum DZ Without Reaching Desired Accuracy'
        status = RM_ErrorMessage(rm_id, logline1)
     RETURN
  END IF
  IF(prtwel) THEN
     WRITE(logline1,5008) zwk,yy(1),yy(2),tambk
        status = RM_ErrorMessage(rm_id, logline1)
     WRITE(fuwel,2003) zwk,yy(1),yy(2),tambk
  ENDIF
  IF(zwk > wrisl(iwel) .OR. zwk < 0.) GO TO 20
  k=k+1
  tambk=xp%dtadzw*zwk+xp%tambi
  IF(k <= kmax) GO TO 10
  WRITE(fuwel,9002) 'Failed to Complete the Well Riser Calculation in ',kmax,' Steps'
9002 FORMAT(tr2,a,i4,a)
  WRITE(logline1,5012) 'Failed to Complete the Well Riser Calculation in ',kmax,' Steps'
5012 FORMAT(a,i4,a)
        status = RM_ErrorMessage(rm_id, logline1)
  ! ... Finished the calculation
  ! ... Linearly extrapolate the pressure, temperature to the end
  ! ...      of the riser pipe
20 IF(iwfss == +1) THEN
     xp%pwrend=yy(1)-dyy(1)*(zwk-wrisl(iwel))
     xp%twrend=yy(2)-dyy(2)*(zwk-wrisl(iwel))
  ELSE
     xp%pwrend=yy(1)-dyy(1)*zwk
     xp%twrend=yy(2)-dyy(2)*zwk
  END IF
!!$  ehwend=ehoftp(xp%twrend,xp%pwrend,erflg)
!!$  IF(erflg) THEN
!!$     WRITE(fuclog,9003) 'EHOFTP interpolation error in WELRIS ', 'Injection well no. ',iwel
!!$9003 FORMAT(tr10,2A,i4)
!!$     ierr(134)=.TRUE.
!!$     errexe=.TRUE.
!!$     RETURN
!!$  END IF

CONTAINS

  SUBROUTINE bsode_thread(zwr,yy,dyy,dz,yymax,yyerr,kflag,jstart,xp)
    ! ... One step of integration of the two o.d.e.'s for the well riser
    ! ...      using a midpoint integration method with the Bulirsch-
    ! ...      Stoer rational function extrapolation method
    ! ... From Gear program p.96
    USE machine_constants, ONLY: kdp
    USE mcw
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
    REAL(KIND=kdp), INTENT(INOUT) :: zwr
    REAL(KIND=kdp), DIMENSION(2), INTENT(INOUT) :: yy
    REAL(KIND=kdp), DIMENSION(2), INTENT(OUT) :: dyy
    REAL(KIND=kdp), INTENT(IN OUT) :: dz
    REAL(KIND=kdp), DIMENSION(2), INTENT(IN OUT) :: yymax
    REAL(KIND=kdp), DIMENSION(2), INTENT(OUT) :: yyerr
    INTEGER, INTENT(OUT) :: kflag
    INTEGER, INTENT(IN) :: jstart
    !
    REAL(KIND=kdp) :: a1, a2, b00, b11, dzchng, &
         fmax = 1.e7_kdp, quotsv, ta, u0, u1, za, zu
    REAL(KIND=kdp), DIMENSION(2) :: dyyn, yymxsv, yyn, yynm1, yysave
    REAL(KIND=kdp), DIMENSION(2,11) :: extrap
    REAL(KIND=kdp), DIMENSION(11,2) ::  quot = RESHAPE((/ 1._kdp, 2.25_kdp, 4._kdp, 9._kdp, &
         16._kdp, 36._kdp, 64._kdp, &
         144._kdp, 256._kdp, 576._kdp, 1024._kdp, &
         1._kdp, 1.77777777777777_kdp, 4._kdp, 7.1111111111111_kdp, 16._kdp, 28.4444444444444_kdp, &
         64._kdp, &
         113.77777777777_kdp, 256._kdp, 455.111111111111_kdp, 1024._kdp/), (/11,2/))
    REAL(KIND=kdp), DIMENSION(2,12) ::  ymaxhv, ynhv, ynm1hv
    INTEGER :: i, j, jhvsv, jhvsv1, jodd, k, l, m, m2, mnext, mtwo
    LOGICAL :: convrg
    !     ------------------------------------------------------------------
    !...
    IF(jstart > 0) THEN
       yysave(1)=yy(1)
       yysave(2)=yy(2)
       yymxsv(1)=yymax(1)
       yymxsv(2)=yymax(2)
       CALL wfdydz_thread(zwr,yy,dyyn,xp)
    ELSE
       yy(1)=yysave(1)
       yy(2)=yysave(2)
       yymax(1)=yymxsv(1)
       yymax(2)=yymxsv(2)
    END IF
10  jhvsv1=0
    kflag=0
20  jhvsv=0
    za=zwr+dz
    jodd=1
    m=1
    mnext=2
    mtwo=3
    DO  i=1,2
       DO  j=1,maxpts
          extrap(i,j)=0._kdp
       END DO
    END DO
    DO  j=1,maxpts
       quotsv=quot(j,jodd)
       quot(j,jodd)=m*m
       convrg=.TRUE.
       IF(j <= maxord/2) convrg=.FALSE.
       IF(j > maxord+1) THEN
          l=maxord+1
          dzchng=.7071068_KDP*dzchng
       ELSE
          l=j
          dzchng=1._kdp+(maxord+1-j)/6._kdp
       END IF
       b0=dz/m
       a2=b0*.5_KDP
       IF(j <= jhvsv1) THEN
          ! ... Use the values of the midpoint integration at the half way
          ! ...     point of the previous integration
          yyn(1)=ynhv(1,j)
          yyn(2)=ynhv(2,j)
          yynm1(1)=ynm1hv(1,j)
          yynm1(2)=ynm1hv(2,j)
          yymax(1)=ymaxhv(1,j)
          yymax(2)=ymaxhv(2,j)
       ELSE
          ! ... Integrate over range H by 2*M steps using midpoint method
          yynm1(1)=yysave(1)
          yynm1(2)=yysave(2)
          yyn(1)=yysave(1)+a2*dyyn(1)
          yyn(2)=yysave(2)+a2*dyyn(2)
          yymax(1)=yymxsv(1)
          yymax(2)=yymxsv(2)
          m2=m+m
          zu=zwr
          DO  k=2,m2
             zu=zu+a2
             CALL wfdydz_thread(zu,yyn,dyy,xp)
             u0=yynm1(1)+b0*dyy(1)
             yynm1(1)=yyn(1)
             yyn(1)=u0
             yymax(1)=MAX(yymax(1),ABS(u0))
             u0=yynm1(2)+b0*dyy(2)
             yynm1(2)=yyn(2)
             yyn(2)=u0
             yymax(2)=MAX(yymax(2),ABS(u0))
             IF(k == m.AND.jhvsv1 == 0.AND.k == 3) THEN
                jhvsv=jhvsv+1
                ynhv(1,jhvsv)=yyn(1)
                ynhv(2,jhvsv)=yyn(2)
                ynm1hv(1,jhvsv)=yynm1(1)
                ynm1hv(2,jhvsv)=yynm1(2)
                ymaxhv(1,jhvsv)=yymax(1)
                ymaxhv(2,jhvsv)=yymax(2)
             END IF
          END DO
       END IF
       CALL wfdydz_thread(za,yyn,dyy,xp)
       DO  i=1,2
          u1=extrap(i,1)
          ! ... Calculate the final value to be used in the extrapolation
          ta=(yyn(i)+yynm1(i)+a2*dyy(i))*.5_KDP
          a1=ta
          ! ... Insert the integral as the first extrapolated value
          extrap(i,1)=ta
          IF(l >= 2) THEN
             IF(ABS(u1)*fmax < ABS(a1)) GO TO 120
             ! ... Extrapolation by rational functions on the second and higher
             ! ...      intervals
             DO  k=2,l
                b1=quot(k,jodd)*u1
                b0=b1-a1
                u0=u1
                IF(ABS(b0) > 0.) THEN
                   b0=(a1-u1)/b0
                   u0=a1*b0
                   a1=b1*b0
                END IF
                u1=extrap(i,k)
                extrap(i,k)=u0
                ta=ta+u0
             END DO
          END IF
          yymax(i)=MAX(yymax(i),ABS(ta))
          yyerr(i)=ABS(yy(i)-ta)
          yy(i)=ta
          IF(yyerr(i) > epswr*yymax(i)) convrg=.FALSE.
       END DO
       quot(j,jodd)=quotsv
       IF(convrg) GO TO 100
       jodd=3-jodd
       m=mnext
       mnext=mtwo
       mtwo=m+m
    END DO
    jhvsv1=jhvsv
90  IF(ABS(dz) <= xp%dzmin) GO TO 110
    dz=.5*dz
    IF(ABS(dz) >= xp%dzmin) GO TO 20
    dz=SIGN(xp%dzmin,dz)
    GO TO 10
100 dz=dz*dzchng
    zwr=za
    RETURN
110 kflag=1
    GO TO 100
120 quot(j,jodd)=quotsv
    GO TO 90
  END SUBROUTINE bsode_thread

  SUBROUTINE wfdydz_thread(zwk,yy,dyy,xp)
    ! ... Calculates the two o.d.e.'s for the well riser pressure
    ! ...      and temperature at a given z location along the riser
    USE machine_constants, ONLY: kdp
    USE mcc
    USE mcp
    USE mcw
    USE phys_const
    USE XP_module, ONLY: Transporter
    IMPLICIT NONE
    TYPE (Transporter) :: xp
    REAL(kind=kdp), INTENT(IN) :: zwk
    REAL(kind=kdp), DIMENSION(2), INTENT(IN) :: yy
    REAL(kind=kdp), DIMENSION(2), INTENT(OUT) :: dyy
    !
    !EXTERNAL viscos
    !REAL(KIND=kdp) :: viscos
    REAL(KIND=kdp) :: c11, c12, c21, c22, det, ffphl, frfac, lgren,  &
         pwrk, qhwrk, ren, tambk, twrk, velwrk, y1, yo
    !     ------------------------------------------------------------------
    !...
    pwrk=yy(1)
    IF(heat) THEN
       twrk=yy(2)
       tambk=xp%dtadzw*zwk+xp%tambi
       qhwrk=qhfac*(tambk-twrk)
    END IF
    denwrk=den0+denp*(pwrk-p0)+dent*(twrk-t0)+denc*c00
    velwrk=4.*xp%qwr/(denwrk*pi*xp%wridt*xp%wridt)
    ! ... Reynolds number for pipe flow
    !ren=ABS(velwrk)*xp%wridt*denwrk/viscos(pwrk,twrk,c00)
    ren=ABS(velwrk)*xp%wridt*denwrk/vis0
    IF(errexe) RETURN
    ! ... Calculate the friction factor for riser pipe (Vennard(1961),Chp.9
    ! ...   xp%eod - Roughness factor/pipe diameter
    lgren=LOG10(ren)
    ! ... Laminar flow Re<2100
    IF(lgren <= 3.3) THEN
       frfac=64./ren
       ! ... Transition flow
    ELSE IF(lgren <= 3.6) THEN
       frfac=10.**(260.67+lgren*(-228.62+lgren*(66.307-6.3944*lgren)))
       ! ... Turbulent flow (smooth to wholly rough)
    ELSE IF(lgren <= 7.0) THEN
       yo = 2.0*LOG10(1./xp%eod) + 1.14
       y1=yo - 2.0*LOG10(1. + 9.28*yo/(xp%eod*ren))
10     IF(ABS((y1-yo)/y1) <= .001_kdp) GO TO 20
       yo = y1
       y1=1.14 - 2.0*LOG10(xp%eod + 9.28*yo/ren)
       GO TO 10
20     frfac =1./(y1*y1)
    ELSE
       ! ... Turbulent flow, high Reynolds number (LGREN>7)(wholly rough)
       ! ...      (Vennard Eq.202)
       frfac=1./(1.14-2.0*LOG10(xp%eod))**2
    END IF
    frfac=frfac*.25
    ffphl=velwrk*velwrk*frfac/xp%wridt
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
  END SUBROUTINE wfdydz_thread

END SUBROUTINE XP_welris_thread
SUBROUTINE welris(iwel,iwfss,uqwmr)
  ! ... Well riser  pressure and temperature calculations
  ! ... Calculates bottom of well riser pressure for injection well or
  ! ...       surface pressure for production well and associated
  ! ...       temperatures
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcc_m
  USE mcch
  USE mcch_m
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE phys_const
  USE PhreeqcRM
  IMPLICIT NONE
  !INCLUDE "RM_interface_F.f90.inc"
  INTEGER, INTENT(IN) :: iwel
  INTEGER, INTENT(IN) :: iwfss
  REAL(KIND=kdp), INTENT(IN) :: uqwmr
  !
  REAL(KIND=kdp) :: dzw, fcj, htcu, ilnxi, tambk, timed, utime, xi, zwk
  REAL(KIND=kdp), DIMENSION(2) :: dyy, yy, yyerr, yymax
  INTEGER :: jstart, k, kflag
  LOGICAL :: erflg
  INTEGER, PARAMETER :: kmax=200
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4, logline5
  integer :: status
  !     ------------------------------------------------------------------
  !...
  ! ... Initialize
  erflg=.FALSE.
  kflag=0
  gcosth=gz*COS(wrangl(iwel))
  wridt=wrid(iwel)
  ! ... Distance along riser is positive upward
  ! ... QWR>0 is production

  qwr=uqwmr/wfrac(iwel)
  eod=wrruf(iwel)/wrid(iwel)
  eod=MAX(eod,1.25e-5_kdp/wrid(iwel))
  dtadzw=(tatwr(iwel)-tabwr(iwel))/wrisl(iwel)
  IF(dzmin <= 0.) dzmin=.01*wrisl(iwel)
  zwk=0.d0
  ! ... IWFSS=+1 for production well
  IF(iwfss == -1) zwk=wrisl(iwel)
  dzw=iwfss*wrisl(iwel)/10.
  yy(1)=p00
  yy(2)=t00
  yymax(1)=1._kdp
  yymax(2)=1._kdp
  tambi=tabwr(iwel)
  qhfac=0.d0
  IF(heat) THEN
     ! ... Calculate parameters for heat transfer to surrounding medium
     ! ...      at current time level
     ! ... Can not handle time = 0 so set to .1 s
     utime=MAX(time,0.1D0)
     timed=4.*dthawr(iwel)*utime/(wbod(iwel)*wbod(iwel))
     IF(timed <= 1._kdp) THEN
        fcj=1./SQRT(pi*timed)+.5-.25*SQRT(timed/pi)+.125*timed
     ELSE IF(timed >= 3.6_kdp) THEN
        xi=1.260*timed
        ilnxi=1./LOG(xi)
        fcj=2.*ilnxi*(1.+ilnxi*(-.5772+ilnxi*(-1.3118+ilnxi*(.2520  &
             +ilnxi*(3.9969+ilnxi*(5.0637+ilnxi))))))+1.2610*ilnxi  &
             *ilnxi*(1.-1.1544*ilnxi)/timed-2.*(ilnxi**3)/timed
     ELSE
        fcj=.3223*timed+.7257
     END IF
     htcu=2./(wrid(iwel)*htcwr(iwel))+(wbod(iwel)-wrid(iwel))/  &
          (2.*kthwr(iwel))+1./(kthawr(iwel)*fcj)
     qhfac=pi*wrid(iwel)/(htcu*qwr)
     tambk=dtadzw*zwk+tambi
  END IF
  IF(prtwel) THEN
     WRITE(fuwel,2001) iwel,p00,t00,qwr
2001 FORMAT(//tr20, 'Integration of Pressure and Temperature in Well',  &
          ' Riser  -- Well No. ',i3/tr20,60('-')/tr25,  &
          'Inlet Pressure (Pa)  .............',1PG10.3/tr25,  &
          'Inlet Temperature (Deg.C) ........',0PF10.1/tr25,  &
          'Total Fluid Flow Rate (kg/s) .....',1PG10.2)
     WRITE(logline1,5001) 'Integration of Pressure and Temperature in Well',  &
          ' Riser  -- Well No. ',iwel
5001 FORMAT(2a,i3)
     WRITE(logline2,5002) dash
5002 FORMAT(a60)
     WRITE(logline3,5003) 'Inlet Pressure (Pa)  .............',p00  
5003 FORMAT(a,1pg10.3)
     WRITE(logline4,5004) 'Inlet Temperature (Deg.C) ........',t00
5004 FORMAT(a,0pf10.1)
     WRITE(logline5,5005) 'Total Fluid Flow Rate (kg/s) .....',qwr
5005 FORMAT(a,1pg10.2)
    status = RM_LogMessage(rm_id, logline1)
    status = RM_LogMessage(rm_id, logline2)
    status = RM_LogMessage(rm_id, logline3)
    status = RM_LogMessage(rm_id, logline4)
    status = RM_LogMessage(rm_id, logline5)
     WRITE(fuwel,2002)  'Distance    Well Riser    Well Riser  ',  &
          'Porous Medium', 'along Well   Pressure   Temperature   Temperature',  &
          '(m)           (Pa)       (Deg.C)        (Deg.C)',dash
2002 FORMAT(/tr20,2A/tr20,a/tr20,a/tr20,a60)
     WRITE(logline1,5006) 'Distance    Well Riser    Well Riser  ',  &
          'Porous Medium', 'along Well   Pressure   Temperature   Temperature',  &
          '(m)           (Pa)       (Deg.C)        (Deg.C)', dots
5006 FORMAT(2a)
     WRITE(logline2,5006) 'along Well   Pressure   Temperature   Temperature'
     WRITE(logline3,5006) '(m)           (Pa)       (Deg.C)        (Deg.C)'
     WRITE(logline4,5007) dash
5007 FORMAT(a60)
    status = RM_LogMessage(rm_id, logline1)
    status = RM_LogMessage(rm_id, logline2)
    status = RM_LogMessage(rm_id, logline3)
    status = RM_LogMessage(rm_id, logline4)
     WRITE(fuwel,2003) zwk,p00,t00,tambk
2003 FORMAT(tr15,f10.2,1PG15.3,2(0PF10.1))
     WRITE(logline1,5008) zwk,p00,t00,tambk
5008 FORMAT(f10.2,1PG15.3,2(0PF10.1))
  END IF
  jstart=1
  k=1
10 CALL bsode(zwk,yy,dyy,dzw,yymax,yyerr,kflag,jstart)
  IF(kflag > 0) THEN
     errexe=.TRUE.
     WRITE(fuwel,9001) 'Well Riser Integration Step Reached ',  &
          'Minimum DZ Without Reaching Desired Accuracy'
9001 FORMAT(/tr10,2A)
     WRITE(logline1,5001) 'Well Riser Integration Step Reached ',  &
          'Minimum DZ Without Reaching Desired Accuracy'
        status = RM_ErrorMessage(rm_id, logline1)
     RETURN
  END IF
  IF(prtwel) THEN
     WRITE(logline1,5008) zwk,yy(1),yy(2),tambk
        status = RM_ErrorMessage(rm_id, logline1)
     WRITE(fuwel,2003) zwk,yy(1),yy(2),tambk
  ENDIF
  IF(zwk > wrisl(iwel) .OR. zwk < 0.) GO TO 20
  k=k+1
  tambk=dtadzw*zwk+tambi
  IF(k <= kmax) GO TO 10
  WRITE(fuwel,9002) 'Failed to Complete the Well Riser Calculation in ',kmax,' Steps'
9002 FORMAT(tr2,a,i4,a)
  WRITE(logline1,5012) 'Failed to Complete the Well Riser Calculation in ',kmax,' Steps'
5012 FORMAT(a,i4,a)
        status = RM_ErrorMessage(rm_id, logline1)
  ! ... Finished the calculation
  ! ... Linearly extrapolate the pressure, temperature to the end
  ! ...      of the riser pipe
20 IF(iwfss == +1) THEN
     pwrend=yy(1)-dyy(1)*(zwk-wrisl(iwel))
     twrend=yy(2)-dyy(2)*(zwk-wrisl(iwel))
  ELSE
     pwrend=yy(1)-dyy(1)*zwk
     twrend=yy(2)-dyy(2)*zwk
  END IF
!!$  ehwend=ehoftp(twrend,pwrend,erflg)
!!$  IF(erflg) THEN
!!$     WRITE(fuclog,9003) 'EHOFTP interpolation error in WELRIS ', 'Injection well no. ',iwel
!!$9003 FORMAT(tr10,2A,i4)
!!$     ierr(134)=.TRUE.
!!$     errexe=.TRUE.
!!$     RETURN
!!$  END IF

CONTAINS

  SUBROUTINE bsode(zwr,yy,dyy,dz,yymax,yyerr,kflag,jstart)
    ! ... One step of integration of the two o.d.e.'s for the well riser
    ! ...      using a midpoint integration method with the Bulirsch-
    ! ...      Stoer rational function extrapolation method
    ! ... From Gear program p.96
    USE machine_constants, ONLY: kdp
    USE mcw
    IMPLICIT NONE
    REAL(KIND=kdp), INTENT(INOUT) :: zwr
    REAL(KIND=kdp), DIMENSION(2), INTENT(INOUT) :: yy
    REAL(KIND=kdp), DIMENSION(2), INTENT(OUT) :: dyy
    REAL(KIND=kdp), INTENT(IN OUT) :: dz
    REAL(KIND=kdp), DIMENSION(2), INTENT(IN OUT) :: yymax
    REAL(KIND=kdp), DIMENSION(2), INTENT(OUT) :: yyerr
    INTEGER, INTENT(OUT) :: kflag
    INTEGER, INTENT(IN) :: jstart
    !
    REAL(KIND=kdp) :: a1, a2, b00, b11, dzchng, &
         fmax = 1.e7_kdp, quotsv, ta, u0, u1, za, zu
    REAL(KIND=kdp), DIMENSION(2) :: dyyn, yymxsv, yyn, yynm1, yysave
    REAL(KIND=kdp), DIMENSION(2,11) :: extrap
    REAL(KIND=kdp), DIMENSION(11,2) ::  quot = RESHAPE((/ 1._kdp, 2.25_kdp, 4._kdp, 9._kdp, &
         16._kdp, 36._kdp, 64._kdp, &
         144._kdp, 256._kdp, 576._kdp, 1024._kdp, &
         1._kdp, 1.77777777777777_kdp, 4._kdp, 7.1111111111111_kdp, 16._kdp, 28.4444444444444_kdp, &
         64._kdp, &
         113.77777777777_kdp, 256._kdp, 455.111111111111_kdp, 1024._kdp/), (/11,2/))
    REAL(KIND=kdp), DIMENSION(2,12) ::  ymaxhv, ynhv, ynm1hv
    INTEGER :: i, j, jhvsv, jhvsv1, jodd, k, l, m, m2, mnext, mtwo
    LOGICAL :: convrg
    !     ------------------------------------------------------------------
    !...
    IF(jstart > 0) THEN
       yysave(1)=yy(1)
       yysave(2)=yy(2)
       yymxsv(1)=yymax(1)
       yymxsv(2)=yymax(2)
       CALL wfdydz(zwr,yy,dyyn)
    ELSE
       yy(1)=yysave(1)
       yy(2)=yysave(2)
       yymax(1)=yymxsv(1)
       yymax(2)=yymxsv(2)
    END IF
10  jhvsv1=0
    kflag=0
20  jhvsv=0
    za=zwr+dz
    jodd=1
    m=1
    mnext=2
    mtwo=3
    DO  i=1,2
       DO  j=1,maxpts
          extrap(i,j)=0._kdp
       END DO
    END DO
    DO  j=1,maxpts
       quotsv=quot(j,jodd)
       quot(j,jodd)=m*m
       convrg=.TRUE.
       IF(j <= maxord/2) convrg=.FALSE.
       IF(j > maxord+1) THEN
          l=maxord+1
          dzchng=.7071068_KDP*dzchng
       ELSE
          l=j
          dzchng=1._kdp+(maxord+1-j)/6._kdp
       END IF
       b0=dz/m
       a2=b0*.5_KDP
       IF(j <= jhvsv1) THEN
          ! ... Use the values of the midpoint integration at the half way
          ! ...     point of the previous integration
          yyn(1)=ynhv(1,j)
          yyn(2)=ynhv(2,j)
          yynm1(1)=ynm1hv(1,j)
          yynm1(2)=ynm1hv(2,j)
          yymax(1)=ymaxhv(1,j)
          yymax(2)=ymaxhv(2,j)
       ELSE
          ! ... Integrate over range H by 2*M steps using midpoint method
          yynm1(1)=yysave(1)
          yynm1(2)=yysave(2)
          yyn(1)=yysave(1)+a2*dyyn(1)
          yyn(2)=yysave(2)+a2*dyyn(2)
          yymax(1)=yymxsv(1)
          yymax(2)=yymxsv(2)
          m2=m+m
          zu=zwr
          DO  k=2,m2
             zu=zu+a2
             CALL wfdydz(zu,yyn,dyy)
             u0=yynm1(1)+b0*dyy(1)
             yynm1(1)=yyn(1)
             yyn(1)=u0
             yymax(1)=MAX(yymax(1),ABS(u0))
             u0=yynm1(2)+b0*dyy(2)
             yynm1(2)=yyn(2)
             yyn(2)=u0
             yymax(2)=MAX(yymax(2),ABS(u0))
             IF(k == m.AND.jhvsv1 == 0.AND.k == 3) THEN
                jhvsv=jhvsv+1
                ynhv(1,jhvsv)=yyn(1)
                ynhv(2,jhvsv)=yyn(2)
                ynm1hv(1,jhvsv)=yynm1(1)
                ynm1hv(2,jhvsv)=yynm1(2)
                ymaxhv(1,jhvsv)=yymax(1)
                ymaxhv(2,jhvsv)=yymax(2)
             END IF
          END DO
       END IF
       CALL wfdydz(za,yyn,dyy)
       DO  i=1,2
          u1=extrap(i,1)
          ! ... Calculate the final value to be used in the extrapolation
          ta=(yyn(i)+yynm1(i)+a2*dyy(i))*.5_KDP
          a1=ta
          ! ... Insert the integral as the first extrapolated value
          extrap(i,1)=ta
          IF(l >= 2) THEN
             IF(ABS(u1)*fmax < ABS(a1)) GO TO 120
             ! ... Extrapolation by rational functions on the second and higher
             ! ...      intervals
             DO  k=2,l
                b1=quot(k,jodd)*u1
                b0=b1-a1
                u0=u1
                IF(ABS(b0) > 0.) THEN
                   b0=(a1-u1)/b0
                   u0=a1*b0
                   a1=b1*b0
                END IF
                u1=extrap(i,k)
                extrap(i,k)=u0
                ta=ta+u0
             END DO
          END IF
          yymax(i)=MAX(yymax(i),ABS(ta))
          yyerr(i)=ABS(yy(i)-ta)
          yy(i)=ta
          IF(yyerr(i) > epswr*yymax(i)) convrg=.FALSE.
       END DO
       quot(j,jodd)=quotsv
       IF(convrg) GO TO 100
       jodd=3-jodd
       m=mnext
       mnext=mtwo
       mtwo=m+m
    END DO
    jhvsv1=jhvsv
90  IF(ABS(dz) <= dzmin) GO TO 110
    dz=.5*dz
    IF(ABS(dz) >= dzmin) GO TO 20
    dz=SIGN(dzmin,dz)
    GO TO 10
100 dz=dz*dzchng
    zwr=za
    RETURN
110 kflag=1
    GO TO 100
120 quot(j,jodd)=quotsv
    GO TO 90
  END SUBROUTINE bsode

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
    !EXTERNAL viscos
    !REAL(KIND=kdp) :: viscos
    REAL(KIND=kdp) :: c11, c12, c21, c22, det, ffphl, frfac, lgren,  &
         pwrk, qhwrk, ren, tambk, twrk, velwrk, y1, yo
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
    !ren=ABS(velwrk)*wridt*denwrk/viscos(pwrk,twrk,c00)
    ren=ABS(velwrk)*wridt*denwrk/vis0
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
10     IF(ABS((y1-yo)/y1) <= .001_kdp) GO TO 20
       yo = y1
       y1=1.14 - 2.0*LOG10(eod + 9.28*yo/ren)
       GO TO 10
20     frfac =1./(y1*y1)
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

END SUBROUTINE welris
