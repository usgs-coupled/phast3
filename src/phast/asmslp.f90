SUBROUTINE asmslp  
  ! ... Performs the assembly and solution of the pressure equation
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcc
  USE mcch, ONLY: unittm
  USE mcg
  USE mcm
  USE mcp
  USE mcs
  USE mcs2
  USE mcv
  USE mcw
  IMPLICIT NONE
  INTERFACE
     SUBROUTINE rowscale(nrow,norm,a,diag,ierr)
       USE machine_constants, ONLY: kdp
       IMPLICIT NONE
       INTEGER, INTENT(IN) :: nrow
       INTEGER, INTENT(IN) :: norm
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: a
       REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: diag
       INTEGER, INTENT(OUT) :: ierr
     END SUBROUTINE rowscale

     SUBROUTINE colscale(nrow,norm,a,ci,diag,ierr)
       USE machine_constants, ONLY: kdp
       IMPLICIT NONE
       INTEGER, INTENT(IN) :: nrow  
       INTEGER, INTENT(IN) :: norm  
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: a    
       INTEGER, DIMENSION(:,:), INTENT(IN) :: ci 
       REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: diag
       INTEGER, INTENT(OUT) :: ierr
     END SUBROUTINE colscale

     SUBROUTINE gcgris(ap,bp,ra,rr,ss,xx,w,z,sumfil)
       USE machine_constants, ONLY: kdp
       REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT), TARGET :: ap
       REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT), TARGET :: bp
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN OUT) :: ra
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN OUT) :: rr
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN OUT) :: ss, w, z
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT), TARGET :: xx
       REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: sumfil
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
  INTEGER :: norm, iierr  
  INTEGER :: itrnp, iwel, ks, m, ma  
  REAL(kind=kdp) :: fddp, sum1, sum2, timenp, udpwkt, upwkt
  LOGICAL :: convp
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
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
!     component 1 is used for stuff in pressure assembly. Should not
!     matter since constant density suppresses all transport terms.
  is = 1
  logline1 =  '     Beginning flow calculation.'
!  WRITE(*,'(a)') TRIM(logline1)
  CALL logprt_c(logline1)
  CALL screenprt_c(logline1)
40 CONTINUE
  CALL asembl  
  CALL aplbci  
     ! ... Scale the matrix equations
     ! ...     row scaling only is default
     norm = 0          ! ... use L-infinity norm
     IF(row_scale) CALL rowscale(nxyz,norm,va,diagr,iierr)
     IF(col_scale) CALL colscale(nxyz,norm,va,ci,diagc,iierr)
     IF(iierr /= 0) THEN
!!$        WRITE(fuclog,*) 'Error in scaling: ', iierr
!!$        ierr(81) = .TRUE.
        WRITE(logline1,*) 'Error in scaling; equation:', iierr
!        WRITE(*,3001) TRIM(logline1)
!3001    FORMAT(/a)
        CALL errprt_c(logline1)
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
     DO IWEL = 1, NWEL  
        IF(wqmeth(iwel) == 0.OR.ABS(qwm(iwel)) <= 1.e-6_kdp.OR.wqmeth(iwel) == 11.OR. &
             wqmeth(iwel) == 13) CYCLE
        !     wqmeth(iwel) == 13) GOTO 70
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
     END DO
  ENDIF
  IF(.NOT.CONVP) THEN  
     ITRNP = ITRNP + 1  
     IF(ITRNP.GT.MAXITN) THEN  
        TIMENP = TIME+DELTIM  
        WRITE(logline1,5003)  '     Maximum No.(',maxitn,') of Iterations Reached', &
             ' for Well Bore Pressure Loop'
5003    FORMAT(a,I4,2a)
        WRITE(logline2,5013) '          Calculating for Time =',cnvtmi*timenp,'  ('//unittm//')'
5013    FORMAT(a,1PG12.5,a)
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
