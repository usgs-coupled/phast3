SUBROUTINE write2_2
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
  USE mcv
  USE mcw
  USE mg2
  USE phys_const
  IMPLICIT NONE
  INCLUDE 'ifwr.inc'
  CHARACTER(LEN=4) :: uword
  CHARACTER(LEN=11) :: chu2, chu3, fmt1
  CHARACTER(LEN=39) :: fmt2, fmt4
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
  REAL(kind=kdp) :: u1, u2, u3, u4, u5, u6, u7, ucnvi, x1z,  &
       x2z, y1z, y2z, z1z, z2z
  INTEGER :: i, ifmt, ifu, indx, ipmz, iis, iwel, iwq1, iwq2, iwq3, j,  &
       jprptc, k, ks, kwb, kwt, l, m, mb, mt, nks
  ! ... Set the unit numbers for node point output
  INTEGER, DIMENSION(12), PARAMETER :: fu =(/16,21,22,23,26,27,0,0,0,0,0,0/)
  INTEGER :: nr
  REAL(kind=kdp), PARAMETER :: cnv = 1._kdp
  REAL(KIND=kdp) :: ph, alk
  INTEGER :: da_err
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  mflbl=' mass '
  rxlbl='X'
  nr = nx
  ! ... Load and compute molal concentrations
  c_mol = c
  CALL convert_to_molal(c_mol,nxyz,nxyz)
  IF(nwel > 0) THEN
     IF(solute .AND. prtic_well_timser) THEN
        ! ... Write static data to file 'FUPLT' for temporal plots
        WRITE(fmt2,"(a,i2,a)") '(tr1,4(1pe15.7,a),i3,a,',ns+2,'(1pe15.7,a)) '
        DO  iwel=1,nwel
           m=mwel(iwel,nkswel(iwel))
           u1=cnvtmi*time
           u2=0._kdp
           ! ... Observation well Q=0 at initial conditions
           u2=p(m)/(den0*gz)+zwt(iwel)
!!$           IF(heat) u4=t(m)
           ! ... Well has ambient cell concentrations at initial conditions
           iis = 1
           CALL calculate_well_ph(c(m,iis), ph, alk)
           WRITE(fuplt,fmt2) cnvli*xw(iwel),achar(9),cnvli*yw(iwel),achar(9),  &
                cnvli*zwt(iwel),achar(9),cnvtmi*time,achar(9),iwel,achar(9),  &
                (c(m,iis),achar(9),iis=1,ns),ph,achar(9), alk, achar(9)
        END DO
        ntprtem = ntprtem+1
     END IF
  END IF
  IF(prtic_p .or. prtic_c) THEN
     IF(errexi) GO TO 390
     ! ... Print initial condition distributions and aquifer properties
     DO  m=1,nxyz
        IF(ibc(m) == -1) THEN
           lprnt1(m)=-1
        ELSE
           lprnt1(m)=1
        END IF
     END DO
     IF(prtic_p .AND. .NOT.steady_flow) THEN
        WRITE(fup,2048) '*** Initial Conditions ***'
2048    FORMAT(//tr40,a)
        IF(ichydp) WRITE(fup,2017)  &
             'Aquifer fluid pressure for hydrostatic i.c. '//dots,  &
             ' PINIT. ',cnvpi*pinit,'(',unitp,')',  &
             'Elevation of pressure for hydrostatic i.c '//dots,  &
             ' ZPINIT ',cnvli*zpinit,'(',TRIM(unitl),')'
2017    FORMAT(/tr25,a60,a,f10.1,tr2,3A/tr25,a60,a,f10.1,tr2,3A)
!!$     WRITE(fulp,2014) 'Initial Pressure Distribution  (',unitp,')'
!!$     WRITE(fup,2014) 'Initial Pressure Distribution  (',unitp,')'
!!$     CALL prntar(2,p,lprnt1,fulp,cnvpi,24,000)
!!$     CALL prntar(2,p,lprnt1,fup,cnvpi,24,000)
!!$     IF(heat.OR.iprptc/100 /= 2) GO TO 330
!!$     WRITE(fulp,2050) 'Initial Fluid Head  (',TRIM(unitl),') '
        WRITE(fup,2050) 'Initial Fluid Head  (',TRIM(unitl),') '
2050    FORMAT(/tr30,4A/)
        ifmt=13
        IF(eeunit) ifmt=12
!!$     CALL prntar(2,hdprnt,lprnt1,fulp,cnvli,ifmt,000)
        CALL prntar(2,hdprnt,lprnt1,fup,cnvli,ifmt,000)
        ntprp = ntprp+1
     END IF
!!$330 IF(heat) THEN
!!$     jprptc=MOD(iprptc,100)/10
!!$     IF(jprptc >= 1) THEN
!!$        WRITE(fulp,2014) 'Initial Temperatures (Deg.',unitt,')'
!!$        WRITE(fut,2014) 'Initial Temperatures (Deg.',unitt,')'
!!$        DO  m=1,nxyz
!!$           aprnt1(m)=cnvt1i*t(m)+cnvt2i
!!$        END DO
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,12,000)
!!$        CALL prntar(2,aprnt1,lprnt1,fut,cnv,12,000)
!!$     END IF
!!$     IF(jprptc == 2) THEN
!!$        DO  m=1,nxyz
!!$           aprnt1(m)=(cnvhei/cnvmi)*eh(m)
!!$        END DO
!!$        WRITE(fulp,2014) 'Initial Specific Enthalpy (',unith,'/' ,unitm,')'
!!$        WRITE(fut,2014) 'Initial Specific Enthalpy (',unith,'/' ,unitm,')'
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,24,000)
!!$        CALL prntar(2,aprnt1,lprnt1,fut,cnv,24,000)
!!$     END IF
!!$  END IF
     IF(solute .AND. prtic_c) THEN
        WRITE(fuc,2048) '*** Initial Conditions ***'
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,mxfrac,1,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Solution Indices and Mixing Fraction'
2051    FORMAT(/tr30,a)
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,mxfrac,2,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Equilibrium-Phase Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,mxfrac,3,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Exchange Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,mxfrac,4,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Surface Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,mxfrac,5,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Gas-Phase Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,mxfrac,6,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Solid-Solution Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,mxfrac,7,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Kinetic-Reaction Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        DO  iis=1,ns
           DO  m=1,nxyz
              aprnt1(m)=c_mol(m,iis)
           END DO
           WRITE(fuc, 2051) 'Initial Molality (mol/kgw)'
           WRITE(fuc,2014) 'Component: ',comp_name(iis)
2014       FORMAT(/tr30,8A)
           CALL prntar(2,aprnt1,lprnt1,fuc,cnv,24,000)
        END DO
        ntprc = ntprc+1
     END IF
     IF(prtpmp) THEN
        uword='    '
        IF(cylind) uword='Ring'
        WRITE(fulp,2014) 'Initial Pore Volume Per Cell '//uword//' (',TRIM(unitl),'^3)'
        CALL prntar(2,pv,lprnt1,fulp,cnvl3i,24,000)
        WRITE(fulp,2031) 'Specific Storage Per Cell '//uword//' ('//TRIM(unitl) //'^-1)'
2031    FORMAT(tr30,a)
        CALL prntar(2,ss,lprnt1,fulp,1.d0/cnvli,24,000)
     END IF
     IF(fresur .AND. .NOT.steady_flow .AND. prtic_p) THEN
        DO  m=1,nxyz
           IF(ibc(m) == -1.OR.frac(m) <= 0.d0) THEN
              lprnt1(m)=-1
           ELSE
              lprnt1(m)=1
           END IF
        END DO
!!$     WRITE(fulp,2014) 'Fraction of Cell That Is Saturated (-)'
        WRITE(fup,2014) 'Fraction of Cell That Is Saturated (-)'
!!$     CALL prntar(2,frac,lprnt1,fulp,cnv,13,000)
        CALL prntar(2,frac,lprnt1,fup,cnv,13,000)
     END IF
!!$  IF(prtdv) THEN
!!$     WRITE(fulp,2114) 'Fluid Density in Cell (',unitm,'/',TRIM(unitl),'^3)',  &
!!$          den(1)
!!$     WRITE(fud,2114) 'Fluid Density in Cell (',unitm,'/',TRIM(unitl),'^3)',  &
!!$          den(1)
!!$     2114 FORMAT(/tr10,a,tr2,1PG12.2)
!!$     WRITE(fulp,2114) 'Fluid Viscosity in Cell (',unitvs,')', vis(1)
!!$     WRITE(fuvs,2114) 'Fluid Viscosity in Cell (',unitvs,')', vis(1)
!!$  END IF
     ! ... Print initial amounts
     WRITE(fulp,2052) 'Initial fluid in region '//dots,cnvmi*fir0,'(',unitm  &
          ,') ;',cnvl3i*firv0,'(',TRIM(unitl),'^3)'
2052 FORMAT(/tr20,a55,1PE14.6,tr2,3A,e14.6,tr2,3A)
!!$  IF(heat) WRITE(fulp,2052)  &
!!$       'Initial heat in region (fluid & porous medium)'//dots, cnvhei*ehir0,'(',unith,')'
     DO  iis=1,ns
        WRITE(fulp,2052) 'Initial solute in region:'//comp_name(iis)//dots,  &
             cnvmi*sir0(iis), '(',unitm,')'
     END DO
  endif
390 WRITE(fulp,2060) dash
2060 FORMAT(/tr1,a120)
!!$  ! ... Write static data to file 'FUPMAP' for screen or plotter maps
!!$  WRITE(fupmap,5005) (ibc(m),m=1,nxyz)
!!$  5005 FORMAT(12I10)
!!$  WRITE(fupmap,5006) (cnvli*x(i),i=1,nx)
!!$  5006 FORMAT(8(1PG15.7))
!!$  WRITE(fupmap,5006) (cnvli*y(j),j=1,ny)
!!$  WRITE(fupmap,5006) (cnvli*z(k),k=1,nz)
  ! ... Write initial condition data to file FUPMAP for screen or plotter maps
  IF(solute .AND. prtic_mapc) THEN
     WRITE(fmt4,"(a,i2,a)") '(tr1,4(1pg11.3,a),i3,a,',ns,'(1pg11.3,a))'
     DO m=1,nxyz
        IF(ibc(m) /= -1) THEN
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(frac(m) < 0.0001_kdp) THEN
              indx = 0
              WRITE(fupmap,fmt4) cnvli*x(i),achar(9),cnvli*y(j),achar(9),cnvli*z(k),  &
                   achar(9),cnvtmi*time,achar(9),indx,achar(9)
           ELSE
              indx = 1
              WRITE(fupmap,fmt4) cnvli*x(i),achar(9),cnvli*y(j),achar(9),cnvli*z(k),  &
                   achar(9),cnvtmi*time,achar(9),indx,achar(9),(c_mol(m,is),achar(9),is=1,ns)
           END IF
        END IF
     END DO
!!$        WRITE(fupmap,5102) ' Time Step No. ',itime,' Time ',cnvtmi*time,' ('//unittm//')'
!!$        5102    FORMAT(a,i5,a,1PG12.3,3A)
!!$        DO  is=1,ns
!!$           WRITE(fupmap,5203) 'Molality (mol/kgw)'//'   Component: ', comp_name(is)
!!$5203       FORMAT(tr30,8A)
!!$           DO  m=1,nxyz
!!$              aprnt1(m)=c_mol(m,is)
!!$           END DO
!!$           WRITE(fupmap,5106) (aprnt1(m),m=1,nxyz)
!!$5106       FORMAT(11(1pe11.3))
!!$        END DO
  ENDIF
!!$  ! ... Write static data to file 'FUPMP2' for potentiometric head or free surface plots
!!$  WRITE(fupmp2,5005) (ibc(m),m=1,nxyz)
!!$  WRITE(fupmp2,5006) (cnvli*x(i),i=1,nx)
!!$  WRITE(fupmp2,5006) (cnvli*y(j),j=1,ny)
!!$  WRITE(fupmp2,5006) (cnvli*z(k),k=1,nz)
  IF(prtic_maphead .AND. .NOT.steady_flow) THEN     ! ... if s.s. flow head map written in write5
     DO m=1,nxyz
        IF(ibc(m) /= -1) THEN
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(frac(m) < 0.0001_kdp) THEN
              indx = 0
              WRITE(fupmp2,8003) cnvli*x(i),achar(9),cnvli*y(j),achar(9),cnvli*z(k),  &
                   achar(9),cnvtmi*time,achar(9),indx,achar(9)
           ELSE
              indx = 1
              WRITE(fupmp2,8003) cnvli*x(i),achar(9),cnvli*y(j),achar(9),cnvli*z(k),  &
                   achar(9),cnvtmi*time,achar(9),indx,achar(9),cnvli*hdprnt(m),achar(9)
8003          FORMAT(4(1pg15.6,a),i5,a,1pg15.6,a)
           ENDIF
        END IF
     END DO
!!$     WRITE(fupmp2,5102) ' Time Step No. ',itime,' Time ',cnvtmi*time,' ('//unittm//')'
!!$     WRITE(fupmp2,5103) 'Initial Fluid Head'
!!$5103 FORMAT(a100)
!!$     WRITE(fupmp2,5104) (cnvli*hdprnt(m),m=1,nxyz)
!!$5104 FORMAT(10(f12.3))
  ENDIF
  ! ... Write initial condition data to FUVMAP for velocity plots
  !*****TO BE ADDED
!!$  ! ... Write static data to file 'FUVMAP' for velocity plots
!!$  WRITE(fuvmap,5005) (ibc(m),m=1,nxyz)
!!$  WRITE(fuvmap,5006) (cnvli*x(i),i=1,nx)
!!$  WRITE(fuvmap,5006) (cnvli*y(j),j=1,ny)
!!$  WRITE(fuvmap,5006) (cnvli*z(k),k=1,nz)
END SUBROUTINE write2_2
