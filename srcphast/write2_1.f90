SUBROUTINE write2_1
  ! ... Write the parameter data after READ2
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcc
  USE mcch
  USE mcg
  USE mcn
  USE mcp
  USE mcs
  USE mct
!!$  USE mcv
  USE mcw
  USE mg2
  USE phys_const
  IMPLICIT NONE
  INCLUDE 'ifwr.inc'
  CHARACTER(LEN=4) :: uword
  CHARACTER(LEN=7) :: cw1
  CHARACTER(LEN=7) :: cw0
  CHARACTER(LEN=11) :: chu2, chu3
  CHARACTER(LEN=49), DIMENSION(0:5) :: wclbl1 = (/  &
       'Observation Well                                 ', &
       'Specified Flow Rate                              ', &
       'Specified Pressure at Well Datum                 ', &
       'Specified Flow Rate,Limiting Pressure at Datum   ', &
       'Specified Pressure at Surface                    ', &
       'Specified Flow Rate, Limiting Pressure at Surface'/)
  CHARACTER(LEN=49), DIMENSION(0:2) :: wclbl2 = (/  &
       '                                                 ', &
       'Allocation by Mobility Times Pressure Difference ', &
       'Allocation by Mobility                           '/)
  CHARACTER(LEN=40), DIMENSION(0:2) :: wclbl3 = (/  &
       '                                        ', &
       'Explicit Layer Rates                    ', &
       'Semi-Implicit Layer Rates               '/)
  REAL(kind=kdp) :: ucnvi
  INTEGER :: i, ifu, iwel, iwq1, iwq2, iwq3, j,  &
       jprptc, k, ks, kwb, kwt, l, lc, ls, m, mb, mt, nks
  ! ... Set the unit numbers for node point output
  INTEGER, DIMENSION(12), PARAMETER :: fu =(/16,21,22,23,26,27,0,0,0,0,0,0/)
  INTEGER :: nr
  REAL(kind=kdp), PARAMETER :: cnv = 1._kdp
  REAL(KIND=kdp) :: ph
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: aprnt5
  INTEGER :: a_err, da_err
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  ALLOCATE (aprnt5(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: write2_1"  
     STOP  
  ENDIF
  !...
  mflbl=' mass '
  rxlbl='X'
  nr = nx
  ! ... Problem dimension information
  WRITE(fulp,2001) 'Number of porous media zones '//dots,' NPMZ . ',npmz,  &
       'Number of specified pressure or mass fraction b.c. '//dots, ' NSBC . ', &
       nsbc,  &
       'Number of specified flux b.c. cells '//dots, ' NFBC . ',nfbc,  &
       'Number of leakage cells '//dots,' NLBC . ',nlbc,  &
       'Number of river leakage cells '//dots,' NRBC . ',nrbc,  &
       !     &     'Number of aquifer influence function cells '//DOTS,
       !     &     ' NAIFC  ',NAIFC,
       !     &     'Number of heat conduction b.c. cells '//DOTS,
       !     &     ' NHCBC  ',NHCBC,
       !     &     'Nodes outside region for each heat conduction b.c. cell '//
       !     &     DOTS,
       !     &     ' NHCN . ',NHCN,  &
  'Number of wells '//dots,' NWEL . ',nwel
2001 FORMAT(/(tr10,a65,a,i6))
!!$  WRITE(logline1,5009) 'Number of porous media zones '//dots,' NPMZ . ',npmz
!!$  WRITE(logline2,5009)        'Number of specified pressure or '//  &
!!$       'mass fraction b.c. '//dots, ' NSBC . ',nsbc
!!$  WRITE(logline3,5009) 'Number of specified flux b.c. cells '//dots, ' NFBC . ',nfbc
!!$  WRITE(logline4,5009) 'Number of leakage cells '//dots,' NLBC . ',nlbc
!!$  WRITE(logline5,5009) 'Number of river leakage cells '//dots,' NRBC . ',nrbc
!!$  WRITE(logline6,5009) 'Number of wells '//dots,' NWEL . ',nwel
!!$5009 format(a65,a,i6)
!!$  call logprt_c(logline1)
!!$  call logprt_c(logline2)
!!$  call logprt_c(logline3)
!!$  call logprt_c(logline4)
!!$  call logprt_c(logline5)
!!$  call logprt_c(logline6)
  IF(.NOT.restrt) THEN
     IF(slmeth == 1) THEN
        WRITE(fulp,2002) 'A4 array dimension requirement (D4 direct solver)'//  &
             dots,' NRAL . ',nral,'elements'
        WRITE(logline1,5001) 'A4 array dimension requirement (D4 direct solver)'//  &
             dots,' NRAL . ',nral,' elements'
        WRITE(logline2,5001) 'Primary storage requirement (D4 direct solver)'//  &
             dots,' NPRIST ',nprist,' elements'
        WRITE(logline3,5001) 'Overhead storage requirement (D4 direct solver)'//  &
             dots,' NOHST .',nohst,' elements'
        call logprt_c(logline1)
        call logprt_c(logline2)
        call logprt_c(logline3)
     ELSE IF(slmeth == 3) THEN
        WRITE(fulp,2002) 'A4 array dimension requirement (RBGCG iterative solver)'//  &
             dots,' NRAL . ',nral,'elements'
        WRITE(logline1,5001) 'A4 array dimension requirement (RBGCG iterative solver)'//  &
             dots,' NRAL . ',nral,' elements'
        WRITE(logline2,5001) 'Primary storage requirement (RBGCG iterative solver)'//  &
             dots,' NPRIST ',nprist,' elements'
        WRITE(logline3,5001) 'Overhead storage requirement (RBGCG iterative solver)'//  &
             dots,' NOHST .',nohst,' elements'
        call logprt_c(logline1)
        call logprt_c(logline2)
        call logprt_c(logline3)
     ELSE IF(slmeth >= 5) THEN
        WRITE(fulp,2002) 'A4 array dimension requirement (D4ZGCG iterative '//  &
             'solver)'//dots,' NRAL . ',nral,'elements'
        WRITE(logline1,5001) 'A4 array dimension requirement (D4ZGCG iterative solver)'//  &
             dots,' NRAL . ',nral,' elements'
        WRITE(logline2,5001) 'Primary storage requirement (D4ZGCG iterative solver)'//  &
             dots,' NPRIST ',nprist,' elements'
        WRITE(logline3,5001) 'Overhead storage requirement (D4ZGCG iterative solver)'//  &
             dots,' NOHST .',nohst,' elements'
        call logprt_c(logline1)
        call logprt_c(logline2)
        call logprt_c(logline3)
     END IF
  END IF
2002 FORMAT(/(tr10,a65,a,i8,tr1,a))
5001 FORMAT(a65,a,i8,a)
  IF(errexi) WRITE(fulp,9001)
9001 FORMAT(/tr10,'**This is an abbreviated printout due to error ',  &
       'exit conditions.'/tr15, 'Data calculated in INIT2 are omitted.**')
  WRITE(fulp,2003) dash
2003 FORMAT(tr1,a120)
!!$  WRITE(logline3,5103) dash
!!$5103 FORMAT(a120)
!!$  call logprt_c(logline3)
  WRITE(fulp,2004) '***  Static Data ***'
2004 FORMAT(//tr30,a)
  ! ... Spatial mesh information
  DO  ifu=1,6
     IF(.NOT.cylind) THEN
        WRITE(fu(ifu),2005) rxlbl//'-Direction Node Coordinates    (',TRIM(unitl),')'
2005    FORMAT(//tr30,4A)
        CALL prntar(1,x,ibc,fu(ifu),cnvli,12,nx)
        WRITE(fu(ifu),2005) 'Y-Direction Node Coordinates   (' ,TRIM(unitl),')'
        CALL prntar(1,y,ibc,fu(ifu),cnvli,12,ny)
     ELSE IF(cylind) THEN
        ! ... Cylindrical aquifer geometry
        WRITE(fu(ifu),2006) cnvli*x(1),TRIM(unitl),cnvli*x(nr),TRIM(unitl)
2006    FORMAT(/tr25,'** Cylindrical (r-z) Coordinate Data **'/tr20,  &
             'Aquifer interior radius .............. RINT . ',f12.3, tr2,'(',a,')'/tr20,  &
             'Aquifer exterior radius .............. REXT . ',f10.1, tr4,'(',a,')')
        rxlbl='R'
        WRITE(fu(ifu),2005) rxlbl//'-Direction Node Coordinates  (', TRIM(unitl),')'
        CALL prntar(1,x,ibc,fu(ifu),cnvli,12,nr)
        WRITE(fu(ifu),2005) rxlbl// '-Coordinate Cell Boundary Locations ',  &
             '(between node(I) and node(I+1))   (',TRIM(unitl),')'
        CALL prntar(1,rm,ibc,fu(ifu),cnvli,112,nr-1)
     END IF
     WRITE(fu(ifu),2005) 'Z-Direction Node Coordinates   (',TRIM(unitl), ')'
     CALL prntar(1,z,ibc,fu(ifu),cnvli,12,nz)
  END DO
  IF(.NOT.tilt) WRITE(fulp,2005) 'Z-Axis is Positive Vertically ', 'Upward'
  IF(tilt) WRITE(fulp,2007) thetxz,thetyz,thetzz
2007 FORMAT(//30X,'Angle between X-axis and vertical ...........',f10.1,2X,'(Deg.)'/30X,  &
       'Angle between Y-axis and vertical ...........',f10.1,2X, '(Deg.)'/30X,  &
       'Angle between Z-axis and vertical ...........', f10.1,2X,'(Deg.)')
  IF(prtpmp) THEN
     ! ... Print porous media zones
     WRITE(fulp,2008)
2008 FORMAT(//tr40,'** Aquifer Properties  **  (read echo)'/ tr35,'Region',  &
          tr45,'Porous Medium'/tr20,  &
          'X1         Y1         Z1          X2         Y2         Z2',  &
          tr8,'Zone Index'/tr8,90('-'))
     WRITE(fulp,2009) (cnvli*x(i1z(i)),cnvli*y(j1z(i)),cnvli*z(k1z(i)),  &
          cnvli*x(i2z(i)),cnvli*y(j2z(i)),cnvli*z(k2z(i)),i,i=1,npmz)
2009 FORMAT((tr14,6(1PG11.3),tr5,i5))
     IF(errexi) GO TO 30
     WRITE(fulp,2010)
2010 FORMAT(//tr30,'*** Porous Media Properties ***'/)
     WRITE(fulp,2013) '*** Properties by Porous Medium Zone ***'
2013 FORMAT(/tr30,a)
     kx = kxx*denf0*grav*86400./abs(visfac)
     ky = kyy*denf0*grav*86400./abs(visfac)
     kz = kzz*denf0*grav*86400./abs(visfac)
     WRITE(fulp,2005) rxlbl//'-Direction Hydraulic Conductivities   (',TRIM(unitl),'/d)'
     CALL prntar(1,kx,ibc,fulp,cnvli,24,npmz)
     IF(.NOT.cylind) THEN
        WRITE(fulp,2005) 'Y-Direction Hydraulic Conductivities   (',TRIM(unitl),'/d)'
        CALL prntar(1,ky,ibc,fulp,cnvli,24,npmz)
     END IF
     WRITE(fulp,2005) 'Z-Direction Hydraulic Conductivities   (',TRIM(unitl),'/d)'
     CALL prntar(1,kz,ibc,fulp,cnvli,24,npmz)
     WRITE(fulp,2011)
2011 FORMAT(/40X,'Porosity (-)')
     CALL prntar(1,poros,ibc,fulp,cnv,24,npmz)
30   CONTINUE
     IF(heat .OR. solute) THEN
        WRITE(fulp,2014) 'Longitudinal Dispersivity   (',TRIM(unitl),')'
2014    FORMAT(/tr30,8A)
        CALL prntar(1,alphl,ibc,fulp,cnvli,24,npmz)
        WRITE(fulp,2014) 'Transverse Dispersivity; Horizontal   (',TRIM(unitl),')'
        CALL prntar(1,alphth,ibc,fulp,cnvli,24,npmz)
        WRITE(fulp,2014) 'Transverse Dispersivity; Vertical   (',TRIM(unitl),')'
        CALL prntar(1,alphtv,ibc,fulp,cnvli,24,npmz)
     END IF
     IF(solute) THEN
        WRITE(fulp,2015) 'Molecular diffusivity-tortuosity product '//  &
             dots,' DM ...',cnvdfi*dm,'(',TRIM(unitl),'^2/',unittm,')'
2015    FORMAT(/tr25,a60,a,1PG10.3,tr2,5A/tr25,a60,a,1PG10.3,tr2,3A)
     END IF
     WRITE(fulp,2017) 'Atmospheric pressure (absolute) '//dots, ' PAATM ',  &
          cnvpi*paatm,'(',unitp,')'
     !     &     'Reference pressure for enthalpy '//DOTS,
     !     &     ' P0H ..',CNVPI*P0H,'(',UNITP,')'
2017 FORMAT(/tr25,a60,a,f10.1,tr2,3A/tr25,a60,a,f10.1,tr2,3A)
     IF(.NOT.heat) THEN
        WRITE(fulp,2017) 'Isothermal aquifer temperature ....'//dots,  &
             ' T0H ..',cnvt1i*t0h+cnvt2i,'(Deg.',unitt,')'
     ELSE IF(heat) THEN
        WRITE(fulp,2017) 'Reference temperature for enthalpy '//dots,  &
             ' T0H ..',cnvt1i*t0h+cnvt2i,'(Deg.',unitt,')'
     END IF
  END IF
  IF(prt_kd) THEN
     WRITE(fukd,2012) rxlbl//'-Direction Fluid Conductance Factor ',  &
          'between '//rxlbl//'(I) and '//rxlbl//'(I+1)   (', TRIM(unitl),'^3)'
2012 FORMAT(/tr25,8A)
     DO  m=1,nxyz
        IF(ibc(m) == -1) THEN
           lprnt1(m)=-1
        ELSE
           lprnt1(m)=1
        END IF
     END DO
     CALL prntar(2,tx,lprnt1,fukd,cnvl3i,24,-100)
     IF(.NOT.cylind) THEN
        WRITE(fukd,2012) 'Y-Direction Fluid Conductance Factor ','between Y(J) and Y(J+1)   (',TRIM(unitl),'^3)'
        CALL prntar(2,ty,lprnt1,fukd,cnvl3i,24,-010)
     END IF
     WRITE(fukd,2012) 'Z-Direction Fluid Conductance Factor ','between Z(K) and Z(K+1)   (',TRIM(unitl),'^3)'
     CALL prntar(2,tz,lprnt1,fukd,cnvl3i,24,-001)
  END IF
  IF(prtfp) THEN
     cw0='0.0   '
     WRITE(cw0,3001) w0
     cw1='1.0   '
     if (solute) WRITE(cw1,3001) w1
3001 FORMAT(f7.4)
     ! ... Print basic fluid properties
     WRITE(fulp,2018) '*** Fluid Properties ***','Physical',  &
          'Fluid compressibility .......'//dots,   ' BP ... ',  &
          bp/cnvpi,'(1/',unitp,')'
2018 FORMAT(//tr40,a/tr45,a/tr25,a60,a,1PE10.2,tr2,3A)
     WRITE(fulp,2019) 'Reference pressure for density '//dots,  &
          ' P0 ..  ',cnvpi*p0,'(',unitp,')',  &
          'Reference temperature for density '//dots,   ' T0 ..  ',  &
          cnvt1i*t0+cnvt2i,'(Deg.',unitt,')', 'Fluid density '//  &
          dots,' DENF0  ',cnvdi*denf0,'(',unitm,'/',TRIM(unitl),'^3)'
2019 FORMAT(/tr25,a60,a,f10.1,tr2,3A/tr25,a60,a,f10.1,tr2,3A/tr25,  &
          a60,a,1PG10.5,tr2,5A)
     IF(solute) WRITE(fulp,2020) 'Fluid density at solute '//mflbl//  &
          'fraction of '//cw1//dots,' DENF1  ',cnvdi*denf1, '(',unitm,'/',TRIM(unitl),'^3)'
2020 FORMAT(tr25,a60,a,1PG10.5,tr2,5A)
     IF(heat) THEN
        WRITE(fulp,2021) 'Thermal',  &
             'Fluid coefficient of thermal expansion '//dots,  &
             ' BT ... ',bt/cnvt1i,'(1/Deg.',unitt,')',  &
             'Fluid heat capacity '//dots,   ' CPF .. ',cnvhci*cpf,  &
             '(',unith,'/',unitm,'-Deg.',unitt,')',  &
             'Fluid thermal conductivity '//dots,   ' KTHF . ',  &
             cnvtci*kthf,'(',unithf,'/',TRIM(unitl),'-Deg.',unitt,')',  &
             'Fluid specific enthalpy at reference conditions'//  &
             dots,' EH0 .. ',(cnvhei/cnvmi)*eh0,'(',unith,'/',unitm, ')'
2021    FORMAT(/tr45,a/tr25,a60,a,1PG10.2,tr2,3A/tr25,a60,a,1PG10.3,  &
             tr2,7A/tr25,a60,a,1PG10.3,tr2,7A/tr25,a60,a,1PG10.3, tr2,5A)
     END IF
     IF(errexi) GO TO 60
     ucnvi=cnvvsi
     IF(visfac > 0.) ucnvi=1.d0
     WRITE(fulp,2022) 'Viscosity factor '//dots,' VISFAC ', ucnvi*visfac
2022 FORMAT(/tr25,a60,a,1PG10.3)
60   IF(.NOT.heat.AND.visfac > 0.) WRITE(fulp,2023)
2023 FORMAT(tr25,'Viscosity will be adjusted to isothermal',' aquifer temperature')
  END IF
  IF(nwel > 0) THEN
     IF(prtwel) THEN
        ! ... Well bore information
        WRITE(fulp,2024)'*** Well Data ***',dash,  &
             'Well', 'Location','Screen Interval','Screen Interval','Calculation',  &
             'Well Diameter',  &
             'No.','X','Y','Z1','Z2','Top Depth','Bottom Depth','Type','('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')','('//TRIM(unitl)//')','('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')','('//TRIM(unitl)//')', dash
        WRITE(fuwel,2024)'*** Well Data ***',dash,  &
             'Well', 'Location','Screen Interval','Screen Interval','Calculation',  &
             'Well Diameter',  &
             'No.','X','Y','Z1','Z2','Top Depth','Bottom Depth','Type','('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')','('//TRIM(unitl)//')','('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')','('//TRIM(unitl)//')', dash
2024    FORMAT(//tr40,a/tr5,a115/  &
             tr5,a,tr7,a,tr12,a,tr10,a,tr14,a,tr5,a/  &
             tr5,a,tr6,a,tr10,a,tr11,a,tr10,a,tr7,a,tr2,a,tr13,a,tr13,a/  &
             tr13,a,tr8,a,tr9,a,tr8,a,tr8,a,tr9,a/  &
             tr5,a115)
        DO  iwel=1,nwel
           chu2 = '           '
           chu3 = '           '
           IF(dwt(iwel) >= 0._kdp .and. dwb(iwel) > 0._kdp) then
              WRITE(chu2,3002) cnvli*dwt(iwel)
              WRITE(chu3,3002) cnvli*dwb(iwel)
3002          FORMAT(1PG11.3)
           END IF
           WRITE(fulp,2025) welidno(iwel),cnvli*xw(iwel),cnvli*yw(iwel),  &
                cnvli*zwb(iwel),cnvli*zwt(iwel),chu2,chu3, &
                wqmeth(iwel), cnvli*wbod(iwel)
           WRITE(fuwel,2025) welidno(iwel),cnvli*xw(iwel),cnvli*yw(iwel),  &
                cnvli*zwb(iwel),cnvli*zwt(iwel),chu2,chu3, &
                wqmeth(iwel), cnvli*wbod(iwel)
2025       FORMAT(tr5,i3,tr2,4(1PG11.3),2a11,tr180,i2,tr12,1PG12.3)
        END DO
        DO  iwel=1,nwel
           iwq1=wqmeth(iwel)/10
           iwq3=2
           IF(wqmeth(iwel) == 11.OR.wqmeth(iwel) == 13) THEN
              iwq2=2
              iwq3=1
           END IF
           IF(iwq1 == 0) THEN
              iwq2=0
              iwq3=0
           END IF
           WRITE(fulp,2026) 'Well No.',welidno(iwel),wclbl1(iwq1),  &
                wclbl2(iwq2),wclbl3(iwq3)
           WRITE(fuwel,2026) 'Well No.',welidno(iwel),wclbl1(iwq1),  &
                wclbl2(iwq2),wclbl3(iwq3)
2026       FORMAT(/tr2,a,i4/tr4,a/tr4,a/tr4,a)
        END DO
!!$        WRITE(fulp,2027) 'Node Layer','Effective Ambient Permeability','Well Flow Factor',  &
!!$             'No.','Below the node  Above the node',  &
!!$             '('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^3)',dash
        WRITE(fuwel,2027) 'Node Layer','Effective Ambient Permeability','Well Flow Factor',  &
             'No.','Below the node  Above the node',  &
             '('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^3)',dash
2027    FORMAT(/tr20,a,tr3,a,tr11,a/tr25,a,tr6,a/tr38,a,tr11,a,tr20,a/tr8,a90)
        DO  iwel=1,nwel
           IF(wqmeth(iwel) >= 40) wrcalc=.TRUE.
           IF(wqmeth(iwel) > 0) THEN
              nks=nkswel(iwel)
              mt=mwel(iwel,nks)
              CALL mtoijk(mt,i,j,kwt,nx,ny)
              mb=mwel(iwel,1)
              CALL mtoijk(mb,i,j,kwb,nx,ny)
!!$              WRITE(fulp,2028) 'Well No.',welidno(iwel)
              WRITE(fuwel,2028) 'Well No.',welidno(iwel)
2028          FORMAT(/tr8,a,i4)
              DO  l=1,nz
                 aprnt1(l) = 0._kdp
                 aprnt2(l) = 0._kdp
                 aprnt2(l) = 0._kdp
              END DO
              DO  ks=1,nks
                 m=mwel(iwel,ks)
                 CALL mtoijk(m,i,j,l,nx,ny)
                 aprnt1(l)=cnvl2i*wcfl(iwel,ks)
                 aprnt2(l)=cnvl2i*wcfu(iwel,ks)
                 aprnt3(l)=cnvl3i*wi(iwel,ks)
              END DO
!!$              WRITE(fulp,2029) (l, aprnt1(l), aprnt2(l), aprnt3(l), l=kwt,kwb,-1)
              WRITE(fuwel,2029) (l, aprnt1(l), aprnt2(l), aprnt3(l), l=kwt,kwb,-1)
2029          FORMAT(tr20,i6,tr8,1pe12.3,tr7,1pe12.3,tr10,1pe12.3)
           END IF
        END DO
        ntprwel = ntprwel+1
     END IF
     deallocate (wcfl, wcfu, dwb, dwt, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed, write2_1: "  
        STOP  
     ENDIF
  END IF
  ! ... Output to well file and xyz.well file with concentrations is in write2_2, 
  ! ...      which follows equilibration calculation
  IF(prtbc) THEN
     IF(nsbc > 0) THEN
        ! ... Specified P,T,or C nodes
        lprnt1 = -1
        DO  l=1,nsbc
           m=msbc(l)
           lprnt1(m)=1
           aprnt1(m)=l
        END DO
        WRITE(fulp,2036) 'Index Numbers For Specified P or C Nodes'
2036    FORMAT(/tr35,a)
        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
     END IF
     IF(nfbc > 0) THEN
        ! ... Specified flux b.c.
        lprnt1 = -1
        DO  l=1,nfbc
           m=mfbc(l)
           lprnt1(m)=1
           aprnt1(m)=l
        END DO
        WRITE(fulp,2036) 'Index Numbers For Specified Flux Nodes'
        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
     END IF
     IF(nlbc > 0) THEN
        ! ... Leakage b.c.
        lprnt1 = -1
        DO  l=1,nlbc
           m=mlbc(l)
           lprnt1(m)=1
           aprnt3(m)=klbc(l)
           aprnt4(m)=zelbc(l)
           aprnt5(m)=bblbc(l)
           aprnt1(m)=l
        END DO
        WRITE(fulp,2036) 'Index Numbers for Aquifer Leakage B.C. Cells'
        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
        WRITE(fulp,2037) 'Aquifer Leakage Factors (',TRIM(unitl),'^2)'
2037    FORMAT(tr35,3A)
        CALL prntar(2,aprnt3,lprnt1,fulp,cnvl3i,24,000)
        WRITE(fulp,2037) 'Elevation of External Surface of Aquitard '//  &
             '(',TRIM(unitl),')'
        CALL prntar(2,aprnt4,lprnt1,fulp,cnvli,24,000)
        !            WRITE(FULP,2037)
        !     &           'Thickness of Aquitard (',TRIM(UNITL),')'
        !            CALL PRNTAR(2,APRNT5,LPRNT1,FULP,CNVLI,24,000)
     END IF
     IF(nrbc > 0) THEN
        ! ... River leakage b.c.
        lprnt1 = -1
        DO  lc=1,nrbc_cells
           m=mrbc_bot(lc)
           lprnt1(m)=1
           aprnt1(m)=m
        END DO
        WRITE(fulp,2036) 'Cell Numbers for River Leakage B.C. Cells'
        WRITE(fulp,2036) '(based on bottom elevation of lowest river segment)'
        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
        WRITE(fulp,2124)'*** River Leakage Data ***',dash,  &
             'Segment','Segment Cell','Min. Cell',  &
             'Leakage Factor','Elevation of River Bed', 'No.','No.','No.',  &
             '('//TRIM(unitl)//'^2)','('//TRIM(unitl)//')', dash
2124    FORMAT(//tr40,a/tr10,a95/ tr13,a,tr1,a,tr3,a,tr4,a,tr8,a/tr16,  &
             a,tr7,a,tr9,a,tr12,a,tr21,a/tr10,a95)
        DO lc=1,nrbc
           DO  ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
              WRITE(fulp,2125) ls,mrbc(ls),mrbc_bot(lc),cnvl2i*krbc(ls),cnvli*zerbc(ls)
2125          FORMAT(tr13,i5,tr7,i3,tr10,i3,tr8,1PG12.3,tr15,1PG12.3)
           END DO
        END DO
     END IF
!!$     IF(naifc > 0) THEN
!!$        !...  ** not available in PHAST
!!$        ! ... Aquifer influence functions
!!$        IF(iaif == 1) THEN
!!$           WRITE(fulp,2038) ' *** Data For Pot Aquifer Influence Function ***',  &
!!$                dash,'Properties of Outer Aquifer Region',  &
!!$                'Porosity','Porous Medium','Aquifer',  &
!!$                'Compressibility','Volume','(-)','(',unitp,'^-1)', '(',TRIM(unitl),'^3)',dash
!!$           2038       FORMAT(//tr30,a/tr15,a110/tr40,a/tr15,a,tr5,a,tr3,a  &
!!$                /tr28,a,tr2,a/tr18,a,tr8,3A,tr6,3A/tr15,a110)
!!$           WRITE(fulp,2039) poroar,cnvp*aboar,cnvl3i*voar
!!$           2039       FORMAT(tr15,0PF10.4,tr5,1PG12.3,tr6,1PG12.3)
!!$        END IF
!!$        IF(iaif == 2) THEN
!!$           WRITE(fulp,2040) '*** Data for Transient Aquifer Influence '//  &
!!$                ' Function ***', dash,'Properties of Outer Aquifer Region',  &
!!$                'Permeability','Porosity','Simulation Region',  &
!!$                'Angle of','Porous Medium','Aquifer','Fluid',  &
!!$                'Equivalent Radius','Influence','Compressibility',  &
!!$                'Thickness','Viscosity','(',TRIM(unitl),'^2)','(-)','(',  &
!!$                TRIM(unitl),')','(Deg.)','(',unitp,'^-1)','(',TRIM(unitl),')', '(',unitvs,')',dash
!!$           2040       FORMAT(//tr30,a/tr15,a110/tr40,a/tr15,a,tr5,a,tr3,a,tr3,  &
!!$                a,tr5,a,tr3,a,tr5,a/tr43,a,tr3,a,tr3,a,tr2,a,tr3,  &
!!$                a/tr18,3A,tr10,a,tr12,3A,tr10,a,tr8,3A,tr6,3A,tr6, 3A/tr15,a110)
!!$           WRITE(fulp,2041) cnvl2i*koar,poroar,cnvli*rioar,  &
!!$                angoar*360.,aboar/cnvpi,cnvli*boar,cnvvsi*visoar
!!$           2041       FORMAT(tr15,1PG12.3,tr2,0PF10.4,tr5,f10.1,tr5,f10.0,  &
!!$                tr5,1PG12.3,tr2,0PF10.1,tr7,1PG10.4)
!!$           WRITE(fulp,2042) 'Coefficients for Approximating Equation',  &
!!$                '(Infinite Exterior Radius of Outer Region)',dash
!!$           2042       FORMAT(//tr30,a/tr30,a/tr25,a70)
!!$           WRITE(fulp,2043) (bbaif(i),i=0,3)
!!$           2043       FORMAT(tr26,4(f12.6,tr5))
!!$        END IF
!!$        IF(errexi) GO TO 300
!!$        DO  m=1,nxyz
!!$           lprnt1(m)=-1
!!$        END DO
!!$        DO  l=1,naifc
!!$           m=maifc(l)
!!$           lprnt1(m)=1
!!$           aprnt1(m)=l
!!$        END DO
!!$        WRITE(fulp,2044) 'Index Numbers for Aquifer Influence Function Cells',  &
!!$             'Only the Largest Index for Multi-Faced Cells'
!!$        2044    FORMAT(//tr35,a/tr35,a)
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
!!$        WRITE(fulp,2036) 'Aquifer Influence Function Apportionment Coefficients'
!!$        CALL prntar(2,uvaifc,lprnt1,fulp,cnv,24,000)
!!$     END IF
  END IF
!!$300 CONTINUE
  IF(fresur) WRITE(fulp,2036) 'A free-surface water table is specified for this simulation'
  IF(prtslm) then
     ! ... Calculation information
     WRITE(fulp,2053) '*** Calculation Information ***'
2053 FORMAT(/tr40,a)
     WRITE(logline1,5053) '                    *** Calculation Information ***'
5053 format(a)
     call logprt_c(logline1)
     ! ...    Iteration parameters
     !      IF(HEAT.OR.SOLUTE) THEN
     !         WRITE(FULP,2054)
     !     &        'Tolerance for P,T,C iteration (fractional density '//
     !     &        'change) '//DOTS,' TOLDEN ',TOLDEN,
     !     &        'Maximum number of iterations allowed on sequential '//
     !     &        'solution of P,T,C equations '//DOTS,' MAXITN ',MAXITN
     !         WRITE(FUCLOG,2054)
     !     &        'Tolerance for P,T,C iteration (fractional density '//
     !     &        'change) '//DOTS,' TOLDEN ',TOLDEN,
     !     &        'Maximum number of iterations allowed on sequential '//
     !     &        'solution of P,T,C equations '//DOTS,' MAXITN ',MAXITN
     ! 2054    FORMAT(/TR10,A80,A,F6.4/TR10,A80,A,I6)
     !      ENDIF
     IF(fdtmth > 0.5) THEN
        WRITE(fulp,2055) 'Backwards-in-time (implicit) differencing for '//  &
             'temporal derivative'
2055    FORMAT(tr10,a)
!!$     WRITE(logline1,5053) 'Backwards-in-time (implicit) differencing for '//  &
!!$          'temporal derivative'
!!$     call logprt_c(logline1)
     ELSE
        WRITE(fulp,2055) 'Centered-in-time (Crank-Nicholson) differencing '//  &
             'for temporal derivative'
!!$     WRITE(logline1,5053) 'Centered-in-time (Crank-Nicholson) differencing '//  &
!!$          'for temporal derivative'
!!$     call logprt_c(logline1)
     END IF
     IF(heat .OR. solute) THEN
        IF(fdsmth < 0.5) THEN
           WRITE(fulp,2055) 'Backwards-in-space (upstream) differencing for '//  &
                'advective terms'
!!$        WRITE(logline1,5053) 'Backwards-in-space (upstream) differencing for '//  &
!!$             'advective terms'
        ELSE
           WRITE(fulp,2055) 'Centered-in-space differencing for advective terms'
!!$        WRITE(logline1,5053) 'Centered-in-space differencing for advective terms'
        END IF
!!$     call logprt_c(logline1)
        IF(crosd) then
           WRITE(fulp,2055) 'The cross-derivative solute flux terms '//  &
                'will be calculated explicitly'
!!$        WRITE(logline1,5053) 'The cross-derivative solute flux terms '//  &
!!$             'will be calculated explicitly'
        else
           WRITE(fulp,2055) 'The cross-derivative solute flux terms '//  &
                'will NOT BE calculated'
!!$        WRITE(logline1,5053) 'The cross-derivative solute flux terms '//  &
!!$             'will NOT BE calculated'
        endif
!!$     call logprt_c(logline1)
     END IF
     IF(slmeth == 3) THEN
        WRITE(fulp,2059) 'Direction index for red-black renumbering '//dots,  &
             ' IDIR..',idir, 'Incomplete LU [f] or modified ILU [t] factorization '//  &
             dots,' MILU.. ',milu,  &
             'Number of search directions before restart '//dots,  &
             ' NSDR..',nsdr,'Tolerance on iterative solution '//dots, ' EPSSLV',epsslv
2059    FORMAT(/tr10,a65,a,i5/tr10,a65,a,l5/tr10,a65,a,i5/tr10,a65,a,1PE8.1)
        WRITE(logline1,5059) '          Direction index for red-black renumbering '//dots,  &
             ' IDIR..',idir
5059    FORMAT(a65,a,i5)
        WRITE(logline2,5159) '          Incomplete LU [f] or modified ILU [t] factorization '//  &
             dots,' MILU.. ',milu
5159    FORMAT(a65,a,l5)
        WRITE(logline3,5059) '          Number of search directions before restart '//dots,  &
             ' NSDR..',nsdr
        WRITE(logline4,5060) '          Tolerance on iterative solution '//dots,' EPSSLV',epsslv
5060    FORMAT(a65,a,1pe8.1)
        call logprt_c(logline1)
        call logprt_c(logline2)
        call logprt_c(logline3)
        call logprt_c(logline4)
     ELSE IF(slmeth == 5) THEN
        WRITE(fulp,2059) 'Direction index for d4 zig-zag renumbering '//dots,  &
             ' IDIR..',idir, 'Incomplete LU [f] or modified ILU [t] factorization '//  &
             dots,' MILU.. ',milu,  &
             'Number of search directions before restart '//dots,  &
             ' NSDR..',nsdr,'Tolerance on iterative solution '//dots, ' EPSSLV',epsslv
        WRITE(logline1,5059) '          Direction index for d4 zig-zag renumbering '//dots,  &
             ' IDIR..',idir
        WRITE(logline2,5159) '          Incomplete LU [f] or modified ILU [t] factorization '//  &
             dots,' MILU.. ',milu
        WRITE(logline3,5059) '          Number of search directions before restart '//dots,  &
             ' NSDR..',nsdr
        WRITE(logline4,5060) '          Tolerance on iterative solution '//dots,' EPSSLV',epsslv
        call logprt_c(logline1)
        call logprt_c(logline2)
        call logprt_c(logline3)
        call logprt_c(logline4)
     END IF
  endif
  WRITE(fulp,'(/tr1,a120)') dash
  ! ... Write zone definition data to file 'FUPZON' for plotting
!!$  IF(pltzon) THEN
!!$     WRITE(fupzon,5003) npmz
!!$     5003 FORMAT(i6)
!!$     DO  ipmz=1,npmz
!!$        x1z=cnvli*x(i1z(ipmz))
!!$        x2z=cnvli*x(i2z(ipmz))
!!$        y1z=cnvli*y(j1z(ipmz))
!!$        y2z=cnvli*y(j2z(ipmz))
!!$        z1z=cnvli*z(k1z(ipmz))
!!$        z2z=cnvli*z(k2z(ipmz))
!!$        WRITE(fupzon,5004)  ipmz,x1z,x2z,y1z,y2z,z1z,z2z
!!$        5004    FORMAT(tr1,i5,tr2,6(1PG15.7))
!!$     END DO
!!$  END IF
!!$  ! ... Write static data to file 'FUVMAP' for velocity plots
!!$  WRITE(fuvmap,5005) (ibc(m),m=1,nxyz)
!!$  WRITE(fuvmap,5006) (cnvli*x(i),i=1,nx)
!!$  WRITE(fuvmap,5006) (cnvli*y(j),j=1,ny)
!!$  WRITE(fuvmap,5006) (cnvli*z(k),k=1,nz)
!!$  ! ... Write static data to file 'FUBNFR' for b.c. flow summation
!!$  WRITE(fubnfr,5005) (ibc(m),m=1,nxyz)
!!$  WRITE(fubnfr,5007) (cnvli*x(i),i=1,nx)
!!$  WRITE(fubnfr,5007) (cnvli*y(j),j=1,ny)
!!$  WRITE(fubnfr,5007) (cnvli*z(k),k=1,nz)
!!$  5007 FORMAT(8(d15.7))
!!$  IF(nsbc > 0) THEN
!!$     WRITE(fubnfr,5005) nsbc
!!$     WRITE(fubnfr,5005) (msbc(l),l=1,nsbc)
!!$  END IF
!!$  IF(nfbc > 0) THEN
!!$     WRITE(fubnfr,5005) nfbc
!!$     WRITE(fubnfr,5005) (mfbc(l),l=1,nfbc)
!!$  END IF
!!$  IF(nlbc > 0) THEN
!!$
!!$     WRITE(fubnfr,5005) nlbc
!!$     WRITE(fubnfr,5005) (mlbc(l),l=1,nlbc)
!!$  END IF
!!$  IF(nrbc > 0) THEN
!!$     WRITE(fubnfr,5005) nrbc_seg
!!$     WRITE(fubnfr,5005) (mrbc(l),l=1,nrbc_seg)
!!$  END IF
!!$  IF(naifc > 0) THEN
!!$     WRITE(fubnfr,5005) naifc
!!$     WRITE(fubnfr,5005) (maifc(l),l=1,naifc)
!!$  END IF
!!$  IF(nhcbc > 0) THEN
!!$     WRITE(fubnfr,5005) nhcbc
!!$     WRITE(fubnfr,5005) (mhcbc(l),l=1,nhcbc)
!!$  END IF
  DEALLOCATE (aprnt5,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array allocation failed: write2_1"  
  ENDIF
END SUBROUTINE write2_1
