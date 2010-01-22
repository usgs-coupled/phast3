SUBROUTINE aplbci  
  ! ... Applies the implicit terms of the boundary conditions  and the
  ! ...      well source terms to the assembled equation matrix
  ! ...      and right hand side
  ! ... Called once for flow and for each component
  USE machine_constants, ONLY: kdp
!!$  use f_units
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
  REAL(KIND=kdp) :: ehoftp  
  INTRINSIC index
  CHARACTER(LEN=9) :: cibc
  REAL(KIND=kdp) :: cavg, dqfdp, dqfwdp, dqhbc, dqhdp, dqhdt, dqhwdp, &
       dqhwdt, dqsbc, dqsdc, dqsdp, dqswdc, dqswdp, dqwlyr, ehaif, ehlbc, &
       qfbc, qfwav, qfwn, qhbc, qhwm, qlim, qm_in, qm_net, qn, qnp, qsbc, qwn, qwnp, &
       sum_cqm_in, ufrac
  INTEGER :: a_err, awqm, da_err, i, ic, iczm, iczp, iwel, j, k, ks, l, l1, lc, ls,  &
       m, ma, mac, mks
  LOGICAL :: erflg
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qsbc3, qsbc4, qswm
  ! ... Set string for use with rcs ident command
  CHARACTER(len=80) :: ident_string='$id: aplbci.f90,v 1.1 2008/04/01 20:09:59 klkipp exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  erflg = .FALSE.  
  ALLOCATE (qsbc3(ns), qsbc4(ns), qswm(ns),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: aplbci"  
     STOP
  ENDIF
  ! ... well source terms
  IF(.NOT.cylind) THEN  
     ! ... cartesian coordinates
     DO 360 iwel = 1, nwel  
        IF(ABS(qwm(iwel) ) .GT.0.) THEN  
           DO 350 ks = 1, nkswel(iwel)  
              mks = mwel(iwel, ks)  
              qwn = qwlyr(iwel, ks)  
              dqwlyr = dqwdpl(iwel,ks)*(dp(mks) - dpwkt(iwel))
              qwnp = qwn + dqwlyr  
              ma = mrno(mks)  
              IF(ieq.EQ.1) THEN  
                 IF(qwnp.LE.0.) THEN  
                    ! ... outflow
                    qfwn = den(mks) * (qwlyr(iwel, ks) - dqwdpl(&
                         iwel, ks) * dpwkt(iwel) )
                    dqfwdp = den(mks) * dqwdpl(iwel, ks)  
                    qhwm = 0.d0  
                    !                        qhwm=qfwn*(eh(mks)+cpf*dt(mks))
                    !                        dqhwdp=dqfwdp*(eh(mks)+cpf*dt(mks))
                    !                           qswm(is)=qfwn*(c(mks,is)+dc(mks,is))
                    !                           dqswdp(is)=dqfwdp*(c(mks,is)+dc(mks,is))
                 ELSE  
                    ! ... inflow
                    qfwn = denwk(iwel, ks) * (qwlyr(iwel, ks) &
                         - dqwdpl(iwel, ks) * dpwkt(iwel) )
                    dqfwdp = denwk(iwel, ks) * dqwdpl(iwel, ks)  
                    qhwm = 0.d0  
                    !                        qhwm=qfwn*ehwk(iwel,ks)
                    !                        dqhwdp=dqfwdp*ehwk(iwel,ks)
                    !                        qswm(is)=qfwn*cwk(iwel,ks,is)
                    !                        dqswdp(is)=dqfwdp*cwk(iwel,ks,is)
                 ENDIF
                 va(7, ma) = va(7, ma) - fdtmth* dqfwdp  
                 rhs(ma) = rhs(ma) + fdtmth* qfwn  
              ELSEIF(ieq.EQ.2) THEN  
                 !...  ** not available for phast
                 !                     if(qwnp.le.0.) then
                 !c.....outflow
                 !                        qhwm=den(mks)*qwnp*eh(mks)
                 !                        dqhwdt=den(m)*qwnp*cpf
                 !                        qswm(is)=den(mks)*qwnp*(c(mks,is)+dc(mks,is))
                 !                     else
                 !c.....inflow
                 !                        qhwm=denwk(mm)*qwnp*ehwk(mm)
                 !                        dqhwdt=0.d0
                 !                        do 862 is=1,ns
                 !                        qswm(is)=denwk(iwel,ks)*qwnp*cwk(iwel,ks,is)
                 !  862                   continue
                 !                     endif
                 !                     va(7,ma)=va(7,ma)-fdtmth*dqhwdt
                 !                     rhs(ma)=rhs(ma)+fdtmth*(qhwm+cc24(m)*qswm(is))
              ELSEIF(ieq.EQ.3) THEN  
                 IF(qwnp.LE.0.) THEN  
                    ! ... outflow
                    qswm(is) = den(mks) * qwnp* c(mks, is)  
                    dqswdc = den(mks) * qwnp  
                    ! ... inflow
                 ELSE  
                    qswm(is) = denwk(iwel,ks)*qwnp*cwk(iwel,ks,is)
                    dqswdc = 0._kdp
                 ENDIF
                 va(7, ma) = va(7, ma) - fdtmth* dqswdc  
                 rhs(ma) = rhs(ma) + fdtmth* qswm(is)  
              ENDIF
350        END DO
        ENDIF
360  END DO
  ELSE  
     ! ... cylindrical coordinates-single well
     awqm = MOD(ABS(wqmeth(1) ), 100)  
     iczm = 1  
     iczp = 6  
     DO 380 ks = 1, nkswel(1)  
        mks = mwel(1, ks)  
        CALL mtoijk(mks, i, j, k, nx, nxy)  
        ! ... current layer flow rates from wbcflo. these are averages over time
        ! ...      step.
        qfwav = qflyr(1, ks)  
        ma = mrno(mks)  
        IF(ieq.EQ.1) THEN  
           IF(ks.GT.1) THEN  
              va(iczm, ma) = va(iczm, ma) - fdtmth* tfw(k - 1)  
              va(7, ma) = va(7, ma) + fdtmth* tfw(k - 1)  
           ENDIF
           IF(ks.LT.nkswel(1) ) THEN  
              va(iczp, ma) = va(iczp, ma) - fdtmth* tfw(k)  
              va(7, ma) = va(7, ma) + fdtmth* tfw(k)  
           ENDIF
           !               rhs(ma)=rhs(ma)+fdtmth*(cc34(mks)*qslyr(iwel,ks,is)+
           !     &                 cc35(mks)*qhlyr(iwel,ks))
           IF(ks.EQ.nkswel(1) ) THEN  
              IF(awqm.EQ.30.OR.awqm.EQ.50) THEN  
                 DO 370 i = 1, 6  
                    va(i, ma) = 0.d0  
370              END DO
                 va(7, ma) = 1.d0  
                 rhs(ma) = pwkt(1) - p(mks)  
              ENDIF
           ENDIF
        ELSEIF(ieq.EQ.2) THEN  
           !... ** not available for phast
           ! ... implicit treatment of convective solute and heat well flows
           IF(qfwav.LE.0.) THEN  
              ! ... outflow
              dqhwdt = qfwav* cpf  
           ELSE  
              ! ... inflow
              dqhwdt = 0.d0  
           ENDIF
           !               va(7,ma)=va(7,ma)-fdtmth*dqhwdt
           !               rhs(ma)=rhs(ma)+fdtmth*(qhlyr(mm)+cc24(m)*qslyr(mm))
        ELSEIF(ieq.EQ.3) THEN  
           IF(qfwav.LE.0.) THEN  
              ! ... outflow
              ! ... implicit treatment of solute well flows
              dqswdc = qfwav  
           ELSE  
              ! ... inflow
              dqswdc = 0.d0  
           ENDIF
           va(7, ma) = va(7, ma) - fdtmth* dqswdc  
           rhs(ma) = rhs(ma) + fdtmth* qslyr(iwel, ks, is)  
        ENDIF
380  END DO
  ENDIF
  ! ... Apply specified p,t or c b.c. terms
  erflg = .FALSE.  
  DO  l=1,nsbc  
     m = msbc(l)  
     WRITE(cibc, 6001) ibc(m)  
6001 FORMAT(i9.9)
     ma = mrno(m)  
     IF(ieq == 1 .AND. cibc(1:1) == '1') THEN  
        DO  ic=1,7
           vafsbc(ic,l) = va(ic,ma)  
        END DO
        rhfsbc(l) = rhs(ma)  
        DO ic=1,6  
           va(ic,ma) = 0._kdp
        END DO
        va(7,ma) = 1._kdp
        rhs(ma) = psbc(l) - p(m)  
     ELSEIF(ieq == 2) THEN  
!!$           !... ** not available for phast
!!$        if(cibc(4:4) .eq.'1') then  
!!$           do 410 i = 1, 7  
!!$              vahsbc(i, l) = va(i, ma)  
!!$410        end do
!!$           rhhsbc(l) = rhs(ma)  
!!$           do 420 i = 1, 6  
!!$              va(i, ma) = 0.d0  
!!$420        end do
!!$           va(7, ma) = 1.d0  
!!$           rhs(ma) = tsbc(l) - t(m)  
!!$           elseif(cibc(1:1) .eq.'1') then  
!!$              ! ... implicit treatment of convective solute and heat b.c. flows
!!$           if(qfsbc(l) .le.0.) then  
!!$              ! ... outflow
!!$              qhbc = qfsbc(l) * eh(m)  
!!$              dqhdt = qfsbc(l) * cpf  
!!$              !**               qsbc=qfsbc(l)*(c(m)+fdtmth*dc(m))
!!$           else  
!!$              ! ... inflow
!!$              if(heat) qhbc = qfsbc(l) * ehoftp(tsbc(l), &
!!$                   p(m), erflg)
!!$              dqhdt = 0.d0  
!!$              !**               qsbc=qfsbc(l)*csbc(l)
!!$           endif
!!$           va(7, ma) = va(7, ma) - fdtmth* dqhdt  
!!$           !               rhs(ma)=rhs(ma)+qhbc+cc24(m)*qsbc
!!$        endif
     ELSEIF(ieq == 3) THEN  
        IF(cibc(7:7) == '1') THEN  
           DO  i=1,7
              vassbc(i,l,is) = va(i,ma)  
           END DO
           rhssbc(l,is) = rhs(ma)  
           DO  i=1,6  
              va(i,ma) = 0._kdp
           END DO
           va(7,ma) = 1._kdp
           rhs(ma) = csbc(l,is) - c(m,is)  
        ELSEIF(cibc(1:1) == '1') THEN  
           IF(qfsbc(l) <= 0.) THEN                ! ... outflow
              ! ... implicit treatment of solute b.c. flows
              qsbc3(is) = qfsbc(l)*c(m,is)  
              dqsdc = qfsbc(l)
           ELSE                                   ! ... inflow
              qsbc3(is) = qfsbc(l)*csbc(l,is)
              dqsdc = 0._kdp
           ENDIF
           va(7,ma) = va(7,ma) - fdtmth*dqsdc
           rhs(ma) = rhs(ma) + qsbc3(is)  
        ENDIF
     ENDIF
  END DO
!!$  if(erflg) then  
!!$     write(fuclog, 9006) 'ehoftp interpolation error in aplbci ', &
!!$          'associated heat flux: specified value b.c.'
!!$9006 format   (tr10,2a,i4)  
!!$     ierr(129) = .true.  
!!$     errexe = .true.  
!!$     return  
!!$  endif
  ! ... Apply specified flux b.c. implicit terms
  DO lc=1,nfbc_cells
     m = flux_seg_index(lc)%m
     DO ls=flux_seg_index(lc)%seg_first,flux_seg_index(lc)%seg_last
        ufrac = 1._kdp
        IF(ifacefbc(ls) < 3) ufrac = frac(m)     
        ! ... Redirect the flux to the free-surface cell, if necessary
        IF(fresur .AND. ifacefbc(ls) == 3 .AND. frac(m) <= 0._kdp) THEN
           l1 = MOD(m,nxy)
           IF(l1 == 0) l1 = nxy
           m = mfsbc(l1)
        ENDIF
        IF (m == 0) EXIT          ! ... skip to next flux b.c. cell
        qn = qfflx(ls)*areafbc(ls)*ufrac
        ma = mrno(m)
        IF(ieq == 1) THEN
           IF(qn <= 0.) THEN                ! ... outflow
              qfbc = den(m)*qn
              dqfdp = 0._kdp
              !$$**               dqsbc=qfbc*dc(m)
              !$$                  dqhbc=qfbc*cpf*dt(m)
           ELSE                             ! ... inflow
              dqsbc = 0._kdp
              !$$                  dqhbc=0._kdp
           ENDIF
           dqsbc = 0._kdp
           ! ... nothing implicit to assemble for flux b.c.
           !$$              rhs(ma)=rhs(ma)+fdtmth*(cc34(m)*dqsbc+cc35(m)*dqhbc)
        ELSEIF(ieq == 3) THEN
           IF(qn <= 0.) THEN                ! ... outflow
              dqsdc = den(m)*qn
           ELSE                             ! ... inflow
              dqsdc = 0._kdp
           ENDIF
           va(7,ma) = va(7,ma) - fdtmth*dqsdc
        ENDIF
     END DO
  END DO
  ! ... Apply aquifer leakage terms
  ! ...      Net segment method for solute
  DO lc=1,nlbc_cells
     m = leak_seg_index(lc)%m     ! ... current leakage communication cell
     ! ... calculate current net aquifer leakage flow rate
     ! ...      possible attenuation included explicitly
     IF(frac(m) <= 0._kdp) CYCLE
     qm_net = 0._kdp
     qfbc = 0._kdp
     dqfdp = 0._kdp
     DO ls=leak_seg_index(lc)%seg_first,leak_seg_index(lc)%seg_last
        qn = albc(ls)
        qnp = qn - blbc(ls)*dp(m)
        IF(qnp <= 0._kdp) THEN           ! ... outflow
           qm_net = qm_net + den(m)*qnp
           qfbc = qfbc + den(m)*qn
           dqfdp = dqfdp - den(m)*blbc(ls)
        ELSE                             ! ... inflow
           qm_net = qm_net + denlbc(ls)*qnp
           qfbc = qfbc + denlbc(ls)*qn  
           dqfdp = dqfdp - denlbc(ls)*blbc(ls)
        ENDIF
     END DO
     ma = mrno(m)
     IF(ieq == 1) THEN
        va(7,ma) = va(7,ma) - fdtmth*dqfdp
        rhs(ma) = rhs(ma) + fdtmth*qfbc
!!$     elseif(ieq.eq.2) then
!!$        !... ** not available for phast
     ELSEIF(ieq == 3) THEN
        IF(qm_net <= 0._kdp) THEN           ! ... net outflow
           qsbc4(is) = qm_net*c(m,is)  
           dqsdc = qm_net  
        ELSE                                ! ... net inflow
           ! ... calculate flow weighted average concentrations for inflow segments
           qm_in = 0._kdp
           sum_cqm_in = 0._kdp
           DO ls=leak_seg_index(lc)%seg_first,leak_seg_index(lc)%seg_last
              qnp = albc(ls) - blbc(ls)*dp(m)
              IF(qnp > 0._kdp) THEN                   ! ... inflow
                 qm_in = qm_in + denlbc(ls)*qnp
                 sum_cqm_in = sum_cqm_in + denlbc(ls)*qnp*clbc(ls,is)  
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
!!$  DO lc=1,nlbc_cells
!!$     m = leak_seg_index(lc)%m     ! ... current leakage communication cell
!!$     IF(frac(m) <= 0._kdp) CYCLE
!!$     DO ls=leak_seg_index(lc)%seg_first,leak_seg_index(lc)%seg_last
!!$        ! ... Calculate current aquifer leakage flow rate
!!$        ! ...      Possible attenuation included explicitly
!!$        qn = albc(ls)
!!$        qnp = qn - blbc(ls)*dp(m)
!!$        ma=mrno(m)
!!$        IF(ieq == 1) THEN
!!$           IF(qnp <= 0.) THEN           ! ... outflow
!!$              qfbc = den(m)*qn
!!$              dqfdp = -den(m)*blbc(ls)
!!$           qhbc=qfbc*(eh(m)+cpf*dt(m))
!!$           dqhdp=dqfdp*(eh(m)+cpf*dt(m))
!!$           qsbc=qfbc*(c(m)+dc(m))
!!$           dqsdp=dqfdp*(c(m)+dc(m))
!!$           ELSE                         ! ... inflow
!!$              qfbc = denlbc(ls)*qn
!!$              dqfdp = -denlbc(ls)*blbc(ls)
!!$           if(heat) ehlbc=ehoftp(tlbc(l),p(m),erflg)
!!$           qhbc=qfbc*ehlbc
!!$           dqhdp=dqfdp*ehlbc
!!$           qsbc=qfbc*clbc(l)
!!$           dqsdp=dqfdp*clbc(l)
!!$           END IF
!!$           va(7,ma) = va(7,ma) - fdtmth*dqfdp
!!$           rhs(ma) = rhs(ma) + fdtmth*qfbc
!!$     else if(ieq == 2) then     ! ... ** not available for phast
!!$        if(qnp <= 0.) then
!!$           ! ... outflow
!!$           qsbc=den(m)*qnp*(c(m)+dc(m))
!!$           qhbc=den(m)*qnp*eh(m)
!!$           dqhdt=den(m)*qnp*cpf
!!$        else
!!$           ! ... inflow
!!$           qsbc=denlbc(l)*qnp*clbc(l)
!!$           if(heat) qhbc=denlbc(l)*qnp*ehoftp(tlbc(l),p(m),erflg)
!!$           dqhdt=0._kdp
!!$        end if
!!$        va(7,ma)=va(7,ma)-fdtmth*dqhdt
!!$        rhs(ma)=rhs(ma)+fdtmth*(qhbc+cc24(m)*qsbc)
!!$        ELSE IF(ieq == 3) THEN
!!$           IF(qnp <= 0.) THEN           ! ... outflow
!!$              qsbc4(is) = den(m)*qnp*c(m,is)
!!$              dqsdc = den(m)*qnp
!!$           ELSE                            ! ... inflow
!!$              qsbc4(is) = denlbc(ls)*qnp*clbc(ls,is)
!!$              dqsdc = 0._kdp
!!$           END IF
!!$           va(7,ma) = va(7,ma) - fdtmth*dqsdc
!!$           rhs(ma) = rhs(ma) + fdtmth*qsbc4(is)
!!$        END IF
!!$     END DO
!!$  END DO
  ! ... Apply river leakage terms
  ! ...      Net segment method for solute
  DO lc=1,nrbc_cells
     m = river_seg_index(lc)%m     ! ... current river communication cell
     ! ... calculate current net river leakage flow rate
     ! ...      possible attenuation included explicitly
     IF(m == 0) CYCLE              ! ... dry column, skip to next river b.c. cell 
     qm_net = 0._kdp
     qfbc = 0._kdp
     dqfdp = 0._kdp
     DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
        qn = arbc(ls)
        qnp = qn - brbc(ls)*dp(m)      ! ... with only one flow equation solution qnp = qn always
        IF(qnp <= 0._kdp) THEN           ! ... outflow
           qm_net = qm_net + den(m)*qnp
           qfbc = qfbc + den(m)*qn
           dqfdp = dqfdp - den(m)*brbc(ls)
           !$$          write(*,*) 1, qfbc, dqfdp, qnp, brbc(ls), p(m)/9807.0_kdp, m, arbc(ls)
        ELSE                             ! ... inflow
           ! ... limit the flow rate for a river leakage
           qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                - 0.5_kdp*den(m)*bbrbc(ls)))
           IF(qnp <= qlim) THEN
              qm_net = qm_net + denrbc(ls)*qnp
              qfbc = qfbc + denrbc(ls)*qn  
              dqfdp = dqfdp - denrbc(ls)*brbc(ls)
              !$$              write(*,*) 2, qfbc, dqfdp, qnp, brbc(ls), p(m)/9807.0_kdp, m, qlim
           ELSEIF(qnp > qlim) THEN
              qm_net = qm_net + denrbc(ls)*qlim
              qfbc = qfbc + denrbc(ls)*qlim
              ! hack for instability from the kink in q vs h relation
              IF (steady_flow) dqfdp = dqfdp - denrbc(ls)*brbc(ls)
              !$$              write(*,*) 3, qfbc, dqfdp, qnp, brbc(ls), p(m)/9807.0_kdp, m, qlim
              ! ... add nothing to dqfdp
           ENDIF
        ENDIF
     END DO
     ma = mrno(m)
     IF(ieq == 1) THEN
        va(7,ma) = va(7,ma) - fdtmth*dqfdp
        rhs(ma) = rhs(ma) + fdtmth*qfbc
     ELSEIF(ieq == 3) THEN
        IF(qm_net <= 0._kdp) THEN           ! ... net outflow
           qsbc4(is) = qm_net*c(m,is)  
           dqsdc = qm_net  
        ELSE                                ! ... net inflow
           ! ... calculate flow weighted average concentrations for inflow segments
           qm_in = 0._kdp
           sum_cqm_in = 0._kdp
           DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
              qnp = arbc(ls) - brbc(ls)*dp(m)
              IF(qnp > 0._kdp) THEN                   ! ... inflow
                 ! ... limit the flow rate for a river leakage
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
!!$  ! ... Apply each segment
!!$  DO lc=1,nrbc_cells
!!$     m = river_seg_index(lc)%m     ! ... current river communication cell
!!$     ! ...      possible attenuation included explicitly
!!$     qfbc = 0._kdp
!!$     dqfdp = 0._kdp
!!$     qm_net = 0._kdp
!!$     IF(m == 0) CYCLE
!!$     DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
!!$        qn = arbc(ls)
!!$        qnp = qn - brbc(ls)*dp(m)      ! ... with steady state flow equation solution qnp = qn always
!!$        ma = mrno(m)
!!$        IF(ieq == 1) THEN
!!$           IF(qnp <= 0._kdp) THEN           ! ... outflow
!!$              qfbc = den(m)*qn
!!$              dqfdp = -den(m)*brbc(ls)
!!$           ELSE                             ! ... inflow
!!$              ! ... limit the flow rate for a river leakage
!!$              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
!!$                   - 0.5_kdp*den(m)*bbrbc(ls)))
!!$              qnp = MIN(qnp,qlim)
!!$              qfbc = denrbc(ls)*qn
!!$              dqfdp = -denrbc(ls)*brbc(ls)
!!$           END IF
!!$           va(7,ma) = va(7,ma) - fdtmth*dqfdp
!!$           rhs(ma) = rhs(ma) + fdtmth*qfbc
!!$        ELSE IF(ieq == 3) THEN
!!$           IF(qnp <= 0.) THEN           ! ... outflow
!!$              qsbc4(is) = den(m)*qnp*c(m,is)
!!$              dqsdc = den(m)*qnp
!!$           ELSE                            ! ... inflow
!!$              qsbc4(is) = denlbc(ls)*qnp*crbc(ls,is)
!!$              dqsdc = 0._kdp
!!$           END IF
!!$           va(7,ma) = va(7,ma) - fdtmth*dqsdc
!!$           rhs(ma) = rhs(ma) + fdtmth*qsbc4(is)
!!$        END IF
!!$     END DO
!!$  END DO
  ! ... Apply each segment
  DO lc=1,ndbc_cells
     m = drain_seg_index(lc)%m     ! ... current drain communication cell
     ! ...      possible attenuation included explicitly
     qfbc = 0._kdp
     dqfdp = 0._kdp
     IF(m == 0) CYCLE
     DO ls=drain_seg_index(lc)%seg_first,drain_seg_index(lc)%seg_last
        qn = adbc(ls)
        qnp = qn - bdbc(ls)*dp(m)      ! ... with steady state flow equation solution qnp = qn always
        ma = mrno(m)
        IF(ieq == 1) THEN
           IF(qnp <= 0._kdp) THEN           ! ... outflow
              qfbc = den(m)*qn
              dqfdp = -den(m)*bdbc(ls)
           ELSE                             ! ... inflow, not allowed
              qfbc = 0._kdp
              dqfdp = 0._kdp
           END IF
           va(7,ma) = va(7,ma) - fdtmth*dqfdp
           rhs(ma) = rhs(ma) + fdtmth*qfbc
        ELSE IF(ieq == 3) THEN
           IF(qnp <= 0.) THEN           ! ... outflow
              qsbc4(is) = den(m)*qnp*c(m,is)
              dqsdc = den(m)*qnp
           ELSE                            ! ... inflow
              qsbc4(is) = 0._kdp
              dqsdc = 0._kdp
           END IF
           va(7,ma) = va(7,ma) - fdtmth*dqsdc
           rhs(ma) = rhs(ma) + fdtmth*qsbc4(is)
        END IF
     END DO
  END DO
!!$  if(erflg) then  
!!$     write(fuclog, 9006) 'ehoftp interpolation error in aplbci ', &
!!$          'associated heat flux: leakage b.c.'
!!$     ierr(129) = .true.  
!!$     errexe = .true.  
!!$     return  
!!$  endif
  ! ... apply a.i.f. b.c. terms
  !... ** not implemented for phast
!!$  do 480 l = 1, naifc  
!!$     ! ... calculate current aquifer influence function flow rate
!!$     m = maifc(l)  
!!$     qn = aaif(l)  
!!$     qnp = qn + baif(l) * dp(m)  
!!$     ma = mrno(m)  
!!$     if(ieq.eq.1) then  
!!$        if(qnp.le.0) then  
!!$           ! ... outflow
!!$           qfbc = den(m) * qn  
!!$           dqfdp = den(m) * baif(l)  
!!$           !**            qsbc=qfbc*(c(m)+dc(m))
!!$           !**            dqsdp=dqfdp*(c(m)+dc(m))
!!$           qhbc = qfbc* (eh(m) + cpf* dt(m) )  
!!$           dqhdp = dqfdp* (eh(m) + cpf* dt(m) )  
!!$        else  
!!$           ! ... inflow
!!$           qfbc = denoar(l) * qn  
!!$           dqfdp = denoar(l) * baif(l)  
!!$           !               qsbc=qfbc*caif(l)
!!$           if(heat) ehaif = ehoftp(taif(l), p(m), erflg)  
!!$           dqsdp = dqfdp* caif(l)  
!!$           qhbc = qfbc* ehaif  
!!$           dqhdp = dqfdp* ehaif  
!!$        endif
!!$        qsbc = 0.d0  
!!$        va(7, ma) = va(7, ma) - fdtmth* (dqfdp + cc34(m) * &
!!$             dqsdp + cc35(m) * dqhdp)
!!$        rhs(ma) = rhs(ma) + fdtmth* (qfbc + cc34(m) * qsbc + &
!!$             cc35(m) * qhbc)
!!$        elseif(ieq.eq.2) then  
!!$        if(qnp.le.0.) then  
!!$           ! ... outflow
!!$           !**            qsbc=den(m)*qnp*(c(m)+dc(m))
!!$           qhbc = den(m) * qnp* eh(m)  
!!$           dqhdt = den(m) * qnp* cpf  
!!$        else  
!!$           ! ... inflow
!!$           !               qsbc=denoar(l)*qnp*caif(l)
!!$           if(heat) qhbc = denoar(l) * qnp* ehoftp(taif(l), &
!!$                p(m), erflg)
!!$           dqhdt = 0.d0  
!!$        endif
!!$        va(7, ma) = va(7, ma) - fdtmth* dqhdt  
!!$        !            rhs(ma)=rhs(ma)+fdtmth*(qhbc+cc24(m)*qsbc)
!!$        elseif(ieq.eq.3) then  
!!$        if(qnp.le.0.) then  
!!$           ! ... outflow
!!$           !**            qsbc=den(m)*qnp*c(m)
!!$           dqsdc = den(m) * qnp  
!!$           ! ... inflow
!!$        else  
!!$           !               qsbc=denoar(l)*qnp*caif(l)
!!$           dqsdc = 0.d0  
!!$        endif
!!$        va(7, ma) = va(7, ma) - fdtmth* dqsdc  
!!$        !            rhs(ma)=rhs(ma)+fdtmth*qsbc
!!$     endif
!!$480 end do
!!$  if(erflg) then  
!!$     write(fuclog, 9006) 'ehoftp interpolation error in aplbci ', &
!!$          'associated heat flux: aquifer influence function b.c.'
!!$     ierr(129) = .true.  
!!$     errexe = .true.  
!!$     return  
!!$  endif
!!$  ! ... heat conduction boundary condition
!!$  !... **  not implemented for phast
!!$  if(ieq.eq.2) then  
!!$     do  l = 1, nhcbc  
!!$        m = mhcbc(l)  
!!$        ma = mrno(m)  
!!$        va(7, ma) = va(7, ma) - fdtmth* dqhcdt(l)  
!!$     end do
!!$  endif
  IF(fresur) THEN  
     ! ... Free-surface boundary condition
     DO m=1,nxyz  
        IF(frac(m) <= 0.) THEN  
           ! ... solve trivial equation for transient dry cells
           ma = mrno(m)  
           WRITE(cibc, 6001) ibc(m)  
           IF((ieq == 1 .AND. cibc(1:1)  /= '1') .OR.  &
                (ieq ==  3 .AND. cibc(7:7)  /= '1')) THEN
              va(7,ma) = 1._kdp
              rhs(ma) = 0._kdp  
              !$$              if(slmeth.eq.1) then  
              ! ... zero the va coefficients for cells connected to an empty cell
              ! ...      to resymmetrize the matrix
              DO ic=1,6  
                 mac = ci(ic,ma)  
                 IF(mac > 0) va(7-ic,mac) = 0._kdp  
              END DO
              !$$              endif
           ENDIF
        ENDIF
     END DO
  ENDIF
  DEALLOCATE (qsbc3, qsbc4, qswm, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "array deallocation failed"  
     STOP  
  ENDIF
END SUBROUTINE aplbci
