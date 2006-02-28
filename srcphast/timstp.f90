SUBROUTINE timstp
  ! ... Calculates the change in time step for automatic time step control
  ! ...      or print time control
  USE machine_constants, ONLY: kdp, one_plus_eps
!!$  USE f_units
  USE mcc
  USE mcch, ONLY: unittm
  USE mcp
  USE mcv
  USE mcw
  USE print_control_mod
  IMPLICIT NONE
  INTRINSIC NINT
  REAL(KIND=kdp) :: adc, adp, adt, uctc, udtim, uptc, utime, uttc, udeltim, utimchg
  INTEGER :: iis
  CHARACTER(LEN=130) :: logline1, logline0='    '
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Update time step counter
  itime=itime+1
  WRITE(*,3001) 'Beginning time step no. ',itime
3001 FORMAT(/a,i6)
  WRITE(logline1,5011) 'Beginning time step no. ',itime
5011 FORMAT(a,i6)
  CALL logprt_c(logline0)
  CALL logprt_c(logline1)
  jtime=jtime+1
  tsfail=.FALSE.
  ! ... Restore the saved time step length if previous step was adjusted for
  ! ...      printing purposes
  IF(deltim_sav > 0._kdp) THEN
     deltim = deltim_sav
     deltim_sav = 0._kdp
  ENDIF
  ! ... Adjust the time step if automatic or print time control
  IF(autots.AND.jtime > 2) THEN
     uttc=dtimmx
     uctc=dtimmx
     ! ... Automatic time step control if two steps into the new series
     ! ... Pressure change control
     uptc=deltim
     ! ... Time step control from Aziz & Settari p.403
     adp=ABS(dpmax)
     adp=MAX(adp,1.d-10)
     IF(adp > dptas.OR.adp <= .9*dptas) uptc=deltim*dptas/adp
     ! ... Temperature change control
     IF(heat) THEN
        uttc=deltim
        adt=ABS(dtmax)
        adt=MAX(adt,1.d-10)
        IF(adt > dttas.OR.adt <= .9*dttas) uttc=deltim*dttas/adt
     END IF
     ! ... Solute mass fraction change control
     DO  iis=1,ns
        uctc=deltim
        adc=ABS(dcmax(iis))
        adc=MAX(adc,1.d-10)
        IF(adc > dctas(iis).OR.adc <= .9*dctas(iis)) uctc=MIN(uctc,deltim*dctas(iis)/adc)
     END DO
     udtim=MIN(uptc,uttc,uctc,2.*deltim,dtimmx)
     udtim=MAX(udtim,dtimmn)
     ! ... If well production concentration near limit use specified time
     ! ...      step
     !..  *** undocumented feature ***
     !..         IF(CWATCH) UDTIM=DTIMU
     ! ... If well shut in, cut back to minimum time
     IF(nshut > 0) THEN
        udtim=dtimmn
        jtime=1
     END IF
     deltim=udtim
     ! ... Put UDTIM into user time units
     udtim=cnvtmi*deltim
     IF(udtim > 1._kdp) THEN
        ! ... Use the nearest integer value of the time step (user units)
        deltim=NINT(udtim)
     ELSE
        !...special mod
        deltim=udtim
        ! ... This may go away in the future. It is neat but can cause
        ! ...      hunting problems
        ! ... MAKE TIME STEP 1,2 OR 5*10**-N OF THE USER TIME UNIT
        !..         DELTIM=10.D0**INT(LOG10(UDTIM)-1.)
        !..         UDTIM=UDTIM/DELTIM
        !..        IF(UDTIM.GT.1.4.AND.UDTIM.LE.3.2) THEN
        !..         DELTIM=2.*DELTIM
        !..         ELSEIF(UDTIM.GT.3.2.AND.UDTIM.LE.7.1) THEN
        !..         DELTIM=5.*DELTIM
        !..         ELSEIF(UDTIM.GT.7.1) THEN
        !..         DELTIM=10.*DELTIM
        !..        ENDIF
     END IF
     !c.....Make DELTIM to the nearest second...Will not work for large times
     !..      DELTIM=DBLE(INT(CNVTM*DELTIM))
     deltim=cnvtm*deltim
  END IF
  utime=cnvtmi*(time+deltim)
  !....UTIME is in user time marching units
  udeltim=cnvtmi*deltim
  ! ... UDELTIM is in user time marching units
  ! ... TIMPRTNXT is in user time marching units
  utimchg=cnvtmi*timchg
  ! ... UTIMCHG is in user time marching units
  IF(utimchg < timprtnxt) THEN
     ! ... If close to time for change, move to time for change or
     ! ...      if overshot time for change, back up
     IF(ABS(utime-utimchg) <= 0.2*udeltim .OR. utime > utimchg) THEN
        deltim_sav = deltim
        deltim = timchg-time
     END IF
  ELSE
     ! ... If close to time for printout, move to time for printout
     ! ... If overshot time for printout, back up
     ! ...   timprtnxt is in user time marching units
     IF(ABS(utime-timprtnxt) <= 0.1*udeltim .OR. utime > timprtnxt) THEN
        deltim_sav = deltim
        deltim = cnvtm*timprtnxt-time
     END IF
  END IF
  ! ... for debugging
  IF (deltim <= 0._kdp) THEN
     STOP 'ERROR: Zero deltim in timstp.'
  ENDIF
  utime=cnvtmi*(time+deltim)*one_plus_eps
  ! ... Set table print flags as requested
  ! ... Solution method data
  prslmi = 0
  IF(ABS(prislm) > 0._kdp) THEN
     CALL print_control(prislm,utime,itime,utimchg,timprslm,prslm)
     IF(prslm) prslmi = 1
  END IF
  ! ... P,C tables of dependent variables in the cells
  IF(ABS(prip) > 0._kdp .AND. .NOT.steady_flow) THEN
     CALL print_control(prip,utime,itime,utimchg,timprp,prp)
  END IF
  IF(ABS(pric) > 0._kdp) THEN
     CALL print_control(pric,utime,itime,utimchg,timprc,prc)
  END IF
  ! ... Global flow balance tables
  IF(ABS(prigfb) > 0._kdp) THEN
     CALL print_control(prigfb,utime,itime,utimchg,timprgfb,prgfb)
  END IF
  ! ... B.C. flow rates
  IF(ABS(pribcf) > 0._kdp) THEN
     CALL print_control(pribcf,utime,itime,utimchg,timprbcf,prbcf)
  END IF
  IF(nwel > 0) THEN
     ! ... Well summary
     IF(ABS(priwel) > 0._kdp) THEN
        CALL print_control(priwel,utime,itime,utimchg,timprwel,prwel)
     END IF
     ! ... Well time series plot data
     IF(ABS(pri_well_timser) > 0._kdp) THEN
        CALL print_control(pri_well_timser,utime,itime,utimchg,timprtem,prtem)
     END IF
  END IF
  IF(cntmapc) THEN
     IF(ABS(primapcomp) > 0._kdp) THEN
        CALL print_control(primapcomp,utime,itime,utimchg,timprmapc,prmapc)
     END IF
  END IF
  IF(cntmaph .AND. .NOT.steady_flow) THEN
     IF(ABS(primaphead) > 0._kdp) THEN
        CALL print_control(primaphead,utime,itime,utimchg,timprmaph,prmaph)
     END IF
  END IF
  prvel = .FALSE.
  IF(ABS(privel) > 0._kdp) THEN
     CALL print_control(privel,utime,itime,utimchg,timprvel,prvel)
     IF(steady_flow .AND. ntprvel > 0) prvel = .FALSE.
  END IF
  prmapv = .FALSE.
  IF(ABS(primapv) > 0._kdp) THEN
     CALL print_control(primapv,utime,itime,utimchg,timprmapv,prmapv)
     IF(steady_flow .AND. ntprmapv > 0) prmapv = .FALSE.
  END IF
  IF (solute) THEN
     ! ... Need write control here to pass to PHREEQC
     prcphrqi = 0     
     IF(ABS(pricphrq) > 0._kdp) THEN
        CALL print_control(pricphrq,utime,itime,utimchg,timprcphrq,prcphrq)
        IF(prcphrq) prcphrqi = 1
     END IF
     prf_chem_phrqi = 0
     IF(ABS(priforce_chem_phrq) > 0._kdp) THEN
        CALL print_control(priforce_chem_phrq,utime,itime,utimchg,timprfchem,  &
             prf_chem_phrq)
        IF(prf_chem_phrq) prf_chem_phrqi = 1
     END IF
     prhdfci = 0
     IF(ABS(prihdf_conc) > 0._kdp) THEN
        CALL print_control(prihdf_conc,utime,itime,utimchg,timprhdfcph,prhdfc)
        IF(prhdfc) prhdfci = 1
     END IF
  END IF
  IF(pricpd > 0._kdp) THEN
     CALL print_control(pricpd,utime,itime,utimchg,timprcpd,prcpd)
  END IF
  prhdfhi = 0
  IF(ABS(prihdf_head) > 0._kdp) THEN
     CALL print_control(prihdf_head,utime,itime,utimchg,timprhdfh,prhdfh)
     IF(steady_flow .AND. ntprhdfh > 0) prhdfh = .FALSE.
     IF (prhdfh) prhdfhi = 1
  END IF
  prhdfvi = 0
  prhdfv = .FALSE.
  IF(ABS(prihdf_vel) > 0._kdp) THEN
     CALL print_control(prihdf_vel,utime,itime,utimchg,timprhdfv,prhdfv)
     IF(steady_flow .AND. ntprhdfv > 0) prhdfv = .FALSE.
     IF (prhdfv) prhdfvi = 1
  END IF
  prkd = .FALSE.
  ! ... Fluid and solute conductances
  IF(itime == 1 .AND. prt_kd) THEN
     prkd = .TRUE.
     timprkd = utimchg
  ELSEIF(ABS(prikd) > 0._kdp) THEN
     CALL print_control(prikd,utime,itime,utimchg,timprkd,prkd)
  END IF
  IF(prslm) THEN
     WRITE(*,3002) 'Current time step length ..........', cnvtmi*deltim,'('//TRIM(unittm)//')'
3002 FORMAT(tr5,a,1PG12.3,tr1,a)
     WRITE(logline1,5001) '     Current time step length .........................'//  &
          '..........',cnvtmi*deltim,' ('//TRIM(unittm)//')'
5001 FORMAT(a,1PG12.3,a)
     CALL logprt_c(logline1)
  ENDIF
END SUBROUTINE timstp
