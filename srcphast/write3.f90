SUBROUTINE write3
  ! ... Writes well and rate data as required during simulation
  ! ...      after INIT3 and ERROR3
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
  USE mg2, ONLY: qfbcv
  USE mg3
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
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: c_mol_rbc
  CHARACTER(LEN=130) :: logline1, logline2, logline3, logline4, logline5
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: write3.f90,v $//$Revision: 2.1 $'
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
  WRITE(fulp,2003) 'Time '//dots(1:30),cnvtmi*time,'('//unittm//')'
  2003 FORMAT(/tr5,a,1PG12.3,tr2,a)
  IF(prt_bc) THEN
     IF(nsbc > 0) THEN
        lprnt1 = -1
        ! ... Print specified P,T or C b.c.
        IF(rdspbc) THEN
           DO  l=1,nsbc
              m=msbc(l)
              WRITE(cibc,6001) ibc(m)
6001          FORMAT(i9)
              IF(cibc(1:1) == '1') THEN
                 CALL mtoijk(m,i,j,k,nx,ny)
                 aprnt1(m)=z(k)+psbc(l)/(denf0*gz)
                 lprnt1(m)=1
              END IF
           END DO
           WRITE(fulp,2004) 'Specified Head B.C.: Fluid Potentiometric Head ('//unitl//')'
2004       FORMAT(/tr30,3A)
           CALL prntar(2,aprnt1,lprnt1,fulp,cnvpi,24,000)
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
!!$           CALL prntar(2,aprnt1,lprnt1,fulp,cnv,12,000)
!!$        END IF
           IF(solute) THEN
              lprnt1 = -1
              ! ... Load and compute molal concentrations
              do iis=1,ns
                 do l=1,nsbc
                    c_mol(l,iis) = csbc(l,iis)              
                 end do
              end do
              CALL convert_to_molal(c_mol,nsbc,nxyz)
              CALL ldchar(indx_sol1_bc,indx_sol2_bc,mxfrac,1,csolmask,solmask,4)
              prthd=.FALSE.
              DO  l=1,nsbc
                 m=msbc(l)
                 WRITE(cibc,6001) ibc(m)
                 IF(cibc(1:1) == '1'.AND.cibc(7:7) /= '1') THEN
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
                    CALL prntar(2,aprnt1,lprnt1,fulp,cnv,24,000)
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
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,12,000)
!!$     END IF
        IF(solute.AND.rdscbc) THEN
           lprnt1 = -1
           !        CALL convert_to_molal(csbc, nsbc, nxyz)
           CALL ldchar(indx_sol1_bc,indx_sol2_bc,mxfrac,1, csolmask,solmask,4)
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
                 CALL prntar(2,aprnt1,lprnt1,fulp,cnv,24,000)
              END IF
           END DO
        END IF
     END IF
     ! ... Flux b.c.
     IF(nfbc > 0) THEN
        lprnt1 = -1
        prnt=.FALSE.
        IF(rdflxq) THEN
           DO  l=1,nfbc
              m=mfbc(l)
              WRITE(cibc,6001) ibc(m)
              ic=INDEX(cibc(1:3),'2')
              IF(ic == 0) ic=INDEX(cibc(1:3),'8')
              IF(ic > 0) THEN
                 IF(l > lnz2) THEN
                    l1=MOD(m,nxy)
                    IF(l1 == 0) l1=nxy
                    m=mfsbc(l1)
                 END IF
                 aprnt1(m)=qfbcv(l)
                 !                  APRNT2(M)=CFLX(L)
                 !                  APRNT3(M)=CNVDI*DENFBC(L)
                 !                  APRNT4(M)=CNVT1I*TFLX(L)+CNVT2I
                 lprnt1(m)=1
                 prnt=.TRUE.
              END IF
           END DO
        END IF
        IF(prnt) THEN
           WRITE(fulp,2006) 'Flux B.C.: Fluid Volumetric Flow Rates (',unitl,'^3/',unittm,')'
           !         WRITE(FULP,2006) 'Flux B.C.: Fluid Flux (',
           !     &        UNITL,'^3/',UNITL,'^2-',UNITTM,')'
2006       FORMAT(/tr30,7A)
           CALL prntar(2,aprnt1,lprnt1,fulp,cnvl3i/cnvtmi,24,000)
           !         CALL PRNTAR(2,APRNT1,LPRNT1,FULP,CNVLI/CNVTMI,24,000)
           !            WRITE(FULP,2006) 'Associated Boundary Densities for Inflow',
           !     &           ' (',UNITM,'/',UNITL,'^3)'
           !            IFMT=12
           !            IF(EEUNIT) IFMT=13
           !            CALL PRNTAR(2,APRNT3,LPRNT1,FULP,CNV,IFMT,000)
!!$        IF(heat) THEN
!!$           WRITE(fulp,2008) 'Associated Boundary Temperatures for Inflow  ','(Deg.',unitt,')'
!!$           CALL prntar(2,aprnt4,lprnt1,fulp,cnv,12,000)
!!$        END IF
           IF(solute) THEN
              DO  m=1,nxyz
                 lprnt1(m)=-1
              END DO
              ! ... Load and compute molal concentrations
              do iis=1,ns
                 do l=1,nfbc
                    c_mol(l,iis) = cflx(l,iis)              
                 end do
              end do
              CALL convert_to_molal(c_mol,nfbc,nxyz)
              CALL ldchar(indx_sol1_bc,indx_sol2_bc,mxfrac,2,csolmask,solmask,4)
              prthd=.FALSE.
              DO  l=1,nfbc
                 m=mfbc(l)
                 WRITE(cibc,6001) ibc(m)
                 IF(cibc(7:7) /= '1') THEN
                    lprnt1(m)=1
                    prthd=.TRUE.
                 END IF
              END DO
              WRITE(fulp,2004) 'Flux B.C.: Associated solution indices'
              CALL prchar(2,csolmask,lprnt1,fulp,000)
              DO  iis=1,ns
                 DO  l=1,nfbc
                    m=mfbc(l)
                    WRITE(cibc,6001) ibc(m)
                    IF(cibc(7:7) /= '1') THEN
                       aprnt2(m)=c_mol(l,iis)
                    END IF
                 END DO
                 IF(prthd) THEN
                    WRITE(fulp,2004) 'Flux B.C.: Associated boundary '//  &
                         'molalities for inflow'
                    WRITE(fulp,2004) 'Component: ', comp_name(iis)
                    CALL prntar(2,aprnt2,lprnt1,fulp,cnv,24,000)
                 END IF
              END DO
           END IF
        END IF
!!$     IF(heat) THEN
!!$        DO  m=1,nxyz
!!$           lprnt1(m)=-1
!!$        END DO
!!$        prnt=.FALSE.
!!$        DO  l=1,nfbc
!!$           m=mfbc(l)
!!$           WRITE(cibc,6001) ibc(m)
!!$           ic=INDEX(cibc(4:6),'2')
!!$           IF(ic > 0) THEN
!!$              aprnt1(m)=qhfbc(l)
!!$              lprnt1(m)=1
!!$              prnt=.TRUE.
!!$           END IF
!!$        END DO
!!$        IF(prnt) THEN
!!$           WRITE(fulp,2008) 'Flux B.C.: Heat Flow Rates ','(diffusive only) ',' ('//unithf//')'
!!$           !             WRITE(FULP,2008) 'Flux B.C.: Heat Flux ',
!!$           !      &           '(diffusive only) ',' ('//UNITHF//'/'//UNITL//'^2)'
!!$           2008       FORMAT(/tr35,10A)
!!$           CALL prntar(2,aprnt1,lprnt1,fulp,cnvhfi,24,000)
!!$           !             CALL PRNTAR(2,APRNT1,LPRNT1,FULP,CNVHFI/CNVL2I,24,000)
!!$        END IF
!!$     END IF
        IF(solute) THEN
           lprnt1 = -1
           DO  iis=1,ns
              prthd=.FALSE.
              DO  l=1,nfbc
                 m=mfbc(l)
                 WRITE(cibc,6001) ibc(m)
                 ic=INDEX(cibc(7:9),'2')
                 IF(ic == 0) ic=INDEX(cibc(1:3),'8')
                 IF(ic > 0) THEN
                    aprnt1(m)=qsfbc(l,iis)
                    lprnt1(m)=1
                    prthd=.TRUE.
                 END IF
              END DO
              IF(prthd) THEN
                 WRITE(fulp,2004) 'Component: ', comp_name(iis)
                 WRITE(fulp,2008) 'Flux B.C.: Solute Flow Rates ','(diffusive only) ', &
                      '  (',unitm,'/',unittm,')'
2008             FORMAT(/tr30,10A)
                 !             WRITE(FULP,2008) 'Flux B.C.: Solute Flux ',
                 !      &            '(diffusive only) ','  (',UNITM,'/',UNITL,'^2-',
                 !      &             UNITTM,')'
                 CALL prntar(2,aprnt1,lprnt1,fulp,cnvmi/cnvtmi,24,000)
                 !             CALL PRNTAR(2,APRNT1,LPRNT1,FULP,CNVMFI/CNVTMI,24,000)
              END IF
           END DO
        END IF
     END IF
     ! ... Aquifer leakage b.c. transient data
     IF(nlbc > 0) THEN
        lprnt1 = -1
        prnt = .false.
        IF(rdlbc) THEN
           DO  l=1,nlbc
              m=mlbc(l)
              lprnt1(m)=1
              aprnt1(m)=philbc(l)
           END DO
           WRITE(fulp,2004) 'Leakage B.C.: Exterior Aquifer Potential Distribution ('//unitep//')'
           CALL prntar(2,aprnt1,lprnt1,fulp,cnvmei,24,000)
     !         IF(PRTDV) THEN
     !            DO 180 L=1,NLBC
     !               M=MLBC(L)
     !               APRNT1(M)=DENLBC(L)
     !  180       CONTINUE
     !            WRITE(FULP,2008) 'Exterior Aquifer Density (',
     !     &           UNITM,'/',UNITL,'^3)'
     !            IFMT=12
     !            IF(EEUNIT) IFMT=13
     !            CALL PRNTAR(2,APRNT1,LPRNT1,FULP,CNVDI,IFMT,000)
     !            DO 190 L=1,NLBC
     !               M=MLBC(L)
     !               APRNT1(M)=VISLBC(L)
     !  190       CONTINUE
     !            WRITE(FULP,2008) 'Exterior Aquifer Viscosity (',
     !     &           UNITVS,')'
     !            IFMT=24
     !            IF(EEUNIT) IFMT=15
     !            CALL PRNTAR(2,APRNT1,LPRNT1,FULP,CNVVSI,IFMT,000)
     !         ENDIF
!!$     IF(heat) THEN
!!$        DO  l=1,nlbc
!!$           m=mlbc(l)
!!$           aprnt1(m)=cnvt1i*tlbc(l)+cnvt2i
!!$        END DO
!!$        WRITE (fulp,2008) 'Leakage Boundary Temperatures for Inflow ','(Deg.',unitt,')'
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,12,000)
!!$     END IF
           IF(solute) THEN
              ! ... Load and compute molal concentrations
              do iis=1,ns
                 do l=1,nlbc
                    c_mol(l,iis) = clbc(l,iis)              
                 end do
              end do
              CALL convert_to_molal(c_mol,nlbc,nxyz)
              CALL ldchar(indx_sol1_bc,indx_sol2_bc,mxfrac,3,csolmask,solmask,4)
              WRITE(fulp,2004) 'Leakage B.C.: Associated solution indices'
              CALL prchar(2,csolmask,lprnt1,fulp,000)
              DO  iis=1,ns
                 prthd=.FALSE.
                 DO  l=1,nlbc
                    m=mlbc(l)
                    aprnt1(m)=c_mol(l,iis)
                    prthd=.TRUE.
                 END DO
                 IF(prthd) THEN
                    WRITE(fulp,2004) 'Leakage B.C.: '//'Associated boundary molalities for inflow'
                    WRITE(fulp,2004) 'Component: ', comp_name(iis)
                    CALL prntar(2,aprnt1,lprnt1,fulp,cnv,24,000)
                 END IF
              END DO
           END IF
        END IF
     END IF
     ! ... River leakage b.c. transient data
     IF(nrbc > 0) THEN
        lprnt1 = -1
        if (rdrbc) then 
           DO  lc=1,nrbc 
              m = mrbc_bot(lc)
              lprnt1(m) = 1
              aprnt1(m) = lc
           END DO
           !*** This should be a nodal printout with each segment number listed for each
           !***     river cell
           WRITE(fulp,2004) 'River Leakage B.C: River Cell Numbers (lowest river bottom)'
           CALL prntar(2,aprnt1,lprnt1,fulp,cnv,10,000)
           ! ... No spatial display of transient leakage data; by segment
           WRITE(fulp,2124)'River Leakage B.C.: Segment Data',dash,  &
                'Segment','Cell','Head','Index 1','Index 2','Fraction 1',  &
                'No.','No.','('//unitl//')', dash
2124       FORMAT(//tr30,a/tr10,a95/tr15,a,tr3,a,tr11,a,tr11,a,tr3,a,tr2,a/tr15,a,tr7,a,tr12,a/tr10,a95)
           DO lc=1,nrbc
              DO  ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
                 WRITE(fulp,2125) ls,mrbc_bot(lc),cnvli*phirbc(ls)/gz,indx_sol1_bc(4,ls), &
                      indx_sol2_bc(4,ls), mxfrac(4,ls)
2125             FORMAT(tr15,i5,tr5,i3,tr9,1PG12.4,I10,I10,F10.4)
              END DO
           END DO
           IF(solute) THEN
              nsa = max(ns,1)
              ! ...  scratch space in case nrbc_seg > nxyz, not likely
              ALLOCATE (c_mol_rbc(nrbc_seg, nsa), &
                   stat = a_err)
              IF (a_err /= 0) THEN  
                 PRINT *, "Array allocation failed: write3"  
                 STOP
              ENDIF
              ! ... Compute and load molal concentrations
              do iis=1,ns
                 do ls=1,nrbc_seg
                    c_mol_rbc(ls,iis) = crbc(ls,iis)
                 end do
              end do
              CALL convert_to_molal(c_mol_rbc,nrbc_seg,nrbc_seg)
!!$           ! ... Load and print solution indices
!!$           CALL ldchar(indx_sol1_bc,indx_sol2_bc,mxfrac,4, csolmask,solmask,4)
!!$           WRITE(fulp,2004) 'River leakage b.c.: Associated solution indices'
!!$           CALL prchar(2,csolmask,lprnt1,fulp,000)
              WRITE(fulp,2224)'River Leakage B.C.: Solute Component Data',dash,  &
                   'Segment','Cell','Associated Concentration',  &
                   'No.','No.','(mol/kg)', dash
2224          FORMAT(//tr30,a/tr10,a95/ tr15,a,tr3,a,tr7,a/tr15,a,tr7,a,tr9,a/tr10,a95)
              DO  iis=1,ns
                 WRITE(fulp,2104) 'Component: ',comp_name(iis)
2104             FORMAT(/tr15,3A)
                 DO lc=1,nrbc
                    DO  ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
                       WRITE(fulp,2125) ls,mrbc_bot(lc),c_mol_rbc(ls,iis)
                    END DO
                 END DO
              END DO
              DEALLOCATE (c_mol_rbc, &
                   stat = da_err)
              IF (da_err /= 0) THEN  
                 PRINT *, "Array deallocation failed, c_mol_rbc"  
                 STOP  
              ENDIF
           END IF
        END IF
     END IF
!!$  ! ... Evapotranspiration b.c. transient data
!!$  IF(netbc > 0) THEN
!!$     !...** not available for PHAST
!!$     DO  m=1,nxyz
!!$        lprnt1(m)=-1
!!$     END DO
!!$     DO  l=1,netbc
!!$        m=metbc(l)
!!$        lprnt1(m)=1
!!$        aprnt1(m)=qetbc(l)
!!$     END DO
!!$     WRITE(fulp,2008) 'Maximum Evapotranspiration Volumetric Flow ','Rates (',unitl,'^3/',unittm,')'
!!$     CALL prntar(2,aprnt1,lprnt1,fulp,cnvl3i/cnvtmi,24,000)
!!$  END IF
!!$  IF(naifc > 0) THEN
!!$     !... ** not available for PHAST
!!$     DO  m=1,nxyz
!!$        lprnt1(m)=-1
!!$     END DO
!!$     IF(prtdv) THEN
!!$        DO  l=1,naifc
!!$           m=maifc(l)
!!$           lprnt1(m)=1
!!$           aprnt1(m)=denoar(l)
!!$        END DO
!!$        WRITE(fulp,2008) 'A.I.F. Exterior Aquifer Region Density ('//unitm//'/'//unitl//'^3)'
!!$        ifmt=12
!!$        IF(eeunit) ifmt=13
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnvdi,ifmt,000)
!!$     END IF
!!$     IF(heat) THEN
!!$        DO  l=1,naifc
!!$           m=maifc(l)
!!$           aprnt1(m)=cnvt1i*taif(l)+cnvt2i
!!$        END DO
!!$        WRITE (fulp,2008) 'A.I.F. Boundary Temperatures for Inflow ','(Deg.',unitt,')'
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,12,000)
!!$     END IF
!!$     IF(solute) THEN
!!$        DO  l=1,naifc
!!$           m=maifc(l)
!!$           aprnt1(m)=caif(l)
!!$           IF(scalmf) aprnt1(m)=(aprnt1(m)-w0)/(w1-w0)
!!$        END DO
!!$        WRITE (fulp,2004) 'A.I.F. Boundary '//mflbl//'Fractions for ','Inflow ( - )'
!!$        CALL prntar(2,aprnt1,lprnt1,fulp,cnv,15,000)
!!$     END IF
!!$  END IF
  END IF
  ! ... Well data
  IF(nwel > 0 .AND. prtwel .AND. .NOT.steady_flow) THEN
     WRITE(fuwel,2009) '*** Transient Well Data ***',  &
          'Well', 'Flow Rate','Surface','Well Datum','Head', 'Injection or Limiting',  &
          'No. ','('//unitl//'^3/'//unittm//')','Head', 'Head','Limited?','Solution Index No.',  &
          '('//unitl//')','('//unitl//')','(-)',dash
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
  IF(.NOT.autots) then
     WRITE(fulp,2013) 'Fixed time step length .......',dots,' DELTIM ',cnvtmi*deltim,  &
          '  ('//unittm//')'
2013 FORMAT(/tr10,a,a35,a,1pg10.3,a)
     WRITE(logline1,5013)  'Fixed time step length .......',dots,' DELTIM ',cnvtmi*deltim,  &
          '  ('//unittm//')'
5013 FORMAT(a,a35,a,1pg10.3,a)
  ELSEIF(autots) then
     aprnt1(1)=dctas(1)
     WRITE(fulp,2014) 'Automatic Time Step Control Parameters',  &
       'Maximum pressure change allowed per time step'//dots,  &
       ' DPTAS  ',cnvpi*dptas,'('//unitp//')', &
  !     &     'Maximum temperature change allowed per time step '//DOTS,
  !     &     ' DTTAS  ',CNVT1I*DTTAS,'(Deg.',UNITT,')',  &
       'Maximum '//mflbl//'fraction change allowed per time step '  &
       //dots,' DCTAS  ',aprnt1(1),'(-)',  &
       'Minimum time step required '//dots,' DTIMMN ',cnvtmi*dtimmn,'('//unittm//')',  &
       'Maximum time step allowed '//dots,' DTIMMX ',cnvtmi*dtimmx,'('//unittm//')'
2014 FORMAT(/tr20,a/  &
          tr10,a65,a,1PG10.2,tr2,a/tr10,a65,a,1PG10.2,tr2,a/  &
          tr10,a65,a,1PG10.2,tr2,a/tr10,a65,a,1PG10.2,tr2,a/  &
          tr10,a65,a,1PG10.2,tr2,a/tr10,a65,a,1PG10.2,tr2,a)
     WRITE(logline1,5014) 'Automatic Time Step Control Parameters'
5014 format(a)
     WRITE(logline2,5114) 'Maximum pressure change allowed per time step'//dots,  &
       ' DPTAS  ',cnvpi*dptas,'  ('//unitp//')'
5114 FORMAT(a65,a,1PG10.2,a)
     WRITE(logline3,5114) 'Maximum '//mflbl//'fraction change allowed per time step '  &
       //dots,' DCTAS  ',aprnt1(1),'  (-)'
     WRITE(logline4,5114) 'Minimum time step required '//dots,' DTIMMN ',  &
       cnvtmi*dtimmn,'  ('//unittm//')'
     WRITE(logline5,5114) 'Maximum time step allowed '//dots,' DTIMMX ',  &
          cnvtmi*dtimmx,'('//unittm//')'
     call logprt_c(logline1)
     call logprt_c(logline2)
     call logprt_c(logline3)
     call logprt_c(logline4)
     call logprt_c(logline5)
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
  call logprt_c(logline1)
  WRITE(fulp,2017) dash
2017 FORMAT(/tr1,a120)
  WRITE(logline1,5017) dash
5017 FORMAT(a95)
  ! call logprt_c(logline1)
  DEALLOCATE (csolmask, solmask, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed"  
     STOP  
  ENDIF
END SUBROUTINE write3
