SUBROUTINE write5
  ! ... Prints out the dependent variables, iteration summaries, well
  ! ...      tables and maps after SUMCAL at end of time step
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcc
  USE mcch
  USE mcg
  USE mcn
  USE mcp
  USE mct
  USE mcv
  USE mcw
  USE mg2, ONLY: hdprnt
  USE print_control_mod
  IMPLICIT NONE
  INCLUDE 'ifwr.inc'
  EXTERNAL ehoftp
  REAL(KIND=kdp) :: ehoftp
  INTRINSIC INDEX, INT
  CHARACTER(LEN=39) :: fmt2, fmt4
  CHARACTER(LEN=46) :: aformt = '(TR5,A43,1PE12.4,TR1,A9,TR1,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=50) :: aform =  '(TR5,A45,T47,1PE12.4,TR1,A9,T72,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=12), DIMENSION(10) :: chaprt
  CHARACTER(LEN=12) :: chu1a, chu2a, chu2, chu3, chu3a, chu4a, chu5a, chu6a, chu7a, chu8a
  CHARACTER(LEN=2) :: chk1
  CHARACTER(LEN=8) :: chu4, chu5, chu6
  CHARACTER(LEN=9) :: cibc
  CHARACTER(LEN=1), DIMENSION(3) :: lbldir = (/'X','Y','Z'/)
  CHARACTER(LEN=12), DIMENSION(:), ALLOCATABLE :: chu10a, chu11a
  REAL(KIND=kdp) :: hwcell, pwcell, tdehir, tdfir, tdsir, u1, u2, u3,  &
       u4,  u5, u6, u7
  INTEGER :: a_err, da_err, i, ic, ifmt, iis, indx,  &
       ip, is1, is2, iw1p, iw2p, iwel, iwfss, iwpp, j, jprptc,  &
       k, k1, ks, l, l1, lc, ll, ls, lll, lwk, lwks, m, mfs, mkt, mm, mt, mwk, nsa
  LOGICAL :: erflg, prthd, prthd2, prthd3
  REAL(KIND=kdp), PARAMETER :: cnv = 1._kdp
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: cwkt_mol
  REAL(KIND=kdp) :: ph, alk
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ALLOCATE (lprnt3(nxyz), lprnt4(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: write5"  
     STOP  
  ENDIF
  erflg=.FALSE.
  ! ... Print out the summary tables
  IF(errexe) THEN
     prp=.TRUE.
     prc=.TRUE.
     prgfb=.TRUE.
     prbcf=.TRUE.
     IF(nwel > 0) prwel=.TRUE.
     prslm=.TRUE.
  END IF
  IF(itime == 0) RETURN     ! ... error exit; no results to print
  IF (solute) THEN
     CALL convert_to_molal(dcmax,1,1)
     c_mol = c
     CALL convert_to_molal(c_mol,nxyz,nxyz)
  ENDIF
  !  WRITE(*,3001) 'Finished time step no. ',itime,'; Time '//dots(1:30),cnvtmi*time,'('//TRIM(unittm)//')'
  !3001 FORMAT(tr5,a,I6,a,1PG12.3,tr2,a)
2001 FORMAT(/tr30,a,i5,a)
2002 FORMAT(/tr5,a60,1PG12.3,tr2,a)
  WRITE(logline1,5001) '     End of Time Step No. ', itime
5001 FORMAT(a,i5)
  WRITE(logline2,5002) '     Time '//dots,cnvtmi*time,' ('//TRIM(TRIM(unittm))//')'
5002 FORMAT(a60,1PG15.6,a)
  CALL logprt_c(logline1)
  CALL logprt_c(logline2)
  IF(prslm) THEN
!!$     IF(heat .OR. solute) WRITE(logline1,5003) '     No. of P,T,C loop iterations used ',dots,itrn
!!$5003 format(a,a26,i4)
!!$2003 FORMAT(/tr5,'No. of P,T,C loop iterations used ',26('.'),i4)
!!$     call logprt_c(logline1)
     IF(autots .AND. ntsfal > 0) THEN 
        WRITE(logline1,5007)  &
             'Number of repeats of time step to achieve ','truncation error'//dots,ntsfal
5007    FORMAT(a42,a23,i4)
        CALL logprt_c(logline1)
     ENDIF
     WRITE(logline1,5027) '     Maximum change in potentiometric head '//dots,  &
          cnvpi*dhmax,' ('//unitl//')',' at location (',  &
          cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(',TRIM(unitl)//')'
5027 FORMAT(A43,1PE12.4,A10,A,3(1PG10.3,A),A)
     CALL logprt_c(logline1)
     !      WRITE(*,aformt) 'Maximum change in potentiometric head '//dots,  &
     !           cnvpi*dhmax,'('//unitl//')','at location (',  &
     !           cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(',TRIM(unitl),')'
     WRITE(logline1,aformt) 'Maximum change in potentiometric head '//dots,  &
          cnvpi*dhmax,'('//unitl//')','at (',  &
          cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(',TRIM(unitl),')'
     CALL screenprt_c(logline1)
!!$     IF(heat) THEN
!!$        WRITE(fuclog,aform) 'Maximum change in temperature '//dots,  &
!!$             cnvt1i*dtmax+cnvt2i,'(Deg.'//unitt//')',  &
!!$             'at location (',cnvli*x(itmax),',',cnvli*y(jtmax),',',cnvli*z(ktmax),')(',unitl,')'
!!$        WRITE(*,aformt) 'Maximum change in temperature '//dots,  &
!!$             cnvt1i*dtmax+cnvt2i,'(Deg.'//unitt//')',  &
!!$             'at location (',cnvli*x(itmax),',',cnvli*y(jtmax),',',cnvli*z(ktmax),')(',unitl,')'
!!$     END IF
     IF (solute) THEN
        DO  is=1,ns
           u6=dcmax(is)
           WRITE(logline1,5027) '     Maximum change in '//TRIM(comp_name(is))//' '//  &
                dots, u6,' (mol/kgw)',' at location (',  &
                cnvli*x(icmax(is)),',',cnvli*y(jcmax(is)),',', cnvli*z(kcmax(is)),')(',TRIM(unitl)//')'
           CALL logprt_c(logline1)
           WRITE(logline1,aformt) 'Maximum change in '//TRIM(comp_name(is))  &
                //dots, u6,'(mol/kgw)','at (',  &
                cnvli*x(icmax(is)),',',cnvli*y(jcmax(is)),',', cnvli*z(kcmax(is)),')(',TRIM(unitl),')'
           CALL screenprt_c(logline1)
        END DO
     END IF
  END IF
  IF(prp .OR. prc) THEN
     DO  m=1,nxyz
        IF(ibc(m) == -1 .OR. frac(m) <= 0.0001_kdp) THEN
           lprnt1(m)=-1
        ELSE
           lprnt1(m)=1
        END IF
     END DO
     ! ... Grid cell values (PTC)
     IF(prp .AND. .NOT.steady_flow) THEN
        WRITE(fup,2001)  '*** Output at End of Time Step No. ', itime,' ***'
        WRITE(fup,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
        WRITE(fup,aform) 'Maximum change in potentiometric head '//dots,  &
             cnvpi*dhmax,'('//unitl//')','at location (',  &
             cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(', unitl,')'
!!$        WRITE(fup,aform) 'Maximum change in pressure '//dots,  &
!!$             cnvpi*dpmax,'('//unitp//')','at location (',  &
!!$             cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(', unitl,')'
!!$        ! WRITE(fup,2008) 'Pressure   (',unitp,')'
2008    FORMAT(/tr30,10A)
!!$        ! CALL prntar(2,p,lprnt1,fup,cnvpi,24,000)
        ifmt=13
        IF(eeunit) ifmt=12
        WRITE(fup,2009) 'Fluid Potentiometric Head ('//TRIM(unitl)//')'
2009    FORMAT(/tr30,3A/tr35,a,1PG10.2,tr2,5A)
        CALL prntar(2,hdprnt,lprnt1,fup,cnvli,ifmt,000)
        IF(fresur) THEN
           DO  m=1,nxyz
              lprnt2(m)=-1
           END DO
           DO  mt=1,nxy
              mfs=mfsbc(mt)
              IF(mfs /= 0) lprnt2(mfs)=1
           END DO
           WRITE(fup,2008) 'Fraction of cell that is saturated  (-)'
           CALL prntar(2,frac,lprnt2,fup,cnv,14,000)
        END IF
        ntprp = ntprp+1
     ENDIF
     IF(solute .AND. prc) THEN
        WRITE(fuc,2001)  '*** Output at End of Time Step No. ', itime,' ***'
        WRITE(fuc,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
        DO  is=1,ns
           WRITE(fuc,aform) 'Maximum change in '//comp_name(is)//'molality '  &
                //dots,dcmax(is),'('//'mol/kgw'//')','at location (',  &
                cnvli*x(icmax(is)),',',cnvli*y(jcmax(is)),',', cnvli*z(kcmax(is)),  &
                ')(',unitl,')'
           WRITE(fuc,2008) 'Molality (mol/kgw)'
           WRITE(fuc,2008) 'Component: '//comp_name(is)
           DO  m=1,nxyz
              aprnt1(m)=c_mol(m,is)
           END DO
           CALL prntar(2,aprnt1,lprnt1,fuc,cnv,25,000)
        END DO
        ntprc = ntprc+1
     END IF
  END IF
  !      IF(PRDV) THEN
  !         WRITE(FUD,2001)  '*** Output at End of Time Step No. ',
  !     &        ITIME,' ***'
  !         WRITE(FUD,2002) 'Time '//DOTS,CNVTMI*TIME,'('//UNITTM//')'
  !         WRITE(FUD,2008) 'Density (',UNITM,'/',UNITL,'^3)'
  !         IFMT=12
  !         IF(EEUNIT) IFMT=13
  !         CALL PRNTAR(2,DEN,LPRNT1,FUD,CNVDI,IFMT,000)
  !         WRITE(FUVS,2001)  '*** Output at End of Time Step No. ',
  !     &        ITIME,' ***'
  !         WRITE(FUVS,2002) 'Time '//DOTS,CNVTMI*TIME,'('//UNITTM//')'
  !         WRITE(FUVS,2008) 'Viscosity   (',UNITVS,')'
  !         IFMT=24
  !         IF(EEUNIT) IFMT=15
  !         CALL PRNTAR(2,VIS,LPRNT1,FUVS,CNVVSI,IFMT,000)
  !      ENDIF
  IF(prgfb) THEN
     ! ... Global flow balance summary
     WRITE(fubal,2001)  '*** Output at End of Time Step No. ', itime,' ***'
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
!!$     IF(heat) THEN
!!$        WRITE(fubal,2011) 'Heat inflow '//dots,cnvhfi*stothi/deltim,  &
!!$             '('//unithf//')',cnvhei*stothi,'('//unith//')',  &
!!$             'Heat outflow '//dots,cnvhfi*stothp/deltim,  &
!!$             '('//unithf//')',cnvhei*stothp,'('//unith//')',  &
!!$             'Change in heat in region '//dots,cnvhfi*dehir/  &
!!$             deltim,'('//unithf//')',cnvhei*dehir,'('//unith//')',  &
!!$             'Residual imbalance '//dots,cnvhfi*shres/deltim,  &
!!$             '('//unithf//')',cnvhei*shres,'('//unith//')',  &
!!$             'Fractional imbalance '//dots,shresf
!!$     END IF
     IF (solute) THEN
        DO  is=1,ns
           WRITE(fubal,2036) 'Component: ', comp_name(is)
           WRITE(fubal,2012) 'Solute inflow '//dots,cnvmfi*stotsi(is)/deltim,  &
                '(',unitm,'/',TRIM(unittm),')',cnvmi*stotsi(is), '(',unitm,')',  &
                'Solute outflow '//dots,cnvmfi*stotsp(is)/deltim, '(',unitm,  &
                '/',TRIM(unittm),')',cnvmi*stotsp(is),'(',unitm,')',  &
                'Change in solute in region from reactions '//dots,  &
                cnvmfi*dsir_chem(is)/deltim,  &
                '(',unitm,'/',TRIM(unittm),')',cnvmi*dsir_chem(is),'(',unitm,')',  &
                'Change in solute in region '//dots, cnvmfi*dsir(is)/deltim,  &
                '(',unitm,'/',TRIM(unittm),')',cnvmi*dsir(is),'(',unitm,')'
2012       FORMAT(/3(tr1,a60,1PE14.6,tr2,5A,tr3,e14.6,tr2,3A/),  &
                tr1,a60,1PE14.6,tr2,5A,tr3,e14.6,tr2,3A)
           WRITE(fubal,2014) 'Residual imbalance '//dots,  &
                cnvmfi*ssres(is)/deltim,'(',unitm,'/',TRIM(unittm),')',  &
                cnvmi*ssres(is),'(',unitm,')', 'Fractional imbalance '//dots,ssresf(is)
2014       FORMAT(tr1,a60,1PE14.6,tr2,5A,tr3,e14.6,tr2,3A/tr1,a60,tr28,0PF8.4)
        END DO
     ENDIF
     WRITE(fubal,2017) 'Current Time Step by Boundary Condition Type','Amounts'
     WRITE(fubal,2023) 'Step total specified head b.c. fluid net inflow '//  &
          dots,cnvmi*stfsbc,'(',unitm,')',  &
          'Step total flux b.c. fluid net inflow '//dots,cnvmi*stffbc,'(',unitm,')',  &
          'Step total leakage b.c. fluid net inflow '//dots,cnvmi*stflbc,'(',unitm,')',  &
          'Step total river leakage b.c. fluid net inflow '//dots,cnvmi*stfrbc,'(',unitm,')', &
          'Step total drain leakage b.c. fluid net inflow '//dots,cnvmi*stfdbc,'(',unitm,')', &
                                !     &        'Step total evapotranspiration b.c. fluid net inflow '//
                                !     &        DOTS,CNVMI*STFETB,'(',UNITM,')',
                                !     &        'Step total aquifer influence fluid net inflow '//DOTS,
                                !     &        CNVMI*STFAIF,'(',UNITM,')',  &
          'Step total well fluid net inflow '//dots,cnvmi*stfwel, '(',unitm,')'
!!$         IF(HEAT) THEN
!!$            WRITE(FUBAL,2016)
!!$     &           'Step total specified T cell or associated with ',
!!$     &           'specified P cell heat net inflow'//DOTS,CNVHEI*STHSBC,
!!$     &           '(',UNITH,')',
!!$     &           'Step total flux b.c. heat net inflow '//DOTS,
!!$     &           CNVHEI*STHFBC,'(',UNITH,')',
!!$     &           'Step total leakage b.c. heat net inflow '//DOTS,
!!$     &           CNVHEI*STHLBC,'(',UNITH,')',
!!$     &           'Step total evapotranspiration b.c. heat net inflow '//
!!$     &           DOTS,CNVHEI*STHETB,'(',UNITH,')',
!!$     &           'Step total aquifer influence heat net inflow '//DOTS,
!!$     &           CNVHEI*STHAIF,'(',UNITH,')',
!!$     &           'Step total heat conduction b.c. heat net inflow '//
!!$     &           DOTS,CNVHEI*STHHCB,'(',UNITH,')',
!!$     &           'Step total well heat net inflow '//DOTS,CNVHEI*STHWEL,
!!$     &           '(',UNITH,')'
!!$ 2016       FORMAT(/TR1,A/TR6,A55,1PE14.6,TR2,3A/6(TR1,A60,1PE14.6,TR2,
!!$     &           3A/))
!!$         ENDIF
     DO  is=1,ns
        WRITE(fubal,2036) 'Component: ', comp_name(is)
        WRITE(fubal,2023) 'Step total specified head b.c. solute net inflow'//dots,  &
             cnvmi*stssbc(is),'(',unitm,')',  &
             'Step total flux b.c. solute net inflow '//dots,cnvmi*stsfbc(is),'(',unitm,')',  &
             'Step total leakage b.c. solute net inflow '//dots,cnvmi*stslbc(is),'(',unitm,')',  &
             'Step total river leakage b.c. solute net inflow '// dots,cnvmi*stsrbc(is), &
             '(',unitm,')', &
             'Step total drain leakage b.c. solute net inflow '// dots,cnvmi*stsdbc(is), &
             '(',unitm,')', &
                                !     &           'Step total evapotranspiration b.c. solute net inflow '
                                !     &           //DOTS,CNVMI*STSETB,'(',UNITM,')',
                                !     &           'Step total aquifer influence solute net inflow '//
                                !     &           DOTS,CNVMI*STSAIF,'(',UNITM,')',  &
             'Step total well solute net inflow '//dots, cnvmi*stswel(is),'(',unitm,')'
     END DO
     WRITE(fubal,2017) 'Cumulative Summary','Amounts'
2017 FORMAT(/tr15,a/tr65,a)
     tdfir=fir-fir0
     WRITE(fubal,2018) 'Cumulative Fluid inflow '//dots,cnvmi*totfi,'(',unitm,')',  &
          'Cumulative Fluid outflow '//dots,cnvmi*totfp,'(',unitm,')',  &
          'Cumulative Change in fluid in region '//dots,cnvmi*tdfir, '(',unitm,')',  &
          'Current Fluid in region '//dots,cnvmi*fir,'(',unitm,')',  &
          'Current Fluid volume in region '//dots,cnvl3i*firv, '(',unitl,'^3)',  &
          'Residual imbalance '//dots,cnvmi*tfres,'(', unitm,')',  &
          'Fractional imbalance '//dots,tfresf
2018 FORMAT(/6(tr1,a60,1PE14.6,tr2,3A/),tr1,a60,0PF12.4)
!!$     IF(heat) THEN
!!$        tdehir=ehir-ehir0
!!$        WRITE(fubal,2019) 'Heat  inflow '//dots,cnvhei*tothi,'(',unith,')',  &
!!$             'Heat  outflow '//dots,cnvhei*tothp,'(',unith,')',  &
!!$             'Change in heat in region '//dots, cnvhei*tdehir,'(',unith,')',  &
!!$             'Heat in region '//dots,cnvhei*ehir,'(',unith,')',  &
!!$             'Residual imbalance '//dots, cnvhei*thres,'(',unith,')',  &
!!$             'Fractional imbalance '//dots,thresf
!!$2019    FORMAT(/5(tr1,a60,1PE14.6,tr2,3A/),tr1,a60,0PF12.4)
!!$     END IF
     IF (solute) THEN
        DO  is=1,ns
           WRITE(fubal,2036) 'Component: ', comp_name(is)
           tdsir=sir(is)-sir0(is)
           WRITE(fubal,2020) 'Cumulative solute inflow '//dots,cnvmi*totsi(is),'(',unitm,')',  &
                'Cumulative solute outflow '//dots,cnvmi*totsp(is),'(',unitm,')',  &
                'Cumulative change in solute in region from reactions '//dots,  &
                cnvmi*tdsir_chem(is),'(',unitm,')',  &
                'Cumulative change in solute in region '//dots, cnvmi*tdsir,'(',unitm,')',  &
                'Current solute in region '//dots,cnvmi*sir(is),'(',unitm,')'
2020       FORMAT(/4(tr1,a60,1PE14.6,tr2,3A/),tr1,a60,1PE14.6,tr2,3A)
           WRITE(fubal,2022) 'Residual imbalance'//dots,cnvmi*tsres(is),'('//unitm//')',  &
                'Fractional imbalance '//dots,tsresf(is)
2022       FORMAT(tr1,a60,1PE14.6,tr2,a/tr1,a60,0PF12.4)
        END DO
     ENDIF
     WRITE(fubal,2017) 'Cumulative Summary by Boundary Condition Type','Amounts'
     WRITE(fubal,2023) 'Cumulative specified head b.c. fluid net inflow '//dots,  &
          cnvmi*tcfsbc,'(',unitm,')',  &
          'Cumulative flux b.c. fluid net inflow '//dots, cnvmi*tcffbc,'(',unitm,')',  &
          'Cumulative leakage b.c. fluid net inflow '//dots,  &
          cnvmi*tcflbc,'(',unitm,')',  &
          'Cumulative river leakage b.c. fluid net inflow '//dots,  &
          cnvmi*tcfrbc,'(',unitm,')', &
          'Cumulative drain leakage b.c. fluid net inflow '//dots,  &
          cnvmi*tcfdbc,'(',unitm,')', &
                                !     &        'Cumulative evapotranspiration b.c. fluid net inflow '//
                                !     &        DOTS,CNVMI*TCFETB,'(',UNITM,')',
                                !     &        'Cumulative aquifer influence fluid net inflow '//DOTS,
                                !     &        CNVMI*TCFAIF,'(',UNITM,')',  &
          'Cumulative well fluid net inflow '//dots,  &
          cnvmi*(totwfi-totwfp),'(',unitm,')'
2023 FORMAT(/6(tr1,a60,1PE14.6,tr2,3A/))
     !         IF(HEAT) THEN
     !            WRITE(FUBAL,2024)
     !     &           'Cumulative specified T cell or associated with ',
     !     &           'specified P cell heat net inflow'//DOTS,
     !     &           CNVHEI*TCHSBC,'(',UNITH,')',
     !     &           'Cumulative flux b.c. heat net inflow '//DOTS,
     !     &           CNVHEI*TCHFBC,'(',UNITH,')',
     !     &           'Cumulative leakage b.c. heat net inflow '//DOTS,
     !     &           CNVHEI*TCHLBC,'(',UNITH,')',
     !     &           'Cumulative evapotranspiration b.c. heat net inflow '//
     !     &           DOTS,CNVHEI*TCHETB,'(',UNITH,')',
     !     &           'Cumulative aquifer influence heat net inflow '//DOTS,
     !     &           CNVHEI*TCHAIF,'(',UNITH,')',
     !     &           'Cumulative heat conduction b.c. heat net inflow '//
     !     &           DOTS,CNVHEI*TCHHCB,'(',UNITH,')',
     !     &           'Cumulative well heat net inflow '//DOTS,
     !     &           CNVHEI*(TOTWHI-TOTWHP),'(',UNITH,')'
     !         ENDIF
     IF (solute) THEN
        DO  is=1,ns
           WRITE(fubal,2036) 'Component: ', comp_name(is)
           WRITE(fubal,2024) 'Cumulative specified head b.c. solute net inflow'//dots,  &
                cnvmi*tcssbc(is),'(',unitm,')',  &
                'Cumulative flux b.c. solute net inflow '//dots,  &
                cnvmi*tcsfbc(is),'(',unitm,')',  &
                'Cumulative leakage b.c. solute net inflow '//dots,  &
                cnvmi*tcslbc(is),'(',unitm,')',  &
                'Cumulative river leakage b.c. solute net inflow '// dots,  &
                cnvmi*tcsrbc(is),'(',unitm,')', &
                'Cumulative drain leakage b.c. solute net inflow '// dots,  &
                cnvmi*tcsdbc(is),'(',unitm,')', &
                                !     &           'Cumulative evapotranspiration b.c. solute net inflow '
                                !     &           //DOTS,CNVMI*TCSETB,'(',UNITM,')',
                                !     &           'Cumulative aquifer influence solute net inflow '//
                                !     &           DOTS,CNVMI*TCSAIF,'(',UNITM,')',  &
                'Cumulative well solute net inflow '//dots,  &
                cnvmi*(totwsi(is)-totwsp(is)),'(',unitm,')'
2024       FORMAT(/6(tr1,a60,1PE14.6,tr2,3A/))
        END DO
     ENDIF
     ntprgfb = ntprgfb+1
  END IF
  IF(prwel .OR. prtem) THEN
     nsa = MAX(ns,1)
     ALLOCATE (chu10a(nsa), chu11a(nsa), cwkt_mol(nwel,nsa), &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: write5"  
        STOP  
     ENDIF
     IF (solute) THEN
        cwkt_mol = cwkt
        CALL convert_to_molal(cwkt_mol,nwel,nwel)
     ENDIF
     IF(prwel) THEN
        ! ... Well summary tables
        WRITE(fuwel,2001)  '*** Output at End of Time Step No. ', itime,' ***'
        WRITE(fuwel,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
        WRITE(fuwel,2025)
2025    FORMAT(/tr40,'*** Well Summary ***')
        WRITE(fuwel,2026) 'Flow Rates (positive is injection)',  &
             'Well','Fluid', 'No.','('//unitm//'/'//TRIM(unittm)//')',dash
2026    FORMAT(/tr27,a/tr2,a,tr20,a/ tr2,a,tr20,a/tr1,a70)
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
2027       FORMAT(1PG12.4)
           WRITE(fuwel,2028) welidno(iwel),cnvmfi*qwm(iwel)
2028       FORMAT(' ',i3,tr20,1PG12.4,tr3,a,tr3,a)
        END DO
        IF(heat) THEN
           WRITE(chu1a,2027) cnvhfi*tqwhp
           WRITE(chu7a,2027) cnvhfi*tqwhi
        END IF
        WRITE(fuwel,2029) dash,'Total - Production',  &
             cnvmfi*tqwfp,chu1a,chu2a,'- Injection', cnvmfi*tqwfi,chu7a,chu8a
2029    FORMAT(tr1,a70/tr1,a,tr5,1PG12.4,tr3,a,tr3,a/tr7,  &
             a,tr6,1PG12.4,2(tr3,a))
        IF(solute) THEN
           DO is1=1,ns,9
              is2 = MIN(is1 + 8,ns)
              WRITE(fuwel,2126) 'Solute Flow Rates (positive is injection)',  &
                   'Well','Solute Component: ', 'No.','('//unitm//'/'//TRIM(unittm)//')',  &
                   (comp_name(is),is=is1,is2)
2126          FORMAT(/tr27,a/tr2,a,tr39,a/tr2,a,tr43,a/tr11,9(a12))
              WRITE(fuwel,2326) dash
2326          FORMAT(tr1,a115)
              DO  iwel=1,nwel
                 DO  is=is1,is2
                    WRITE(chu10a(is),2027) cnvmfi*qsw(iwel,is)
                 END DO
                 WRITE(fuwel,2128) iwel,(chu10a(is),is=is1,is2)
2128             FORMAT(tr1,i3,tr4,9a)
              END DO
              DO  is=is1,is2
                 WRITE(chu10a(is),2027) cnvmfi*tqwsp(is)
                 WRITE(chu11a(is),2027) cnvmfi*tqwsi(is)
              END DO
              WRITE(fuwel,2129) dash,'Total - Production', (chu10a(is),is=is1,is2)
2129          FORMAT(tr1,a115/tr1,a/tr8,9a)
              WRITE(fuwel,2329) '- Injection', (chu11a(is),is=is1,is2)
2329          FORMAT(tr7,a/tr8,9a)
           END DO
        END IF
        WRITE(fuwel,2030) 'Cumulative Production','Cumulative Injection',  &
             'Well','Fluid','Fluid', 'No.','('//unitm//')','('//unitm//')',dash
2030    FORMAT(/tr16,a,tr3,a/tr2,a,tr17,a,tr20,a/tr2,a,tr18,a,tr21,a/tr1,a90)
        DO  iwel=1,nwel
!!$           IF(heat) THEN
!!$              WRITE(chu3a,2031) cnvhei*whpcum(iwel)
!!$              WRITE(chu5a,2031) cnvhei*whicum(iwel)
!!$           END IF
!!$2031       FORMAT(1PG12.4)
           WRITE(fuwel,2032) welidno(iwel),cnvmi*wfpcum(iwel),cnvmi*wficum(iwel)
2032       FORMAT(' ',i4,tr14,1pg12.4,tr13,1pg12.4)
        END DO
!!$        IF(heat) THEN
!!$           WRITE(chu3a,2031) cnvhei*totwhp
!!$           WRITE(chu5a,2031) cnvhei*totwhi
!!$        END IF
        WRITE(fuwel,2033) dash,'Total - Production', cnvmi*totwfp,'- Injection',cnvmi*totwfi
2033    FORMAT(tr1,a90/tr1,a,1pg12.4/tr7,a,tr26,1pg12.4)
        IF(solute) THEN
           DO is1=1,ns,9
              is2 = MIN(is1 + 8,ns)
              WRITE(fuwel,2126) 'Cumulative Production',  &
                   'Well','Solute Component: ', 'No.','('//unitm//')',  &
                   (comp_name(is),is=is1,is2)
              WRITE(fuwel,2326) dash
              DO  iwel=1,nwel
                 DO  is=is1,is2
                    WRITE(chu10a(is),2027) cnvmi*wspcum(iwel,is)
                 END DO
                 WRITE(fuwel,2128) iwel,(chu10a(is),is=is1,is2)
              END DO
              DO  is=is1,is2
                 WRITE(chu10a(is),2027)  cnvmi*totwsp(is)
              END DO
              WRITE(fuwel,2129) dash,'Total - Production', (chu10a(is),is=is1,is2)
           END DO
           DO is1=1,ns,9
              is2 = MIN(is1 + 8,ns)
              WRITE(fuwel,2126) 'Cumulative Injection',  &
                   'Well','Solute Component: ', 'No.','('//unitm//')',  &
                   (comp_name(is),is=is1,is2)
              WRITE(fuwel,2326) dash
              DO  iwel=1,nwel
                 DO  is=is1,is2
                    WRITE(chu11a(is),2027) cnvmi*wsicum(iwel,is)
                 END DO
                 WRITE(fuwel,2128) iwel,(chu11a(is),is=is1,is2)
              END DO
              DO  is=is1,is2
                 WRITE(chu11a(is),2027)  cnvmi*totwsi(is)
              END DO
              WRITE(fuwel,2129) dash,'Total - Injection', (chu11a(is),is=is1,is2)
           END DO
        END IF
!!$        WRITE(fuwel,2034) 'The following parameters are averages over ',  &
!!$             'the time step just completed','Well',  &
!!$             'Top Completion Layer','Well Datum', 'No.','Cell Head',  &
!!$             'Head', '('//unitl//')','('//unitl//')',dash
!!$2034    FORMAT(/tr20,2A/tr2,a,tr3,a,tr4,a/ tr2,a,tr8,a,tr13,a/tr16,a,tr14,a, /tr1,a100)
!!$        DO  iwel=1,nwel
!!$           IF(wqmeth(iwel) < 0) CYCLE
!!$           wrcalc=.FALSE.
!!$           IF(wqmeth(iwel) >= 40) wrcalc=.TRUE.
!!$           mkt=mwel(iwel,nkswel(iwel))
!!$           u2=0.d0
!!$           u3=0.d0
!!$           u4=0.d0
!!$           u5=0.d0
!!$           u6=0.d0
!!$           chu2='            '
!!$           chu3='            '
!!$           chu4='        '
!!$           chu5='        '
!!$           chu6='        '
!!$!           hwcell=p(mkt)/(den0*gz)+zwt(iwel)  !***incorrect
!!$           u1=time
!!$           iwfss=INT(SIGN(1.d0,qwm(iwel)))
!!$           IF(ABS(qwm(iwel)) < 1.e-8_kdp) iwfss=0
!!$           IF(wqmeth(iwel) > 0) THEN
!!$              ! ... Production or injection well
!!$!              u2=pwkt(iwel)/(den0*gz)+zwt(iwel) !*** not correct
!!$              !..            PWSUR(IWEL)=PWSUR(IWEL)+DP(MKT)
!!$              pwcell=p(mkt)
!!$!              hwcell=pwcell/(den0*gz)+zwt(iwel) !*** not correct
!!$              !..               PWSUR(IWEL)=PWSUR(IWEL)-DP(MKT)
!!$              IF(wrcalc) u3=pwsur(iwel)
!!$              IF(heat) THEN
!!$                 u4=twkt(iwel)
!!$                 IF(qwm(iwel) <= 0.AND.wrcalc) u5=twsur(iwel)
!!$              END IF
!!$           ELSE
!!$              ! ... Observation well Q=0 ,WQMETH=0
!!$!              u2=p(mkt)/(den0*gz)+zwt(iwel)  !***not correct
!!$              IF(heat) u4=t(mkt)
!!$           END IF
!!$           !            U7=DEN(MKT)
!!$           ! ... Load strings for printout
!!$           IF(iwfss /= 0) THEN
!!$              IF(wrcalc) then
!!$                 WRITE(chu2,3002) cnvli*u2
!!$                 WRITE(chu3,3002) cnvli*u3
!!$3002             FORMAT(1PG12.4)
!!$              END IF
!!$              IF(heat) THEN
!!$                 WRITE(chu4,3003) cnvt1i*u4+cnvt2i
!!$                 IF(wrcalc) WRITE(chu5,3003) cnvt1i*u5+cnvt2i
!!$3003             FORMAT(f8.1)
!!$              END IF
!!$           END IF
!!$           WRITE(fuwel,2035) welidno(iwel),chu5,chu2,chu3   ! *** chu5 temporary blank
!!$2035       FORMAT(tr1,i3,3(tr8,a12))
!!$        END DO
        IF(solute) THEN
           DO is1=1,ns,9
              is2 = MIN(is1 + 8,ns)
              WRITE(fuwel,2126) 'The following parameters are averages over the time step just completed',  &
                   'Well','Well Datum Solute Component Molality','No.','(mol/kgw)',  &
                   (comp_name(is),is=is1,is2)
              WRITE(fuwel,2326) dash
              DO  iwel=1,nwel
                 IF(wqmeth(iwel) < 0) CYCLE
                 wrcalc=.FALSE.
                 IF(wqmeth(iwel) >= 40) wrcalc=.TRUE.
                 mkt=mwel(iwel,nkswel(iwel))
                 iwfss=INT(SIGN(1.d0,qwm(iwel)))
                 IF(ABS(qwm(iwel)) < 1.e-8_kdp) iwfss=0
                 IF(wqmeth(iwel) > 0) THEN
                    ! ... Production or injection well
                    DO  is=is1,is2
                       u10(is)=cwkt_mol(iwel,is)
                    END DO
                 ELSE
                    ! ... Observation well Q=0 ,WQMETH=0
                    DO  is=is1,is2
                       u10(is)=c_mol(mkt,is)
                    END DO
                 END IF
                 ! ... Load strings for printout
                 IF(iwfss /= 0) THEN
                    DO  is=is1,is2
                       WRITE(chu10a(is),3004) u10(is)
3004                   FORMAT(1pg12.3)
                    END DO
                 END IF
                 WRITE(fuwel,2128) iwel,(chu10a(is),is=is1,is2)
              END DO
           END DO
        END IF
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
2036    FORMAT(//tr10,6A)
        iw1p=-9
110     iw1p=iw1p+10
        iw2p=MIN(iw1p+9,nwel)
        WRITE(fuwel,2037) 'Layer','Well Sequence Number','No.',  &
             (welidno(ip),ip=iw1p,iw2p)
2037    FORMAT(/tr1,a,tr25,a/tr1,a,i9,9I12)
        WRITE(fuwel,2038) dash
2038    FORMAT(tr1,a120)
        DO  k=1,nz
           k1=nz+1-k
           WRITE(chk1,3005) k1
3005       FORMAT(i2)
           l=0
           DO  iwpp=iw1p,iw2p
              l=l+1
              chaprt(l)='            '
              mwk=iw(iwpp)+(jw(iwpp)-1)*nx+(k1-1)*nxy
              IF(lprnt1(mwk) == iwpp) WRITE(chaprt(l),3006) aprnt1(mwk)
3006          FORMAT(1PG12.3)
           END DO
           WRITE(fuwel,2039) chk1,(chaprt(i),i=1,l)
2039       FORMAT(tr2,a2,tr2,10(a12))
        END DO
        IF(iw2p < nwel) GO TO 110
!!$        IF(heat) THEN
!!$           ! ... Well heat injection/production per layer
!!$           DO  iwel=1,nwel
!!$              DO  k=1,nz
!!$                 lwk=(iwel-1)*nz+k
!!$                 aprnt1(lwk)=0.d0
!!$              END DO
!!$           END DO
!!$           DO  iwel=1,nwel
!!$              DO  ks=1,nkswel(iwel)
!!$                 lwks=mwel(iwel,ks)
!!$                 aprnt1(lwks)=cnvmfi*qhlyr(iwel,ks)
!!$              END DO
!!$           END DO
!!$           WRITE(fuwel,2036) 'Current Heat Production(-)/Injection(+) Rates ', &
!!$                'per layer ('//unithf//')'
!!$           iw1p=-9
!!$140        iw1p=iw1p+10
!!$           iw2p=MIN(iw1p+9,nwel)
!!$           WRITE(fuwel,2037) 'Layer','Well Number','No.', (ip,ip=iw1p,iw2p)
!!$           WRITE(fuwel,2038) dash
!!$           DO  k=1,nz
!!$              k1=nz+1-k
!!$              WRITE(chk1,3005) k1
!!$              l=0
!!$              DO  iwpp=iw1p,iw2p
!!$                 l=l+1
!!$                 chaprt(l)='            '
!!$                 mm=nz*(iwpp-1)+k1
!!$                 aprnt4(iwpp)=aprnt1(mm)
!!$                 IF(k1 >= lcbw(iwpp).AND.k1 <= lctw(iwpp))  &
!!$                      WRITE(chaprt(l),3006) aprnt4(iwpp)
!!$              END DO
!!$              WRITE(fuwel,2039) chk1,(chaprt(i),i=1,l)
!!$           END DO
!!$           IF(iw2p < nwel) GO TO 140
!!$        END IF
        IF (solute) THEN
           DO  is=1,ns
              ! ... Well solute injection/production per layer
              lprnt1 = 0
              aprnt1 = 0._kdp
              DO  iwel=1,nwel
                 DO  ks=1,nkswel(iwel)
                    lwks = mwel(iwel,ks)
                    lprnt1(lwks) = iwel
                    aprnt1(lwks) = cnvmfi*qslyr(iwel,ks,is)
                 END DO
              END DO
              WRITE(fuwel,2036) 'Current Solute Production(-)/Injection(+) Rates ',  &
                   'per layer ('//unitm//'/'//TRIM(unittm)//')'
              WRITE(fuwel,2906) 'Component: ',comp_name(is)
2906          FORMAT(/tr10,a,a)
              iw1p=-9
170           iw1p=iw1p+10
              iw2p=MIN(iw1p+9,nwel)
              WRITE(fuwel,2037) 'Layer','Well Number','No.', (welidno(ip),ip=iw1p,iw2p)
              WRITE(fuwel,2038) dash
              DO  k=1,nz
                 k1=nz+1-k
                 WRITE(chk1,3005) k1
                 l=0
                 DO  iwpp=iw1p,iw2p
                    l=l+1
                    chaprt(l)='            '
                    mwk=iw(iwpp)+(jw(iwpp)-1)*nx+(k1-1)*nxy
                    IF(lprnt1(mwk) == iwpp) WRITE(chaprt(l),3006) aprnt1(mwk)
                 END DO
                 WRITE(fuwel,2039) chk1,(chaprt(i),i=1,l)
              END DO
              IF(iw2p < nwel) GO TO 170
           END DO
           WRITE(fuwel,2040)
2040       FORMAT(/tr1,120('-')/)
        ENDIF
        ntprwel = ntprwel+1
     END IF
     IF(prtem) THEN
        DO  iwel=1,nwel
           mkt=mwel(iwel,nkswel(iwel))
           u2=0.d0
           !           hwcell=p(mkt)/(den0*gz)+zwt(iwel)  !***wrong formula
           u1=time
           iwfss=INT(SIGN(1.d0,qwm(iwel)))
           IF(ABS(qwm(iwel)) < 1.e-8_kdp) iwfss=0
           IF(wqmeth(iwel) > 0 .AND. iwfss /= 0) THEN
              ! ... Production or injection well
              !              u2=pwkt(iwel)/(den0*gz)+zwt(iwel)  !***incorrect
              DO  is=1,ns
                 u10(is)=cwkt_mol(iwel,is)
              END DO
           ELSE
              ! ... Observation well Q=0 ,WQMETH=0
              !              u2=p(mkt)/(den0*gz)+zwt(iwel)   !***incorrect
              IF (solute) THEN
                 DO  is=1,ns
                    u10(is)=c_mol(mkt,is)
                 END DO
              ENDIF
           END IF
           ! ... Write to file 'FUPLT' for post processing to temporal plots
           ! Calculate pH of well mixture
           IF (solute) THEN
              CALL calculate_well_ph(u10, ph, alk)
              WRITE(fmt2,"(a,i2,a)") '(tr1,4(1pe15.7,a),i3,a,',ns+2,'(1pe15.7,a))'
              WRITE(fuplt,fmt2) cnvli*xw(iwel),ACHAR(9),cnvli*yw(iwel),ACHAR(9),  &
                   cnvli*zwt(iwel),ACHAR(9),cnvtmi*time,ACHAR(9),iwel,ACHAR(9),  &
                   (u10(is),ACHAR(9),is=1,ns),ph,ACHAR(9), alk, ACHAR(9)
           ENDIF
        END DO
        ntprtem = ntprtem+1
     END IF
     DEALLOCATE (chu10a, chu11a, cwkt_mol, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed"  
        STOP  
     ENDIF
  ENDIF
  IF(prbcf) THEN
     WRITE(fubcf,2001) '*** Output at End of Time Step No. ', itime,' ***'
     WRITE(fubcf,2002) 'Time '//dots,cnvtmi*time,'('//TRIM(unittm)//')'
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
              !                  APRNT2(M)=QHSBC(L)
              !                  APRNT3(M)=QSSBC(L)
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
           CALL prntar(2,aprnt1,lprnt1,fubcf,cnvmfi,24,000)
        END IF
        IF(heat.AND.prthd2) THEN
           WRITE(fubcf,2042) 'Associated Heat   ('//unithf//')'
           CALL prntar(2,aprnt2,lprnt2,fubcf,cnvhfi,24,000)
        END IF
        IF (solute) THEN
           DO  is=1,ns
              DO  l=1,nsbc
                 m=msbc(l)
                 WRITE(cibc,3007) ibc(m)
                 IF(cibc(1:1) == '1') THEN
                    lprnt1(m)=1
                    prthd=.TRUE.
                    aprnt3(m)=qssbc(l,is)
                    IF(cibc(7:7) /= '1') THEN
                       lprnt3(m)=1
                       prthd3=.TRUE.
                    END IF
                 END IF
              END DO
              IF(prthd3) THEN
                 WRITE(fubcf,2042) 'Specified Head B.C.: Associated Solute   (',  &
                      unitm,'/' ,TRIM(unittm),')'
                 WRITE(fubcf,2042) 'Component: ', comp_name(is)
                 CALL prntar(2,aprnt3,lprnt3,fubcf,cnvmfi,24,000)
              END IF
           END DO
        ENDIF
!!$        IF(heat) THEN
!!$           DO  m=1,nxyz
!!$              lprnt1(m)=-1
!!$           END DO
!!$           prthd=.FALSE.
!!$           DO  l=1,nsbc
!!$              m=msbc(l)
!!$              WRITE(cibc,3007) ibc(m)
!!$              IF(cibc(4:4) == '1') THEN
!!$                 !                     APRNT1(M)=QHSBC(L)
!!$                 lprnt1(m)=1
!!$                 prthd=.TRUE.
!!$              END IF
!!$           END DO
!!$           IF(prthd) THEN
!!$              WRITE(fubcf,2042) 'Heat   ('//unithf//')'
!!$              CALL prntar(2,aprnt1,lprnt1,fubcf,cnvhfi,24,000)
!!$           END IF
!!$        END IF
        IF (solute) THEN
           DO  is=1,ns
              DO  m=1,nxyz
                 lprnt1(m)=-1
              END DO
              prthd=.FALSE.
              DO  l=1,nsbc
                 m=msbc(l)
                 WRITE(cibc,3007) ibc(m)
                 IF(cibc(7:7) == '1') THEN
                    aprnt1(m)=qssbc(l,is)
                    lprnt1(m)=1
                    prthd=.TRUE.
                 END IF
              END DO
              IF(prthd) THEN
                 WRITE(fubcf,2042) 'Solute   (',unitm,'/',TRIM(unittm),')'
                 WRITE(fubcf,2042) 'Component: ', comp_name(is)
                 CALL prntar(2,aprnt1,lprnt1,fubcf,cnvmfi,24,000)
              END IF
           END DO
        END IF
     ENDIF
     IF(nfbc > 0) THEN
        WRITE(fubcf,2043)  'Specified Flux B.C.: Flow Rates (at end of time step)',  &
             '(positive is into the region)'
2043    FORMAT(//tr25,a/tr25,a)
        lprnt1 = -1
        !$$        prthd=.FALSE.
        DO  lc=1,nfbc_cells
           m = flux_seg_index(lc)%m
           IF(fresur) THEN
              ls = flux_seg_index(lc)%seg_first
              IF(ifacefbc(ls) == 3 .AND. m >= mtp1) THEN
                 l1 = MOD(m,nxy)
                 IF(l1 == 0) l1 = nxy
                 m = mfsbc(l1)
              END IF
           END IF
           IF (m > 0) THEN
              lprnt1(m) = 1
              !$$              prthd=.TRUE.
              aprnt1(m) = qffbc(lc)
           END IF
        END DO
!!$        IF(erflg) THEN
!!$           WRITE(fuclog,9001) 'EHOFTP interpolation error in WRITE5 ','Specified flux b.c '
!!$9001       FORMAT(tr10,2A,i4)
!!$           ierr(134)=.TRUE.
!!$           errexe=.TRUE.
!!$           RETURN
!!$        END IF
        WRITE(fubcf,2042) 'Fluid Mass   (',unitm,'/',TRIM(unittm),')'
        CALL prntar(2,aprnt1,lprnt1,fubcf,cnvmfi,24,000)
!!$        IF(heat .AND. prthd) THEN
!!$           WRITE(fubcf,2042) 'Associated Advective Heat   ('// unithf//')'
!!$           CALL prntar(2,aprnt2,lprnt1,fubcf,cnvmfi,24,000)
!!$        END IF
        IF (solute) THEN
           DO  iis=1,ns
              DO  lc=1,nfbc_cells
                 m = flux_seg_index(lc)%m
                 IF(.NOT.fresur) THEN
                    lprnt1(m) = 1
                    aprnt3(m) = qsfbc(lc,iis)
                 ELSEIF(fresur) THEN
                    ls = flux_seg_index(lc)%seg_first
                    IF(ifacefbc(ls) == 3 .AND. m >= mtp1) THEN
                       l1 = MOD(m,nxy)
                       IF(l1 == 0) l1 = nxy
                       m = mfsbc(l1)
                    END IF
                    lprnt1(m) = 1
                    prthd=.TRUE.
                    aprnt3(m) = qsfbc(lc,iis)
                 END IF
              END DO
              IF(prthd) THEN
                 WRITE(fubcf,2042) 'Flux B.C.: Associated Advective Solute   ('  &
                      //unitm//'/'//TRIM(unittm)//')'
                 WRITE(fubcf,2042) 'Component: ', comp_name(iis)
                 CALL prntar(2,aprnt3,lprnt1,fubcf,cnvmfi,24,000)
              END IF
           END DO
        ENDIF
!!$        IF(heat) THEN
!!$           DO  m=1,nxyz
!!$              lprnt1(m)=-1
!!$           END DO
!!$           prthd=.FALSE.
!!$           DO  l=1,nfbc
!!$              m=mfbc(l)
!!$              WRITE(cibc,3007) ibc(m)
!!$              ic=INDEX(cibc(4:6),'2')
!!$              IF(ic > 0) THEN
!!$                 lprnt1(m)=1
!!$                 prthd=.TRUE.
!!$                 !                     APRNT1(M)=QHFBC(L)
!!$              END IF
!!$           END DO
!!$           IF(prthd) THEN
!!$              WRITE(fubcf,2042) 'Heat   ('//unithf//')'
!!$              CALL prntar(2,aprnt1,lprnt1,fubcf,cnvhfi,24,000)
!!$           END IF
!!$        END IF
        IF (solute) THEN
           lprnt1 = -1
           prthd = .FALSE.
           DO  iis=1,ns
              DO  lc=1,nfbc_cells
                 m = flux_seg_index(lc)%m
                 WRITE(cibc,3007) ibc(m)
                 ic=INDEX(cibc(7:9),'2')
                 IF(.NOT.fresur) THEN
                    IF(ic > 0) THEN
                       lprnt1(m) = 1
                       prthd=.TRUE.
                       aprnt3(m) = qsfbc(lc,iis)
                    END IF
                 ELSEIF(fresur) THEN
                    ls = flux_seg_index(lc)%seg_last
                    IF(ifacefbc(ls) == 3 .AND. m >= mtp1) THEN
                       l1 = MOD(m,nxy)
                       IF(l1 == 0) l1 = nxy
                       m = mfsbc(l1)
                    END IF
                    IF(ic > 0) THEN
                       lprnt1(m) = 1
                       prthd=.TRUE.
                       aprnt3(m) = qsfbc(lc,iis)
                    END IF
                 END IF
              END DO
              IF(prthd) THEN
                 WRITE(fubcf,2042) 'Solute Flux B.C.: Diffusive   ('  &
                      //unitm//'/'//TRIM(unittm)//')'
                 WRITE(fubcf,2042) 'Component: ', comp_name(iis)
                 CALL prntar(2,aprnt3,lprnt1,fubcf,cnvmfi,24,000)
              END IF
           END DO
        END IF
     END IF
     IF(nlbc > 0) THEN
        WRITE(fubcf,2043) 'Leakage B.C.: Flow Rates ','(positive is into the region)'
        WRITE(fubcf,2042) 'Fluid   (',unitm,'/',TRIM(unittm),')'
        lprnt1 = -1
        DO  lc=1,nlbc
           m = leak_seg_index(lc)%m
           lprnt1(m) = 1
           aprnt1(m) = qflbc(lc)
           !$$                 APRNT2(M)=QHLBC(L)
           !$$                 APRNT3(M)=QSLBC(L)
        END DO
        CALL prntar(2,aprnt1,lprnt1,fubcf,cnvmfi,24,000)
!!$        IF(heat) THEN
!!$           WRITE(fubcf,2042) 'Leakage B.C.: Associated Advective Heat   ('// unithf//')'
!!$           CALL prntar(2,aprnt2,lprnt1,fubcf,cnvhfi,24,000)
!!$        END IF
        IF (solute) THEN
           DO  iis=1,ns
              DO  lc=1,nlbc
                 m = leak_seg_index(lc)%m
                 lprnt1(m) = 1
                 aprnt3(m) = qslbc(lc,iis)
              END DO
              WRITE(fubcf,2042) 'Leakage B.C.: Associated Advective Solute   ('  &
                   //unitm//'/'//TRIM(unittm)//')'
              WRITE(fubcf,2042) 'Component: ', comp_name(iis)
              CALL prntar(2,aprnt3,lprnt1,fubcf,cnvmfi,24,000)
           END DO
        END IF
     END IF
     IF(nrbc > 0) THEN
        WRITE(fubcf,2043) 'River Leakage B.C.: Flow Rates ','(positive is into the region)'
        WRITE(fubcf,2042) 'Fluid   (',unitm,'/',TRIM(unittm),')'
        lprnt4 = -1
        aprnt4 = 0._kdp
        DO  lc=1,nrbc
           m = river_seg_index(lc)%m
           lprnt4(m) = 1
           aprnt4(m) = qfrbc(lc)
        END DO
        CALL prntar(2,aprnt4,lprnt4,fubcf,cnvmfi,24,000)
!!$        IF(heat) THEN
!!$           WRITE(fubcf,2042) 'Associated Advective Heat   ('// unithf//')'
!!$           CALL prntar(2,aprnt2,lprnt1,fubcf,cnvhfi,24,000)
!!$        END IF
        IF (solute) THEN
           DO  iis=1,ns
              DO  lc=1,nrbc
                 m = river_seg_index(lc)%m
                 aprnt3(m) = qsrbc(lc,iis)
              END DO
              WRITE(fubcf,2042) 'River Leakage B.C.: Associated Advective Solute   ('  &
                   //unitm//'/'//TRIM(unittm)//')'
              WRITE(fubcf,2042) 'Component: ', comp_name(iis)
              CALL prntar(2,aprnt3,lprnt4,fubcf,cnvmfi,24,000)
           END DO
        END IF
     END IF
     IF(ndbc > 0) THEN
        WRITE(fubcf,2043) 'Drain Leakage B.C.: Flow Rates ','(positive is into the region)'
        WRITE(fubcf,2042) 'Fluid   (',unitm,'/',TRIM(unittm),')'
        lprnt4 = -1
        aprnt4 = 0._kdp
        DO  lc=1,ndbc
           m = drain_seg_index(lc)%m
           lprnt4(m) = 1
           aprnt4(m) = qfdbc(lc)
        END DO
        CALL prntar(2,aprnt4,lprnt4,fubcf,cnvmfi,24,000)
!!$        IF(heat) THEN
!!$           WRITE(fubcf,2042) 'Associated Advective Heat   ('// unithf//')'
!!$           CALL prntar(2,aprnt2,lprnt1,fubcf,cnvhfi,24,000)
!!$        END IF
        IF (solute) THEN
           DO  iis=1,ns
              DO  lc=1,ndbc
                 m = drain_seg_index(lc)%m
                 aprnt3(m) = qsdbc(lc,iis)
              END DO
              WRITE(fubcf,2042) 'Drain Leakage B.C.: Associated Advective Solute   ('  &
                   //unitm//'/'//TRIM(unittm)//')'
              WRITE(fubcf,2042) 'Component: ', comp_name(iis)
              CALL prntar(2,aprnt3,lprnt4,fubcf,cnvmfi,24,000)
           END DO
        END IF
     END IF
!!$     IF(netbc > 0) THEN
!!$        !...**not available for PHAST
!!$        WRITE(fubcf,2043) 'Evapotranspiration Flow Rates ','(positive is into the region)'
!!$        WRITE(fubcf,2042) 'Fluid   (',unitm,'/',TRIM(unittm),')'
!!$        DO  m=1,nxyz
!!$           lprnt1(m)=-1
!!$        END DO
!!$        DO  l=1,netbc
!!$           m=metbc(l)
!!$           ! ... Locate the flux at the cell containing the free-surface
!!$           l1=MOD(m,nxy)
!!$           IF(l1 == 0) l1=nxy
!!$           m=mfsbc(l1)
!!$           aprnt1(m)=qfetbc(l)
!!$           !               APRNT2(M)=QHETBC(L)
!!$           !               APRNT3(M)=QSETBC(L)
!!$           lprnt1(m)=1
!!$        END DO
!!$        CALL prntar(2,aprnt1,lprnt1,fubcf,cnvmfi,24,000)
!!$        IF(heat) THEN
!!$           WRITE(fubcf,2042) 'Associated Advective Heat   ('// unithf//')'
!!$           CALL prntar(2,aprnt2,lprnt1,fubcf,cnvhfi,24,000)
!!$        END IF
!!$        IF(solute) THEN
!!$           WRITE(fubcf,2042) 'Associated Advective Solute   (',unitm,'/',TRIM(unittm),')'
!!$           CALL prntar(2,aprnt3,lprnt1,fubcf,cnvmfi,24,000)
!!$        END IF
!!$     END IF
!!$     IF(naifc > 0) THEN
!!$        !... ** not available for PHAST
!!$        WRITE(fubcf,2043) 'Aquifer Influence Function Flow Rates',  &
!!$             '(positive is into the region)'
!!$        WRITE(fubcf,2042) 'Fluid   (',unitm,'/',TRIM(unittm),')'
!!$        DO  m=1,nxyz
!!$           aprnt1(m)=0.d0
!!$           aprnt2(m)=0.d0
!!$           aprnt3(m)=0.d0
!!$           lprnt1(m)=-1
!!$        END DO
!!$        DO  l=1,naifc
!!$           m=maifc(l)
!!$           aprnt1(m)=aprnt1(m)+qfaif(l)
!!$           !               APRNT2(M)=APRNT2(M)+QHAIF(L)
!!$           !               APRNT3(M)=APRNT3(M)+QSAIF(L)
!!$           lprnt1(m)=1
!!$        END DO
!!$        CALL prntar(2,aprnt1,lprnt1,fubcf,cnvmfi,24,000)
!!$        IF(heat) THEN
!!$           WRITE(fubcf,2042) 'Associated Advective Heat   ('// unithf//')'
!!$           CALL prntar(2,aprnt2,lprnt1,fubcf,cnvhfi,24,000)
!!$        END IF
!!$        IF(solute) THEN
!!$           WRITE(fubcf,2042) 'Associated Advective Solute   (',unitm,'/',TRIM(unittm),')'
!!$           CALL prntar(2,aprnt3,lprnt1,fubcf,cnvmfi,24,000)
!!$        END IF
!!$     END IF
!!$     IF(nhcbc > 0) THEN
!!$        !... **not available for PHAST
!!$        WRITE(fubcf,2043) 'Heat Conduction B.C. Heat Flow Rates ',  &
!!$             '(positive is into the region)'
!!$        DO  m=1,nxyz
!!$           lprnt1(m)=-1
!!$        END DO
!!$        DO  l=1,nhcbc
!!$           m=mhcbc(l)
!!$           aprnt1(m)=qhcbc(l)
!!$           lprnt1(m)=1
!!$        END DO
!!$        WRITE(fubcf,2042) 'Heat   ('//unithf//')'
!!$        CALL prntar(2,aprnt1,lprnt1,fubcf,cnvhfi,24,000)
!!$        WRITE(fubcf,2043) 'Heat Conduction B.C. Temperature Profiles ', &
!!$             'Rows are normal to the boundary '
!!$        WRITE(fubcf,2042) 'Temperature  (Deg.'//unitt//')'
!!$        WRITE(fubcf,2044) 'B.C. Node No.'
!!$2044    FORMAT(tr1,a)
!!$        DO  l=1,nhcbc
!!$           WRITE(fubcf,2045) l
!!$2045       FORMAT(i3)
!!$           lll=(l-1)*nhcn
!!$           DO  ll=1,nhcn
!!$              aprnt1(ll)=cnvt1i*thcbc(lll+ll)+cnvt2i
!!$              lprnt1(ll)=1
!!$           END DO
!!$           CALL prntar(1,aprnt1,lprnt1,fubcf,cnv,12,nhcn)
!!$        END DO
!!$     END IF
     ntprbcf = ntprbcf+1
  END IF
  ! ... Write contour map data
  IF(solute .AND. cntmapc) THEN
     IF(prmapc) THEN
        ! ... Write component concentrations to file 'FUPMAP' for visualization
        WRITE(fmt4,"(a,i2,a)") '(tr1,4(1pg11.3,a),i3,a,',ns,'(1pg11.3,a))'
        DO m=1,nxyz
           IF(ibc(m) /= -1) THEN
              CALL mtoijk(m,i,j,k,nx,ny)
              IF(frac(m) < 0.0001_kdp) THEN
                 indx = 0
                 WRITE(fupmap,fmt4) cnvli*x(i),ACHAR(9),cnvli*y(j),ACHAR(9),cnvli*z(k),  &
                      ACHAR(9),cnvtmi*time,ACHAR(9),indx,ACHAR(9)
              ELSE
                 indx = 1
                 WRITE(fupmap,fmt4) cnvli*x(i),ACHAR(9),cnvli*y(j),ACHAR(9),cnvli*z(k),  &
                      ACHAR(9),cnvtmi*time,ACHAR(9),indx,ACHAR(9),(c_mol(m,is),ACHAR(9),is=1,ns)
              END IF
           END IF
        END DO
!!$        WRITE(fupmap,5002) ' Time Step No. ',itime,' Time ',cnvtmi*time,' ('//TRIM(unittm)//')'
!!$5002    FORMAT(a,i5,a,1PG12.3,3A)
!!$        DO  is=1,ns
!!$           WRITE(fupmap,5003) 'Molality (mol/kgw)'//'   Component: '//comp_name(is)
!!$5003    FORMAT(tr30,2a)
!!$           DO  m=1,nxyz
!!$              aprnt1(m)=c_mol(m,is)
!!$           END DO
!!$           WRITE(fupmap,5006) (aprnt1(m),m=1,nxyz)
!!$5006       FORMAT(11(1pe11.3))
!!$        END DO
        ntprmapcomp = ntprmapcomp+1
     END IF
  END IF
  IF(cntmaph) THEN
     IF(prmaph .AND. .NOT.steady_flow) THEN
        ! ... Write head to file 'FUPMP2' for visualization
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
8003             FORMAT(4(1pg15.6,a),i5,a,1pg15.6,a)
              ENDIF
           END IF
        END DO
!!$        ! ... Write head to file 'FUPMP2' for screen or plotter maps
!!$        WRITE(fupmp2,5002) ' Time Step No. ',itime,' Time ',cnvtmi*time,' ('//TRIM(unittm)//')'
!!$        if(fresur) then
!!$           WRITE(fupmp2,5003) 'Free surface index array'
!!$           WRITE(fupmp2,5007) (mfsbc(m),m=1,nxy)
!!$5007       FORMAT(12I10)
!!$        endif
!!$        WRITE(fupmp2,5003) 'Head '
!!$5003    FORMAT(tr30,2a)
!!$        WRITE(fupmp2,5004) (cnvli*hdprnt(m),m=1,nxyz)
!!$5004    FORMAT(9(1PG14.6))
        ntprmaphead = ntprmaphead+1
     END IF
  END IF
!!$  IF(prbcf) THEN
!!$     WRITE(fubnfr,5002) ' Time Step No. ',itime,' Time ',cnvtmi*time,' (',TRIM(unittm),')'
!!$     IF(nsbc > 0) THEN
!!$        WRITE(fubnfr,2046)  &
!!$             'Specified Pressure, Temperature, or Mass Fraction ', 'B.C. Flow Rates'
!!$2046    FORMAT(tr1,2A)
!!$        WRITE(fubnfr,5008) (cnvmfi*qfsbc(l),l=1,nsbc)
!!$5008    FORMAT(9(1PE13.5))
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Heat Flow or Associated Heat   '
!!$           WRITE(fubnfr,5008) (cnvhfi*qhsbc(l),l=1,nsbc)
!!$        END IF
!!$        DO  is=1,ns
!!$           WRITE(fubnfr,2046) 'Solute Flow or Associated Solute  '//'Component: '//comp_name(is)
!!$           WRITE(fubnfr,5008) (cnvmfi*qssbc(l,is),l=1,nsbc)
!!$        END DO
!!$        WRITE(fubnfr,2046)  &
!!$             'Specified Pressure, Temperature, or Mass Fraction ',  &
!!$             'B.C. Cumulative Cell Flow Amounts - Fluid Mass'
!!$        WRITE(fubnfr,5008) (cnvmi*ccfsb(l),l=1,nsbc)
!!$        WRITE(fubnfr,2046) 'Specified Pressure, Temperature, or Mass Fraction ',  &
!!$             'B.C. Cumulative Cell Flow Amounts - Fluid Volume'
!!$        WRITE(fubnfr,5008) (cnvl3i*ccfvsb(l),l=1,nsbc)
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Heat Flow or Associated Heat    ',  &
!!$                'Cumulative Cell Heat Flow Amounts'
!!$           WRITE(fubnfr,5008) (cnvhei*cchsb(l),l=1,nsbc)
!!$        END IF
!!$        DO  is=1,ns
!!$           WRITE(fubnfr,2046) 'Solute Flow or Associated Solute  ',  &
!!$                'Cumulative Cell Solute Flow Amounts'// 'Component: '//comp_name(is)
!!$           WRITE(fubnfr,5008) (cnvmi*ccssb(l,is),l=1,nsbc)
!!$        END DO
!!$     END IF
!!$     IF(nfbc > 0) THEN
!!$        WRITE(fubnfr,2046) 'Specified Flux B.C. Flow Rates '
!!$        DO  l=1,nfbc
!!$           m=mfbc(l)
!!$           IF(qfbcv(l) > 0.) THEN
!!$              aprnt1(l)=denfbc(l)*qfbcv(l)
!!$              IF(heat) aprnt2(l)=denfbc(l)*qfbcv(l)*ehoftp(tflx(l), p(m),erflg)
!!$              !                  APRNT3(L)=DENFBC(L)*QFBCV(L)*cfbc(L)
!!$           ELSE
!!$              aprnt1(l)=den(m)*qfbcv(l)
!!$              !              aprnt2(l)=den(m)*qfbcv(l)*eh(m)
!!$              !                  APRNT3(L)=DEN(M)*QFBCV(L)*C(M)
!!$           END IF
!!$        END DO
!!$        WRITE(fubnfr,2046) 'Fluid Mass '
!!$        WRITE(fubnfr,5008) (cnvmfi*aprnt1(l),l=1,nfbc)
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Associated Advective Heat '
!!$           WRITE(fubnfr,5008) (cnvhfi*aprnt2(l),l=1,nfbc)
!!$        END IF
!!$        DO  is=1,ns
!!$           DO  l=1,nfbc
!!$              m=mfbc(l)
!!$              IF(qfbcv(l) > 0.) THEN
!!$                 aprnt3(l)=denfbc(l)*qfbcv(l)*cfbc(l,is)
!!$              ELSE
!!$                 aprnt3(l)=den(m)*qfbcv(l)*c(m,is)
!!$              END IF
!!$           END DO
!!$           WRITE(fubnfr,2046) 'Associated Advective Solute '//'Component: '//comp_name(is)
!!$           WRITE(fubnfr,5008) (cnvmfi*aprnt3(l),l=1,nfbc)
!!$        END DO
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Heat '
!!$           WRITE(fubnfr,5008) (cnvhfi*qhfbc(l),l=1,nfbc)
!!$        END IF
!!$        DO  is=1,ns
!!$           WRITE(fubnfr,2046) 'Solute '// 'Component: '//comp_name(is)
!!$           WRITE(fubnfr,5008) (cnvmfi*qsfbc(l,is),l=1,nfbc)
!!$        END DO
!!$        WRITE(fubnfr,2046) 'Specified Flux B.C. ',  &
!!$             'Cumulative Cell Flow Amounts - Fluid Mass'
!!$        WRITE(fubnfr,5008) (cnvmi*ccffb(l),l=1,nfbc)
!!$        WRITE(fubnfr,2046) 'Specified Flux B.C. ',  &
!!$             'Cumulative Cell Flow Amounts - Fluid Volume'
!!$        WRITE(fubnfr,5008) (cnvl3i*ccfvfb(l),l=1,nfbc)
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Heat Flow or Associated Heat    ', &
!!$                'Cumulative Cell Heat Flow Amounts'
!!$           WRITE(fubnfr,5008) (cnvhei*cchfb(l),l=1,nfbc)
!!$        END IF
!!$        DO  is=1,ns
!!$           WRITE(fubnfr,2046) 'Solute Flow or Associated Solute  ',  &
!!$                'Cumulative Cell Solute Flow Amounts'// 'Component: '//comp_name(is)
!!$           WRITE(fubnfr,5008) (cnvmi*ccsfb(l,is),l=1,nfbc)
!!$        END DO
!!$     END IF
!!$     IF(nlbc > 0) THEN
!!$        WRITE(fubnfr,2046) 'Aquifer Leakage Flow Rates '
!!$        WRITE(fubnfr,5008) (cnvmfi*qflbc(l),l=1,nlbc)
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Associated Advective Heat '
!!$           WRITE(fubnfr,5008) (cnvhfi*qhlbc(l),l=1,nlbc)
!!$        END IF
!!$        DO  is=1,ns
!!$           WRITE(fubnfr,2046) 'Associated Advective Solute '
!!$           WRITE(fubnfr,5008) (cnvmfi*qslbc(l,is),l=1,nlbc)
!!$        END DO
!!$        WRITE(fubnfr,2046) 'Leakage B.C. ',  &
!!$             'Cumulative Cell Flow Amounts - Fluid Mass'
!!$        WRITE(fubnfr,5008) (cnvmi*ccflb(l),l=1,nlbc)
!!$        WRITE(fubnfr,2046) 'Leakage B.C. ',  &
!!$             'Cumulative Cell Flow Amounts - Fluid Volume'
!!$        WRITE(fubnfr,5008) (cnvl3i*ccfvlb(l),l=1,nlbc)
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Associated Advective Heat ',  &
!!$                'Cumulative Cell Heat Flow Amounts'
!!$           WRITE(fubnfr,5008) (cnvhei*cchlb(l),l=1,nlbc)
!!$        END IF
!!$        DO  is=1,ns
!!$           WRITE(fubnfr,2046) 'Associated Advective Solute  ',  &
!!$                'Cumulative Cell Solute Flow Amounts'// 'Component: '//comp_name(is)
!!$           WRITE(fubnfr,5008) (cnvmi*ccslb(l,is),l=1,nlbc)
!!$        END DO
!!$     END IF
!!$     IF(nrbc > 0) THEN
!!$        WRITE(fubnfr,2046) 'River Leakage Flow Rates '
!!$        WRITE(fubnfr,5008) (cnvmfi*qfrbc(l),l=1,nrbc)
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Associated Advective Heat '
!!$           WRITE(fubnfr,5008) (cnvhfi*qhrbc(l),l=1,nrbc)
!!$        END IF
!!$        DO  is=1,ns
!!$           WRITE(fubnfr,2046) 'Associated Advective Solute '
!!$           WRITE(fubnfr,5008) (cnvmfi*qsrbc(l,is),l=1,nrbc)
!!$        END DO
!!$        WRITE(fubnfr,2046) 'River Leakage B.C. ',  &
!!$             'Cumulative Cell Flow Amounts - Fluid Mass'
!!$        WRITE(fubnfr,5008) (cnvmi*ccfrb(l),l=1,nrbc)
!!$        WRITE(fubnfr,2046) 'River Leakage B.C. ',  &
!!$             'Cumulative Cell Flow Amounts - Fluid Volume'
!!$        WRITE(fubnfr,5008) (cnvl3i*ccfvrb(l),l=1,nrbc)
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Associated Advective Heat ',  &
!!$                'Cumulative Cell Heat Flow Amounts'
!!$           WRITE(fubnfr,5008) (cnvhei*cchrb(l),l=1,nrbc)
!!$        END IF
!!$        DO  is=1,ns
!!$           WRITE(fubnfr,2046) 'Associated Advective Solute  ',  &
!!$                'Cumulative Cell Solute Flow Amounts'// 'Component: '//comp_name(is)
!!$           WRITE(fubnfr,5008) (cnvmi*ccsrb(l,is),l=1,nrbc)
!!$        END DO
!!$     END IF
!!$     !         IF(NETBC.GT.0) THEN
!!$     !... *** not implemented in PHAST
!!$     !            WRITE(FUBNFR,2046) 'Evapotranspiration Flow Rates '
!!$     !            WRITE(FUBNFR,5008) (CNVMFI*QFETBC(L),L=1,NETBC)
!!$     !            IF(HEAT) THEN
!!$     !               WRITE(FUBNFR,2046) 'Associated Advective Heat '
!!$     !               WRITE(FUBNFR,5008) (CNVHFI*QHETBC(L),L=1,NETBC)
!!$     !            ENDIF
!!$     !            IF(SOLUTE) THEN
!!$     !               WRITE(FUBNFR,2046) 'Associated Advective Solute '
!!$     !               WRITE(FUBNFR,5008) (CNVMFI*QSETBC(L),L=1,NETBC)
!!$     !            ENDIF
!!$     !            WRITE(FUBNFR,2046)
!!$     !     &           'Evapotranspiration B.C. ',
!!$     !     &           'Cumulative Cell Flow Amounts - Fluid Mass'
!!$     !            WRITE(FUBNFR,5008) (CNVMI*CCFETB(L),L=1,NETBC)
!!$     !            WRITE(FUBNFR,2046)
!!$     !     &           'Evapotranspiration B.C. ',
!!$     !     &           'Cumulative Cell Flow Amounts - Fluid Volume'
!!$     !            WRITE(FUBNFR,5008) (CNVL3I*CCFVEB(L),L=1,NETBC)
!!$     !            IF(HEAT) THEN
!!$     !               WRITE(FUBNFR,2046) 'Associated Advective Heat    ',
!!$     !     &              'Cumulative Cell Heat Flow Amounts'
!!$     !               WRITE(FUBNFR,5008) (CNVHEI*CCHETB(L),L=1,NETBC)
!!$     !            ENDIF
!!$     !            IF(SOLUTE) THEN
!!$     !               WRITE(FUBNFR,2046) 'Associated Advective Solute  ',
!!$     !     &              'Cumulative Cell Solute Flow Amounts'
!!$     !               WRITE(FUBNFR,5008) (CNVMI*CCSETB(L),L=1,NETBC)
!!$     !            ENDIF
!!$     !         ENDIF
!!$     IF(naifc > 0) THEN
!!$        !.. ** not implemented in PHAST
!!$        WRITE(fubnfr,2046) 'Aquifer Influence Function Flow Rates'
!!$        WRITE(fubnfr,5008) (cnvmfi*qfaif(l),l=1,naifc)
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Associated Advective Heat '
!!$           WRITE(fubnfr,5008) (cnvhfi*qhaif(l),l=1,naifc)
!!$        END IF
!!$        IF(solute) THEN
!!$           WRITE(fubnfr,2046) 'Associated Advective Solute '
!!$           !               WRITE(FUBNFR,5008) (CNVMFI*QSAIF(L),L=1,NAIFC)
!!$        END IF
!!$        WRITE(fubnfr,2046) 'Aquifer Influence Function B.C. ',  &
!!$             'Cumulative Cell Flow Amounts - Fluid Mass'
!!$        WRITE(fubnfr,5008) (cnvmi*ccfaif(l),l=1,naifc)
!!$        WRITE(fubnfr,2046) 'Aquifer Influence Function B.C. ',  &
!!$             'Cumulative Cell Flow Amounts - Fluid Volume'
!!$        WRITE(fubnfr,5008) (cnvl3i*ccfvai(l),l=1,naifc)
!!$        IF(heat) THEN
!!$           WRITE(fubnfr,2046) 'Associated Advective Heat ',  &
!!$                'Cumulative Cell Heat Flow Amounts'
!!$           WRITE(fubnfr,5008) (cnvhei*cchaif(l),l=1,naifc)
!!$        END IF
!!$        IF(solute) THEN
!!$           WRITE(fubnfr,2046) 'Associated Advective Solute  ',  &
!!$                'Cumulative Cell Solute Flow Amounts'
!!$           WRITE(fubnfr,5008) (cnvmi*ccsaif(l),l=1,naifc)
!!$        END IF
!!$     END IF
  WRITE(logline1,3001) 'Finished time step no. ',itime,'; Time '//dots(1:30),cnvtmi*time,'('//TRIM(unittm)//')'
3001 FORMAT(a,I6,a,1PG18.9,tr2,a)
  CALL screenprt_c(logline1)
!!$     IF(nhcbc > 0) THEN
!!$        !... ** not implemented in PHAST
!!$        WRITE(fubnfr,2046) 'Heat Conduction B.C. Heat Flow Rates '
!!$        WRITE(fubnfr,5008) (cnvhfi*qhcbc(l),l=1,nhcbc)
!!$        WRITE(fubnfr,2046)' Heat    ', 'Cumulative Cell Heat Flow Amounts'
!!$        WRITE(fubnfr,5008) (cnvhei*cchhcb(l),l=1,nhcbc)
!!$     END IF
!!$  END IF
  ! ... Set the next time for printout if by user time units
!!$440 continue
!!$  timprtnxt=MIN(utimchg,timprbcf, timprcpd, timprgfb, &
!!$       timprhdfh, timprhdfv, timprhdfcph,  &
!!$       timprkd, timprmapc, timprmaph, timprmapv, &
!!$       timprp, timprc, timprcphrq, timprfchem, timprslm, timprtem, timprvel, timprwel)
  DEALLOCATE (lprnt3, lprnt4,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array allocation failed: write5"  
  ENDIF
END SUBROUTINE write5
