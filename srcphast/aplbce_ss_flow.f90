SUBROUTINE aplbce_ss_flow  
  ! ... Applies right hand side terms from b.c.
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcv
  USE mg2
  USE phys_const
  IMPLICIT NONE
  REAL(KIND=kdp) ::  delp2, dpudt, dqetdp, dzfsdp, eta, &
       ltd, p00, p1, pu, qfbc, qhbc, qhbc2, qn, timed, &
       timedn, ufdt2, ufrac, uphim, uzav, z0, z1, zfsa
  INTEGER :: a_err, da_err, imod, iis, k, ks, l, l1, lc, ll, ls, m, mc, ms 
  LOGICAL :: erflg  
  CHARACTER(LEN=9) :: cibc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qsbc, qsbc2
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
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: aplbce_ss_flow"  
     STOP  
  ENDIF
  DO L = 1, NFBC  
     M = MFBC(L)  
     UFRAC = 1._kdp  
     IF(L.LT.LNZ2) UFRAC = FRAC(M)  
     ! ... Redirect the flux to the free-surface cell, if necessary
     IF(L.GE.LNZ2) THEN  
        L1 = MOD(M, NXY)  
        IF(L1.EQ.0) L1 = NXY  
        M = MFSBC(L1)  
        UFRAC = 1._kdp  
     ENDIF
     QN = QFBCV(L)  
     IF(QN.LE.0.) THEN  
        ! ... Outflow
        QFBC = DEN(M) * QN* UFRAC  
     ELSE  
        ! ... Inflow
        QFBC = DENFBC(L) * QN* UFRAC  
     ENDIF
     RF(M) = RF(M) + UFDT2* QFBC  
  END DO
  ! ... Calculate leakage b.c. coefficients
  ! ...      only for horizontal coordinates
  DO 20 L = 1, NLBC  
     M = MLBC(L)  
     ALBC(L) = 0._kdp
     BLBC(L) = 0._kdp
     UFRAC = FRAC(M)  
     ! ... No flow to or from empty cells, and attenuate flows
     ! ...      at partially saturated cells.
     IF(UFRAC.GT.0.) THEN  
        IMOD = MOD(M, NXY)  
        K = (M - IMOD) / NXY + MIN(1, IMOD)  
        WRITE(CIBC, 6001) IBC(M)  
6001    FORMAT(I9)  
        IF(CIBC(3:3) .EQ.'3') THEN  
           UZAV = ZELBC(L) - .5* BBLBC(L)  
        ELSE  
           UZAV = ZELBC(L)  
        ENDIF
        UPHIM = P(M) + GZ* (DENLBC(L) - DEN(M) ) * UZAV  
        BLBC(L) = KLBC(L) * UFRAC/ VISLBC(L)  
        ALBC(L) = BLBC(L) * ((DENLBC(L) * PHILBC(L) - DEN(M) &
             * GZ* Z(K) ) - UPHIM)
        ! ... Attenuate the flow rate for a partially saturated cell with
        ! ...      leakage through a lateral face
        IF(CIBC(1:1) .EQ.'3'.OR.CIBC(2:2) .EQ.'3') THEN  
           ALBC(L) = UFRAC* ALBC(L)  
           BLBC(L) = UFRAC* BLBC(L)  
        ENDIF
     ENDIF
20 END DO
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
        ! ...   now ms = mc
        imod = MOD(ms,nxy)
        ks = (ms - imod)/nxy + MIN(1,imod)
        uphim = p(ms) + gz*(denrbc(ls) - den(ms))*uzav
        brbc(ls) = krbc(ls)/visrbc(ls)
        arbc(ls) = brbc(ls)*((denrbc(ls)*phirbc(ls) - den(ms)*gz*z(ks)) - uphim)
     END DO
  END DO
!!$  IF(NAIFC.GT.0) THEN  
!!$     !... *** not implemented for PHAST
!!$     ! ... Calculate aquifer influence function b.c. terms
!!$     ! ... ***This section is missed if the time step is repeated***
!!$     IF(IAIF.EQ.2) THEN  
!!$        ! ... Carter-Tracy influence functions
!!$        ! ... Calculate dimensionless time
!!$        TIMED = (TIME+DELTIM) * FTDAIF  
!!$        TIMEDN = TIME* FTDAIF  
!!$        ! ... Find pressure influence function and slope by approximate
!!$        ! ...      equation from FANCHI
!!$        IF(timed <= 0.01_kdp) THEN  
!!$           PU = - 2.* SQRT(TIMED/PI)  
!!$           DPUDT = - 1._kdp/ SQRT(TIMED* PI)  
!!$           ELSEIF(timed >= 1000._kdp) THEN  
!!$           PU = - .5*(LOG(timed) + 0.80907_kdp)  
!!$           DPUDT = - .5/timed  
!!$        ELSE  
!!$           LTD = LOG(timed)  
!!$           PU = BBAIF(0) + BBAIF(1) * TIMED+BBAIF(2) * LTD+BBAIF(&
!!$                3) * LTD* LTD
!!$           DPUDT = BBAIF(1) + (BBAIF(2) + 2.* BBAIF(3) * &
!!$                LTD) / TIMED
!!$        ENDIF
!!$     ENDIF
!!$     DO 30 L = 1, NAIFC  
!!$        M = MAIFC(L)  
!!$        UFRAC = FRAC(M)  
!!$        IF(L.GE.LNZ4) THEN  
!!$           L1 = MOD(M, NXY)  
!!$           IF(L1.EQ.0) L1 = NXY  
!!$           M = MFSBC(L1)  
!!$           UFRAC = 1._kdp
!!$        ENDIF
!!$        IF(IAIF.EQ.1) THEN  
!!$           ! ... Pot aquifer
!!$           AAIF(L) = 0._kdp
!!$           BAIF(L) = - VAIFC(L) * UFRAC/ DELTIM  
!!$           ELSEIF(IAIF.EQ.2) THEN  
!!$              ! ... Carter-Tracy
!!$           AAIF(L) = F1AIF* VAIFC(L) * ((P(M) - PAIF(L) ) &
!!$                - DPUDT* WCAIF(L) * F2AIF) * UFRAC/ (PU - DPUDT* &
!!$                TIMEDN)
!!$           BAIF(L) = F1AIF* VAIFC(L) * UFRAC/ (PU - DPUDT* &
!!$                TIMEDN)
!!$        ENDIF
!!$30   END DO
!!$  ENDIF
  DEALLOCATE (qsbc, qsbc2, &
       stat = da_err)
  IF (da_err.NE.0) THEN  
     PRINT *, "Array deallocation failed: aplbce_ss_flow"  
     STOP  
  ENDIF
END SUBROUTINE aplbce_ss_flow
