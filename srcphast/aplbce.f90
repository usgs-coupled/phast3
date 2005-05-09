SUBROUTINE aplbce  
  ! ... Applies right hand side terms from b.c.
  ! ... Calculates the conductive heat loss b.c.
  ! ...      and applies to the right hand side
  USE machine_constants, ONLY: kdp
!!$  USE f_units
  USE mcb
  USE mcc
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcv
  USE mg2
  USE phys_const
  IMPLICIT NONE
  EXTERNAL EHOFTP  
  REAL(kind=kdp) :: EHOFTP  
  REAL(kind=kdp) ::  DELP2, DPUDT, DQETDP, DZFSDP, ETA, &
       LTD, P00, P1, PU, QFBC, QHBC, QHBC2, QN, TIMED, &
       TIMEDN, UFDT2, UFRAC, UPHIM, UZAV, Z0, Z1, ZFSA
  REAL(kind=kdp), DIMENSION(10) :: BETA( 10), GAMMA( 10)
  INTEGER :: a_err, da_err, imod, iis, k, ks, l, l1, lc, ll, ls, lll, m, mc, ms  
  LOGICAL :: ERFLG  
  CHARACTER(len=9) :: CIBC
  REAL(kind=kdp), DIMENSION(:), ALLOCATABLE :: qsbc, qsbc2
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  UFDT2 = FDTMTH  
  ! ... Specified P,T,or C b.c. terms are applied in APLBCI
  ! ... Apply specified flux b.c. dispersive and advective terms
  ERFLG = .FALSE.  
  ALLOCATE (qsbc(ns), qsbc2(ns), &
       stat = a_err)
  IF (a_err.NE.0) THEN  
     PRINT *, "Array allocation failed: aplbce"  
     STOP  
  ENDIF
  DO 10 L = 1, NFBC  
     M = MFBC( L)  
     UFRAC = 1._kdp  
     IF( L.LT.LNZ2) UFRAC = FRAC( M)  
     ! ... Redirect the flux to the free-surface cell, if necessary
     IF( L.GE.LNZ2) THEN  
        L1 = MOD( M, NXY)  
        IF( L1.EQ.0) L1 = NXY  
        M = MFSBC( L1)  
        UFRAC = 1._kdp  
     ENDIF
     QN = QFBCV( L)  
     IF( QN.LE.0.) THEN  
        ! ... Outflow
        QFBC = DEN( M) * QN* UFRAC  
        if (heat) QHBC = QFBC* EH( M)  
        DO  iis = 1, ns  
           QSBC(iis) = QFBC* C( M,iis)  
        END DO
     ELSE  
        ! ... Inflow
        QFBC = DENFBC( L) * QN* UFRAC  
        IF( HEAT) QHBC = QFBC* EHOFTP( TFLX( L), P( M), ERFLG)  
        DO  iis = 1, ns  
           QSBC(iis) = QFBC* CFLX( L,iis)  
        END DO
     ENDIF
     RF( M) = RF( M) + UFDT2* QFBC  
!!$     IF( HEAT) THEN  
!!$        QHBC2 = QHFBC( L) * UFRAC  
!!$        RH( M) = RH( M) + UFDT2* ( QHBC2 + QHBC)  
!!$     ENDIF
     DO  iis = 1, ns  
        QSBC2( iis) = QSFBC( L, iis) * UFRAC  
        RS( M, iis) = RS( M, iis) + UFDT2* ( QSBC2( iis) + QSBC( iis) )  
     END DO
10 END DO
!!$  IF( ERFLG) THEN  
!!$     WRITE( FUCLOG, 9006) 'EHOFTP interpolation error in APLBCE ', &
!!$          'Associated heat flux: Specified flux b.c.'
!!$9006 FORMAT   (TR10,2A,I4)  
!!$     IERR( 129) = .TRUE.  
!!$     ERREXE = .TRUE.  
!!$     RETURN  
!!$  ENDIF
  ! ... Calculate leakage b.c. coefficients
  ! ...      only for horizontal coordinates
  DO L = 1, NLBC  
     m = mlbc(l)  
     albc(l) = 0._kdp
     blbc(l) = 0._kdp
     ufrac = frac(m)  
     ! ... No flow to or from empty cells, and attenuate flows
     ! ...      at partially saturated cells.
     IF( UFRAC.GT.0.) THEN  
        IMOD = MOD( M, NXY)  
        K = ( M - IMOD) / NXY + MIN( 1, IMOD)  
        WRITE( CIBC, 6001) IBC( M)  
6001    FORMAT      (I9)  
        IF( CIBC( 3:3) .EQ.'3') THEN  
           UZAV = ZELBC( L) - .5* BBLBC( L)  
        ELSE  
           UZAV = ZELBC( L)  
        ENDIF
        UPHIM = P( M) + GZ* ( DENLBC( L) - DEN( M) ) * UZAV  
        BLBC( L) = KLBC( L) * UFRAC/ VISLBC( L)  
        ALBC( L) = BLBC( L) * ( ( DENLBC( L) * PHILBC( L) - DEN( M) &
             * GZ* Z( K) ) - UPHIM)
        ! ... Attenuate the flow rate for a partially saturated cell with
        ! ...      leakage through a lateral face
        IF( CIBC( 1:1) .EQ.'3'.OR.CIBC( 2:2) .EQ.'3') THEN  
           ALBC( L) = UFRAC* ALBC( L)  
           BLBC( L) = UFRAC* BLBC( L)  
        ENDIF
     ENDIF
     ! ... It is too late to do this. Read3 data is in for this time step.
!!$     ! ... Load flow rates for balance calculation
!!$     qn = albc(l)
!!$     IF(qn < 0._kdp) THEN
!!$        ! ... Outflow
!!$        qflbc(l) = den(m)*qn
!!$        DO  is=1,ns
!!$           qslbc(l,is) = qflbc(l)*c(m,is)
!!$        END DO
!!$     ELSE
!!$        ! ... Inflow
!!$        qflbc(l) = denlbc(l)*qn
!!$        DO  is=1,ns
!!$           qslbc(l,is) = qflbc(l)*clbc(l,is)
!!$        END DO
!!$     END IF
  END DO
  ! ... Calculate river leakage b.c. coefficients
  ! ...      only for horizontal coordinates; No lateral river leakage
  DO lc=1,nrbc_cells
     mc = river_seg_index(lc)%m
     IF(mc == 0) CYCLE     ! ... dry column
     DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
        arbc(ls) = 0._kdp
        brbc(ls) = 0._kdp
        uzav = zerbc(ls) - .5_kdp*bbrbc(ls)     
        ms = mrbc(ls)        ! ... current river segment cell for aquifer head
                             ! ... now ms = mc
        imod = mod(ms,nxy)
        ks = (ms - imod)/nxy + min(1,imod)
        uphim = p(ms) + gz*(denrbc(ls) - den(ms))*uzav
        brbc(ls) = krbc(ls)/visrbc(ls)
        arbc(ls) = brbc(ls)*((denrbc(ls)*phirbc(ls) - den(ms)*gz*z(ks)) - uphim)
     END DO
  END DO
!!$  DO ls=1,nrbc_seg
!!$     m = mrbc(ls)     ! ... current f.s. cell
!!$     arbc(ls) = 0._kdp
!!$     brbc(ls) = 0._kdp
!!$     imod = mod(m,nxy)
!!$     k = (m - imod)/nxy + min(1,imod)
!!$     uzav = zerbc(ls) - .5_kdp*bbrbc(ls)
!!$     uphim = p(m) + gz*(denrbc(ls) - den(m))*uzav
!!$     brbc(ls) = krbc(ls)/visrbc(ls)
!!$     arbc(ls) = brbc(ls)*((denrbc(ls)*phirbc(ls) - den(m)*gz*z(k)) - uphim)
!!$     ! ... No lateral river leakage
!!$  END DO
!!$  DO lc=1,nrbc_cells
!!$     m = river_seg_index(lc)%m
!!$     IF(m == 0) CYCLE
!!$     ! ... Calculate current net aquifer leakage flow rate
!!$     ! ...      Possible attenuation included explicitly
!!$     qm_net = 0._kdp
!!$     DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
!!$        qn = arbc(ls)
!!$        IF(qn < 0._kdp) THEN
!!$           ! ... Outflow
!!$           qm_net = qm_net + den(m)*qn
!!$        ELSE  
!!$           ! ... Inflow
!!$           ! ... Limit the flow rate for a river leakage
!!$           qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
!!$                - den(m)*bbrbc(ls)))
!!$           qn = MIN(qn,qlim)
!!$           qm_net = qm_net + denrbc(ls)*qn
!!$        ENDIF
!!$     END DO
!!$     qfrbc(lc) = qm_net
!!$     IF(qm_net < 0._kdp) THEN  
!!$        ! ... Outflow
!!$        DO  is=1,ns
!!$           qsrbc(lc,is) = qfrbc(lc)*c(m,is)
!!$        END DO
!!$     ELSE
!!$        ! ... Inflow
!!$        qm_in = 0._kdp
!!$        sum_cqm_in = 0._kdp
!!$        DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
!!$           qn = arbc(ls)
!!$           IF(qn > 0._kdp) THEN  
!!$              ! ... Inflow
!!$              ! ... Limit the flow rate for a river leakage
!!$              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*  &
!!$                   (zerbc(ls)-0.5_kdp*bbrbc(ls)) - den(m)*bbrbc(ls)))
!!$              qn = MIN(qn,qlim)
!!$              qm_in = qm_in + denrbc(ls)*qn
!!$              sum_cqm_in = sum_cqm_in + denrbc(ls)*qn*crbc(ls,is)  
!!$           ENDIF
!!$        END DO
!!$        cavg = sum_cqm_in/qm_in
!!$        DO  is=1,ns
!!$           qsrbc(lc,is) = qfrbc(lc)*cavg
!!$        END DO
!!$     END IF
!!$  END DO
!!$  IF( NAIFC.GT.0) THEN  
!!$     !... *** not implemented for PHAST
!!$     ! ... Calculate aquifer influence function b.c. terms
!!$     ! ... ***This section is missed if the time step is repeated***
!!$     IF( IAIF.EQ.2) THEN  
!!$        ! ... Carter-Tracy influence functions
!!$        ! ... Calculate dimensionless time
!!$        TIMED = ( TIME+DELTIM) * FTDAIF  
!!$        TIMEDN = TIME* FTDAIF  
!!$        ! ... Find pressure influence function and slope by approximate
!!$        ! ...      equation from FANCHI
!!$        IF(TIMED <= 0.01_kdp) THEN  
!!$           PU = - 2.* SQRT( TIMED/ PI)  
!!$           DPUDT = - 1._kdp/ SQRT( TIMED* PI)  
!!$           ELSEIF(TIMED >= 1000._kdp) THEN  
!!$           PU = - .5*(LOG(timed) + 0.80907_kdp)  
!!$           DPUDT = - .5/timed  
!!$        ELSE  
!!$           LTD = LOG(timed)  
!!$           PU = BBAIF( 0) + BBAIF( 1) * TIMED+BBAIF( 2) * LTD+BBAIF( &
!!$                3) * LTD* LTD
!!$           DPUDT = BBAIF( 1) + ( BBAIF( 2) + 2.* BBAIF( 3) * &
!!$                LTD) / TIMED
!!$        ENDIF
!!$     ENDIF
!!$     DO 30 L = 1, NAIFC  
!!$        M = MAIFC( L)  
!!$        UFRAC = FRAC( M)  
!!$        IF( L.GE.LNZ4) THEN  
!!$           L1 = MOD( M, NXY)  
!!$           IF( L1.EQ.0) L1 = NXY  
!!$           M = MFSBC( L1)  
!!$           UFRAC = 1._KDP  
!!$        ENDIF
!!$        IF( IAIF.EQ.1) THEN  
!!$           ! ... Pot aquifer
!!$           AAIF( L) = 0._KDP  
!!$           BAIF( L) = - VAIFC( L) * UFRAC/ DELTIM  
!!$           ELSEIF( IAIF.EQ.2) THEN  
!!$              ! ... Carter-Tracy
!!$           AAIF( L) = F1AIF* VAIFC( L) * ( ( P( M) - PAIF( L) ) &
!!$                - DPUDT* WCAIF( L) * F2AIF) * UFRAC/ ( PU - DPUDT* &
!!$                TIMEDN)
!!$           BAIF( L) = F1AIF* VAIFC( L) * UFRAC/ ( PU - DPUDT* &
!!$                TIMEDN)
!!$        ENDIF
!!$30   END DO
!!$  ENDIF
!!$  !      IF(HEAT) THEN
!!$  !... ** not implemented for PHAST
!!$  ! ... Calculate heat conduction b.c.
!!$  ! ... Finite difference heat flow calculation
!!$  ! ... Update temperature distribution for temperature at beginning
!!$  ! ...      of current time step
!!$  ! ... ***This section is missed if the time step is repeated***
!!$  !         DO 100 L=1,NHCBC
!!$  !            M=MHCBC(L)
!!$  !            LLL=(L-1)*NHCN
!!$  !            AA1(1)=0.D0
!!$  !            AA2(1)=1.D0
!!$  !            AA3(1)=0.D0
!!$  !            AA4(1)=T(M)
!!$  !            DO 40 LL=2,NHCN-1
!!$  !               AA1(LL)=-A1HC(LL)*DELTIM*DTHHC(L)
!!$  !               AA2(LL)=1.+A2HC(LL)*DELTIM*DTHHC(L)
!!$  !               AA3(LL)=-A3HC(LL)*DELTIM*DTHHC(L)
!!$  !               AA4(LL)=THCBC(LLL+LL)
!!$  !   40       CONTINUE
!!$  !            AA1(NHCN)=0.D0
!!$  !            AA2(NHCN)=1.D0
!!$  !            AA3(NHCN)=0.D0
!!$  !            AA4(NHCN)=THCBC(L*NHCN)
!!$  !C.....Solve the tri-diagonal set of equations
!!$  !            BETA(1)=AA2(1)
!!$  !            GAMMA(1)=AA4(1)/BETA(1)
!!$  !            DO 50 LL=2,NHCN
!!$  !               BETA(LL)=AA2(LL)-AA1(LL)*AA3(LL-1)/BETA(LL-1)
!!$  !               GAMMA(LL)=(AA4(LL)-AA1(LL)*GAMMA(LL-1))/BETA(LL)
!!$  !   50       continue
!!$  !C.....Compute solution vector, THCBC
!!$  !            THCBC(LLL+NHCN)=GAMMA(NHCN)
!!$  !            DO 60 LL=NHCN-1,1,-1
!!$  !               THCBC(LLL+LL)=GAMMA(LL)-AA3(LL)*THCBC(LLL+LL+1)/BETA(LL)
!!$  !   60       continue
!!$  !C.....Calculate heat flow rate for no boundary temperature change
!!$  !            QHCBC(L)=KARHC(L)*(THCBC(LLL+2)-THCBC(LLL+1))/(ZHCBC(2)
!!$  !     X           -ZHCBC(1))
!!$  !C.....Apply to r.h.s.
!!$  !            RH(M)=RH(M)+UFDT2*QHCBC(L)
!!$  !C.....Calculate boundary heat flow rate per degree C change
!!$  !            AA4(1)=1.
!!$  !            DO 70 LL=2,NHCN-1
!!$  !               AA4(LL)=0.
!!$  !   70       continue
!!$  !            AA4(NHCN)=0.
!!$  !            BETA(1)=AA2(1)
!!$  !            GAMMA(1)=AA4(1)/BETA(1)
!!$  !            DO 80 LL=2,NHCN
!!$  !               BETA(LL)=AA2(LL)-AA1(LL)*AA3(LL-1)/BETA(LL-1)
!!$  !               GAMMA(LL)=(AA4(LL)-AA1(LL)*GAMMA(LL-1))/BETA(LL)
!!$  !   80       continue
!!$  !C.....Compute solution vector, TPHCBC
!!$  !            TPHCBC(LLL+NHCN)=GAMMA(NHCN)
!!$  !            DO 90 LL=NHCN-1,1,-1
!!$  !               TPHCBC(LLL+LL)=GAMMA(LL)-AA3(LL)*TPHCBC(LLL+LL+1)/
!!$  !     &              BETA(LL)
!!$  !   90       continue
!!$  !            DQHCDT(L)=KARHC(L)*(TPHCBC(LLL+2)-TPHCBC(LLL+1))/(ZHCBC(2)
!!$  !     X           -ZHCBC(1))
!!$  !  100    CONTINUE
!!$  !      ENDIF
  DEALLOCATE (qsbc, qsbc2, &
       stat = da_err)
  IF (da_err /=  0) THEN  
     PRINT *, "Array deallocation failed: aplbce"  
     STOP  
  ENDIF
END SUBROUTINE aplbce
