SUBROUTINE asmslp_flow  
  ! ... Performs the assembly and solution of the pressure equation
  ! ...      for one time step
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcch, ONLY: unittm
  USE mcg
  USE mcg_m
  USE mcm
  USE mcm_m
  USE mcp
  USE mcp_m
  USE mcs
  USE mcs2
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE scale_jds_mod
  USE solver_direct_mod
  USE solver_iter_mod
  IMPLICIT NONE
  INTERFACE
     SUBROUTINE sbcflo(iequ,ddv,ufracnp,qdvsbc,rhssbc,vasbc)
       USE machine_constants, ONLY: kdp
      INTEGER, INTENT(IN) :: iequ
       REAL(KIND=kdp), DIMENSION(0:), INTENT(IN) :: ddv
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: ufracnp
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: qdvsbc
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: rhssbc
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: vasbc
     END SUBROUTINE sbcflo
  END INTERFACE
  !
  INTEGER :: norm, iierr  
  INTEGER :: itrnp, iwel, ks, m, ma  
  REAL(KIND=kdp) :: fddp, sum1, sum2, timenp, udpwkt, upwkt
  LOGICAL :: convp
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: asmslp_flow.F90,v 1.1 2013/09/19 23:15:13 klkipp Exp $'
  !     ------------------------------------------------------------------
  ! ... Assemble and solve the flow equation for pressure (head)
  errexe = .FALSE.  
  convp = .FALSE.  
  dp = 0._kdp
  dt = 0._kdp
  dc = 0._kdp
  IF (nwel > 0) dpwkt = 0._kdp
  ieq = 1  
  itrnp = 1
  ! ... component 1 is used for stuff in pressure assembly. Should not
  ! ...    matter since constant density suppresses all transport terms.
  is = 1
  if (.not. steady_flow) then
     logline1 =  '     Beginning flow calculation.'
     CALL RM_LogMessage(logline1)
     CALL RM_ScreenMessage(logline1)
  endif
40 CONTINUE
  CALL asembl_flow  
  CALL aplbci_flow  
  ! ... Scale the matrix equations
  ! ...     row scaling only is default
  norm = 0          ! ... use L-infinity norm
  IF(row_scale) CALL rowscale(nxyz,norm,va,diagr,iierr)
  IF(col_scale) CALL colscale(nxyz,norm,va,ci,diagc,iierr)
  IF(iierr /= 0) THEN
!!$        WRITE(fuclog,*) 'Error in scaling: ', iierr
!!$        ierr(81) = .TRUE.
     WRITE(logline1,*) 'Error in scaling; equation:', iierr
     !$$        WRITE(*,3001) TRIM(logline1)
     !$$3001    FORMAT(/a)
     !***     CALL RM_ErrorMessage(logline1)
     RETURN
  END IF
  IF(col_scale) THEN
     IF(MINVAL(diagc) /= 1._kdp .AND. MAXVAL(diagc) /= 1._kdp)  &
          ident_diagc = .FALSE.
  END IF
  IF(row_scale) THEN
     DO ma=1,nxyz
        rhs(ma) = diagr(ma)*rhs(ma)
     END DO
  END IF
  ! ... Solve the matrix equations
  IF(slmeth == 1) THEN  
     ! ... Direct solver
     CALL tfrds(diagra, envlra, envura)  
  ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN  
     ! ... Generalized conjugate gradient iterative solver on reduced matrix
     CALL gcgris(ap, bbp, ra, rr, sss, xx, ww, zz, sumfil)
  ENDIF
  IF(ERREXE) RETURN  
  ! ... Flow equation has just been solved
  dpmax = 0._kdp
  ! ... Descale the solution vector
  IF(col_scale) THEN
     DO ma=1,nxyz
        rhs(ma) = diagc(ma)*rhs(ma)
     END DO
  END IF
  ! ... Extract the solution from the solution vector
  DO  m=1,nxyz  
     ma = mrno(m)  
     dp(m) = rhs(ma)  
     IF(frac(m) > 0.) dpmax = MAX(dpmax,ABS(dp(m)))
  END DO
  ! ... If adjustable time step, check for unacceptable time step length
  IF(autots .AND. jtime > 2) THEN  
     ! ... If DP is too large, reduce the time step
     IF(ABS(dpmax) > 1.5*dptas) THEN  
        tsfail = .TRUE.
        RETURN
     ENDIF
  ENDIF
  ! ... Calculate change in well datum pressure, if specified implicit
  ! ...      flow rate, and test for convergence, for rectangular region
  convp = .TRUE.  
  IF(.NOT. cylind) THEN  
     DO iwel = 1,nwel  
        IF(wqmeth(iwel) == 0 .OR. ABS(qwm(iwel)) <= 1.e-6_kdp .OR. wqmeth(iwel) == 11 .OR.  &
             wqmeth(iwel) == 13) CYCLE
        !$$     wqmeth(iwel) == 13) GOTO 70
        !$$               IF(WQMETH(IWEL).EQ.20.OR.WQMETH(IWEL).EQ.40) GO TO 70
        ! ... Calculate change in well datum pressure.
        ! ...      Neglects change in flow direction from time N to N+NU
        sum1 = 0._kdp  
        sum2 = 0._kdp  
        DO 60 ks = 1,nkswel(iwel)  
           m = mwel(iwel, ks)  
           sum1 = sum1 + dqwdpl(iwel,ks)*dp(m)  
           sum2 = sum2 + dqwdpl(iwel,ks)  
60      END DO
        udpwkt = sum1/sum2  
        upwkt = pwkt(iwel) + udpwkt  
        IF(itrnp > 0) THEN  
           fddp = ABS(udpwkt/dpwkt(iwel) - 1._kdp)  
        ELSE  
           fddp = 1._kdp  
        ENDIF
        IF(fddp > 0.001_kdp) THEN  
           convp = .FALSE.  
        ELSE  
           pwkt(iwel) = upwkt  
        ENDIF
        dpwkt(iwel) = udpwkt  
     END DO
  ENDIF
  IF(.NOT.convp) THEN  
     itrnp = itrnp + 1  
     IF(itrnp > maxitn) THEN  
        timenp = time+deltim  
        WRITE(logline1,5003)  '     Maximum No.(',maxitn,') of Iterations Reached', &
             ' for Well Bore Pressure Loop'
5003    FORMAT(a,I4,2a)
        WRITE(logline2,5013) '          Calculating for Time ..... ',cnvtmi*timenp,'  ('//unittm//')'
5013    FORMAT(a,1PG12.5,a)
!!$        WRITE(*,'(//TR10,a/TR15,a/)') logline1,logline2
        CALL RM_ErrorMessage(logline1)
        CALL RM_ErrorMessage(logline2)
!!$        WRITE(FULP, 9003) MAXITN, CNVTMI* TIMENP, UNITTM  
!!$        9003 FORMAT(//TR10, 'Maximum No.(',I4,') of Iterations Reached', &
!!$             ' for Well Bore Pressure Loop'/TR15, &
!!$             'Calculating for Time =',1PG12.5,'  (',A,')'/)
        logline1 =  '          A printout of current data was done.'
!!$        WRITE(*,'(a)') logline1
        CALL RM_ErrorMessage(logline1)
        ERREXE = .TRUE.  
        RETURN  
     ENDIF
     GOTO 40  
  ENDIF
  ! ... Calculate specified P b.c. cell boundary flow rates at end of time step
  ! ...     for current values of DP
  IF(nsbc > 0) CALL sbcflo(1, dp, frac, qfsbc, rhfsbc, vafsbc)  
  ! ... Calculate layer flow rates for cylindrical single well
  IF(cylind) THEN
     IF(wqmeth(1) /= 11 .AND. wqmeth(1) /= 13) CALL wbcflo
  ENDIF
  ! ... Update the dependent variables
! should do this in sumcal_ss_flow and sumcal1 
!  DO  m=1,nxyz
!     IF(ibc(m) == -1) CYCLE
!     p(m)=p(m)+dp(m)
!  END DO

END SUBROUTINE asmslp_flow
