SUBROUTINE rhsn_flow
  ! ... Calculates right hand side terms at time level N,
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
  REAL(KIND=kdp) :: qfbc, qlim, qm_in, qm_net, qn, szzw, ucwt, ufdt0, ufrac, wt
  REAL(KIND=kdp) :: hrbc
  INTEGER :: a_err, da_err, i, iis, iwel, iwfss, j, k, ks, l, lc0, l1,  &
       lc, ls, m, mc0, mfs, mkt, nks, nsa
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: cavg, sum_cqm_in
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: rhsn_flow.f90,v 1.1 2013/09/19 23:15:13 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  ufdt0 = 1._kdp-fdtmth
  ntsfal=0         ! ... Set number of failed time steps to zero

  ! ... Zero r.h.s. arrays in preparation for next time level calculation
  rf = 0._kdp
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
  IF(nwel > 0) THEN  
     ! ... Load rhs with well explicit flow rates at each layer
     DO  iwel=1,nwel
        IF(wqmeth(iwel) == 0) CYCLE
        IF(.NOT.cylind .OR. wqmeth(iwel) == 11 .OR. wqmeth(iwel) == 13) THEN
           DO  k=1,nkswel(iwel)
              m=mwel(iwel,k)
              rf(m)=rf(m)+ufdt0*qflyr_n(iwel,k)
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
                rf(mkt)=rf(mkt)-ufdt0*qwm_n(iwel)
        END IF
     END DO
  END IF
  ! ... Specified P b.c. terms are applied in ASEMBL
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
           ELSE                     ! ... Inflow
              qfbc = denfbc(ls)*qn*ufrac
           END IF
           rf(m) = rf(m) + ufdt0*qfbc
        END DO
     END DO
  END IF
  IF(nlbc > 0) THEN
     ! ... Calculate leakage b.c. terms
     ! ... Allocate scratch space
     ALLOCATE (cavg(nsa), sum_cqm_in(nsa),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: rhsn_flow, point 2"  
        STOP
     ENDIF
     IF(fresur) THEN
        DO lc=1,nlbc
           ! ... Update the indices locating the cells communicating with leaky layer
           mc0 = leak_seg_m(lc)
           lc0 = MOD(mc0,nxy)
           IF(lc0 == 0) lc0 = nxy
           mfs = mfsbc(lc0)    ! ... currrent f.s. cell in column lc0
           DO ls=leak_seg_first(lc),leak_seg_last(lc)
              IF(ifacelbc(ls) == 3) THEN
                 leak_seg_m(lc) = mfs            ! ... communicate with f.s. cell always
                 mlbc(ls) = leak_seg_m(lc)      ! ... currrent leakage segment cell for aquifer head
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
           ELSE                          ! ... Inflow
              IF(fresur .AND. ifacelbc(ls) == 3) THEN
                 ! ... Limit the flow rate for unconfined z-face leakage from above
                 qlim = blbc(ls)*(denlbc(ls)*philbc_n(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
                      - 0.5_kdp*den0*bblbc(ls)))
                 qn = MIN(qn,qlim)
              END IF
              qm_net = qm_net + denlbc(ls)*qn
           END IF
        END DO
        rf(m) = rf(m) + ufdt0*qm_net
        qflbc(lc) = qm_net
        IF(qm_net <= 0._kdp) THEN           ! ... net outflow
        ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
           ! ... calculate flow weighted average concentrations for inflow segments
           qm_in = 0._kdp
           sum_cqm_in = 0._kdp
           DO ls=leak_seg_first(lc),leak_seg_last(lc)
              qn = albc(ls)
              IF(qn > 0._kdp) THEN                   ! ... inflow
                 IF(fresur .AND. ifacelbc(ls) == 3) THEN
                    ! ... limit the flow rate for unconfined z-face leakage from above
                    qlim = blbc(ls)*(denlbc(ls)*philbc_n(ls) - gz*(denlbc(ls)*  &
                         (zelbc(ls)-0.5_kdp*bblbc(ls)) - 0.5_kdp*den0*bblbc(ls)))
                    qn = MIN(qn,qlim)
                 END IF
              ENDIF
           END DO
        ENDIF
     END DO
     DEALLOCATE (cavg, sum_cqm_in, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed, rhsn"  
        STOP
     ENDIF
  END IF

  IF(nrbc > 0) THEN
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
          mc0 = river_seg_m(lc)
          lc0 = MOD(mc0,nxy)
          IF(lc0 == 0) lc0 = nxy
          mfs = mfsbc(lc0)    ! ... currrent f.s. cell
          river_seg_m(lc) = mfs            ! ... communicate with f.s. cell always
          DO ls=river_seg_first(lc),river_seg_last(lc)
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
              if (arbc(ls) .gt. 1.0e50_kdp) cycle
              qn = arbc(ls)
              hrbc = phirbc(ls)/gz
              if(hrbc > zerbc(ls)) then      ! ... treat as river
                  IF(qn <= 0._kdp) THEN           ! ... Outflow
                      qm_net = qm_net + den0*qn
                  ELSE                            ! ... Inflow
                      ! ... Limit the flow rate for a river leakage
                      qlim = brbc(ls)*(denrbc(ls)*phirbc_n(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                        - 0.5_kdp*den0*bbrbc(ls)))
                      qn = MIN(qn,qlim)
                      qm_net = qm_net + denrbc(ls)*qn
                  END IF
              else                           ! ... treat as drain 
                  IF(qn <= 0._kdp) THEN      ! ... Outflow
                      qm_net = qm_net + den0*qn
                  ELSE                        ! ... Inflow, none allowed
                  END IF
              end if
          END DO
          rf(m) = rf(m) + ufdt0*qm_net
          qfrbc(lc) = qm_net
          IF(qm_net <= 0._kdp) THEN           ! ... net outflow
          ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow; river
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
                  ENDIF
              END DO
          else                       ! ... no inflow or outflow; treat as drain
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
              if (adbc(ls) .gt. 1.0e50_kdp) cycle
              qn = adbc(ls)
              IF(qn <= 0.) THEN      ! ... Outflow
                  qfbc = den0*qn
              ELSE                        ! ... Inflow, none allowed
                  qn = 0._kdp
                  qfbc = 0._kdp
              END IF
              rf(m) = rf(m) + ufdt0*qfbc
          END DO
      END DO
  END IF

!!$  ! ... Calculate aquifer influence function b.c. terms
!!$  ! ...      Calculate step total flow rates and nodal step flow rates
!!$  !... *** not implemented in PHAST
END SUBROUTINE rhsn_flow
