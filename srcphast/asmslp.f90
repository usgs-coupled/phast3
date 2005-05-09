SUBROUTINE asmslp  
  ! ... Performs the assembly and solution of the pressure equation
  USE machine_constants, ONLY: kdp
!!$  USE f_units
  USE mcb
  USE mcc
  use mcch, ONLY: unittm
  USE mcg
  USE mcm
  USE mcp
  USE mcs
  USE mcs2
  USE mcv
  USE mcw
  IMPLICIT NONE
  INTERFACE
     SUBROUTINE gcgris(ap,bp,ra,rr,ss,xx,w,z,sumfil)
       USE machine_constants, ONLY: kdp
       REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT) :: ap
       REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT) :: bp
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN OUT) :: ra
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN OUT) :: rr
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN OUT) :: ss, w, z
       REAL(kind=kdp), DIMENSION(:), INTENT(INOUT) :: sumfil
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: xx
     END SUBROUTINE gcgris
     SUBROUTINE sbcflo(iequ,ddv,ufracnp,qdvsbc,rhssbc,vasbc)
       USE machine_constants, ONLY: kdp
      INTEGER, INTENT(IN) :: iequ
       REAL(KIND=kdp), DIMENSION(0:), INTENT(IN) :: ddv
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: ufracnp
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: qdvsbc
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: rhssbc
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: vasbc
     END SUBROUTINE sbcflo
     SUBROUTINE tfrds(diagra,envlra,envura)
       USE machine_constants, ONLY: kdp
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: diagra, envlra, envura
     END SUBROUTINE tfrds
  END INTERFACE
!
  REAL(kind=kdp) :: fddp, sum1, sum2, timenp, udpwkt, upwkt
  INTEGER :: itrnp, iwel, ks, m, ma  
  LOGICAL :: convp
  CHARACTER(LEN=130) :: logline1, logline2
  !.....Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  ! ... Assemble and solve the flow equation for pressure (head)
  errexe = .false.  
  convp = .false.  
  dp = 0._kdp
  dt = 0._kdp
  dc = 0._kdp
  if (nwel > 0) dpwkt = 0._kdp
  ieq = 1  
  itrnp = 1
!     component 1 is used for stuff in pressure assembly. Should not
!     matter since constant density suppresses all transport terms.
  is = 1
  logline1 =  '     Beginning flow calculation.'
  WRITE(*,'(a)') trim(logline1)
  CALL logprt_c(logline1)
40 CONTINUE
  CALL asembl  
  CALL aplbci  
  ! ... Solve the matrix equations
  IF(slmeth == 1) THEN  
     ! ... Direct solver
     CALL tfrds(diagra, envlra, envura)  
  ELSEIF(slmeth == 3 .or. slmeth == 5) THEN  
     ! ... Generalized conjugate gradient iterative solver on reduced matrix
     CALL gcgris(ap, bbp, ra, rr, sss, xx, ww, zz, sumfil)
  ENDIF
  IF(ERREXE) RETURN  
  ! ... Flow equation has just been solved
  DPMAX = 0._kdp
  DO  M = 1, NXYZ  
     MA = MRNO(M)  
     DP(M) = RHS(MA)  
     IF(FRAC(M).GT.0.) DPMAX = MAX(DPMAX, ABS(DP(M)))  
  END DO
  ! ... If adjustable time step, check for unacceptable time step length
  IF(AUTOTS.AND.JTIME.GT.2) THEN  
     ! ... If DP is too large, abort the p,c sequence and
     ! ...      reduce the time step
     IF(ABS(DPMAX) .GT.1.5* DPTAS) THEN  
        TSFAIL = .TRUE.  
        RETURN  
     ENDIF
  ENDIF
  ! ... Calculate change in well datum pressure, if specified implicit
  ! ...      flow rate, and test for convergence, rectangular region
  CONVP = .TRUE.  
  IF(.NOT.CYLIND) THEN  
     DO 70 IWEL = 1, NWEL  
        IF(wqmeth(iwel) == 0.OR.ABS(qwm(iwel)) <= 1.e-6_kdp.OR.wqmeth(iwel) == 11.OR. &
             wqmeth(iwel) == 13) GOTO 70
        !               IF(WQMETH(IWEL).EQ.20.OR.WQMETH(IWEL).EQ.40) GO TO 70
        ! ... Calculate change in well datum pressure.
        ! ...      Neglects change in flow direction from time N to N+NU
        SUM1 = 0.D0  
        SUM2 = 0.D0  
        DO 60 Ks = 1, nkswel(IWEL)  
           M = mwel(iwel, ks)  
           SUM1 = SUM1 + DQWDPL(iwel, ks) * DP(M)  
           SUM2 = SUM2 + DQWDPL(iwel, ks)  
60      END DO
        UDPWKT = SUM1/ SUM2  
        UPWKT = PWKT(IWEL) + UDPWKT  
        IF(ITRNP.GT.0) THEN  
           FDDP = ABS(UDPWKT/ DPWKT(IWEL) - 1.D0)  
        ELSE  
           FDDP = 1.D0  
        ENDIF
        IF(fddp > 0.001_kdp) THEN  
           convp = .FALSE.  
        ELSE  
           pwkt(iwel) = upwkt  
        ENDIF
        DPWKT(IWEL) = UDPWKT  
70   END DO
  ENDIF
  IF(.NOT.CONVP) THEN  
     ITRNP = ITRNP + 1  
     IF(ITRNP.GT.MAXITN) THEN  
        TIMENP = TIME+DELTIM  
        WRITE(logline1,5003)  '     Maximum No.(',maxitn,') of Iterations Reached', &
             ' for Well Bore Pressure Loop'
5003    FORMAT(a,I4,2a)
        WRITE(logline2,5013) '          Calculating for Time =',cnvtmi*timenp,'  ('//unittm//')'
5013    format(a,1PG12.5,a)
!!$        WRITE(*,'(//TR10,a/TR15,a/)') logline1,logline2
        CALL errprt_c(logline1)
        CALL errprt_c(logline2)
!!$        WRITE(FULP, 9003) MAXITN, CNVTMI* TIMENP, UNITTM  
!!$        9003 FORMAT(//TR10, 'Maximum No.(',I4,') of Iterations Reached', &
!!$             ' for Well Bore Pressure Loop'/TR15, &
!!$             'Calculating for Time =',1PG12.5,'  (',A,')'/)
        logline1 =  '          A printout of current data was done.'
!!$        WRITE(*,'(a)') logline1
        CALL errprt_c(logline1)
        ERREXE = .TRUE.  
        RETURN  
     ENDIF
     GOTO 40  
  ENDIF
  ! ... Calculate specified P b.c. cell boundary flow rates for current values of DP,DC
  IF(NSBC.GT.0) CALL SBCFLO(1, DP, FRAC, QFSBC, RHFSBC, VAFSBC)  
  ! ... Calculate layer flow rates for cylindrical single well
  IF(CYLIND) THEN
     IF(WQMETH(1).NE.11.AND.WQMETH(1).NE.13) CALL WBCFLO
  ENDIF
END SUBROUTINE asmslp
