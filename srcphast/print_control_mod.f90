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
     CHARACTER*30 name
     LOGICAL :: print_flag, once, initial, in
     INTEGER :: print_flag_integer, count_prints
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
  LOGICAL initial_porous_media, initial_fluid_properties, initial_bc, initial_progress_statistics, &
       initial_wells, initial_conductances, initial_components, initial_xyz_components, initial_heads, &
       initial_xyz_heads, initial_ss_velocities, initial_xyz_velocities, initial_xyz_chemistry, &
       initial_force_chemistry, initial_hdf_chemistry, initial_hdf_heads, initial_ss_hdf_velocities, &
       initial_xyz_wells
  
  LOGICAL print_bc

  PRIVATE :: print_control_l, print_control_i

CONTAINS

  SUBROUTINE pc_initialize()
    USE mcc, only: solute
    USE mcw, only: nwel
    IMPLICIT NONE
    ! ...
    CALL pc_init(print_progress_statistics, .false., "print_progress_statistics")
    CALL pc_init(print_components, .false., "print_components")
    CALL pc_init(print_force_chemistry, .false., "print_force_chemistry")
    CALL pc_init(print_hdf_chemistry, .false., "print_hdf_chemistry")
    CALL pc_init(print_xyz_components, .false., "print_xyz_components")
    CALL pc_init(print_xyz_chemistry, .false., "print_xyz_chemistry")
    CALL pc_init(print_restart, .false., "print_restart")
    CALL pc_init(print_wells, .false., "print_wells")
    CALL pc_init(print_xyz_wells, .false., "print_xyz_wells")
    CALL pc_init(print_global_flow_balance, .false., "print_global_flow_balance")
    CALL pc_init(print_bc_flows, .false., "print_bc_flows")
    CALL pc_init(print_conductances, .false., "print_conductances")
    CALL pc_init(print_heads, .true., "print_heads")
    CALL pc_init(print_velocities, .true., "print_velocities")
    CALL pc_init(print_hdf_heads, .true., "print_hdf_heads")
    CALL pc_init(print_hdf_velocities, .true., "print_hdf_velocities")
    CALL pc_init(print_xyz_heads, .true., "print_xyz_heads")
    CALL pc_init(print_xyz_velocities, .true., "print_xyz_velocities")
    CALL pc_init(print_restart_hst, .false., "print_restart_hst")
    if (.not. solute) then
       CALL pc_out(print_components)
       CALL pc_out(print_force_chemistry)
       CALL pc_out(print_hdf_chemistry)
       CALL pc_out(print_xyz_components)
       CALL pc_out(print_xyz_chemistry) 
       CALL pc_out(print_restart)
    endif
    if (nwel <= 0) then
       CALL pc_out(print_wells)
    endif
    if (.not. solute) then
       CALL pc_out(print_xyz_wells)
    endif
    CALL pc_out(print_restart_hst)
    
  END SUBROUTINE pc_initialize

  SUBROUTINE pc_init(pc, once, string)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    LOGICAL :: once
    CHARACTER(*) :: string
    ! ...
    pc%name = string
    pc%print_flag = .false.
    pc%count_prints = 0
    pc%once = once
    pc%initial = .false.
    pc%print_flag_integer = 0
    pc%print_interval = 0.0
    pc%print_time = 0.0
    pc%in = .true.

  END SUBROUTINE pc_init

  SUBROUTINE pc_out(pc)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    ! ...
    pc%print_flag = .false.
    pc%count_prints = 0
    pc%once = .false.
    pc%initial = .false.
    pc%print_flag_integer = 0
    pc%print_interval = 0.0
    pc%print_time = 0.0
    pc%in = .false.
  END SUBROUTINE pc_out

  SUBROUTINE pc_set_print_flags(utime, itime, utimchg)  
    USE mcc
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: itime
    REAL(KIND=kdp), INTENT(IN) :: utimchg, utime
    ! timstp.f90
    call pc_hst2mod
!    write(*,*) "Before set print flags ", utime, itime, utimchg
!    call pc_dump_all
    CALL pc_set_print_flag(print_progress_statistics, utime, itime, utimchg)
    CALL pc_set_print_flag(print_components, utime, itime, utimchg)
    CALL pc_set_print_flag(print_global_flow_balance, utime, itime, utimchg)
    CALL pc_set_print_flag(print_bc_flows, utime, itime, utimchg)
    CALL pc_set_print_flag(print_wells, utime, itime, utimchg)
    CALL pc_set_print_flag(print_conductances, utime, itime, utimchg)
    IF(itime == 1 .AND. prt_kd) THEN
       print_conductances%print_flag = .TRUE.
!       prkd = .TRUE.
!       timprkd = utimchg
    endif
    CALL pc_set_print_flag(print_heads, utime, itime, utimchg)
    CALL pc_set_print_flag(print_velocities, utime, itime, utimchg)
    CALL pc_set_print_flag(print_force_chemistry, utime, itime, utimchg)
    CALL pc_set_print_flag(print_hdf_chemistry, utime, itime, utimchg)
    CALL pc_set_print_flag(print_xyz_components, utime, itime, utimchg)
    CALL pc_set_print_flag(print_hdf_heads, utime, itime, utimchg)
    CALL pc_set_print_flag(print_hdf_velocities, utime, itime, utimchg)
    CALL pc_set_print_flag(print_xyz_chemistry, utime, itime, utimchg)
    CALL pc_set_print_flag(print_xyz_heads, utime, itime, utimchg)
    CALL pc_set_print_flag(print_xyz_velocities, utime, itime, utimchg)
    CALL pc_set_print_flag(print_xyz_wells, utime, itime, utimchg)
    CALL pc_set_print_flag(print_restart, utime, itime, utimchg)
    CALL pc_set_print_flag(print_restart_hst, utime, itime, utimchg)
!    write(*,*) "After set print flags"
!    call pc_dump_all
    call pc_mod2hst
    
  END SUBROUTINE pc_set_print_flags

  SUBROUTINE pc_set_print_flag(pc, utime, itime, utimchg)  ! timstp.f90
    USE mcc
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    INTEGER, INTENT(IN) :: itime
    REAL(KIND=kdp), INTENT(IN) :: utimchg, utime
    ! ... 
    if (.not. pc%in) return
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
    if (steady_flow .and. pc%once .and. pc%print_flag .and. (pc%count_prints > 0)) then
       pc%print_flag = .false.
    endif

    if (pc%print_flag) pc%print_flag_integer = 1

  END SUBROUTINE pc_set_print_flag

  SUBROUTINE pc_mod2hst
    USE mcc
    IMPLICIT NONE
    ! 
    prslm = print_progress_statistics%print_flag
    prslmi = print_progress_statistics%print_flag_integer
    prislm = print_progress_statistics%print_interval    
    timprslm = print_progress_statistics%print_time

    prp = print_heads%print_flag
    prip = print_heads%print_interval
    timprp = print_heads%print_time
    ntprp = print_heads%count_prints

    prc = print_components%print_flag
    pric = print_components%print_interval
    timprc = print_components%print_time
    ntprc = print_components%count_prints

    prgfb = print_global_flow_balance%print_flag
    prigfb = print_global_flow_balance%print_interval
    timprgfb = print_global_flow_balance%print_time
    ntprgfb = print_global_flow_balance%count_prints

    prbcf = print_bc_flows%print_flag
    pribcf = print_bc_flows%print_interval
    timprbcf = print_bc_flows%print_time
    ntprbcf = print_bc_flows%count_prints

    prwel = print_wells%print_flag
    priwel = print_wells%print_interval
    timprwel = print_wells%print_time
    ntprwel = print_wells%count_prints

    prtem = print_xyz_wells%print_flag
    pri_well_timser = print_xyz_wells%print_interval
    timprtem = print_xyz_wells%print_time
    ntprtem = print_xyz_wells%count_prints

    prkd = print_conductances%print_flag
    prikd = print_conductances%print_interval
    timprkd = print_conductances%print_time
    ntprkd = print_conductances%count_prints

    prvel = print_velocities%print_flag
    privel = print_velocities%print_interval
    timprvel = print_velocities%print_time
    ntprvel = print_velocities%count_prints

!    cntmapc = print_xyz_components%print_flag
    prmapc = print_xyz_components%print_flag
    primapcomp = print_xyz_components%print_interval
    timprmapc = print_xyz_components%print_time
    ntprmapcomp = print_xyz_components%count_prints

!    cntmaph = print_xyz_heads%print_flag
    prmaph = print_xyz_heads%print_flag
    primaphead = print_xyz_heads%print_interval
    timprmaph = print_xyz_heads%print_time
    ntprmaphead = print_xyz_heads%count_prints

    vecmap = print_xyz_velocities%print_flag
    prmapv = print_xyz_velocities%print_flag
    primapv = print_xyz_velocities%print_interval
    timprmapv = print_xyz_velocities%print_time
    ntprmapv = print_xyz_velocities%count_prints

    prcphrq = print_xyz_chemistry%print_flag
    pricphrq = print_xyz_chemistry%print_interval
    timprcphrq = print_xyz_chemistry%print_time
    prcphrqi = print_xyz_chemistry%print_flag_integer

    prf_chem_phrq = print_force_chemistry%print_flag
    priforce_chem_phrq = print_force_chemistry%print_interval
    timprfchem = print_force_chemistry%print_time
    prf_chem_phrqi = print_force_chemistry%print_flag_integer

    prhdfc = print_hdf_chemistry%print_flag
    prihdf_conc = print_hdf_chemistry%print_interval
    timprhdfcph = print_hdf_chemistry%print_time
    prhdfci = print_hdf_chemistry%print_flag_integer

    prhdfh = print_hdf_heads%print_flag
    prihdf_head = print_hdf_heads%print_interval
    timprhdfh = print_hdf_heads%print_time
    ntprhdfh = print_hdf_heads%count_prints
    prhdfhi = print_hdf_heads%print_flag_integer

    prhdfv = print_hdf_velocities%print_flag
    prihdf_vel = print_hdf_velocities%print_interval
    timprhdfv = print_hdf_velocities%print_time
    ntprhdfv = print_hdf_velocities%count_prints
    prhdfvi = print_hdf_velocities%print_flag_integer

    prcpd = print_restart_hst%print_flag
    pricpd = print_restart_hst%print_interval
    timprcpd = print_restart_hst%print_time
    ntprcpd = print_restart_hst%count_prints
  END SUBROUTINE pc_mod2hst

  SUBROUTINE pc_hst2mod
    USE mcc
    IMPLICIT NONE
    ! 
    print_progress_statistics%print_flag = prslm
    print_progress_statistics%print_flag_integer = prslmi
    print_progress_statistics%print_interval     = prislm
    print_progress_statistics%print_time = timprslm

    print_heads%print_flag = prp
    print_heads%print_interval = prip
    print_heads%print_time = timprp
    print_heads%count_prints = ntprp

    print_components%print_flag = prc
    print_components%print_interval = pric
    print_components%print_time = timprc
    print_components%count_prints = ntprc

    print_global_flow_balance%print_flag = prgfb
    print_global_flow_balance%print_interval = prigfb
    print_global_flow_balance%print_time = timprgfb
    print_global_flow_balance%count_prints = ntprgfb

    print_bc_flows%print_flag = prbcf
    print_bc_flows%print_interval = pribcf
    print_bc_flows%print_time = timprbcf
    print_bc_flows%count_prints = ntprbcf

    print_wells%print_flag = prwel
    print_wells%print_interval = priwel
    print_wells%print_time = timprwel
    print_wells%count_prints = ntprwel

    print_xyz_wells%print_flag = prtem
    print_xyz_wells%print_interval = pri_well_timser
    print_xyz_wells%print_time = timprtem
    print_xyz_wells%count_prints = ntprtem

    print_conductances%print_flag = prkd
    print_conductances%print_interval = prikd
    print_conductances%print_time = timprkd
    print_conductances%count_prints = ntprkd

    print_velocities%print_flag = prvel
    print_velocities%print_interval = privel
    print_velocities%print_time = timprvel
    print_velocities%count_prints = ntprvel

!    print_xyz_components%print_flag = cntmapc
    print_xyz_components%print_flag = prmapc
    print_xyz_components%print_interval = primapcomp
    print_xyz_components%print_time = timprmapc
    print_xyz_components%count_prints = ntprmapcomp

!    cntmaph = print_xyz_heads%print_flag 
    prmaph = print_xyz_heads%print_flag 
    print_xyz_heads%print_interval = primaphead
    print_xyz_heads%print_time = timprmaph
    print_xyz_heads%count_prints = ntprmaphead

    print_xyz_velocities%print_flag = vecmap
    print_xyz_velocities%print_flag = prmapv
    print_xyz_velocities%print_interval = primapv
    print_xyz_velocities%print_time = timprmapv
    print_xyz_velocities%count_prints = ntprmapv

    print_xyz_chemistry%print_flag = prcphrq
    print_xyz_chemistry%print_interval = pricphrq
    print_xyz_chemistry%print_time = timprcphrq
    print_xyz_chemistry%print_flag_integer = prcphrqi

    print_force_chemistry%print_flag = prf_chem_phrq
    print_force_chemistry%print_interval = priforce_chem_phrq
    print_force_chemistry%print_time = timprfchem
    print_force_chemistry%print_flag_integer = prf_chem_phrqi

    print_hdf_chemistry%print_flag = prhdfc
    print_hdf_chemistry%print_interval = prihdf_conc
    print_hdf_chemistry%print_time = timprhdfcph
    print_hdf_chemistry%print_flag_integer = prhdfci

    print_hdf_heads%print_flag = prhdfh
    print_hdf_heads%print_interval = prihdf_head
    print_hdf_heads%print_time = timprhdfh
    print_hdf_heads%count_prints = ntprhdfh
    print_hdf_heads%print_flag_integer = prhdfhi

    print_hdf_velocities%print_flag = prhdfv
    print_hdf_velocities%print_interval = prihdf_vel
    print_hdf_velocities%print_time = timprhdfv
    print_hdf_velocities%count_prints = ntprhdfv
    print_hdf_velocities%print_flag_integer = prhdfvi

    print_restart_hst%print_flag = prcpd
    print_restart_hst%print_interval = pricpd
    print_restart_hst%print_time = timprcpd
    print_restart_hst%count_prints = ntprcpd
  END SUBROUTINE pc_hst2mod

  SUBROUTINE pc_set_print_flags_error
    IMPLICIT NONE
    ! ...
    CALL pc_reset(print_heads, .true.)
    CALL pc_reset(print_global_flow_balance, .true.)
    CALL pc_reset(print_wells, .true.)
    CALL pc_reset(print_progress_statistics, .true.)

  END SUBROUTINE pc_set_print_flags_error

  SUBROUTINE pc_set_print_times(utime, utimchg)
    IMPLICIT NONE
    REAL(KIND=kdp), INTENT(IN) :: utimchg, utime
    ! ... 
    call pc_hst2mod
    next_print_time = utimchg
    CALL pc_set_print_time(print_progress_statistics, utime)
    CALL pc_set_print_time(print_components, utime)
    CALL pc_set_print_time(print_global_flow_balance, utime)
    CALL pc_set_print_time(print_bc_flows, utime)
    CALL pc_set_print_time(print_wells, utime)
    CALL pc_set_print_time(print_conductances, utime)
    CALL pc_set_print_time(print_heads, utime)
    CALL pc_set_print_time(print_velocities, utime)
    CALL pc_set_print_time(print_force_chemistry, utime)
    CALL pc_set_print_time(print_hdf_chemistry, utime)
    CALL pc_set_print_time(print_xyz_components, utime)
    CALL pc_set_print_time(print_hdf_heads, utime)
    CALL pc_set_print_time(print_hdf_velocities, utime)
    CALL pc_set_print_time(print_xyz_chemistry, utime)
    CALL pc_set_print_time(print_xyz_heads, utime)
    CALL pc_set_print_time(print_xyz_velocities, utime)
    CALL pc_set_print_time(print_xyz_wells, utime)
    CALL pc_set_print_time(print_restart, utime)
    CALL pc_set_print_time(print_restart_hst, utime)
    call pc_mod2hst
  END SUBROUTINE pc_set_print_times

  SUBROUTINE pc_set_print_time(pc, utime)  ! init3
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    REAL(KIND=kdp), INTENT(IN) :: utime
    ! ... 
    if (.not. pc%in) return
    if (pc%print_interval > 0._kdp) THEN
       pc%print_time = (1._kdp+INT(utime/pc%print_interval))*pc%print_interval
       if (pc%print_time < next_print_time) next_print_time = pc%print_time
    ENDIF
  END SUBROUTINE pc_set_print_time

  SUBROUTINE pc_update_print_times(utime, utimchg)  ! update_print_flags
    IMPLICIT NONE
    REAL(KIND=kdp), INTENT(IN) :: utimchg, utime
    call pc_hst2mod
!    write(*,*) "Before update print flags ", utime, utimchg
!    call pc_dump_all
    next_print_time = utimchg
    CALL pc_update_print_time(print_progress_statistics, utime)
    CALL pc_update_print_time(print_components, utime)
    CALL pc_update_print_time(print_global_flow_balance, utime)
    CALL pc_update_print_time(print_bc_flows, utime)
    CALL pc_update_print_time(print_wells, utime)
    CALL pc_update_print_time(print_conductances, utime)
    CALL pc_update_print_time(print_heads, utime)
    CALL pc_update_print_time(print_velocities, utime)
    CALL pc_update_print_time(print_force_chemistry, utime)
    CALL pc_update_print_time(print_hdf_chemistry, utime)
    CALL pc_update_print_time(print_xyz_components, utime)
    CALL pc_update_print_time(print_hdf_heads, utime)
    CALL pc_update_print_time(print_hdf_velocities, utime)
    CALL pc_update_print_time(print_xyz_chemistry, utime)
    CALL pc_update_print_time(print_xyz_heads, utime)
    CALL pc_update_print_time(print_xyz_velocities, utime)
    CALL pc_update_print_time(print_xyz_wells, utime)
    CALL pc_update_print_time(print_restart, utime)
    CALL pc_update_print_time(print_restart_hst, utime)
    call pc_mod2hst
!    write(*,*) "After update print flags ", utime, utimchg
!    call pc_dump_all
  END SUBROUTINE pc_update_print_times

  SUBROUTINE pc_update_print_time(pc, utime)  ! update_print_flags
    USE mcc
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    REAL(KIND=kdp), INTENT(IN) :: utime
    ! ...
    if (.not. pc%in) return
    if (steady_flow .and. pc%once .and. (pc%count_prints > 0)) return

    IF( pc%print_interval > 0._kdp) THEN
       ! if just printed, update print_time
       if (pc%print_flag) pc%print_time=(1._kdp+INT((1.0_kdp+1.e-10_kdp)*utime/pc%print_interval))*pc%print_interval
       ! find smallest print_time
       if (pc%print_time < next_print_time) next_print_time = pc%print_time
    endif
  END SUBROUTINE pc_update_print_time

  SUBROUTINE pc_dump_all
    IMPLICIT NONE
    ! ... 
    CALL pc_dump(print_progress_statistics)
    CALL pc_dump(print_components)
    CALL pc_dump(print_global_flow_balance)
    CALL pc_dump(print_bc_flows)
    CALL pc_dump(print_wells)
    CALL pc_dump(print_conductances)
    CALL pc_dump(print_heads)
    CALL pc_dump(print_velocities)
    CALL pc_dump(print_force_chemistry)
    CALL pc_dump(print_hdf_chemistry)
    CALL pc_dump(print_xyz_components)
    CALL pc_dump(print_hdf_heads)
    CALL pc_dump(print_hdf_velocities)
    CALL pc_dump(print_xyz_chemistry)
    CALL pc_dump(print_xyz_heads)
    CALL pc_dump(print_xyz_velocities)
    CALL pc_dump(print_xyz_wells)
    CALL pc_dump(print_restart)
    CALL pc_dump(print_restart_hst)
  END SUBROUTINE pc_dump_all

  SUBROUTINE pc_dump(pc)
    TYPE (PrintControl) :: pc
    write (*,*) pc%name
    write (*,*) "     print_flag ", pc%print_flag 
    write (*,*) "     once", pc%once
    write (*,*) "     initial ", pc%initial 
    write (*,*) "     in", pc%in
    write (*,*) "     print_flag_integer ", pc%print_flag_integer 
    write (*,*) "     count_prints", pc%count_prints
    write (*,*) "     print_interval", pc%print_interval
    write (*,*) "     print_time", pc%print_time
  END SUBROUTINE pc_dump

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

  SUBROUTINE pc_reset(pc, tf)
    IMPLICIT NONE
    TYPE (PrintControl) :: pc
    LOGICAL :: tf
    ! ...
    if (pc%in) then
       pc%print_flag = tf
       if (pc%print_flag) pc%print_flag_integer = 1
    endif
  END SUBROUTINE pc_reset

END MODULE print_control_mod
