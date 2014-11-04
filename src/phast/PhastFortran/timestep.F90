SUBROUTINE timestep
  ! ... Calculates the change in time step for automatic time step control
  ! ...      or print time control
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE mcc
  USE mcc_m
  USE mcch, ONLY: unittm
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
#if defined(USE_MPI)
  USE mpi_mod
#endif
  USE print_control_mod
  USE PhreeqcRM
  IMPLICIT NONE
  !INCLUDE "RM_interface_F.f90.inc"
  INTRINSIC NINT
  REAL(KIND=kdp) :: adc, adp, adt, uctc, udtim, uptc, utime, uttc, udeltim, utimchg
  INTEGER :: iis
#ifdef USE_MPI
  INTEGER, DIMENSION(2) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(2) :: array_bcst_r
#endif
  CHARACTER(LEN=130) :: logline1, logline0='    '
  INTEGER :: status
  !     ------------------------------------------------------------------
  !...
  ! ... Update time step counter
#ifdef USE_MPI  
  if (mpi_myself == 0) then
    CALL MPI_BCAST(METHOD_TIMESTEPWORKER, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
  endif
#endif   
  itime = itime+1

  WRITE(logline1,5011) 'Beginning time step no. ',itime
5011 FORMAT(a,i6)
  status = RM_LogMessage(rm_id, logline0)
  status = RM_LogMessage(rm_id, logline1)
  status = RM_ScreenMessage(rm_id, logline0)
  status = RM_ScreenMessage(rm_id, logline1)

  jtime = jtime+1

#ifdef USE_MPI
  !*** broadcast itime, jtime
  IF (solute) THEN   
     array_bcst_i(1) = itime; array_bcst_i(2) = jtime     
     CALL MPI_BCAST(array_bcst_i, 2, MPI_INTEGER, manager,  &
          xp_comm, ierrmpi)
  ENDIF
#endif
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
     END IF
     deltim=cnvtm*deltim
  END IF
  utime=cnvtmi*(time+deltim)
  ! ... UTIME is in user time marching units
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
     STOP 'ERROR: Zero deltim in timestep.'
  ENDIF
#ifdef USE_MPI
  if (solute) then
     CALL MPI_BCAST(deltim, 1, MPI_DOUBLE_PRECISION, manager, xp_comm, ierrmpi)
     CALL MPI_BCAST(time, 1, MPI_DOUBLE_PRECISION, manager, xp_comm, ierrmpi)
  endif
#endif
  utime=cnvtmi*(time+deltim)*one_plus_eps
  ! ... Set table print flags as requested 
  CALL pc_set_print_flags(utime, itime, utimchg)
  IF(print_progress_statistics%print_flag) THEN
     !$$     WRITE(*,3002) 'Current time step length ..........', cnvtmi*deltim,'('//TRIM(unittm)//')'
     !$$3002 FORMAT(tr5,a,1PG12.3,tr1,a)
     WRITE(logline1,5001) '     Current time step length .........................'//  &
          '..........',cnvtmi*deltim,' ('//TRIM(unittm)//')'
5001 FORMAT(a,1PG12.3,a)
     status = RM_LogMessage(rm_id, logline1)
     status = RM_ScreenMessage(rm_id, logline1)
  ENDIF
END SUBROUTINE timestep
