SUBROUTINE error3
  ! ... Error checks transient data after INIT3
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcg, ONLY: nxy
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE print_control_mod
  IMPLICIT NONE
  INTRINSIC INDEX
  CHARACTER(LEN=9) :: cibc
  CHARACTER(LEN=130) :: logline1
  INTEGER :: i, ic, iis, iwel, l, l2, ls, m, m1, mt, warnflag
  REAL(KIND=kdp) :: udeltim
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: error3.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Specified pressure and unconfined b.c.
  ! ...      Check for free surface in interior cell isolating the
  ! ...      specified pressure cell from below  
  DO l=1,nsbc
     m = msbc(l)
!!$      IF(frac(m) > 0._kdp) CYCLE
     IF(frac(m) <= 0._kdp) CYCLE
     IF((m-nxy) > 0) THEN
        WRITE(cibc,6001) ibc(m-nxy)
6001    FORMAT(i9.9)
        IF(cibc(1:1) == '1') CYCLE
        IF(frac(m-nxy) < 1._kdp) ierr(147) = .TRUE.
     ENDIF
  END DO
  IF(fresur) THEN
     ! ... Check for multiple free surfaces in unconfined region
     ! ... This would be from boundary conditions
     chk_fs: DO mt=1,nxy
        m1 = mfsbc(mt)
        DO m=m1-nxy,1,-nxy
           IF(frac(m) < 1._kdp) THEN
              !!              ierr(148) = .true.       !   warning not fatal error
              WRITE(logline1,'(a)') 'Multiple free surfaces in column of cells;'//  &
                   ' Check boundary condition on head field.'
                CALL warnprt_c(logline1)
              EXIT chk_fs
           END IF
        END DO
     END DO chk_fs
  END IF
  ! ... Flux b.c.
  IF(rdflxq .OR. rdflxh .OR. rdflxs) THEN
     DO  l2=1,nfbc
        m=mfbc(l2)
        WRITE(cibc,6001) ibc(m)
        ic = INDEX(cibc(1:3),'1')
        IF(ABS(qfbcv(l2)) > 0. .AND. ic > 0) ierr(70)=.TRUE.
        IF(mfbc(l2) == 0) ierr(77)=.TRUE.
        ic = INDEX(cibc(4:6),'1')
!$$        IF(heat .AND. ABS(qhfbc(l2)) > 0. .AND. ic > 0) ierr(71)=.TRUE.
        ic=INDEX(cibc(7:9),'1')
        DO  iis=1,ns
           IF(solute .AND. ABS(qsfbc(l2,iis)) > 0. .AND. ic > 0) ierr(72)=.TRUE.
        END DO
     END DO
  END IF
  ! ... Leakage b.c.
  IF(rdlbc .AND. fresur) THEN
     DO  ls=1,nlbc_seg
        IF(ifacelbc(ls) == 3) THEN
           IF(philbc(ls) < gz*zelbc(ls)) ierr(73)=.TRUE.
        END IF
     END DO
  END IF
  ! ... River leakage b.c.
  !IF(rdrbc) THEN
  !   DO  ls=1,nrbc_seg
  !      IF(phirbc(ls) < gz*zerbc(ls)) ierr(74)=.TRUE.
  !   END DO
  !END IF
  ! ... Drain b.c.: nothing to be done
  ! ... Check well data
  DO  iwel=1,nwel
     IF(iwel > 1.AND.cylind.AND.wqmeth(iwel) /= 0) ierr(78)=.TRUE.
     IF(pwsurs(iwel) /= 0._kdp.AND.wqmeth(iwel) < 40) ierr(75)=.TRUE.
     IF((wqmeth(iwel) == 20.OR.wqmeth(iwel) == 40).AND.  &
          ABS(qwv(iwel)) > 0.) ierr(76)=.TRUE.
     IF(wqmeth(iwel) == 20.AND.pwkt(iwel) == 0._kdp) ierr(81)=.TRUE.
  END DO
  ! ... Calculation parameters
  ! IF(timchg <= time) ierr(83)=.TRUE.
  ! keep going until start_time   
  IF(timchg <= time .and. time > timrst*cnvtm) ierr(83)=.TRUE.   

  IF(dtimmx < dtimmn) ierr(84)=.TRUE.
  ! ... Print control parameters
  udeltim = cnvtmi*deltim_transient
  warnflag = 0
  IF(pribcf > 0._kdp .AND. pribcf < udeltim) warnflag = warnflag + 1
  IF(pricpd > 0._kdp .AND. pricpd < udeltim) warnflag = warnflag + 1
  IF(prigfb > 0._kdp .AND. prigfb < udeltim) warnflag = warnflag + 1
  IF(prikd > 0._kdp .AND. prikd < udeltim) warnflag = warnflag + 1
  IF(primaphead > 0._kdp .AND. primaphead < udeltim) warnflag = warnflag + 1
  IF(primapcomp > 0._kdp .AND. primapcomp < udeltim) warnflag = warnflag + 1
  IF(primapv > 0._kdp .AND. primapv < udeltim) warnflag = warnflag + 1
  IF(pri_zf_xyzt > 0._kdp .AND. pri_zf_xyzt < udeltim) warnflag = warnflag + 1
  IF(prip > 0._kdp .AND. prip < udeltim) warnflag = warnflag + 1
  IF(pric > 0._kdp .AND. pric < udeltim) warnflag = warnflag + 1
  IF(pricphrq > 0._kdp .AND. pricphrq < udeltim) warnflag = warnflag + 1
  IF(priforce_chem_phrq > 0._kdp .AND. priforce_chem_phrq < udeltim) warnflag = warnflag + 1
  IF(prislm > 0._kdp .AND. prislm < udeltim) warnflag = warnflag + 1
  IF(print_restart%print_interval > 0._kdp .AND. print_restart%print_interval < udeltim) warnflag = warnflag + 1
  IF(privel > 0._kdp .AND. privel < udeltim) warnflag = warnflag + 1
  IF(priwel > 0._kdp .AND. priwel < udeltim) warnflag = warnflag + 1
  IF(pri_well_timser > 0._kdp .AND. pri_well_timser < udeltim) warnflag = warnflag + 1
  IF(pri_zf > 0._kdp .AND. pri_zf < udeltim) warnflag = warnflag + 1
  IF(pri_zf_tsv > 0._kdp .AND. pri_zf_tsv < udeltim) warnflag = warnflag + 1
  IF(prihdf_head > 0._kdp .AND. prihdf_head < udeltim) warnflag = warnflag + 1
  IF(prihdf_vel > 0._kdp .AND. prihdf_vel < udeltim) warnflag = warnflag + 1
  IF(prihdf_conc > 0._kdp .AND. prihdf_conc < udeltim) warnflag = warnflag + 1
  IF(prihdf_intermediate > 0._kdp .AND. prihdf_intermediate < udeltim) warnflag = warnflag + 1
  IF(warnflag > 0) THEN
     WRITE(logline1,'(i2,a)') warnflag,' print control intervals are less than '//  &
          'defined time step length.'
            CALL warnprt_c(logline1)
  END IF
  DO  i=70,170
     IF(ierr(i)) errexi=.TRUE.
  END DO
  IF(errexi) CALL errprt(70,170)
END SUBROUTINE error3
