SUBROUTINE WBBAL  
  ! ... Calculates a flow and heat balance over the wellbore
  ! ... Wells with a flow reversal in the well bore will not have a
  ! ...      realistic balance calculation.
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcp
  USE mcv
  USE mcw
  IMPLICIT NONE
  INTRINSIC INT  
  REAL(KIND=kdp) :: uqhw, uqwm, uqwmi
  INTEGER :: a_err, da_err, iis, iwel, iwfss, ks, m, mkt, nks, nsa
  LOGICAL :: erflg, florev
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  uqsw
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: wbbal.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  ERFLG = .FALSE.  
  nsa = MAX(ns,1)
     ALLOCATE (uqsw(nsa), &
          STAT = a_err)
     IF (a_err.ne.0) THEN  
        PRINT *, "Array allocation failed: wbbal"  
        STOP  
     ENDIF
  DO 60 IWEL = 1, NWEL  
     IF( WQMETH( IWEL) .EQ.0) GOTO 60  
     !         WRCALC=.FALSE.
     UQWM = - QWM( IWEL)  
     IWFSS = INT(SIGN(1._kdp,uqwm))  
     IF(ABS(uqwm) < 1.E-8_kdp) iwfss = 0  
     nks = nkswel( iwel)  
     !         MMKT=mwel(IWEL,nks)
     DO 10 Ks = 1, nks  
        M = mwel( iwel, ks)  
        IF( .NOT.CYLIND) THEN  
           ! ... Update layer flow rates for line source/sink wells
           QWLYR( iwel, ks) = QWLYR( iwel, ks) + DQWDPL( iwel, ks) *( DP( M) - DPWKT( IWEL) )
           PWK( iwel, ks) = PWK( iwel, ks) + DPWKT( IWEL)  
        ELSE  
           ! ... Update well bore pressure profile for cylindrical system
           PWK( iwel, ks) = P( M)  
        ENDIF
10   END DO
     IF( CYLIND) THEN  
        MKT = mwel( 1, nks)  
        ! ... PWKT is at time N+1
        ! ...    should it be PWK(MKT)??
        PWKT( IWEL) = P( MKT)  
     ELSE  
        PWKT( IWEL) = PWK( iwel, nks)  
     ENDIF
     ! ... Sum mass, heat, and solute flow rates for the well
     ! ...      calculate new enthalpy, temperature, mass fraction,
     ! ...      density profiles
     FLOREV = .FALSE.
     IF( IWFSS.GE.0) THEN  
        ! ... Production well
        UQWM = 0.D0  
        UQHW = 0.D0  
        do 12 iis = 1, ns  
           UQSW( iis) = 0.D0  
12      end do
        DO 20 Ks = 1, nks  
           M = mwel( iwel, ks)  
           IF( QWLYR( iwel, ks) .LT.0.D0) THEN  
              ! ... Production layer
              QFLYR( iwel, ks) = DEN( M) * QWLYR( iwel, ks)  
              UQWM = UQWM - QFLYR( iwel, ks)  
              !                  IF(HEAT) THEN
              !                     QHLYR(IWEL,K)=QFLYR(IWEL,K)*EH(M)
              !                     UQHW=UQHW-QHLYR(IWEL,K)
              !                     EHWK(IWEL,K)=UQHW/UQWM
              !                     TWK(IWEL,K)=TOFEP(EHWK(IWEL,K),PWK(IWEL,K),ERFLG)
              !                  ENDIF
              do 13 iis = 1, ns  
                 QSLYR( IWEL, Ks, iis) = QFLYR( IWEL, Ks) * C( M, iis)  
                 UQSW( iis) = UQSW( iis) - QSLYR( IWEL, Ks, iis)  
                 CWK( IWEL, Ks, iis) = UQSW( iis) / UQWM  
13            end do
           ELSE  
              ! ... Injection layer from producing well (not allowed at layer KB, ks=1
              QFLYR( IWEL, Ks) = DENWK( IWEL, Ks) * QWLYR( IWEL, Ks)  
              UQWM = UQWM - QFLYR( IWEL, Ks)  
              !                  IF(HEAT) THEN
              !                     EHWK(IWEL,K)=EHWK(IWEL,K-1)
              !                     QHLYR(IWEL,K)=QFLYR(IWEL,K)*EHWK(IWEL,K)
              !                     UQHW=UQHW-QHLYR(IWEL,K)
              !                     TWK(IWEL,K)=TOFEP(EHWK(IWEL,K),PWK(IWEL,K),ERFLG)
              !                  ENDIF
              do 14 iis = 1, ns  
                 CWK( IWEL, Ks, iis) = CWK( IWEL, Ks - 1, iis)  
                 QSLYR( IWEL, Ks, iis) = QFLYR( IWEL, Ks) * CWK( &
                      IWEL, Ks, iis)
                 UQSW( iis) = UQSW( iis) - QSLYR( IWEL, Ks, iis)  
14            end do
           ENDIF
           DENWK( IWEL, Ks) = DEN0  
           !               IF(ERFLG) THEN
           !                  WRITE(FUCLOG,9001)
           !     &                 'TOFEP interpolation error in WBBAL',
           !     &                 'Production well no. ',IWEL
           ! 9001             FORMAT(TR10,2A,I4)
           !                  IERR(129)=.TRUE.
           !                  ERREXE=.TRUE.
           !                  RETURN
           !               ENDIF
           IF(UQWM < 0.D0) THEN  
              WRITE(logline1,9012) 'Production well no. ', IWEL, &
                   ' has down bore flow from level ', Ks + 1, ' to ', Ks, &
                   '; Time plane N =', ITIME-1
9012          FORMAT(A,I4,A,I2,A,I2,A,I4)
              WRITE(logline2,9022) ' Flow rate =', UQWM
9022          format(A,1PG10.2)  
              call warnprt_c(logline1)
              call warnprt_c(logline2)
              WRITE(FUWEL,9002) 'Production well no. ', IWEL, &
                   ' has down bore flow from level ', Ks + 1, ' to ', Ks, &
                   '; Time plane N =', ITIME-1, ' Flow rate =', UQWM
9002          FORMAT(TR10,A,I4,A,I2,A,I2,A,I4/TR15,A,1PG10.2)  
              FLOREV = .TRUE.  
           ENDIF
20      END DO
        ELSEIF( IWFSS.LT.0) THEN  
           ! ... Injection well
        UQWMI = UQWM  
!        IF( HEAT) EHWKT( IWEL) = EHOFTP( TWKT( IWEL), PWKT( IWEL), &
!             ERFLG)
        !            IF(ERFLG) THEN
        !               WRITE(FUCLOG,9001) 'EHOFTP interpolation error in WBBAL'
        !     &              'Injection well no. ',IWEL
        !               IERR(134)=.TRUE.
        !               ERREXE=.TRUE.
        !               RETURN
        !            ENDIF
        !            UQHW=UQWM*EHWKT(IWEL)
        do  iis = 1, ns  
           UQSW( iis) = UQWM* CWKT( IWEL, iis)  
        end do
        DO 30 Ks = nks, 1, - 1  
           M = mwel( iwel, ks)  
           IF( QWLYR( IWEL, Ks) .GT.0.D0) THEN  
              ! ... INJECTION LAYER
              IF( Ks.EQ.nks) THEN  
                 !                     IF(HEAT) THEN
                 !                        EHWK(IWEL,K)=EHWKT(IWEL)
                 !                        TWK(IWEL,K)=TWKT(IWEL)
                 !                     ENDIF
                 do  iis = 1, ns  
                    CWK( IWEL, Ks, iis) = CWKT( IWEL, iis)  
                 end do
              ELSE  
                 !                     IF(HEAT) THEN
                 !                        EHWK(IWEL,K)=EHWK(IWEL,K+1)
                 !                        TWK(IWEL,K)=TOFEP(EHWK(IWEL,K),PWK(IWEL,K),ERFL
                 !                     ENDIF
                 do  iis = 1, ns  
                    CWK( IWEL, Ks, iis) = CWK( IWEL, Ks + 1, iis)  
                 end do
              ENDIF
              DENWK( IWEL, Ks) = DEN0  
              QFLYR( IWEL, Ks) = DENWK( IWEL, Ks) * QWLYR( IWEL, Ks)  
              UQWM = UQWM + QFLYR( IWEL, Ks)  
              !                  IF(HEAT) QHLYR(IWEL,Ks)=QFLYR(IWEL,Ks)*EHWK(IWEL,Ks)
              !                  UQHW=UQHW+QHLYR(IWEL,Ks)
              do  iis = 1, ns  
                 QSLYR( IWEL, Ks, iis) = QFLYR( IWEL, Ks) * CWK( &
                      IWEL, Ks, iis)
                 UQSW( iis) = UQSW( iis) + QSLYR( IWEL, Ks, iis)  
              end do
           ELSE  
              ! ... Production layer into injection well
              QFLYR( IWEL, Ks) = DEN( M) * QWLYR( IWEL, Ks)  
              UQWM = UQWM + QFLYR( IWEL, Ks)  
              !                  IF(HEAT) THEN
              !                     QHLYR(IWEL,K)=QFLYR(IWEL,K)*EH(M)
              !                     UQHW=UQHW+QHLYR(IWEL,K)
              !                     EHWK(IWEL,K)=UQHW/UQWM
              !                     TWK(IWEL,K)=TOFEP(EHWK(IWEL,K),PWK(IWEL,K),ERFLG)
              !                  ENDIF
              do  iis = 1, ns  
                 QSLYR( IWEL, Ks, iis) = QFLYR( IWEL, Ks) * C( M, iis)  
                 UQSW( iis) = UQSW( iis) + QSLYR( IWEL, Ks, iis)  
                 CWK( IWEL, Ks, iis) = UQSW( iis) / UQWM  
              end do
              DENWK( IWEL, Ks) = DEN0  
           ENDIF
           !               IF(ERFLG) THEN
           !                  WRITE(FUCLOG,9001)
           !     &                 'TOFEP interpolation error in WBBAL',
           !     &                 'Injection well no. ',IWEL
           !                  IERR(129)=.TRUE.
           !                  ERREXE=.TRUE.
           !                  RETURN
           !               ENDIF
           IF(Ks.GT.1.AND.UQWM/ABS(uqwmi) > 0.01_kdp) THEN  
              FLOREV = .TRUE.  
              WRITE(logline1,9012) 'Injection well no. ', IWEL, &
                   ' has up bore flow from level ', Ks + 1, ' to ', Ks, &
                   '; Time plane N =', ITIME-1
              WRITE(logline2,9022) ' Flow rate =', UQWM
              call warnprt_c(logline1)
              call warnprt_c(logline2)
              WRITE(FUWEL, 9002) 'Injection well no. ', IWEL,  &
                   ' has up bore flow from level ', Ks - 1, ' to ', Ks,  &
                   '; Time plane N =', ITIME,' Flow rate =',UQWM
           ENDIF
30      END DO
        IF(ABS(uqwm/uqwmi) > 0.01_kdp) THEN  
           ! ... Well has excess residual flow rate
           FLOREV = .TRUE.
           WRITE(logline1,9012) 'Injection well no. ', IWEL,  &
                ' has >1% residual flow through well bottom',  &
                   '; Time plane N =', ITIME-1
              WRITE(logline2,9022) ' Flow rate =',UQWM
              call errprt_c(logline1)
              call errprt_c(logline2)
           WRITE(FUWEL, 9002) 'Injection well no. ', IWEL, ' has >1% residua &
                &l flow through well bottom', '; Time plane N =', ITIME-1, ' Flow r &
                &ate =', UQWM
        ENDIF
     ENDIF
     IF(FLOREV) THEN  
        logline1 =  'Well solute concentrations may be poor approximations (WBBAL)'
        call errprt_c(logline1)
        WRITE(FUWEL,9003) 'Well solute concentrations may be poor approximations (WBBAL)'
9003    FORMAT(TR10,A)  
        IERR( 142) = .TRUE.  
        ERREXE = .TRUE.  
     ENDIF
     ! ... Cumulative amounts for each well, save current fluid, heat, and
     ! ...       solute flow rates
     QWM( IWEL) = 0.D0  
     IF( HEAT) QHW( IWEL) = 0.D0  
     do  iis = 1, ns  
        QSW( IWEL, iis) = 0.D0  
     end do
     DO  Ks = 1, nks  
        QWM( IWEL) = QWM( IWEL) + QFLYR( IWEL, Ks)  
        !            IF(HEAT) QHW(IWEL)=QHW(IWEL)+QHLYR(IWEL,Ks)
        do  iis = 1, ns  
           QSW( IWEL, iis) = QSW( IWEL, iis) + QSLYR( IWEL, Ks, iis)  
        end do
     END DO
     !         IF(HEAT) TWKT(IWEL)=TWK(IWEL,nks)
     do  iis = 1, ns  
        CWKT( IWEL, iis) = CWK( IWEL, nks, iis)  
     end do
     ! ... Well riser calculations
     !...  ** not available in PHAST
60 END DO
  DEALLOCATE (uqsw, &
       STAT = da_err)
  IF (da_err.ne.0) THEN  
     PRINT *, "Array deallocation failed"  
     STOP  
  ENDIF
END SUBROUTINE wbbal
