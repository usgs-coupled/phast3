SUBROUTINE sumcal1_manager
  ! ... Performs summary calculations at end of time step for transport with
  ! ...      steady-state flow
  ! ... This is the first block of sumcal. The second block follows the
  ! ...      chemical reaction calculations
  USE machine_constants
!!$  USE f_units
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcch
  USE mcch_m
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
!!$  USE mg2_m, ONLY: hdprnt, wt_elev
  IMPLICIT NONE
  INTERFACE
     SUBROUTINE sbcflo(iequ,ddv,ufracnp,qdvsbc,rhssbc,vasbc)
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) :: iequ
       REAL(KIND=kdp), DIMENSION(0:), INTENT(IN) :: ddv
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: ufracnp
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: qdvsbc
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: rhssbc
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: vasbc
     END SUBROUTINE sbcflo
  END INTERFACE
  !
!!$  CHARACTER(LEN=50) :: aform = '(TR5,A45,T47,1PE12.4,TR1,A7,T66,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=46) :: aformt = '(TR5,A43,1PE12.4,TR1,A7,TR1,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=9) :: cibc
  REAL(KIND=kdp) :: denmfs, qfbc,  &
       qlim, qm_in, qm_net, qn, qnp,  &
       u0, u1, ufdt0, ufdt1,  &
       ufrac, up0, z0, zfsl, zm1, zp1
  REAL(KIND=kdp) :: u6
  REAL(KIND=kdp) :: hrbc
  INTEGER :: a_err, da_err, i, iis, imod, iwel, j, k, l, lc, l1, ls, m, mt, nsa
  INTEGER :: mpmax
  INTEGER, DIMENSION(:), ALLOCATABLE :: mcmax
!$$  LOGICAL :: erflg
  CHARACTER(LEN=130) :: logline1
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: cavg, sum_cqm_in
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qsbc3, qsbc4
!!$  REAL(KIND=kdp), DIMENSION(nxy) :: fracn
  !     ------------------------------------------------------------------
  !...
  ufdt0 = 1._kdp - fdtmth
  ufdt1 = fdtmth
  nsa = MAX(ns,1)
  dpmax=0._kdp
  dhmax=0._kdp
  dtmax=0._kdp
  DO  iis=1,ns
     dcmax(iis)=0._kdp
  END DO
  ! ... Allocate scratch space
  ALLOCATE (mcmax(nsa), zfsn(nxy),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: sumcal1_manager, point 1"
     STOP
  ENDIF
  DO  m=1,nxyz
     IF(ibc(m) == -1 .OR. frac(m) <= 0.) CYCLE
     ! ... Find maximum changes in dependent variables
        IF(ABS(dp(m)) >= ABS(dpmax)) THEN
            dpmax=dp(m)
             mpmax=m
        END IF
        DO  iis=1,ns
           IF((ABS(dc(m,iis)) >= ABS(dcmax(iis)))) THEN
              dcmax(iis)=dc(m,iis)
              mcmax(iis)=m
           END IF
        END DO
  END DO
  ! ... Decode into IMAX,JMAX,KMAX
  CALL mtoijk(mpmax,ipmax,jpmax,kpmax,nx,ny)
  dhmax=dpmax/(den0*gz)
  DO  iis=1,ns
     CALL mtoijk(mcmax(iis),icmax(iis),jcmax(iis),kcmax(iis),nx,ny)
  END DO
  DEALLOCATE (mcmax, &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, sumcal1_manager"  
     STOP
  ENDIF
  ! ... Check for unacceptable time step length
  ! ...  ***not used at present ***
!!$  IF(autots .AND. jtime > 2) THEN
!!$     ! ... Algorithm from Aziz & Settari p.404
!!$     IF(ABS(dpmax) > 1.5*dptas) tsfail=.TRUE.
!!$     IF(ABS(dtmax) > 1.5*dttas) tsfail=.TRUE.
!!$     DO  iis=1,ns
!!$        IF(ABS(dcmax(iis)) > 1.5*dctas(iis)) tsfail=.TRUE.
!!$     END DO
!!$     IF(tsfail) THEN
!!$        itime=itime-1
!!$        ntsfal=ntsfal+1
!!$        IF(ntsfal > 5 .OR. deltim <= dtimmn) THEN
!!$           ierr(170)=.TRUE.
!!$           errexe=.TRUE.
!!$        END IF
!!$        WRITE(logline1,2001) 'Current time step length '//dots,cnvtmi*deltim,'  ('//unittm//')'
!!$2001    FORMAT(a60,1PG12.3,A)
!!$!**        status = RM_LogMessage(rm_id, logline1)
!!$        WRITE(logline1,2002) 'Current time step length .....',cnvtmi*deltim,'  ('//unittm//')'
!!$2002    FORMAT(a,1PG12.3,A)
!!$!**        status = RM_ScreenMessage(rm_id, logline1)
!!$        WRITE(logline1,5001) 'Maximum change in potentiometric head '//dots,  &
!!$             cnvpi*dhmax,' ('//unitl//')',' at location (',  &
!!$             cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax), ')(',unitl//')'
!!$5001    FORMAT(A45,1PE14.4,A8,A,3(1PG10.3,A),A)
!!$        status = RM_LogMessage(rm_id, logline1)
!!$        status = RM_ScreenMessage(rm_id, logline1)
!!$        DO  iis=1,ns
!!$           WRITE(logline1,3102) 'Component no. ',iis,'  ',comp_name(iis)
!!$3102       FORMAT(a,i4,a,a)
!!$           status = RM_LogMessage(rm_id, logline1)
!!$           status = RM_ScreenMessage(rm_id, logline1)
!!$           !$$           WRITE(*,2102) 'Component no. ',iis,comp_name(iis)
!!$           !2102       FORMAT(/tr10,a,i4,tr2,a)
!!$           u6=dcmax(iis)
!!$           WRITE(logline1,5001) 'Maximum change in '//mflbl//'fraction '//dots,  &
!!$                u6,'(-)','at location (',cnvli*x(icmax(iis)),',',cnvli*y(jcmax(iis)),',',  &
!!$                cnvli*z(kcmax(iis)),' )(',unitl//')'
!!$           status = RM_LogMessage(rm_id, logline1)
!!$           status = RM_ScreenMessage(rm_id, logline1)
!!$           !$$           WRITE(*,aformt) 'Maximum change in '//mflbl//'fraction '//dots,  &
!!$           !$$                u6,'(-)','at location (',  &
!!$           !$$                cnvli*x(icmax(iis)),',',cnvli*y(jcmax(iis)),',',  &
!!$           !$$                cnvli*z(kcmax(iis)),')(',unitl,')'
!!$        END DO
!!$        RETURN
!!$     END IF
!!$  END IF
  time = time + deltim
  IF(nwel > 0) THEN
     ! ... Sum the injection rates and production rates for the wells
     tqwfp=0._kdp
     tqwhp=0._kdp
     tqwfi=0._kdp
     tqwhi=0._kdp
     totwfi=0._kdp
     totwfp=0._kdp
     totwhi=0._kdp
     totwhp=0._kdp
     DO  iis=1,ns
        tqwsp(iis)=0._kdp
        tqwsi(iis)=0._kdp
        totwsi(iis)=0._kdp
        totwsp(iis)=0._kdp
     END DO
     ! ... Obtain well flow rates and conditions
     CALL wbbal
     DO  iwel=1,nwel
        IF(wqmeth(iwel) == 0) CYCLE
        IF(qwm(iwel) <= 0._kdp) THEN     ! ... Production wells
           ! ... Step total flow rates
           ! ... Production rate totals for all wells
           ! ... Cumulative amounts for each well
           stotfp = stotfp-ufdt1*qwm(iwel)
           tqwfp=tqwfp-qwm(iwel)
           stfwp(iwel) = stfwp(iwel)-ufdt1*qwm(iwel)
           DO  iis=1,ns
              stotsp(iis) = stotsp(iis)-ufdt1*qsw(iwel,iis)
              tqwsp(iis)=tqwsp(iis)-qsw(iwel,iis)
              stswp(iwel,iis) = stswp(iwel,iis)-ufdt1*qsw(iwel,iis)
           END DO
        ELSE                             ! ... Injection wells
           ! ... Step total flow rates
           ! ... Injection rate totals for all wells
           ! ... Cumulative amounts for each well
           stotfi = stotfi+ufdt1*qwm(iwel)
           tqwfi=tqwfi+qwm(iwel)
           stfwi(iwel) = stfwi(iwel)+ufdt1*qwm(iwel)
           DO  iis=1,ns
              stotsi(iis) = stotsi(iis)+ufdt1*qsw(iwel,iis)
              tqwsi(iis)=tqwsi(iis)+qsw(iwel,iis)
              stswi(iwel,iis) = stswi(iwel,iis)+ufdt1*qsw(iwel,iis)
           END DO
        END IF
        ! ... Cumulative amounts for each well and for all wells
        wfpcum(iwel)=wfpcum(iwel)+stfwp(iwel)*deltim
        wficum(iwel)=wficum(iwel)+stfwi(iwel)*deltim
        ! ... Convert step total flow rates to step total amounts and add net to
        ! ...      the sum for the wells
        stfwel=stfwel+(stfwi(iwel)-stfwp(iwel))*deltim
        DO  iis=1,ns
           stswel(iis)=stswel(iis)+(stswi(iwel,iis)-stswp(iwel,iis))*deltim
        END DO
        totwfp=totwfp+wfpcum(iwel)
        totwfi=totwfi+wficum(iwel)
        DO  iis=1,ns
           wspcum(iwel,iis)=wspcum(iwel,iis)+stswp(iwel,iis)*deltim
           wsicum(iwel,iis)=wsicum(iwel,iis)+stswi(iwel,iis)*deltim
           totwsp(iis)=totwsp(iis)+wspcum(iwel,iis)
           totwsi(iis)=totwsi(iis)+wsicum(iwel,iis)
        END DO
     END DO
  END IF
  ! ... Calculate specified P,C b.c. cell boundary flow rates and amounts
  ! ...      and associated solute flow rates and amounts
  IF(nsbc > 0) THEN
     ! ... Fluid flows calculated in ASMSLP
     !...         CALL SBCFLO(1,DP,FRACNP,QFSBC,RHFSBC,VAFSBC)
     DO  iis=1,ns
        dcv => dc(0:,iis)
        qssbcv => qssbc(:,iis)
        rhsbcv => rhssbc(:,iis)
        vasbcv => vassbc(:,:,iis)
        CALL sbcflo(3,dcv,fracnp,qssbcv,rhsbcv,vasbcv)
     END DO
  END IF
  DO l=1,nsbc
     m=msbc(l)
     ! ... In case of specified head in dry cells
     sfsb(l) = 0._kdp
     sfvsb(l) = 0._kdp
     DO  iis=1,ns
        sssb(l,iis) = 0._kdp
     END DO
     IF(frac(m) <= 0._kdp) CYCLE
     WRITE(cibc,6001) ibc(m)
6001 FORMAT(i9.9)
     ! ... Sum fluid and diffusive or associated heat and solute fluxes
     ! ...      Flow rates calculated in SBCFLO
     IF(cibc(1:1) == '1') THEN
        IF(qfsbc(l) <= 0._kdp) THEN       ! ... Outflow boundary
           stotfp=stotfp-qfsbc(l)   ! .. wt factor included
        ELSE                              ! ... Inflow boundary
           stotfi=stotfi+qfsbc(l)   ! .. wt factor included
        END IF
        sfsb(l)=qfsbc(l)
        sfvsb(l)=qfsbc(l)/den0
        stfsbc=stfsbc+qfsbc(l)   ! .. wt factor included
        ! ... Calculate advective heat and solute flows at specified
        ! ...      pressure b.c. cells
        IF(cibc(7:7) /= '1') THEN
           DO  iis=1,ns
              IF(qfsbc(l) <= 0._kdp) THEN
                 qssbc(l,iis)=qfsbc(l)*(c(m,iis)-ufdt0*dc(m,iis))
                 stotsp(iis) = stotsp(iis)-qssbc(l,iis)     ! .. wt factor included
              ELSE
                 qssbc(l,iis)=qfsbc(l)*csbc(l,iis)
                 stotsi(iis) = stotsi(iis)+qssbc(l,iis)     ! .. wt factor included
              END IF
              sssb(l,iis)=qssbc(l,iis)
              stssbc(iis) = stssbc(iis)+qssbc(l,iis)   ! .. wt factor included
           END DO
        END IF
     END IF
     IF(cibc(7:7) == '1') THEN
        DO  iis=1,ns
           IF(qssbc(l,iis) <= 0._kdp) THEN              ! ... Outflow boundary
              stotsp(iis) = stotsp(iis)-qssbc(l,iis)     ! .. wt factor included
           ELSE                                   ! ... Inflow boundary
              stotsi(iis) = stotsi(iis)+qssbc(l,iis)     ! .. wt factor included
           END IF
           sssb(l,iis)=qssbc(l,iis)
           stssbc(iis) = stssbc(iis)+qssbc(l,iis)     ! .. wt factor included
        END DO
     END IF
  END DO
  ! ... Compute total cumulative cell flow amounts
  ! ...      flow rate is over entire time step by balance calculation
  DO  l=1,nsbc
     ccfsb(l) = ccfsb(l)+sfsb(l)*deltim
     ccfvsb(l) = ccfvsb(l)+sfvsb(l)*deltim
     DO  iis=1,ns
        ccssb(l,iis) = ccssb(l,iis)+sssb(l,iis)*deltim
     END DO
  END DO
  ! ... Convert step total flow rates to step total amounts
  stfsbc=stfsbc*deltim
  ! ... Add to cumulative totals
  tcfsbc=tcfsbc+stfsbc
  DO  iis=1,ns
     stssbc(iis)=stssbc(iis)*deltim
     tcssbc(iis)=tcssbc(iis)+stssbc(iis)
  END DO
  ! ... Specified flux b.c.
  ! ... Allocate scratch space
  ALLOCATE (qsbc3(nsa), qsbc4(nsa),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: sumcal1_manager, point 2"  
     STOP
  ENDIF
  DO lc=1,nfbc_cells
     m = flux_seg_m(lc)
     qffbc(lc) = 0._kdp
     qsfbc(lc,:) = 0._kdp
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
        IF (m == 0) EXIT          ! ... dry column, skip to next flux b.c. cell
        qn = qfflx(ls)*areafbc(ls)
        IF(qn <= 0.) THEN             ! ... Outflow
           qfbc = den0*qn*ufrac  
           qffbc(lc) = qffbc(lc) + qfbc
           stotfp = stotfp-ufdt1*qfbc
           DO  iis=1,ns
              qsbc3(iis) = qfbc*c(m,iis)
              qsfbc(lc,iis) = qsfbc(lc,iis) + qsbc3(iis)
              stotsp(iis) = stotsp(iis)-ufdt1*qsbc3(iis)
           END DO
        ELSE                      ! ... Inflow
           qfbc = denfbc(ls)*qn*ufrac
           qffbc(lc) = qffbc(lc) + qfbc
           stotfi = stotfi+ufdt1*qfbc
           DO  iis=1,ns
              qsbc3(iis) = qfbc*cfbc(ls,iis)
              qsfbc(lc,iis) = qsfbc(lc,iis) + qsbc3(iis)
              stotsi(iis) = stotsi(iis)+ufdt1*qsbc3(iis)
           END DO
        END IF
        sffb(lc) = sffb(lc) + qfbc
        sfvfb(lc) = sfvfb(lc) + qn
        stffbc = stffbc+ufdt1*qfbc
        DO  iis=1,ns
           qsbc4(iis) = qsflx(ls,iis)*areafbc(ls)*ufrac
           IF(qsbc4(iis) <= 0._kdp) THEN
              stotsp(iis) = stotsp(iis)-ufdt1*qsbc4(iis)
           ELSE
              stotsi(iis) = stotsi(iis)+ufdt1*qsbc4(iis)
           END IF
           ssfb(lc,iis) = ssfb(lc,iis) + qsbc4(iis) + qsbc3(iis)
           stsfbc(iis) = stsfbc(iis)+ufdt1*(qsbc4(iis)+qsbc3(iis))
        END DO
     END DO
  END DO
  ! ... Compute cumulative cell flow amounts
  DO  lc=1,nfbc
     ccffb(lc) = ccffb(lc)+0.5*sffb(lc)*deltim
     ccfvfb(lc) = ccfvfb(lc)+0.5*sfvfb(lc)*deltim
     DO  iis=1,ns
        ccsfb(lc,iis) = ccsfb(lc,iis)+0.5*ssfb(lc,iis)*deltim
     END DO
  END DO
  DEALLOCATE (qsbc3, qsbc4,  &
       stat = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed, sumcal1_manager"
     STOP
  ENDIF
  ! ... Convert step total flow rates to step total amounts
  stffbc = stffbc*deltim
  tcffbc = tcffbc+stffbc
  DO  iis=1,ns
     stsfbc(iis) = stsfbc(iis)*deltim
     tcsfbc(iis) = tcsfbc(iis)+stsfbc(iis)
  END DO
  ! ... Aquifer leakage b.c.
  ! ... Allocate scratch space
  ALLOCATE (cavg(nsa), sum_cqm_in(nsa),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: sumcal1_manager, point 2"  
     STOP
  ENDIF
  DO lc=1,nlbc_cells
     m = leak_seg_m(lc)
     qflbc(lc) = 0._kdp
     qslbc(lc,:) = 0._kdp
     sflb(lc) = 0._kdp
     sfvlb(lc) = 0._kdp
     sslb(lc,:) = 0._kdp
     IF(m == 0) CYCLE
     ! ... Calculate current net aquifer leakage flow rate
     qm_net = 0._kdp
     DO ls=leak_seg_first(lc),leak_seg_last(lc)
        qnp = albc(ls) - blbc(ls)*dp(m)
        IF(qnp <= 0._kdp) THEN           ! ... Outflow
           qm_net = qm_net + den0*qnp
           sfvlb(lc) = sfvlb(lc) + qnp
        ELSE                            ! ... Inflow
           IF(fresur .AND. ifacelbc(ls) == 3) THEN
              ! ... Limit the flow rate for z-face unconfined leakage from above
              qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
                   - 0.5_kdp*den0*bblbc(ls)))
              qnp = MIN(qnp,qlim)
           END IF
           qm_net = qm_net + denlbc(ls)*qnp
           sfvlb(lc) = sfvlb(lc) + qnp
        ENDIF
     END DO
     qflbc(lc) = qm_net
     sflb(lc) = sflb(lc) + qflbc(lc)
     stflbc = stflbc + ufdt1*qflbc(lc)
     IF(qm_net <= 0._kdp) THEN           ! ... net outflow
	stotfp = stotfp - ufdt1*qflbc(lc)
        DO  iis=1,ns
           qslbc(lc,iis) = qflbc(lc)*c(m,iis)
           stotsp(iis) = stotsp(iis) - ufdt1*qslbc(lc,iis)
        END DO
     ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
        stotfi = stotfi + ufdt1*qflbc(lc)
        ! ... calculate flow weighted average concentrations for inflow segments
        qm_in = 0._kdp
        sum_cqm_in = 0._kdp
        DO ls=leak_seg_first(lc),leak_seg_last(lc)
           qnp = albc(ls) - blbc(ls)*dp(m)
           IF(qnp > 0._kdp) THEN                   ! ... inflow
              IF(fresur .AND. ifacelbc(ls) == 3) THEN
                 ! ... limit the flow rate for unconfined z-face leakage from above
                 qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*  &
                      (zelbc(ls)-0.5_kdp*bblbc(ls)) - 0.5_kdp*den0*bblbc(ls)))
                 qnp = MIN(qnp,qlim)
              END IF
              qm_in = qm_in + denlbc(ls)*qnp
              DO  iis=1,ns
                 sum_cqm_in(iis) = sum_cqm_in(iis) + denlbc(ls)*qnp*clbc(ls,iis)
              END DO
           ENDIF
        END DO
        if (qm_in .gt. 0.0_kdp) then
            DO iis=1,ns
                cavg(iis) = sum_cqm_in(iis)/qm_in
                qslbc(lc,iis) = qflbc(lc)*cavg(iis)
                stotsi(iis) = stotsi(iis) + ufdt1*qslbc(lc,iis)
            END DO
        endif
     END IF
     DO  iis=1,ns
        sslb(lc,iis)=sslb(lc,iis) + qslbc(lc,iis)
        stslbc(iis) = stslbc(iis) + ufdt1*qslbc(lc,iis)
     END DO
  END DO
  ! ... Compute cumulative cell flow amounts
  DO lc=1,nlbc
     ccflb(lc) = ccflb(lc) + 0.5*sflb(lc)*deltim
     ccfvlb(lc) = ccfvlb(lc) + 0.5*sfvlb(lc)*deltim
     DO iis=1,ns
        ccslb(lc,iis) = ccslb(lc,iis) + 0.5*sslb(lc,iis)*deltim
     END DO
  END DO
  ! ... Convert step total flow rates to step total amounts
  ! ...     and sum for cumulative amounts
  stflbc = stflbc*deltim
  tcflbc = tcflbc + stflbc
  DO  iis=1,ns
     stslbc(iis) = stslbc(iis)*deltim
     tcslbc(iis) = tcslbc(iis) + stslbc(iis)
  END DO
  ! ... Do not update the indices connecting leakage to aquifer yet!
  DEALLOCATE (cavg, sum_cqm_in, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, sumcal1_manager"  
     STOP
  ENDIF
  ! ... River leakage b.c.
!$$  erflg=.FALSE.
  ! ... Allocate scratch space
  ALLOCATE (cavg(nsa), sum_cqm_in(nsa),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: sumcal1_manager, point 3"  
     STOP
  ENDIF
  DO lc=1,nrbc_cells
     m = river_seg_m(lc)
     qfrbc(lc) = 0._kdp
     qsrbc(lc,:) = 0._kdp
     sfrb(lc) = 0._kdp
     sfvrb(lc) = 0._kdp
     ssrb(lc,:) = 0._kdp
     IF(m == 0) CYCLE              ! ... dry column, skip to next river b.c. cell 
     ! ... Calculate current net aquifer leakage flow rate
     qm_net = 0._kdp
     DO ls=river_seg_first(lc),river_seg_last(lc)
         if (arbc(ls) .gt. 1.0e50_kdp) cycle
         qnp = arbc(ls) - brbc(ls)*dp(m)
         hrbc = phirbc(ls)/gz
         if(hrbc > zerbc(ls)) then      ! ... treat as river
             IF(qnp <= 0._kdp) THEN          ! ... Outflow
                 qm_net = qm_net + den0*qnp
                 sfvrb(lc) = sfvrb(lc) + qnp
             ELSE                            ! ... Inflow
                 ! ... Limit the flow rate for a river leakage
                 qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                 - 0.5_kdp*den0*bbrbc(ls)))
                 qnp = MIN(qnp,qlim)
                 qm_net = qm_net + denrbc(ls)*qnp
                 sfvrb(lc) = sfvrb(lc) + qnp
             ENDIF
         else                           ! ... treat as drain 
             IF(qnp <= 0._kdp) THEN           ! ... Outflow
                 qm_net = qm_net + den0*qnp
                 sfvrb(lc) = sfvrb(lc) + qnp
                 !qfbc = den(m)*qnp
                 !qfrbc(lc) = qfrbc(lc) + qfbc
                 !stotfp = stotfp-ufdt1*qfbc
                 !DO  iis=1,ns
                 !    qsbc3(iis) = qfbc*c(m,iis)
                 !    qsrbc(lc,iis) = qsrbc(lc,iis) + qsbc3(iis)
                 !    stotsp(iis) = stotsp(iis)-ufdt1*qsbc3(iis)
                 !END DO
             ELSE                            ! ... Inflow
                 !qfbc = 0._kdp
                 !qfrbc(lc) = qfrbc(lc) + qfbc
                 !stotfi = stotfi+ufdt1*qfbc
                 !DO  iis=1,ns
                 !    qsbc3(iis) = 0._kdp
                 !    qsrbc(lc,iis) = qsrbc(lc,iis) + qsbc3(iis)
                 !    stotsi(iis) = stotsi(iis) + ufdt1*qsbc3(iis)
                 !END DO
             ENDIF
         end if             
     END DO
     qfrbc(lc) = qm_net
     sfrb(lc) = sfrb(lc) + qfrbc(lc)
     stfrbc = stfrbc + ufdt1*qfrbc(lc)
     IF(qm_net <= 0._kdp) THEN           ! ... net outflow
         stotfp = stotfp - ufdt1*qfrbc(lc)
         DO  iis=1,ns
             qsrbc(lc,iis) = qfrbc(lc)*c(m,iis)
             stotsp(iis) = stotsp(iis) - ufdt1*qsrbc(lc,iis)
         END DO
     ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
         stotfi = stotfi + ufdt1*qfrbc(lc)
         ! ... calculate flow weighted average concentrations for inflow segments
         qm_in = 0._kdp
         sum_cqm_in = 0._kdp
         DO ls=river_seg_first(lc),river_seg_last(lc)
             if (arbc(ls) .gt. 1.0e50_kdp) cycle
             qnp = arbc(ls) - brbc(ls)*dp(m)
             IF(qnp > 0._kdp) THEN                   ! ... inflow
                 ! ... limit the flow rate for a river leakage
                 qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*  &
                 (zerbc(ls)-0.5_kdp*bbrbc(ls)) - 0.5_kdp*den0*bbrbc(ls)))
                 qnp = MIN(qnp,qlim)
                 qm_in = qm_in + denrbc(ls)*qnp
                 DO  iis=1,ns
                     sum_cqm_in(iis) = sum_cqm_in(iis) + denrbc(ls)*qnp*crbc(ls,iis)
                 END DO
             ENDIF
         END DO
         if (qm_in .gt. 0.0_kdp) then
             DO iis=1,ns
                 cavg(iis) = sum_cqm_in(iis)/qm_in
                 qsrbc(lc,iis) = qfrbc(lc)*cavg(iis)
                 stotsi(iis) = stotsi(iis) + ufdt1*qsrbc(lc,iis)
             END DO
         endif
     else                       ! ... no inflow or outflow; treat as drain
         qnp = 0._kdp
         qfbc = 0._kdp
         !stotfi = stotfi + ufdt0*qfbc
         !sfvrb(lc) = sfvrb(lc) + qnp
         !DO  iis=1,ns
         !    qsbc3(iis) = 0._kdp
         !    stotsi(iis) = stotsi(iis) + ufdt0*qsbc3(iis)
         !END DO
     ENDIF
     DO  iis=1,ns
        ssrb(lc,iis)=ssrb(lc,iis) + qsrbc(lc,iis)
        stsrbc(iis) = stsrbc(iis) + ufdt1*qsrbc(lc,iis)
     END DO
  END DO
  ! ... Compute cumulative cell flow amounts
  DO lc=1,nrbc
     ccfrb(lc) = ccfrb(lc) + 0.5*sfrb(lc)*deltim
     ccfvrb(lc) = ccfvrb(lc) + 0.5*sfvrb(lc)*deltim
     DO iis=1,ns
        ccsrb(lc,iis) = ccsrb(lc,iis) + 0.5*ssrb(lc,iis)*deltim
     END DO
  END DO
  ! ... Convert step total flow rates to step total amounts
  ! ...     and sum for cumulative amounts
  stfrbc = stfrbc*deltim
  tcfrbc = tcfrbc + stfrbc
  DO  iis=1,ns
     stsrbc(iis) = stsrbc(iis)*deltim
     tcsrbc(iis) = tcsrbc(iis) + stsrbc(iis)
  END DO
  ! ... Do not update the indices connecting river to aquifer yet!
  DEALLOCATE (cavg, sum_cqm_in, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, sumcal1_manager"  
     STOP
  ENDIF
  ! ... Drain leakage b.c.
  ! ... Allocate scratch space
  ALLOCATE (qsbc3(nsa), qsbc4(nsa),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: sumcal1_manager, point 3.1"  
     STOP
  ENDIF
  DO lc=1,ndbc_cells
     m = drain_seg_m(lc)
     qfdbc(lc) = 0._kdp
     qsdbc(lc,:) = 0._kdp
     sfdb(lc) = 0._kdp
     sfvdb(lc) = 0._kdp
     ssdb(lc,:) = 0._kdp
     IF(m == 0) CYCLE
     DO ls=drain_seg_first(lc),drain_seg_last(lc)
        if (adbc(ls) .gt. 1.0e50_kdp) cycle
        qnp = adbc(ls) - bdbc(ls)*dp(m)
        IF(qnp <= 0._kdp) THEN           ! ... Outflow
           qfbc = den0*qnp
           qfdbc(lc) = qfdbc(lc) + qfbc
           stotfp = stotfp-ufdt1*qfbc
           DO  iis=1,ns
              qsbc3(iis) = qfbc*c(m,iis)
              qsdbc(lc,iis) = qsdbc(lc,iis) + qsbc3(iis)
              stotsp(iis) = stotsp(iis)-ufdt1*qsbc3(iis)
           END DO
        ELSE                            ! ... Inflow
           qfbc = 0._kdp
           !qfdbc(lc) = qfdbc(lc) + qfbc
           !stotfi = stotfi+ufdt1*qfbc
           !DO  iis=1,ns
           !   qsbc3(iis) = 0._kdp
           !   qsdbc(lc,iis) = qsdbc(lc,iis) + qsbc3(iis)
           !   stotsi(iis) = stotsi(iis) + ufdt1*qsbc3(iis)
           !END DO
        ENDIF
     END DO
     sfdb(lc) = sfdb(lc) + qfdbc(lc)
     sfvdb(lc) = sfvdb(lc) + qfdbc(lc)/den0
     stfdbc = stfdbc + ufdt1*qfdbc(lc)
     DO  iis=1,ns
        ssdb(lc,iis) = ssdb(lc,iis) + qsdbc(lc,iis)
        stsdbc(iis) = stsdbc(iis) + ufdt1*qsdbc(lc,iis)
     END DO
  END DO
  ! ... Compute cumulative cell flow amounts
  DO lc=1,ndbc
     ccfdb(lc) = ccfdb(lc) + 0.5*sfdb(lc)*deltim
     ccfvdb(lc) = ccfvdb(lc) + 0.5*sfvdb(lc)*deltim
     DO iis=1,ns
        ccsdb(lc,iis) = ccsdb(lc,iis) + 0.5*ssdb(lc,iis)*deltim
     END DO
  END DO
  DEALLOCATE (qsbc3, qsbc4,  &
       stat = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed, sumcal1_manager"
     STOP
  ENDIF
  ! ... Convert step total flow rates to step total amounts
  ! ...     and sum for cumulative amounts
  stfdbc = stfdbc*deltim
  tcfdbc = tcfdbc+stfdbc
  DO  iis=1,ns
     stsdbc(iis) = stsdbc(iis)*deltim
     tcsdbc(iis) = tcsdbc(iis)+stsdbc(iis)
  END DO
  ! ... Do not update the indices connecting drain to aquifer yet!
!!$  ! ... Calculate aquifer influence function boundary flow rates
!!$  !... *** not implemented for PHAST
!!$  ! ... Heat conduction b.c.
!!$  !... *** not implemented for PHAST
  ! ... Calculate total fluid mass, fluid volume, solute in region
  ! ...      of active cells before chemical reaction step
  ! ... Calculate mass of each aqueous solute component in region
  ! ...      of active cells before chemical reaction step
  fir = 0._kdp
  firv = 0._kdp
  ehir = 0._kdp
  sir_prechem = 0._kdp
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     IF(frac(m) <= 0._kdp) CYCLE
     u0=pv(m)*frac(m)
     u1=0._kdp
     fir = fir+u0*den0
     firv = firv+u0
     DO  iis=1,ns
        sir_prechem(iis) = sir_prechem(iis) + den0*(u0+u1)*c(m,iis)
     END DO
!!$     IF(ABS(prip) > 0. .OR. ABS(prihdf_head) > 0. .OR. ABS(primaphead) > 0.) THEN
!!$        ! ... Calculate head field
!!$        imod = MOD(m,nxy)
!!$        k = (m-imod)/nxy + MIN(1,imod)
!!$        hdprnt(m) = z(k)+p(m)/(den0*gz)
!!$     END IF
  END DO
!!$  IF(fresur .AND. (ABS(prip) > 0. .OR. ABS(primaphead) > 0.)) THEN
!!$     ! ... Calculate water-table elevation
!!$     DO mt=1,nxy
!!$        m = mfsbc(mt)
!!$        IF (m > 0) THEN
!!$           wt_elev(mt) = z_node(m) + p(m)/(den0*gz)
!!$        END IF
!!$     END DO
!!$  END IF
  ! ... Calculate the internal zone flow rates if requested
  IF(ABS(pri_zf) > 0. .OR. ABS(pri_zf_tsv) > 0.) CALL zone_flow

END SUBROUTINE sumcal1_manager
