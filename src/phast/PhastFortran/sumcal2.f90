SUBROUTINE sumcal2
  ! ... Performs summary calculations at end of time step
  ! ... This is block2 for after chemical reaction step
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m, ONLY: hdprnt, wt_elev
  USE PhreeqcRM
  IMPLICIT NONE
  INTEGER :: status
  !
  !$$  CHARACTER(LEN=50) :: aform = '(TR5,A45,T47,1PE12.4,TR1,A7,T66,A,3(1PG10.3,A),2A)'
  !$$  CHARACTER(LEN=46) :: aformt = '(TR5,A43,1PE12.4,TR1,A7,TR1,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=9) :: cibc
  CHARACTER(LEN=130) :: logline1
  REAL(KIND=kdp) :: denmfs, p1, pmfs,  &
       qlim, qm_in, qm_net, qn, qnp,  &
       u0, u1, ufdt0, ufdt1,  &
       ufrac, up0, z0, z1, z2, zfsl, zm1, zmfs, zp1
  INTEGER :: da_err, i, icol, imod, iwel, j, jcol, k, kcol, kfs, l, lc, l1, ls,  &
       m, m0, m1, m1kp, mfs, mt
  LOGICAL :: ierrw
  REAL(KIND=kdp), PARAMETER :: epssat = 1.e-6_kdp  
  !     ------------------------------------------------------------------
  !...
  ufdt0 = 1._kdp - fdtmth
  ufdt1 = fdtmth
  ! ... Calculate total solute in region
  ! ...     after reaction step
  sir = 0._kdp
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     IF(frac(m) <= 0._kdp) CYCLE
     !IF(frac_np1(m) <= 0._kdp) CYCLE
     u0=pv(m)*frac(m)
     !u0=pv(m)*frac_np1(m)
     u1=0._kdp
     DO  is=1,ns
        sir(is) = sir(is)+den0*(u0+u1)*c(m,is)
     END DO
  END DO
  ! ... Change in fluid and solute over time step and by reaction
  dfir = fir-firn
  DO  is=1,ns
     dsir(is) = sir(is)-sirn(is)
     dsir_chem(is) = sir(is)-sir_prechem(is)
  END DO
  ! ... Cumulative totals
  ! ... Convert step total flow rates to step total amounts
  stotfi=stotfi*deltim
  stothi=stothi*deltim
  stotfp=stotfp*deltim
  stothp=stothp*deltim
  totfi=totfi+stotfi
  totfp=totfp+stotfp
  DO  is=1,ns
     stotsi(is) = stotsi(is)*deltim
     stotsp(is) = stotsp(is)*deltim
     totsi(is) = totsi(is) + stotsi(is)
     totsp(is) = totsp(is) + stotsp(is)
     tdsir_chem(is) = tdsir_chem(is) + dsir_chem(is)
  END DO
  ! ... Fluid mass and solute balance calculations
  sfres = dfir-stotfi+stotfp
  tfres = fir-fir0-totfi+totfp
  u1 = MAX(ABS(dfir),stotfi,stotfp)
  sfresf = 1.e99_kdp
  IF(u1 > 0.) sfresf=sfres/u1
  u1=MAX(ABS(fir-fir0),totfi,totfp)
  tfresf = 1.e99_kdp
  IF(u1 > 0.) tfresf=tfres/u1
  DO  is=1,ns
     ssres(is) = dsir(is) - stotsi(is) + stotsp(is) - dsir_chem(is)
     tsres(is) = sir(is) - sir0(is) - totsi(is) + totsp(is) - tdsir_chem(is)
     u1=MAX(ABS(dsir(is)),stotsi(is),stotsp(is),dsir_chem(is))
     ssresf(is) = 1.e99_kdp
     IF(u1 > 0.) ssresf(is)=ssres(is)/u1
     u1 = MAX(ABS(sir(is)-sir0(is)),totsi(is),totsp(is),ABS(tdsir_chem(is)))
     tsresf(is) = 1.e99_kdp
     IF(u1 > 0.) tsresf(is)=tsres(is)/u1
  END DO
 
  DEALLOCATE (zfsn, &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, sumcal2, number 1d"  
     STOP
  ENDIF
END SUBROUTINE sumcal2
