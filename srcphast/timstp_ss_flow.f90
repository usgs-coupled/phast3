SUBROUTINE timstp_ss_flow
  ! ... Calculates the change in time step for automatic time step control
  ! ...      or print time control
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE f_units
  USE mcc
  USE mcch, ONLY: unittm
  USE mcp
  USE mcv
  USE mcw
  USE print_control_mod
  IMPLICIT NONE
  INTRINSIC nint
  REAL(KIND=kdp) :: adp, uctc, udtim, uptc, utime, utimchg, uttc
  CHARACTER(LEN=130) :: logline1, logline0='    '
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Update time step counter
  itime=itime+1
  WRITE(*,3001) 'Beginning steady state time step no. ',itime
3001 FORMAT(/a,i6)
  WRITE(logline1,5011) 'Beginning steady state time step no. ',itime
5011 FORMAT(a,i6)
  CALL logprt_c(logline0)
  CALL logprt_c(logline1)
  jtime=jtime+1
  tsfail=.FALSE.
  ! ... Adjust the time step if automatic or print time control
  ! ... Always use automatic time step for marching to steady state flow
  IF(jtime > 2) THEN
     ! ... Automatic time step control if two steps into the new series
     !..      DTMOLD=DELTIM
     uttc=dtimmx
     uctc=dtimmx
     ! ... Pressure change control
     uptc=deltim
     ! ... Time step control from Aziz & Settari p.403
     adp=ABS(dpmax)
     adp=MAX(adp,1.d-10)
     IF(adp > dptas .OR. adp <= .9*dptas) uptc=deltim*dptas/adp
     udtim=MIN(uptc,uttc,uctc,2.*deltim,dtimmx)
     udtim=MAX(udtim,dtimmn)
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
     ! ... Make DELTIM to the nearest second ***suspended
     !..     deltim=cnvtm*deltim-MOD(cnvtm*deltim,1._kdp)
     deltim=cnvtm*deltim
  END IF
  utime=cnvtmi*(time+deltim)*one_plus_eps
  utimchg=cnvtmi*timchg
  ! ... Solution method data
  prslmi = 0
  IF(ABS(prislm) > 0._kdp) THEN
     CALL print_control(prislm,utime,itime,utimchg,timprslm,prslm)
     IF(prslm) prslmi = 1
  END IF
  IF(prtss_vel .OR. ABS(privel) > 0._kdp) THEN
     prvel = .TRUE.
     IF(ntprvel > 0) prvel = .FALSE.
  END IF
  IF(prtss_mapvel .OR. ABS(primapv) > 0._kdp) THEN
     prmapv = .TRUE.
     IF(ntprmapv > 0) prmapv = .FALSE.
  END IF
  prhdfvi = 0
  IF(prtsshdf_vel .OR. ABS(prihdf_vel) > 0._kdp) THEN
     prhdfv = .TRUE.
     prhdfvi = 1
     IF(ntprhdfv > 0) prhdfv = .FALSE.
  END IF
  ! ... Fluid conductances
  IF(prt_kd .OR. ABS(prikd) > 0._kdp) THEN
     prkd = .TRUE.
     IF(ntprkd > 0) prkd = .FALSE.
  END IF
  IF(prslm) THEN
     WRITE(*,3002) 'Current time step length ..........', cnvtmi*deltim,'('//TRIM(unittm)//')'
3002 FORMAT(tr5,a,1PG12.3,tr1,a)
     WRITE(logline1,5001) '     Current time step length .........................'//  &
          '..........',cnvtmi*deltim,' ('//TRIM(unittm)//')'
5001 FORMAT(a,1PG12.3,a)
     CALL logprt_c(logline1)
  ENDIF
END SUBROUTINE timstp_ss_flow
