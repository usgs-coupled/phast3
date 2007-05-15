SUBROUTINE simulate_ss_flow
  ! ... Calls the routines necessary to simulate a steady-state solution
  ! ...      to the flow equation. This yields a pressure
  ! ...      (potentiometric head) solution for the initial condition for
  ! ...      the transient simulation.
  USE mcc
  USE mcp, ONLY: fdtmth, fdtmth_ssflow
  USE mcv
  USE mcw
  IMPLICIT NONE
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  !.....Start of the transient loop for marching to steady state
  logline1 = '     '
  logline2 = 'Beginning flow calculation for steady-state i.c.'
!  WRITE(*,3001) TRIM(logline2)
!3001 FORMAT(/a)  
  CALL logprt_c(logline1)
  CALL logprt_c(logline2)
  CALL screenprt_c(logline1)
  CALL screenprt_c(logline2)
  fdtmth = fdtmth_ssflow     ! ... set time differencing method to flow ss 
  DO
     CALL coeff_ss_flow
     !..  CALL write4
     CALL rhsn_ss_flow
     ! ... Read the transient data, if first pass
     IF(itime == 0) THEN
        CALL read3
        CALL init3
        CALL error3
        CALL write3_ss_flow
        IF(errexi) RETURN
     END IF
     IF(nwel > 0) THEN
        IF(cylind) THEN
           CALL wellsc_ss_flow
        ELSE
           CALL wellsr_ss_flow
        END IF
     END IF
     CALL aplbce_ss_flow
     IF(errexe) THEN
        CALL write5_ss_flow
        EXIT
     END IF
20   CALL timstp_ss_flow
     IF(.NOT.solute) CALL write6
     CALL asmslp_ss_flow
     CALL sumcal_ss_flow
     IF(tsfail .AND. .NOT.errexe) GO TO 20
     CALL write5_ss_flow
     IF(converge_ss) EXIT
     IF(itime > maxitn) THEN
        ierr(146) = .TRUE.
        errexe = .TRUE.
     END IF
     IF(errexe) EXIT
  END DO
  logline2 = 'Done with steady-state flow.'
!  WRITE(*,'(/A)') TRIM(logline2)
  CALL logprt_c(' ')
  CALL logprt_c(logline2)
  CALL screenprt_c(logline2)
  IF(errexe .OR. errexi) THEN
     logline1 = 'ERROR exit.'
!     WRITE(*,'(A)') TRIM(logline1)
     CALL logprt_c(logline1)
     CALL screenprt_c(logline1)
  END IF
  !..  CALL write4               ! ... calculate and print velocity fields if requested
  CALL init2_post_ss
END SUBROUTINE simulate_ss_flow

