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
     LOGICAL :: print_flag, keep_file, once, initial
     INTEGER :: print_flag_integer
     REAL(KIND=kdp) :: print_interval, print_time
  END TYPE PrintControl

  TYPE (PrintControl) &
       print_progress_statistics,  &
       print_components, print_global_flow_balance, print_bc_flows, print_wells, &
       print_conductances, print_heads, print_velocities, print_force_chemistry, &
       print_hdf_chemistry, print_xyz_components, print_hdf_heads, print_hdf_velocities, &
       print_xyz_chemistry, print_xyz_heads, print_xyz_velocities, print_xyz_wells, &
       print_restart, print_restart_hst

  LOGICAL print_end_of_period
  DOUBLE PRECISION next_print_time

  PRIVATE :: print_control_l, print_control_i

CONTAINS

  SUBROUTINE pc_initialize()
    IMPLICIT NONE
    ! ...
    CALL pc_init(print_progress_statistics, .false.)
    CALL pc_init(print_components, .false.)
    CALL pc_init(print_global_flow_balance, .false.)
    CALL pc_init(print_bc_flows, .false.)
    CALL pc_init(print_wells, .false.)
    CALL pc_init(print_conductances, .false.)
    CALL pc_init(print_heads, .true.)
    CALL pc_init(print_velocities, .true.)
    CALL pc_init(print_force_chemistry, .false.)
    CALL pc_init(print_hdf_chemistry, .false.)
    CALL pc_init(print_xyz_components, .false.)
    CALL pc_init(print_hdf_heads, .true.)
    CALL pc_init(print_hdf_velocities, .true.)
    CALL pc_init(print_xyz_chemistry, .false.)
    CALL pc_init(print_xyz_heads, .true.)
    CALL pc_init(print_xyz_velocities, .true.)
    CALL pc_init(print_xyz_wells, .false.)
    CALL pc_init(print_restart, .false.)
    CALL pc_init(print_restart_hst, .false.)
    
  END SUBROUTINE pc_initialize


  SUBROUTINE pc_init(pc, once)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    LOGICAL :: once
    ! ...
    pc%print_flag = .false.
    pc%keep_file = .false.
    pc%once = once
    pc%initial = .false.
    pc%print_flag_integer = 0
    pc%print_interval = 0.0
    pc%print_time = 0.0

  END SUBROUTINE pc_init

  SUBROUTINE pc_reset(pc)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    ! ...
    pc%print_flag = .false.
    pc%print_flag_integer = 0

  END SUBROUTINE pc_reset

  SUBROUTINE pc_set_print_flag(pc, utime, itime, utimchg)  ! timstp.f90
    USE mcc
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    INTEGER, INTENT(IN) :: itime
    REAL(KIND=kdp), INTENT(IN) :: utimchg, utime
    ! ... print_interval = prislm = privar
    ! ... print_time = timprslm = timprvar
    ! ... transient = prslm = prvar
    pc%print_flag = .false.
    pc%print_flag_integer = 0
    ! print interval is in time units
    IF (pc%print_interval > 0.0_kdp) THEN
       IF(ABS(pc%print_time-utime) <= .01_kdp*deltim*cnvtmi) THEN
          pc%print_flag=.TRUE.
       END IF
    ! print interval is in steps
    ELSE IF(pc%print_interval < 0._kdp) THEN
       IF(MOD(itime,INT(ABS(pc%print_interval))) == 0) pc%print_flag=.TRUE.
    END IF
    ! logic for end of simulation period
    IF((utime >= utimchg) .and. (pc%print_interval /= 0) .and. print_end_of_period) then
       pc%print_flag=.TRUE.
    ENDIF
    ! logic for one time printing
    if (steady_flow .and. pc%once) then
    endif

    if (pc%print_flag) pc%print_flag_integer = 1

  END SUBROUTINE pc_set_print_flag

  SUBROUTINE pc_set_print_time_init3(pc, utime, utimchg)  ! init3
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    REAL(KIND=kdp), INTENT(IN) ::  utimchg, utime

    if (pc%print_interval > 0._kdp) THEN
       pc%print_time = (1._kdp+INT(utime/pc%print_interval))*pc%print_interval
    ELSE 
       pc%print_time = utimchg
    ENDIF
  END SUBROUTINE pc_set_print_time_init3

  SUBROUTINE pc_set_print_time(pc, utime)  ! update_print_flags
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    REAL(KIND=kdp), INTENT(IN) :: utime

    IF(pc%print_flag .AND. pc%print_interval > 0._kdp) THEN
       pc%print_time=(1._kdp+INT(utime/pc%print_interval))*pc%print_interval
    END IF
  END SUBROUTINE pc_set_print_time

  SUBROUTINE pc_set_next_print_time(utimchg)
    IMPLICIT NONE
    REAL(KIND=kdp), INTENT(IN) :: utimchg
    next_print_time = MIN(utimchg, &
              print_progress_statistics%print_time,  &
              print_components%print_time, &
              print_global_flow_balance%print_time, &
              print_bc_flows%print_time, &
              print_wells%print_time, &
              print_conductances%print_time, &
              print_heads%print_time, &
              print_velocities%print_time, &
              print_force_chemistry%print_time, &
              print_hdf_chemistry%print_time, &
              print_xyz_components%print_time, &
              print_hdf_heads%print_time, &
              print_hdf_velocities%print_time, &
              print_xyz_chemistry%print_time, &
              print_xyz_heads%print_time, &
              print_xyz_velocities%print_time, &
              print_xyz_wells%print_time, &
              print_restart%print_time, &
              print_restart_hst%print_time)
  END SUBROUTINE pc_set_next_print_time

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
