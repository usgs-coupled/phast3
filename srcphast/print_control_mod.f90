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
       '$RCSfile: print_control_mod.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------

  PRIVATE :: print_control_l, print_control_i

CONTAINS

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
