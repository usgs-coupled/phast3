SUBROUTINE rhsn_ss_flow
  ! ... Calculates right hand side terms at time level N,
  ! ...      and starts the step cumulative totals for the first portion
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
  REAL(KIND=kdp) :: qfbc, qlim, qm_net, qn, szzw, ufdt0, ufrac, wt
  REAL(KIND=kdp) :: hrbc
  INTEGER :: a_err, da_err, i, iwel, iwfss, j, k, ks, l, lc0, l1, lc, ls,  &
       m, mc0, mfs, mkt, nks
!!$  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qsbc3, qsbc4
  !     ------------------------------------------------------------------
  !...
  ufdt0 = 1._kdp-fdtmth
  ntsfal=0     ! ... Set number of failed time steps to zero
  ! ... Initialize the step b.c. flow accumulators
  !...  ***This could be put into an init4 routine***
  stotfi = 0._kdp
  stotfp = 0._kdp
!$$  stfaif = 0._kdp
  stffbc = 0._kdp
  stflbc = 0._kdp
  stfrbc = 0._kdp
  stfdbc = 0._kdp
  stfsbc = 0._kdp
  stfwel = 0._kdp
  IF (nwel > 0) then
     stfwi = 0._kdp
     stfwp = 0._kdp
  END IF
  ! ... Load current total fluid mass amount into storage
  ! ...      for nth time level
  firn=fir
  ! ... Zero r.h.s. arrays in preparation for next time level calculation
  rf = 0._kdp
!!$  IF(solute) rs = 0._kdp
  ! ... Calculate right hand side dispersive flux terms and
  ! ...      convective flux terms (not cross-dispersive flux terms)
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
           rf(m+1)=rf(m+1)+sxx(m)
           rf(m)=rf(m)-sxx(m)
20         CONTINUE
           ! ... Y-direction
           mijpk=cellno(i,j+1,k)
           IF(j == ny .OR. cylind) GO TO 30
           IF(frac(mijpk) <= 0.) GO TO 30
           wt=fdsmth
           IF(syy(m) < 0.) wt=1._kdp-wt
           rf(mijpk)=rf(mijpk)+syy(m)
           rf(m)=rf(m)-syy(m)
30         CONTINUE
           ! ... Z-direction
           IF(k == nz) GO TO 40
           mijkp=cellno(i,j,k+1)
           wt=fdsmth
           IF(szz(m) < 0.) wt=1._kdp-wt
           rf(mijkp)=rf(mijkp)+szz(m)
           rf(m)=rf(m)-szz(m)
40         CONTINUE
        END DO
     END DO
  END DO
  ! ... Load rhs with well explicit flow rates at each layer
  DO  iwel=1,nwel
     IF(wqmeth(iwel) == 0) CYCLE
     IF(.NOT.cylind .OR. wqmeth(iwel) == 11 .OR. wqmeth(iwel) == 13) THEN
        DO  k=1,nkswel(iwel)
           m=mwel(iwel,k)
           rf(m)=rf(m)+ufdt0*qflyr(iwel,k)
        END DO
     ELSE IF(cylind) THEN
        DO  ks=1,nkswel(iwel)-1
           m=mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           mijkp=m+nxy
           szzw=-tfw(k)*(p(mijkp)-p(m)+denwk(iwel,ks)*gz*(z(k+1)-z(k)))
           rf(mijkp)=rf(mijkp)+szzw
           rf(m)=rf(m)-szzw
        END DO
        nks=nkswel(iwel)
        mkt=mwel(iwel,nks)
        IF(wqmeth(iwel) <= 20 .OR. wqmeth(iwel) == 40)  &
             rf(mkt)=rf(mkt)-ufdt0*qwm(iwel)
     END IF
     ! ... Step cumulative flow rates from wells. To be converted to amounts
     ! ...      in SUMCAL
     iwfss=INT(SIGN(1._kdp,-qwm(iwel)))
     IF(ABS(qwm(iwel)) < 1.e-8_kdp) iwfss=0
     IF(iwfss >= 0) THEN            ! ... Production well
        stfwp(iwel) = -ufdt0*qwm(iwel)
        stotfp=stotfp+stfwp(iwel)
     ELSE IF(iwfss < 0) THEN        ! ... Injection well
        stfwi(iwel) = ufdt0*qwm(iwel)
        stotfi=stotfi+stfwi(iwel)
     END IF
  END DO
  ! ... Specified P,T,or C b.c. terms are applied in ASEMBL
  ! ... Apply specified flux b.c. dispersive and advective terms
  DO lc=1,nfbc_cells
     m = flux_seg_m(lc)
     sffb(lc) = 0._kdp
     sfvfb(lc) = 0._kdp
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
        qn = qfflx(ls)*areafbc(ls)
        sfvfb(lc) = sfvfb(lc) + qn
        IF(qn <= 0.) THEN        ! ... Outflow
           qfbc = den0*qn*ufrac
           stotfp = stotfp-ufdt0*qfbc
        ELSE                     ! ... Inflow
           qfbc = denfbc(ls)*qn*ufrac
           stotfi = stotfi+ufdt0*qfbc
        END IF
        rf(m) = rf(m) + ufdt0*qfbc
        sffb(lc) = sffb(lc) + qfbc
        stffbc = stffbc + ufdt0*qfbc
     END DO
  END DO
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
  ! ...      Calculate step total flow rates and cell step flow rates.
  DO  lc=1,nlbc
     m = leak_seg_m(lc)
     sflb(lc) = 0._kdp
     sfvlb(lc) = 0._kdp
     IF(m == 0) CYCLE              ! ... empty column 
     ! ... Calculate current net aquifer leakage flow rate
     qm_net = 0._kdp
     DO ls=leak_seg_first(lc),leak_seg_last(lc)
        qn = albc(ls)
        IF(qn <= 0.) THEN           ! ... Outflow
           qm_net = qm_net + den0*qn
           sfvlb(lc) = sfvlb(lc) + qn
        ELSE                              ! ... Inflow
           IF(fresur .AND. ifacelbc(ls) == 3) THEN
              ! ... Limit the flow rate for unconfined z-face leakage from above
              qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
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
     ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
        stotfi = stotfi + ufdt0*qflbc(lc)
     END IF
  END DO
  ! ... Calculate river leakage b.c. terms
  DO lc=1,nrbc
     ! ... Update the indices locating the cells communicating with the river
     mc0 = river_seg_m(lc)
     lc0 = MOD(mc0,nxy)
     IF(lc0 == 0) lc0 = nxy
     mfs = mfsbc(lc0)    ! ... currrent f.s. cell
!$$     river_seg_m(lc) = MIN(mfs,mrbc_bot(lc))
     river_seg_m(lc) = mfs            ! ... communicate with f.s. cell always
     DO ls=river_seg_first(lc),river_seg_last(lc)
!$$        mrbc(ls) = MIN(mfs,mrseg_bot(ls))    ! ... currrent river segment cell for aquifer head
        mrbc(ls) = river_seg_m(lc)     ! ... currrent river segment cell for aquifer head
                                             ! ... now the same as communication cell
     END DO
  END DO
  ! ...      Calculate step total flow rates and nodal step flow rates.
  DO  lc=1,nrbc                    ! ... by river cell communicating to aquifer
     m = river_seg_m(lc)     ! ... current communicating cell 
     sfrb(lc) = 0._kdp
     sfvrb(lc) = 0._kdp
     IF(m == 0) CYCLE          ! ... dry column
     ! ... Calculate current net aquifer leakage flow rate
     qm_net = 0._kdp
     DO ls=river_seg_first(lc),river_seg_last(lc)
        if (arbc(ls) .gt. 1.0e50_kdp) cycle
        qn = arbc(ls)
        hrbc = phirbc(ls)/gz
        if(hrbc > zerbc(ls)) then      ! ... treat as river
            IF(qn <= 0.) THEN         ! ... Outflow
                qm_net = qm_net + den0*qn
                sfvrb(lc) = sfvrb(lc) + qn
            ELSE                             ! ... Inflow
                ! ... Limit the flow rate for a river leakage
                qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                - 0.5_kdp*den0*bbrbc(ls)))
                qn = MIN(qn,qlim)
                qm_net = qm_net + denrbc(ls)*qn
                sfvrb(lc) = sfvrb(lc) + qn
            END IF
        else                           ! ... treat as drain 
           IF(qn <= 0._kdp) THEN         ! ... Outflow
              !qfbc = den(m)*qn
              qm_net = qm_net + den0*qn
              !stotfp = stotfp - ufdt0*qfbc
              sfvrb(lc) = sfvrb(lc) + qn
           ELSE                             ! ... Inflow, none allowed
              !qn = 0._kdp
              !qfbc = 0._kdp
              !stotfi = stotfi + ufdt0*qfbc
              !sfvrb(lc) = sfvrb(lc) + qn
           END IF
        end if            
     END DO
     rf(m) = rf(m) + ufdt0*qm_net
     sfrb(lc) = sfrb(lc) + qm_net
     stfrbc = stfrbc + ufdt0*qm_net
     IF(qm_net <= 0._kdp) THEN           ! ... net outflow
         stotfp = stotfp - ufdt0*qfrbc(lc)
     ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
         stotfi = stotfi + ufdt0*qfrbc(lc)
     END IF
  END DO
  ! ... Calculate drain leakage b.c. terms
  DO lc=1,ndbc
     ! ... Update the indices locating the cells communicating with the drain
!$$     !mc0 = drain_seg_index(lc)%m
!$$     !lc0 = MOD(mc0,nxy)
!$$     !IF(lc0 == 0) lc0 = nxy
!$$     !mfs = mfsbc(lc0)    ! ... currrent f.s. cell
!$$     drain_seg_index(lc)%m = MIN(mfs,mdbc_bot(lc))
!$$     !drain_seg_index(lc)%m = mfs            ! ... communicate with f.s. cell always
     DO ls=drain_seg_first(lc),drain_seg_last(lc)
!$$        mdbc(ls) = MIN(mfs,mrseg_bot(ls))    ! ... currrent drain segment cell for aquifer head
!$$        !mdbc(ls) = drain_seg_index(lc)%m     ! ... currrent drain segment cell for aquifer head
                                             ! ... now the same as communication cell
        drain_seg_m(lc) = mdbc(ls)                                               
     END DO
  END DO
  ! ...      Calculate step total flow rates and nodal step flow rates.
  DO  lc=1,ndbc                    ! ... by drain cell communicating to aquifer
     m = drain_seg_m(lc)       ! ... current communicating cell 
     sfdb(lc) = 0._kdp
     sfvdb(lc) = 0._kdp
     IF(m == 0) CYCLE              ! ... empty column 
     DO ls=drain_seg_first(lc),drain_seg_last(lc)
        if (adbc(ls) .gt. 1.0e50_kdp) cycle
        qn = adbc(ls)
        IF(qn <= 0.) THEN         ! ... Outflow
           qfbc = den0*qn
           stotfp = stotfp - ufdt0*qfbc
           sfvdb(lc) = sfvdb(lc) + qn
        ELSE                             ! ... Inflow, none allowed
           qn = 0._kdp
           qfbc = 0._kdp
           !stotfi = stotfi + ufdt0*qfbc
           !sfvdb(lc) = sfvdb(lc) + qn
        END IF
        rf(m) = rf(m) + ufdt0*qfbc
        sfdb(lc) = sfdb(lc) + qfbc
        stfdbc = stfdbc + ufdt0*qfbc
     END DO
  END DO
!!$  ! ... Calculate aquifer influence function b.c. terms
!!$  ! ...      Calculate step total flow rates and nodal step flow rates
!!$  !... *** not implemented in PHAST
END SUBROUTINE rhsn_ss_flow
