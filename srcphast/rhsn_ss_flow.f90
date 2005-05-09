SUBROUTINE rhsn_ss_flow
  ! ... Calculates right hand side terms at time level N,
  ! ...      and starts the step cumulative totals for the first portion
  ! ...      of the time step
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcv
  USE mcw
  USE mg2, ONLY: qfbcv
  IMPLICIT NONE
  INTRINSIC INT
  REAL(KIND=kdp) :: qfbc, qn, szzw,  &
       ufdt0, ufrac, wt
  INTEGER :: a_err, da_err, i, iwel, iwfss, j, k, ks, l, lc0, l1, lc, ls,  &
       m, mc0, mfs, mkt, nks, nsa
!!$  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE  :: qsbc3, qsbc4
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ufdt0 = 1._kdp-fdtmth
  ntsfal=0     ! ... Set number of failed time steps to zero
  ! ... Initialize the step b.c. flow accumulators
  !...  ***This could be put into an init4 routine***
  stotfi = 0._kdp
  stotfp = 0._kdp
!..  stfaif = 0._kdp
  stffbc = 0._kdp
  stflbc = 0._kdp
  stfrbc = 0._kdp
  stfsbc = 0._kdp
  stfwel = 0._kdp
  IF (nwel > 0) stfwi = 0._kdp
  IF (nwel > 0) stfwp = 0._kdp
  nsa = MAX(ns,1)
  ! ... Allocate scratch space
  ! ... Load current total fluid mass amount into storage
  ! ...      for nth time level
  firn=fir
  ! ... Zero r.h.s. arrays in preparation for next time level calculation
  rf = 0._kdp
  IF(solute) rs = 0._kdp
  ! ... Calculate right hand side dispersive flux terms and
  ! ...      convective flux terms (not cross-dispersive flux terms)
  ! ... Inactive cells are excluded by zero flow rate and transmissivity
  ! ... Dry cells are isolated by zero flow rate
  DO  k=1,nz
     DO  j=1,ny
        DO  i=1,nx
           m=cellno(i,j,k)
           IF(i == nx) GO TO 20
           IF(frac(m+1) <= 0.) GO TO 20
           ! ... X-direction
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
           IF(k == nz) GO TO 40
           ! ... Z-direction
           mijkp=cellno(i,j,k+1)
           wt=fdsmth
           IF(szz(m) < 0.) wt=1._kdp-wt
           rf(mijkp)=rf(mijkp)+szz(m)
           rf(m)=rf(m)-szz(m)
40         CONTINUE
        END DO
     END DO
  END DO
  DO  iwel=1,nwel
     IF(wqmeth(iwel) == 0) CYCLE
     ! ... Load rhs with well explicit flow rates at each
     ! ...      layer
     IF(.NOT.cylind.OR.wqmeth(iwel) == 11.OR.wqmeth(iwel) == 13) THEN
        DO  k=1,nkswel(iwel)
           m=mwel(iwel,k)
           rf(m)=rf(m)+ufdt0*qflyr(iwel,k)
        END DO
     ELSE IF(cylind) THEN
        DO  ks=1,nkswel(iwel)-1
           m=mwel(iwel,ks)
           CALL mtoijk(m,i,j,k,nx,ny)
           mijkp=m+nxy
           szzw=-tfw(k)*(p(mijkp)-p(m)+denwk(iwel,ks)*gz* (z(k+1)-z(k)))
           rf(mijkp)=rf(mijkp)+szzw
           rf(m)=rf(m)-szzw
        END DO
        nks=nkswel(iwel)
        mkt=mwel(iwel,nks)
        IF(wqmeth(iwel) <= 20.OR.wqmeth(iwel) == 40)  &
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
  DO  l=1,nfbc
     m=mfbc(l)
     ufrac=1._kdp
     IF(l < lnz2) ufrac=frac(m)
     ! ... Redirect the flux to the free-surface cell, if it is precipitation
     ! ...      flux at uppermost z-plane.
     IF(l >= lnz2) THEN
        l1=MOD(m,nxy)
        IF(l1 == 0) l1=nxy
        m=mfsbc(l1)
     ENDIF
     ! ... Calculate step total flow rate contributions and
     ! ...      cell step flow rate contributions.
     qn=qfbcv(l)
     sfvfb(l)=qn
     IF(qn <= 0.) THEN        ! ... Outflow
        qfbc=den(m)*qn*ufrac
        stotfp = stotfp-ufdt0*qfbc
     ELSE                     ! ... Inflow
        qfbc=denfbc(l)*qn*ufrac
        stotfi = stotfi+ufdt0*qfbc
     END IF
     rf(m)=rf(m)+ufdt0*qfbc
     sffb(l)=qfbc
     stffbc = stffbc+ufdt0*qfbc
  END DO
  ! ... Calculate leakage b.c. terms
  ! ...      Calculate step total flow rates and cell step flow rates.
  DO  l=1,nlbc
     m=mlbc(l)
     IF(frac(m) > 0._kdp) THEN
        IF(qflbc(l) <= 0.) THEN           ! ... Outflow
           stotfp = stotfp-ufdt0*qflbc(l)
!!$           stothp=stothp-0.5*qhlbc(l)
           sfvlb(l)=qflbc(l)/den(m)
!!$           DO  iis=1,ns
!!$              stotsp(iis)=stotsp(iis)-ufdt0*qslbc(l,iis)
!!$           END DO
        ELSE                              ! ... Inflow
           stotfi = stotfi+ufdt0*qflbc(l)
           sfvlb(l)=qflbc(l)/denlbc(l)
        END IF
        rf(m)=rf(m)+ufdt0*qflbc(l)
        sflb(l)=qflbc(l)
        stflbc = stflbc+ufdt0*qflbc(l)
     ENDIF
  END DO
  ! ... Calculate river leakage b.c. terms
  DO lc=1,nrbc
     ! ... Update the indices locating the cells communicating with the river
     mc0 = river_seg_index(lc)%m
     lc0 = MOD(mc0,nxy)
     IF(lc0 == 0) lc0 = nxy
     mfs = mfsbc(lc0)    ! ... currrent f.s. cell
!     river_seg_index(lc)%m = MIN(mfs,mrbc_bot(lc))
     river_seg_index(lc)%m = mfs            ! ... communicate with f.s. cell always
     DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
!        mrbc(ls) = MIN(mfs,mrseg_bot(ls))    ! ... currrent river segment cell for aquifer head
        mrbc(ls) = river_seg_index(lc)%m     ! ... currrent river segment cell for aquifer head
                                             ! ... now the same as communication cell
     END DO
  END DO
  ! ...      Calculate step total flow rates and nodal step flow rates.
  DO  lc=1,nrbc                    ! ... by river cell communicating to aquifer
     m = river_seg_index(lc)%m     ! ... current communicating cell 
     IF(m == 0) CYCLE              ! ... empty column 
     IF(qfrbc(lc) <= 0.) THEN    ! ... Outflow
        stotfp = stotfp-ufdt0*qfrbc(lc)
!!$        STOTHP=STOTHP-ufdt0*QHRBC(LC)
        sfvrb(lc)=qfrbc(lc)/den(m)
     ELSE                        ! ... Inflow
        stotfi = stotfi+ufdt0*qfrbc(lc)
!!$        STOTHI=STOTHI+ufdt0*QHRBC(LC)
        sfvrb(lc)=qfrbc(lc)/denrbc(lc)
     END IF
     rf(m)=rf(m)+ufdt0*qfrbc(lc)
     sfrb(lc)=qfrbc(lc)
     stfrbc = stfrbc+ufdt0*qfrbc(lc)
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
!!$        sfvaif(l)=qfaif(l)/den(m)
!!$     ELSE
!!$        ! ... Inflow
!!$        stotfi=stotfi+0.5*qfaif(l)
!!$        stothi=stothi+0.5*qhaif(l)
!!$        sfvaif(l)=qfaif(l)/denoar(l)
!!$     END IF
!!$     rf(m)=rf(m)+ufdt0*qfaif(l)
!!$     sfaif(l)=qfaif(l)
!!$     stfaif=stfaif+0.5*qfaif(l)
!!$  END DO
END SUBROUTINE rhsn_ss_flow
