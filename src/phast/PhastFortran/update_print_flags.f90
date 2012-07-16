SUBROUTINE update_print_flags
  ! ... Updates the print control flags to the next times for printout when
  ! ...     printout is by user time interval
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE mcc
  USE mcc_m
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE print_control_mod
  IMPLICIT NONE
  REAL(KIND=kdp) :: utime, udeltim, utimchg
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  utime=cnvtmi*time*one_plus_eps
  !....UTIME is in user time marching units
  udeltim=cnvtmi*deltim
  ! ... UDELTIM is in user time marching units
  ! ... TIMPRTNXT is in user time marching units
  utimchg=cnvtmi*timchg
  ! ... UTIMCHG is in user time marching units
  ! ... Set table print flags as requested
  ! ... Solution method data
!!$  IF(prslm .AND. prislm > 0._kdp) THEN
!!$     timprslm=(1._kdp+INT(utime/prislm))*prislm
!!$  END IF
!!$  CALL pc_set_print_time(print_restart, utime)
!!$  ! ... P,C tables of dependent variables in the cells
!!$  IF(prp .AND. prip > 0._kdp) THEN
!!$     timprp=(1._kdp+INT(utime/prip))*prip
!!$  END IF
!!$  IF(prc .AND. pric > 0._kdp) THEN
!!$     timprc=(1._kdp+INT(utime/pric))*pric
!!$  END IF
!!$  ! ... Global flow balance tables
!!$  IF(prgfb .AND. prigfb > 0._kdp) THEN
!!$     timprgfb=(1._kdp+INT(utime/prigfb))*prigfb
!!$  END IF
!!$  ! ... B.C. flow rates
!!$  IF(prbcf .AND. pribcf > 0._kdp) THEN
!!$     timprbcf=(1._kdp+INT(utime/pribcf))*pribcf
!!$  END IF
!!$  IF(nwel > 0) THEN
!!$     ! ... Well summary
!!$     IF(prwel .AND. priwel > 0._kdp) THEN
!!$        timprwel=(1._kdp+INT(utime/priwel))*priwel
!!$     END IF
!!$     ! ... Well time series plot data
!!$     IF(prtem .AND. pri_well_timser > 0._kdp) THEN
!!$        timprtem=(1._kdp+INT(utime/pri_well_timser))*pri_well_timser
!!$     END IF
!!$  END IF
!!$  IF(prkd .AND. prikd > 0._kdp) THEN
!!$      timprkd = (1._kdp+INT(utime/prikd))*prikd
!!$  END IF
!!$  IF(prvel .AND. privel > 0._kdp) THEN
!!$     timprvel=(1._kdp+INT(utime/privel))*privel
!!$  END IF
!!$  IF(cntmapc) THEN
!!$     IF(prmapc .AND. primapcomp > 0._kdp) THEN
!!$        timprmapc=(1._kdp+INT(utime/primapcomp))*primapcomp
!!$     END IF
!!$  END IF
!!$  IF(cntmaph .AND. .NOT.steady_flow) THEN
!!$     IF(prmaph .AND. primaphead > 0._kdp) THEN
!!$        timprmaph=(1._kdp+INT(utime/primaphead))*primaphead
!!$     END IF
!!$  END IF
!!$  IF(vecmap .AND. .NOT.steady_flow) THEN
!!$     IF(prmapv .AND. primapv > 0._kdp) THEN
!!$        timprmapv=(1._kdp+INT(utime/primapv))*primapv
!!$     END IF
!!$  END IF
!!$  IF(prcphrq .AND. pricphrq > 0._kdp) THEN
!!$     timprcphrq = (1._kdp+INT(utime/pricphrq))*pricphrq
!!$  END IF
!!$  IF(prf_chem_phrq .AND. priforce_chem_phrq > 0._kdp) THEN
!!$     timprfchem = (1._kdp+INT(utime/priforce_chem_phrq))*priforce_chem_phrq
!!$  END IF
!!$  IF(prhdfc .AND. prihdf_conc > 0._kdp) THEN
!!$     timprhdfcph = (1._kdp+INT(utime/prihdf_conc))*prihdf_conc
!!$  END IF
!!$  IF(prhdfh .AND. prihdf_head > 0._kdp) THEN
!!$     timprhdfh = (1._kdp+INT(utime/prihdf_head))*prihdf_head
!!$  END IF
!!$  IF(prhdfv .AND. prihdf_vel > 0._kdp) THEN
!!$     timprhdfv = (1._kdp+INT(utime/prihdf_vel))*prihdf_vel
!!$  END IF
!!$  IF(prcpd .AND. pricpd > 0._kdp) THEN
!!$     timprcpd = (1._kdp+INT(utime/pricpd))*pricpd
!!$  END IF
!!$  timprtnxt=MIN(utimchg,timprbcf, timprcpd, timprgfb, &
!!$       timprhdfh, timprhdfv, timprhdfcph,  &
!!$       timprkd, timprmapc, timprmaph, timprmapv, &
!!$       timprp, timprc, timprcphrq, timprfchem, timprslm, timprtem, timprvel, timprwel)
  CALL pc_update_print_times(utime, utimchg)
  timprtnxt = next_print_time
!  write(*,*) utime, utimchg, next_print_time, &
!       timprbcf, timprcpd, timprgfb, &
!       timprhdfh, timprhdfv, timprhdfcph,  &
!       timprkd, timprmapc, timprmaph, timprmapv, &
!       timprp, timprc, timprcphrq, timprfchem, timprslm, timprtem, timprvel, timprwel
END SUBROUTINE update_print_flags
