SUBROUTINE write5_ss_flow
  ! ... Prints out the dependent variables, iteration summaries, well
  ! ...      tables and maps after SUMCAL at end of time step
  USE machine_constants, ONLY: kdp, one_plus_eps
  USE f_units
  USE mcb
  USE mcb_m
  USE mcb2_m
  USE mcc
  USE mcc_m
  USE mcch
  USE mcch_m
  USE mcg
  USE mcg_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mct_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m, ONLY: hdprnt, wt_elev
  USE print_control_mod
  USE PhreeqcRM
  IMPLICIT NONE
  INCLUDE 'ifwr.inc'
  INTRINSIC INDEX, INT
  CHARACTER(LEN=46) :: aformt = '(TR5,A43,1PE12.4,TR1,A7,TR1,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=50) :: aform =  '(TR5,A45,T47,1PE12.4,TR1,A7,T68,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=12), DIMENSION(10) :: chaprt
  CHARACTER(LEN=12) :: chu1a, chu2a, chu2, chu3, chu3a, chu4a, chu5a, chu6a, chu7a, chu8a
  CHARACTER(LEN=2) :: chk1
  CHARACTER(LEN=8) :: chu4, chu5, chu6
  CHARACTER(LEN=9) :: cibc
  CHARACTER(LEN=1), DIMENSION(3) :: lbldir = (/'X','Y','Z'/)
  CHARACTER(LEN=12), DIMENSION(:), ALLOCATABLE :: chu10a, chu11a
  REAL(KIND=kdp) :: hwcell, pwcell, tdehir, tdfir, tdsir, utime
  INTEGER :: a_err, da_err, i, ic, ifmt, indx, ip, iw1p, iw2p, iwel, iwfss, iwpp, izn,  &
       j, jprptc,  &
       k, k1, ks, l, l1, lc, ll, lll, ls, lwk, lwks, m, mfs, mkt, mm, mt, mwk, nsa
  LOGICAL :: erflg, prthd, prthd2, prthd3
  REAL(KIND=kdp), PARAMETER :: cnv=1._kdp
  CHARACTER(LEN=130) :: logline1, logline2
  INTEGER :: status
  !     ------------------------------------------------------------------
  ALLOCATE (lprnt3(nxyz), lprnt4(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: write5_ss_flow 1"  
     STOP  
  ENDIF
  erflg=.FALSE.
  ! ... Print out the summary tables
  ! ... Set table print flags as requested
  prc=.FALSE.
  prp=.FALSE.
  prgfb=.FALSE.
  przf = .FALSE.
  przf_xyzt = .FALSE.
  przf_tsv = .FALSE.
  prbcf=.FALSE.
  prwel=.FALSE.
  prslm=.FALSE.
!!$  prtem=.FALSE.
  prmaph=.FALSE.
  IF(errexe) THEN
     prp=.TRUE.
     prgfb=.TRUE.
     prbcf=.TRUE.
     IF(nwel > 0) prwel=.TRUE.
     prslm=.TRUE.
  ELSE
     utime=cnvtmi*time*one_plus_eps
     ! ... Solution method data
     IF(ABS(prislm) > 0._kdp) THEN
        CALL print_control(prislm,utime,itime,timchg,timprslm,prslm)
     END IF
     ! ... Tables of head in the cells
     IF(ABS(prip) > 0._kdp) THEN
        prp=.TRUE.
        IF(converge_ss) timprp = timchg
     END IF
     ! ... Global flow balance tables
     IF(ABS(prigfb) > 0._kdp) THEN
        prgfb = .TRUE.
     END IF
     ! ... Zone flow rates
     IF(ABS(pri_zf) > 0._kdp) THEN
        IF(converge_ss) przf=.TRUE.
     END IF
     IF(ABS(pri_zf_xyzt) > 0._kdp) THEN
        IF(converge_ss) przf_xyzt=.TRUE.
     END IF 
     IF(ABS(pri_zf_tsv) > 0._kdp) THEN
        IF(converge_ss) przf_tsv=.TRUE.
     END IF     
     ! ... B.C. flow rates
     IF(ABS(pribcf) > 0._kdp) THEN
        IF(converge_ss) prbcf=.TRUE.
     END IF
     ! ... Well summary
     IF(ABS(priwel) > 0._kdp .AND. nwel > 0) THEN
        IF(converge_ss) prwel=.TRUE.
     END IF
     IF(prtic_maphead .OR. ABS(primaphead) > 0._kdp) THEN
        IF(converge_ss) THEN
           prmaph=.TRUE.
           timprmaph = timchg
        END IF
     END IF
  END IF
  !!  WRITE(*,3001) 'Iteration Step No. ', itime,'; for Steady State Flow'
!!$  3001 FORMAT(tr5,a,I6,a)
  IF(prslm) THEN
     !       Already printed in sumcal_ss_flow
!!$     WRITE(logline1,5001) '*** Output at End of Steady State Iteration No. ', itime,' ***'
!!$5001 FORMAT(a,i5,a)
!!$     WRITE(logline2,5002) 'Time '//dots,cnvtmi*time,'  ('//TRIM(unittm)//')'
!!$5002 FORMAT(a60,1PG12.3,a)
!!$     status = RM_LogMessage(rm_id, logline1)
!!$     status = RM_LogMessage(rm_id, logline2)
     IF(ntsfal > 0) THEN 
        WRITE(logline1,5007) 'Number of repeats of time step to achieve ','truncation error'//dots,ntsfal
5007    FORMAT(a42,a23,i4)
        status = RM_LogMessage(rm_id, logline1)
     ENDIF
     !       Already printed in sumcal_ss_flow
!!$     WRITE(logline1,5027) 'Maximum change in potentiometric head '//dots,  &
!!$          cnvpi*dhmax,' ('//TRIM(unitl)//')',' at location (',  &
!!$          cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(',TRIM(unitl)//')'
!!$5027 format(A43,1PE12.4,A10,A,3(1PG10.3,A),A)
!!$     status = RM_LogMessage(rm_id, logline1)
!!$     WRITE(*,aformt) 'Maximum change in potentiometric head '//dots,  &
!!$          cnvpi*dhmax,'('//unitl//')','at location (',  &
!!$          cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(',TRIM(unitl),')'
  END IF
  IF(prp .OR. prc) THEN
     DO  m=1,nxyz
        IF(ibc(m) == -1 .OR. frac(m) <= 0.0001_kdp) THEN
           lprnt1(m)=-1
        ELSE
           lprnt1(m)=1
        END IF
     END DO
     ! ... Grid cell values pressure, head
     IF(prp) THEN
        WRITE(fup,2001)  '*** Output at End of Steady State Iteration No. ', itime,' ***'
        WRITE(fup,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
        WRITE(fup,aform) 'Maximum change in potentiometric head '//dots,  &
             cnvpi*dhmax,'('//unitl//')','at location (',  &
             cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(',TRIM(unitl),')'
        ! WRITE(fup,2008) 'Pressure   (',unitp,')'
2008    FORMAT(/tr30,10A)
        ! CALL printar(2,p,lprnt1,fup,cnvpi,24,000)
        ifmt=13
        IF(eeunit) ifmt=12
        WRITE(fup,2009) 'Fluid Potentiometric Head ('//TRIM(unitl)//')'
2009    FORMAT(/tr30,3A/tr35,a,1PG10.2,tr2,5A)
        CALL printar(2,hdprnt,lprnt1,fup,cnvli,ifmt,000)
        IF(fresur) THEN
           lprnt2 = -1
           lprnt3 = -1
           DO  mt=1,nxy
              mfs = mfsbc(mt)
              IF(mfs /= 0) THEN
                 lprnt2(mfs) = 1
                 lprnt3(mt) = 1
                 aprnt1(mt) = wt_elev(mt)
              END IF
           END DO
           WRITE(fup,2008) 'Fraction of cell that is saturated  (-)'
           CALL printar(2,frac,lprnt2,fup,cnv,14,000)
           WRITE(fuwt,2001)  '*** Output at End of Steady State Iteration No. ', itime,' ***'
           WRITE(fuwt,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
           WRITE(fuwt,2008) 'Water-Table Elevation  ('//TRIM(unitl)//')'
           CALL printar(2,aprnt1,lprnt3,fuwt,cnvli,ifmt,000)
        END IF
        ntprp = ntprp+1
     ENDIF
  END IF
  IF(prmaph) THEN
     ! ... Write head to file 'Fupmp2' for visualization
     DO m=1,nxyz
        IF(ibc(m) /= -1) THEN
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(frac(m) < 0.0001_kdp) THEN
              indx = 0
              WRITE(fupmp2,8003) cnvli*x(i),ACHAR(9),cnvli*y(j),ACHAR(9),cnvli*z(k),  &
                   ACHAR(9),cnvtmi*time,ACHAR(9),indx,ACHAR(9)
           ELSE
              indx = 1
              WRITE(fupmp2,8003) cnvli*x(i),ACHAR(9),cnvli*y(j),ACHAR(9),cnvli*z(k),  &
                   ACHAR(9),cnvtmi*time,ACHAR(9),indx,ACHAR(9),cnvli*hdprnt(m),ACHAR(9)
8003          FORMAT(4(1pg15.6,a),i5,a,1pg15.6,a)
           ENDIF
        END IF
     END DO
     IF(fresur) THEN
        DO mt=1,nxy
           IF(mfsbc(mt) /= 0) THEN
              CALL mtoijk(mt,i,j,k,nx,ny)
                 WRITE(fupmp3,8203) cnvli*x(i),ACHAR(9),cnvli*y(j),ACHAR(9),  &
                      cnvtmi*time,ACHAR(9),cnvli*wt_elev(mt),ACHAR(9)
8203             FORMAT(4(1pg15.6,a))
           END IF
        END DO
     END IF
!!$        WRITE(fupmp2,5002) ' Steady State Time Step No. ',itime,' Time ',cnvtmi*time,  &
!!$             ' ('//TRIM(unittm)//')'
!!$5002    FORMAT(a,i5,a,1PG12.3,3A)
!!$        IF(fresur) THEN
!!$           WRITE(fupmp2,5003) 'Free surface index array'
!!$5003       FORMAT(a100)
!!$           WRITE(fupmp2,5007) (mfsbc(m),m=1,nxy)
!!$5007       FORMAT(12I10)
!!$        ENDIF
!!$        WRITE(fupmp2,5003) 'Potentiometric Head'
!!$        WRITE(fupmp2,5004) (cnvli*hdprnt(m),m=1,nxyz)
!!$5004    FORMAT(9(1PG14.6))
     ntprmaphead = ntprmaphead+1
  END IF
  IF(prgfb) THEN
     ! ... Global flow balance summary
     WRITE(fubal,2001)  '*** Output at End of Steady State Iteration No. ', itime,' ***'
     WRITE(fubal,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
     WRITE(fubal,2010)
2010 FORMAT(/tr40,'*** Global Flow Balance Summary ***'/tr25,  &
          'Current Time Step',tr25,'Rates',tr18,'Amounts')
     WRITE(fubal,2011) 'Fluid inflow '//dots,cnvmfi*stotfi/deltim,  &
          '('//unitm//'/'//TRIM(unittm)//')',cnvmi*stotfi,'('//unitm//')',  &
          'Fluid outflow '//dots,cnvmfi*stotfp/deltim,  &
          '('//unitm//'/'//TRIM(unittm)//')',cnvmi*stotfp,'('//unitm//')',  &
          'Change in fluid in region '//dots,cnvmfi*dfir/deltim,  &
          '('//unitm//'/'//TRIM(unittm)//')',cnvmi*dfir,'('//unitm//')',  &
          'Residual imbalance '//dots,cnvmfi*sfres/deltim,  &
          '('//unitm//'/'//TRIM(unittm)//')',cnvmi*sfres,'('//unitm//')',  &
          'Fractional imbalance '//dots,sfresf
2011 FORMAT(/4(tr1,a60,1PE14.6,tr2,a,tr3,e14.6,tr2,a/),tr1,a60,tr28,0PF8.4)
     WRITE(fubal,2317) 'Current Time Step by Boundary Condition Type',  &
          'Rates','Amounts'
2317 FORMAT(/tr15,a/tr65,a,tr21,a)
     WRITE(fubal,2423) 'Step total specified p cell fluid net inflow '//dots,  &
          cnvmfi*stfsbc/deltim,'('//unitm//'/'//TRIM(unittm)//')',cnvmi*stfsbc,'('//unitm//')',  &
          'Step total flux b.c. fluid net inflow '//dots,  &
          cnvmfi*stffbc/deltim,'('//unitm//'/'//TRIM(unittm)//')',cnvmi*stffbc,'('//unitm//')',  &
          'Step total leakage b.c. fluid net inflow '//dots,  &
          cnvmfi*stflbc/deltim,'('//unitm//'/'//TRIM(unittm)//')',cnvmi*stflbc,'('//unitm//')',  &
          'Step total river leakage b.c. fluid net inflow '//dots,  &
          cnvmfi*stfrbc/deltim,'('//unitm//'/'//TRIM(unittm)//')',cnvmi*stfrbc,'('//unitm//')',  &
          'Step total drain leakage b.c. fluid net inflow '//dots,  &
          cnvmfi*stfdbc/deltim,'('//unitm//'/'//TRIM(unittm)//')',cnvmi*stfdbc,'('//unitm//')',  &
          'Step total well fluid net inflow '//dots,  &
          cnvmfi*stfwel/deltim,'('//unitm//'/'//TRIM(unittm)//')',cnvmi*stfwel,'('//unitm//')'
2423 FORMAT(/6(tr1,a60,1PE14.6,tr2,A,tr3,1PE14.6,tr2,A/))
     ntprgfb = ntprgfb+1
  END IF
  IF(przf) THEN
     ! ... Zonal flow rates
     WRITE(fuzf,2001)  '*** Output at End of Steady State Iteration No. ', itime,' ***'
     WRITE(fuzf,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
     DO izn=1,num_flo_zones
        WRITE(fuzf,2310) '*** Zonal Flow Summary, zone:',zone_number(izn),' ***',  &
             zone_title(izn), 'Current Time Step','Rates'
2310    FORMAT(/tr40,a,i4,a,/tr10,a/tr25,a,tr25,a)
        WRITE(fuzf,2311) 'Fluid inflow '//dots,cnvmfi*qfzoni(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'Fluid outflow '//dots,cnvmfi*qfzonp(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')'
2311    FORMAT(/2(tr1,a60,1PE14.6,tr2,a/))
        WRITE(fuzf,2017) 'Current Iteration Step Internal Faces','Rates'
        WRITE(fuzf,2323) 'Internal face fluid inflow '//  &
             dots,cnvmfi*qfzoni_int(izn),'('//unitm//'/'//TRIM(unittm)//')',  &
             'Internal face fluid outflow '//dots,cnvmfi*qfzonp_int(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')'
        WRITE(fuzf,2017) 'Current Iteration Step by Boundary Condition Type','Rates'
2017 FORMAT(/tr15,a/tr65,a)
        WRITE(fuzf,2323) 'Specified head b.c. fluid inflow '//  &
             dots,cnvmfi*qfzoni_sbc(izn),'('//unitm//'/'//TRIM(unittm)//')',  &
             'Specified head b.c. fluid outflow '//dots,cnvmfi*qfzonp_sbc(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'Flux b.c. fluid inflow '//dots,cnvmfi*qfzoni_fbc(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'Flux b.c. fluid outflow '//dots,cnvmfi*qfzonp_fbc(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'Leakage b.c. fluid inflow '//dots,cnvmfi*qfzoni_lbc(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'Leakage b.c. fluid outflow '//dots,cnvmfi*qfzonp_lbc(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'River leakage b.c. fluid inflow '//dots,cnvmfi*qfzoni_rbc(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'River leakage b.c. fluid outflow '//dots,cnvmfi*qfzonp_rbc(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'Drain leakage b.c. fluid inflow '//dots,cnvmfi*qfzoni_dbc(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'Drain leakage b.c. fluid outflow '//dots,cnvmfi*qfzonp_dbc(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'Well fluid inflow '//dots,cnvmfi*qfzoni_wel(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')',  &
             'Well fluid outflow '//dots,cnvmfi*qfzonp_wel(izn),  &
             '('//unitm//'/'//TRIM(unittm)//')'
2323    FORMAT(/12(tr1,a60,1PE14.6,tr2,A/))
     ENDDO
     ntprzf = ntprzf+1
  ENDIF
  IF(przf_tsv) THEN
     ! ... Zonal flow rates to tab separated file, fuzf_tsv
     DO izn=1,num_flo_zones
        WRITE(fuzf_tsv,2502) cnvtmi*time,achar(9),zone_number(izn),achar(9),'Water',achar(9),  &
             cnvmfi*qfzoni(izn),achar(9),cnvmfi*qfzonp(izn),achar(9),  &
             cnvmfi*qfzoni_int(izn),achar(9),cnvmfi*qfzonp_int(izn),achar(9),  &
             cnvmfi*qfzoni_sbc(izn),achar(9),cnvmfi*qfzonp_sbc(izn),achar(9),  &
             cnvmfi*qfzoni_fbc(izn),achar(9),cnvmfi*qfzonp_fbc(izn),achar(9),  &
             cnvmfi*qfzoni_lbc(izn),achar(9),cnvmfi*qfzonp_lbc(izn),achar(9),  &
             cnvmfi*qfzoni_rbc(izn),achar(9),cnvmfi*qfzonp_rbc(izn),achar(9),  &
             cnvmfi*qfzoni_dbc(izn),achar(9),cnvmfi*qfzonp_dbc(izn),achar(9),  &
             cnvmfi*qfzoni_wel(izn),achar(9),cnvmfi*qfzonp_wel(izn),achar(9)
2502    FORMAT(tr1,1pg13.6,a,i3,a,a,a,16(1pg14.7,a))
     ENDDO
     ntprzf_tsv = ntprzf_tsv+1
  END IF
  IF(prwel) THEN
     nsa = MAX(ns,1)
     ALLOCATE (chu10a(nsa), chu11a(nsa), &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: write5_ss 2"  
        STOP  
     ENDIF
     ! ... Well summary tables
     WRITE(fuwel,2001)  '*** Output at End of Steady State Iteration No. ', itime,' ***'
     WRITE(fuwel,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
     WRITE(fuwel,2025)
2025 FORMAT(/tr40,'*** Well Summary ***')
     WRITE(fuwel,2026) 'Flow Rates (positive is injection)',  &
          'Well','Fluid', 'No.','('//unitm//'/'//TRIM(unittm)//')',dash
2026 FORMAT(/tr27,a/tr2,a,tr20,a/ tr2,a,tr20,a/tr1,a70)
     chu1a='           '
     chu2a='           '
     chu3a='          '
     chu4a='          '
     chu5a='          '
     chu6a='          '
     chu7a='           '
     chu8a='           '
     DO  iwel=1,nwel
        IF(heat) WRITE(chu1a,2027) cnvhfi*qhw(iwel)
2027    FORMAT(1PG12.4)
        WRITE(fuwel,2028) welidno(iwel),cnvmfi*qwm(iwel)
2028    FORMAT(' ',i3,tr20,1PG12.4,tr3,a,tr3,a)
     END DO
     WRITE(fuwel,2029) dash,'Total - Production',  &
          cnvmfi*tqwfp,chu1a,chu2a,'- Injection', cnvmfi*tqwfi,chu7a,chu8a
2029 FORMAT(tr1,a70/tr1,a,tr5,1PG12.4,tr3,a,tr3,a/tr7,  &
          a,tr6,1PG12.4,2(tr3,a))
!!$     2030 FORMAT(/tr20,a,tr10,a/tr2,a,tr15,a,tr22,a/tr2,a,tr17,a,tr22,a/tr1,a90)
!!$     2033 FORMAT(tr1,a90/tr1,a,1PG12.4/tr7, a,tr26,1PG12.4)
!!$     WRITE(fuwel,2034) 'The following parameters are averages over ',  &
!!$          'the time step just completed','Well',  &
!!$          'Top Completion Layer','Well Datum', 'No.','Cell Head',  &
!!$          'Head', '('//unitl//')','('//unitl//')',dash
!!$2034 FORMAT(/tr20,2A/tr2,a,tr3,a,tr4,a/tr2,a,tr8,a,tr13,a/tr16,a,tr14,a/tr1,a100)
!!$     DO  iwel=1,nwel
!!$        IF(wqmeth(iwel) < 0) CYCLE
!!$        wrcalc=.FALSE.
!!$        IF(wqmeth(iwel) >= 40) wrcalc=.TRUE.
!!$        mkt=mwel(iwel,nkswel(iwel))
!!$        u2=0.d0
!!$        u3=0.d0
!!$        u4=0.d0
!!$        u5=0.d0
!!$        u6=0.d0
!!$        chu2='            '
!!$        chu3='            '
!!$        chu4='        '
!!$        chu5='        '
!!$        chu6='        '
!!$!        hwcell=p(mkt)/(den0*gz)+zwt(iwel)
!!$        u1=time
!!$        iwfss=INT(SIGN(1.d0,qwm(iwel)))
!!$        IF(ABS(qwm(iwel)) < 1.e-8_kdp) iwfss=0
!!$        IF(wqmeth(iwel) > 0) THEN
!!$           ! ... Production or injection well
!!$!           u2=pwkt(iwel)/(den0*gz)+zwt(iwel)
!!$           !..            PWSUR(IWEL)=PWSUR(IWEL)+DP(MKT)
!!$           pwcell=p(mkt)
!!$!           hwcell=pwcell/(den0*gz)+zwt(iwel)
!!$           !..               PWSUR(IWEL)=PWSUR(IWEL)-DP(MKT)
!!$           IF(wrcalc) u3=pwsur(iwel)
!!$        ELSE
!!$           ! ... Observation well Q=0 ,WQMETH=0
!!$!           u2=p(mkt)/(den0*gz)+zwt(iwel)
!!$        END IF
!!$        ! ... Load strings for printout
!!$        IF(iwfss /= 0) THEN
!!$           IF(wrcalc) then
!!$              WRITE(chu2,3002) cnvli*u2
!!$              WRITE(chu3,3002) cnvli*u3
!!$              3002 FORMAT(1PG12.4)
!!$           END IF
!!$        END IF
!!$        WRITE(fuwel,2035) welidno(iwel),chu5,chu2,chu3    !***chu5 temporary blank
!!$        2035    FORMAT(tr1,i3,3(tr8,a12))
!!$     END DO
     ! ... Well fluid injection/production per layer
     DO  m=1,nxyz
        lprnt1(m)=0
        aprnt1(m)=0.d0
     END DO
     DO  iwel=1,nwel
        DO  ks=1,nkswel(iwel)
           lwks = mwel(iwel,ks)
           lprnt1(lwks) = iwel
           aprnt1(lwks) = cnvmfi*qflyr(iwel,ks)
        END DO
     END DO
     WRITE(fuwel,2036) 'Current Fluid Production(-)/Injection(+) Rates ',  &
          'per layer ('//unitm//'/'//TRIM(unittm)//')'
2036 FORMAT(//tr10,6A)
     iw1p=-9
110  iw1p=iw1p+10
     iw2p=MIN(iw1p+9,nwel)
     WRITE(fuwel,2037) 'Layer','Well Sequence Number','No.',  &
          (welidno(ip),ip=iw1p,iw2p)
2037 FORMAT(/tr1,a,tr25,a/tr1,a,i9,9I12)
     WRITE(fuwel,2038) dash
2038 FORMAT(tr1,a120)
     DO  k=1,nz
        k1=nz+1-k
        WRITE(chk1,3005) k1
3005    FORMAT(i2)
        l=0
        DO  iwpp=iw1p,iw2p
           l=l+1
           chaprt(l)='            '
           mwk=iw(iwpp)+(jw(iwpp)-1)*nx+(k1-1)*nxy
           IF(lprnt1(mwk) == iwpp) WRITE(chaprt(l),3006) aprnt1(mwk)
3006       FORMAT(1PG12.3)
        END DO
        WRITE(fuwel,2039) chk1,(chaprt(i),i=1,l)
2039    FORMAT(tr2,a2,tr2,10(a12))
     END DO
     IF(iw2p < nwel) GO TO 110
     WRITE(fuwel,2040)
2040 FORMAT(/tr1,120('-')/)
     DEALLOCATE (chu10a, chu11a, &
          stat = da_err)
     IF (da_err.NE.0) THEN  
        PRINT *, "Array deallocation failed"  
        STOP  
     ENDIF
     ntprwel = ntprwel+1
  END IF
!$$$ force bcf print
  prbcf = .TRUE.
  IF(prbcf) THEN
     WRITE(fubcf,2001) '*** Output at End of Steady State Iteration No. ', itime,' ***'
2001 FORMAT(/tr30,a,i5,a)
     WRITE(fubcf,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
2002 FORMAT(/tr5,a60,1PG12.3,tr2,a)
     IF(nsbc > 0) THEN
        DO  m=1,nxyz
           lprnt2(m)=-1
           lprnt3(m)=-1
           lprnt1(m)=-1
        END DO
        prthd=.FALSE.
        prthd2=.FALSE.
        prthd3=.FALSE.
        WRITE(fubcf,2041) 'Specified Head B.C.: Flow Rates (average over time step)',  &
             '(positive is into the region)'
2041    FORMAT(//tr25,a/tr25,a)
        DO  l=1,nsbc
           m=msbc(l)
           WRITE(cibc,3007) ibc(m)
3007       FORMAT(i9.9)
           IF(cibc(1:1) == '1') THEN
              lprnt1(m)=1
              prthd=.TRUE.
              aprnt1(m)=qfsbc(l)
              IF(cibc(4:4) /= '1') THEN
                 lprnt2(m)=1
                 prthd2=.TRUE.
              END IF
              IF(cibc(7:7) /= '1') THEN
                 lprnt3(m)=1
                 prthd3=.TRUE.
              END IF
           END IF
        END DO
        IF(prthd) THEN
           WRITE(fubcf,2042) 'Fluid   (',unitm,'/',TRIM(unittm),')'
2042       FORMAT(tr20,10A)
           CALL printar(2,aprnt1,lprnt1,fubcf,cnvmfi,24,000)
        END IF
     END IF
     IF(nfbc > 0) THEN
        WRITE(fubcf,2043)  'Specified Flux B.C.: Flow Rates (at end of time step)',  &
             '(positive is into the region)'
2043    FORMAT(//tr25,a/tr25,a)
        lprnt1 = -1
        !$$        prthd=.FALSE.
        DO  lc=1,nfbc_cells
           m = flux_seg_m(lc)
           IF(fresur) THEN
              ls = flux_seg_first(lc)
              IF(ifacefbc(ls) == 3 .AND. frac(m) <= 0._kdp) THEN
                 l1 = MOD(m,nxy)
                 IF(l1 == 0) l1 = nxy
                 m = mfsbc(l1)
              END IF
           END IF
           IF (m > 0) THEN          ! ... skip columns of dry cells
              lprnt1(m) = 1
              !$$              prthd=.TRUE.
              aprnt1(m) = qffbc(lc)
           END IF
        END DO
        WRITE(fubcf,2042) 'Fluid Mass   (',unitm,'/',TRIM(unittm),')'
        CALL printar(2,aprnt1,lprnt1,fubcf,cnvmfi,24,000)
     END IF
     IF(nlbc > 0) THEN
        WRITE(fubcf,2043) 'Leakage B.C.: Flow Rates ','(positive is into the region)'
        WRITE(fubcf,2042) 'Fluid   (',unitm,'/',TRIM(unittm),')'
        lprnt1 = -1
        DO  lc=1,nlbc
           m = leak_seg_m(lc)
           lprnt1(m) = 1
           aprnt1(m) = qflbc(lc)
        END DO
        CALL printar(2,aprnt1,lprnt1,fubcf,cnvmfi,24,000)
     END IF
     IF(nrbc > 0) THEN
        WRITE(fubcf,2043) 'River Leakage B.C.: Flow Rates ','(positive is into the region)'
        WRITE(fubcf,2042) 'Fluid   (',unitm,'/',TRIM(unittm),')'
        lprnt4 = -1
        DO  lc=1,nrbc
           m = river_seg_m(lc)
           IF(m > 0) THEN
              lprnt4(m) = 1
              aprnt4(m) = qfrbc(lc)
           END IF
        END DO
        CALL printar(2,aprnt4,lprnt4,fubcf,cnvmfi,24,000)
     END IF
     IF(ndbc > 0) THEN
        WRITE(fubcf,2043) 'Drain Leakage B.C.: Flow Rates ','(positive is into the region)'
        WRITE(fubcf,2042) 'Fluid   (',unitm,'/',TRIM(unittm),')'
        lprnt4 = -1
        DO  lc=1,ndbc
           m = drain_seg_m(lc)
           lprnt4(m) = 1
           aprnt4(m) = qfdbc(lc)
        END DO
        CALL printar(2,aprnt4,lprnt4,fubcf,cnvmfi,24,000)
     END IF
!!$     IF(netbc > 0) THEN
!!$        !...**not available for PHAST
!!$     IF(naifc > 0) THEN
!!$        !... ** not available for PHAST
     ntprbcf = ntprbcf+1
  END IF
  ! ... Set the next time for printout if by user time units
!!$  IF(time >= cnvtm*timprt) timprt=timprt+primin
  DEALLOCATE (lprnt3, lprnt4,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: write5_ss_flow"  
  ENDIF
END SUBROUTINE write5_ss_flow
