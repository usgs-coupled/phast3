SUBROUTINE rhsn_manager
  ! ... Calculates and loads the step cumulative totals for the first portion
  ! ...      of the time step
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcm
  USE mcm_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  IMPLICIT NONE
  INTRINSIC INT
  REAL(KIND=kdp) :: qfbc, qlim, qm_in, qm_net, qn, szzw, ucwt, ufdt0, ufrac, wt
  REAL(KIND=kdp) :: hrbc
  INTEGER :: a_err, da_err, i, iis, iwel, iwfss, j, k, ks, l, lc0, l1,  &
       lc, ls, m, mc0, mfs, mkt, nks, nsa
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: cavg, sum_cqm_in
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qsbc3, qsbc4
  !     ------------------------------------------------------------------
  !...
  rf = 0._kdp

  ufdt0 = 1._kdp-fdtmth
  ntsfal=0         ! ... Set number of failed time steps to zero
  ! ... Initialize the step b.c. flow accumulators
  !...  ***This could be put into an init4 routine***
  stotfi = 0._kdp
  stothi = 0._kdp
  stotfp = 0._kdp
  stothp = 0._kdp
  stotsi = 0._kdp
  stotsp = 0._kdp
  stffbc = 0._kdp
  stflbc = 0._kdp
  stfrbc = 0._kdp
  stfdbc = 0._kdp
  stfsbc = 0._kdp
  stfwel = 0._kdp
  sthfbc = 0._kdp
  sthhcb = 0._kdp
  sthlbc = 0._kdp
  sthsbc = 0._kdp
  sthwel = 0._kdp
  stssbc = 0._kdp
  stsfbc = 0._kdp
  stslbc = 0._kdp
  stsrbc = 0._kdp
  stsdbc = 0._kdp
  stswel = 0._kdp
  IF (nwel > 0) THEN
     stfwi = 0._kdp
     stfwp = 0._kdp
     stswi = 0._kdp
     stswp = 0._kdp
  END IF
  IF (solute) sirn = sir 
  nsa = MAX(ns,1)
  ! ... Allocate scratch space
  ALLOCATE (qsbc3(nsa), qsbc4(nsa), &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: rhsn"  
     STOP  
  ENDIF
  ! ... Load current total fluid mass amount into storage
  ! ...      for nth time level
  firn=fir
  ! ... Load rhs with well, heat and solute explicit flow rates at each layer
  DO  iwel=1,nwel
     IF(wqmeth(iwel) == 0) CYCLE
     ! ... Step cumulative flow rates from wells. To be converted to amounts
     ! ...      in SUMCAL
     iwfss=INT(SIGN(1._kdp,-qwm_n(iwel)))
     IF(ABS(qwm_n(iwel)) < MIN_WELL_FLOW) iwfss=0
     IF(iwfss >= 0) THEN            ! ... Production well
        stfwp(iwel) = -ufdt0*qwm_n(iwel)
        stotfp = stotfp+stfwp(iwel)
        DO  iis=1,ns
           stswp(iwel,iis) = -ufdt0*qsw_n(iwel,iis)
           stotsp(iis)=stotsp(iis)+stswp(iwel,iis)
        END DO
     ELSE IF(iwfss < 0) THEN        ! ... Injection well
        stfwi(iwel) = ufdt0*qwm_n(iwel)
        stotfi = stotfi+stfwi(iwel)
        DO  iis=1,ns
           stswi(iwel,iis) = ufdt0*qsw_n(iwel,iis)
           stotsi(iis)=stotsi(iis)+stswi(iwel,iis)
        END DO
     END IF
  END DO
  ! ... Specified P,T,or C b.c. terms are applied in ASEMBL
  IF(nfbc > 0) THEN
     ! ... Apply specified flux b.c. dispersive and advective terms
     DO lc=1,nfbc_cells
        m = flux_seg_m(lc)
        sffb(lc) = 0._kdp
        sfvfb(lc) = 0._kdp
        ssfb(lc,:) = 0._kdp
        IF(m == 0) CYCLE     ! ... dry column
        DO ls=flux_seg_first(lc),flux_seg_last(lc)
           ufrac = 1._kdp
           IF(ABS(ifacefbc(ls)) < 3) ufrac = frac(m)  
           IF(fresur .AND. ifacefbc(ls) == 3 .AND. frac(m) <= 0._kdp) THEN
              ! ... Redirect the flux from above to the free-surface cell
              l1 = MOD(m,nxy)
              IF(l1 == 0) l1 = nxy
              m = mfsbc(l1)
           ENDIF
           IF(m == 0) EXIT     ! ... dry column, skip to next flux b.c. cell
           ! ... Calculate step total flow rate contributions and
           ! ...      cell step flow rate contributions.
           qn = qfflx_n(ls)*areafbc(ls)
           sfvfb(lc) = sfvfb(lc) + qn
           IF(qn <= 0.) THEN        ! ... Outflow
              qfbc = den0*qn*ufrac
              stotfp = stotfp-ufdt0*qfbc
              DO  iis=1,ns
                 qsbc3(iis) = qfbc*c(m,iis)
                 stotsp(iis) = stotsp(iis)-ufdt0*qsbc3(iis)
              END DO
           ELSE                     ! ... Inflow
              qfbc = denfbc(ls)*qn*ufrac
              stotfi = stotfi+ufdt0*qfbc
              DO  iis=1,ns
                 qsbc3(iis) = qfbc*cfbc_n(ls,iis)
                 stotsi(iis) = stotsi(iis)+ufdt0*qsbc3(iis)
              END DO
           END IF
           ! need rf here?         rf(m) = rf(m) + ufdt0*qfbc
           sffb(lc) = sffb(lc) + qfbc
           stffbc = stffbc + ufdt0*qfbc
           DO  iis=1,ns
              qsbc4(iis) = qsflx_n(ls,iis)*areafbc(ls)*ufrac
              IF(qsbc4(iis) <= 0.) THEN
                 stotsp(iis) = stotsp(iis) - ufdt0*qsbc4(iis)
              ELSE
                 stotsi(iis) = stotsi(iis) + ufdt0*qsbc4(iis)
              END IF

              ssfb(lc,iis) = ssfb(lc,iis) + qsbc3(iis)+qsbc4(iis)
              stsfbc(iis) = stsfbc(iis) + ufdt0*(qsbc4(iis)+qsbc3(iis))
           END DO
        END DO
     END DO
  END IF
  IF(nlbc > 0) THEN
     ! ... Calculate leakage b.c. terms
     ! ... Allocate scratch space
     ALLOCATE (cavg(nsa), sum_cqm_in(nsa),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: rhsn, point 2"  
        STOP
     ENDIF
     IF(fresur) THEN
        DO lc=1,nlbc
           ! ... Update the indices locating the cells communicating with leaky layer
           mc0 = leak_seg_m(lc)
           lc0 = MOD(mc0,nxy)
           IF(lc0 == 0) lc0 = nxy
           mfs = mfsbc(lc0)    ! ... currrent f.s. cell in column lc0
           !$$     leak_seg_index(lc)%m = MIN(mfs,mrbc_bot(lc))
           DO ls=leak_seg_first(lc),leak_seg_last(lc)
              IF(ifacelbc(ls) == 3) THEN
                 leak_seg_m(lc) = mfs            ! ... communicate with f.s. cell always
                 !$$        mrbc(ls) = MIN(mfs,mrseg_bot(ls))    ! ... currrent leakage segment cell 
                 mlbc(ls) = leak_seg_m(lc)     ! ... currrent leakage segment cell for aquifer head
              END IF                            ! ... now the same as communication cell
           END DO
        END DO
     END IF
     DO  lc=1,nlbc
        m = leak_seg_m(lc)
        sflb(lc) = 0._kdp
        sfvlb(lc) = 0._kdp
        sslb(lc,:) = 0._kdp
        IF(m == 0) CYCLE              ! ... empty column 
        ! ... Calculate current net aquifer leakage flow rate
        qm_net = 0._kdp
        DO ls=leak_seg_first(lc),leak_seg_last(lc)
           qn = albc(ls)
           IF(qn <= 0._kdp) THEN       ! ... Outflow
              qm_net = qm_net + den0*qn
              sfvlb(lc) = sfvlb(lc) + qn
           ELSE                          ! ... Inflow
              IF(fresur .AND. ifacelbc(ls) == 3) THEN
                 ! ... Limit the flow rate for unconfined z-face leakage from above
                 qlim = blbc(ls)*(denlbc(ls)*philbc_n(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
                      - 0.5_kdp*den0*bblbc(ls)))
                 qn = MIN(qn,qlim)
              END IF
              qm_net = qm_net + denlbc(ls)*qn
              sfvlb(lc) = sfvlb(lc) + qn
           END IF
        END DO
        rf(m) = rf(m) + ufdt0*qm_net
        qflbc(lc) = qm_net
        sflb(lc) = sflb(lc) + qflbc(lc)
        stflbc = stflbc + ufdt0*qflbc(lc)
        IF(qm_net <= 0._kdp) THEN           ! ... net outflow
           stotfp = stotfp - ufdt0*qflbc(lc)
           DO  iis=1,ns
              qsbc4(iis) = qflbc(lc)*c(m,iis)
              stotsp(iis) = stotsp(iis) - ufdt0*qsbc4(iis)
           END DO
        ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
           stotfi = stotfi + ufdt0*qflbc(lc)
           ! ... calculate flow weighted average concentrations for inflow segments
           qm_in = 0._kdp
           sum_cqm_in = 0._kdp
           DO ls=leak_seg_first(lc),leak_seg_last(lc)
              qn = albc(ls)
              IF(qn > 0._kdp) THEN                   ! ... inflow
                 qm_in = qm_in + denlbc(ls)*qn
                 DO  iis=1,ns
                    sum_cqm_in(iis) = sum_cqm_in(iis) + denlbc(ls)*qn*clbc_n(ls,iis)
                 END DO
              ENDIF
           END DO
           if (qm_in .gt. 0.0_kdp) then
               DO iis=1,ns
                   cavg(iis) = sum_cqm_in(iis)/qm_in
                   qsbc4(iis) = qm_net*cavg(iis)
                   stotsi(iis) = stotsi(iis) + ufdt0*qsbc4(iis)
                   sslb(lc,iis) = sslb(lc,iis) + qsbc4(iis)
                   stslbc(iis) = stslbc(iis) + ufdt0*qsbc4(iis)
               END DO
           endif
        ENDIF
     END DO
     DEALLOCATE (cavg, sum_cqm_in, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed, rhsn_manager"  
        STOP
     ENDIF
  END IF

  IF(nrbc > 0) THEN
     ! ... Calculate river leakage b.c. terms
     ! ... Allocate scratch space
     ALLOCATE (cavg(nsa), sum_cqm_in(nsa),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: rhsn_manager, point 3"
        STOP
     ENDIF
     DO lc=1,nrbc
        ! ... Update the indices locating the cells communicating with the river
        mc0 = river_seg_m(lc)
        lc0 = MOD(mc0,nxy)
        IF(lc0 == 0) lc0 = nxy
        mfs = mfsbc(lc0)    ! ... currrent f.s. cell
        !$$     river_seg_index(lc)%m = MIN(mfs,mrbc_bot(lc))
        river_seg_m(lc) = mfs            ! ... communicate with f.s. cell always
        DO ls=river_seg_first(lc),river_seg_last(lc)
           !$$        mrbc(ls) = MIN(mfs,mrseg_bot(ls))     ! ... currrent river segment cell for aquifer head
           mrbc(ls) = river_seg_m(lc)       ! ... currrent river segment cell for aquifer head
           ! ... now the same as communication cell
        END DO
     END DO
     ! ...      Calculate step total flow rates and cell step flow rates.
     DO  lc=1,nrbc                    ! ... by river cell communicating to aquifer
         m = river_seg_m(lc)       ! ... current communicating cell 
         sfrb(lc) = 0._kdp
         sfvrb(lc) = 0._kdp
         ssrb(lc,:) = 0._kdp
         IF(m == 0) CYCLE              ! ... dry column, skip to next river b.c. cell 
         ! ... Calculate current net river leakage flow rate
         qm_net = 0._kdp
         DO ls=river_seg_first(lc),river_seg_last(lc)
             if (arbc(ls) .gt. 1.0e50_kdp) cycle
             qn = arbc(ls)
             hrbc = phirbc(ls)/gz
             if(hrbc > zerbc(ls)) then      ! ... treat as river
                 IF(qn <= 0._kdp) THEN           ! ... Outflow
                     qm_net = qm_net + den0*qn
                     sfvrb(lc) = sfvrb(lc) + qn
                 ELSE                            ! ... Inflow
                     ! ... Limit the flow rate for a river leakage
                     qlim = brbc(ls)*(denrbc(ls)*phirbc_n(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                     - 0.5_kdp*den0*bbrbc(ls)))
                     qn = MIN(qn,qlim)
                     qm_net = qm_net + denrbc(ls)*qn
                     sfvrb(lc) = sfvrb(lc) + qn
                 END IF
             else                           ! ... treat as drain 
                 IF(qn <= 0._kdp) THEN      ! ... Outflow
                     !qfbc = den(m)*qn
                     qm_net = qm_net + den0*qn
                     !stotfp = stotfp - ufdt0*qfbc
                     sfvrb(lc) = sfvrb(lc) + qn
                 ELSE                        ! ... Inflow, none allowed
                     !qn = 0._kdp
                     !qfbc = 0._kdp
                     !stotfi = stotfi + ufdt0*qfbc
                     !sfvrb(lc) = sfvrb(lc) + qn
                 END IF
             end if              
         END DO
         rf(m) = rf(m) + ufdt0*qm_net
         qfrbc(lc) = qm_net
         sfrb(lc) = sfrb(lc) + qfrbc(lc)
         stfrbc = stfrbc + ufdt0*qfrbc(lc)
         IF(qm_net <= 0._kdp) THEN           ! ... net outflow
             stotfp = stotfp - ufdt0*qfrbc(lc)
             DO  iis=1,ns
                 qsbc3(iis) = qfrbc(lc)*c(m,iis)
                 stotsp(iis) = stotsp(iis) - ufdt0*qsbc3(iis)
             END DO
         ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
             stotfi = stotfi + ufdt0*qfrbc(lc)
             ! ... calculate flow weighted average concentrations for inflow segments
             qm_in = 0._kdp
             sum_cqm_in = 0._kdp
             DO ls=river_seg_first(lc),river_seg_last(lc)
                 if (arbc(ls) .gt. 1.0e50_kdp) cycle
                 qn = arbc(ls)
                 IF(qn > 0._kdp) THEN                   ! ... inflow
                     ! ... limit the flow rate for a river leakage
                     qlim = brbc(ls)*(denrbc(ls)*phirbc_n(ls) - gz*(denrbc(ls)*  &
                     (zerbc(ls)-0.5_kdp*bbrbc(ls)) - 0.5_kdp*den0*bbrbc(ls)))
                     qn = MIN(qn,qlim)
                     qm_in = qm_in + denrbc(ls)*qn
                     DO  iis=1,ns              
                         sum_cqm_in(iis) = sum_cqm_in(iis) + denrbc(ls)*qn*crbc_n(ls,iis)
                     END DO
                 ENDIF
             END DO
             if (qm_in .gt. 0.0_kdp) then
                 DO iis=1,ns
                     cavg(iis) = sum_cqm_in(iis)/qm_in
                     qsbc4(iis) = qm_net*cavg(iis)
                     stotsi(iis) = stotsi(iis) + ufdt0*qsbc4(iis)
                     !!$           rs(m,iis) = rs(m,iis) + ufdt0*qsbc4(iis)
                     ssrb(lc,iis) = ssrb(lc,iis) + qsbc4(iis)
                     stsrbc(iis) = stsrbc(iis) + ufdt0*qsbc4(iis)
                 END DO
             endif
         else                       ! ... no inflow or outflow; treat as drain
             !qn = 0._kdp
             !qfbc = 0._kdp
             !stotfi = stotfi + ufdt0*qfbc
             !sfvrb(lc) = sfvrb(lc) + qn
             !DO  iis=1,ns
             !    qsbc3(iis) = 0._kdp
             !    stotsi(iis) = stotsi(iis) + ufdt0*qsbc3(iis)
             !END DO
         ENDIF
     END DO
     DEALLOCATE (cavg, sum_cqm_in, &
          stat = da_err)
     IF (da_err /= 0) THEN
        PRINT *, "Array deallocation failed, rhsn"
        STOP
     ENDIF
  END IF
  IF(ndbc > 0) THEN
     ! ... Calculate drain leakage b.c. terms
     DO lc=1,ndbc
        ! ... Update the indices locating the cells communicating with the drain
        !$$     mc0 = drain_seg_index(lc)%m
        !$$     !lc0 = MOD(mc0,nxy)
        !$$     !IF(lc0 == 0) lc0 = nxy
        !$$     !mfs = mfsbc(lc0)    ! ... currrent f.s. cell
        !$$     drain_seg_index(lc)%m = MIN(mfs,mdbc_bot(lc))
        !$$     !drain_seg_index(lc)%m = mfs            ! ... communicate with f.s. cell always
        DO ls=drain_seg_first(lc),drain_seg_last(lc)
           !$$        mdbc(ls) = MIN(mfs,mrseg_bot(ls))     ! ... currrent drain segment cell for aquifer head
           !$$        !mdbc(ls) = drain_seg_index(lc)%m     ! ... currrent drain segment cell for aquifer head
           ! ... now the same as communication cell
           drain_seg_m(lc) = mdbc(ls)                                    
        END DO
     END DO
     ! ...      Calculate step total flow rates and cell step flow rates.
     DO  lc=1,ndbc                    ! ... by drain cell communicating to aquifer
        m = drain_seg_m(lc)       ! ... current communicating cell 
        sfdb(lc) = 0._kdp
        sfvdb(lc) = 0._kdp
        ssdb(lc,:) = 0._kdp
        IF(m == 0) CYCLE              ! ... dry column 
        DO ls=drain_seg_first(lc),drain_seg_last(lc)
           if (adbc(ls) .gt. 1.0e50_kdp) cycle
           qn = adbc(ls)
           IF(qn <= 0.) THEN      ! ... Outflow
              qfbc = den0*qn
              stotfp = stotfp - ufdt0*qfbc
              sfvdb(lc) = sfvdb(lc) + qn
              DO  iis=1,ns
                 qsbc3(iis) = qfbc*c(m,iis)
                 stotsp(iis) = stotsp(iis) - ufdt0*qsbc3(iis)
              END DO
           ELSE                        ! ... Inflow, none allowed
              qn = 0._kdp
              qfbc = 0._kdp
              !stotfi = stotfi + ufdt0*qfbc
              !sfvdb(lc) = sfvdb(lc) + qn
              !DO  iis=1,ns
              !   qsbc3(iis) = 0._kdp
              !   stotsi(iis) = stotsi(iis) + ufdt0*qsbc3(iis)
              !END DO
           END IF
            ! need rf? rf(m) = rf(m) + ufdt0*qfbc
           sfdb(lc) = sfdb(lc) + qfbc
           stfdbc = stfdbc + ufdt0*qfbc
           DO  iis=1,ns
              ssdb(lc,iis) = ssdb(lc,iis) + qsbc3(iis)
              stsdbc(iis) = stsdbc(iis) + ufdt0*qsbc3(iis)
           END DO
        END DO
     END DO
  END IF

!!$  ! ... Calculate aquifer influence function b.c. terms
!!$  ! ...      Calculate step total flow rates and nodal step flow rates
!!$  !... *** not implemented in PHAST

  DEALLOCATE (qsbc3, qsbc4,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, rhsn_manager"  
     STOP
  ENDIF
END SUBROUTINE rhsn_manager
