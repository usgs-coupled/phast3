SUBROUTINE write3
  ! ... Writes well and rate data as required during simulation
  ! ...      after INIT3 and ERROR3
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
  USE mg3_m
  IMPLICIT NONE
  INCLUDE 'ifwr.inc'
  INTRINSIC INDEX
  CHARACTER(LEN=11) :: blank = '           ', ucc, up1c, up2c, uqc, utc
  CHARACTER(LEN=4) :: limit
  CHARACTER(LEN=9) :: cibc
  REAL(KIND=kdp), PARAMETER :: cnv = 1._kdp
  INTEGER :: a_err, da_err, i, ic, ifmt, iis, iwel, j, k, l, l1, lc, ls, m, nsa
  LOGICAL :: prnt, prthd
  CHARACTER(LEN=11), DIMENSION(:), ALLOCATABLE :: csolmask
  INTEGER, DIMENSION(:), ALLOCATABLE :: solmask
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: c_mol_bc
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4, logline5
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Allocate scratch space
  ALLOCATE (csolmask(nxyz), solmask(nxyz), &
       stat = a_err)
  IF (a_err.NE.0) THEN  
     PRINT *, "Array allocation failed: write3"  
     STOP  
  ENDIF
  WRITE(fulp,2001) dash
2001 FORMAT(tr1,a120)
  WRITE(fulp,2002)
2002 FORMAT(//tr40,'*** Transient Data ***')
  WRITE(fulp,2003) 'Time '//dots(1:30),cnvtmi*time,'('//TRIM(unittm)//')'
2003 FORMAT(/tr5,a,1PG12.3,tr2,a)
  IF(prt_bc) THEN
     IF(nsbc > 0) THEN
        lprnt1 = -1
        ! ... Print specified P,T or C b.c.
        IF(rdspbc) THEN
           DO  l=1,nsbc
              m=msbc(l)
              WRITE(cibc,6001) ibc(m)
6001          FORMAT(i9.9)
              IF(cibc(1:1) == '1') THEN
                 CALL mtoijk(m,i,j,k,nx,ny)
                 aprnt1(m)=z(k)+psbc(l)/(denf0*gz)
                 lprnt1(m)=1
              END IF
           END DO
           WRITE(fulp,2004) 'Specified Head B.C.: Fluid Potentiometric Head ('//TRIM(unitl)//')'
2004       FORMAT(/tr30,3A)
           CALL printar(2,aprnt1,lprnt1,fulp,cnvpi,24,000)
!!$        IF(heat) THEN
!!$           prthd=.FALSE.
!!$           DO  l=1,nsbc
!!$              m=msbc(l)
!!$              lprnt1(m)=-1
!!$              WRITE(cibc,6001) ibc(m)
!!$              IF(cibc(1:1) == '1'.AND.cibc(4:4) /= '1') THEN
!!$                 aprnt1(m)=cnvt1i*tsbc(l)+cnvt2i
!!$                 lprnt1(m)=1
!!$                 prthd=.TRUE.
!!$              END IF
!!$           END DO
!!$           IF(prthd) WRITE(fulp,2004)  &
!!$                'Associated boundary temperatures for inflow  ', '(Deg.'//unitt//')'
!!$           CALL printar(2,aprnt1,lprnt1,fulp,cnv,12,000)
!!$        END IF
           IF(solute) THEN
              lprnt1 = -1
              ! ... Load and compute molal concentrations
              DO iis=1,ns
                 DO l=1,nsbc
                    c_mol(l,iis) = csbc(l,iis)              
                 END DO
              END DO
              CALL RM_convert_to_molal(c_mol,nsbc,nxyz)
              CALL ldchar_bc(indx1_sbc, indx2_sbc, mxf_sbc, 1, csolmask, solmask, msbc)
              prthd=.FALSE.
              DO  l=1,nsbc
                 m=msbc(l)
                 WRITE(cibc,6001) ibc(m)
                 IF(cibc(1:1) == '1' .AND. cibc(7:7) /= '1') THEN
                    lprnt1(m)=1
                    prthd=.TRUE.
                 END IF
              END DO
              WRITE(fulp,2004) 'Specified Head B.C.: Associated solution indices'
              CALL prchar(2,csolmask,lprnt1,fulp,000)
              DO  iis=1,ns
                 DO  l=1,nsbc
                    m=msbc(l)
                    WRITE(cibc,6001) ibc(m)
                    IF(cibc(1:1) == '1'.AND.cibc(7:7) /= '1') THEN
                       aprnt1(m)=c_mol(l,iis)
                    END IF
                 END DO
                 IF(prthd) THEN
                    WRITE(fulp,2004) 'Specified Head B.C.: Associated boundary '//   &
                         'molalities for inflow'
                    WRITE(fulp,2004) 'Component: ', comp_name(iis)
                    CALL printar(2,aprnt1,lprnt1,fulp,cnv,24,000)
                 END IF
              END DO
           END IF
        END IF
!!$     IF(heat.AND.rdstbc) THEN
!!$        DO  m=1,nxyz
!!$           lprnt1(m)=-1
!!$        END DO
!!$        DO  l=1,nsbc
!!$           m=msbc(l)
!!$           WRITE(cibc,6001) ibc(m)
!!$           IF(cibc(4:4) == '1') THEN
!!$              aprnt1(m)=cnvt1i*tsbc(l)+cnvt2i
!!$              lprnt1(m)=1
!!$           END IF
!!$        END DO
!!$        WRITE(fulp,2004) 'Specified boundary temperatures  (Deg.'//unitt//')'
!!$        CALL printar(2,aprnt1,lprnt1,fulp,cnv,12,000)
!!$     END IF
        IF(solute .AND. rdscbc) THEN
           lprnt1 = -1
           ! CALL convert_to_molal(csbc, nsbc, nxyz)
           CALL ldchar_bc(indx1_sbc, indx2_sbc, mxf_sbc, 1, csolmask, solmask, msbc)
           prthd=.FALSE.
           DO  l=1,nsbc
              m=msbc(l)
              WRITE(cibc,6001) ibc(m)
              IF(cibc(7:7) == '1') THEN
                 lprnt1(m)=1
                 prthd=.TRUE.
              END IF
           END DO
           WRITE(fulp,2004) 'Specified solution indices'
           CALL prchar(2,csolmask,lprnt1,fulp,000)
           DO  iis=1,ns
              DO  l=1,nsbc
                 m=msbc(l)
                 WRITE(cibc,6001) ibc(m)
                 IF(cibc(7:7) == '1') THEN
                    aprnt1(m)=c_mol(l,iis)
                 END IF
              END DO
              IF(prthd) THEN
                 WRITE(fulp,2004) 'Component: ', comp_name(iis)
                 WRITE(fulp,2004) 'Specified boundary molalities'
                 CALL printar(2,aprnt1,lprnt1,fulp,cnv,24,000)
              END IF
           END DO
        END IF
     END IF
     ! ... Flux b.c.
     IF(nfbc > 0) THEN
        lprnt1 = -1
        prnt=.FALSE.
        IF(rdflxq) THEN
           ! ... No spatial display of transient flux data; by segment ****at present
           WRITE(fulp,2124) 'Specified Flux B.C.: Segment Data',  &
                dash,  &
                'Segment','Cell','Index','Flux     ','Index 1','Index 2','Mix Fraction',  &
                'No.','No.', 'i       j       k',  &
                '('//TRIM(unitl)//'^2/'//TRIM(unittm)//')',  &
                dash
2124       FORMAT(//tr30,a/tr10,a95/tr15,a,tr3,a,tr11,a,tr20,a,tr3,a,tr3,a,tr2,a/tr15,  &
                a,tr7,a,tr6,a/  &
                tr64,a/tr10,a95)
           DO ls=1,nfbc_seg
              call mtoijk(mfbc(ls),i,j,k,nx,ny)
              WRITE(fulp,2125) ls, mfbc(ls), i, j, k, (cnvl2i/cnvtmi)*qfflx(ls), indx1_fbc(ls),  &
                   indx2_fbc(ls), mxf_fbc(ls)
2125          FORMAT(tr15,i5,tr5,i3,3(tr4,i4),tr9,1PG12.4,I10,I10,tr2,0PF10.4)
           END DO
           IF(solute) THEN
              nsa = MAX(ns,1)
              ! ...  scratch space in case nfbc_seg > nxyz, not likely
              ALLOCATE (c_mol_bc(nfbc_seg,nsa),  &
                   stat = a_err)
              IF (a_err /= 0) THEN  
                 PRINT *, "Array allocation failed: write3"  
                 STOP
              ENDIF
              ! ... Compute and load molal concentrations
              DO iis=1,ns
                 DO ls=1,nfbc_seg
                    c_mol_bc(ls,iis) = cfbc(ls,iis)
                 END DO
              END DO
              CALL RM_convert_to_molal(c_mol_bc,nfbc_seg,nfbc_seg)
              WRITE(fulp,2324) 'Specified Flux B.C.: Solute Component Data',dash,  &
                   'Segment','Cell','Associated Concentration',  &
                   'No.','No.','(mol/kg)', dash
2324          FORMAT(//tr30,a/tr10,a95/ tr15,a,tr3,a,tr7,a/tr15,a,tr7,a,tr9,a/tr10,a95)
              DO  iis=1,ns
                 WRITE(fulp,2104) 'Component: ',comp_name(iis)
2104             FORMAT(/tr15,3A)
                 DO ls=1,nfbc_seg
                    WRITE(fulp,2325) ls, mfbc(ls), c_mol_bc(ls,iis)
2325                FORMAT(tr15,i5,tr5,i3,tr9,1PG12.4,I10,I10,tr2,0PF10.4)
                 END DO
                 CALL ldchar_bc(indx1_fbc, indx2_fbc, mxf_fbc, 1, csolmask, solmask, mfbc)
              END DO
              DEALLOCATE (c_mol_bc, &
                   stat = da_err)
              IF (da_err /= 0) THEN  
                 PRINT *, "Array deallocation failed"  
                 STOP
              ENDIF
           END IF
        END IF
        IF(rdflxs) THEN
           WRITE(fulp,2008) 'Flux B.C.: Solute Flow Rates ','(diffusive only) ', &
                '  ('//TRIM(unitm)//'/'//TRIM(unittm)//')'
2008       FORMAT(/tr30,10A)
           DO  iis=1,ns
              WRITE(fulp,2104) 'Component: ', comp_name(iis)           
              DO  ls=1,nfbc_seg
                 WRITE(fulp,2325) ls, mfbc(ls), qsflx(ls,iis)
              END DO
           END DO
        END IF
     END IF
     ! ... Aquifer leakage b.c. transient data
     IF(nlbc > 0) THEN
        lprnt1 = -1
        IF(rdlbc) THEN
           ! ... No spatial display of transient leakage data; by segment
           WRITE(fulp,2224) 'Aquifer Leakage B.C.: Segment Data',  &
                dash,  &
                'Segment','Cell','Index','Head','Index 1','Index 2','Mix Fraction',  &
                'No.','No.', 'i       j       k',  &
                '('//TRIM(unitl)//')',  &
                dash
2224       FORMAT(//tr30,a/tr10,a95/tr15,a,tr3,a,tr12,a,tr18,a,tr10,a,tr3,a,tr2,a/tr15,  &
                a,tr7,a,tr7,a/  &
                tr65,a/tr10,a95)
           DO ls=1,nlbc_seg
              call mtoijk(mlbc(ls),i,j,k,nx,ny)
              WRITE(fulp,2225) ls, mlbc(ls), i, j, k, cnvli*philbc(ls)/gz, indx1_lbc(ls),  &
                   indx2_lbc(ls), mxf_lbc(ls)
2225          FORMAT(tr15,i5,tr5,i3,3(tr4,i4),tr9,1PG12.4,I10,I10,tr3,0PF10.4)
           END DO
           IF(solute) THEN
              nsa = MAX(ns,1)
              ! ...  scratch space in case nlbc_seg > nxyz, not likely
              ALLOCATE (c_mol_bc(nlbc_seg,nsa),  &
                   stat = a_err)
              IF (a_err /= 0) THEN  
                 PRINT *, "Array allocation failed: write3"  
                 STOP
              ENDIF
              ! ... Compute and load molal concentrations
              DO iis=1,ns
                 DO ls=1,nlbc_seg
                    c_mol_bc(ls,iis) = clbc(ls,iis)
                 END DO
              END DO
              CALL RM_convert_to_molal(c_mol_bc,nlbc_seg,nlbc_seg)
              WRITE(fulp,2324) 'Aquifer Leakage B.C.: Solute Component Data',  &
                   dash,  &
                   'Segment','Cell','Associated Concentration',  &
                   'No.','No.','(mol/kg)', dash
              DO  iis=1,ns
                 WRITE(fulp,2104) 'Component: ',comp_name(iis)
                 DO ls=1,nlbc_seg
                    WRITE(fulp,2325) ls, mlbc(ls), c_mol_bc(ls,iis)
                 END DO
                 CALL ldchar_bc(indx1_lbc, indx2_lbc, mxf_lbc, 3, csolmask, solmask, mlbc)
              END DO
              DEALLOCATE (c_mol_bc,  &
                   stat = da_err)
              IF (da_err /= 0) THEN 
                 PRINT *, "Array deallocation failed"  
                 STOP
              ENDIF
           END IF
        END IF
     END IF
     ! ... River leakage b.c. transient data
     IF(nrbc > 0) THEN
        lprnt1 = -1
        IF (rdrbc) THEN 
!!$           DO  lc=1,nrbc 
!!$              m = mrbc_bot(lc)
!!$              lprnt1(m) = 1
!!$              aprnt1(m) = lc
!!$           END DO
!!$           !*** This should be a nodal printout with each segment number listed for each
!!$           !***     river cell
!!$           WRITE(fulp,2004) 'River Leakage B.C: River Cell Numbers (lowest river bottom)'
!!$           CALL printar(2,aprnt1,lprnt1,fulp,cnv,10,000)
           ! ... No spatial display of transient river leakage data; by segment
           WRITE(fulp,2224) 'River Leakage B.C.: Segment Data',  &
                dash,  &
                'Segment','Cell','Index','Head','Index 1','Index 2','Mix Fraction',  &
                'No.','No.','i       j       k',  &
                '('//TRIM(unitl)//')', dash
           DO lc=1,nrbc
              call mtoijk(mrbc_bot(lc),i,j,k,nx,ny)
              DO  ls=river_seg_first(lc),river_seg_last(lc)
                 WRITE(fulp,2225) ls, mrbc_bot(lc), i, j, k, cnvli*phirbc(ls)/gz, indx1_rbc(ls),  &
                      indx2_rbc(ls), mxf_rbc(ls)
              END DO
           END DO
           IF(solute) THEN
              nsa = MAX(ns,1)
              ! ...  scratch space in case nrbc_seg > nxyz, not likely
              ALLOCATE (c_mol_bc(nrbc_seg,nsa),  &
                   stat = a_err)
              IF (a_err /= 0) THEN  
                 PRINT *, "Array allocation failed: write3"  
                 STOP
              ENDIF
              ! ... Compute and load molal concentrations
              DO iis=1,ns
                 DO ls=1,nrbc_seg
                    c_mol_bc(ls,iis) = crbc(ls,iis)
                 END DO
              END DO
              CALL RM_convert_to_molal(c_mol_bc,nrbc_seg,nrbc_seg)
              ! ... Load and print solution indices ****** not built yet for segments
!!$           CALL ldchar_bc(indx1_rbc, indx2_rbc, mxf_rbc, 4, csolmask, solmask, mrbc)
!!$           WRITE(fulp,2004) 'River leakage B.C.: Associated solution indices'
!!$           CALL prchar(2,csolmask,lprnt1,fulp,000)
              WRITE(fulp,2324) 'River Leakage B.C.: Solute Component Data',  &
                   dash,  &
                   'Segment','Cell','Associated Concentration',  &
                   'No.','No.','(mol/kg)', dash
              DO  iis=1,ns
                 WRITE(fulp,2104) 'Component: ',comp_name(iis)
                 DO lc=1,nrbc
                    DO  ls=river_seg_first(lc),river_seg_last(lc)
                       WRITE(fulp,2325) ls, mrbc_bot(lc), c_mol_bc(ls,iis)
                    END DO
                 END DO
              END DO
              DEALLOCATE (c_mol_bc,  &
                   stat = da_err)
              IF (da_err /= 0) THEN  
                 PRINT *, "Array deallocation failed"  
                 STOP
              ENDIF
           END IF
        END IF
     END IF
     ! ... Drain leakage b.c. transient data: nothing to be done
!!$  ! ... Evapotranspiration b.c. transient data
!!$     !...** not available for PHAST
  END IF
  ! ... Well data
  IF(nwel > 0 .AND. prtwel .AND. .NOT.steady_flow) THEN
     WRITE(fuwel,2009) '*** Transient Well Data ***',  &
          'Well', 'Flow Rate','Surface','Well Datum','Head', 'Injection or Limiting',  &
          'No. ','('//TRIM(unitl)//'^3/'//TRIM(unittm)//')','Head', 'Head','Limited?','Solution Index No.',  &
          '('//TRIM(unitl)//')','('//TRIM(unitl)//')','(-)',dash
2009 FORMAT(//tr40,a/tr10,a,tr6,a,tr5,a,tr5,a,tr5,a,tr10,  &
          a/tr10,a,tr7,a,tr5,a,tr10,a,tr6,a,tr10,a/tr35,a,tr10,a,tr30,a/tr8,a90)
     DO  iwel=1,nwel
        uqc=BLANK
        IF(wqmeth(iwel) /= 20.AND.wqmeth(iwel) /= 40) WRITE(uqc,2010)(cnvl3i/cnvtmi)*qwv(iwel)
2010    FORMAT(1PG11.4)
        up1c=BLANK
        !            IF(WQMETH(IWEL).GE.40) WRITE(UP1C,2010)
        !     &             CNVPI*(PWSURS(IWEL)/(den0*gz)+ZWT(IWEL)+riserlen)
        up2c=BLANK
        IF(wqmeth(iwel) == 20.OR.wqmeth(iwel) == 30) &
             WRITE(up2c,2010) cnvli*(pwkt(iwel)/(den0*gz)+zwt(iwel))   !*** incorrect head
        limit='No '
        IF(wqmeth(iwel) == 30.OR.wqmeth(iwel) == 50) limit='Yes'
        utc=BLANK
        IF(qwv(iwel) > 0..AND.heat) WRITE(utc,2010) cnvt1i*twsrkt(iwel)+cnvt2i
        ucc=BLANK
        IF(solute) THEN
           IF(qwv(iwel) < 0.) lprnt1(1)=indx1_wel(iwel)
           IF(qwv(iwel) > 0.) lprnt1(1)=indx1_wel(iwel)
           IF(qwv(iwel) > 0. .OR. MOD(wqmeth(iwel),10) > 1) WRITE(ucc,2110) lprnt1(1)
2110       FORMAT(i4)
        END IF
        WRITE(fuwel,2011) welidno(iwel),uqc,up1c,up2c,limit,utc,ucc
2011    FORMAT(tr10,i3,3(tr5,a),a,2a)
     END DO
  END IF
  WRITE(fulp,2012) '*** Calculation Information ***'
2012 FORMAT(//tr40,a)
  IF(.NOT.prtslm) GO TO 300
  IF(.NOT.autots) THEN
     WRITE(fulp,2013) 'Fixed time step length .......',dots,' DELTIM ',cnvtmi*deltim,  &
          '  ('//TRIM(unittm)//')'
2013 FORMAT(/tr10,a,a35,a,1pg10.3,a)
     WRITE(logline1,5013)  'Fixed time step length .......',dots,' DELTIM ',cnvtmi*deltim,  &
          '  ('//TRIM(unittm)//')'
5013 FORMAT(a,a35,a,1pg10.3,a)
  ELSEIF(autots) THEN
     aprnt1(1)=dctas(1)
     WRITE(fulp,2014) 'Automatic Time Step Control Parameters',  &
          'Maximum pressure change allowed per time step'//dots,  &
          ' DPTAS  ',cnvpi*dptas,'('//TRIM(unitp)//')', &
                                !     &     'Maximum temperature change allowed per time step '//DOTS,
                                !     &     ' DTTAS  ',CNVT1I*DTTAS,'(Deg.',UNITT,')',  &
          'Maximum '//mflbl//'fraction change allowed per time step '  &
          //dots,' DCTAS  ',aprnt1(1),'(-)',  &
          'Minimum time step required '//dots,' DTIMMN ',cnvtmi*dtimmn,'('//TRIM(unittm)//')',  &
          'Maximum time step allowed '//dots,' DTIMMX ',cnvtmi*dtimmx,'('//TRIM(unittm)//')'
2014 FORMAT(/tr20,a/  &
          tr10,a65,a,1PG10.2,tr2,a/tr10,a65,a,1PG10.2,tr2,a/  &
          tr10,a65,a,1PG10.2,tr2,a/tr10,a65,a,1PG10.2,tr2,a/  &
          tr10,a65,a,1PG10.2,tr2,a/tr10,a65,a,1PG10.2,tr2,a)
     WRITE(logline1,5014) 'Automatic Time Step Control Parameters'
5014 FORMAT(a)
     WRITE(logline2,5114) 'Maximum pressure change allowed per time step'//dots,  &
          ' DPTAS  ',cnvpi*dptas,'  ('//TRIM(unitp)//')'
5114 FORMAT(a65,a,1PG10.2,a)
     WRITE(logline3,5114) 'Maximum '//mflbl//'fraction change allowed per time step '  &
          //dots,' DCTAS  ',aprnt1(1),'  (-)'
     WRITE(logline4,5114) 'Minimum time step required '//dots,' DTIMMN ',  &
          cnvtmi*dtimmn,'  ('//TRIM(unittm)//')'
     WRITE(logline5,5114) 'Maximum time step allowed '//dots,' DTIMMX ',  &
          cnvtmi*dtimmx,'('//TRIM(unittm)//')'
     CALL logprt_c(logline1)
     CALL logprt_c(logline2)
     CALL logprt_c(logline3)
     CALL logprt_c(logline4)
     CALL logprt_c(logline5)
  END IF
  !....***replace with ht type time step reasons
!!$  IF(primin > 0) THEN
!!$     WRITE(fulp,2015)  &
!!$          'Maximum time step determined by print frequency '//dots,  &
!!$          'PRIMIN',ABS(primin),'('//unittm//')'
!!$2015 FORMAT(tr10,a65,a,i8,tr2,a)
!!$     WRITE(logline1,5015)  &
!!$          'Maximum time step determined by print frequency '//dots,  &
!!$          'PRIMIN',ABS(primin),'  ('//unittm//')'
!!$5015 FORMAT(a65,a,i8,a)
!!$     call logprt_c(logline1)
!!$  END IF
300 WRITE(fulp,2016) 'Time at which next set of transient',  &
       'parameters will be read '//dots,' TIMCHG ', cnvtmi*timchg,  &
       '('//TRIM(unittm)//')'
2016 FORMAT(tr10,a/tr15,a60,a,1PG10.3,tr2,a)
  WRITE(logline1,5116)  '     Time at which next set of transient '//  &
       'parameters will be read '//dots,' TIMCHG ', cnvtmi*timchg,  &
       '  ('//TRIM(unittm)//')'
5116 FORMAT(a75,a,1PG10.3,a)
  CALL logprt_c(logline1)
  WRITE(fulp,2017) dash
2017 FORMAT(/tr1,a120)
  WRITE(logline1,5017) dash
5017 FORMAT(a95)
  !**  ! call logprt_c(logline1)
  DEALLOCATE (csolmask, solmask, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed"  
     STOP  
  ENDIF
END SUBROUTINE write3
