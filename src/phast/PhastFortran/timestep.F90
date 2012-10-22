#include 'mpi_fix_case.h'
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
  USE mpi_struct_arrays
#endif
  USE print_control_mod
  IMPLICIT NONE
  INTRINSIC NINT
  REAL(KIND=kdp) :: adc, adp, adt, uctc, udtim, uptc, utime, uttc, udeltim, utimchg
  INTEGER :: iis
#ifdef USE_MPI
  INTEGER :: int_real_type, mpi_array_type
  INTEGER, DIMENSION(2) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(2) :: array_bcst_r
#endif
  CHARACTER(LEN=130) :: logline1, logline0='    '
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: timestep.F90,v 1.2 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Update time step counter
  itime = itime+1

  WRITE(logline1,5011) 'Beginning time step no. ',itime
5011 FORMAT(a,i6)
  CALL logprt_c(logline0)
  CALL logprt_c(logline1)
  CALL screenprt_c(logline0)
  CALL screenprt_c(logline1)

  jtime = jtime+1

#ifdef USE_MPI
  !*** broadcast itime, jtime
  IF (solute) THEN
     array_bcst_i(1) = itime; array_bcst_i(2) = jtime
     int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
     CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager,  &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(int_real_type,ierrmpi)
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
!!$        ! ... This may go away in the future. It is neat but can cause
!!$        ! ...      hunting problems
!!$        ! ... MAKE TIME STEP 1,2 OR 5*10**-N OF THE USER TIME UNIT
!!$        !..         DELTIM=10.D0**INT(LOG10(UDTIM)-1.)
!!$        !..         UDTIM=UDTIM/DELTIM
!!$        !..        IF(UDTIM.GT.1.4.AND.UDTIM.LE.3.2) THEN
!!$        !..         DELTIM=2.*DELTIM
!!$        !..         ELSEIF(UDTIM.GT.3.2.AND.UDTIM.LE.7.1) THEN
!!$        !..         DELTIM=5.*DELTIM
!!$        !..         ELSEIF(UDTIM.GT.7.1) THEN
!!$        !..         DELTIM=10.*DELTIM
!!$        !..        ENDIF
     END IF
     !!$ ... Make DELTIM to the nearest second...Will not work for large times
     !!$ ..      deltim=DBLE(INT(cnvtm*deltim))
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
     CALL MPI_BCAST(deltim, 1, MPI_DOUBLE_PRECISION, manager, world, ierrmpi)
     CALL MPI_BCAST(time, 1, MPI_DOUBLE_PRECISION, manager, world, ierrmpi)
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
     CALL logprt_c(logline1)
     CALL screenprt_c(logline1)
  ENDIF
END SUBROUTINE timestep
