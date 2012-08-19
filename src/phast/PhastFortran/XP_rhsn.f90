SUBROUTINE XP_rhsn_thread(xp)
  ! ... Calculates right hand side terms at time level N,
  ! ...      for transport equation for one component
  !
  USE machine_constants, ONLY: kdp
  USE mcb, ONLY: ibc, fresur, nfbc, nfbc_cells, flux_seg_m, flux_seg_first,  &
       flux_seg_last, leak_seg_first, leak_seg_last,  &
       river_seg_first, river_seg_last,  &
       drain_seg_first, drain_seg_last, &
       mfsbc, mdbc, qfflx_n, areafbc, denfbc, &
       nlbc, nrbc, ndbc, albc, blbc, &
       denlbc, philbc, bblbc, zelbc, qflbc, &
       arbc, brbc, denrbc, phirbc, zerbc, bbrbc, qfrbc, &
       adbc, & 
       ifacefbc, ifacelbc
  USE mcc, ONLY: cylind
  USE mcg, ONLY: nx, nxy, ny, nz, cellno
  USE mcn, ONLY: z
  USE mcp, ONLY: fdsmth, fdtmth, gz, den0
  USE mcv, ONLY: frac, p
  USE mcw, ONLY: nwel, tfw, wqmeth, nkswel, mwel
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTRINSIC INT
  REAL(KIND=kdp) :: qfbc, qlim, qm_in, qm_net, szzw, qn, ucwt, ufdt0, ufrac, wt
  INTEGER :: i, iwel, j, k, ks, lc0, l1,  &
       lc, ls, m, mc0, mfs, mkt, nks
  INTEGER :: mijpk, mijkp
  REAL(KIND=kdp) :: cavg, sum_cqm_in
  REAL(KIND=kdp) :: qsbc3, qsbc4
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: XP_rhsn.f90,v 1.4 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  ufdt0 = 1._kdp-fdtmth
  xp%ntsfal=0         ! ... Set number of failed time steps to zero
  !!$ iis = xp%iis_no          ! ... Set the component number
  ! ... Zero r.h.s. arrays in preparation for next time level calculation
  !$$  rf = 0._kdp
  xp%rs = 0._kdp
  ! ... Calculate right hand side dispersive flux terms and
  ! ...      advective flux terms (not cross-dispersive flux terms)
  ! ... Inactive cells are excluded by zero flow rate and transmissivity
  ! ... Dry cells are isolated by zero flow rate
  DO  k=1,nz
     DO  j=1,ny
        DO  i=1,nx
           m=cellno(i,j,k)
           IF(ibc(m) == -1) CYCLE
           ! ... X-direction
           IF(i == nx) GO TO 20
           IF(frac(m+1) <= 0.) GO TO 20
           wt=fdsmth
           IF(xp%sxx(m) < 0.) wt=1._kdp-wt
           ucwt=((1._kdp-wt)*xp%c_w(m)+wt*xp%c_w(m+1))
           xp%rs(m+1)=xp%rs(m+1)+xp%sxx(m)*ucwt-xp%tsx(m)*(xp%c_w(m+1)-xp%c_w(m))
           xp%rs(m)=xp%rs(m)-xp%sxx(m)*ucwt+xp%tsx(m)*(xp%c_w(m+1)-xp%c_w(m))
20         CONTINUE
           ! ... Y-direction
           mijpk=cellno(i,j+1,k)
           IF(j == ny .OR. cylind) GO TO 30
           IF(frac(mijpk) <= 0.) GO TO 30
           wt=fdsmth
           IF(xp%syy(m) < 0.) wt=1._kdp-wt
           ucwt=((1._kdp-wt)*xp%c_w(m)+wt*xp%c_w(mijpk))
           xp%rs(mijpk)=xp%rs(mijpk)+xp%syy(m)*ucwt-xp%tsy(m)*(xp%c_w(mijpk)-xp%c_w(m))
           xp%rs(m)=xp%rs(m)-xp%syy(m)*ucwt+xp%tsy(m)*(xp%c_w(mijpk)-xp%c_w(m))
30         CONTINUE
           ! ... Z-direction
           IF(k == nz) GO TO 40
           mijkp=cellno(i,j,k+1)
           wt=fdsmth
           IF(xp%szz(m) < 0.) wt=1._kdp-wt
           ucwt=((1._kdp-wt)*xp%c_w(m)+wt*xp%c_w(mijkp))
           xp%rs(mijkp)=xp%rs(mijkp)+xp%szz(m)*ucwt-xp%tsz(m)*(xp%c_w(mijkp)-xp%c_w(m))
           xp%rs(m)=xp%rs(m)-xp%szz(m)*ucwt+xp%tsz(m)*(xp%c_w(mijkp)-xp%c_w(m))
40         CONTINUE
        END DO
     END DO
  END DO
  IF(nwel > 0) THEN  
     ! ... Load rhs with well solute explicit flow rates at each layer
     DO  iwel=1,nwel
        IF(wqmeth(iwel) == 0) CYCLE
        IF(.NOT.cylind .OR. wqmeth(iwel) == 11 .OR. wqmeth(iwel) == 13) THEN
           DO  k=1,nkswel(iwel)
              m=mwel(iwel,k)
              xp%rs(m)=xp%rs(m)+ufdt0*xp%qslyr_n(iwel,k)
           END DO
        ELSE IF(cylind) THEN
           DO  ks=1,nkswel(iwel)-1
              m=mwel(iwel,ks)
              CALL mtoijk(m,i,j,k,nx,ny)
              mijkp=m+nxy
              !szzw=-tfw(k)*(p(mijkp)-p(m)+denwk(iwel,ks)*gz*(z(k+1)-z(k)))
              szzw=-tfw(k)*(p(mijkp)-p(m)+den0*gz*(z(k+1)-z(k)))
              xp%rs(m)=xp%rs(m)+ufdt0*xp%qslyr_n(iwel,ks)
           END DO
           nks=nkswel(iwel)
           mkt=mwel(iwel,nks)
           xp%rs(mkt)=xp%rs(mkt)+ufdt0*xp%qslyr_n(iwel,nks)
        END IF
     END DO
  END IF
  ! ... Specified P or C b.c. terms are applied in ASEMBL
  IF(nfbc > 0) THEN
     ! ... Apply specified flux b.c. dispersive and advective terms
     DO lc=1,nfbc_cells
        m = flux_seg_m(lc)
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
           IF(qn <= 0.) THEN        ! ... Outflow
              qfbc = den0*qn*ufrac
              !$$           stotfp = stotfp-ufdt0*qfbc
              qsbc3 = qfbc*xp%c_w(m)
           ELSE                     ! ... Inflow
              qfbc = denfbc(ls)*qn*ufrac
              !$$             stotfi = stotfi+ufdt0*qfbc
              qsbc3 = qfbc*xp%cfbc_n(ls)
           END IF
           qsbc4 = xp%qsflx_n(ls)*areafbc(ls)*ufrac
           xp%rs(m) = xp%rs(m) + ufdt0*(qsbc4+qsbc3)
        END DO
     END DO
  END IF

  IF(nlbc > 0) THEN
     ! ... Calculate leakage b.c. terms
     IF(fresur) THEN
        DO lc=1,nlbc
           ! ... Update the indices locating the cells communicating with leaky layer
           mc0 = xp%leak_seg_m(lc)
           lc0 = MOD(mc0,nxy)
           IF(lc0 == 0) lc0 = nxy
           mfs = mfsbc(lc0)    ! ... currrent f.s. cell in column lc0
           !$$     leak_seg_index(lc)%m = MIN(mfs,mrbc_bot(lc))
           DO ls=leak_seg_first(lc),leak_seg_last(lc)
              IF(ifacelbc(ls) == 3) THEN
                 xp%leak_seg_m(lc) = mfs            ! ... communicate with f.s. cell always
                 !$$        xp%mrbc(ls) = MIN(mfs,mrseg_bot(ls))    ! ... currrent leakage segment cell 
                 xp%mlbc(ls) = xp%leak_seg_m(lc)     ! ... currrent leakage segment cell for aquifer head
              END IF                            ! ... now the same as communication cell
           END DO
        END DO
     END IF
     DO  lc=1,nlbc
        m = xp%leak_seg_m(lc)          ! ... current communicating cell
        IF(m == 0) CYCLE              ! ... empty column 
        ! ... Calculate current net aquifer leakage flow rate
        qm_net = 0._kdp
        DO ls=leak_seg_first(lc),leak_seg_last(lc)
           qn = albc(ls)
           IF(qn <= 0._kdp) THEN       ! ... Outflow
              qm_net = qm_net + den0*qn
              !$$              sfvlb(lc) = sfvlb(lc) + qn
           ELSE                          ! ... Inflow
              IF(fresur .AND. ifacelbc(ls) == 3) THEN
                 ! ... Limit the flow rate for unconfined z-face leakage from above
                 qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
                      - 0.5_kdp*den0*bblbc(ls)))
                 qn = MIN(qn,qlim)
              END IF
              qm_net = qm_net + denlbc(ls)*qn
              !$$              xp%sfvlb(lc) = xp%sfvlb(lc) + qn
           END IF
        END DO
        IF(qm_net <= 0._kdp) THEN           ! ... net outflow
           qsbc4 = qflbc(lc)*xp%c_w(m)
        ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
           ! ... calculate flow weighted average concentrations for inflow segments
           qm_in = 0._kdp
           sum_cqm_in = 0._kdp
           DO ls=leak_seg_first(lc),leak_seg_last(lc)
              qn = albc(ls)
              IF(qn > 0._kdp) THEN                   ! ... inflow
                 IF(fresur .AND. ifacelbc(ls) == 3) THEN
                    ! ... limit the flow rate for unconfined z-face leakage from above
                    qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*  &
                         (zelbc(ls)-0.5_kdp*bblbc(ls)) - 0.5_kdp*den0*bblbc(ls)))
                    qn = MIN(qn,qlim)
                 END IF
                 qm_in = qm_in + denlbc(ls)*qn
                 sum_cqm_in = sum_cqm_in + denlbc(ls)*qn*xp%clbc_n(ls)
              ENDIF
           END DO
           cavg = sum_cqm_in/qm_in
           qsbc4 = qm_net*cavg
           xp%rs(m) = xp%rs(m) + ufdt0*qsbc4
        ENDIF
     END DO
  END IF

  IF(nrbc > 0) THEN
     ! ... Calculate river leakage b.c. terms
     ! ... Allocate scratch space
     DO lc=1,nrbc
        ! ... Update the indices locating the cells communicating with the river
        mc0 = xp%river_seg_m(lc)
        lc0 = MOD(mc0,nxy)
        IF(lc0 == 0) lc0 = nxy
        mfs = mfsbc(lc0)    ! ... currrent f.s. cell
        !$$     river_seg_index(lc)%m = MIN(mfs,mrbc_bot(lc))
        xp%river_seg_m(lc) = mfs            ! ... communicate with f.s. cell always
        DO ls=river_seg_first(lc),river_seg_last(lc)
           !$$        xp%mrbc(ls) = MIN(mfs,mrseg_bot(ls))     ! ... currrent river segment cell for aquifer head
           xp%mrbc(ls) = xp%river_seg_m(lc)       ! ... currrent river segment cell for aquifer head
           ! ... now the same as communication cell
        END DO
     END DO
     ! ...      Calculate step total flow rates and cell step flow rates.
     DO  lc=1,nrbc                    ! ... by river cell communicating to aquifer
        m = xp%river_seg_m(lc)       ! ... current communicating cell 
        IF(m == 0) CYCLE              ! ... dry column, skip to next river b.c. cell 
        ! ... Calculate current net river leakage flow rate
        qm_net = 0._kdp
        DO ls=river_seg_first(lc),river_seg_last(lc)
           qn = arbc(ls)
           IF(qn <= 0._kdp) THEN           ! ... Outflow
              qm_net = qm_net + den0*qn
           ELSE                            ! ... Inflow
              ! ... Limit the flow rate for a river leakage
              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                   - 0.5_kdp*den0*bbrbc(ls)))
              qn = MIN(qn,qlim)
              qm_net = qm_net + denrbc(ls)*qn
           END IF
        END DO
        IF(qm_net <= 0._kdp) THEN           ! ... net outflow
           qsbc3 = qfrbc(lc)*xp%c_w(m)
        ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
           ! ... calculate flow weighted average concentrations for inflow segments
           qm_in = 0._kdp
           sum_cqm_in = 0._kdp
           DO ls=river_seg_first(lc),river_seg_last(lc)
              qn = arbc(ls)
              IF(qn > 0._kdp) THEN                   ! ... inflow
                 ! ... limit the flow rate for a river leakage
                 qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*  &
                      (zerbc(ls)-0.5_kdp*bbrbc(ls)) - 0.5_kdp*den0*bbrbc(ls)))
                 qn = MIN(qn,qlim)
                 qm_in = qm_in + denrbc(ls)*qn
                 sum_cqm_in = sum_cqm_in + denrbc(ls)*qn*xp%crbc_n(ls)
              ENDIF
           END DO
           cavg = sum_cqm_in/qm_in
           qsbc4 = qm_net*cavg
           xp%rs(m) = xp%rs(m) + ufdt0*qsbc4
        ENDIF
     END DO
  END IF

  IF(ndbc > 0) THEN
     ! ... Calculate drain leakage b.c. terms
     DO lc=1,ndbc
        ! ... Update the indices locating the cells communicating with the drain
        DO ls=drain_seg_first(lc),drain_seg_last(lc)
           ! ... now the same as communication cell
           xp%drain_seg_m(lc) = mdbc(ls)                                    
        END DO
     END DO
     ! ...      Calculate step total flow rates and cell step flow rates.
     DO  lc=1,ndbc                    ! ... by drain cell communicating to aquifer
        m = xp%drain_seg_m(lc)       ! ... current communicating cell 
        IF(m == 0) CYCLE              ! ... empty column 
        DO ls=drain_seg_first(lc),drain_seg_last(lc)
           qn = adbc(ls)
           IF(qn <= 0.) THEN      ! ... Outflow
              qfbc = den0*qn
              qsbc3 = qfbc*xp%c_w(m)
           ELSE                        ! ... Inflow, none allowed
              qn = 0._kdp
              qfbc = 0._kdp
              qsbc3 = 0._kdp
           END IF
           xp%rs(m) = xp%rs(m) + ufdt0*qsbc3
        END DO
     END DO
  END IF

END SUBROUTINE XP_rhsn_thread
SUBROUTINE XP_rhsn(xp)
  ! ... Calculates right hand side terms at time level N,
  ! ...      for transport equation for one component
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcv
  USE mcw
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTRINSIC INT
  REAL(KIND=kdp) :: qfbc, qlim, qm_in, qm_net, szzw, qn, ucwt, ufdt0, ufrac, wt
  INTEGER :: i, iwel, j, k, ks, lc0, l1,  &
       lc, ls, m, mc0, mfs, mkt, nks
  REAL(KIND=kdp) :: cavg, sum_cqm_in
  REAL(KIND=kdp) :: qsbc3, qsbc4
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: XP_rhsn.f90,v 1.4 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  ufdt0 = 1._kdp-fdtmth
  ntsfal=0         ! ... Set number of failed time steps to zero
  !!$ iis = xp%iis_no          ! ... Set the component number
  ! ... Zero r.h.s. arrays in preparation for next time level calculation
  !$$  rf = 0._kdp
  xp%rs = 0._kdp
  ! ... Calculate right hand side dispersive flux terms and
  ! ...      advective flux terms (not cross-dispersive flux terms)
  ! ... Inactive cells are excluded by zero flow rate and transmissivity
  ! ... Dry cells are isolated by zero flow rate
  DO  k=1,nz
     DO  j=1,ny
        DO  i=1,nx
           m=cellno(i,j,k)
           IF(ibc(m) == -1) CYCLE
           ! ... X-direction
           IF(i == nx) GO TO 20
           IF(frac(m+1) <= 0.) GO TO 20
           wt=fdsmth
           IF(sxx(m) < 0.) wt=1._kdp-wt
           ucwt=((1._kdp-wt)*xp%c_w(m)+wt*xp%c_w(m+1))
           xp%rs(m+1)=xp%rs(m+1)+sxx(m)*ucwt-tsx(m)*(xp%c_w(m+1)-xp%c_w(m))
           xp%rs(m)=xp%rs(m)-sxx(m)*ucwt+tsx(m)*(xp%c_w(m+1)-xp%c_w(m))
20         CONTINUE
           ! ... Y-direction
           mijpk=cellno(i,j+1,k)
           IF(j == ny .OR. cylind) GO TO 30
           IF(frac(mijpk) <= 0.) GO TO 30
           wt=fdsmth
           IF(syy(m) < 0.) wt=1._kdp-wt
           ucwt=((1._kdp-wt)*xp%c_w(m)+wt*xp%c_w(mijpk))
           xp%rs(mijpk)=xp%rs(mijpk)+syy(m)*ucwt-tsy(m)*(xp%c_w(mijpk)-xp%c_w(m))
           xp%rs(m)=xp%rs(m)-syy(m)*ucwt+tsy(m)*(xp%c_w(mijpk)-xp%c_w(m))
30         CONTINUE
           ! ... Z-direction
           IF(k == nz) GO TO 40
           mijkp=cellno(i,j,k+1)
           wt=fdsmth
           IF(szz(m) < 0.) wt=1._kdp-wt
           ucwt=((1._kdp-wt)*xp%c_w(m)+wt*xp%c_w(mijkp))
           xp%rs(mijkp)=xp%rs(mijkp)+szz(m)*ucwt-tsz(m)*(xp%c_w(mijkp)-xp%c_w(m))
           xp%rs(m)=xp%rs(m)-szz(m)*ucwt+tsz(m)*(xp%c_w(mijkp)-xp%c_w(m))
40         CONTINUE
        END DO
     END DO
  END DO
  IF(nwel > 0) THEN  
     ! ... Load rhs with well solute explicit flow rates at each layer
     DO  iwel=1,nwel
        IF(wqmeth(iwel) == 0) CYCLE
        IF(.NOT.cylind .OR. wqmeth(iwel) == 11 .OR. wqmeth(iwel) == 13) THEN
           DO  k=1,nkswel(iwel)
              m=mwel(iwel,k)
              xp%rs(m)=xp%rs(m)+ufdt0*xp%qslyr_n(iwel,k)
           END DO
        ELSE IF(cylind) THEN
           DO  ks=1,nkswel(iwel)-1
              m=mwel(iwel,ks)
              CALL mtoijk(m,i,j,k,nx,ny)
              mijkp=m+nxy
              szzw=-tfw(k)*(p(mijkp)-p(m)+denwk(iwel,ks)*gz*(z(k+1)-z(k)))
              xp%rs(m)=xp%rs(m)+ufdt0*xp%qslyr_n(iwel,ks)
           END DO
           nks=nkswel(iwel)
           mkt=mwel(iwel,nks)
           xp%rs(mkt)=xp%rs(mkt)+ufdt0*xp%qslyr_n(iwel,nks)
        END IF
     END DO
  END IF
  ! ... Specified P or C b.c. terms are applied in ASEMBL
  IF(nfbc > 0) THEN
     ! ... Apply specified flux b.c. dispersive and advective terms
     DO lc=1,nfbc_cells
        m = flux_seg_m(lc)
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
           IF(qn <= 0.) THEN        ! ... Outflow
              qfbc = den0*qn*ufrac
              !$$           stotfp = stotfp-ufdt0*qfbc
              qsbc3 = qfbc*xp%c_w(m)
           ELSE                     ! ... Inflow
              qfbc = denfbc(ls)*qn*ufrac
              !$$             stotfi = stotfi+ufdt0*qfbc
              qsbc3 = qfbc*xp%cfbc_n(ls)
           END IF
           qsbc4 = xp%qsflx_n(ls)*areafbc(ls)*ufrac
           xp%rs(m) = xp%rs(m) + ufdt0*(qsbc4+qsbc3)
        END DO
     END DO
  END IF

  IF(nlbc > 0) THEN
     ! ... Calculate leakage b.c. terms
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
        m = leak_seg_m(lc)          ! ... current communicating cell
        IF(m == 0) CYCLE              ! ... empty column 
        ! ... Calculate current net aquifer leakage flow rate
        qm_net = 0._kdp
        DO ls=leak_seg_first(lc),leak_seg_last(lc)
           qn = albc(ls)
           IF(qn <= 0._kdp) THEN       ! ... Outflow
              qm_net = qm_net + den0*qn
              !$$              sfvlb(lc) = sfvlb(lc) + qn
           ELSE                          ! ... Inflow
              IF(fresur .AND. ifacelbc(ls) == 3) THEN
                 ! ... Limit the flow rate for unconfined z-face leakage from above
                 qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
                      - 0.5_kdp*den0*bblbc(ls)))
                 qn = MIN(qn,qlim)
              END IF
              qm_net = qm_net + denlbc(ls)*qn
              !$$              xp%sfvlb(lc) = xp%sfvlb(lc) + qn
           END IF
        END DO
        IF(qm_net <= 0._kdp) THEN           ! ... net outflow
           qsbc4 = qflbc(lc)*xp%c_w(m)
        ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
           ! ... calculate flow weighted average concentrations for inflow segments
           qm_in = 0._kdp
           sum_cqm_in = 0._kdp
           DO ls=leak_seg_first(lc),leak_seg_last(lc)
              qn = albc(ls)
              IF(qn > 0._kdp) THEN                   ! ... inflow
                 IF(fresur .AND. ifacelbc(ls) == 3) THEN
                    ! ... limit the flow rate for unconfined z-face leakage from above
                    qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*  &
                         (zelbc(ls)-0.5_kdp*bblbc(ls)) - 0.5_kdp*den0*bblbc(ls)))
                    qn = MIN(qn,qlim)
                 END IF
                 qm_in = qm_in + denlbc(ls)*qn
                 sum_cqm_in = sum_cqm_in + denlbc(ls)*qn*xp%clbc_n(ls)
              ENDIF
           END DO
           cavg = sum_cqm_in/qm_in
           qsbc4 = qm_net*cavg
           xp%rs(m) = xp%rs(m) + ufdt0*qsbc4
        ENDIF
     END DO
  END IF

  IF(nrbc > 0) THEN
     ! ... Calculate river leakage b.c. terms
     ! ... Allocate scratch space
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
        IF(m == 0) CYCLE              ! ... dry column, skip to next river b.c. cell 
        ! ... Calculate current net river leakage flow rate
        qm_net = 0._kdp
        DO ls=river_seg_first(lc),river_seg_last(lc)
           qn = arbc(ls)
           IF(qn <= 0._kdp) THEN           ! ... Outflow
              qm_net = qm_net + den0*qn
           ELSE                            ! ... Inflow
              ! ... Limit the flow rate for a river leakage
              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                   - 0.5_kdp*den0*bbrbc(ls)))
              qn = MIN(qn,qlim)
              qm_net = qm_net + denrbc(ls)*qn
           END IF
        END DO
        IF(qm_net <= 0._kdp) THEN           ! ... net outflow
           qsbc3 = qfrbc(lc)*xp%c_w(m)
        ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
           ! ... calculate flow weighted average concentrations for inflow segments
           qm_in = 0._kdp
           sum_cqm_in = 0._kdp
           DO ls=river_seg_first(lc),river_seg_last(lc)
              qn = arbc(ls)
              IF(qn > 0._kdp) THEN                   ! ... inflow
                 ! ... limit the flow rate for a river leakage
                 qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*  &
                      (zerbc(ls)-0.5_kdp*bbrbc(ls)) - 0.5_kdp*den0*bbrbc(ls)))
                 qn = MIN(qn,qlim)
                 qm_in = qm_in + denrbc(ls)*qn
                 sum_cqm_in = sum_cqm_in + denrbc(ls)*qn*xp%crbc_n(ls)
              ENDIF
           END DO
           cavg = sum_cqm_in/qm_in
           qsbc4 = qm_net*cavg
           xp%rs(m) = xp%rs(m) + ufdt0*qsbc4
        ENDIF
     END DO
  END IF

  IF(ndbc > 0) THEN
     ! ... Calculate drain leakage b.c. terms
     DO lc=1,ndbc
        ! ... Update the indices locating the cells communicating with the drain
        DO ls=drain_seg_first(lc),drain_seg_last(lc)
           ! ... now the same as communication cell
           drain_seg_m(lc) = mdbc(ls)                                    
        END DO
     END DO
     ! ...      Calculate step total flow rates and cell step flow rates.
     DO  lc=1,ndbc                    ! ... by drain cell communicating to aquifer
        m = drain_seg_m(lc)       ! ... current communicating cell 
        IF(m == 0) CYCLE              ! ... empty column 
        DO ls=drain_seg_first(lc),drain_seg_last(lc)
           qn = adbc(ls)
           IF(qn <= 0.) THEN      ! ... Outflow
              qfbc = den0*qn
              qsbc3 = qfbc*xp%c_w(m)
           ELSE                        ! ... Inflow, none allowed
              qn = 0._kdp
              qfbc = 0._kdp
              qsbc3 = 0._kdp
           END IF
           xp%rs(m) = xp%rs(m) + ufdt0*qsbc3
        END DO
     END DO
  END IF

END SUBROUTINE XP_rhsn

