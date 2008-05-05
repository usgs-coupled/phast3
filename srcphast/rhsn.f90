SUBROUTINE rhsn
  ! ... Calculates right hand side terms at time level N,
  ! ...      and loads the step cumulative totals for the first portion
  ! ...      of the time step
  USE machine_constants, ONLY: kdp
!!$  USE f_units
  USE mcb
  USE mcc
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcv
  USE mcw
  IMPLICIT NONE
!$$  EXTERNAL ehoftp
!$$  REAL(KIND=kdp) :: ehoftp
  INTRINSIC INT
  REAL(KIND=kdp) :: qfbc, qlim, qm_in, qm_net, qn, szzw, ucwt, ufdt0, ufrac, wt
  INTEGER :: a_err, da_err, i, iis, iwel, iwfss, j, k, ks, l, lc0, l1,  &
       lc, ls, m, mc0, mfs, mkt, nks, nsa
  LOGICAL :: erflg
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: cavg, sum_cqm_in
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qsbc3, qsbc4
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  erflg=.FALSE.
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
!..  stfaif = 0._kdp
  stffbc = 0._kdp
  stflbc = 0._kdp
  stfrbc = 0._kdp
  stfdbc = 0._kdp
  stfsbc = 0._kdp
  stfwel = 0._kdp
!..  sthaif = 0._kdp
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
!..  stsaif = 0._kdp
  stswel = 0._kdp
  IF (nwel > 0) then
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
  ! ... Load current total fluid mass, heat, solute amounts into storage
  ! ...      for nth time level
  firn=fir
!!$  ehirn=ehir
  ! ... Zero r.h.s. arrays in preparation for next time level calculation
  rf = 0._kdp
!!$     IF(heat) rh = 0._kdp
  IF(solute) rs = 0._kdp
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
           rf(m+1)=rf(m+1)+sxx(m)
           rf(m)=rf(m)-sxx(m)
!!$           IF(heat) THEN
!!$              uhwt=((1._kdp-wt)*eh(m)+wt*eh(m+1))
!!$              rh(m+1)=rh(m+1)+sxx(m)*uhwt-thx(m)*(t(m+1)-t(m))
!!$              rh(m)=rh(m)-sxx(m)*uhwt+thx(m)*(t(m+1)-t(m))
!!$           END IF
           DO  iis=1,ns
              ucwt=((1._kdp-wt)*c(m,iis)+wt*c(m+1,iis))
              rs(m+1,iis)=rs(m+1,iis)+sxx(m)*ucwt-tsx(m)* (c(m+1,iis)-c(m,iis))
              rs(m,iis)=rs(m,iis)-sxx(m)*ucwt+tsx(m)* (c(m+1,iis)-c(m,iis))
           END DO
20         CONTINUE
           ! ... Y-direction
           mijpk=cellno(i,j+1,k)
           IF(j == ny .OR. cylind) GO TO 30
           IF(frac(mijpk) <= 0.) GO TO 30
           wt=fdsmth
           IF(syy(m) < 0.) wt=1._kdp-wt
           rf(mijpk)=rf(mijpk)+syy(m)
           rf(m)=rf(m)-syy(m)
!!$           IF(heat) THEN
!!$              uhwt=((1._kdp-wt)*eh(m)+wt*eh(mijpk))
!!$              rh(mijpk)=rh(mijpk)+syy(m)*uhwt-thy(m)*(t(mijpk)-t(m))
!!$              rh(m)=rh(m)-syy(m)*uhwt+thy(m)*(t(mijpk)-t(m))
!!$           END IF
           DO  iis=1,ns
              ucwt=((1._kdp-wt)*c(m,iis)+wt*c(mijpk,iis))
              rs(mijpk,iis)=rs(mijpk,iis)+syy(m)*ucwt-tsy(m)* (c(mijpk,iis)-c(m,iis))
              rs(m,iis)=rs(m,iis)-syy(m)*ucwt+tsy(m)* (c(mijpk,iis)-c(m,iis))
           END DO
30         CONTINUE
           ! ... Z-direction
           IF(k == nz) GO TO 40
           mijkp=cellno(i,j,k+1)
           wt=fdsmth
           IF(szz(m) < 0.) wt=1._kdp-wt
           rf(mijkp)=rf(mijkp)+szz(m)
           rf(m)=rf(m)-szz(m)
!!$           IF(heat) THEN
!!$              uhwt=((1._kdp-wt)*eh(m)+wt*eh(mijkp))
!!$              rh(mijkp)=rh(mijkp)+szz(m)*uhwt-thz(m)*(t(mijkp)-t(m))
!!$              rh(m)=rh(m)-szz(m)*uhwt+thz(m)*(t(mijkp)-t(m))
!!$           END IF
           DO  iis=1,ns
              ucwt=((1._kdp-wt)*c(m,iis)+wt*c(mijkp,iis))
              rs(mijkp,iis)=rs(mijkp,iis)+szz(m)*ucwt-tsz(m)* (c(mijkp,iis)-c(m,iis))
              rs(m,iis)=rs(m,iis)-szz(m)*ucwt+tsz(m)* (c(mijkp,iis)-c(m,iis))
           END DO
           ! ... No sorption or decay
40         CONTINUE
        END DO
     END DO
  END DO
  ! ... Load rhs with well, heat and solute explicit flow rates at each
  ! ...      layer
  DO  iwel=1,nwel
     IF(wqmeth(iwel) == 0) CYCLE
     IF(.NOT.cylind .OR. wqmeth(iwel) == 11 .OR. wqmeth(iwel) == 13) THEN
        DO  k=1,nkswel(iwel)
           m=mwel(iwel,k)
           rf(m)=rf(m)+ufdt0*qflyr(iwel,k)
!!$           IF(heat) rh(m)=rh(m)+ufdt0*qhlyr(iwel,k)
           DO  iis=1,ns
              rs(m,iis)=rs(m,iis)+ufdt0*qslyr(iwel,k,iis)
           END DO
        END DO
     ELSE IF(cylind) THEN
        DO  ks=1,nkswel(iwel)-1
           m=mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           mijkp=m+nxy
           szzw=-tfw(k)*(p(mijkp)-p(m)+denwk(iwel,ks)*gz*(z(k+1)-z(k)))
           rf(mijkp)=rf(mijkp)+szzw
           rf(m)=rf(m)-szzw
!!$           IF(heat) rh(m)=rh(m)+ufdt0*qhlyr(iwel,ks)
           DO  iis=1,ns
              rs(m,iis)=rs(m,iis)+ufdt0*qslyr(iwel,ks,iis)
           END DO
        END DO
        nks=nkswel(iwel)
        mkt=mwel(iwel,nks)
        IF(wqmeth(iwel) <= 20 .OR. wqmeth(iwel) == 40)  &
             rf(mkt)=rf(mkt)-ufdt0*qwm(iwel)
!!$        IF(heat) rh(mkt)=rh(mkt)+ufdt0*qhlyr(iwel,nks)
        DO  iis=1,ns
           rs(mkt,iis)=rs(mkt,iis)+ufdt0*qslyr(iwel,nks,iis)
        END DO
     END IF
     ! ... Step cumulative flow rates from wells. To be converted to amounts
     ! ...      in SUMCAL
     iwfss=INT(SIGN(1._kdp,-qwm(iwel)))
     IF(ABS(qwm(iwel)) < 1.e-8_kdp) iwfss=0
     IF(iwfss >= 0) THEN            ! ... Production well
        stfwp(iwel) = -ufdt0*qwm(iwel)
!!$        sthwp(iwel) = -ufdt0*qhw(iwel)
        stotfp=stotfp+stfwp(iwel)
        !        stothp=stothp+sthwp(iwel)
        DO  iis=1,ns
           stswp(iwel,iis) = -ufdt0*qsw(iwel,iis)
           stotsp(iis)=stotsp(iis)+stswp(iwel,iis)
        END DO
     ELSE IF(iwfss < 0) THEN        ! ... Injection well
        stfwi(iwel) = ufdt0*qwm(iwel)
!!$        sthwi(iwel)=ufdt0*qhw(iwel)
        stotfi=stotfi+stfwi(iwel)
!!$        stothi=stothi+sthwi(iwel)
        DO  iis=1,ns
           stswi(iwel,iis) = ufdt0*qsw(iwel,iis)
           stotsi(iis)=stotsi(iis)+stswi(iwel,iis)
        END DO
     END IF
  END DO
  ! ... Specified P,T,or C b.c. terms are applied in ASEMBL
  ! ... Apply specified flux b.c. dispersive and advective terms
  DO lc=1,nfbc_cells
     m = flux_seg_index(lc)%m
     sffb(lc) = 0._kdp
     sfvfb(lc) = 0._kdp
     ssfb(lc,:) = 0._kdp
     IF(m == 0) CYCLE     ! ... dry column
     DO ls=flux_seg_index(lc)%seg_first,flux_seg_index(lc)%seg_last
        ufrac = 1._kdp
        IF(ifacefbc(ls) < 3) ufrac = frac(m)
        IF(fresur .AND. ifacefbc(ls) == 3 .AND. m >= mtp1) THEN
           ! ... Redirect the flux to the free-surface cell
           l1 = MOD(m,nxy)
           IF(l1 == 0) l1 = nxy
           m = mfsbc(l1)
        ENDIF
        IF(m == 0) CYCLE     ! ... dry column
        ! ... Calculate step total flow rate contributions and
        ! ...      cell step flow rate contributions.
        qn = qfflx(ls)*areafbc(ls)
        sfvfb(lc) = sfvfb(lc) + qn
        IF(qn <= 0.) THEN        ! ... Outflow
           qfbc = den(m)*qn*ufrac
           stotfp = stotfp-ufdt0*qfbc
!!$        qhbc=qfbc*eh(m)
!!$        stothp = stothp-ufdt0*qhbc
           DO  iis=1,ns
              qsbc3(iis) = qfbc*c(m,iis)
              stotsp(iis) = stotsp(iis)-ufdt0*qsbc3(iis)
           END DO
        ELSE                     ! ... Inflow
           qfbc = denfbc(ls)*qn*ufrac
           stotfi = stotfi+ufdt0*qfbc
!!$        IF(heat) qhbc=qfbc*ehoftp(tflx(l),p(m),erflg)
!!$        stothi=stothi+ufdt0*qhbc
           DO  iis=1,ns
              qsbc3(iis) = qfbc*cfbc(ls,iis)
              stotsi(iis) = stotsi(iis)+ufdt0*qsbc3(iis)
           END DO
        END IF
        rf(m) = rf(m) + ufdt0*qfbc
        sffb(lc) = sffb(lc) + qfbc
        stffbc = stffbc + ufdt0*qfbc
!!$     IF(heat) THEN
!!$        qhbc2=qhfbc(l)*ufrac
!!$        IF(qhbc2 <= 0.) THEN
!!$           stothp=stothp-0.5*qhbc2
!!$        ELSE
!!$           stothi=stothi+0.5*qhbc2
!!$        END IF
!!$        rh(m)=rh(m)+ufdt0*(qhbc2+qhbc)
!!$        shfb(l)=qhbc+qhbc2
!!$        sthfbc=sthfbc+0.5*(qhbc2+qhbc)
!!$     END IF
        DO  iis=1,ns
           qsbc4(iis) = qsflx(ls,iis)*areafbc(ls)*ufrac
           IF(qsbc4(iis) <= 0.) THEN
              stotsp(iis) = stotsp(iis) - ufdt0*qsbc4(iis)
           ELSE
              stotsi(iis) = stotsi(iis) + ufdt0*qsbc4(iis)
           END IF
           rs(m,iis) = rs(m,iis) + ufdt0*(qsbc4(iis)+qsbc3(iis))
           ssfb(lc,iis) = ssfb(lc,iis) + qsbc3(iis)+qsbc4(iis)
           stsfbc(iis) = stsfbc(iis) + ufdt0*(qsbc4(iis)+qsbc3(iis))
        END DO
     END DO
!!$  IF(erflg) THEN
!!$     WRITE(fuclog,9001) 'EHOFTP interpolation error in RHSN ',  &
!!$          'Associated heat flux: Specified flux b.c.'
!!$9001 FORMAT(tr10,2A,i4)
!!$     ierr(134)=.TRUE.
!!$     errexe=.TRUE.
!!$     RETURN
!!$  END IF
  END DO
  ! ... Calculate leakage b.c. terms
  ! ... Allocate scratch space
  ALLOCATE (cavg(nsa), sum_cqm_in(nsa),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: rhsn, point 2"  
     STOP
  ENDIF
  DO  lc=1,nlbc
     m = leak_seg_index(lc)%m
     sflb(lc) = 0._kdp
     sfvlb(lc) = 0._kdp
     sslb(lc,:) = 0._kdp
     IF(m == 0) CYCLE              ! ... empty column 
     ! ... Calculate current net aquifer leakage flow rate
     qm_net = 0._kdp
     DO ls=leak_seg_index(lc)%seg_first,leak_seg_index(lc)%seg_last
        qn = albc(ls)
        IF(qn <= 0._kdp) THEN       ! ... Outflow
           qm_net = qm_net + den(m)*qn
           sfvlb(lc) = sfvlb(lc) + qn
        ELSE                          ! ... Inflow
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
        DO ls=leak_seg_index(lc)%seg_first,leak_seg_index(lc)%seg_last
           qn = albc(ls)
           IF(qn > 0._kdp) THEN                   ! ... inflow
              qm_in = qm_in + denlbc(ls)*qn
              DO  iis=1,ns
                 sum_cqm_in(iis) = sum_cqm_in(iis) + denlbc(ls)*qn*clbc(ls,iis)
              END DO
           ENDIF
        END DO
        DO iis=1,ns
           cavg(iis) = sum_cqm_in(iis)/qm_in
           qsbc4(iis) = qm_net*cavg(iis)
           stotsi(iis) = stotsi(iis) + ufdt0*qsbc4(iis)
           rs(m,iis) = rs(m,iis) + ufdt0*qsbc4(iis)
           sslb(lc,iis) = sslb(lc,iis) + qsbc4(iis)
           stslbc(iis) = stslbc(iis) + ufdt0*qsbc4(iis)
        END DO
     ENDIF
  END DO
  DEALLOCATE (cavg, sum_cqm_in, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, rhsn"  
     STOP
  ENDIF
  ! ... Calculate river leakage b.c. terms
  ! ... Allocate scratch space
  ALLOCATE (cavg(nsa), sum_cqm_in(nsa),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: rhsn, point 3"
     STOP
  ENDIF
  DO lc=1,nrbc
     ! ... Update the indices locating the cells communicating with the river
     mc0 = river_seg_index(lc)%m
     lc0 = MOD(mc0,nxy)
     IF(lc0 == 0) lc0 = nxy
     mfs = mfsbc(lc0)    ! ... currrent f.s. cell
!     river_seg_index(lc)%m = MIN(mfs,mrbc_bot(lc))
     river_seg_index(lc)%m = mfs            ! ... communicate with f.s. cell always
     DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
!        mrbc(ls) = MIN(mfs,mrseg_bot(ls))     ! ... currrent river segment cell for aquifer head
        mrbc(ls) = river_seg_index(lc)%m     ! ... currrent river segment cell for aquifer head
                                             ! ... now the same as communication cell
     END DO
  END DO
  ! ...      Calculate step total flow rates and cell step flow rates.
  DO  lc=1,nrbc                    ! ... by river cell communicating to aquifer
     m = river_seg_index(lc)%m     ! ... current communicating cell 
     sfrb(lc) = 0._kdp
     sfvrb(lc) = 0._kdp
     ssrb(lc,:) = 0._kdp
     IF(m == 0) CYCLE              ! ... empty column 
     ! ... Calculate current net aquifer leakage flow rate
     qm_net = 0._kdp
     DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
        qn = arbc(ls)
        IF(qn <= 0._kdp) THEN           ! ... Outflow
           qm_net = qm_net + den(m)*qn
           sfvrb(lc) = sfvrb(lc) + qn
        ELSE                            ! ... Inflow
           ! ... Limit the flow rate for a river leakage
           qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                - 0.5_kdp*den(m)*bbrbc(ls)))
           qn = MIN(qn,qlim)
           qm_net = qm_net + denrbc(ls)*qn
           sfvrb(lc) = sfvrb(lc) + qn
        END IF
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
        DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
           qn = arbc(ls)
           IF(qn > 0._kdp) THEN                   ! ... inflow
              ! ... limit the flow rate for a river leakage
              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*  &
                   (zerbc(ls)-0.5_kdp*bbrbc(ls)) - 0.5_kdp*den(m)*bbrbc(ls)))
              qn = MIN(qn,qlim)
              qm_in = qm_in + denrbc(ls)*qn
              DO  iis=1,ns              
                 sum_cqm_in(iis) = sum_cqm_in(iis) + denrbc(ls)*qn*crbc(ls,iis)
              END DO
           ENDIF
        END DO
        DO iis=1,ns
           cavg(iis) = sum_cqm_in(iis)/qm_in
           qsbc4(iis) = qm_net*cavg(iis)
           stotsi(iis) = stotsi(iis) + ufdt0*qsbc4(iis)
           rs(m,iis) = rs(m,iis) + ufdt0*qsbc4(iis)
           ssrb(lc,iis) = ssrb(lc,iis) + qsbc4(iis)
           stsrbc(iis) = stsrbc(iis) + ufdt0*qsbc4(iis)
        END DO
     ENDIF
  END DO
  DEALLOCATE (cavg, sum_cqm_in, &
       stat = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed, rhsn"
     STOP
  ENDIF
  ! ... Calculate drain leakage b.c. terms
  DO lc=1,ndbc
     ! ... Update the indices locating the cells communicating with the drain
     mc0 = drain_seg_index(lc)%m
     lc0 = MOD(mc0,nxy)
     IF(lc0 == 0) lc0 = nxy
     mfs = mfsbc(lc0)    ! ... currrent f.s. cell
!     drain_seg_index(lc)%m = MIN(mfs,mdbc_bot(lc))
     drain_seg_index(lc)%m = mfs            ! ... communicate with f.s. cell always
     DO ls=drain_seg_index(lc)%seg_first,drain_seg_index(lc)%seg_last
!        mdbc(ls) = MIN(mfs,mrseg_bot(ls))     ! ... currrent drain segment cell for aquifer head
        mdbc(ls) = drain_seg_index(lc)%m     ! ... currrent drain segment cell for aquifer head
                                             ! ... now the same as communication cell
     END DO
  END DO
  ! ...      Calculate step total flow rates and cell step flow rates.
  DO  lc=1,ndbc                    ! ... by drain cell communicating to aquifer
     m = drain_seg_index(lc)%m     ! ... current communicating cell 
     sfdb(lc) = 0._kdp
     sfvdb(lc) = 0._kdp
     ssdb(lc,:) = 0._kdp
     IF(m == 0) CYCLE              ! ... empty column 
     DO ls=drain_seg_index(lc)%seg_first,drain_seg_index(lc)%seg_last
        qn = adbc(ls)
        IF(qn <= 0.) THEN      ! ... Outflow
           qfbc = den(m)*qn
           stotfp = stotfp - ufdt0*qfbc
!!$        STOTHP=STOTHP-0.5*QHDBC(LC)
           sfvdb(lc) = sfvdb(lc) + qn
           DO  iis=1,ns
              qsbc3(iis) = qfbc*c(m,iis)
              stotsp(iis) = stotsp(iis) - ufdt0*qsbc3(iis)
           END DO
        ELSE                        ! ... Inflow
           qfbc = 0._kdp
           stotfi = stotfi + ufdt0*qfbc
!!$        STOTHI=STOTHI+0.5*QHDBC(LC)
           sfvdb(lc) = sfvdb(lc) + qn
           DO  iis=1,ns
              qsbc3(iis) = 0._kdp
              stotsi(iis) = stotsi(iis) + ufdt0*qsbc3(iis)
           END DO
        END IF
        rf(m) = rf(m) + ufdt0*qfbc
        sfdb(lc) = sfdb(lc) + qfbc
        stfdbc = stfdbc + ufdt0*qfbc
!!$     IF(HEAT) THEN
!!$       RH(M)=RH(M)+UFDT0*QHDBC(LC)
!!$       SHRB(LC)=QHDBC(LC)
!!$       STHDBC=STHDBC+0.5*QHDBC(LC)
!!$     ENDIF
        DO  iis=1,ns
           rs(m,iis) = rs(m,iis) + ufdt0*qsbc3(iis)
           ssdb(lc,iis) = ssdb(lc,iis) + qsbc3(iis)
           stsdbc(iis) = stsdbc(iis) + ufdt0*qsbc3(iis)
        END DO
     END DO
  END DO
!!$  ! ... Calculate aquifer influence function b.c. terms
!!$  ! ...      Calculate step total flow rates and nodal step flow rates
!!$  !... *** not implemented in PHAST
!!$  DO  l=1,naifc
!!$     m=maifc(l)
!!$     IF(qfaif(l) <= 0.) THEN
!!$        ! ... Outflow
!!$        stotfp=stotfp-0.5*qfaif(l)
!!$        stothp=stothp-0.5*qhaif(l)
!!$        !...            STOTSP=STOTSP-0.5*QSAIF(L)
!!$        sfvaif(l)=qfaif(l)/den(m)
!!$        ! ... Inflow
!!$     ELSE
!!$        stotfi=stotfi+0.5*qfaif(l)
!!$        stothi=stothi+0.5*qhaif(l)
!!$        !...            STOTSI=STOTSI+0.5*QSAIF(L)
!!$        sfvaif(l)=qfaif(l)/denoar(l)
!!$     END IF
!!$     rf(m)=rf(m)+ufdt0*qfaif(l)
!!$     sfaif(l)=qfaif(l)
!!$     stfaif=stfaif+0.5*qfaif(l)
!!$     IF(heat) THEN
!!$        rh(m)=rh(m)+ufdt0*qhaif(l)
!!$        shaif(l)=qhaif(l)
!!$        sthaif=sthaif+0.5*qhaif(l)
!!$     END IF
!!$     IF(solute) THEN
!!$        !...            RS(M)=RS(M)+UFDT0*QSAIF(L)
!!$        stsaif(l)=qsaif(l)
!!$        !            STSAIF=STSAIF+0.5*QSAIF(L)
!!$     END IF
!!$  END DO
!!$  IF(heat) THEN
!!$     !... *** not implemented in PHAST
!!$     ! ... Calculate heat conduction b.c. and apply to r.h.s.
!!$     ! ...      Calculate step total flow rates
!!$     DO  l=1,nhcbc
!!$        m=mhcbc(l)
!!$        rh(m)=rh(m)+ufdt0*qhcbc(l)
!!$        IF(qhcbc(l) <= 0.) THEN
!!$           stothp=stothp-0.5*qhcbc(l)
!!$        ELSE
!!$           stothi=stothi+0.5*qhcbc(l)
!!$        END IF
!!$        sthhcb=sthhcb+0.5*qhcbc(l)
!!$     END DO
!!$  END IF
  DEALLOCATE (qsbc3, qsbc4,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, rhsn"  
     STOP
  ENDIF
END SUBROUTINE rhsn
