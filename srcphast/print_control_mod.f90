MODULE print_control_mod
  ! ... Sets the print control flag and stop sign for a given output file
  USE machine_constants, ONLY: kdp
  USE mcv, ONLY: deltim
  USE mcp, ONLY: cnvtmi
  IMPLICIT NONE
  INTERFACE print_control
     MODULE PROCEDURE print_control_l, print_control_i
  END INTERFACE
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80), PRIVATE :: ident_string=  &
       '$Id$'
  !     ------------------------------------------------------------------


  TYPE :: PrintControl
     LOGICAL :: print
     INTEGER :: print_int, next_time
     REAL(KIND=kdp) :: freq, time_print
  END TYPE PrintControl

  TYPE (PrintControl) print_restart

  PRIVATE :: print_control_l, print_control_i

CONTAINS

  SUBROUTINE pc_initialize(pc)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    ! ...
    pc%print = .false.
    pc%print_int = 0
    pc%freq = 0.0
    pc%time_print = 0.0
  END SUBROUTINE pc_initialize

  SUBROUTINE pc_reset(pc)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    ! ...
    pc%print = .false.
    pc%print_int = 0
  END SUBROUTINE pc_reset

  SUBROUTINE pc_set(pc, utime, itime, timchg)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    INTEGER, INTENT(IN) :: itime
    REAL(KIND=kdp), INTENT(IN) :: timchg, utime
    ! ... freq = prislm = privar
    ! ... time_print = timprslm = timprvar
    ! ... transient = prslm = prvar
    pc%print = .false.
    pc%print_int = 0
    IF (pc%freq > 0.0_kdp) THEN
       IF(ABS(pc%time_print-utime) <= .01_kdp*deltim*cnvtmi) THEN
          pc%print=.TRUE.
       END IF
    ELSE IF(pc%freq < 0._kdp) THEN
       IF(MOD(itime,INT(ABS(pc%freq))) == 0) pc%print=.TRUE.
    END IF
    IF(utime >= timchg) then
       pc%print=.TRUE.
    ENDIF
    if (pc%print) pc%print_int = 1
  END SUBROUTINE pc_set

  SUBROUTINE pc_set_time_print_init(pc, utime, utimchg)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    REAL(KIND=kdp), INTENT(IN) ::  utimchg, utime

    if (pc%freq > 0._kdp) THEN
       pc%time_print = (1._kdp+INT(utime/pc%freq))*pc%freq
    ELSE 
       pc%time_print = utimchg
    ENDIF
  END SUBROUTINE pc_set_time_print_init

  SUBROUTINE pc_set_time_print(pc, utime)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    REAL(KIND=kdp), INTENT(IN) :: utime

    IF(pc%print .AND. pc%freq > 0._kdp) THEN
       pc%time_print=(1._kdp+INT(utime/pc%freq))*pc%freq
    END IF
  END SUBROUTINE pc_set_time_print

  SUBROUTINE print_control_l(privar,utime,itime,timchg,timprvar,prvar)
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: itime
    REAL(KIND=kdp), INTENT(IN) :: privar, timchg, utime
    REAL(KIND=kdp), INTENT(INOUT) :: timprvar
    LOGICAL, INTENT(OUT) :: prvar
    ! ...
    prvar = .false.
    IF(privar > 0._kdp) THEN
       !     IF(ABS(timprvar-utime) <= 3.e-6_kdp) THEN
       IF(ABS(timprvar-utime) <= .01_kdp*deltim*cnvtmi) THEN
          prvar=.TRUE.
!!$          IF(reset) timprvar=(1._kdp+INT(utime/privar))*privar
       END IF
    ELSE IF(privar < 0._kdp) THEN
       IF(MOD(itime,INT(ABS(privar))) == 0) prvar=.TRUE.
    END IF
    IF(utime >= timchg) prvar=.TRUE.
  END SUBROUTINE print_control_l

  SUBROUTINE print_control_i(privar,utime,itime,timchg,timprvar,prvar)
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: itime
    REAL(KIND=kdp), INTENT(IN) :: privar, timchg, utime
    REAL(KIND=kdp), INTENT(INOUT) :: timprvar
!!$    LOGICAL, INTENT(IN) :: reset
    INTEGER, INTENT(OUT) :: prvar
    ! ...
    prvar = 0
    IF(privar > 0._kdp) THEN
       !     IF(ABS(timprvar-utime) <= 3.e-6_kdp) THEN
       IF(ABS(timprvar-utime) <= .01_kdp*deltim*cnvtmi) THEN
          prvar = 1
!!$          IF(reset) timprvar=(1._kdp+INT(utime/privar))*privar
       END IF
    ELSE IF(privar < 0._kdp) THEN
       IF(MOD(itime,INT(ABS(privar))) == 0) prvar = 1
    END IF
    IF(utime >= timchg) prvar = 1
  END SUBROUTINE print_control_i

END MODULE print_control_mod
