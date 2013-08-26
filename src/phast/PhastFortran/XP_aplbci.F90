SUBROUTINE XP_aplbci_thread(xp)
  ! ... Applies the implicit terms of the boundary conditions  and the
  ! ...      well source terms to the assembled equation matrix
  ! ...      and right hand side
  USE machine_constants, ONLY: kdp
  USE mcb, only: nsbc, msbc, ibc, char_ibc, qfsbc, &
    ifacefbc, ifacelbc, fresur, &
    flux_seg_m, flux_seg_first, flux_seg_last, mfsbc, &
    leak_seg_first, leak_seg_last, denlbc, philbc, zelbc, bblbc, &
    nrbc_cells, river_seg_first, river_seg_last, arbc, brbc, denrbc, phirbc, zerbc, bbrbc, &
    ndbc_cells, drain_seg_first, drain_seg_last, adbc, bdbc, &
    qfflx, areafbc, albc, blbc, &
    nfbc_cells, nlbc_cells
  USE mcc, only: cylind, steady_flow
  USE mcg, only: nx, nxy, nxyz
  USE mcm, only:
  USE mcp, only: den0, fdtmth, gz
  USE mcs, only: mrno, ci
  USE mcv, only: dp, frac
  USE mcw, only: nwel, nkswel, mwel, dpwkt, wqmeth
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTRINSIC index
  CHARACTER(LEN=9) :: cibc
  REAL(KIND=kdp) :: cavg, dqfdp, dqfwdp, dqhbc, dqhdp, dqhdt, dqhwdp,  &
       dqhwdt, dqsbc, dqsdc, dqsdp, dqswdc, dqswdp, dqwlyr, ehaif, ehlbc,  &
       qfbc, qfwav, qfwn, qhbc, qhwm, qlim, qm_in, qm_net, qn, qnp, qsbc, qsbc3, qsbc4,  &
       qswm, qwn, qwnp, sum_cqm_in, ufrac
  REAL(KIND=kdp) :: hrbc
  INTEGER :: a_err, awqm, da_err, i, ic, iczm, iczp, iwel, j, k, ks, l, l1, lc, ls,  &
       m, ma, mac, mks
  LOGICAL :: erflg
!  INTEGER :: dum2, dum3
!  REAL(KIND=kdp) :: dum1
  ! ... Set string for use with rcs ident command
  CHARACTER(LEN=80) :: ident_string='$id: aplbci.f90,v 1.1 2008/04/01 20:09:59 klkipp exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  erflg = .FALSE.  
  ! ... well source terms
  IF(.NOT.cylind) THEN  
     ! ... cartesian coordinates
     DO iwel = 1,nwel  
        IF(ABS(xp%qwm(iwel)) > 0.) THEN  
           DO ks = 1,nkswel(iwel)  
              mks = mwel(iwel,ks)  
              qwn = xp%qwlyr(iwel,ks)  
              dqwlyr = xp%dqwdpl(iwel,ks)*(dp(mks) - dpwkt(iwel))
              qwnp = qwn + dqwlyr  
              ma = mrno(mks)  
              IF(qwnp <= 0.) THEN        ! ... outflow
                 qswm = den0*qwnp*xp%c_w(mks)  
                 dqswdc = den0*qwnp  
              ELSE                      ! ... inflow
                 !qswm = denwk(iwel,ks)*qwnp*xp%cwk(iwel,ks)
                 qswm = den0*qwnp*xp%cwk(iwel,ks)
                 dqswdc = 0._kdp
              ENDIF
              xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqswdc
              xp%rhs(ma) = xp%rhs(ma) + fdtmth*qswm
           END DO
        ENDIF
     END DO
  ELSE  
     ! ... cylindrical coordinates-single well
     awqm = MOD(ABS(wqmeth(1)),100)  
     iczm = 1  
     iczp = 6  
     DO ks = 1,nkswel(1)  
        mks = mwel(1,ks)  
        CALL mtoijk(mks,i,j,k,nx,nxy)
        ! ... current layer flow rates from wbcflo. these are averages over time
        ! ...      step.
        qfwav = xp%qflyr(1,ks)
        ma = mrno(mks)  
        IF(qfwav <= 0.) THEN      ! ... outflow
           ! ... implicit treatment of solute well flows
           dqswdc = qfwav
        ELSE                     ! ... inflow
           dqswdc = 0._kdp
        ENDIF
        xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqswdc
        xp%rhs(ma) = xp%rhs(ma) + fdtmth*xp%qslyr(iwel,ks)
     END DO
  ENDIF
  IF(nsbc > 0) THEN
     ! ... Apply specified p,t or c b.c. terms
     DO  ls=1,nsbc
        m = msbc(ls)
        cibc = char_ibc(m)
!        WRITE(cibc,6001) ibc(m)  
6001    FORMAT(i9.9)
        ma = mrno(m)  
        if (frac(m) <= 0.0) cycle
        IF(cibc(7:7) == '1') THEN  
           DO  i=1,7
              xp%vassbc(i,ls) = xp%va(i,ma)  
           END DO
           xp%rhssbc(ls) = xp%rhs(ma)  
           DO  i=1,6  
              xp%va(i,ma) = 0._kdp
           END DO
           xp%va(7,ma) = 1._kdp
           xp%rhs(ma) = xp%csbc(ls) - xp%c_w(m)  
        ELSEIF(cibc(1:1) == '1') THEN  
           IF(qfsbc(ls) <= 0.) THEN                ! ... outflow
              ! ... implicit treatment of solute b.c. flows
              qsbc3 = qfsbc(ls)*xp%c_w(m)  
              dqsdc = qfsbc(ls)
           ELSE                                   ! ... inflow
              qsbc3 = qfsbc(ls)*xp%csbc(ls)
              dqsdc = 0._kdp
           ENDIF
           xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqsdc
           xp%rhs(ma) = xp%rhs(ma) + qsbc3
        ENDIF
     END DO
  END IF
  ! ... Apply specified flux b.c. implicit terms
  DO lc=1,nfbc_cells
     m = flux_seg_m(lc)     ! ... current flux communication cell
     DO ls=flux_seg_first(lc),flux_seg_last(lc)
        ufrac = 1._kdp
        IF(ABS(ifacefbc(ls)) < 3) ufrac = frac(m)     
        ! ... Redirect the flux from above to the free-surface cell
        IF(fresur .AND. ifacefbc(ls) ==3 .AND. frac(m) <= 0._kdp) THEN
           l1 = MOD(m,nxy)
           IF(l1 == 0) l1 = nxy
           m = mfsbc(l1)
        ENDIF
        IF (m == 0) EXIT          ! ... skip to next flux b.c. cell
        qn = qfflx(ls)*areafbc(ls)*ufrac
        ma = mrno(m)
        IF(qn <= 0.) THEN                ! ... outflow
           dqsdc = den0*qn
        ELSE                             ! ... inflow
           dqsdc = 0._kdp
        ENDIF
        xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqsdc
     END DO
  END DO
  ! ... Apply aquifer leakage terms
  ! ...      Net segment method for solute
  DO lc=1,nlbc_cells
     m = xp%leak_seg_m(lc)     ! ... current leakage communication cell
     ! ... Calculate current net aquifer leakage flow rate
     ! ...      Possible attenuation included explicitly
     IF(m == 0) CYCLE              ! ... dry column, skip to next leaky b.c. cell 
     qm_net = 0._kdp
     qfbc = 0._kdp
     dqfdp = 0._kdp
     DO ls=leak_seg_first(lc),leak_seg_last(lc)
        qn = albc(ls)
        qnp = qn - blbc(ls)*dp(m)
        IF(qnp <= 0._kdp) THEN           ! ... outflow
           qm_net = qm_net + den0*qnp
           qfbc = qfbc + den0*qn
           dqfdp = dqfdp - den0*blbc(ls)
        ELSE                             ! ... inflow
           IF(fresur .AND. ifacelbc(ls) == 3) THEN
              ! ... limit the flow rate for vertical leakage from above
              qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
                   - 0.5_kdp*den0*bblbc(ls)))
              IF(qnp <= qlim) THEN
                 qm_net = qm_net + denlbc(ls)*qnp
                 qfbc = qfbc + denlbc(ls)*qn
                 dqfdp = dqfdp - denlbc(ls)*blbc(ls)
              ELSEIF(qnp > qlim) THEN
                 qm_net = qm_net + denlbc(ls)*qlim
                 qfbc = qfbc + denlbc(ls)*qlim
                 ! hack for instability from the kink in q vs h relation
                 IF (steady_flow) dqfdp = dqfdp - denlbc(ls)*blbc(ls)
                 ! ... add nothing to dqfdp
              ENDIF
           ELSE          ! ... x or y face
              qm_net = qm_net + denlbc(ls)*qnp
              qfbc = qfbc + denlbc(ls)*qn  
              dqfdp = dqfdp - denlbc(ls)*blbc(ls)
           END IF
        ENDIF
     END DO
     ma = mrno(m)
     IF(qm_net <= 0._kdp) THEN           ! ... net outflow
        qsbc4 = qm_net*xp%c_w(m)
        dqsdc = qm_net  
     ELSE                                ! ... net inflow
        ! ... calculate flow weighted average concentrations for inflow segments
        qm_in = 0._kdp
        sum_cqm_in = 0._kdp
        DO ls=leak_seg_first(lc),leak_seg_last(lc)  
           qnp = albc(ls) - blbc(ls)*dp(m)
           IF(qnp > 0._kdp) THEN                   ! ... inflow
              IF(fresur .AND. ifacelbc(ls) == 3) THEN
                 ! ... limit the flow rate for vertical leakage from above
                 qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*  &
                      (zelbc(ls)-0.5_kdp*bblbc(ls)) - 0.5_kdp*den0*bblbc(ls)))
                 qnp = MIN(qnp,qlim)
                 qm_in = qm_in + denlbc(ls)*qnp
                 sum_cqm_in = sum_cqm_in + denlbc(ls)*qnp*xp%clbc(ls)  
              ELSE          ! ... x or y face
                 qm_in = qm_in + denlbc(ls)*qnp
                 sum_cqm_in = sum_cqm_in + denlbc(ls)*qnp*xp%clbc(ls)
              END IF
           ENDIF
        END DO
        cavg = sum_cqm_in/qm_in
        qsbc4 = qm_net*cavg
        dqsdc = 0._kdp
     ENDIF
     xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqsdc 
     xp%rhs(ma) = xp%rhs(ma) + fdtmth*qsbc4
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
!!$              qfbc = den0*qn
!!$              dqfdp = -den0*blbc(ls)
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
!!$           xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqfdp
!!$           xp%rhs(ma) = xp%rhs(ma) + fdtmth*qfbc
!!$        else
!!$           ! ... inflow
!!$           qsbc=denlbc(l)*qnp*clbc(l)
!!$           if(heat) qhbc=denlbc(l)*qnp*ehoftp(tlbc(l),p(m),erflg)
!!$           dqhdt=0._kdp
!!$        end if
!!$        xp%va(7,ma)=xp%va(7,ma)-fdtmth*dqhdt
!!$        xp%rhs(ma)=xp%rhs(ma)+fdtmth*(qhbc+cc24(m)*qsbc)
!!$        ELSE IF(ieq == 3) THEN
!!$           IF(qnp <= 0.) THEN           ! ... outflow
!!$              qsbc4(is) = den0*qnp*c(m,is)
!!$              dqsdc = den0*qnp
!!$           ELSE                            ! ... inflow
!!$              qsbc4(is) = denlbc(ls)*qnp*clbc(ls,is)
!!$              dqsdc = 0._kdp
!!$           END IF
!!$           xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqsdc
!!$           xp%rhs(ma) = xp%rhs(ma) + fdtmth*qsbc4(is)
!!$        END IF
!!$     END DO
!!$  END DO
  ! ... Apply river leakage terms
  ! ...      Net segment method for solute
  DO lc=1,nrbc_cells
     m = xp%river_seg_m(lc)       ! ... current river communication cell
     ! ... calculate current net river leakage flow rate
     ! ...      possible attenuation included explicitly
     IF(m == 0) CYCLE              ! ... dry column, skip to next river b.c. cell 
     qm_net = 0._kdp
     qfbc = 0._kdp
     dqfdp = 0._kdp
     DO ls=river_seg_first(lc),river_seg_last(lc)
        qn = arbc(ls)
        qnp = qn - brbc(ls)*dp(m)      ! ... with steady state flow, qnp = qn always
        hrbc = phirbc(ls)/gz
        if(hrbc > zerbc(ls)) then      ! ... treat as river
            IF(qnp <= 0._kdp) THEN           ! ... outflow
                qm_net = qm_net + den0*qnp
                qfbc = qfbc + den0*qn
                dqfdp = dqfdp - den0*brbc(ls)
            ELSE                             ! ... inflow
                ! ... limit the flow rate for a river leakage
                qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                - 0.5_kdp*den0*bbrbc(ls)))
                IF(qnp <= qlim) THEN
                    qm_net = qm_net + denrbc(ls)*qnp
                    qfbc = qfbc + denrbc(ls)*qn  
                    dqfdp = dqfdp - denrbc(ls)*brbc(ls)
                ELSEIF(qnp > qlim) THEN
                    qm_net = qm_net + denrbc(ls)*qlim
                    qfbc = qfbc + denrbc(ls)*qlim
                    ! .. hack for instability from the kink in q vs h relation
                    IF (steady_flow) dqfdp = dqfdp - denrbc(ls)*brbc(ls)
                    ! ... add nothing to dqfdp
                ENDIF
            ENDIF
        else                           ! ... treat as drain 
            ma = mrno(m)
            IF(qnp <= 0.) THEN           ! ... outflow
                qsbc4 = den0*qnp*xp%c_w(m)
                dqsdc = den0*qnp
            ELSE                            ! ... inflow, not allowed
                qsbc4 = 0._kdp
                dqsdc = 0._kdp
            END IF
        end if            
     END DO
     ma = mrno(m)
     IF(qm_net <= 0._kdp) THEN           ! ... net outflow
        qsbc4 = qm_net*xp%c_w(m)  
        dqsdc = qm_net  
     ELSE                                ! ... net inflow
        ! ... calculate flow weighted average concentrations for inflow segments
        qm_in = 0._kdp
        sum_cqm_in = 0._kdp
        DO ls=river_seg_first(lc),river_seg_last(lc)
           qnp = arbc(ls) - brbc(ls)*dp(m)
           IF(qnp > 0._kdp) THEN                   ! ... inflow
              ! ... limit the flow rate for a river leakage
              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*  &
                   (zerbc(ls)-0.5_kdp*bbrbc(ls)) - 0.5_kdp*den0*bbrbc(ls)))
              qnp = MIN(qnp,qlim)
              qm_in = qm_in + denrbc(ls)*qnp
              sum_cqm_in = sum_cqm_in + denrbc(ls)*qnp*xp%crbc(ls)  
           ENDIF
        END DO
        cavg = sum_cqm_in/qm_in
        qsbc4 = qm_net*cavg
        dqsdc = 0._kdp
     ENDIF
     xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqsdc 
     xp%rhs(ma) = xp%rhs(ma) + fdtmth*qsbc4
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
!!$              qfbc = den0*qn
!!$              dqfdp = -den0*brbc(ls)
!!$           ELSE                             ! ... inflow
!!$              ! ... limit the flow rate for a river leakage
!!$              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
!!$                   - 0.5_kdp*den0*bbrbc(ls)))
!!$              qnp = MIN(qnp,qlim)
!!$              qfbc = denrbc(ls)*qn
!!$              dqfdp = -denrbc(ls)*brbc(ls)
!!$           END IF
!!$           xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqfdp
!!$           xp%rhs(ma) = xp%rhs(ma) + fdtmth*qfbc
!!$        ELSE IF(ieq == 3) THEN
!!$           IF(qnp <= 0.) THEN           ! ... outflow
!!$              qsbc4(is) = den0*qnp*c(m,is)
!!$              dqsdc = den0*qnp
!!$           ELSE                            ! ... inflow
!!$              qsbc4(is) = denlbc(ls)*qnp*crbc(ls,is)
!!$              dqsdc = 0._kdp
!!$           END IF
!!$           xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqsdc
!!$           xp%rhs(ma) = xp%rhs(ma) + fdtmth*qsbc4(is)
!!$        END IF
!!$     END DO
!!$  END DO
  ! ... Apply each segment
  DO lc=1,ndbc_cells
     m = xp%drain_seg_m(lc)       ! ... current drain communication cell
     ! ...      possible attenuation included explicitly
     qfbc = 0._kdp
     dqfdp = 0._kdp
     IF(m == 0) CYCLE
     DO ls=drain_seg_first(lc),drain_seg_last(lc)
        qn = adbc(ls)
        qnp = qn - bdbc(ls)*dp(m)      ! ... with steady state flow equation solution qnp = qn always
        ma = mrno(m)
        IF(qnp <= 0.) THEN           ! ... outflow
           qsbc4 = den0*qnp*xp%c_w(m)
           dqsdc = den0*qnp
        ELSE                            ! ... inflow, not allowed
           qsbc4 = 0._kdp
           dqsdc = 0._kdp
        END IF
        xp%va(7,ma) = xp%va(7,ma) - fdtmth*dqsdc
        xp%rhs(ma) = xp%rhs(ma) + fdtmth*qsbc4
     END DO
  END DO
  ! ... apply a.i.f. b.c. terms
  !... ** not implemented for phast
  IF(fresur) THEN
     ! ... Free-surface boundary condition
     DO m=1,nxyz
        IF(frac(m) <= 0.) THEN
           ! ... solve trivial equation for transient dry cells
           ma = mrno(m)
            cibc = char_ibc(m)
!           WRITE(cibc, 6001) ibc(m)
           IF(cibc(7:7)  /= '1') THEN
              xp%va(7,ma) = 1._kdp
              xp%rhs(ma) = 0._kdp
              ! ... zero the xp%va coefficients for cells connected to an empty cell
              ! ...      to resymmetrize the matrix
              DO ic=1,6  
                 mac = ci(ic,ma)  
                 IF(mac > 0) xp%va(7-ic,mac) = 0._kdp  
              END DO
           ENDIF
        ENDIF
     END DO
  ENDIF
END SUBROUTINE XP_aplbci_thread
SUBROUTINE XP_aplbci(xp)
  ! ... Applies the implicit terms of the boundary conditions  and the
  ! ...      well source terms to the assembled equation matrix
  ! ...      and right hand side
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc, only: cylind, steady_flow
  USE mcg
  USE mcm
  USE mcp, only: den0, fdtmth, gz
  USE mcs, only: mrno, ci
  USE mcv, only: dp, frac
  USE mcw
  USE XP_module, only: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTRINSIC index
  CHARACTER(LEN=9) :: cibc
  REAL(KIND=kdp) :: cavg, dqfdp, dqfwdp, dqhbc, dqhdp, dqhdt, dqhwdp,  &
       dqhwdt, dqsbc, dqsdc, dqsdp, dqswdc, dqswdp, dqwlyr, ehaif, ehlbc,  &
       qfbc, qfwav, qfwn, qhbc, qhwm, qlim, qm_in, qm_net, qn, qnp, qsbc, qsbc3, qsbc4,  &
       qswm, qwn, qwnp, sum_cqm_in, ufrac
  REAL(KIND=kdp) :: hrbc
  INTEGER :: a_err, awqm, da_err, i, ic, iczm, iczp, iwel, j, k, ks, l, l1, lc, ls,  &
       m, ma, mac, mks
  LOGICAL :: erflg
!  INTEGER :: dum2, dum3
!  REAL(KIND=kdp) :: dum1
  ! ... Set string for use with rcs ident command
  CHARACTER(LEN=80) :: ident_string='$id: aplbci.f90,v 1.1 2008/04/01 20:09:59 klkipp exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  erflg = .FALSE.  
  ! ... well source terms
  IF(.NOT.cylind) THEN  
     ! ... cartesian coordinates
     DO iwel = 1,nwel  
        IF(ABS(qwm(iwel)) > 0.) THEN  
           DO ks = 1,nkswel(iwel)  
              mks = mwel(iwel,ks)  
              qwn = qwlyr(iwel,ks)  
              dqwlyr = dqwdpl(iwel,ks)*(dp(mks) - dpwkt(iwel))
              qwnp = qwn + dqwlyr  
              ma = mrno(mks)  
              IF(qwnp <= 0.) THEN        ! ... outflow
                 qswm = den0*qwnp*xp%c_w(mks)  
                 dqswdc = den0*qwnp  
              ELSE                      ! ... inflow
                 qswm = denwk(iwel,ks)*qwnp*xp%cwk(iwel,ks)
                 dqswdc = 0._kdp
              ENDIF
              va(7,ma) = va(7,ma) - fdtmth*dqswdc
              rhs(ma) = rhs(ma) + fdtmth*qswm
           END DO
        ENDIF
     END DO
  ELSE  
     ! ... cylindrical coordinates-single well
     awqm = MOD(ABS(wqmeth(1)),100)  
     iczm = 1  
     iczp = 6  
     DO ks = 1,nkswel(1)  
        mks = mwel(1,ks)  
        CALL mtoijk(mks,i,j,k,nx,nxy)
        ! ... current layer flow rates from wbcflo. these are averages over time
        ! ...      step.
        qfwav = qflyr(1,ks)
        ma = mrno(mks)  
        IF(qfwav <= 0.) THEN      ! ... outflow
           ! ... implicit treatment of solute well flows
           dqswdc = qfwav
        ELSE                     ! ... inflow
           dqswdc = 0._kdp
        ENDIF
        va(7,ma) = va(7,ma) - fdtmth*dqswdc
        rhs(ma) = rhs(ma) + fdtmth*xp%qslyr(iwel,ks)
     END DO
  ENDIF
  IF(nsbc > 0) THEN
     ! ... Apply specified p,t or c b.c. terms
     DO  ls=1,nsbc
        m = msbc(ls)
        WRITE(cibc,6001) ibc(m)  
6001    FORMAT(i9.9)
        ma = mrno(m)  
        if (frac(m) <= 0.0) cycle
        IF(cibc(7:7) == '1') THEN  
           DO  i=1,7
              xp%vassbc(i,ls) = va(i,ma)  
           END DO
           xp%rhssbc(ls) = rhs(ma)  
           DO  i=1,6  
              va(i,ma) = 0._kdp
           END DO
           va(7,ma) = 1._kdp
           rhs(ma) = xp%csbc(ls) - xp%c_w(m)  
        ELSEIF(cibc(1:1) == '1') THEN  
           IF(qfsbc(ls) <= 0.) THEN                ! ... outflow
              ! ... implicit treatment of solute b.c. flows
              qsbc3 = qfsbc(ls)*xp%c_w(m)  
              dqsdc = qfsbc(ls)
           ELSE                                   ! ... inflow
              qsbc3 = qfsbc(ls)*xp%csbc(ls)
              dqsdc = 0._kdp
           ENDIF
           va(7,ma) = va(7,ma) - fdtmth*dqsdc
           rhs(ma) = rhs(ma) + qsbc3
        ENDIF
     END DO
  END IF
  ! ... Apply specified flux b.c. implicit terms
  DO lc=1,nfbc_cells
     m = flux_seg_m(lc)     ! ... current flux communication cell
     DO ls=flux_seg_first(lc),flux_seg_last(lc)
        ufrac = 1._kdp
        IF(ABS(ifacefbc(ls)) < 3) ufrac = frac(m)     
        ! ... Redirect the flux from above to the free-surface cell
        IF(fresur .AND. ifacefbc(ls) ==3 .AND. frac(m) <= 0._kdp) THEN
           l1 = MOD(m,nxy)
           IF(l1 == 0) l1 = nxy
           m = mfsbc(l1)
        ENDIF
        IF (m == 0) EXIT          ! ... skip to next flux b.c. cell
        qn = qfflx(ls)*areafbc(ls)*ufrac
        ma = mrno(m)
        IF(qn <= 0.) THEN                ! ... outflow
           dqsdc = den0*qn
        ELSE                             ! ... inflow
           dqsdc = 0._kdp
        ENDIF
        va(7,ma) = va(7,ma) - fdtmth*dqsdc
     END DO
  END DO
  ! ... Apply aquifer leakage terms
  ! ...      Net segment method for solute
  DO lc=1,nlbc_cells
     m = leak_seg_m(lc)     ! ... current leakage communication cell
     ! ... Calculate current net aquifer leakage flow rate
     ! ...      Possible attenuation included explicitly
     IF(m == 0) CYCLE              ! ... dry column, skip to next leaky b.c. cell 
     qm_net = 0._kdp
     qfbc = 0._kdp
     dqfdp = 0._kdp
     DO ls=leak_seg_first(lc),leak_seg_last(lc)
        qn = albc(ls)
        qnp = qn - blbc(ls)*dp(m)
        IF(qnp <= 0._kdp) THEN           ! ... outflow
           qm_net = qm_net + den0*qnp
           qfbc = qfbc + den0*qn
           dqfdp = dqfdp - den0*blbc(ls)
        ELSE                             ! ... inflow
           IF(fresur .AND. ifacelbc(ls) == 3) THEN
              ! ... limit the flow rate for vertical leakage from above
              qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
                   - 0.5_kdp*den0*bblbc(ls)))
              IF(qnp <= qlim) THEN
                 qm_net = qm_net + denlbc(ls)*qnp
                 qfbc = qfbc + denlbc(ls)*qn
                 dqfdp = dqfdp - denlbc(ls)*blbc(ls)
              ELSEIF(qnp > qlim) THEN
                 qm_net = qm_net + denlbc(ls)*qlim
                 qfbc = qfbc + denlbc(ls)*qlim
                 ! hack for instability from the kink in q vs h relation
                 IF (steady_flow) dqfdp = dqfdp - denlbc(ls)*blbc(ls)
                 ! ... add nothing to dqfdp
              ENDIF
           ELSE          ! ... x or y face
              qm_net = qm_net + denlbc(ls)*qnp
              qfbc = qfbc + denlbc(ls)*qn  
              dqfdp = dqfdp - denlbc(ls)*blbc(ls)
           END IF
        ENDIF
     END DO
     ma = mrno(m)
     IF(qm_net <= 0._kdp) THEN           ! ... net outflow
        qsbc4 = qm_net*xp%c_w(m)
        dqsdc = qm_net  
     ELSE                                ! ... net inflow
        ! ... calculate flow weighted average concentrations for inflow segments
        qm_in = 0._kdp
        sum_cqm_in = 0._kdp
        DO ls=leak_seg_first(lc),leak_seg_last(lc)  
           qnp = albc(ls) - blbc(ls)*dp(m)
           IF(qnp > 0._kdp) THEN                   ! ... inflow
              IF(fresur .AND. ifacelbc(ls) == 3) THEN
                 ! ... limit the flow rate for vertical leakage from above
                 qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*  &
                      (zelbc(ls)-0.5_kdp*bblbc(ls)) - 0.5_kdp*den0*bblbc(ls)))
                 qnp = MIN(qnp,qlim)
                 qm_in = qm_in + denlbc(ls)*qnp
                 sum_cqm_in = sum_cqm_in + denlbc(ls)*qnp*xp%clbc(ls)  
              ELSE          ! ... x or y face
                 qm_in = qm_in + denlbc(ls)*qnp
                 sum_cqm_in = sum_cqm_in + denlbc(ls)*qnp*xp%clbc(ls)
              END IF
           ENDIF
        END DO
        cavg = sum_cqm_in/qm_in
        qsbc4 = qm_net*cavg
        dqsdc = 0._kdp
     ENDIF
     va(7,ma) = va(7,ma) - fdtmth*dqsdc 
     rhs(ma) = rhs(ma) + fdtmth*qsbc4
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
!!$              qfbc = den0*qn
!!$              dqfdp = -den0*blbc(ls)
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
!!$              qsbc4(is) = den0*qnp*c(m,is)
!!$              dqsdc = den0*qnp
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
     m = river_seg_m(lc)       ! ... current river communication cell
     ! ... calculate current net river leakage flow rate
     ! ...      possible attenuation included explicitly
     IF(m == 0) CYCLE              ! ... dry column, skip to next river b.c. cell 
     qm_net = 0._kdp
     qfbc = 0._kdp
     dqfdp = 0._kdp
     DO ls=river_seg_first(lc),river_seg_last(lc)
        qn = arbc(ls)
        qnp = qn - brbc(ls)*dp(m)      ! ... with steady state flow, qnp = qn always
        hrbc = phirbc(ls)/gz
        if(hrbc > zerbc(ls)) then      ! ... treat as river
            IF(qnp <= 0._kdp) THEN           ! ... outflow
                qm_net = qm_net + den0*qnp
                qfbc = qfbc + den0*qn
                dqfdp = dqfdp - den0*brbc(ls)
            ELSE                             ! ... inflow
                ! ... limit the flow rate for a river leakage
                qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                - 0.5_kdp*den0*bbrbc(ls)))
                IF(qnp <= qlim) THEN
                    qm_net = qm_net + denrbc(ls)*qnp
                    qfbc = qfbc + denrbc(ls)*qn  
                    dqfdp = dqfdp - denrbc(ls)*brbc(ls)
                ELSEIF(qnp > qlim) THEN
                    qm_net = qm_net + denrbc(ls)*qlim
                    qfbc = qfbc + denrbc(ls)*qlim
                    ! .. hack for instability from the kink in q vs h relation
                    IF (steady_flow) dqfdp = dqfdp - denrbc(ls)*brbc(ls)
                    ! ... add nothing to dqfdp
                ENDIF
            ENDIF
        else                           ! ... treat as drain 
            ma = mrno(m)
            IF(qnp <= 0.) THEN           ! ... outflow
                qsbc4 = den0*qnp*xp%c_w(m)
                dqsdc = den0*qnp
            ELSE                            ! ... inflow, not allowed
                qsbc4 = 0._kdp
                dqsdc = 0._kdp
            END IF
        end if            
     END DO
     ma = mrno(m)
     IF(qm_net <= 0._kdp) THEN           ! ... net outflow
        qsbc4 = qm_net*xp%c_w(m)  
        dqsdc = qm_net  
     ELSE                                ! ... net inflow
        ! ... calculate flow weighted average concentrations for inflow segments
        qm_in = 0._kdp
        sum_cqm_in = 0._kdp
        DO ls=river_seg_first(lc),river_seg_last(lc)
           qnp = arbc(ls) - brbc(ls)*dp(m)
           IF(qnp > 0._kdp) THEN                   ! ... inflow
              ! ... limit the flow rate for a river leakage
              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*  &
                   (zerbc(ls)-0.5_kdp*bbrbc(ls)) - 0.5_kdp*den0*bbrbc(ls)))
              qnp = MIN(qnp,qlim)
              qm_in = qm_in + denrbc(ls)*qnp
              sum_cqm_in = sum_cqm_in + denrbc(ls)*qnp*xp%crbc(ls)  
           ENDIF
        END DO
        cavg = sum_cqm_in/qm_in
        qsbc4 = qm_net*cavg
        dqsdc = 0._kdp
     ENDIF
     va(7,ma) = va(7,ma) - fdtmth*dqsdc 
     rhs(ma) = rhs(ma) + fdtmth*qsbc4
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
!!$              qfbc = den0*qn
!!$              dqfdp = -den0*brbc(ls)
!!$           ELSE                             ! ... inflow
!!$              ! ... limit the flow rate for a river leakage
!!$              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
!!$                   - 0.5_kdp*den0*bbrbc(ls)))
!!$              qnp = MIN(qnp,qlim)
!!$              qfbc = denrbc(ls)*qn
!!$              dqfdp = -denrbc(ls)*brbc(ls)
!!$           END IF
!!$           va(7,ma) = va(7,ma) - fdtmth*dqfdp
!!$           rhs(ma) = rhs(ma) + fdtmth*qfbc
!!$        ELSE IF(ieq == 3) THEN
!!$           IF(qnp <= 0.) THEN           ! ... outflow
!!$              qsbc4(is) = den0*qnp*c(m,is)
!!$              dqsdc = den0*qnp
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
     m = drain_seg_m(lc)       ! ... current drain communication cell
     ! ...      possible attenuation included explicitly
     qfbc = 0._kdp
     dqfdp = 0._kdp
     IF(m == 0) CYCLE
     DO ls=drain_seg_first(lc),drain_seg_last(lc)
        qn = adbc(ls)
        qnp = qn - bdbc(ls)*dp(m)      ! ... with steady state flow equation solution qnp = qn always
        ma = mrno(m)
        IF(qnp <= 0.) THEN           ! ... outflow
           qsbc4 = den0*qnp*xp%c_w(m)
           dqsdc = den0*qnp
        ELSE                            ! ... inflow, not allowed
           qsbc4 = 0._kdp
           dqsdc = 0._kdp
        END IF
        va(7,ma) = va(7,ma) - fdtmth*dqsdc
        rhs(ma) = rhs(ma) + fdtmth*qsbc4
     END DO
  END DO
  ! ... apply a.i.f. b.c. terms
  !... ** not implemented for phast
  IF(fresur) THEN
     ! ... Free-surface boundary condition
     DO m=1,nxyz
        IF(frac(m) <= 0.) THEN
           ! ... solve trivial equation for transient dry cells
           ma = mrno(m)
           WRITE(cibc, 6001) ibc(m)
           IF(cibc(7:7)  /= '1') THEN
              va(7,ma) = 1._kdp
              rhs(ma) = 0._kdp
              ! ... zero the va coefficients for cells connected to an empty cell
              ! ...      to resymmetrize the matrix
              DO ic=1,6  
                 mac = ci(ic,ma)  
                 IF(mac > 0) va(7-ic,mac) = 0._kdp  
              END DO
           ENDIF
        ENDIF
     END DO
  ENDIF
END SUBROUTINE XP_aplbci
