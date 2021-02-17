SUBROUTINE aplbci_flow  
  ! ... Applies the implicit terms of the boundary conditions  and the
  ! ...      well source terms to the assembled equation matrix
  ! ...      and right hand side
  ! ... Called once for flow
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcm
  USE mcm_m
  USE mcp
  USE mcp_m
  USE mcs
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m
  IMPLICIT NONE
  INTRINSIC index
  CHARACTER(LEN=9) :: cibc
!!$!  REAL(KIND=kdp) :: cavg, dqfdp, dqfwdp, dqhbc, dqhdp, dqhdt, dqhwdp, &
!!$!       dqhwdt, dqsbc, dqsdc, dqsdp, dqswdc, dqswdp, dqwlyr, ehaif, ehlbc, &
!!$!       qfbc, qfwav, qfwn, qhbc, qhwm, qlim, qm_in, qm_net, qn, qnp, qsbc, qwn, qwnp, &
!!$!       sum_cqm_in, ufrac
  REAL(KIND=kdp) :: dqfdp, dqfwdp,  &
       dqsbc, dqwlyr, &
       qfbc, qfwav, qfwn, qlim, qm_net, qn, qnp, qwn, qwnp, &
       ufrac
  REAL(KIND=kdp) :: hrbc
  INTEGER :: awqm, i, ic, iczm, iczp, iwel, j, k, ks, l, l1, lc, ls,  &
       m, ma, mac, mks
  LOGICAL :: erflg
  !     ------------------------------------------------------------------
  !...
  erflg = .FALSE.  
  ! ... Well source terms
  IF(.NOT.cylind) THEN                 ! ... cartesian coordinates
     DO  iwel = 1, nwel  
        IF(ABS(qwm(iwel)) > 0.) THEN  
           DO  ks=1,nkswel(iwel)  
              mks = mwel(iwel,ks)  
              qwn = qwlyr(iwel,ks)  
              dqwlyr = dqwdpl(iwel,ks)*(dp(mks) - dpwkt(iwel))
              qwnp = qwn + dqwlyr  
              ma = mrno(mks)  
              IF(qwnp <= 0.) THEN       ! ... outflow
                 qfwn = den0*(qwlyr(iwel,ks) - dqwdpl(iwel,ks)*dpwkt(iwel))
                 dqfwdp = den0*dqwdpl(iwel,ks)  
              ELSE                      ! ... inflow
                 qfwn = denwk(iwel,ks)*(qwlyr(iwel,ks) - dqwdpl(iwel,ks)*dpwkt(iwel))
                 dqfwdp = denwk(iwel,ks)*dqwdpl(iwel,ks)  
              ENDIF
              va(7,ma) = va(7,ma) - fdtmth*dqfwdp  
              rhs(ma) = rhs(ma) + fdtmth*qfwn  
           END DO
        ENDIF
     END DO
  ELSE                           ! ... cylindrical coordinates-single well
     awqm = MOD(ABS(wqmeth(1)), 100)  
     iczm = 1  
     iczp = 6  
     DO  ks=1,nkswel(1)
        mks = mwel(1,ks)  
        CALL mtoijk(mks, i, j, k, nx, nxy)  
        ! ... Current layer flow rates from wbcflo. These are averages over time
        ! ...      step.
        qfwav = qflyr(1,ks)  
        ma = mrno(mks)  
        IF(ks > 1) THEN  
           va(iczm,ma) = va(iczm,ma) - fdtmth*tfw(k-1)  
           va(7,ma) = va(7,ma) + fdtmth*tfw(k-1)  
        ENDIF
        IF(ks < nkswel(1)) THEN  
           va(iczp,ma) = va(iczp,ma) - fdtmth*tfw(k)  
           va(7,ma) = va(7,ma) + fdtmth*tfw(k)  
        ENDIF
        IF(ks == nkswel(1)) THEN  
           IF(awqm == 30 .OR. awqm == 50) THEN  
              DO  i=1,6  
                 va(i,ma) = 0._kdp  
              END DO
              va(7,ma) = 1._kdp  
              rhs(ma) = pwkt(1) - p(mks)  
           ENDIF
        ENDIF
     END DO
  ENDIF
  ! ... Apply specified p,t or c b.c. terms
  erflg = .FALSE.  
  IF(nsbc > 0 ) THEN
     DO  l=1,nsbc  
        m = msbc(l)  
        WRITE(cibc, 6001) ibc(m)  
6001    FORMAT(i9.9)
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
        END IF
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
           qfbc = den0*qn
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
     END DO
  END DO
  ! ... Apply aquifer leakage terms
  ! ...      Net segment method for solute
  DO lc=1,nlbc_cells
     m = leak_seg_m(lc)     ! ... current leakage communication cell
     ! ... calculate current net aquifer leakage flow rate
     ! ...      possible attenuation included explicitly
     IF(m == 0) CYCLE              ! ... dry column, skip to next leaky b.c. cell 
     qm_net = 0._kdp
     qfbc = 0._kdp
     dqfdp = 0._kdp
     DO ls=leak_seg_first(lc),leak_seg_last(lc)
        qn = albc(ls)
        qnp = qn - blbc(ls)*dp(m)
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
              ! *** hack for instability from the kink in q vs h relation
              IF (steady_flow) dqfdp = dqfdp - denlbc(ls)*blbc(ls)
              ! ... add nothing to dqfdp
              dqfdp = dqfdp - denlbc(ls)*blbc(ls)
           ENDIF
        ELSE          ! ... x or y face
           IF(qnp <= 0._kdp) THEN           ! ... outflow
              qm_net = qm_net + den0*qnp
              qfbc = qfbc + den0*qn
              dqfdp = dqfdp - den0*blbc(ls)
           ELSE                             ! ... inflow
              qm_net = qm_net + denlbc(ls)*qnp
              qfbc = qfbc + denlbc(ls)*qn  
              dqfdp = dqfdp - denlbc(ls)*blbc(ls)
           ENDIF
        END IF
     END DO
     ma = mrno(m)
     va(7,ma) = va(7,ma) - fdtmth*dqfdp
     rhs(ma) = rhs(ma) + fdtmth*qfbc
  END DO
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
        if (arbc(ls) .gt. 1e50_kdp) cycle
        qn = arbc(ls)
        qnp = qn - brbc(ls)*dp(m)      ! ... with steady state flow, qnp = qn always
        hrbc = phirbc(ls)/gz
        ! continuity as a function of (hrbc - zerbc(ls))
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
                    ! hack for instability from the kink in q vs h relation
                    IF (steady_flow) dqfdp = dqfdp - denrbc(ls)*brbc(ls)
                    ! ... add nothing to dqfdp
                    dqfdp = dqfdp - denrbc(ls)*brbc(ls)
                ENDIF
            ENDIF
        else                           ! ... treat as drain 
           !IF(qnp <= 0._kdp) THEN           ! ... outflow
           IF(qnp <= 0._kdp) THEN
              qm_net = qm_net + den0*qnp
              qfbc = qfbc + den0*qn
              dqfdp = dqfdp - den0*brbc(ls)
           ELSE                             ! ... inflow, not allowed
              !qfbc = 0._kdp
              !dqfdp = 0._kdp
              !write(*,*) "Mass loss spot ",qnp, qn, dp(m), hrbc, zerbc(ls)
              !qm_net = qm_net + den(m)*qnp
              !qfbc = qfbc + den(m)*qn              
              dqfdp = dqfdp - den0*brbc(ls)
           END IF
        end if
     END DO
     ma = mrno(m)
     va(7,ma) = va(7,ma) - fdtmth*dqfdp
     rhs(ma) = rhs(ma) + fdtmth*qfbc
  END DO
  ! ... Apply each segment
  DO lc=1,ndbc_cells
     m = drain_seg_m(lc)       ! ... current drain communication cell
     ! ...      possible attenuation included explicitly
     qfbc = 0._kdp
     dqfdp = 0._kdp
     IF(m == 0) CYCLE
     DO ls=drain_seg_first(lc),drain_seg_last(lc)
        if (adbc(ls) .gt. 1.0e50_kdp) cycle
        qn = adbc(ls)
        qnp = qn - bdbc(ls)*dp(m)      ! ... with steady state flow equation solution qnp = qn always
        ma = mrno(m)
        IF(qnp <= 0._kdp) THEN           ! ... outflow
           qfbc = den0*qn
           dqfdp = -den0*bdbc(ls)
        ELSE                             ! ... inflow, not allowed
           qfbc = 0._kdp
           dqfdp = 0._kdp
        END IF
        va(7,ma) = va(7,ma) - fdtmth*dqfdp
        rhs(ma) = rhs(ma) + fdtmth*qfbc
     END DO
  END DO
!!$  ! ... apply a.i.f. b.c. terms
!!$  !... ** not implemented for phast
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
           ENDIF
        ENDIF
     END DO
  ENDIF

END SUBROUTINE aplbci_flow
