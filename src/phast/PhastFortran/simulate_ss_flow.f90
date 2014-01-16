SUBROUTINE simulate_ss_flow
  ! ... Calls the routines necessary to simulate a steady-state solution
  ! ...      to the flow equation. This yields a steady-state pressure
  ! ...      (potentiometric head) solution for the transient solute 
  ! ...      transport simulation.
  USE mcc
  USE mcc_m
  USE mcp, ONLY: fdtmth
  USE mcp_m, ONLY: fdtmth_ssflow
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  IMPLICIT NONE
  INCLUDE "RM_interface.f90.inc"
  CHARACTER(LEN=130) :: logline1, logline2
  INTEGER :: status
  !     ------------------------------------------------------------------
  !...
  ! ... Start of the transient loop for marching to steady state
  time = 0.0_kdp
  logline1 = '     '
  logline2 = 'Beginning flow calculation for steady-state i.c.'
    status = RM_LogMessage(rm_id, logline1)
    status = RM_LogMessage(rm_id, logline2)
    status = RM_ScreenMessage(rm_id, logline1)
    status = RM_ScreenMessage(rm_id, logline2)
  fdtmth = fdtmth_ssflow     ! ... set time differencing method to flow ss 
  DO
     CALL coeff_flow
!$$    CALL write4
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
     CALL aplbce_flow
     IF(errexe) THEN
        CALL write5_ss_flow
        EXIT
     END IF
20   CALL timestep_ss_flow
     IF(.NOT.solute) CALL write6
     CALL asmslp_flow
     CALL sumcal_ss_flow
     IF(tsfail .AND. .NOT.errexe) GO TO 20
     CALL write5_ss_flow
     IF(converge_ss) EXIT          ! ... normal termination of time step loop
     IF(itime > maxitn) THEN
        ierr(146) = .TRUE.
        errexe = .TRUE.
     END IF
     IF(errexe) EXIT
  END DO
  logline2 = 'Done with steady-state flow.'
    status = RM_LogMessage(rm_id, ' ')
    status = RM_LogMessage(rm_id, logline2)
    status = RM_ScreenMessage(rm_id, logline2)
  IF(errexe .OR. errexi) THEN
     logline1 = 'ERROR exit.'
        status = RM_LogMessage(rm_id, logline1)
        status = RM_ScreenMessage(rm_id, logline1)
  END IF
  ! CALL write4               ! ... calculate and print velocity fields if requested
  CALL init2_post_ss
END SUBROUTINE simulate_ss_flow

