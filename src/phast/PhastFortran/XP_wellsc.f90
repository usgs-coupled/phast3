SUBROUTINE XP_wellsc_thread(xp)
  ! ... Well Prodution/Injection Routine -- Calculates friction factors,
  ! ...      well conductance factors, modifies the right hand side flow,
  ! ...      installs specified well total flow rate
  ! ... Finite radius coupled version for cylindrical coordinates
  ! ... Used with the cylindrical coordinate system with central well
  !!$  USE machine_constants, ONLY: kdp
  USE f_units, ONLY: fuwel
  USE mcb, ONLY: fresur
  USE mcc, ONLY: eps, errexe, ierr, heat, rm_id
  USE mcc_m, ONLY: prtwel
  USE mcch, ONLY: dots, unittm
  USE mcg, ONLY: nx, ny, nz
  USE mcn, ONLY: x, z
  USE mcp, ONLY: fdtmth, vis0, den0, gz, p0, t0, cnvtmi
  USE mcv, ONLY: itime, frac, p, time
  USE mcw, ONLY: nwel, wqmeth, nkswel, mwel, wi, pwsurs, pwkts, wrisl, wrangl, &
    twk, twsrkt, twrend, tolfpw, ehwend, mxitqw, eod, tolqw, twsur, MIN_WELL_FLOW
  USE phys_const
  USE XP_module, ONLY: Transporter
  USE PhreeqcRM
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTRINSIC INT
  REAL(KIND=kdp) :: arwb, fpr3, frflm, frflp, lgren, ren, summob,  &
       szzw, uclm, uclp, ucwkt, udnkt, udnlm, udnlp, udnsur, uehwkt,  &
       ufdt2, uplm, uplp, upm, upwkt, upwsur, uqhw, uqsw, uqvsur,  &
       uqwm, uqwmi, uqwmr, uqwv, uqwvkt, utlm, utlp, utwkt, uvflm,  &
       uvflp, uvwlm, uvwlp, y1, yo
  INTEGER :: a_err, awqm, da_err, i, iis, itrn2, iwel, iwfss, j, k, ks, m,  &
       mkt, nks
  INTEGER :: nshut
  LOGICAL :: erflg, florev
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: mobw, r
  INTEGER, DIMENSION(:), ALLOCATABLE :: jwell
  INTEGER my_itime
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4, logline5, logline6
  INTEGER :: status
  !     ------------------------------------------------------------------
  !...
  my_itime = itime - 1          ! ... local time index
  erflg = .FALSE.
!!$ iis  =  xp%iis_no          ! ... Set index to selected component
  nshut = 0
  ufdt2 = fdtmth
  ALLOCATE (jwell(nwel), mobw(nwel*nz), r(nx),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: XP_wellsc"  
     STOP
  ENDIF
  r(1) = x(1)
  DO  iwel=1,nwel
     awqm = ABS(wqmeth(iwel))
     ! ... Uppermost completion cell
     nks = nkswel(iwel)
     mkt = mwel(iwel,nks)
555  CONTINUE
     ! ... Initialize flow rates for this time step
     DO  ks=1,nz
        xp%qwlyr(iwel,ks) = 0._kdp
        xp%qflyr(iwel,ks) = 0._kdp
        xp%qslyr(iwel,ks) = 0._kdp
        xp%dqwdpl(iwel,ks) = 0._kdp
     END DO
     ! ... Observation wells are skipped
     IF(awqm == 0) CYCLE
     arwb = pi*r(1)*r(1)
     fpr3 = 4.*pi*r(1)*r(1)*r(1)
     ! ... Calculate cell mobilities
     DO  ks=1,nks
        m = mwel(iwel,ks)
        CALL mtoijk(m,i,j,k,nx,ny)
        mobw(ks) = wi(iwel,ks)/vis0
        ! ... Adjust mobility for saturated thickness
        IF(fresur) mobw(ks) = mobw(ks)*frac(m)
        IF(my_itime == 0) THEN
           ! ... Initialize density, pressure, temperature, concentration profiles
           ! ...      in the wellbore
           !denwk(iwel,ks) = den0
           xp%pwk(iwel,ks) = p(m)
           xp%cwk(iwel,ks) = xp%c_w(m)
        END IF
     END DO
     upm = xp%pwk(iwel,nks)
     !udnkt = denwk(iwel,nks)
     udnkt = den0
     ! ... Start of one iteration loop
40   CONTINUE
     IF(awqm/10 == 1 .OR. awqm == 30) THEN
        ! ... Specified flow rate
        uqwvkt = -xp%qwv(iwel)
        ! ... UQWVKT>0 is production
        upwkt = xp%pwk(iwel,nks)
     ELSE IF(awqm == 50 .AND. my_itime > 0) THEN
        ! ... Specified flow rate at surface, pressure constraint
        !uqwvkt = -xp%qwm(iwel)/denwk(iwel,nks)
        uqwvkt = -xp%qwm(iwel)/den0
        upwsur = pwsurs(iwel)
     ELSE IF(awqm == 20) THEN
        ! ... Specified datum pressure
        upwkt = pwkts(iwel)
     ELSE IF(awqm == 40) THEN
        ! ... Specified surface pressure
        upwsur = pwsurs(iwel)
        udnsur = den0
        !dengl = denwk(iwel,nks)*gz*wrisl(iwel)*COS(wrangl(iwel))
        xp%dengl = den0*gz*wrisl(iwel)*COS(wrangl(iwel))
        ! ... Well datum pressure estimate
        IF(my_itime == 0) THEN
           upwkt = upwsur+xp%dengl
        ELSE
           upwkt = xp%pwkt(iwel)
        END IF
     END IF
     iwfss = INT(SIGN(1._kdp,uqwvkt))
     IF(ABS(uqwvkt) < MIN_WELL_FLOW) iwfss = 0
     IF(awqm == 20 .OR. awqm == 40) THEN
        IF(upwkt > upm) THEN
           iwfss = -1
        ELSE IF(upwkt < upm) THEN
           iwfss = 1
        END IF
     END IF
     IF(iwfss >= 0) THEN
        ! ... Production well
        utwkt = twk(iwel,nks)
        ucwkt = xp%cwk(iwel,nks)
     ELSE IF(iwfss < 0) THEN
        ! ... Injection well
        utwkt = twsrkt(iwel)
        ucwkt = xp%cwkt(iwel)
     END IF
     udnkt = den0
     ! ... Iteration loop start if necessary for well control parameters
     itrn2 = 1
60   CONTINUE
     IF(awqm/10 == 1 .OR. awqm == 30 .OR. awqm == 50) THEN
        ! ... Specified flow rate, WQMETH= 11 or 10 or 12 or 13
        summob = 0._kdp
        DO  ks=1,nks
           summob = summob+mobw(ks)
        END DO
        IF(awqm == 30) THEN
           ! ... Apply pressure limitation for well datum pressure
           IF(iwfss > 0) upwkt = MAX(upwkt,pwkts(iwel))
           IF(iwfss < 0) upwkt = MIN(upwkt,pwkts(iwel))
        END IF
     END IF
     IF(awqm == 50 .AND. iwfss < 0) THEN
        ! ... Injection well, specified surface flow rate, pressure constraint
        ! ...      Estimate PWSUR
        xp%pwrend = upwkt
        !upwsur = upwkt-denwk(iwel,nks)*gz*wrisl(iwel)*COS(wrangl(iwel))
        upwsur = upwkt-den0*gz*wrisl(iwel)*COS(wrangl(iwel))
801     upwsur = upwsur+upwkt-xp%pwrend
        udnsur = den0
        uqwmr = -xp%qwv(iwel)*udnsur
        xp%p00 = upwsur
        xp%t00 = xp%t0h
        CALL welris(iwel,iwfss,uqwmr)
        IF(prtwel) THEN
           WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet'
5011       FORMAT(2A)
           WRITE(logline2,5011) 'no.              rate        pressure ',  &
                '   temperature  pressure        temperature'
           WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)'
           WRITE(logline4,5021) dots
5021       FORMAT(a80)
           status = RM_LogMessage(rm_id, logline1)
           status = RM_LogMessage(rm_id, logline2)
           status = RM_LogMessage(rm_id, logline3)
           status = RM_LogMessage(rm_id, logline4)
           WRITE(fuwel,2001) 'well iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet',  &
                'no.              rate        pressure ',  &
                '   temperature  pressure        temperature',  &
                '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)', dots
2001       FORMAT(/tr5,2A/tr5,2A/tr5,2A/tr5,a80)
           WRITE(logline1,2032) iwel,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
2032       FORMAT(i5,i12,2(1PG14.6),0PF10.1,1PG14.6,0PF10.1)
           status = RM_LogMessage(rm_id, logline1)
           WRITE(fuwel,2002)  iwel,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
2002       FORMAT(i5,i12,2(1PG14.6),0PF10.1,1PG14.6,0PF10.1)
        END IF
        IF(ABS(upwkt-xp%pwrend) <= tolfpw*upwkt) THEN
           ! ... We have riser calculation convergence
           upwkt = xp%pwrend
           utwkt = twrend
           uehwkt = ehwend
           udnkt = den0
           uqwvkt = uqwmr/udnkt
        ELSE
           itrn2 = itrn2+1
           IF(itrn2 > mxitqw) GO TO 200
           GO TO 801
        END IF
        ! ... Test for surface pressure constraint
        IF(upwsur >= pwsurs(iwel)) THEN
           ! ... High pressure limited
           upwsur = pwsurs(iwel)
           awqm = 40
           GO TO 40
        END IF
     END IF
81   CONTINUE
     ! ... Allocate the flow
     IF(awqm == 20 .OR. awqm == 40) uqwv=0._kdp
     DO  ks=1,nks
        m = mwel(iwel,ks)
        IF(mobw(ks) > 0.) THEN
           IF(awqm == 11 .OR. iwfss < 0) THEN
              ! ... Allocate on mobility alone, always for injection
              xp%qwlyr(iwel,ks) = -uqwvkt*mobw(ks)/summob
           END IF
           ! ... Sum the volumetric flow rates for specified pressure conditions
           IF(awqm == 20 .OR. awqm == 40) uqwv = uqwv-xp%qwlyr(iwel,ks)
        END IF
     END DO
     IF(awqm == 20 .OR. awqm == 40) THEN
        iwfss = INT(SIGN(1._kdp,uqwv))
        IF(ABS(uqwv) < MIN_WELL_FLOW) iwfss = 0
        uqwvkt = uqwv
     END IF
     ! ... Sum mass and solute flow rates for the well
     ! ...      calculate mass fraction,
     ! ...      density profiles
     florev = .FALSE.
     IF(iwfss >= 0) THEN
        ! ... Production well
        uqwm = 0._kdp
        uqhw = 0._kdp
        uqsw = 0._kdp
        DO  ks=1,nks
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(xp%qwlyr(iwel,ks) < 0.) THEN
              ! ... Production layer
              xp%qflyr(iwel,ks) = den0*xp%qwlyr(iwel,ks)
              uqwm = uqwm-xp%qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = xp%qflyr(iwel,ks)*xp%c_w(m)
              uqsw = uqsw-xp%qslyr(iwel,ks)
              xp%cwk(iwel,ks) = uqsw/uqwm
           ELSE
              ! ... Injection layer from producing well (not allowed at layer Ks=1)
              !xp%qflyr(iwel,ks) = denwk(iwel,ks)*xp%qwlyr(iwel,ks)
              xp%qflyr(iwel,ks) = den0*xp%qwlyr(iwel,ks)
              uqwm = uqwm-xp%qflyr(iwel,ks)
              xp%cwk(iwel,ks) = xp%cwk(iwel,ks-1)
              xp%qslyr(iwel,ks) = xp%qflyr(iwel,ks)*xp%cwk(iwel,ks)
              uqsw = uqsw-xp%qslyr(iwel,ks)
           END IF
           !denwk(iwel,ks) = den0
           IF(uqwm < 0.) THEN
              WRITE(fuwel,9002) 'Production Well No. ',iwel,  &
                   ' has down bore flow from level ',k+1,' to ',  &
                   k,'; Time plane N =',my_itime,' Mass flow rate =', uqwm
9002          FORMAT(tr10,a,i4,a,i2,a,i2,a,i4/tr15,a,1PG10.2)
              florev = .TRUE.
           END IF
           IF(ks == nks) CYCLE
           IF(awqm /= 11) THEN
              ! ... Calculate wellbore velocity profile and friction factors
              uplp = p0
              utlp = t0
              uclp = 0.005_kdp
              udnlp = den0
              uvwlp = uqwm/(udnlp*arwb)
              ! ... Reynolds number for pipe flow
              ren = ABS(uvwlp)*2.*r(1)*udnlp/vis0
              IF(errexe) RETURN
              ! ... Calculate the friction factor for well bore (Vennard(1961),Chp.9)
              lgren = LOG10(ren)
              ! ... Laminar flow Re<2100
              IF(lgren <= 3.3) THEN
                 frflp = 64./ren
                 ! ... Transition flow
              ELSE IF(lgren <= 3.6) THEN
                 frflp = 10.**(260.67+lgren*(-228.62+ lgren*(66.307-6.3944*lgren)))
                 ! ... Turbulent flow (smooth to wholly rough)
                 ! ... EOD - roughness factor/pipe diameter
              ELSE IF(lgren <= 7.0) THEN
                 yo  =  2.0*LOG10(1./eod) + 1.14
                 y1 = yo - 2.0*LOG10(1. + 9.28*yo/(eod*ren))
320              IF(ABS((y1-yo)/y1) <= eps) GO TO 330
                 yo  =  y1
                 y1 = 1.14 - 2.0*LOG10(eod + 9.28*yo/ren)
                 GO TO 320
330              frflp  = 1./(y1*y1)
              ELSE
                 ! ... Turbulent flow, high Reynolds number (LGREN>7)(wholly rough)
                 ! ...      (Vennard eq.202)
                 frflp = 1./(1.14-2.0*LOG10(eod))**2
              END IF
              frflp = frflp*.25
              uvflp = uvwlp*frflp
              xp%tfw(k) = fpr3/(uvflp*(z(k+1)-z(k)))
           END IF
        END DO
        ! ... xp%tfw is zero for nodes within cased off intervals
        udnkt = den0
        utwkt = twk(iwel,nks)
        ucwkt = xp%cwk(iwel,nks)
     ELSE IF(iwfss < 0) THEN
        ! ... Injection well
        uqwm = udnkt*uqwvkt
        ! ... UWQM>0 is production
        uqwmi = uqwm
        uqhw = uqwm*uehwkt
        uqsw = uqwm*ucwkt
        DO  ks=nks,1,-1
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,nz)
           IF(xp%qwlyr(iwel,ks) > 0.) THEN
              ! ... Injection layer
              IF(ks == nks) THEN
                 xp%cwk(iwel,ks) = xp%cwkt(iwel)
              ELSE
                 xp%cwk(iwel,ks) = xp%cwk(iwel,ks+1)
              END IF
              !denwk(iwel,ks) = den0
              !xp%qflyr(iwel,ks) = denwk(iwel,ks)*xp%qwlyr(iwel,ks)
              xp%qflyr(iwel,ks) = den0*xp%qwlyr(iwel,ks)
              uqwm = uqwm+xp%qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = xp%qflyr(iwel,ks)*xp%cwk(iwel,ks)
              uqsw = uqsw+xp%qslyr(iwel,ks)
           ELSE
              ! ... Production layer into injection well
              xp%qflyr(iwel,ks) = den0*xp%qwlyr(iwel,ks)
              uqwm = uqwm+xp%qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = xp%qflyr(iwel,ks)*xp%c_w(m)
              uqsw = uqsw+xp%qslyr(iwel,ks)
              xp%cwk(iwel,ks) = uqsw/uqwm
           END IF
           !denwk(iwel,ks) = den0
           IF(ks > 1.AND.uqwm/ABS(uqwmi) > 0.01_kdp) THEN
              florev = .TRUE.
              WRITE(fuwel,9002) 'Injection Well No. ',iwel,  &
                   ' has up bore flow from level ',k-1,' to ',k,  &
                   '; Time plane N =',my_itime,' Mass flow rate =', uqwm
           END IF
           IF(ks == nks) CYCLE
           IF(awqm /= 11) THEN
              ! ... Calculate wellbore velocity profile and friction factors
              uplm = p0
              utlm = t0
              uclm = 0.005_kdp
              udnlm = den0
              uvwlm = uqwm/(udnlm*arwb)
              ! ... Reynolds number for pipe flow
              ren = ABS(uvwlm)*2.*r(1)*udnlm/vis0
              IF(errexe) RETURN
              ! ... Calculate the friction factor for well bore (Vennard(1961),chp.9)
              lgren = LOG10(ren)
              ! ... Laminar flow Re<2100
              IF(lgren <= 3.3) THEN
                 frflm = 64./ren
                 ! ... Transition flow
              ELSE IF(lgren <= 3.6) THEN
                 frflm = 10.**(260.67+lgren*(-228.62+lgren* (66.307-6.3944*lgren)))
                 ! ... Turbulent flow (smooth to wholly rough)
              ELSE IF(lgren <= 7.0) THEN
                 yo  =  2.0*LOG10(1./eod) + 1.14
                 y1 = yo - 2.0*LOG10(1. + 9.28*yo/(eod*ren))
420              IF(ABS((y1-yo)/y1) <= eps) GO TO 430
                 yo  =  y1
                 y1 = 1.14 - 2.0*LOG10(eod + 9.28*yo/ren)
                 GO TO 420
430              frflm  = 1./(y1*y1)
              ELSE
                 ! ... Turbulent flow, high reynolds number (LGREN>7)(wholly rough)
                 ! ...        (Vennard, eq.202)
                 frflm = 1./(1.14-2.0*LOG10(eod))**2
              END IF
              frflm = frflm*.25
              uvflm = uvwlm*frflm
              xp%tfw(k-1) = fpr3/(uvflm*(z(k)-z(k-1)))
           END IF
        END DO
        IF(ABS(uqwm/uqwmi) > 0.01_kdp) THEN
           ! ... Well has excess residual flow rate
           florev = .TRUE.
           WRITE(fuwel,9003) 'Injection Well No. ',iwel,  &
                ' has excess residual flow  ',  &
                '; Time plane N =',my_itime,' Mass flow rate =', uqwm
9003       FORMAT(tr10,a,i4,a,a,i4/tr15,a,1PG10.2)
        END IF
     END IF
     IF(florev) THEN
        WRITE(fuwel,9004) 'Well density, enthalpy, and solute concentration ',  &
             'may be poor approximations (WELLSC)'
9004    FORMAT(tr10,2A)
        ierr(142) = .TRUE.
     END IF
     IF(awqm == 10 .OR. awqm >= 20) THEN
        IF(iwfss > 0 .AND. uqwm < 0.) THEN
           ! ... Net reverse well flow. Shut well in.
           nshut = nshut+1
           jwell(nshut) = iwel
           DO  ks=1,nks
              m = mwel(iwel,ks)
              CALL mtoijk(m,i,j,k,nx,ny)
              xp%qwlyr(iwel,ks) = 0._kdp
              xp%qflyr(iwel,ks) = 0._kdp
              xp%dqwdpl(iwel,ks) = 0._kdp
              uqwm = 0._kdp
              uqhw = 0._kdp
              xp%qslyr(iwel,ks) = 0._kdp
              uqsw = 0._kdp
           END DO
           GO TO 151
        END IF
        IF(awqm == 50 .AND. iwfss >= 0) THEN
           ! ... Production well, specified surface flow rate, pressure constraint
           uqwmr = uqwm
           xp%p00 = upwkt
           CALL welris(iwel,iwfss,uqwmr)
           IF(prtwel) THEN
              WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                   '   riser inlet   riser outlet riser outlet'
              WRITE(logline2,5011) 'no.              rate        pressure ',  &
                   '   temperature  pressure        temperature'
              WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                   '   (Deg.C)    (Pa)             (Deg.C)'
              WRITE(logline4,5021) dots
              status = RM_LogMessage(rm_id, logline1)
              status = RM_LogMessage(rm_id, logline2)
              status = RM_LogMessage(rm_id, logline3)
              status = RM_LogMessage(rm_id, logline4)
              WRITE(fuwel,2001) 'well  iteration mass flow  riser inlet ',  &
                   '   riser inlet   riser outlet riser outlet',  &
                   'no.               rate        pressure ',  &
                   '   temperature  pressure        temperature',  &
                   '                        (kg/s)        (Pa)    ',  &
                   '    (Deg.C)    (Pa)             (Deg.C)', dots
              WRITE(logline1,2032) iwel,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
              status = RM_LogMessage(rm_id, logline1)
              WRITE(fuwel,2002) iwel,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
           END IF
           IF(xp%pwrend <= pwsurs(iwel)) THEN
              ! ... Low pressure limited
              upwsur = pwsurs(iwel)
              awqm = 40
              GO TO 40
           END IF
           udnsur = den0
           uqvsur = -uqwmr/udnsur
           IF(ABS(uqvsur-xp%qwv(iwel)) > tolqw*xp%qwv(iwel)) THEN
              uqvsur = .5*(uqvsur+xp%qwv(iwel))
              itrn2 = itrn2+1
              IF(itrn2 > mxitqw) GO TO 200
              GO TO 60
           END IF
        END IF
        IF(awqm == 40) THEN
           ! ... Specified surface pressure
           iwfss = INT(SIGN(1._kdp,uqwm))
           IF(ABS(uqwm) < MIN_WELL_FLOW) iwfss = 0
           uqwmr = uqwm
           IF(iwfss >= 0) THEN
              ! ... Production well
              xp%p00 = upwkt
              xp%t00 = utwkt
              CALL welris(iwel,iwfss,uqwmr)
              IF(prtwel) THEN
                 WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                      '   riser inlet   riser outlet riser outlet'
                 WRITE(logline2,5011) 'no.              rate        pressure ',  &
                      '   temperature  pressure        temperature'
                 WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                      '   (Deg.C)    (Pa)             (Deg.C)'
                 WRITE(logline4,5021) dots
                 status = RM_LogMessage(rm_id, logline1)
                 status = RM_LogMessage(rm_id, logline2)
                 status = RM_LogMessage(rm_id, logline3)
                 status = RM_LogMessage(rm_id, logline4)
                 WRITE(fuwel,2001) 'well  iteration mass flow  riser inlet ',  &
                      '   riser inlet   riser outlet riser outlet',  &
                      'no.               rate        pressure ',  &
                      '   temperature  pressure        temperature',  &
                      '                    (kg/s)        (Pa)     ',  &
                      '    (Deg.C)    (Pa)             (Deg.C)', dots
                 WRITE(logline1,2032) iwel,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
                 status = RM_LogMessage(rm_id, logline1)
                 WRITE(fuwel,2002) iwel,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
              END IF
              IF(ABS(xp%pwrend-pwsurs(iwel)) > tolfpw*pwsurs(iwel)) THEN
                 upwkt = upwkt+xp%pwrend-pwsurs(iwel)
                 itrn2 = itrn2+1
                 IF(itrn2 > mxitqw) GO TO 200
                 GO TO 81
              END IF
           ELSE IF(iwfss < 0) THEN
              ! ... Injection well
              xp%p00 = pwsurs(iwel)
              xp%t00 = xp%t0h
              IF(heat) xp%t00 = twsur(iwel)
              CALL welris(iwel,iwfss,uqwmr)
              IF(prtwel) THEN
                 WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                      '   riser inlet   riser outlet riser outlet'
                 WRITE(logline2,5011) 'no.              rate        pressure ',  &
                      '   temperature  pressure        temperature'
                 WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                      '   (Deg.C)    (Pa)             (Deg.C)'
                 WRITE(logline4,5021) dots
                 status = RM_LogMessage(rm_id, logline1)
                 status = RM_LogMessage(rm_id, logline2)
                 status = RM_LogMessage(rm_id, logline3)
                 status = RM_LogMessage(rm_id, logline4)
                 WRITE(fuwel,2001) 'well  iteration mass flow  riser inlet ',  &
                      '   riser inlet   riser outlet riser outlet',  &
                      'no.               rate        pressure ',  &
                      '   temperature  pressure        temperature',  &
                      '                    (kg/s)        (Pa)     ',  &
                      '    (Deg.C)    (Pa)             (Deg.C)', dots

                 WRITE(logline1,2032) iwel,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
                 status = RM_LogMessage(rm_id, logline1)
                 WRITE(fuwel,2002)  iwel,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
              END IF
              IF(ABS(xp%pwrend-upwkt) > tolfpw*upwkt) THEN
                 upwkt = xp%pwrend
                 utwkt = twrend
                 itrn2 = itrn2+1
                 IF(itrn2 > mxitqw) GO TO 200
                 GO TO 81
              END IF
              upwkt = xp%pwrend
              utwkt = twrend
              uehwkt = ehwend
           END IF
        END IF
     END IF
     ! ... Calculate fluid mass flow rate, store mass fraction
151  xp%qwm(iwel) = 0._kdp
     DO  ks=1,nks
        xp%qwm(iwel) = xp%qwm(iwel)+xp%qflyr(iwel,ks)
     END DO
     xp%pwkt(iwel) = upwkt
     xp%cwkt(iwel) = ucwkt
     xp%cwk(iwel,nks) = ucwkt
     ! ... Test for production concentration greater than specified limit
     IF((awqm == 12 .OR. awqm == 13) .AND. iwfss > 0) THEN
        IF(xp%cwkt(iwel) > 0.8*xp%cwkts(iwel)) THEN
           !..              priwel = 1.
           xp%cwatch = .TRUE.
        END IF
        IF(xp%cwkt(iwel) > xp%cwkts(iwel)) THEN
           xp%qwv(iwel) = 0._kdp
           nshut = nshut+1
           jwell(nshut) = iwel
           !$$                 priwel = my_itime+1
           xp%cwatch = .FALSE.
           GO TO 555
        END IF
     END IF
     ! ... Load rhs with well explicit flow rates at each layer
!!$     DO  ks=1,nks-1
!!$        m = mwel(iwel,ks)
!!$        CALL mtoijk(m,i,j,k,nx,ny)
!!$        IF(awqm == 11 .OR. awqm == 13) THEN
!!$           rf(m) = rf(m)+ufdt2*xp%qflyr(iwel,ks)
!!$        ELSE
!!$           mijkp = m+nxy
!!$           szzw = -xp%tfw(k)*(p(mijkp)-p(m)+denwk(iwel,ks)*gz*(z(k+1)-z(k)))
!!$           rf(mijkp) = rf(mijkp)+szzw
!!$           rf(m) = rf(m)-szzw
!!$        END IF
!!$     END DO
!!$     mkt = mwel(iwel,nks)
!!$     IF(awqm == 11 .OR. awqm == 13) THEN
!!$        rf(mkt) = rf(mkt)+ufdt2*xp%qflyr(iwel,nks)
!!$     ELSE IF(awqm <= 20 .OR. awqm == 40) THEN
!!$        rf(mkt) = rf(mkt)-ufdt2*xp%qwm(iwel)
!!$     END IF
     CYCLE
200  CONTINUE
     WRITE(fuwel,9005) 'Well No. ',iwel,' did not converge on riser',  &
          'calculation for WELLSC, ITIME =',my_itime
9005 FORMAT(tr10,a,i3,2A,i5)
     WRITE(logline1,9015) 'Well No. ',iwel,' did not converge on riser',  &
          'calculation for WELLSC, ITIME =',my_itime
9015 FORMAT(a,i3,2A,i5)
     status = RM_ErrorMessage(rm_id, logline1)
     errexe = .TRUE.
  END DO
  ! ... End of well loop
  IF(nshut > 0) THEN
     WRITE(fuwel,9016) 'Time =',cnvtmi*time,'('//unittm//')',  &
          'The following wells were shut in due to net flow ',  &
          'reversal or due to reservoir pressure too',  &
          'low (high) relative to bore hole pressure for prodution (injection)',  &
          'or production concentration limit reached',  &
          (jwell(i),i=1,nshut)
9016 FORMAT(//tr20,a,1PG10.4,2X,A/tr10,a/tr25,a  &
          /tr25,a  &
          /tr25,a  &
          /(tr30,25I4))
     WRITE(logline1,8016) 'Time  = ',cnvtmi*time,'  ('//unittm//')'
8016 FORMAT(a,1pg10.4,a)
     WRITE(logline2,8017) 'The following wells were shut in due to net flow '
8017 FORMAT(a)
     WRITE(logline3,8017) '          reversal or due to reservoir pressure too' 
     WRITE(logline4,8017) '          low (high) relative to bore hole pressure '//  &
          'for prodution (injection)'
     WRITE(logline5,8017) '          or production concentration limit reached'
     WRITE(logline6,8018) (jwell(i),i=1,nshut)
8018 FORMAT(25i4)
!!$     status = RM_WarningMessage(rm_id, logline1)
!!$     status = RM_WarningMessage(rm_id, logline2)
!!$     status = RM_WarningMessage(rm_id, logline3)
!!$     status = RM_WarningMessage(rm_id, logline4)
!!$     status = RM_WarningMessage(rm_id, logline5)
!!$     status = RM_WarningMessage(rm_id, logline6)
  END IF
  DEALLOCATE (jwell, mobw, r,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, XP_wellsc"  
     STOP  
  ENDIF
END SUBROUTINE XP_wellsc_thread
SUBROUTINE XP_wellsc(xp)
  ! ... Well Prodution/Injection Routine -- Calculates friction factors,
  ! ...      well conductance factors, modifies the right hand side flow,
  ! ...      installs specified well total flow rate
  ! ... Finite radius coupled version for cylindrical coordinates
  ! ... Used with the cylindrical coordinate system with central well
  !!$  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcc
  USE mcc_m, ONLY: prtwel
  USE mcch
  USE mcg
  USE mcn
  USE mcp
  USE mcv
  USE mcw
  USE phys_const
  USE XP_module, ONLY: Transporter
  USE PhreeqcRM
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTRINSIC INT
  REAL(KIND=kdp) :: arwb, fpr3, frflm, frflp, lgren, ren, summob,  &
       szzw, uclm, uclp, ucwkt, udnkt, udnlm, udnlp, udnsur, uehwkt,  &
       ufdt2, uplm, uplp, upm, upwkt, upwsur, uqhw, uqsw, uqvsur,  &
       uqwm, uqwmi, uqwmr, uqwv, uqwvkt, utlm, utlp, utwkt, uvflm,  &
       uvflp, uvwlm, uvwlp, y1, yo
  INTEGER :: a_err, awqm, da_err, i, iis, itrn2, iwel, iwfss, j, k, ks, m,  &
       mkt, nks
  LOGICAL :: erflg, florev
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: mobw, r
  INTEGER, DIMENSION(:), ALLOCATABLE :: jwell
  INTEGER my_itime
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4, logline5, logline6
  INTEGER :: status
  !     ------------------------------------------------------------------
  !...
  my_itime = itime - 1          ! ... local time index
  erflg = .FALSE.
!!$ iis  =  xp%iis_no          ! ... Set index to selected component
  nshut = 0
  ufdt2 = fdtmth
  ALLOCATE (jwell(nwel), mobw(nwel*nz), r(nx),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: XP_wellsc"  
     STOP
  ENDIF
  r(1) = x(1)
  DO  iwel=1,nwel
     awqm = ABS(wqmeth(iwel))
     ! ... Uppermost completion cell
     nks = nkswel(iwel)
     mkt = mwel(iwel,nks)
555  CONTINUE
     ! ... Initialize flow rates for this time step
     DO  ks=1,nz
        qwlyr(iwel,ks) = 0._kdp
        qflyr(iwel,ks) = 0._kdp
        xp%qslyr(iwel,ks) = 0._kdp
        dqwdpl(iwel,ks) = 0._kdp
     END DO
     ! ... Observation wells are skipped
     IF(awqm == 0) CYCLE
     arwb = pi*r(1)*r(1)
     fpr3 = 4.*pi*r(1)*r(1)*r(1)
     ! ... Calculate cell mobilities
     DO  ks=1,nks
        m = mwel(iwel,ks)
        CALL mtoijk(m,i,j,k,nx,ny)
        mobw(ks) = wi(iwel,ks)/vis0
        ! ... Adjust mobility for saturated thickness
        IF(fresur) mobw(ks) = mobw(ks)*frac(m)
        IF(my_itime == 0) THEN
           ! ... Initialize density, pressure, temperature, concentration profiles
           ! ...      in the wellbore
           denwk(iwel,ks) = den0
           pwk(iwel,ks) = p(m)
           xp%cwk(iwel,ks) = xp%c_w(m)
        END IF
     END DO
     upm = pwk(iwel,nks)
     udnkt = denwk(iwel,nks)
     ! ... Start of one iteration loop
40   CONTINUE
     IF(awqm/10 == 1 .OR. awqm == 30) THEN
        ! ... Specified flow rate
        uqwvkt = -qwv(iwel)
        ! ... UQWVKT>0 is production
        upwkt = pwk(iwel,nks)
     ELSE IF(awqm == 50 .AND. my_itime > 0) THEN
        ! ... Specified flow rate at surface, pressure constraint
        uqwvkt = -qwm(iwel)/denwk(iwel,nks)
        upwsur = pwsurs(iwel)
     ELSE IF(awqm == 20) THEN
        ! ... Specified datum pressure
        upwkt = pwkts(iwel)
     ELSE IF(awqm == 40) THEN
        ! ... Specified surface pressure
        upwsur = pwsurs(iwel)
        udnsur = den0
        dengl = denwk(iwel,nks)*gz*wrisl(iwel)*COS(wrangl(iwel))
        ! ... Well datum pressure estimate
        IF(my_itime == 0) THEN
           upwkt = upwsur+dengl
        ELSE
           upwkt = pwkt(iwel)
        END IF
     END IF
     iwfss = INT(SIGN(1._kdp,uqwvkt))
     IF(ABS(uqwvkt) < MIN_WELL_FLOW) iwfss = 0
     IF(awqm == 20 .OR. awqm == 40) THEN
        IF(upwkt > upm) THEN
           iwfss = -1
        ELSE IF(upwkt < upm) THEN
           iwfss = 1
        END IF
     END IF
     IF(iwfss >= 0) THEN
        ! ... Production well
        utwkt = twk(iwel,nks)
        ucwkt = xp%cwk(iwel,nks)
     ELSE IF(iwfss < 0) THEN
        ! ... Injection well
        utwkt = twsrkt(iwel)
        ucwkt = xp%cwkt(iwel)
     END IF
     udnkt = den0
     ! ... Iteration loop start if necessary for well control parameters
     itrn2 = 1
60   CONTINUE
     IF(awqm/10 == 1 .OR. awqm == 30 .OR. awqm == 50) THEN
        ! ... Specified flow rate, WQMETH= 11 or 10 or 12 or 13
        summob = 0._kdp
        DO  ks=1,nks
           summob = summob+mobw(ks)
        END DO
        IF(awqm == 30) THEN
           ! ... Apply pressure limitation for well datum pressure
           IF(iwfss > 0) upwkt = MAX(upwkt,pwkts(iwel))
           IF(iwfss < 0) upwkt = MIN(upwkt,pwkts(iwel))
        END IF
     END IF
     IF(awqm == 50 .AND. iwfss < 0) THEN
        ! ... Injection well, specified surface flow rate, pressure constraint
        ! ...      Estimate PWSUR
        pwrend = upwkt
        upwsur = upwkt-denwk(iwel,nks)*gz*wrisl(iwel)*COS(wrangl(iwel))
801     upwsur = upwsur+upwkt-pwrend
        udnsur = den0
        uqwmr = -qwv(iwel)*udnsur
        p00 = upwsur
        t00 = t0h
        CALL welris(iwel,iwfss,uqwmr)
        IF(prtwel) THEN
           WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet'
5011       FORMAT(2A)
           WRITE(logline2,5011) 'no.              rate        pressure ',  &
                '   temperature  pressure        temperature'
           WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)'
           WRITE(logline4,5021) dots
5021       FORMAT(a80)
           status = RM_LogMessage(rm_id, logline1)
           status = RM_LogMessage(rm_id, logline2)
           status = RM_LogMessage(rm_id, logline3)
           status = RM_LogMessage(rm_id, logline4)
           WRITE(fuwel,2001) 'well iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet',  &
                'no.              rate        pressure ',  &
                '   temperature  pressure        temperature',  &
                '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)', dots
2001       FORMAT(/tr5,2A/tr5,2A/tr5,2A/tr5,a80)
           WRITE(logline1,2032) iwel,itrn2,uqwmr,p00,t00,pwrend,twrend
2032       FORMAT(i5,i12,2(1PG14.6),0PF10.1,1PG14.6,0PF10.1)
           status = RM_LogMessage(rm_id, logline1)
           WRITE(fuwel,2002)  iwel,itrn2,uqwmr,p00,t00,pwrend,twrend
2002       FORMAT(i5,i12,2(1PG14.6),0PF10.1,1PG14.6,0PF10.1)
        END IF
        IF(ABS(upwkt-pwrend) <= tolfpw*upwkt) THEN
           ! ... We have riser calculation convergence
           upwkt = pwrend
           utwkt = twrend
           uehwkt = ehwend
           udnkt = den0
           uqwvkt = uqwmr/udnkt
        ELSE
           itrn2 = itrn2+1
           IF(itrn2 > mxitqw) GO TO 200
           GO TO 801
        END IF
        ! ... Test for surface pressure constraint
        IF(upwsur >= pwsurs(iwel)) THEN
           ! ... High pressure limited
           upwsur = pwsurs(iwel)
           awqm = 40
           GO TO 40
        END IF
     END IF
81   CONTINUE
     ! ... Allocate the flow
     IF(awqm == 20 .OR. awqm == 40) uqwv=0._kdp
     DO  ks=1,nks
        m = mwel(iwel,ks)
        IF(mobw(ks) > 0.) THEN
           IF(awqm == 11 .OR. iwfss < 0) THEN
              ! ... Allocate on mobility alone, always for injection
              qwlyr(iwel,ks) = -uqwvkt*mobw(ks)/summob
           END IF
           ! ... Sum the volumetric flow rates for specified pressure conditions
           IF(awqm == 20 .OR. awqm == 40) uqwv = uqwv-qwlyr(iwel,ks)
        END IF
     END DO
     IF(awqm == 20 .OR. awqm == 40) THEN
        iwfss = INT(SIGN(1._kdp,uqwv))
        IF(ABS(uqwv) < MIN_WELL_FLOW) iwfss = 0
        uqwvkt = uqwv
     END IF
     ! ... Sum mass and solute flow rates for the well
     ! ...      calculate mass fraction,
     ! ...      density profiles
     florev = .FALSE.
     IF(iwfss >= 0) THEN
        ! ... Production well
        uqwm = 0._kdp
        uqhw = 0._kdp
        uqsw = 0._kdp
        DO  ks=1,nks
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(qwlyr(iwel,ks) < 0.) THEN
              ! ... Production layer
              qflyr(iwel,ks) = den0*qwlyr(iwel,ks)
              uqwm = uqwm-qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = qflyr(iwel,ks)*xp%c_w(m)
              uqsw = uqsw-xp%qslyr(iwel,ks)
              xp%cwk(iwel,ks) = uqsw/uqwm
           ELSE
              ! ... Injection layer from producing well (not allowed at layer Ks=1)
              qflyr(iwel,ks) = denwk(iwel,ks)*qwlyr(iwel,ks)
              uqwm = uqwm-qflyr(iwel,ks)
              xp%cwk(iwel,ks) = xp%cwk(iwel,ks-1)
              xp%qslyr(iwel,ks) = qflyr(iwel,ks)*xp%cwk(iwel,ks)
              uqsw = uqsw-xp%qslyr(iwel,ks)
           END IF
           denwk(iwel,ks) = den0
           IF(uqwm < 0.) THEN
              WRITE(fuwel,9002) 'Production Well No. ',iwel,  &
                   ' has down bore flow from level ',k+1,' to ',  &
                   k,'; Time plane N =',my_itime,' Mass flow rate =', uqwm
9002          FORMAT(tr10,a,i4,a,i2,a,i2,a,i4/tr15,a,1PG10.2)
              florev = .TRUE.
           END IF
           IF(ks == nks) CYCLE
           IF(awqm /= 11) THEN
              ! ... Calculate wellbore velocity profile and friction factors
              uplp = p0
              utlp = t0
              uclp = 0.005_kdp
              udnlp = den0
              uvwlp = uqwm/(udnlp*arwb)
              ! ... Reynolds number for pipe flow
              ren = ABS(uvwlp)*2.*r(1)*udnlp/vis0
              IF(errexe) RETURN
              ! ... Calculate the friction factor for well bore (Vennard(1961),Chp.9)
              lgren = LOG10(ren)
              ! ... Laminar flow Re<2100
              IF(lgren <= 3.3) THEN
                 frflp = 64./ren
                 ! ... Transition flow
              ELSE IF(lgren <= 3.6) THEN
                 frflp = 10.**(260.67+lgren*(-228.62+ lgren*(66.307-6.3944*lgren)))
                 ! ... Turbulent flow (smooth to wholly rough)
                 ! ... EOD - roughness factor/pipe diameter
              ELSE IF(lgren <= 7.0) THEN
                 yo  =  2.0*LOG10(1./eod) + 1.14
                 y1 = yo - 2.0*LOG10(1. + 9.28*yo/(eod*ren))
320              IF(ABS((y1-yo)/y1) <= eps) GO TO 330
                 yo  =  y1
                 y1 = 1.14 - 2.0*LOG10(eod + 9.28*yo/ren)
                 GO TO 320
330              frflp  = 1./(y1*y1)
              ELSE
                 ! ... Turbulent flow, high Reynolds number (LGREN>7)(wholly rough)
                 ! ...      (Vennard eq.202)
                 frflp = 1./(1.14-2.0*LOG10(eod))**2
              END IF
              frflp = frflp*.25
              uvflp = uvwlp*frflp
              tfw(k) = fpr3/(uvflp*(z(k+1)-z(k)))
           END IF
        END DO
        ! ... TFW is zero for nodes within cased off intervals
        udnkt = den0
        utwkt = twk(iwel,nks)
        ucwkt = xp%cwk(iwel,nks)
     ELSE IF(iwfss < 0) THEN
        ! ... Injection well
        uqwm = udnkt*uqwvkt
        ! ... UWQM>0 is production
        uqwmi = uqwm
        uqhw = uqwm*uehwkt
        uqsw = uqwm*ucwkt
        DO  ks=nks,1,-1
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,nz)
           IF(qwlyr(iwel,ks) > 0.) THEN
              ! ... Injection layer
              IF(ks == nks) THEN
                 xp%cwk(iwel,ks) = xp%cwkt(iwel)
              ELSE
                 xp%cwk(iwel,ks) = xp%cwk(iwel,ks+1)
              END IF
              denwk(iwel,ks) = den0
              qflyr(iwel,ks) = denwk(iwel,ks)*qwlyr(iwel,ks)
              uqwm = uqwm+qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = qflyr(iwel,ks)*xp%cwk(iwel,ks)
              uqsw = uqsw+xp%qslyr(iwel,ks)
           ELSE
              ! ... Production layer into injection well
              qflyr(iwel,ks) = den0*qwlyr(iwel,ks)
              uqwm = uqwm+qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = qflyr(iwel,ks)*xp%c_w(m)
              uqsw = uqsw+xp%qslyr(iwel,ks)
              xp%cwk(iwel,ks) = uqsw/uqwm
           END IF
           denwk(iwel,ks) = den0
           IF(ks > 1.AND.uqwm/ABS(uqwmi) > 0.01_kdp) THEN
              florev = .TRUE.
              WRITE(fuwel,9002) 'Injection Well No. ',iwel,  &
                   ' has up bore flow from level ',k-1,' to ',k,  &
                   '; Time plane N =',my_itime,' Mass flow rate =', uqwm
           END IF
           IF(ks == nks) CYCLE
           IF(awqm /= 11) THEN
              ! ... Calculate wellbore velocity profile and friction factors
              uplm = p0
              utlm = t0
              uclm = 0.005_kdp
              udnlm = den0
              uvwlm = uqwm/(udnlm*arwb)
              ! ... Reynolds number for pipe flow
              ren = ABS(uvwlm)*2.*r(1)*udnlm/vis0
              IF(errexe) RETURN
              ! ... Calculate the friction factor for well bore (Vennard(1961),chp.9)
              lgren = LOG10(ren)
              ! ... Laminar flow Re<2100
              IF(lgren <= 3.3) THEN
                 frflm = 64./ren
                 ! ... Transition flow
              ELSE IF(lgren <= 3.6) THEN
                 frflm = 10.**(260.67+lgren*(-228.62+lgren* (66.307-6.3944*lgren)))
                 ! ... Turbulent flow (smooth to wholly rough)
              ELSE IF(lgren <= 7.0) THEN
                 yo  =  2.0*LOG10(1./eod) + 1.14
                 y1 = yo - 2.0*LOG10(1. + 9.28*yo/(eod*ren))
420              IF(ABS((y1-yo)/y1) <= eps) GO TO 430
                 yo  =  y1
                 y1 = 1.14 - 2.0*LOG10(eod + 9.28*yo/ren)
                 GO TO 420
430              frflm  = 1./(y1*y1)
              ELSE
                 ! ... Turbulent flow, high reynolds number (LGREN>7)(wholly rough)
                 ! ...        (Vennard, eq.202)
                 frflm = 1./(1.14-2.0*LOG10(eod))**2
              END IF
              frflm = frflm*.25
              uvflm = uvwlm*frflm
              tfw(k-1) = fpr3/(uvflm*(z(k)-z(k-1)))
           END IF
        END DO
        IF(ABS(uqwm/uqwmi) > 0.01_kdp) THEN
           ! ... Well has excess residual flow rate
           florev = .TRUE.
           WRITE(fuwel,9003) 'Injection Well No. ',iwel,  &
                ' has excess residual flow  ',  &
                '; Time plane N =',my_itime,' Mass flow rate =', uqwm
9003       FORMAT(tr10,a,i4,a,a,i4/tr15,a,1PG10.2)
        END IF
     END IF
     IF(florev) THEN
        WRITE(fuwel,9004) 'Well density, enthalpy, and solute concentration ',  &
             'may be poor approximations (WELLSC)'
9004    FORMAT(tr10,2A)
        ierr(142) = .TRUE.
     END IF
     IF(awqm == 10 .OR. awqm >= 20) THEN
        IF(iwfss > 0 .AND. uqwm < 0.) THEN
           ! ... Net reverse well flow. Shut well in.
           nshut = nshut+1
           jwell(nshut) = iwel
           DO  ks=1,nks
              m = mwel(iwel,ks)
              CALL mtoijk(m,i,j,k,nx,ny)
              qwlyr(iwel,ks) = 0._kdp
              qflyr(iwel,ks) = 0._kdp
              dqwdpl(iwel,ks) = 0._kdp
              uqwm = 0._kdp
              uqhw = 0._kdp
              xp%qslyr(iwel,ks) = 0._kdp
              uqsw = 0._kdp
           END DO
           GO TO 151
        END IF
        IF(awqm == 50 .AND. iwfss >= 0) THEN
           ! ... Production well, specified surface flow rate, pressure constraint
           uqwmr = uqwm
           p00 = upwkt
           CALL welris(iwel,iwfss,uqwmr)
           IF(prtwel) THEN
              WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                   '   riser inlet   riser outlet riser outlet'
              WRITE(logline2,5011) 'no.              rate        pressure ',  &
                   '   temperature  pressure        temperature'
              WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                   '   (Deg.C)    (Pa)             (Deg.C)'
              WRITE(logline4,5021) dots
              status = RM_LogMessage(rm_id, logline1)
              status = RM_LogMessage(rm_id, logline2)
              status = RM_LogMessage(rm_id, logline3)
              status = RM_LogMessage(rm_id, logline4)
              WRITE(fuwel,2001) 'well  iteration mass flow  riser inlet ',  &
                   '   riser inlet   riser outlet riser outlet',  &
                   'no.               rate        pressure ',  &
                   '   temperature  pressure        temperature',  &
                   '                        (kg/s)        (Pa)    ',  &
                   '    (Deg.C)    (Pa)             (Deg.C)', dots
              WRITE(logline1,2032) iwel,itrn2,uqwmr,p00,t00,pwrend,twrend
              status = RM_LogMessage(rm_id, logline1)
              WRITE(fuwel,2002) iwel,itrn2,uqwmr,p00,t00,pwrend,twrend
           END IF
           IF(pwrend <= pwsurs(iwel)) THEN
              ! ... Low pressure limited
              upwsur = pwsurs(iwel)
              awqm = 40
              GO TO 40
           END IF
           udnsur = den0
           uqvsur = -uqwmr/udnsur
           IF(ABS(uqvsur-qwv(iwel)) > tolqw*qwv(iwel)) THEN
              uqvsur = .5*(uqvsur+qwv(iwel))
              itrn2 = itrn2+1
              IF(itrn2 > mxitqw) GO TO 200
              GO TO 60
           END IF
        END IF
        IF(awqm == 40) THEN
           ! ... Specified surface pressure
           iwfss = INT(SIGN(1._kdp,uqwm))
           IF(ABS(uqwm) < MIN_WELL_FLOW) iwfss = 0
           uqwmr = uqwm
           IF(iwfss >= 0) THEN
              ! ... Production well
              p00 = upwkt
              t00 = utwkt
              CALL welris(iwel,iwfss,uqwmr)
              IF(prtwel) THEN
                 WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                      '   riser inlet   riser outlet riser outlet'
                 WRITE(logline2,5011) 'no.              rate        pressure ',  &
                      '   temperature  pressure        temperature'
                 WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                      '   (Deg.C)    (Pa)             (Deg.C)'
                 WRITE(logline4,5021) dots
                 status = RM_LogMessage(rm_id, logline1)
                 status = RM_LogMessage(rm_id, logline2)
                 status = RM_LogMessage(rm_id, logline3)
                 status = RM_LogMessage(rm_id, logline4)
                 WRITE(fuwel,2001) 'well  iteration mass flow  riser inlet ',  &
                      '   riser inlet   riser outlet riser outlet',  &
                      'no.               rate        pressure ',  &
                      '   temperature  pressure        temperature',  &
                      '                    (kg/s)        (Pa)     ',  &
                      '    (Deg.C)    (Pa)             (Deg.C)', dots
                 WRITE(logline1,2032) iwel,itrn2,uqwmr,p00,t00,pwrend,twrend
                 status = RM_LogMessage(rm_id, logline1)
                 WRITE(fuwel,2002) iwel,itrn2,uqwmr,p00,t00,pwrend,twrend
              END IF
              IF(ABS(pwrend-pwsurs(iwel)) > tolfpw*pwsurs(iwel)) THEN
                 upwkt = upwkt+pwrend-pwsurs(iwel)
                 itrn2 = itrn2+1
                 IF(itrn2 > mxitqw) GO TO 200
                 GO TO 81
              END IF
           ELSE IF(iwfss < 0) THEN
              ! ... Injection well
              p00 = pwsurs(iwel)
              t00 = t0h
              IF(heat) t00 = twsur(iwel)
              CALL welris(iwel,iwfss,uqwmr)
              IF(prtwel) THEN
                 WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                      '   riser inlet   riser outlet riser outlet'
                 WRITE(logline2,5011) 'no.              rate        pressure ',  &
                      '   temperature  pressure        temperature'
                 WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                      '   (Deg.C)    (Pa)             (Deg.C)'
                 WRITE(logline4,5021) dots
                 status = RM_LogMessage(rm_id, logline1)
                 status = RM_LogMessage(rm_id, logline2)
                 status = RM_LogMessage(rm_id, logline3)
                 status = RM_LogMessage(rm_id, logline4)
                 WRITE(fuwel,2001) 'well  iteration mass flow  riser inlet ',  &
                      '   riser inlet   riser outlet riser outlet',  &
                      'no.               rate        pressure ',  &
                      '   temperature  pressure        temperature',  &
                      '                    (kg/s)        (Pa)     ',  &
                      '    (Deg.C)    (Pa)             (Deg.C)', dots

                 WRITE(logline1,2032) iwel,itrn2,uqwmr,p00,t00,pwrend,twrend
                 status = RM_LogMessage(rm_id, logline1)
                 WRITE(fuwel,2002)  iwel,itrn2,uqwmr,p00,t00,pwrend,twrend
              END IF
              IF(ABS(pwrend-upwkt) > tolfpw*upwkt) THEN
                 upwkt = pwrend
                 utwkt = twrend
                 itrn2 = itrn2+1
                 IF(itrn2 > mxitqw) GO TO 200
                 GO TO 81
              END IF
              upwkt = pwrend
              utwkt = twrend
              uehwkt = ehwend
           END IF
        END IF
     END IF
     ! ... Calculate fluid mass flow rate, store mass fraction
151  qwm(iwel) = 0._kdp
     DO  ks=1,nks
        qwm(iwel) = qwm(iwel)+qflyr(iwel,ks)
     END DO
     pwkt(iwel) = upwkt
     xp%cwkt(iwel) = ucwkt
     xp%cwk(iwel,nks) = ucwkt
     ! ... Test for production concentration greater than specified limit
     IF((awqm == 12 .OR. awqm == 13) .AND. iwfss > 0) THEN
        IF(xp%cwkt(iwel) > 0.8*xp%cwkts(iwel)) THEN
           !..              priwel = 1.
           cwatch = .TRUE.
        END IF
        IF(xp%cwkt(iwel) > xp%cwkts(iwel)) THEN
           qwv(iwel) = 0._kdp
           nshut = nshut+1
           jwell(nshut) = iwel
           !$$                 priwel = my_itime+1
           cwatch = .FALSE.
           GO TO 555
        END IF
     END IF
     ! ... Load rhs with well explicit flow rates at each layer
!!$     DO  ks=1,nks-1
!!$        m = mwel(iwel,ks)
!!$        CALL mtoijk(m,i,j,k,nx,ny)
!!$        IF(awqm == 11 .OR. awqm == 13) THEN
!!$           rf(m) = rf(m)+ufdt2*qflyr(iwel,ks)
!!$        ELSE
!!$           mijkp = m+nxy
!!$           szzw = -tfw(k)*(p(mijkp)-p(m)+denwk(iwel,ks)*gz*(z(k+1)-z(k)))
!!$           rf(mijkp) = rf(mijkp)+szzw
!!$           rf(m) = rf(m)-szzw
!!$        END IF
!!$     END DO
!!$     mkt = mwel(iwel,nks)
!!$     IF(awqm == 11 .OR. awqm == 13) THEN
!!$        rf(mkt) = rf(mkt)+ufdt2*qflyr(iwel,nks)
!!$     ELSE IF(awqm <= 20 .OR. awqm == 40) THEN
!!$        rf(mkt) = rf(mkt)-ufdt2*qwm(iwel)
!!$     END IF
     CYCLE
200  CONTINUE
     WRITE(fuwel,9005) 'Well No. ',iwel,' did not converge on riser',  &
          'calculation for WELLSC, ITIME =',my_itime
9005 FORMAT(tr10,a,i3,2A,i5)
     WRITE(logline1,9015) 'Well No. ',iwel,' did not converge on riser',  &
          'calculation for WELLSC, ITIME =',my_itime
9015 FORMAT(a,i3,2A,i5)
     status = RM_ErrorMessage(rm_id, logline1)
     errexe = .TRUE.
  END DO
  ! ... End of well loop
  IF(nshut > 0) THEN
     WRITE(fuwel,9016) 'Time =',cnvtmi*time,'('//unittm//')',  &
          'The following wells were shut in due to net flow ',  &
          'reversal or due to reservoir pressure too',  &
          'low (high) relative to bore hole pressure for prodution (injection)',  &
          'or production concentration limit reached',  &
          (jwell(i),i=1,nshut)
9016 FORMAT(//tr20,a,1PG10.4,2X,A/tr10,a/tr25,a  &
          /tr25,a  &
          /tr25,a  &
          /(tr30,25I4))
     WRITE(logline1,8016) 'Time  = ',cnvtmi*time,'  ('//unittm//')'
8016 FORMAT(a,1pg10.4,a)
     WRITE(logline2,8017) 'The following wells were shut in due to net flow '
8017 FORMAT(a)
     WRITE(logline3,8017) '          reversal or due to reservoir pressure too' 
     WRITE(logline4,8017) '          low (high) relative to bore hole pressure '//  &
          'for prodution (injection)'
     WRITE(logline5,8017) '          or production concentration limit reached'
     WRITE(logline6,8018) (jwell(i),i=1,nshut)
8018 FORMAT(25i4)
!!$     status = RM_WarningMessage(rm_id, logline1)
!!$     status = RM_WarningMessage(rm_id, logline2)
!!$     status = RM_WarningMessage(rm_id, logline3)
!!$     status = RM_WarningMessage(rm_id, logline4)
!!$     status = RM_WarningMessage(rm_id, logline5)
!!$     status = RM_WarningMessage(rm_id, logline6)
  END IF
  DEALLOCATE (jwell, mobw, r,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, XP_wellsc"  
     STOP  
  ENDIF
END SUBROUTINE XP_wellsc
