SUBROUTINE write2_1
  ! ... Write the parameter data after READ2
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcb2
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
  USE ld_seg_mod
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
  INTEGER :: i, ic, ifc, ifu, iwel, iwq1, iwq2, iwq3, izn, j,  &
       jprptc, k, ks, kwb, kwt, l, lc, ls, m, mb, mt, nks
  INTEGER :: mp, msp
  INTEGER :: ipmz, mele, nxele, nxyele, nele
  INTEGER, DIMENSION(nwel*nz) :: indxprint
  ! ... Set the unit numbers for node point output
  INTEGER, DIMENSION(12), PARAMETER :: fu =(/16,21,22,23,26,27,0,0,0,0,0,0/)
  INTEGER :: nr
  REAL(KIND=kdp), PARAMETER :: cnv=1._kdp, one=1._kdp
  REAL(KIND=kdp) :: ph
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: aprnt5
  INTEGER :: a_err, da_err
  !!  type(rbc_indices), dimension(:), pointer :: ptr
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
       'Number of drain leakage cells '//dots,' NDBC . ',ndbc,  &
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
!!$  WRITE(logline5,5009) 'Number of drain leakage cells '//dots,' NDBC . ',ndbc
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
        WRITE(fulp,2002) 'Linear solver array dimension requirement (D4 direct solver)'//  &
             dots,' NSTSLV ',nstslv,' elements'
        WRITE(logline1,5001) 'Linear solver array dimension requirement (D4 direct solver)'//  &
             dots,' NSTSLV ',nstslv,' elements'
        WRITE(logline2,5001) 'Primary storage requirement (D4 direct solver)'//  &
             dots,' NPRIST ',nprist,' elements'
        WRITE(logline3,5001) 'Overhead storage requirement (D4 direct solver)'//  &
             dots,' NOHST .',nohst,' elements'
        CALL logprt_c(logline1)
        CALL logprt_c(logline2)
        CALL logprt_c(logline3)
     ELSE IF(slmeth == 3) THEN
        WRITE(fulp,2002) 'Linear solver array dimension requirement (RBGCG iterative solver)'//  &
             dots,' NSTSLV ',nstslv,' elements'
        WRITE(logline1,5001) 'Linear solver array dimension requirement (RBGCG iterative solver)'//  &
             dots,' NSTSLV ',nstslv,' elements'
        WRITE(logline2,5001) 'Primary storage requirement (RBGCG iterative solver)'//  &
             dots,' NPRIST ',nprist,' elements'
        WRITE(logline3,5001) 'Overhead storage requirement (RBGCG iterative solver)'//  &
             dots,' NOHST .',nohst,' elements'
        CALL logprt_c(logline1)
        CALL logprt_c(logline2)
        CALL logprt_c(logline3)
     ELSE IF(slmeth >= 5) THEN
        WRITE(fulp,2002) 'Linear solver array dimension requirement (D4ZGCG iterative '//  &
             'solver)'//dots,' NSTSLV ',nstslv,' elements'
        WRITE(logline1,5001) 'Linear solver array dimension requirement (D4ZGCG iterative '//  &
             'solver)'//dots,' NSTSLV ',nstslv,' elements'
        WRITE(logline2,5001) 'Primary storage requirement (D4ZGCG iterative solver)'//  &
             dots,' NPRIST ',nprist,' elements'
        WRITE(logline3,5001) 'Overhead storage requirement (D4ZGCG iterative solver)'//  &
             dots,' NOHST .',nohst,' elements'
        CALL logprt_c(logline1)
        CALL logprt_c(logline2)
        CALL logprt_c(logline3)
     END IF
  END IF
2002 FORMAT(/(tr10,a70,a,i8,a))
5001 FORMAT(a70,a,i8,a)
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
        WRITE(fu(ifu),2005) 'Y-Direction Node Coordinates   (',TRIM(unitl),')'
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
!!$     WRITE(fulp,2008)
!!$2008 FORMAT(//tr40,'** Aquifer Properties  **  (read echo)'/ tr35,'Region',  &
!!$          tr45,'Porous Medium'/tr20,  &
!!$          'X1         Y1         Z1          X2         Y2         Z2',  &
!!$          tr8,'Zone Index'/tr8,90('-'))
!!$     WRITE(fulp,2009) (cnvli*x(i1z(i)),cnvli*y(j1z(i)),cnvli*z(k1z(i)),  &
!!$          cnvli*x(i2z(i)),cnvli*y(j2z(i)),cnvli*z(k2z(i)),i,i=1,npmz)
!!$2009 FORMAT((tr14,6(1PG11.3),tr5,i5))
     IF(errexi) GO TO 30
     WRITE(fulp,2010)
2010 FORMAT(//tr30,'*** Porous Media Properties ***'/)
     WRITE(fulp,2013) '*** Properties by Porous Medium Zone ***'
2013 FORMAT(/tr30,a)
     kx = kxx*denf0*grav*86400./ABS(visfac)
     ky = kyy*denf0*grav*86400./ABS(visfac)
     kz = kzz*denf0*grav*86400./ABS(visfac)
     ! ... calculate specific storage distribution
     ss = den0*gz*(abpm + poros*bp)
     ! ... Load and flag the active elements for printouts
     nxele = nx-1
     nxyele = (nx-1)*(ny-1)
     nele = nxyele*(nz-1)
     ALLOCATE (lprnt4(nele),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: write2_1, number 1.1"  
        STOP  
     ENDIF
     lprnt4 = 0
     aprnt1 = 0.
     aprnt2 = 0.
     aprnt3 = 0.
     aprnt4 = 0.
     aprnt5 = 0.
     DO  ipmz=1,npmz
        mele = (k1z(ipmz)-1)*nxyele + (j1z(ipmz)-1)*nxele + i1z(ipmz)
        lprnt4(mele) = 1
        aprnt1(mele) = kx(ipmz)
        aprnt2(mele) = ky(ipmz)
        aprnt3(mele) = kz(ipmz)
        aprnt4(mele) = poros(ipmz)
        aprnt5(mele) = ss(ipmz)
     END DO
!!$     WRITE(fulp,2005) rxlbl//'-Direction Hydraulic Conductivities   (',TRIM(unitl),'/d)'
!!$     CALL prntar(1,kx,lprnt4,fulp,cnvli,24,npmz)
!!$     IF(.NOT.cylind) THEN
!!$        WRITE(fulp,2005) 'Y-Direction Hydraulic Conductivities   (',TRIM(unitl),'/d)'
!!$        CALL prntar(1,ky,lprnt4,fulp,cnvli,24,npmz)
!!$     END IF
!!$     WRITE(fulp,2005) 'Z-Direction Hydraulic Conductivities   (',TRIM(unitl),'/d)'
!!$     CALL prntar(1,kz,lprnt4,fulp,cnvli,24,npmz)
     WRITE(fulp,2005) rxlbl//'-Direction Hydraulic Conductivities by Element (',TRIM(unitl),'/d)'
     CALL prntar(2,aprnt1,lprnt4,fulp,cnvli,24,-111)
     IF(.NOT.cylind) THEN
        WRITE(fulp,2005) 'Y-Direction Hydraulic Conductivities by Element (',TRIM(unitl),'/d)'
        CALL prntar(2,aprnt2,lprnt4,fulp,cnvli,24,-111)
     END IF
     WRITE(fulp,2005) 'Z-Direction Hydraulic Conductivities by Element (',TRIM(unitl),'/d)'
     CALL prntar(2,aprnt3,lprnt4,fulp,cnvli,24,-111)
!$$     WRITE(fulp,2011) 'Porosity (-)'
!$$     CALL prntar(1,poros,lprnt4,fulp,cnv,24,npmz)
     WRITE(fulp,2011) 'Porosity by Element (-)'
2011 FORMAT(/tr40,a)
     CALL prntar(2,aprnt4,lprnt4,fulp,cnv,24,-111)
!$$     WRITE(fulp,2031) 'Specific Storage ('//TRIM(unitl) //'^-1)'
!$$     CALL prntar(1,ss,lprnt4,fulp,1.d0/cnvli,24,npmz)
     WRITE(fulp,2031) 'Specific Storage by Element ('//TRIM(unitl) //'^-1)'
2031 FORMAT(tr30,a)
     CALL prntar(2,aprnt5,lprnt4,fulp,1.d0/cnvli,24,-111)
30   CONTINUE
     IF(heat .OR. solute) THEN
        ! ... Load the active elements for printing
        aprnt1 = 0.
        aprnt2 = 0.
        aprnt3 = 0.
        DO  ipmz=1,npmz
           mele = (k1z(ipmz)-1)*nxyele + (j1z(ipmz)-1)*nxele + i1z(ipmz)
           aprnt1(mele) = alphl(ipmz)
           aprnt2(mele) = alphth(ipmz)
           aprnt3(mele) = alphtv(ipmz)
        END DO
!!$        WRITE(fulp,2014) 'Longitudinal Dispersivity   (',TRIM(unitl),')'
!!$        CALL prntar(1,alphl,ibc,fulp,cnvli,24,npmz)
!!$        WRITE(fulp,2014) 'Transverse Dispersivity; Horizontal   (',TRIM(unitl),')'
!!$        CALL prntar(1,alphth,ibc,fulp,cnvli,24,npmz)
!!$        WRITE(fulp,2014) 'Transverse Dispersivity; Vertical   (',TRIM(unitl),')'
!!$        CALL prntar(1,alphtv,ibc,fulp,cnvli,24,npmz)
        WRITE(fulp,2014) 'Longitudinal Dispersivity by Element (',TRIM(unitl),')'
2014    FORMAT(/tr30,8A)
        CALL prntar(2,aprnt1,lprnt4,fulp,cnvli,24,-111)
        WRITE(fulp,2014) 'Transverse Dispersivity; Horizontal by Element (',TRIM(unitl),')'
        CALL prntar(2,aprnt2,lprnt4,fulp,cnvli,24,-111)
        WRITE(fulp,2014) 'Transverse Dispersivity; Vertical by Element (',TRIM(unitl),')'
        CALL prntar(2,aprnt3,lprnt4,fulp,cnvli,24,-111)
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
     DEALLOCATE (lprnt4,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation lprnt4 failed: write2_1"  
     ENDIF
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
     IF (solute) WRITE(cw1,3001) w1
3001 FORMAT(f7.4)
     ! ... Print basic fluid properties
     WRITE(fulp,2018) '*** Fluid Properties ***','Physical',  &
          'Fluid compressibility .......'//dots,   ' BP ... ',  &
          bp/cnvpi,'(1/',unitp,')'
2018 FORMAT(//tr35,a/tr40,a/tr20,a60,a,1PE10.2,tr2,3A)
     WRITE(fulp,2019) 'Reference pressure for density '//dots,  &
          ' P0 ..  ',cnvpi*p0,'(',unitp,')',  &
          'Reference temperature for density '//dots,   ' T0 ..  ',  &
          cnvt1i*t0+cnvt2i,'(Deg.',unitt,')', 'Fluid density '//  &
          dots,' DENF0  ',cnvdi*denf0,'(',unitm,'/',TRIM(unitl),'^3)'
2019 FORMAT(/tr20,a60,a,f10.1,tr2,3A/tr20,a60,a,f10.1,tr2,3A/tr20,  &
          a60,a,1PG10.5,tr2,5A)
     IF(solute) WRITE(fulp,2020) 'Fluid density at solute '//mflbl//  &
          'fraction of '//cw1//dots,' DENF1  ',cnvdi*denf1, '(',unitm,'/',TRIM(unitl),'^3)'
2020 FORMAT(tr20,a60,a,1PG10.5,tr2,5A)
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
2022 FORMAT(/tr20,a60,a,1PG10.3)
60   IF(.NOT.heat.AND.visfac > 0.) WRITE(fulp,2023)
2023 FORMAT(tr20,'Viscosity will be adjusted to isothermal',' aquifer temperature')
  END IF
  IF(nwel > 0) THEN
     IF(prtbc) THEN
        ! ... Well bore information to probdef file
        WRITE(fulp,2024)'*** Well Data ***',dash,  &
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
           IF(dwt(iwel) >= 0._kdp .AND. dwb(iwel) > 0._kdp) THEN
              WRITE(chu2,3002) cnvli*dwt(iwel)
              WRITE(chu3,3002) cnvli*dwb(iwel)
3002          FORMAT(1PG11.3)
           END IF
           WRITE(fulp,2025) welidno(iwel),cnvli*xw(iwel),cnvli*yw(iwel),  &
                cnvli*zwb(iwel),cnvli*zwt(iwel),chu2,chu3, &
                wqmeth(iwel), cnvli*wbod(iwel)
2025       FORMAT(tr5,i3,tr2,4(1PG11.3),2a11,tr19,i2,tr12,1PG12.3)
        END DO
        DO  iwel=1,nwel
           iwq1=wqmeth(iwel)/10
           iwq3=2
           IF(wqmeth(iwel) == 11 .OR. wqmeth(iwel) == 13) THEN
              iwq2=2
              iwq3=1
           END IF
           IF(iwq1 == 0) THEN
              iwq2=0
              iwq3=0
           END IF
           WRITE(fulp,2026) 'Well No.',welidno(iwel),wclbl1(iwq1),  &
                wclbl2(iwq2),wclbl3(iwq3)
2026       FORMAT(/tr2,a,i4/tr4,a/tr4,a/tr4,a)
        END DO
!!$        WRITE(fulp,2027) 'Node Layer','Effective Ambient Permeability','Well Flow Factor',  &
!!$             'No.','Below the node  Above the node',  &
!!$             '('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^3)',dash
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
2028          FORMAT(/tr8,a,i4)
              DO  l=1,nz
                 aprnt1(l) = 0._kdp
                 aprnt2(l) = 0._kdp
                 aprnt3(l) = 0._kdp
              END DO
              DO  ks=1,nks
                 m=mwel(iwel,ks)
                 CALL mtoijk(m,i,j,l,nx,ny)
                 aprnt1(l)=cnvl2i*wcfl(iwel,ks)
                 aprnt2(l)=cnvl2i*wcfu(iwel,ks)
                 aprnt3(l)=cnvl3i*wi(iwel,ks)
              END DO
!!$              WRITE(fulp,2029) (l, aprnt1(l), aprnt2(l), aprnt3(l), l=kwt,kwb,-1)
2029          FORMAT(tr20,i6,tr8,1pe12.3,tr7,1pe12.3,tr10,1pe12.3)
           END IF
        END DO
        WRITE(fulp,2334)'*** Well Data by Segment ***',  &
             dash,  &
             'Segment', 'Cell', 'Index', 'Well No.',  &
             'No.','No.','i       j       k',  &
             dash
2334    FORMAT(//tr40,a/tr10,a95/  &
             tr15,a,tr7,a,tr10,a,tr16,a/tr15,  &
             a,tr12,a,tr5,a/  &
             tr10,a95)
        call merge_ref(mwel, indxprint)
        ls = 0
        do mp=1,nwel*nz
           msp = indxprint(mp)
           call mptoiwks(msp,iwel,ks,nwel)
           if (mwel(iwel,ks) /= 0) then
              ls = ls + 1
              call mtoijk(mwel(iwel,ks),i,j,k,nx,ny)
              WRITE(fulp,2335) ls, mwel(iwel,ks), i, j, k, welidno(iwel)
2335          FORMAT(tr15,i5,tr6,i5,3(tr4,i4),tr10,i4)
           end if
        end do
     END IF
     IF(prtwel) THEN
        ! ... Well bore information to well file
        WRITE(fuwel,2024)'*** Well Data ***',dash,  &
             'Well', 'Location','Screen Interval','Screen Interval','Calculation',  &
             'Well Diameter',  &
             'No.','X','Y','Z1','Z2','Top Depth','Bottom Depth','Type','('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')','('//TRIM(unitl)//')','('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')','('//TRIM(unitl)//')', dash
        DO  iwel=1,nwel
           chu2 = '           '
           chu3 = '           '
           IF(dwt(iwel) >= 0._kdp .AND. dwb(iwel) > 0._kdp) THEN
              WRITE(chu2,3002) cnvli*dwt(iwel)
              WRITE(chu3,3002) cnvli*dwb(iwel)
           END IF
           WRITE(fuwel,2025) welidno(iwel),cnvli*xw(iwel),cnvli*yw(iwel),  &
                cnvli*zwb(iwel),cnvli*zwt(iwel),chu2,chu3, &
                wqmeth(iwel), cnvli*wbod(iwel)
        END DO
        DO  iwel=1,nwel
           iwq1=wqmeth(iwel)/10
           iwq3=2
           IF(wqmeth(iwel) == 11 .OR. wqmeth(iwel) == 13) THEN
              iwq2=2
              iwq3=1
           END IF
           IF(iwq1 == 0) THEN
              iwq2=0
              iwq3=0
           END IF
           WRITE(fuwel,2026) 'Well No.',welidno(iwel),wclbl1(iwq1),  &
                wclbl2(iwq2),wclbl3(iwq3)
        END DO
        WRITE(fuwel,2027) 'Node Layer','Effective Ambient Permeability','Well Flow Factor',  &
             'No.','Below the node  Above the node',  &
             '('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^3)',dash
        DO  iwel=1,nwel
           IF(wqmeth(iwel) >= 40) wrcalc=.TRUE.
           IF(wqmeth(iwel) > 0) THEN
              nks=nkswel(iwel)
              mt=mwel(iwel,nks)
              CALL mtoijk(mt,i,j,kwt,nx,ny)
              mb=mwel(iwel,1)
              CALL mtoijk(mb,i,j,kwb,nx,ny)
              WRITE(fuwel,2028) 'Well No.',welidno(iwel)
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
              WRITE(fuwel,2029) (l, aprnt1(l), aprnt2(l), aprnt3(l), l=kwt,kwb,-1)
           END IF
        END DO
        ntprwel = ntprwel+1
     END IF
     DEALLOCATE (wcfl, wcfu, dwb, dwt, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed, write2_1: "  
        STOP  
     ENDIF
  END IF
  ! ... Output to well file and tsv.well file with concentrations is in write2_2, 
  ! ...      which follows equilibration calculation
  IF(prtbc) THEN
    IF(nsbc > 0) THEN
       ! ... Specified P,T,or C nodes
!!$        lprnt1 = -1
!!$        DO  l=1,nsbc
!!$           m=msbc(l)
!!$           lprnt1(m)=1
!!$           aprnt1(m)=l
!!$        END DO
!!$        WRITE(fulp,2036) 'Index Numbers For Specified P or C Nodes'
2036    FORMAT(/tr35,a)
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
!$$        WRITE(fulp,2036) 'Segment Numbers For Specified P or C Nodes'
!$$        CALL ldchar_seg(sv_seg_indx, 1, caprnt, lprnt1)
!$$        CALL prchar(2,caprnt,lprnt1,fulp,000)
        WRITE(fulp,2234)'*** Specified Head B.C. Data by Segment ***',  &
             dash,  &
             'Segment', 'Cell', 'Index',  &
             'No.','No.','i       j       k',  &
             dash
2234    FORMAT(//tr40,a/tr10,a95/  &
             tr15,a,tr7,a,tr10,a/tr15,  &
             a,tr12,a,tr5,a/  &
             tr10,a95)
        DO ls=1,nsbc_seg
           call mtoijk(msbc(ls),i,j,k,nx,ny)
           WRITE(fulp,2235) ls, msbc(ls), i, j, k
2235       FORMAT(tr15,i5,tr6,i5,3(tr4,i4))
        END DO
     END IF
     IF(nfbc > 0) THEN
        ! ... Specified flux b.c.
!!$        lprnt1 = -1
!!$        DO  lc=1,nfbc
!!$           m = flux_seg_index(lc)%m
!!$           lprnt1(m) = 1
!!$           aprnt1(m) = lc
!!$        END DO
!!$        WRITE(fulp,2036) 'Index Numbers For Specified Flux Nodes'
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
!!$        WRITE(fulp,2036) 'Segment Numbers For Specified Flux Nodes'
!!$        CALL ldchar_seg(flux_seg_index, 2, caprnt, lprnt1)
!!$        !!        ptr => flux_seg_index
!!$        !!        CALL ldchar_seg( 2, caprnt, lprnt1)
!!$        !!        nullify (ptr)
!!$        CALL prchar(2,caprnt,lprnt1,fulp,000)
        WRITE(fulp,2034)'*** Flux B.C. Data by Segment ***',  &
             dash,  &
             'Segment', 'Cell', 'Index', 'Face','Face',  &
             'No.','No.','i       j       k','Area','Orientation',  &
             '('//TRIM(unitl)//'^2)',  &
             dash
2034    FORMAT(//tr40,a/tr10,a95/  &
             tr15,a,tr7,a,tr10,a,tr21,a,tr11,a/tr15,  &
             a,tr12,a,tr5,a,tr14,a,tr7,a/tr69,a/  &
             tr10,a95)
        DO  ls=1,nfbc_seg
           call mtoijk(mfbc(ls),i,j,k,nx,ny)
           WRITE(fulp,2035) ls, mfbc(ls), i, j, k, cnvl2i*areafbc(ls), ifacefbc(ls)
2035       FORMAT(tr15,i5,tr6,i5,3(tr4,i4),tr10,1PG11.3,tr9,i2)
        END DO
     END IF
     IF(nlbc > 0) THEN
        ! ... Leakage b.c.
!!$        lprnt1 = -1
!!$        DO  lc=1,nlbc
!!$           m = leak_seg_index(lc)%m
!!$           lprnt1(m)=1
!!$           aprnt1(m)=lc
!!$        END DO
!!$        WRITE(fulp,2036) 'Index Numbers for Aquifer Leakage B.C. Cells'
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
!!$        WRITE(fulp,2036) 'Segment Numbers For Leakage B.C. Nodes'
!!$        CALL ldchar_seg(leak_seg_index, 3, caprnt, lprnt1)
!!$        CALL prchar(2,caprnt,lprnt1,fulp,000)
        WRITE(fulp,2044)'*** Leakage B.C. Data by Segment ***',  &
             dash,  &
             'Segment', 'Cell', 'Index', 'Face', 'Face', 'Leakage Factor','Thickness','Elevation',  &
             'No.','No.','i       j       k','Area','Orientation','of Aquitard','of Aquitard',  &
             '('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^3)','('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')',  &
             dash
2044    FORMAT(//tr40,a/tr10,a110/  &
             tr15,a,tr7,a,tr10,a,tr11,a,tr8,a,tr5,a,tr3,a,tr4,a/tr15,  &
             a,tr11,a,tr5,a,tr5,a,tr5,a,tr17,a,tr2,a/tr59,  &
             a,tr20,a,tr11,a,tr11,a/  &
             tr10,a110)
        DO  ls=1,nlbc_seg
           call mtoijk(mlbc(ls),i,j,k,nx,ny)
           WRITE(fulp,2045) ls, mlbc(ls), i, j, k, cnvl2i*arealbc(ls), ifacelbc(ls),  &
                cnvl3i*klbc(ls), cnvli*bblbc(ls), cnvli*zelbc(ls)
2045       FORMAT(tr15,i5,tr5,i5,3(tr4,i4),tr3,1PG11.3,tr5,i2,tr5,1pg11.3,tr5,1pg11.3,tr3,1pg11.3)
        END DO
     END IF
     IF(nrbc > 0) THEN
        ! ... River leakage b.c.
!!$        lprnt1 = -1
!!$        DO  lc=1,nrbc_cells
!!$           m = river_seg_index(lc)%m
!!$           lprnt1(m) = 1
!!$           aprnt1(m) = lc
!!$        END DO
!!$        WRITE(fulp,2036) 'Cell Numbers for River Leakage B.C. Cells'
!!$        WRITE(fulp,2036) '(based on bottom elevation of lowest river segment)'
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
!!$        WRITE(fulp,2036) 'Segment Numbers For River Leakage Nodes'
!!$        CALL ldchar_seg(river_seg_index, 4, caprnt, lprnt1)
!!$        CALL prchar(2,caprnt,lprnt1,fulp,000)
        WRITE(fulp,2054)'*** River B.C. Data by Segment ***',  &
             dash,  &
             'Segment', 'Cell', 'Index', 'Min. Cell', 'Face', 'Leakage Factor','Thickness','Elevation',  &
             'No.','No.','i      j      k','Area','of River Bed','of River Bed',  &
             '('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^3)','('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')',  &
             dash
2054    FORMAT(//tr35,a/tr5,a107/  &
             tr10,a,tr7,a,tr8,a,tr8,a,tr5,a,tr5,a,tr3,a,tr4,a/tr10,  &
             a,tr11,a,tr5,a,tr16,a,tr20,a,tr3,a/tr63,a,tr9,a,tr10,a,tr10,a/  &
             tr5,a107)
        DO lc=1,nrbc
           DO  ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
              call mtoijk(mrbc(ls),i,j,k,nx,ny)
              WRITE(fulp,2055) ls, mrbc(ls), i, j, k, mrbc_bot(lc), cnvl2i*arearbc(ls), cnvl3i*krbc(ls),  &
                   cnvli*one, cnvli*zerbc(ls)
2055          FORMAT(tr10,i5,tr6,i5,3(tr3,i4),tr3,i5,tr5,1PG11.3,tr3,1pg11.3,tr3,1pg11.3,tr3,1pg11.3)
           END DO
        END DO
     END IF
     IF(ndbc > 0) THEN
        ! ... Drain leakage b.c.
!!$        lprnt1 = -1
!!$        DO  lc=1,ndbc_cells
!!$           m = drain_seg_index(lc)%m
!!$           lprnt1(m) = 1
!!$           aprnt1(m) = lc
!!$        END DO
!!$        WRITE(fulp,2036) 'Cell Numbers for Drain Leakage B.C. Cells'
!!$        WRITE(fulp,2036) '(based on bottom elevation of lowest drain segment)'
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
!!$        WRITE(fulp,2036) 'Segment Numbers for Drain Leakage Nodes'
!!$        CALL ldchar_seg(drain_seg_index, 4, caprnt, lprnt1)
!!$        CALL prchar(2,caprnt,lprnt1,fulp,000)
        WRITE(fulp,2554)'*** Drain B.C. Data by Segment ***',  &
             dash,  &
             'Segment', 'Cell', 'Index', 'Min. Cell', 'Face', 'Leakage Factor','Thickness','Elevation',  &
             'No.','No.','i      j      k','Area','of Drain Bed','of Drain Bed',  &
             '('//TRIM(unitl)//'^2)','('//TRIM(unitl)//'^3)','('//TRIM(unitl)//')',  &
             '('//TRIM(unitl)//')',  &
             dash
2554    FORMAT(//tr35,a/tr5,a107/  &
             tr10,a,tr7,a,tr8,a,tr8,a,tr5,a,tr5,a,tr3,a,tr4,a/tr10,  &
             a,tr11,a,tr5,a,tr16,a,tr20,a,tr3,a/tr63,a,tr9,a,tr10,a,tr10,a/  &
             tr5,a107)

        DO lc=1,ndbc
           DO  ls=drain_seg_index(lc)%seg_first,drain_seg_index(lc)%seg_last
              call mtoijk(mdbc(ls),i,j,k,nx,ny)
              WRITE(fulp,2055) ls, mdbc(ls), i, j, k, mdbc_bot(lc), cnvl2i*areadbc(ls), cnvl3i*kdbc(ls),  &
                   cnvli*one, cnvli*zedbc(ls)
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
  IF(prtslm) THEN
     ! ... Calculation information
     WRITE(fulp,2063) '*** Calculation Information ***'
2063 FORMAT(/tr40,a)
     WRITE(logline1,5053) '                    *** Calculation Information ***'
5053 FORMAT(a)
     CALL logprt_c(logline1)
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
        WRITE(fulp,2064) 'Backwards-in-time (implicit) differencing for '//  &
             'temporal derivative'
2064    FORMAT(tr10,a)
!!$     WRITE(logline1,5053) 'Backwards-in-time (implicit) differencing for '//  &
!!$          'temporal derivative'
!!$     call logprt_c(logline1)
     ELSE
        WRITE(fulp,2064) 'Centered-in-time (Crank-Nicholson) differencing '//  &
             'for temporal derivative'
!!$     WRITE(logline1,5053) 'Centered-in-time (Crank-Nicholson) differencing '//  &
!!$          'for temporal derivative'
!!$     call logprt_c(logline1)
     END IF
     IF(heat .OR. solute) THEN
        IF(fdsmth < 0.5) THEN
           WRITE(fulp,2064) 'Backwards-in-space (upstream) differencing for '//  &
                'advective terms'
!!$        WRITE(logline1,5053) 'Backwards-in-space (upstream) differencing for '//  &
!!$             'advective terms'
        ELSE
           WRITE(fulp,2064) 'Centered-in-space differencing for advective terms'
!!$        WRITE(logline1,5053) 'Centered-in-space differencing for advective terms'
        END IF
!!$     call logprt_c(logline1)
        IF(crosd) THEN
           WRITE(fulp,2064) 'The cross-derivative solute flux terms '//  &
                'will be calculated explicitly'
!!$        WRITE(logline1,5053) 'The cross-derivative solute flux terms '//  &
!!$             'will be calculated explicitly'
        ELSE
           WRITE(fulp,2064) 'The cross-derivative solute flux terms '//  &
                'will NOT BE calculated'
!!$        WRITE(logline1,5053) 'The cross-derivative solute flux terms '//  &
!!$             'will NOT BE calculated'
        ENDIF
!!$     call logprt_c(logline1)
     END IF
     IF(row_scale .AND. col_scale) THEN
        WRITE(fulp,2159) 'Row and column scaling, using L-inf norm, will be done'
2159    FORMAT(/tr10,a65)
        WRITE(logline1,5201)  &
             '          Row and column scaling, using L-inf norm, will be done'
5201    FORMAT(a)
        CALL logprt_c(logline1)
     ELSEIF(row_scale .AND. .NOT.col_scale) THEN
        WRITE(fulp,2159) 'Row scaling only, using L-inf norm, will be done'
        WRITE(logline1,5201)  &
             '          Row scaling only, using L-inf norm, will be done'
        CALL logprt_c(logline1)
     ELSEIF(.NOT.row_scale .AND. col_scale) THEN
        WRITE(fulp,2159) 'Column scaling only, using L-inf norm, will be done'
        WRITE(logline1,5201)  &
             '          Column scaling only, using L-inf norm, will be done'
        CALL logprt_c(logline1)
     END IF
     IF(slmeth == 3) THEN
        WRITE(fulp,2059) 'Direction index for red-black renumbering '//dots,' IDIR..',idir,  &
             'Incomplete LU [f] or modified ILU [t] factorization '//dots,' MILU..',milu,  &
             'Number of search directions before restart '//dots,' NSDR..',nsdr,  &
             'Tolerance on iterative solution '//dots, ' EPSSLV',epsslv
2059    FORMAT(/tr10,a65,a,i5/tr10,a65,a,l5/tr10,a65,a,i5/tr10,a65,a,1PE8.1)
        WRITE(logline1,5059)  & 
             '          Direction index for red-black renumbering '//dots,' IDIR..',idir
5059    FORMAT(a65,a,i5)
        WRITE(logline2,5159)  &
             '          Incomplete LU [f] or modified ILU [t] factorization '//dots,' MILU..',milu
5159    FORMAT(a65,a,l5)
        WRITE(logline3,5059)  &
             '          Number of search directions before restart '//dots,' NSDR..',nsdr
        WRITE(logline4,5060)  &
             '          Tolerance on iterative solution '//dots,' EPSSLV',epsslv
5060    FORMAT(a65,a,1pe8.1)
        CALL logprt_c(logline1)
        CALL logprt_c(logline2)
        CALL logprt_c(logline3)
        CALL logprt_c(logline4)
     ELSE IF(slmeth == 5) THEN
        WRITE(fulp,2059) 'Direction index for d4 zig-zag renumbering '//dots,' IDIR..',idir,  &
             'Incomplete LU [f] or modified ILU [t] factorization '//dots,' MILU..',milu,  &
             'Number of search directions before restart '//dots,' NSDR..',nsdr,  &
             'Tolerance on iterative solution '//dots, ' EPSSLV',epsslv
        WRITE(logline1,5059)  &
             '          Direction index for d4 zig-zag renumbering '//dots,' IDIR..',idir
        WRITE(logline2,5159)  &
             '          Incomplete LU [f] or modified ILU [t] factorization '//dots,' MILU..',milu
        WRITE(logline3,5059)  &
             '          Number of search directions before restart '//dots,' NSDR..',nsdr
        WRITE(logline4,5060)  &
             '          Tolerance on iterative solution '//dots,' EPSSLV',epsslv
        CALL logprt_c(logline1)
        CALL logprt_c(logline2)
        CALL logprt_c(logline3)
        CALL logprt_c(logline4)
     END IF
  ENDIF
  WRITE(fulp,'(/tr1,a120)') dash
  ! ... Write zone definition data to file 'FUZF'
  ! ... Spatial mesh information
  IF(.NOT.cylind) THEN
     WRITE(fuzf,2005) rxlbl//'-Direction Node Coordinates    ('//TRIM(unitl)//')'
     CALL prntar(1,x,ibc,fuzf,cnvli,12,nx)
     WRITE(fuzf,2005) 'Y-Direction Node Coordinates   ('//TRIM(unitl)//')'
     CALL prntar(1,y,ibc,fuzf,cnvli,12,ny)
  ELSE IF(cylind) THEN
     ! ... Cylindrical aquifer geometry
     WRITE(fuzf,2006) cnvli*x(1),TRIM(unitl),cnvli*x(nr),TRIM(unitl)
     rxlbl='R'
     WRITE(fuzf,2005) rxlbl//'-Direction Node Coordinates  ('//TRIM(unitl)//')'
     CALL prntar(1,x,ibc,fuzf,cnvli,12,nr)
     WRITE(fuzf,2005) rxlbl// '-Coordinate Cell Boundary Locations ',  &
          '(between node(I) and node(I+1))   ('//TRIM(unitl)//')'
     CALL prntar(1,rm,ibc,fuzf,cnvli,112,nr-1)
  END IF
  WRITE(fuzf,2005) 'Z-Direction Node Coordinates   ('//TRIM(unitl)//')'
  CALL prntar(1,z,ibc,fuzf,cnvli,12,nz)
  IF(num_flo_zones > 0) THEN
     lprnt1 = -1
     DO  izn=1,num_flo_zones
        DO ifc=1,zone_ib(izn)%num_int_faces
           m = zone_ib(izn)%mcell_no(ifc)
           lprnt1(m) = 1
           aprnt1(m) = izn
        END DO
        IF(nsbc_cells > 0) THEN
           DO ic=1,lnk_bc2zon(izn,1)%num_bc
              m = msbc(lnk_bc2zon(izn,1)%lcell_no(ic))
              lprnt1(m) = 1
              aprnt1(m) = izn
           END DO
        END IF
        IF(nfbc_cells > 0) THEN
           DO ic=1,lnk_bc2zon(izn,2)%num_bc
              m = mfbc(lnk_bc2zon(izn,2)%lcell_no(ic))
              lprnt1(m) = 1
              aprnt1(m) = izn
           END DO
           IF(fresur) THEN
              DO ic=1,lnk_cfbc2zon(izn)%num_bc
                 m = mfbc(lnk_cfbc2zon(izn)%lcell_no(ic))
                 lprnt1(m) = 1
                 aprnt1(m) = izn
              END DO
           end IF
        END IF
        IF(nlbc_cells > 0) THEN
           DO ic=1,lnk_bc2zon(izn,3)%num_bc
              m = mlbc(lnk_bc2zon(izn,3)%lcell_no(ic))
              lprnt1(m) = 1
              aprnt1(m) = izn
           END DO
        END IF
        IF(nrbc_cells > 0 .and. fresur) THEN
           DO ic=1,lnk_crbc2zon(izn)%num_bc
              m = mrbc(lnk_crbc2zon(izn)%lcell_no(ic))
              lprnt1(m) = 1
              aprnt1(m) = izn
           END DO
        END IF
        IF(ndbc_cells > 0) THEN
           DO ic=1,lnk_bc2zon(izn,4)%num_bc
              m = mdbc(lnk_bc2zon(izn,4)%lcell_no(ic))
              lprnt1(m) = 1
              aprnt1(m) = izn
           END DO
        END IF
        IF(nwel > 0) THEN
           DO ic=1,seg_well(izn)%num_wellseg
              iwel = seg_well(izn)%iwel_no(ic)
              ks = seg_well(izn)%ks_no(ic)
              m = mwel(iwel,ks)
              lprnt1(m) = 1
              aprnt1(m) = izn
           END DO
        END IF
     END DO
     WRITE(fuzf,2036) 'Index Numbers for Flow Zones'
     CALL prntar(2,aprnt1,lprnt1,fuzf,cnv,10,000)
  END IF
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
     PRINT *, "Array deallocation aprnt5 failed: write2_1"  
  ENDIF

CONTAINS

  SUBROUTINE merge_ref (xvalt, irngt)
    ! ... Construct the index for a sort using a merge-sort algorithm
    ! ... Adapted from code of Michel Olagnon
    !   Ranks array XVALT into index array IRNGT, using merge-sort
    ! __________________________________________________________
    !   This version is not optimized for performance, and is thus
    !   not as difficult to read as some other ones.
    !   Michel Olagnon - April 2000
    ! __________________________________________________________
    USE machine_constants, ONLY: kdp
    IMPLICIT NONE
    INTEGER, DIMENSION (*), INTENT (IN)  :: xvalt
    INTEGER, DIMENSION (:), INTENT (OUT) :: irngt
    ! 
    INTEGER, DIMENSION (:), ALLOCATABLE :: jwrkt
    INTEGER :: lmtna, lmtnc
    INTEGER :: nval, iind, iwrkd, iwrk, iwrkf, jinda, iinda, iindb
    INTEGER :: a_err, da_err
    !---------------------------------------------------------------------
!$$    nval = MIN(SIZE(xvalt), SIZE(irngt))
    nval = SIZE(irngt)
    IF (nval <= 0) THEN     ! ... Nothing to sort
       RETURN
    END IF
    ! ... Fill-in the index array, creating ordered couples
    DO iind = 2, nval, 2
       IF (xvalt(iind-1) < xvalt(iind)) THEN
          irngt (iind-1) = iind - 1
          irngt (iind) = iind
       ELSE
          irngt (iind-1) = iind
          irngt (iind) = iind - 1
       END IF
    END DO
    IF (MOD(nval,2) /= 0) THEN
       irngt(nval) = nval
    END IF
    ! ... We will now have ordered subsets A - B - A - B - ...
    ! ... and merge A and B couples into     C   -   C   - ...
    ALLOCATE (jwrkt(1:nval),  &
         stat = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: merge_sort, number 1"  
       STOP
    ENDIF
    lmtnc = 2
    lmtna = 2
    ! ... Iteration. Each time, the length of the ordered subsets
    ! ...      is doubled.
    DO
       IF (lmtna >= nval) EXIT
       iwrkf = 0
       lmtnc = 2 * lmtnc
       iwrk = 0
       ! ...  Loop on merges of A and B into C
       DO
          iinda = iwrkf
          iwrkd = iwrkf + 1
          iwrkf = iinda + lmtnc
          jinda = iinda + lmtna
          IF (iwrkf >= nval) THEN
             IF (jinda >= nval) EXIT
             iwrkf = nval
          END IF
          iindb = jinda
          ! ...  Shortcut for the case when the max of A is smaller
          ! ...       than the min of B (no need to do anything)
          IF (xvalt(irngt(jinda)) <= xvalt(irngt(jinda+1))) THEN
             iwrk = iwrkf
             CYCLE
          END IF
          ! ... One steps in the C subset, that we create in the final rank array
          DO
             IF (iwrk >= iwrkf) THEN
                ! ... Make a copy of the rank index array for next iteration
                irngt(iwrkd:iwrkf) = jwrkt(iwrkd:iwrkf)
                EXIT
             END IF
             iwrk = iwrk + 1
             ! ... We still have unprocessed values in both A and B
             IF (iinda < jinda) THEN
                IF (iindb < iwrkf) THEN
                   IF (xvalt(irngt(iinda+1)) > xvalt(irngt(iindb+1))) THEN
                      iindb = iindb + 1
                      jwrkt(iwrk) = irngt(iindb)
                   ELSE
                      iinda = iinda + 1
                      jwrkt(iwrk) = irngt(iinda)
                   END IF
                ELSE
                   ! ... Only A still with unprocessed values
                   iinda = iinda + 1
                   jwrkt(iwrk) = irngt(iinda)
                END IF
             ELSE
                ! ... Only B still with unprocessed values
                irngt(iwrkd:iindb) = jwrkt(iwrkd:iindb)
                iwrk = iwrkf
                EXIT
             END IF
          END DO
       END DO
       ! ... The Cs become As and Bs
       lmtna = 2*lmtna
    END DO
    ! ... Clean up
    DEALLOCATE (jwrkt,  &
         stat = da_err)
    IF (da_err /= 0) THEN  
       PRINT *, "Array deallocation failed: merge_sort"
       STOP
    ENDIF
  END SUBROUTINE merge_ref

  SUBROUTINE mptoiwks(m,i,k,ni)
    ! ... Returns the index (I,K) of the point with
    ! ...       index M.
    !
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: m, ni
    INTEGER, INTENT(OUT) :: i, k
    !
    INTEGER :: imod
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id$'
    !     ------------------------------------------------------------------
    !...
    imod = MOD(m,ni)
    k = (m-imod)/ni + MIN(1,imod)
    i = imod
    IF (i == 0) i = ni
  END SUBROUTINE mptoiwks

END SUBROUTINE write2_1
