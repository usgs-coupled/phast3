SUBROUTINE XP_wellsr_thread(xp)
  ! ... Well prodution/injection routine -- sets rates for each layer for
  ! ...       each well
  ! ... Line source/sink version for rectangular coordinates
!!$  USE machine_constants, ONLY: kdp
  USE machine_constants, ONLY: kdp
  USE f_units, ONLY: fuwel
  USE mcb, ONLY: fresur
  USE mcc, ONLY: ierr, errexe, rm_id
  USE mcc_m, ONLY: prtwel
  USE mcch, ONLY: dots
  USE mcg, ONLY: nx, ny, nz
  USE mcn, ONLY: z
  USE mcp, ONLY: vis0, den0, gz
  USE mcv, ONLY: itime, frac, p
  USE mcw, ONLY: nwel, wqmeth, nkswel, mwel, wi, pwsurs, pwkts, wrisl, wrangl, &
    twrend, tolfpw, mxitqw, tolqw
  USE XP_module, ONLY: Transporter
  USE PhreeqcRM
  IMPLICIT NONE
  !INCLUDE "RM_interface_F.f90.inc"
  INTRINSIC INT
  TYPE (Transporter) :: xp
  REAL(KIND=kdp) :: sum1, sumdnz, summob, ucwkt, udnkt, udnsur,  &
       upm, upwkt, upwsur, uqsw, uqvsur, uqwm, uqwmi,  &
       uqwmr, uqwv, uqwvkt, utwkt
  INTEGER :: a_err, awqm, da_err, i, iis, itrn1, itrn2, iwel, iwfss, j, k, ks,  &
       kwt, m, mt, nks
  LOGICAL :: convd, florev
  ! ...  r array is removed
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: mobw
  INTEGER, DIMENSION(:), ALLOCATABLE :: jwell
  INTEGER my_itime
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4, logline5, logline6
  INTEGER :: status
  INTEGER nshut
  !     ------------------------------------------------------------------
  !...
  my_itime = itime - 1          ! ... local time index
  ! ... Initialize flow rate variables
  nshut=0
  !!$iis = xp%iis_no          ! ... Set index to selected component
  ALLOCATE (jwell(nwel), mobw(nwel*nz),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: wellsr"  
     STOP  
  ENDIF
  DO  iwel=1,nwel
     awqm = ABS(wqmeth(iwel))
     xp%wrcalc = .FALSE.
     IF(awqm >= 40) xp%wrcalc=.TRUE.
     ! ... Uppermost completion cell
     nks = nkswel(iwel)
     mt = mwel(iwel,nks)
     CALL mtoijk(mt,i,j,kwt,nx,ny)
10   CONTINUE
     ! ... Initialize flow rates for this time step
     DO  ks=1,nz
        xp%qwlyr(iwel,ks) = 0._kdp
        xp%qflyr(iwel,ks) = 0._kdp
        xp%qslyr(iwel,ks) = 0._kdp
        xp%dqwdpl(iwel,ks) = 0._kdp
     END DO
     ! ... Observation wells are skipped
     IF(awqm == 0) CYCLE
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
        udnsur  =  den0
        !xp%dengl = denwk(iwel,nks)*gz*wrisl(iwel)*COS(wrangl(iwel))
        xp%dengl = den0*gz*wrisl(iwel)*COS(wrangl(iwel))
        ! ... Well datum pressure estimate
        IF(my_itime == 0) THEN
           upwkt = upwsur+xp%dengl
        ELSE
           upwkt = xp%pwkt(iwel)
        END IF
     END IF
     iwfss = INT(SIGN(1._kdp,uqwvkt))
     IF(ABS(uqwvkt) < 1.e-8_kdp) iwfss = 0
     IF(awqm == 20 .OR. awqm == 40) THEN
        IF(upwkt > upm) THEN
           iwfss = -1
        ELSE IF(upwkt < upm) THEN
           iwfss = 1
        END IF
     END IF
     IF(iwfss >= 0) THEN            ! ... Production well
        ucwkt = xp%cwk(iwel,nks)
     ELSE IF(iwfss < 0) THEN        ! ... Injection well
        ucwkt = xp%cwkt(iwel)
     END IF
     udnkt  =  den0
     ! ... Iteration loop start for wellbore flow allocation
     itrn1 = 1
     itrn2 = 1
50   CONTINUE
     IF(awqm/10 == 1 .OR. awqm == 30 .OR. awqm == 50) THEN
        ! ... Specified flow rate, WQMETH = 11 or 10 or 12 or 13
        sum1 = 0._kdp
        summob = 0._kdp
        sumdnz = 0._kdp
        DO  ks=nks,1,-1
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           !IF(ks < nks) sumdnz  =  sumdnz + (denwk(iwel,ks+1)+denwk(iwel,ks))*  &
           IF(ks < nks) sumdnz  =  sumdnz + (den0+den0)*  &
                (z(k+1)-z(k))
           sum1 = sum1+mobw(ks)*(p(m)-.5*gz*sumdnz)
           summob = summob+mobw(ks)
        END DO
        IF(summob <= 0.) THEN
           ierr(140) = .TRUE.
           errexe = .TRUE.
           GO TO 200
        END IF
        ! ... Pressure at well datum
        upwkt = (-uqwvkt+sum1)/summob
        IF(awqm == 30) THEN
           ! ... Apply pressure limitation for well datum pressure
           IF(iwfss > 0) upwkt = MAX(upwkt,pwkts(iwel))
           IF(iwfss < 0) upwkt = MIN(upwkt,pwkts(iwel))
        END IF
     END IF
     IF(awqm == 50 .AND. iwfss < 0) THEN
        ! ... Injection well, specified surface flow rate, pressure constraint
        ! ...   Estimate PWSUR
        xp%pwrend = upwkt
        !upwsur = upwkt-denwk(iwel,nks)* gz*wrisl(iwel)*COS(wrangl(iwel))
        upwsur = upwkt-den0 * gz*wrisl(iwel)*COS(wrangl(iwel))
70      upwsur = upwsur+upwkt-xp%pwrend
        udnsur = den0
        uqwmr = -xp%qwv(iwel)*udnsur
        xp%p00 = upwsur
        xp%t00 = xp%t0h
        CALL welris(iwel,iwfss,uqwmr)
        IF(prtwel) THEN
           WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet'
5011       FORMAT(2A)
           WRITE(logline2,5011) 'no.     #1       #2       rate        pressure ',  &
                '   temperature  pressure        temperature'
           WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)'
           WRITE(logline4,5021) dots
5021       FORMAT(a80)
           status = RM_LogMessage(rm_id, logline1)
           status = RM_LogMessage(rm_id, logline2)
           status = RM_LogMessage(rm_id, logline3)
           status = RM_LogMessage(rm_id, logline4)
           WRITE(fuwel,2001) 'well iteration iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet',  &
                'no.     #1       #2       rate        pressure ',  &
                '   temperature  pressure        temperature',  &
                '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)', dots
2001       FORMAT(/tr5,2A/tr5,2A/tr5,2A/tr5,a80)
           WRITE(logline1,2032) iwel,itrn1,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
2032       FORMAT(i5,2i12,2(1PG14.6),0PF10.1,1PG14.6,0PF10.1)
           status = RM_LogMessage(rm_id, logline1)
           WRITE(fuwel,2002) iwel,itrn1,itrn2,uqwmr,xp%p00,xp%t00, xp%pwrend,twrend
2002       FORMAT(i5,2I12,2(1PG14.6),0PF10.1,1PG14.6,0PF10.1)
        END IF
        IF(ABS(upwkt-xp%pwrend) <= tolfpw*upwkt) THEN
           ! ... We have riser calculation convergence
           upwkt = xp%pwrend
           udnkt  =  den0
           uqwvkt = uqwmr/udnkt
        ELSE
           itrn2 = itrn2+1
           IF(itrn2 > mxitqw) GO TO 170
           GO TO 70
        END IF
        ! ... Test for surface pressure constraint
        IF(upwsur >= pwsurs(iwel)) THEN           ! ... High pressure limited
           upwsur = pwsurs(iwel)
           awqm = 40
           GO TO 40
        END IF
     END IF
80   CONTINUE
     ! ... Allocate the flow
     IF(awqm == 20 .OR. awqm == 40) uqwv = 0._kdp
     DO  ks=nks,1,-1
        m = mwel(iwel,ks)
        CALL mtoijk(m,i,j,k,nx,ny)
        IF(mobw(ks) > 0.) THEN
           ! ... Calculate the pressure profile in the well
           IF(ks == nks) THEN
              xp%pwk(iwel,ks) = upwkt
           ELSE
              xp%pwk(iwel,ks) = xp%pwk(iwel,ks+1)+.5*gz*  &
                   !(denwk(iwel,ks+1)+denwk(iwel,ks))*(z(k+1)-z(k))
                   (den0+den0)*(z(k+1)-z(k))
           END IF
           IF(awqm == 11 .OR. awqm == 13 .OR. my_itime == 0 .OR. iwfss < 0) THEN
              ! ... Allocate on mobility alone, always for injection
              xp%qwlyr(iwel,ks) = -uqwvkt*mobw(ks)/summob
           ELSE
              ! ... Allocate on mobility*pressure difference
              ! ... Explicit flow rate term
              xp%qwlyr(iwel,ks) = mobw(ks)*(xp%pwk(iwel,ks)-p(m))
              ! ... Semi-implicit rate for LHS
              xp%dqwdpl(iwel,ks) = -mobw(ks)
           END IF
           ! ... Sum the volumetric flow rates for specified pressure
           ! ...      conditions
           IF(awqm == 20 .OR. awqm == 40) uqwv=uqwv-xp%qwlyr(iwel,ks)
        END IF
     END DO
     IF(awqm == 20 .OR. awqm == 40) THEN
        iwfss = INT(SIGN(1._kdp,uqwv))
        IF(ABS(uqwv) < 1.e-8_kdp) iwfss = 0
        uqwvkt = uqwv
     END IF
     ! ... Sum mass solute flow rates for the well
     ! ... Calculate new mass fraction,
     ! ...      density profiles
     florev = .FALSE.
     IF(iwfss >= 0) THEN
        ! ... Production well
        uqwm = 0._kdp
        uqsw = 0._kdp
        DO  ks=1,nks
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(xp%qwlyr(iwel,ks) < 0.) THEN              ! ... Production layer
              xp%qflyr(iwel,ks) = den0*xp%qwlyr(iwel,ks)
              uqwm = uqwm-xp%qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = xp%qflyr(iwel,ks)*xp%c_w(m)
              uqsw = uqsw-xp%qslyr(iwel,ks)
              xp%cwk(iwel,ks) = uqsw/uqwm
           ELSE
              ! ... Injection layer from producing well (not allowed at layer K = 1)
              !xp%qflyr(iwel,ks)  =  denwk(iwel,ks)*xp%qwlyr(iwel,ks)
              xp%qflyr(iwel,ks)  =  den0*xp%qwlyr(iwel,ks)
              uqwm = uqwm-xp%qflyr(iwel,ks)
              xp%cwk(iwel,ks) = xp%cwk(iwel,ks-1)
              xp%qslyr(iwel,ks) = xp%qflyr(iwel,ks)*xp%cwk(iwel,ks)
              uqsw = uqsw-xp%qslyr(iwel,ks)
           END IF
           !udenw(ks) = den0
           IF(uqwm < 0.) THEN
              WRITE(fuwel,9002) 'Production Well No. ',iwel,  &
                   ' has down bore flow from level ',k+1,' to ',  &
                   k,'; Time plane N  = ',my_itime,'; Mass flow rate  = ', uqwm
9002          FORMAT(tr10,a,i4,a,i2,a,i2,a,i4/tr15,a,1PG10.2)
              florev = .TRUE.
           END IF
        END DO
        !udnkt = denwk(iwel,nks)
        udnkt = den0
        ucwkt = xp%cwk(iwel,nks)
     ELSE IF(iwfss < 0) THEN        ! ... Injection well
        uqwm = udnkt*uqwvkt
        ! ... UWQM>0 is production
        uqwmi = uqwm
        uqsw = uqwm*ucwkt
        DO  ks=nks,1,-1
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(xp%qwlyr(iwel,ks) > 0.) THEN              ! ... Injection layer
              IF(ks == nks) THEN
                 xp%cwk(iwel,ks) = xp%cwkt(iwel)
              ELSE
                 xp%cwk(iwel,ks) = xp%cwk(iwel,ks+1)
              END IF
              !udenw(ks) = den0
              !xp%qflyr(iwel,ks) = udenw(ks)*xp%qwlyr(iwel,ks)
              xp%qflyr(iwel,ks) = den0*xp%qwlyr(iwel,ks)
              uqwm = uqwm+xp%qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = xp%qflyr(iwel,ks)*xp%cwk(iwel,ks)
              uqsw = uqsw+xp%qslyr(iwel,ks)
           ELSE              ! ... Production layer into injection well
              xp%qflyr(iwel,ks) = den0*xp%qwlyr(iwel,ks)
              uqwm = uqwm+xp%qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = xp%qflyr(iwel,ks)*xp%c_w(m)
              uqsw = uqsw+xp%qslyr(iwel,ks)
              xp%cwk(iwel,ks) = uqsw/uqwm
           END IF
           !udenw(ks) = den0
           IF(ks > 1 .AND. uqwm/ABS(uqwmi) > 0.01_kdp) THEN
              florev = .TRUE.
              WRITE(fuwel,9002) 'Injection Well No. ',iwel,  &
                   ' has up bore flow from level ',ks-1,' to ',ks,  &
                   '; Time plane N =',my_itime,' Mass flow rate =', uqwm
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
             'may be poor approximations (WELLSR)'
9004    FORMAT(tr10,2A)
        ierr(142) = .TRUE.
     END IF
     IF(awqm == 11) GO TO 150
     IF(iwfss > 0 .AND. uqwm < 0.) THEN
        ! ... Net reverse well flow. Shut well in.
        nshut = nshut+1
        jwell(nshut) = iwel
        DO  ks=1,nks
           xp%qwlyr(iwel,ks) = 0._kdp
           xp%qflyr(iwel,ks) = 0._kdp
           xp%dqwdpl(iwel,ks) = 0._kdp
           uqwm = 0._kdp
           xp%qslyr(iwel,ks) = 0._kdp
           uqsw = 0._kdp
        END DO
        GO TO 150
     END IF
     convd = .TRUE.
     ! ... Convergence test on density profile
     !DO  ks=1,nks
        !IF(ABS(udenw(ks)-denwk(iwel,ks)) > tolden*denwk(iwel,ks)) convd=.FALSE.
        !denwk(iwel,ks) = udenw(ks)
     !END DO
     IF(convd) GO TO 140
     itrn1 = itrn1+1
     IF(itrn1 >= mxitqw) GO TO 180
     GO TO 50
     ! ... We have achieved convergence on density
140  IF(awqm == 50 .AND. iwfss > 0) THEN
        ! ... Production well, specified surface flow rate, pressure constraint
        uqwmr=uqwm
        xp%p00 = upwkt
        CALL welris(iwel,iwfss,uqwmr)
        IF(prtwel) THEN
           WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet'
           WRITE(logline2,5011) 'no.     #1       #2       rate        pressure ',  &
                '   temperature  pressure        temperature'
           WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)'
           WRITE(logline4,5021) dots
           status = RM_LogMessage(rm_id, logline1)
           status = RM_LogMessage(rm_id, logline2)
           status = RM_LogMessage(rm_id, logline3)
           status = RM_LogMessage(rm_id, logline4)
           WRITE(fuwel,2001) 'well iteration iteration mass flow  riser inlet ',  &
                '   riser inlet   riser outlet riser outlet',  &
                'no.     #1       #2       rate        pressure ',  &
                '   temperature  pressure        temperature',  &
                '                        (kg/s)        (Pa)     ',  &
                '    (Deg.C)    (Pa)             (Deg.C)', dots
           WRITE(logline1,2032) iwel,itrn1,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
           status = RM_LogMessage(rm_id, logline1)
           WRITE(fuwel,2002) iwel,itrn1,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend, twrend
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
           IF(itrn2 > mxitqw) GO TO 170
           GO TO 50
        END IF
     END IF
     IF(awqm == 40) THEN
        ! ... Specified surface pressure
        iwfss = INT(SIGN(1._kdp,uqwm))
        IF(ABS(uqwm) <= 1.e-8_kdp) iwfss = 0
        uqwmr = uqwm
        IF(iwfss > 0) THEN
           ! ... Production well
           xp%p00 = upwkt
           CALL welris(iwel,iwfss,uqwmr)
           IF(prtwel) THEN
              WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                   '   riser inlet   riser outlet riser outlet'
              WRITE(logline2,5011) 'no.     #1       #2       rate        pressure ',  &
                   '   temperature  pressure        temperature'
              WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                   '   (Deg.C)    (Pa)             (Deg.C)'
              WRITE(logline4,5021) dots
              status = RM_LogMessage(rm_id, logline1)
              status = RM_LogMessage(rm_id, logline2)
              status = RM_LogMessage(rm_id, logline3)
              status = RM_LogMessage(rm_id, logline4)
              WRITE(fuwel,2001)  &
                   'well iteration iteration mass flow  riser inlet ',  &
                   '   riser inlet   riser outlet riser outlet',  &
                   'no.     #1       #2       rate        pressure ',  &
                   '   temperature  pressure        temperature',  &
                   '                        (kg/s)        (Pa)     ',  &
                   '    (Deg.C)    (Pa)             (Deg.C)', dots
              WRITE(logline1,2032) iwel,itrn1,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
              status = RM_LogMessage(rm_id, logline1)
              WRITE(fuwel,2002) iwel,itrn1,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend, twrend
           END IF
           IF(ABS(xp%pwrend-pwsurs(iwel)) > tolfpw*pwsurs(iwel)) THEN
              upwkt = upwkt+xp%pwrend-pwsurs(iwel)
              itrn2 = itrn2+1
              IF(itrn2 > mxitqw) GO TO 170
              GO TO 80
           END IF
        ELSE IF(iwfss < 0) THEN
           ! ... Injection well
           xp%p00 = pwsurs(iwel)
           xp%t00 = xp%t0h
           CALL welris(iwel,iwfss,uqwmr)
           IF(prtwel) THEN
              WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                   '   riser inlet   riser outlet riser outlet'
              WRITE(logline2,5011) 'no.     #1       #2       rate        pressure ',  &
                   '   temperature  pressure        temperature'
              WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                   '   (Deg.C)    (Pa)             (Deg.C)'
              WRITE(logline4,5021) dots
              status = RM_LogMessage(rm_id, logline1)
              status = RM_LogMessage(rm_id, logline2)
              status = RM_LogMessage(rm_id, logline3)
              status = RM_LogMessage(rm_id, logline4)
              WRITE(fuwel,2001)  &
                   'well iteration iteration mass flow  riser inlet ',  &
                   '   riser inlet   riser outlet riser outlet',  &
                   'no.     #1       #2       rate        pressure ',  &
                   '   temperature  pressure        temperature',  &
                   '                        (kg/s)        (Pa)     ',  &
                   '    (Deg.C)    (Pa)             (Deg.C)', dots
              WRITE(logline1,2032) iwel,itrn1,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
              status = RM_LogMessage(rm_id, logline1)
              WRITE(fuwel,2002) iwel,itrn1,itrn2,uqwmr,xp%p00,xp%t00,xp%pwrend,twrend
           END IF
           IF(ABS(xp%pwrend-upwkt) > tolfpw*upwkt) THEN
              upwkt = xp%pwrend
              itrn2 = itrn2+1
              IF(itrn2 > mxitqw) GO TO 170
              GO TO 80
           END IF
           upwkt = xp%pwrend
        END IF
     END IF
     ! ... Calculate fluid mass flow rate, store enthalpy, temperature,
     ! ...       mass fraction
150  xp%qwm(iwel) = 0._kdp
     DO  ks=1,nks
        xp%qwm(iwel) = xp%qwm(iwel)+xp%qflyr(iwel,ks)
     END DO
     xp%pwkt(iwel) = upwkt
     ! ... Production or injection well
     xp%cwkt(iwel) = ucwkt
     xp%cwk(iwel,nks) = ucwkt
     ! ... Test for production concentration greater than specified limit
     IF((awqm == 12 .OR. awqm == 13) .AND. iwfss > 0) THEN
        IF(xp%cwkt(iwel) > 0.8*xp%cwkts(iwel)) THEN
           !...              priwel = 1.
           xp%cwatch = .TRUE.
        END IF
        IF(xp%cwkt(iwel) > xp%cwkts(iwel)) THEN
           xp%qwv(iwel) = 0.
           nshut = nshut+1
           jwell(nshut) = iwel
           !!$     priwel = my_itime+1
           xp%cwatch = .FALSE.
           GO TO 10
        END IF
     END IF
     CYCLE
170  CONTINUE
     WRITE(fuwel,9005) 'Well No. ',iwel,'calculation for WELLSR, ITIME =',my_itime
9005 FORMAT(tr10,a,i3,A,i5)
     WRITE(logline1,9015) 'Well No. ',iwel,'calculation for WELLSR, ITIME =',my_itime
9015 FORMAT(a,i3,a,i5)
     status = RM_LogMessage(rm_id, logline1)
     errexe = .TRUE.
180  CONTINUE
     WRITE(fuwel,9005)  &
          'Well No. ',iwel,' did not converge on density in WELLSR', '; ITIME =',my_itime
     WRITE(logline1,9015) 'Well No. ',iwel,' did not converge on  density in WELLSR',  &
          '; ITIME =',my_itime
     status = RM_ErrorMessage(rm_id, logline1)
     errexe = .TRUE.
  END DO
  ! ... End of well loop
!!$  IF(nshut > 0) THEN
!!$     WRITE(fuwel,9006) cnvtmi*time,'(',unittm,')', (jwell(i),i=1,nshut)
!!$9006 FORMAT(//tr20,'Time  = ',1PG10.4,tr2,3A/tr10,  &
!!$          'The following wells were shut in due to net flow '/tr25,  &
!!$          'reversal or due to reservoir pressure too'/tr25,  &
!!$          'low (high) relative to bore hole pressure for ',  &
!!$          'prodution (injection)'/tr25,  &
!!$          'or production concentration limit reached'/(tr30,25I4))
!!$     WRITE(logline1,8016) 'Time =',cnvtmi*time,'  ('//unittm//')'
!!$8016 format(a,1pg10.4,a)
!!$     WRITE(logline2,8017) 'The following wells were shut in due to net flow '
!!$8017 format(a)
!!$     WRITE(logline3,8017) '          reversal or due to reservoir pressure too' 
!!$     WRITE(logline4,8017) '          low (high) relative to bore hole pressure '//  &
!!$          'for prodution (injection)'
!!$     WRITE(logline5,8017) '          or production concentration limit reached'
!!$     WRITE(logline6,8018) (jwell(i),i=1,nshut)
!!$8018 format(25i4)
!!$     status = RM_WarningMessage(rm_id, logline1)
!!$     status = RM_WarningMessage(rm_id, logline2)
!!$     status = RM_WarningMessage(rm_id, logline3)
!!$     status = RM_WarningMessage(rm_id, logline4)
!!$     status = RM_WarningMessage(rm_id, logline5)
!!$     status = RM_WarningMessage(rm_id, logline6)
!!$  END IF
  DEALLOCATE (jwell, mobw,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, XP_wellsr"  
     STOP  
  ENDIF
  RETURN
200 CONTINUE
  WRITE(fuwel,9005) 'Well no. ',iwel,' has all zero mobility factors; WELLSR, ITIME =',my_itime
  WRITE(logline1,9015) 'Well no. ',iwel,' has all zero mobility factors; WELLSR, ITIME =',my_itime
  status = RM_ErrorMessage(rm_id, logline1)
  DEALLOCATE (jwell, mobw,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, XP_wellsr"
     STOP  
  ENDIF
END SUBROUTINE XP_wellsr_thread
SUBROUTINE XP_wellsr(xp)
  ! ... Well prodution/injection routine -- sets rates for each layer for
  ! ...       each well
  ! ... Line source/sink version for rectangular coordinates
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
  USE XP_module, ONLY: Transporter
  USE PhreeqcRM
  IMPLICIT NONE
  !INCLUDE "RM_interface_F.f90.inc"
  INTRINSIC INT
  TYPE (Transporter) :: xp
  REAL(KIND=kdp) :: sum1, sumdnz, summob, ucwkt, udnkt, udnsur,  &
       upm, upwkt, upwsur, uqsw, uqvsur, uqwm, uqwmi,  &
       uqwmr, uqwv, uqwvkt, utwkt
  INTEGER :: a_err, awqm, da_err, i, iis, itrn1, itrn2, iwel, iwfss, j, k, ks,  &
       kwt, m, mt, nks
  LOGICAL :: convd, florev
  ! ...  r array is removed
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: mobw
  INTEGER, DIMENSION(:), ALLOCATABLE :: jwell
  INTEGER my_itime
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4, logline5, logline6
  INTEGER :: status
  !     ------------------------------------------------------------------
  !...
  my_itime = itime - 1          ! ... local time index
  ! ... Initialize flow rate variables
  nshut=0
  !!$iis = xp%iis_no          ! ... Set index to selected component
  ALLOCATE (jwell(nwel), mobw(nwel*nz),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: wellsr"  
     STOP  
  ENDIF
  DO  iwel=1,nwel
     awqm = ABS(wqmeth(iwel))
     wrcalc = .FALSE.
     IF(awqm >= 40) wrcalc=.TRUE.
     ! ... Uppermost completion cell
     nks = nkswel(iwel)
     mt = mwel(iwel,nks)
     CALL mtoijk(mt,i,j,kwt,nx,ny)
10   CONTINUE
     ! ... Initialize flow rates for this time step
     DO  ks=1,nz
        qwlyr(iwel,ks) = 0._kdp
        qflyr(iwel,ks) = 0._kdp
        xp%qslyr(iwel,ks) = 0._kdp
        dqwdpl(iwel,ks) = 0._kdp
     END DO
     ! ... Observation wells are skipped
     IF(awqm == 0) CYCLE
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
        udnsur  =  den0
        dengl = denwk(iwel,nks)*gz*wrisl(iwel)*COS(wrangl(iwel))
        ! ... Well datum pressure estimate
        IF(my_itime == 0) THEN
           upwkt = upwsur+dengl
        ELSE
           upwkt = pwkt(iwel)
        END IF
     END IF
     iwfss = INT(SIGN(1._kdp,uqwvkt))
     IF(ABS(uqwvkt) < 1.e-8_kdp) iwfss = 0
     IF(awqm == 20 .OR. awqm == 40) THEN
        IF(upwkt > upm) THEN
           iwfss = -1
        ELSE IF(upwkt < upm) THEN
           iwfss = 1
        END IF
     END IF
     IF(iwfss >= 0) THEN            ! ... Production well
        ucwkt = xp%cwk(iwel,nks)
     ELSE IF(iwfss < 0) THEN        ! ... Injection well
        ucwkt = xp%cwkt(iwel)
     END IF
     udnkt  =  den0
     ! ... Iteration loop start for wellbore flow allocation
     itrn1 = 1
     itrn2 = 1
50   CONTINUE
     IF(awqm/10 == 1 .OR. awqm == 30 .OR. awqm == 50) THEN
        ! ... Specified flow rate, WQMETH = 11 or 10 or 12 or 13
        sum1 = 0._kdp
        summob = 0._kdp
        sumdnz = 0._kdp
        DO  ks=nks,1,-1
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(ks < nks) sumdnz  =  sumdnz + (denwk(iwel,ks+1)+denwk(iwel,ks))*  &
                (z(k+1)-z(k))
           sum1 = sum1+mobw(ks)*(p(m)-.5*gz*sumdnz)
           summob = summob+mobw(ks)
        END DO
        IF(summob <= 0.) THEN
           ierr(140) = .TRUE.
           errexe = .TRUE.
           GO TO 200
        END IF
        ! ... Pressure at well datum
        upwkt = (-uqwvkt+sum1)/summob
        IF(awqm == 30) THEN
           ! ... Apply pressure limitation for well datum pressure
           IF(iwfss > 0) upwkt = MAX(upwkt,pwkts(iwel))
           IF(iwfss < 0) upwkt = MIN(upwkt,pwkts(iwel))
        END IF
     END IF
     IF(awqm == 50 .AND. iwfss < 0) THEN
        ! ... Injection well, specified surface flow rate, pressure constraint
        ! ...   Estimate PWSUR
        pwrend = upwkt
        upwsur = upwkt-denwk(iwel,nks)* gz*wrisl(iwel)*COS(wrangl(iwel))
70      upwsur = upwsur+upwkt-pwrend
        udnsur = den0
        uqwmr = -qwv(iwel)*udnsur
        p00 = upwsur
        t00 = t0h
        CALL welris(iwel,iwfss,uqwmr)
        IF(prtwel) THEN
           WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet'
5011       FORMAT(2A)
           WRITE(logline2,5011) 'no.     #1       #2       rate        pressure ',  &
                '   temperature  pressure        temperature'
           WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)'
           WRITE(logline4,5021) dots
5021       FORMAT(a80)
           status = RM_LogMessage(rm_id, logline1)
           status = RM_LogMessage(rm_id, logline2)
           status = RM_LogMessage(rm_id, logline3)
           status = RM_LogMessage(rm_id, logline4)
           WRITE(fuwel,2001) 'well iteration iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet',  &
                'no.     #1       #2       rate        pressure ',  &
                '   temperature  pressure        temperature',  &
                '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)', dots
2001       FORMAT(/tr5,2A/tr5,2A/tr5,2A/tr5,a80)
           WRITE(logline1,2032) iwel,itrn1,itrn2,uqwmr,p00,t00,pwrend,twrend
2032       FORMAT(i5,2i12,2(1PG14.6),0PF10.1,1PG14.6,0PF10.1)
           status = RM_LogMessage(rm_id, logline1)
           WRITE(fuwel,2002) iwel,itrn1,itrn2,uqwmr,p00,t00, pwrend,twrend
2002       FORMAT(i5,2I12,2(1PG14.6),0PF10.1,1PG14.6,0PF10.1)
        END IF
        IF(ABS(upwkt-pwrend) <= tolfpw*upwkt) THEN
           ! ... We have riser calculation convergence
           upwkt = pwrend
           udnkt  =  den0
           uqwvkt = uqwmr/udnkt
        ELSE
           itrn2 = itrn2+1
           IF(itrn2 > mxitqw) GO TO 170
           GO TO 70
        END IF
        ! ... Test for surface pressure constraint
        IF(upwsur >= pwsurs(iwel)) THEN           ! ... High pressure limited
           upwsur = pwsurs(iwel)
           awqm = 40
           GO TO 40
        END IF
     END IF
80   CONTINUE
     ! ... Allocate the flow
     IF(awqm == 20 .OR. awqm == 40) uqwv = 0._kdp
     DO  ks=nks,1,-1
        m = mwel(iwel,ks)
        CALL mtoijk(m,i,j,k,nx,ny)
        IF(mobw(ks) > 0.) THEN
           ! ... Calculate the pressure profile in the well
           IF(ks == nks) THEN
              pwk(iwel,ks) = upwkt
           ELSE
              pwk(iwel,ks) = pwk(iwel,ks+1)+.5*gz*  &
                   (denwk(iwel,ks+1)+denwk(iwel,ks))*(z(k+1)-z(k))
           END IF
           IF(awqm == 11 .OR. awqm == 13 .OR. my_itime == 0 .OR. iwfss < 0) THEN
              ! ... Allocate on mobility alone, always for injection
              qwlyr(iwel,ks) = -uqwvkt*mobw(ks)/summob
           ELSE
              ! ... Allocate on mobility*pressure difference
              ! ... Explicit flow rate term
              qwlyr(iwel,ks) = mobw(ks)*(pwk(iwel,ks)-p(m))
              ! ... Semi-implicit rate for LHS
              dqwdpl(iwel,ks) = -mobw(ks)
           END IF
           ! ... Sum the volumetric flow rates for specified pressure
           ! ...      conditions
           IF(awqm == 20 .OR. awqm == 40) uqwv=uqwv-qwlyr(iwel,ks)
        END IF
     END DO
     IF(awqm == 20 .OR. awqm == 40) THEN
        iwfss = INT(SIGN(1._kdp,uqwv))
        IF(ABS(uqwv) < 1.e-8_kdp) iwfss = 0
        uqwvkt = uqwv
     END IF
     ! ... Sum mass solute flow rates for the well
     ! ... Calculate new mass fraction,
     ! ...      density profiles
     florev = .FALSE.
     IF(iwfss >= 0) THEN
        ! ... Production well
        uqwm = 0._kdp
        uqsw = 0._kdp
        DO  ks=1,nks
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(qwlyr(iwel,ks) < 0.) THEN              ! ... Production layer
              qflyr(iwel,ks) = den0*qwlyr(iwel,ks)
              uqwm = uqwm-qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = qflyr(iwel,ks)*xp%c_w(m)
              uqsw = uqsw-xp%qslyr(iwel,ks)
              xp%cwk(iwel,ks) = uqsw/uqwm
           ELSE
              ! ... Injection layer from producing well (not allowed at layer K = 1)
              qflyr(iwel,ks)  =  denwk(iwel,ks)*qwlyr(iwel,ks)
              uqwm = uqwm-qflyr(iwel,ks)
              xp%cwk(iwel,ks) = xp%cwk(iwel,ks-1)
              xp%qslyr(iwel,ks) = qflyr(iwel,ks)*xp%cwk(iwel,ks)
              uqsw = uqsw-xp%qslyr(iwel,ks)
           END IF
           udenw(ks) = den0
           IF(uqwm < 0.) THEN
              WRITE(fuwel,9002) 'Production Well No. ',iwel,  &
                   ' has down bore flow from level ',k+1,' to ',  &
                   k,'; Time plane N  = ',my_itime,'; Mass flow rate  = ', uqwm
9002          FORMAT(tr10,a,i4,a,i2,a,i2,a,i4/tr15,a,1PG10.2)
              florev = .TRUE.
           END IF
        END DO
        udnkt = denwk(iwel,nks)
        ucwkt = xp%cwk(iwel,nks)
     ELSE IF(iwfss < 0) THEN        ! ... Injection well
        uqwm = udnkt*uqwvkt
        ! ... UWQM>0 is production
        uqwmi = uqwm
        uqsw = uqwm*ucwkt
        DO  ks=nks,1,-1
           m = mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(qwlyr(iwel,ks) > 0.) THEN              ! ... Injection layer
              IF(ks == nks) THEN
                 xp%cwk(iwel,ks) = xp%cwkt(iwel)
              ELSE
                 xp%cwk(iwel,ks) = xp%cwk(iwel,ks+1)
              END IF
              udenw(ks) = den0
              qflyr(iwel,ks) = udenw(ks)*qwlyr(iwel,ks)
              uqwm = uqwm+qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = qflyr(iwel,ks)*xp%cwk(iwel,ks)
              uqsw = uqsw+xp%qslyr(iwel,ks)
           ELSE              ! ... Production layer into injection well
              qflyr(iwel,ks) = den0*qwlyr(iwel,ks)
              uqwm = uqwm+qflyr(iwel,ks)
              xp%qslyr(iwel,ks) = qflyr(iwel,ks)*xp%c_w(m)
              uqsw = uqsw+xp%qslyr(iwel,ks)
              xp%cwk(iwel,ks) = uqsw/uqwm
           END IF
           udenw(ks) = den0
           IF(ks > 1 .AND. uqwm/ABS(uqwmi) > 0.01_kdp) THEN
              florev = .TRUE.
              WRITE(fuwel,9002) 'Injection Well No. ',iwel,  &
                   ' has up bore flow from level ',ks-1,' to ',ks,  &
                   '; Time plane N =',my_itime,' Mass flow rate =', uqwm
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
             'may be poor approximations (WELLSR)'
9004    FORMAT(tr10,2A)
        ierr(142) = .TRUE.
     END IF
     IF(awqm == 11) GO TO 150
     IF(iwfss > 0 .AND. uqwm < 0.) THEN
        ! ... Net reverse well flow. Shut well in.
        nshut = nshut+1
        jwell(nshut) = iwel
        DO  ks=1,nks
           qwlyr(iwel,ks) = 0._kdp
           qflyr(iwel,ks) = 0._kdp
           dqwdpl(iwel,ks) = 0._kdp
           uqwm = 0._kdp
           xp%qslyr(iwel,ks) = 0._kdp
           uqsw = 0._kdp
        END DO
        GO TO 150
     END IF
     convd = .TRUE.
     ! ... Convergence test on density profile
     DO  ks=1,nks
        IF(ABS(udenw(ks)-denwk(iwel,ks)) > tolden*denwk(iwel,ks)) convd=.FALSE.
        denwk(iwel,ks) = udenw(ks)
     END DO
     IF(convd) GO TO 140
     itrn1 = itrn1+1
     IF(itrn1 >= mxitqw) GO TO 180
     GO TO 50
     ! ... We have achieved convergence on density
140  IF(awqm == 50 .AND. iwfss > 0) THEN
        ! ... Production well, specified surface flow rate, pressure constraint
        uqwmr=uqwm
        p00 = upwkt
        CALL welris(iwel,iwfss,uqwmr)
        IF(prtwel) THEN
           WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                '   riser inlet   riser outlet riser outlet'
           WRITE(logline2,5011) 'no.     #1       #2       rate        pressure ',  &
                '   temperature  pressure        temperature'
           WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                '   (Deg.C)    (Pa)             (Deg.C)'
           WRITE(logline4,5021) dots
           status = RM_LogMessage(rm_id, logline1)
           status = RM_LogMessage(rm_id, logline2)
           status = RM_LogMessage(rm_id, logline3)
           status = RM_LogMessage(rm_id, logline4)
           WRITE(fuwel,2001) 'well iteration iteration mass flow  riser inlet ',  &
                '   riser inlet   riser outlet riser outlet',  &
                'no.     #1       #2       rate        pressure ',  &
                '   temperature  pressure        temperature',  &
                '                        (kg/s)        (Pa)     ',  &
                '    (Deg.C)    (Pa)             (Deg.C)', dots
           WRITE(logline1,2032) iwel,itrn1,itrn2,uqwmr,p00,t00,pwrend,twrend
           status = RM_LogMessage(rm_id, logline1)
           WRITE(fuwel,2002) iwel,itrn1,itrn2,uqwmr,p00,t00,pwrend, twrend
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
           IF(itrn2 > mxitqw) GO TO 170
           GO TO 50
        END IF
     END IF
     IF(awqm == 40) THEN
        ! ... Specified surface pressure
        iwfss = INT(SIGN(1._kdp,uqwm))
        IF(ABS(uqwm) <= 1.e-8_kdp) iwfss = 0
        uqwmr = uqwm
        IF(iwfss > 0) THEN
           ! ... Production well
           p00 = upwkt
           CALL welris(iwel,iwfss,uqwmr)
           IF(prtwel) THEN
              WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                   '   riser inlet   riser outlet riser outlet'
              WRITE(logline2,5011) 'no.     #1       #2       rate        pressure ',  &
                   '   temperature  pressure        temperature'
              WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                   '   (Deg.C)    (Pa)             (Deg.C)'
              WRITE(logline4,5021) dots
              status = RM_LogMessage(rm_id, logline1)
              status = RM_LogMessage(rm_id, logline2)
              status = RM_LogMessage(rm_id, logline3)
              status = RM_LogMessage(rm_id, logline4)
              WRITE(fuwel,2001)  &
                   'well iteration iteration mass flow  riser inlet ',  &
                   '   riser inlet   riser outlet riser outlet',  &
                   'no.     #1       #2       rate        pressure ',  &
                   '   temperature  pressure        temperature',  &
                   '                        (kg/s)        (Pa)     ',  &
                   '    (Deg.C)    (Pa)             (Deg.C)', dots
              WRITE(logline1,2032) iwel,itrn1,itrn2,uqwmr,p00,t00,pwrend,twrend
              status = RM_LogMessage(rm_id, logline1)
              WRITE(fuwel,2002) iwel,itrn1,itrn2,uqwmr,p00,t00,pwrend, twrend
           END IF
           IF(ABS(pwrend-pwsurs(iwel)) > tolfpw*pwsurs(iwel)) THEN
              upwkt = upwkt+pwrend-pwsurs(iwel)
              itrn2 = itrn2+1
              IF(itrn2 > mxitqw) GO TO 170
              GO TO 80
           END IF
        ELSE IF(iwfss < 0) THEN
           ! ... Injection well
           p00 = pwsurs(iwel)
           t00 = t0h
           CALL welris(iwel,iwfss,uqwmr)
           IF(prtwel) THEN
              WRITE(logline1,5011) 'well iteration mass flow  riser inlet',  &
                   '   riser inlet   riser outlet riser outlet'
              WRITE(logline2,5011) 'no.     #1       #2       rate        pressure ',  &
                   '   temperature  pressure        temperature'
              WRITE(logline3,5011) '                        (kg/s)        (Pa)      ',  &
                   '   (Deg.C)    (Pa)             (Deg.C)'
              WRITE(logline4,5021) dots
              status = RM_LogMessage(rm_id, logline1)
              status = RM_LogMessage(rm_id, logline2)
              status = RM_LogMessage(rm_id, logline3)
              status = RM_LogMessage(rm_id, logline4)
              WRITE(fuwel,2001)  &
                   'well iteration iteration mass flow  riser inlet ',  &
                   '   riser inlet   riser outlet riser outlet',  &
                   'no.     #1       #2       rate        pressure ',  &
                   '   temperature  pressure        temperature',  &
                   '                        (kg/s)        (Pa)     ',  &
                   '    (Deg.C)    (Pa)             (Deg.C)', dots
              WRITE(logline1,2032) iwel,itrn1,itrn2,uqwmr,p00,t00,pwrend,twrend
              status = RM_LogMessage(rm_id, logline1)
              WRITE(fuwel,2002) iwel,itrn1,itrn2,uqwmr,p00,t00,pwrend,twrend
           END IF
           IF(ABS(pwrend-upwkt) > tolfpw*upwkt) THEN
              upwkt = pwrend
              itrn2 = itrn2+1
              IF(itrn2 > mxitqw) GO TO 170
              GO TO 80
           END IF
           upwkt = pwrend
        END IF
     END IF
     ! ... Calculate fluid mass flow rate, store enthalpy, temperature,
     ! ...       mass fraction
150  qwm(iwel) = 0._kdp
     DO  ks=1,nks
        qwm(iwel) = qwm(iwel)+qflyr(iwel,ks)
     END DO
     pwkt(iwel) = upwkt
     ! ... Production or injection well
     xp%cwkt(iwel) = ucwkt
     xp%cwk(iwel,nks) = ucwkt
     ! ... Test for production concentration greater than specified limit
     IF((awqm == 12 .OR. awqm == 13) .AND. iwfss > 0) THEN
        IF(xp%cwkt(iwel) > 0.8*xp%cwkts(iwel)) THEN
           !...              priwel = 1.
           cwatch = .TRUE.
        END IF
        IF(xp%cwkt(iwel) > xp%cwkts(iwel)) THEN
           qwv(iwel) = 0.
           nshut = nshut+1
           jwell(nshut) = iwel
           !!$     priwel = my_itime+1
           cwatch = .FALSE.
           GO TO 10
        END IF
     END IF
     CYCLE
170  CONTINUE
     WRITE(fuwel,9005) 'Well No. ',iwel,'calculation for WELLSR, ITIME =',my_itime
9005 FORMAT(tr10,a,i3,A,i5)
     WRITE(logline1,9015) 'Well No. ',iwel,'calculation for WELLSR, ITIME =',my_itime
9015 FORMAT(a,i3,a,i5)
     status = RM_LogMessage(rm_id, logline1)
     errexe = .TRUE.
180  CONTINUE
     WRITE(fuwel,9005)  &
          'Well No. ',iwel,' did not converge on density in WELLSR', '; ITIME =',my_itime
     WRITE(logline1,9015) 'Well No. ',iwel,' did not converge on  density in WELLSR',  &
          '; ITIME =',my_itime
     status = RM_ErrorMessage(rm_id, logline1)
     errexe = .TRUE.
  END DO
  ! ... End of well loop
!!$  IF(nshut > 0) THEN
!!$     WRITE(fuwel,9006) cnvtmi*time,'(',unittm,')', (jwell(i),i=1,nshut)
!!$9006 FORMAT(//tr20,'Time  = ',1PG10.4,tr2,3A/tr10,  &
!!$          'The following wells were shut in due to net flow '/tr25,  &
!!$          'reversal or due to reservoir pressure too'/tr25,  &
!!$          'low (high) relative to bore hole pressure for ',  &
!!$          'prodution (injection)'/tr25,  &
!!$          'or production concentration limit reached'/(tr30,25I4))
!!$     WRITE(logline1,8016) 'Time =',cnvtmi*time,'  ('//unittm//')'
!!$8016 format(a,1pg10.4,a)
!!$     WRITE(logline2,8017) 'The following wells were shut in due to net flow '
!!$8017 format(a)
!!$     WRITE(logline3,8017) '          reversal or due to reservoir pressure too' 
!!$     WRITE(logline4,8017) '          low (high) relative to bore hole pressure '//  &
!!$          'for prodution (injection)'
!!$     WRITE(logline5,8017) '          or production concentration limit reached'
!!$     WRITE(logline6,8018) (jwell(i),i=1,nshut)
!!$8018 format(25i4)
!!$     status = RM_WarningMessage(rm_id, logline1)
!!$     status = RM_WarningMessage(rm_id, logline2)
!!$     status = RM_WarningMessage(rm_id, logline3)
!!$     status = RM_WarningMessage(rm_id, logline4)
!!$     status = RM_WarningMessage(rm_id, logline5)
!!$     status = RM_WarningMessage(rm_id, logline6)
!!$  END IF
  DEALLOCATE (jwell, mobw,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, XP_wellsr"  
     STOP  
  ENDIF
  RETURN
200 CONTINUE
  WRITE(fuwel,9005) 'Well no. ',iwel,' has all zero mobility factors; WELLSR, ITIME =',my_itime
  WRITE(logline1,9015) 'Well no. ',iwel,' has all zero mobility factors; WELLSR, ITIME =',my_itime
  status = RM_ErrorMessage(rm_id, logline1)
  DEALLOCATE (jwell, mobw,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, XP_wellsr"
     STOP  
  ENDIF
END SUBROUTINE XP_wellsr

