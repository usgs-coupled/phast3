SUBROUTINE aplbci  
  !.....Applies the implicit terms of the boundary conditions  and the
  !.....     well source terms to the assembled equation matrix
  !.....     and right hand side
  !.....Called once for flow and for each component
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcc
  USE mcg
  USE mcm
  USE mcp
  USE mcs
  USE mcv
  USE mcw
  USE mg2
  IMPLICIT NONE
  EXTERNAL ehoftp  
  REAL(kind=kdp) :: ehoftp  
  INTRINSIC INDEX
  CHARACTER(len=9) :: cibc
  REAL(KIND=kdp) :: cavg, DQFDP, DQFWDP, DQHBC, DQHDP, DQHDT, DQHWDP, &
       DQHWDT, DQSBC, DQSDC, DQSDP, DQSWDC, DQSWDP, DQWLYR, EHAIF, EHLBC, &
       QFBC, QFWAV, QFWN, QHBC, QHWM, QLIM, qm_in, qm_net, QN, QNP, qsbc, QWN, QWNP, &
       sum_cqm_in, UFRAC
  INTEGER :: a_err, awqm, da_err, i, ic, iczm, iczp, iwel, j, k, ks, l, l1, lc, ls,  &
       m, ma, mac, mks
  LOGICAL :: erflg
  REAL(kind=kdp), DIMENSION(:), ALLOCATABLE ::  qsbc3, qsbc4, qswm
  !.....Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: aplbci.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  ERFLG = .FALSE.  
  ALLOCATE (qsbc3(ns), qsbc4(ns), qswm(ns), &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: aplbci"  
     STOP  
  ENDIF
  !.....Well source terms
  IF( .NOT.CYLIND) THEN  
     !.....Cartesian coordinates
     DO 360 IWEL = 1, NWEL  
        IF( ABS( QWM( IWEL) ) .GT.0.) THEN  
           DO 350 KS = 1, NKSWEL( IWEL)  
              MKS = MWEL( IWEL, KS)  
              QWN = QWLYR( IWEL, KS)  
              DQWLYR = DQWDPL( IWEL, KS) * ( DP( MKS) - DPWKT( IWEL) &
                   )
              QWNP = QWN + DQWLYR  
              MA = MRNO( MKS)  
              IF( IEQ.EQ.1) THEN  
                 IF( QWNP.LE.0.) THEN  
                    !.....OUTFLOW
                    QFWN = DEN( MKS) * ( QWLYR( IWEL, KS) - DQWDPL( &
                         IWEL, KS) * DPWKT( IWEL) )
                    DQFWDP = DEN( MKS) * DQWDPL( IWEL, KS)  
                    QHWM = 0.D0  
                    !                        QHWM=QFWN*(EH(MKS)+CPF*DT(MKS))
                    !                        DQHWDP=DQFWDP*(EH(MKS)+CPF*DT(MKS))
                    !                           QSWM(IS)=QFWN*(C(MKS,IS)+DC(MKS,IS))
                    !                           DQSWDP(IS)=DQFWDP*(C(MKS,IS)+DC(MKS,IS))
                 ELSE  
                    !.....INFLOW
                    QFWN = DENWK( IWEL, KS) * ( QWLYR( IWEL, KS) &
                         - DQWDPL( IWEL, KS) * DPWKT( IWEL) )
                    DQFWDP = DENWK( IWEL, KS) * DQWDPL( IWEL, KS)  
                    QHWM = 0.D0  
                    !                        QHWM=QFWN*EHWK(IWEL,KS)
                    !                        DQHWDP=DQFWDP*EHWK(IWEL,KS)
                    !                        QSWM(IS)=QFWN*CWK(IWEL,KS,IS)
                    !                        DQSWDP(IS)=DQFWDP*CWK(IWEL,KS,IS)
                 ENDIF
                 VA( 7, MA) = VA( 7, MA) - FDTMTH* DQFWDP  
                 RHS( MA) = RHS( MA) + FDTMTH* QFWN  
                 ELSEIF( IEQ.EQ.2) THEN  
                    !...  ** not available for PHAST
                    !                     IF(QWNP.LE.0.) THEN
                    !C.....OUTFLOW
                    !                        QHWM=DEN(MKS)*QWNP*EH(MKS)
                    !                        DQHWDT=DEN(M)*QWNP*CPF
                    !                        QSWM(IS)=DEN(MKS)*QWNP*(C(MKS,is)+DC(MKS,is))
                    !                     ELSE
                    !C.....INFLOW
                    !                        QHWM=DENWK(MM)*QWNP*EHWK(MM)
                    !                        DQHWDT=0.D0
                    !                        DO 862 IS=1,NS
                    !                        QSWM(IS)=DENWK(IWEL,KS)*QWNP*CWK(IWEL,KS,IS)
                    !  862                   CONTINUE
                    !                     ENDIF
                    !                     VA(7,MA)=VA(7,MA)-FDTMTH*DQHWDT
                    !                     RHS(MA)=RHS(MA)+FDTMTH*(QHWM+CC24(M)*QSWM(IS))
                 ELSEIF( IEQ.EQ.3) THEN  
                 IF( QWNP.LE.0.) THEN  
                    !.....OUTFLOW
                    QSWM( IS) = DEN( MKS) * QWNP* C( MKS, IS)  
                    DQSWDC = DEN( MKS) * QWNP  
                    !.....INFLOW
                 ELSE  
                    QSWM( IS) = DENWK( IWEL, KS) * QWNP* CWK( IWEL, &
                         KS, IS)
                    DQSWDC = 0.D0  
                 ENDIF
                 VA( 7, MA) = VA( 7, MA) - FDTMTH* DQSWDC  
                 RHS( MA) = RHS( MA) + FDTMTH* QSWM( IS)  
              ENDIF
350        END DO
        ENDIF
360  END DO
  ELSE  
     !.....Cylindrical coordinates-single well
     AWQM = MOD( ABS( WQMETH( 1) ), 100)  
     ICZM = 1  
     ICZP = 6  
     DO 380 KS = 1, NKSWEL( 1)  
        MKS = MWEL( 1, KS)  
        CALL MTOIJK( MKS, I, J, K, NX, NXY)  
        !.....Current layer flow rates from WBCFLO. These are averages over time
        !.....     step.
        QFWAV = QFLYR( 1, KS)  
        MA = MRNO( MKS)  
        IF( IEQ.EQ.1) THEN  
           IF( KS.GT.1) THEN  
              VA( ICZM, MA) = VA( ICZM, MA) - FDTMTH* TFW( K - 1)  
              VA( 7, MA) = VA( 7, MA) + FDTMTH* TFW( K - 1)  
           ENDIF
           IF( KS.LT.NKSWEL( 1) ) THEN  
              VA( ICZP, MA) = VA( ICZP, MA) - FDTMTH* TFW( K)  
              VA( 7, MA) = VA( 7, MA) + FDTMTH* TFW( K)  
           ENDIF
           !               RHS(MA)=RHS(MA)+FDTMTH*(CC34(MKS)*QSLYR(IWEL,KS,IS)+
           !     &                 CC35(MKS)*QHLYR(IWEL,KS))
           IF( KS.EQ.NKSWEL( 1) ) THEN  
              IF( AWQM.EQ.30.OR.AWQM.EQ.50) THEN  
                 DO 370 I = 1, 6  
                    VA( I, MA) = 0.D0  
370              END DO
                 VA( 7, MA) = 1.D0  
                 RHS( MA) = PWKT( 1) - P( MKS)  
              ENDIF
           ENDIF
           ELSEIF( IEQ.EQ.2) THEN  
              !... ** not available for PHAST
              !.....Implicit treatment of convective solute and heat well flows
           IF( QFWAV.LE.0.) THEN  
              !.....OUTFLOW
              DQHWDT = QFWAV* CPF  
           ELSE  
              !.....INFLOW
              DQHWDT = 0.D0  
           ENDIF
           !               VA(7,MA)=VA(7,MA)-FDTMTH*DQHWDT
           !               RHS(MA)=RHS(MA)+FDTMTH*(QHLYR(MM)+CC24(M)*QSLYR(MM))
           ELSEIF( IEQ.EQ.3) THEN  
           IF( QFWAV.LE.0.) THEN  
              !.....Outflow
              !.....Implicit treatment of solute well flows
              DQSWDC = QFWAV  
           ELSE  
              !.....Inflow
              DQSWDC = 0.D0  
           ENDIF
           VA( 7, MA) = VA( 7, MA) - FDTMTH* DQSWDC  
           RHS( MA) = RHS( MA) + FDTMTH* QSLYR( iwel, ks, is)  
        ENDIF
380  END DO
  ENDIF
  !.....Apply specified P,T or C b.c. terms
  ERFLG = .FALSE.  
  DO 450 L = 1, NSBC  
     M = MSBC( L)  
     WRITE( CIBC, 6001) IBC( M)  
6001 FORMAT   (I9)  
     MA = MRNO( M)  
     IF( IEQ.EQ.1.AND.CIBC( 1:1) .EQ.'1') THEN  
        DO 390 IC = 1, 7  
           VAFSBC( IC, L) = VA( IC, MA)  
390     END DO
        RHFSBC( L) = RHS( MA)  
        DO 400 IC = 1, 6  
           VA( IC, MA) = 0.D0  
400     END DO
        VA( 7, MA) = 1.D0  
        RHS( MA) = PSBC( L) - P( M)  
        ELSEIF( IEQ.EQ.2) THEN  
           !... ** not available for PHAST
        IF( CIBC( 4:4) .EQ.'1') THEN  
           DO 410 I = 1, 7  
              VAHSBC( I, L) = VA( I, MA)  
410        END DO
           RHHSBC( L) = RHS( MA)  
           DO 420 I = 1, 6  
              VA( I, MA) = 0.D0  
420        END DO
           VA( 7, MA) = 1.D0  
           RHS( MA) = TSBC( L) - T( M)  
           ELSEIF( CIBC( 1:1) .EQ.'1') THEN  
              !.....Implicit treatment of convective solute and heat b.c. flows
           IF( QFSBC( L) .LE.0.) THEN  
              !.....Outflow
              QHBC = QFSBC( L) * EH( M)  
              DQHDT = QFSBC( L) * CPF  
              !**               QSBC=QFSBC(L)*(C(M)+FDTMTH*DC(M))
           ELSE  
              !.....INFLOW
              IF( HEAT) QHBC = QFSBC( L) * EHOFTP( TSBC( L), &
                   P( M), ERFLG)
              DQHDT = 0.D0  
              !**               QSBC=QFSBC(L)*CSBC(L)
           ENDIF
           VA( 7, MA) = VA( 7, MA) - FDTMTH* DQHDT  
           !               RHS(MA)=RHS(MA)+QHBC+CC24(M)*QSBC
        ENDIF
        ELSEIF( IEQ.EQ.3) THEN  
        IF( CIBC( 7:7) .EQ.'1') THEN  
           DO 430 I = 1, 7  
              VASSBC( I, L, is) = VA( I, MA)  
430        END DO
           RHSSBC( L, is) = RHS( MA)  
           DO 440 I = 1, 6  
              VA( I, MA) = 0.D0  
440        END DO
           VA( 7, MA) = 1.D0  
           RHS( MA) = CSBC( L, is) - C( M, is)  
           ELSEIF( CIBC( 1:1) .EQ.'1') THEN  
           IF( QFSBC( L) .LE.0.) THEN  
              !.....Outflow
              !.....Implicit treatment of solute b.c. flows
              QSBC3( is) = QFSBC( L) * C( M, is)  
              DQSDC = QFSBC( L)  
              !.....Inflow
           ELSE  
              QSBC3( is) = QFSBC( L) * CSBC( L, is)  
              DQSDC = 0.D0  
           ENDIF
           VA( 7, MA) = VA( 7, MA) - FDTMTH* DQSDC  
           RHS( MA) = RHS( MA) + QSBC3( is)  
        ENDIF
     ENDIF
450 END DO
!!$  IF( ERFLG) THEN  
!!$     WRITE( FUCLOG, 9006) 'EHOFTP interpolation error in APLBCI ', &
!!$          'Associated heat flux: Specified value b.c.'
!!$9006 FORMAT   (TR10,2A,I4)  
!!$     IERR( 129) = .TRUE.  
!!$     ERREXE = .TRUE.  
!!$     RETURN  
!!$  ENDIF
  !.....Apply specified flux b.c. implicit terms
  DO 460 L = 1, NFBC  
     M = MFBC( L)  
     UFRAC = FRAC( M)  
     !.....Redirect the flux to the free-surface cell, if necessary
     IF( L.GE.LNZ2) THEN  
        L1 = MOD( M, NXY)  
        IF( L1.EQ.0) L1 = NXY  
        M = MFSBC( L1)  
        UFRAC = 1._kdp  
     ENDIF
     QN = QFBCV( L) * UFRAC  
     WRITE( CIBC, 6001) IBC( M)  
     IC = INDEX( CIBC( 1:3) , '2')  
     IF( IC.EQ.0) IC = INDEX( CIBC( 1:3) , '8')  
     IF( IC.GT.0) THEN  
        !.....Specified flux b.c. - associated heat and solute
        MA = MRNO( M)  
        IF( IEQ.EQ.1) THEN  
           IF( QN.LE.0.) THEN  
              !.....Outflow
              QFBC = DEN( M) * QN  
              !**               DQSBC=QFBC*DC(M)
              !                  DQHBC=QFBC*CPF*DT(M)
           ELSE  
              !.....INFLOW
              DQSBC = 0.D0  
              !                  DQHBC=0.D0
           ENDIF
           dqsbc = 0.d0  
           !              RHS(MA)=RHS(MA)+FDTMTH*(CC34(M)*DQSBC+CC35(M)*DQHBC)
           ELSEIF( IEQ.EQ.2) THEN  
              !... ** not available for PHAST
           IF( QN.LE.0.) THEN  
              !.....OUTFLOW
              !**               DQSBC=DEN(M)*QN*DC(M)
              DQHDT = DEN( M) * QN* CPF  
           ELSE  
              !.....INFLOW
              DQSBC = 0.D0  
              DQHDT = 0.D0  
           ENDIF
           VA( 7, MA) = VA( 7, MA) - FDTMTH* DQHDT  
           dqsbc = 0.d0  
           RHS( MA) = RHS( MA) + FDTMTH* CC24( M) * DQSBC  
           ELSEIF( IEQ.EQ.3) THEN  
           IF( QN.LE.0.) THEN  
              !.....OUTFLOW
              DQSDC = DEN( M) * QN  
           ELSE  
              !.....INFLOW
              DQSDC = 0.D0  
           ENDIF
           VA( 7, MA) = VA( 7, MA) - FDTMTH* DQSDC  
        ENDIF
     ENDIF
460 END DO
  !.....Apply aquifer leakage terms
  DO  l=1,nlbc
     m=mlbc(l)
     IF(frac(m) <= 0._kdp) CYCLE
     ! ... Calculate current aquifer leakage flow rate
     ! ...      Possible attenuation included explicitly
     qn=albc(l)
     qnp=qn-blbc(l)*dp(m)
     ma=mrno(m)
     IF(ieq == 1) THEN
        IF(qnp <= 0.) THEN
           ! ... Outflow
           qfbc = den(m)*qn
           dqfdp = -den(m)*blbc(l)
!!$           qhbc=qfbc*(eh(m)+cpf*dt(m))
!!$           dqhdp=dqfdp*(eh(m)+cpf*dt(m))
!!$           qsbc=qfbc*(c(m)+dc(m))
!!$           dqsdp=dqfdp*(c(m)+dc(m))
        ELSE
           ! ... Inflow
           qfbc = denlbc(l)*qn
           dqfdp = -denlbc(l)*blbc(l)
!!$           IF(heat) ehlbc=ehoftp(tlbc(l),p(m),erflg)
!!$           qhbc=qfbc*ehlbc
!!$           dqhdp=dqfdp*ehlbc
!!$           qsbc=qfbc*clbc(l)
!!$           dqsdp=dqfdp*clbc(l)
        END IF
        va(7,ma) = va(7,ma) - fdtmth*dqfdp
        rhs(ma) = rhs(ma) + fdtmth*qfbc
!!$     ELSE IF(ieq == 2) THEN     ! ... ** not available for PHAST
!!$        IF(qnp <= 0.) THEN
!!$           ! ... Outflow
!!$           qsbc=den(m)*qnp*(c(m)+dc(m))
!!$           qhbc=den(m)*qnp*eh(m)
!!$           dqhdt=den(m)*qnp*cpf
!!$        ELSE
!!$           ! ... Inflow
!!$           qsbc=denlbc(l)*qnp*clbc(l)
!!$           IF(heat) qhbc=denlbc(l)*qnp*ehoftp(tlbc(l),p(m),erflg)
!!$           dqhdt=0._kdp
!!$        END IF
!!$        va(7,ma)=va(7,ma)-fdtmth*dqhdt
!!$        rhs(ma)=rhs(ma)+fdtmth*(qhbc+cc24(m)*qsbc)
     ELSE IF(ieq == 3) THEN
        IF(qnp <= 0.) THEN
           ! ... Outflow
           qsbc4(is) = den(m)*qnp*c(m,is)
           dqsdc = den(m)*qnp
        ELSE
           ! ... Inflow
           qsbc4(is) = denlbc(l)*qnp*clbc(l,is)
           dqsdc = 0._kdp
        END IF
        va(7,ma) = va(7,ma) - fdtmth*dqsdc
        rhs(ma) = rhs(ma) + fdtmth*qsbc4(is)
     END IF
  END DO
  ! ... Apply river leakage terms
  DO lc=1,nrbc_cells  
     m = river_seg_index(lc)%m     ! ... current river communication cell
     !.....Calculate current net aquifer leakage flow rate
     !.....     Possible attenuation included explicitly
     qm_net = 0._kdp
     qfbc = 0._kdp
     dqfdp = 0._kdp
     DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
        qn = arbc(ls)
        qnp = qn - brbc(ls)*dp(m)      ! ... with only one flow equation solution qnp = qn always
        IF(qnp <= 0._kdp) THEN
           ! ... Outflow
           qm_net = qm_net + den(m)*qnp
           qfbc = qfbc + den(m)*qn
           dqfdp = dqfdp - den(m)*brbc(ls)
!          write(*,*) 1, qfbc, dqfdp, qnp, brbc(ls), p(m)/9807.0_kdp, m, arbc(ls)
        ELSE
           ! ... Inflow
           !.....Limit the flow rate for a river leakage
           qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                - 0.5_kdp*den(m)*bbrbc(ls)))
           IF(qnp <= qlim ) THEN
              qm_net = qm_net + denrbc(ls)*qnp
              qfbc = qfbc + denrbc(ls)*qn  
              dqfdp = dqfdp - denrbc(ls)*brbc(ls)
!              write(*,*) 2, qfbc, dqfdp, qnp, brbc(ls), p(m)/9807.0_kdp, m, qlim
           ELSEIF(qnp > qlim) THEN
              qm_net = qm_net + denrbc(ls)*qlim
              qfbc = qfbc + denrbc(ls)*qlim
              ! Hack for instability from the kink in q vs h relation
              if (steady_flow) dqfdp = dqfdp - denrbc(ls)*brbc(ls)
!              write(*,*) 3, qfbc, dqfdp, qnp, brbc(ls), p(m)/9807.0_kdp, m, qlim
              ! ... Add nothing to dqfdp
           ENDIF
        ENDIF
     END DO
     ma = mrno(m)
     IF(ieq == 1) THEN
        va(7,ma) = va(7,ma) - fdtmth*dqfdp
        rhs(ma) = rhs(ma) + fdtmth*qfbc
!!$     ELSEIF( IEQ.EQ.2) THEN
!!$        !... ** not available for PHAST
!!$        IF( QNP.LE.0.) THEN  
!!$           !.....Outflow
!!$           !**            QSBC=DEN(M)*QNP*(C(M)+DC(M))
!!$           QHBC = DEN( M) * QNP* EH( M)  
!!$           DQHDT = DEN( M) * QNP* CPF  
!!$        ELSE  
!!$           !.....INFLOW
!!$           IF( HEAT) QHBC = DENLBC( L) * QNP* EHOFTP( TLBC( L), &
!!$                P( M), ERFLG)
!!$           DQHDT = 0.D0  
!!$        ENDIF
!!$        VA( 7, MA) = VA( 7, MA) - FDTMTH* DQHDT  
!!$        !            RHS(MA)=RHS(MA)+FDTMTH*(QHBC+CC24(M)*QSBC)
     ELSEIF(ieq == 3) THEN
        IF(qm_net <= 0._kdp) THEN
           ! ... Outflow
           qsbc4(is) = qm_net*c(m,is)  
           dqsdc = qm_net  
        ELSE  
           ! ... Inflow
           ! ... Calculate flow weighted average concentrations for inflow segments
           qm_in = 0._kdp
           sum_cqm_in = 0._kdp
           DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
              qnp = arbc(ls) - brbc(ls)*dp(m)
              IF(qnp > 0._kdp) THEN  
                 ! ... Inflow
                 ! ... Limit the flow rate for a river leakage
                 qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*  &
                      (zerbc(ls)-0.5_kdp*bbrbc(ls)) - 0.5_kdp*den(m)*bbrbc(ls)))
                 qnp = MIN(qnp,qlim)
                 qm_in = qm_in + denrbc(ls)*qnp
                 sum_cqm_in = sum_cqm_in + denrbc(ls)*qnp*crbc(ls,is)  
              ENDIF
           END DO
           cavg = sum_cqm_in/qm_in
           qsbc4(is) = qm_net*cavg
           dqsdc = 0._kdp
        ENDIF
        va(7,ma) = va(7,ma) - fdtmth*dqsdc 
        rhs(ma) = rhs(ma) + fdtmth*qsbc4(is)
     ENDIF
  END DO
!!$  IF( ERFLG) THEN  
!!$     WRITE( FUCLOG, 9006) 'EHOFTP interpolation error in APLBCI ', &
!!$          'Associated heat flux: Leakage b.c.'
!!$     IERR( 129) = .TRUE.  
!!$     ERREXE = .TRUE.  
!!$     RETURN  
!!$  ENDIF
  !.....Apply a.i.f. b.c. terms
  !... ** not implemented for PHAST
!!$  DO 480 L = 1, NAIFC  
!!$     !.....Calculate current aquifer influence function flow rate
!!$     M = MAIFC( L)  
!!$     QN = AAIF( L)  
!!$     QNP = QN + BAIF( L) * DP( M)  
!!$     MA = MRNO( M)  
!!$     IF( IEQ.EQ.1) THEN  
!!$        IF( QNP.LE.0) THEN  
!!$           !.....OUTFLOW
!!$           QFBC = DEN( M) * QN  
!!$           DQFDP = DEN( M) * BAIF( L)  
!!$           !**            QSBC=QFBC*(C(M)+DC(M))
!!$           !**            DQSDP=DQFDP*(C(M)+DC(M))
!!$           QHBC = QFBC* ( EH( M) + CPF* DT( M) )  
!!$           DQHDP = DQFDP* ( EH( M) + CPF* DT( M) )  
!!$        ELSE  
!!$           !.....INFLOW
!!$           QFBC = DENOAR( L) * QN  
!!$           DQFDP = DENOAR( L) * BAIF( L)  
!!$           !               QSBC=QFBC*CAIF(L)
!!$           IF( HEAT) EHAIF = EHOFTP( TAIF( L), P( M), ERFLG)  
!!$           DQSDP = DQFDP* CAIF( L)  
!!$           QHBC = QFBC* EHAIF  
!!$           DQHDP = DQFDP* EHAIF  
!!$        ENDIF
!!$        qsbc = 0.d0  
!!$        VA( 7, MA) = VA( 7, MA) - FDTMTH* ( DQFDP + CC34( M) * &
!!$             DQSDP + CC35( M) * DQHDP)
!!$        RHS( MA) = RHS( MA) + FDTMTH* ( QFBC + CC34( M) * QSBC + &
!!$             CC35( M) * QHBC)
!!$        ELSEIF( IEQ.EQ.2) THEN  
!!$        IF( QNP.LE.0.) THEN  
!!$           !.....OUTFLOW
!!$           !**            QSBC=DEN(M)*QNP*(C(M)+DC(M))
!!$           QHBC = DEN( M) * QNP* EH( M)  
!!$           DQHDT = DEN( M) * QNP* CPF  
!!$        ELSE  
!!$           !.....INFLOW
!!$           !               QSBC=DENOAR(L)*QNP*CAIF(L)
!!$           IF( HEAT) QHBC = DENOAR( L) * QNP* EHOFTP( TAIF( L), &
!!$                P( M), ERFLG)
!!$           DQHDT = 0.D0  
!!$        ENDIF
!!$        VA( 7, MA) = VA( 7, MA) - FDTMTH* DQHDT  
!!$        !            RHS(MA)=RHS(MA)+FDTMTH*(QHBC+CC24(M)*QSBC)
!!$        ELSEIF( IEQ.EQ.3) THEN  
!!$        IF( QNP.LE.0.) THEN  
!!$           !.....OUTFLOW
!!$           !**            QSBC=DEN(M)*QNP*C(M)
!!$           DQSDC = DEN( M) * QNP  
!!$           !.....INFLOW
!!$        ELSE  
!!$           !               QSBC=DENOAR(L)*QNP*CAIF(L)
!!$           DQSDC = 0.D0  
!!$        ENDIF
!!$        VA( 7, MA) = VA( 7, MA) - FDTMTH* DQSDC  
!!$        !            RHS(MA)=RHS(MA)+FDTMTH*QSBC
!!$     ENDIF
!!$480 END DO
!!$  IF( ERFLG) THEN  
!!$     WRITE( FUCLOG, 9006) 'EHOFTP interpolation error in APLBCI ', &
!!$          'Associated heat flux: Aquifer influence function b.c.'
!!$     IERR( 129) = .TRUE.  
!!$     ERREXE = .TRUE.  
!!$     RETURN  
!!$  ENDIF
!!$  !.....Heat conduction boundary condition
!!$  !... **  not implemented for PHAST
!!$  IF( IEQ.EQ.2) THEN  
!!$     DO  L = 1, NHCBC  
!!$        M = MHCBC( L)  
!!$        MA = MRNO( M)  
!!$        VA( 7, MA) = VA( 7, MA) - FDTMTH* DQHCDT( L)  
!!$     END DO
!!$  ENDIF
  IF( FRESUR) THEN  
     !.....Free-surface boundary condition
     DO M = 1, NXYZ  
        IF( FRAC( M) .LE.0.) THEN  
           !.....Solve trivial equation for transient dry cells
           MA = MRNO( M)  
           WRITE( CIBC, 6001) IBC( M)  
           IF( ( IEQ.EQ.1.AND.CIBC( 1:1)  /= '1') .OR.( &
                IEQ.EQ.3.AND.CIBC( 7:7)  /= '1') ) THEN
              VA( 7, MA) = 1.D0  
              RHS( MA) = 0.D0  
!              IF(SLMETH.EQ.1) THEN  
                 !.....Zero the VA coefficients for cells connected to an empty cell
                 !.....     to resymmetrize the matrix
                 DO ic = 1,6  
                    mac = ci(ic,ma)  
                    if(mac.gt.0) va(7-ic,mac) = 0.d0  
                 END DO
!              ENDIF
           ENDIF
        ENDIF
     END DO
  ENDIF
  DEALLOCATE (qsbc3, qsbc4, qswm, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed"  
     STOP  
  ENDIF
END SUBROUTINE aplbci
