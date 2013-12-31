SUBROUTINE write2_2
  ! ... Write the parameter data after READ2
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcb_m
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
  USE mg2_m
  USE phys_const
  IMPLICIT NONE
  INCLUDE 'IPhreeqc.f90.inc'
  INCLUDE 'RM_interface.f90.inc'
  INCLUDE 'ifwr.inc'
  CHARACTER(LEN=4) :: uword
!!$  CHARACTER(LEN=11) :: chu2, chu3, fmt1
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
  REAL(kind=kdp) :: u1, u2
  INTEGER :: i, ifmt, ifu, indx, ipmz, iis, iwel, j,  &
       jprptc, k, ks, kwb, kwt, l, m, mb, mt, mfs, nks
  ! ... Set the unit numbers for node point output
  INTEGER, DIMENSION(12), PARAMETER :: fu =(/16,21,22,23,26,27,0,0,0,0,0,0/)
  INTEGER :: nr
  REAL(kind=kdp), PARAMETER :: cnv = 1._kdp
  REAL(KIND=kdp) :: ph, alk
  INTEGER :: da_err
  INTEGER :: a_err
  CHARACTER(LEN=100) :: string, svalue
  INTEGER :: iphreeqc_id, nthreads, status, vtype
  DOUBLE PRECISION, DIMENSION(100) :: c_well
  DOUBLE PRECISION :: tc, p_atm
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: write2_2.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  ALLOCATE (lprnt3(nxyz),  &
       STAT = a_err)  
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: write2_2"  
     STOP  
  ENDIF
  mflbl=' mass '
  rxlbl='X'
  nr = nx
  ! ... Load and compute molal concentrations
  c_mol = c
  CALL RM_convert_to_molal(rm_id, c_mol(1,1), nxyz, nxyz)
  IF(nwel > 0) THEN
     nthreads = RM_GetNThreads(rm_id)
     iphreeqc_id = RM_GetIPhreeqcId(rm_id, nthreads + 1)
     string = "SELECTED_OUTPUT; -reset false; -pH; -alkalinity"
     status = RunString(iphreeqc_id, string)
     string = "RUN_CELLS; -cell 0"
     IF(solute .AND. prtic_well_timser) THEN
        ! ... Write static data to file 'FUPLT' for temporal plots
        WRITE(fmt2,"(a,i2,a)") '(tr1,4(1pe15.7,a),i3,a,',ns+2,'(1pe15.7,a)) '
        DO  iwel=1,nwel
           m=mwel(iwel,nkswel(iwel))
           u1=cnvtmi*time
           u2=0._kdp
           ! ... Observation well Q=0 at initial conditions
           u2=p(m)/(den0*gz)+zwt(iwel)
           ! ... Well has ambient cell concentrations at initial conditions
           iis = 1
           !CALL RM_calculate_well_ph(c(m,iis), ph, alk)
           tc = 25.0
           p_atm = 1.0
           do i = 1, ns
               c_well(i) = c(m,i)
           enddo       
           iphreeqc_id = RM_Concentrations2Utility(rm_id, c_well(1), 1, 1, tc, p_atm)
           status = RM_ErrorHandler(rm_id, iphreeqc_id, 1, "write2_2, RM_Concentrations2Utility");
           status = RunString(iphreeqc_id, string)
           status = GetSelectedOutputValue(iphreeqc_id, 1, 1, vtype, pH, svalue)
           status = GetSelectedOutputValue(iphreeqc_id, 1, 2, vtype, alk, svalue)
           WRITE(fuplt,fmt2) cnvli*xw(iwel),ACHAR(9),cnvli*yw(iwel),ACHAR(9),  &
                cnvli*zwt(iwel),ACHAR(9),cnvtmi*time,ACHAR(9),iwel,ACHAR(9),  &
                (c(m,iis),ACHAR(9),iis=1,ns),ph,ACHAR(9), alk, ACHAR(9)
        END DO
        ntprtem = ntprtem+1
     END IF
  END IF
  IF(prtic_p .OR. prtic_c) THEN
     IF(errexi) GO TO 390
     ! ... Print initial condition distributions and aquifer properties
     DO  m=1,nxyz
        IF(ibc(m) == -1.OR.frac(m) <= 0.0_kdp) THEN
        !IF(ibc(m) == -1) THEN
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
!!$     CALL printar(2,p,lprnt1,fulp,cnvpi,24,000)
!!$     CALL printar(2,p,lprnt1,fup,cnvpi,24,000)
!!$     IF(heat.OR.iprptc/100 /= 2) GO TO 330
!!$     WRITE(fulp,2050) 'Initial Fluid Head  ('//TRIM(unitl)//') '
        WRITE(fup,2050) 'Initial Fluid Head  ('//TRIM(unitl)//') '
2050    FORMAT(/tr30,a/)
        ifmt=13
        IF(eeunit) ifmt=12
!!$     CALL printar(2,hdprnt,lprnt1,fulp,cnvli,ifmt,000)
        CALL printar(2,hdprnt,lprnt1,fup,cnvli,ifmt,000)
        IF(fresur) THEN
           lprnt3 = -1
           DO  mt=1,nxy
              mfs = mfsbc(mt)
              IF(mfs /= 0) THEN
                 lprnt3(mt) = 1
                 aprnt1(mt) = wt_elev(mt)
              END IF
           END DO
           WRITE(fuwt,2050) 'Initial Water-Table Elevation  ('//TRIM(unitl)//') '
           CALL printar(2,aprnt1,lprnt3,fuwt,cnvli,ifmt,000)
        END IF
        ntprp = ntprp+1
     END IF
     IF(solute .AND. prtic_c) THEN
        WRITE(fuc,2048) '*** Initial Conditions ***'
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,ic_mxfrac,1,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Solution Indices and Mixing Fraction'
2051    FORMAT(/tr30,a)
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,ic_mxfrac,2,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Equilibrium-Phase Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,ic_mxfrac,3,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Exchange Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,ic_mxfrac,4,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Surface Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,ic_mxfrac,5,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Gas-Phase Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,ic_mxfrac,6,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Solid-Solution Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        CALL ldchar(indx_sol1_ic,indx_sol2_ic,ic_mxfrac,7,caprnt,lprnt1,7)
        WRITE(fuc,2051) 'Initial Kinetic-Reaction Indices and Mixing Fraction'
        CALL prchar(2,caprnt,lprnt1,fuc,000)
        DO  iis=1,ns
           DO  m=1,nxyz
              aprnt1(m)=c_mol(m,iis)
           END DO
           WRITE(fuc, 2051) 'Initial Molality (mol/kgw)'
           WRITE(fuc,2014) 'Component: ',comp_name(iis)
2014       FORMAT(/tr30,8A)
           CALL printar(2,aprnt1,lprnt1,fuc,cnv,24,000)
        END DO
        ntprc = ntprc+1
     END IF
     IF(prtpmp) THEN
        uword='    '
        IF(cylind) uword='Ring'
        WRITE(fulp,2014) 'Initial Pore Volume Per Cell '//uword//' (',TRIM(unitl),'^3)'
        CALL printar(2,pv,lprnt1,fulp,cnvl3i,24,000)
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
!!$     CALL printar(2,frac,lprnt1,fulp,cnv,13,000)
        CALL printar(2,frac,lprnt1,fup,cnv,13,000)
     END IF
!    IF(prtdv) THEN
!        WRITE(fulp,2114) 'Fluid Density in Cell (',unitm,'/',TRIM(unitl),'^3)',  &
!            den0
!    WRITE(fud,2114) 'Fluid Density in Cell (',unitm,'/',TRIM(unitl),'^3)',  &
!            den0
!2114 FORMAT(/tr10,a,tr2,1PG12.2)
!        WRITE(fulp,2114) 'Fluid Viscosity in Cell (',unitvs,')', vis0
!        WRITE(fuvs,2114) 'Fluid Viscosity in Cell (',unitvs,')', vis0
!    END IF
     ! ... Print initial amounts
     WRITE(fulp,2052) 'Initial fluid in region '//dots,cnvmi*fir0,'(',unitm  &
          ,') ;',cnvl3i*firv0,'(',TRIM(unitl),'^3)'
2052 FORMAT(/tr15,a55,1PE14.6,tr2,3A,e14.6,tr2,3A)
     DO  iis=1,ns
        WRITE(fulp,2052) 'Initial solute in region:'//comp_name(iis)//dots,  &
             cnvmi*sir0(iis), '(',unitm,')'
     END DO
  ENDIF
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
              WRITE(fupmap,fmt4) cnvli*x(i),ACHAR(9),cnvli*y(j),ACHAR(9),cnvli*z(k),  &
                   ACHAR(9),cnvtmi*time,ACHAR(9),indx,ACHAR(9)
           ELSE
              indx = 1
              WRITE(fupmap,fmt4) cnvli*x(i),ACHAR(9),cnvli*y(j),ACHAR(9),cnvli*z(k),  &
                   ACHAR(9),cnvtmi*time,ACHAR(9),indx,ACHAR(9),(c_mol(m,is),ACHAR(9),is=1,ns)
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
                      ACHAR(9),cnvtmi*time,ACHAR(9),cnvli*wt_elev(mt),ACHAR(9)
8203             FORMAT(3(1pg15.6,a),1pg15.6,a)
           END IF
        END DO
     END IF
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
  DEALLOCATE (lprnt3,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: write2_2, number d1"  
  ENDIF

END SUBROUTINE write2_2
