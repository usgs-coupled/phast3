SUBROUTINE welris(iwel,iwfss,uqwmr)
  ! ... Well riser  pressure and temperature calculations
  ! ... Calculates bottom of well riser pressure for injection well or
  ! ...       surface pressure for production well and associated
  ! ...       temperatures
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcch
  USE mcp
  USE mcv
  USE mcw
  USE phys_const
  IMPLICIT NONE
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
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
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
5001 format(2a,i3)
     WRITE(logline2,5002) dash
5002 format(a60)
     WRITE(logline3,5003) 'Inlet Pressure (Pa)  .............',p00  
5003 format(a,1pg10.3)
     WRITE(logline4,5004) 'Inlet Temperature (Deg.C) ........',t00
5004 format(a,0pf10.1)
     WRITE(logline5,5005) 'Total Fluid Flow Rate (kg/s) .....',qwr
5005 format(a,1pg10.2)
     call logprt_c(logline1)
     call logprt_c(logline2)
     call logprt_c(logline3)
     call logprt_c(logline4)
     call logprt_c(logline5)
     WRITE(fuwel,2002)  'Distance    Well Riser    Well Riser  ',  &
          'Porous Medium', 'along Well   Pressure   Temperature   Temperature',  &
          '(m)           (Pa)       (Deg.C)        (Deg.C)',dash
2002 FORMAT(/tr20,2A/tr20,a/tr20,a/tr20,a60)
     WRITE(logline1,5006) 'Distance    Well Riser    Well Riser  ',  &
          'Porous Medium', 'along Well   Pressure   Temperature   Temperature',  &
          '(m)           (Pa)       (Deg.C)        (Deg.C)', dots
5006 format(2a)
     WRITE(logline2,5006) 'along Well   Pressure   Temperature   Temperature'
     WRITE(logline3,5006) '(m)           (Pa)       (Deg.C)        (Deg.C)'
     WRITE(logline4,5007) dash
5007 format(a60)
     call logprt_c(logline1)
     call logprt_c(logline2)
     call logprt_c(logline3)
     call logprt_c(logline4)
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
     call errprt_c(logline1)
     RETURN
  END IF
  IF(prtwel) then
     WRITE(logline1,5008) zwk,yy(1),yy(2),tambk
     call errprt_c(logline1)
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
  call errprt_c(logline1)
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
END SUBROUTINE welris
