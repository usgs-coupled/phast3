SUBROUTINE read3
  ! ... Reads time varying data at time of change during simulation
  ! ...      well rates, boundary conditions
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcc
  USE mcg
  USE mcp
  USE mcv
  USE mcw
  USE mg3
  IMPLICIT NONE
  INCLUDE 'ifrd.inc'
  CHARACTER(LEN=80) :: line
  REAL(KIND=kdp) :: uhrbc, umxfrac, uq
  INTEGER :: a_err, ic, icall, irecrbc, iis, iwel, uwelseqno, uisolw,  &
       uisolrbc1, uisolrbc2
  INTEGER, SAVE :: ntd=0
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Check for end of simulation
  READ(fuins,*) thru
  if (print_rde) WRITE(furde,8001) 'THRU,[3.1]or[3.99]',thru
  8001 FORMAT(tr5,a/tr5,8L5)
  IF(thru) RETURN
  ntd = ntd+1
  ! ... Allocate the temporary group 3 arrays
  ALLOCATE ( pnp(nxyz), qff(nxyz), qffx(nxyz), qffy(nxyz), qffz(nxyz), &
       qhfx(nxyz), qhfy(nxyz), qhfz(nxyz), &
       tnp(1), ucbc(nxyz), udenbc(nxyz), udenlb(nxyz), uphilb(nxyz), uphirb(nxyz), &
       uqetb(nxyz), uqs(ns), utbc(1), uvislb(nxyz), &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: read3"  
     STOP  
  ENDIF
  WRITE(logline1,'(a,i2)') 'Reading transient data for simulation: Set ',ntd
  CALL logprt_c(logline1)
  prtbc=.FALSE.
  prtslm=.FALSE.
  prtwel=.FALSE.
  ! ... Well information transient parameters
  IF(nwel > 0) THEN
     READ(fuins,*) rdwtd
     if (print_rde) WRITE(furde,8001) 'RDWTD,[3.2.1]',rdwtd
     IF(rdwtd) THEN
        prtwel=.TRUE.
        if (print_rde) WRITE(furde,8002) 'WEL_SEQNO,QWV,INDX_SOL,[3.2.2]'
        8002    FORMAT(tr5,2A)
10      READ(fuins,'(A)') line
        ic=INDEX(line(1:20),'END')
        IF(ic == 0) ic=INDEX(line(1:20),'end')
        IF(ic > 0) GO TO 30
        BACKSPACE(UNIT=fuins)
        READ(fuins,*) uwelseqno,uq,uisolw
        if (print_rde) WRITE(furde,8003) uwelseqno,uq,uisolw
        8003    FORMAT(tr5,i5,tr2,1PG12.4,tr2,i5)
        IF(uwelseqno > nwel) GO TO 20
        iwel=uwelseqno
        qwv(iwel)=cnvvf*uq
        indx1_wel(iwel)=uisolw
        GO TO 10
20      ierr(117)=.TRUE.
        GO TO 10
     END IF
30   CONTINUE
  END IF
  IF(nsbc > 0) THEN
     READ(fuins,*) rdspbc,rdstbc,rdscbc
     if (print_rde) WRITE(furde,8001) 'RDSPBC,RDSTBC,RDSCBC,[3.3.1]', rdspbc,rdstbc,rdscbc
     ! ... Specified value P,T or C - input by x,y,z range
     IF(rdspbc.OR.rdstbc.OR.rdscbc) prtbc=.TRUE.
     IF(rdspbc) THEN
        CALL rewi(pnp,301,106)
        IF(heat) CALL rewi(utbc,313,109)
        IF(solute) THEN
           ! ... Read specified b.c. solutions into csbc
           CALL indx_rewi_bc(indx_sol1_bc,indx_sol2_bc,mxfrac,1, 113,127)
        END IF
     END IF
     IF(rdstbc) CALL rewi(tnp,303,171)
     IF(rdscbc) THEN
        ! rdscbc always false, otherwise conflict with previous call to indx_rewi_bc
        IF(solute) THEN
           ! ... Read specified b.c. solutions into csbc
           CALL indx_rewi_bc(indx_sol1_bc,indx_sol2_bc,mxfrac,1, 13,127)
        END IF
     END IF
  END IF
  IF(nfbc > 0) THEN
     READ(fuins,*) rdflxq,rdflxh,rdflxs
     if (print_rde) WRITE(furde,8001) 'RDFLXQ,RDFLXH,RDFLXS,[3.4.1]', rdflxq,rdflxh,rdflxs
     IF(rdflxq) THEN
        ! ... Specified fluid flux b.c. - input by x,y,z range
        ! ...      volumetric fluxes
        prtbc=.TRUE.
        CALL rewi(qff,321,111)
        ! ... Associated density for inflow
        CALL rewi(udenbc,325,121)
        ! ... Associated temperature and mass fraction
        IF(heat) CALL rewi(utbc,323,112)
        IF(solute) THEN
           ! ... Read associated b.c. solutions into cfbc
           CALL indx_rewi_bc(indx_sol1_bc,indx_sol2_bc,mxfrac,2, 213,127)
        END IF
     END IF
     ! ... Heat and solute diffusive fluxes for no flow b.c.
     ! ...     Read in as 3 vector components
     IF(rdflxh) THEN
        CALL rewi3(qhfx,qhfy,qhfz,4,132)
     END IF
     IF(rdflxs) THEN
        DO  iis=1,ns
           qsfxis => qsfx(:,iis)
           qsfyis => qsfy(:,iis)
           qsfzis => qsfz(:,iis)
           CALL rewi3(qsfxis,qsfyis,qsfzis,5,114)
        END DO
     END IF
  END IF
  ! ... Aquifer leakage b.c. transient parameters
  IF(nlbc > 0) THEN
     READ(fuins,*) rdlbc
     if (print_rde) WRITE(furde,8001) 'RDLBC,[3.5.1]',rdlbc
     IF(rdlbc) THEN
        prtbc=.TRUE.
        CALL rewi(uphilb,1,124)
        CALL rewi(udenlb,2,124)
        CALL rewi(uvislb,3,124)
        IF(heat) CALL rewi(utbc,333,125)
        IF(solute) THEN
           ! ... Read associated b.c. solutions into clbc
           CALL indx_rewi_bc(indx_sol1_bc,indx_sol2_bc,mxfrac,3, 313,127)
        END IF
     END IF
  END IF
  ! ... River leakage b.c. transient parameters
  IF(nrbc > 0) THEN
     READ(fuins,*) rdrbc
     if (print_rde) WRITE(furde,8001) 'RDRBC,[3.5.1]',rdrbc
     IF(rdrbc) THEN
        if (print_rde) WRITE(furde,8004)  '** River Leakage Parameters **',  &
             '  (read echo[3.5.5])',' ',  &
             '  IRECRBC, HRBC,  ISOLRBC1, ISOLRBC2, MXFRACRBC'
8004    FORMAT(tr5,2A/tr10,a)
90      READ(fuins,'(A)') line
        ic=INDEX(line(1:20),'END')
        IF(ic == 0) ic=INDEX(line(1:20),'end')
        IF(ic > 0) GO TO 140
        BACKSPACE(UNIT=fuins)
        READ(fuins,*) irecrbc,uhrbc,uisolrbc1,uisolrbc2,umxfrac
        if (print_rde) WRITE(furde,8005) irecrbc,uhrbc,uisolrbc1,uisolrbc2,umxfrac
8005    FORMAT(tr1,i5,1PG11.3,2I5,f10.2)
!        imrbc=mrbc(irecrbc)
        uphirb(irecrbc)=gz*uhrbc
        IF(solute) THEN
           indx_sol1_bc(4,irecrbc)=uisolrbc1
           indx_sol2_bc(4,irecrbc)=uisolrbc2
           mxfrac(4,irecrbc)=umxfrac
        END IF
        GO TO 90
     END IF
  END IF
140 CONTINUE
!!$  IF(naifc > 0) THEN
!!$     !...***   not implemented for PHAST
!!$     READ(fuins,*) rdaif
!!$     if (print_rde) WRITE(furde,8001) 'RDAIF,[3.7.1]',rdaif
!!$     ! ... A.I.F. b.c. associated density, temperature and mass fraction
!!$     ! ...      for outer region
!!$     IF(rdaif) THEN
!!$        prtbc=.TRUE.
!!$        CALL rewi(udenbc,345,121)
!!$        IF(heat) CALL rewi(utbc,343,122)
!!$        !            IF(SOLUTE) CALL REWI(UCBC,344,123)
!!$     END IF
!!$  END IF
  READ(fuins,*) rdcalc
  if (print_rde) WRITE(furde,8001) 'RDCALC,[3.8.1]',rdcalc
  IF(rdcalc) THEN
     prtslm=.TRUE.
     ! ... Calculation information
     READ(fuins,*) autots
     if (print_rde) WRITE(furde,8001) 'AUTOTS,[3.8.2]',autots
     IF(.NOT.autots) THEN
        READ(fuins,*) deltim
        if (print_rde) WRITE(furde,8006) 'DELTIM,[3.8.3A]',deltim
8006    FORMAT(tr5,a/tr5,10(1PG12.5))
     END IF
     IF(autots) THEN
        READ(fuins,*) dptas,dttas,dtimmn,dtimmx
        if (print_rde) WRITE(furde,8007) 'DPTAS,DTTAS,DTIMMN,DTIMMX,',  &
             '[3.8.3B]',dptas,dttas,dtimmn,dtimmx
8007    FORMAT(tr5,2A/tr5,10(1PG12.5))
        IF(solute) THEN
           READ(fuins,*) (dctas(iis),iis=1,ns)
           if (print_rde) WRITE(furde,8007) 'DCTAS(iis),iis=1,ns', '[3.8.3B]',(dctas(iis),iis=1,ns)
        END IF
        !...   *** well control not documented yet  ***
        !            READ(FUINS,*) DPTAS,DTTAS,DCTAS,DTIMMN,DTIMMX,DTIMU
        !            if (print_rde) WRITE(FURDE,8007) 'DPTAS,DTTAS,DCTAS,DTIMMN,DTIMMX,DTIMU',
        !     &           '[3.8.3B]',DPTAS,DTTAS,DCTAS,DTIMMN,DTIMMX,DTIMU
        ! 830        FORMAT(TR5,2A/TR5,10(1PG12.5))
     ELSEIF(steady_flow) THEN
        READ(fuins,*) dptas,dttas,dtimmn,dtimmx
        if (print_rde) WRITE(furde,8007) 'DPTAS,DTTAS,DTIMMN,DTIMMX,',  &
             '[3.8.3B]',dptas,dttas,dtimmn,dtimmx
     END IF
  END IF
  ! ... Time of next change in transient data
  READ(fuins,*) timchg
  if (print_rde) WRITE(furde,8006) 'TIMCHG,[3.8.4]',timchg
  ! ... Output information
  ! ... Print interval for output tables at end of time step
  READ(fuins,*) prislm, prikd, prip, pric, pricphrq, priforce_chem_phrq, privel, prigfb,  &
       pribcf, priwel
  if (print_rde) WRITE(furde,8008) 'PRISLM,PRIKD,PRIP,PRIC,PRICPHRQ,PRIFORCE_CHEM_PRHQ,PRIVEL,PRIGFB,',  &
       'PRIBCF,PRIWEL,[3.9.1]', prislm,prikd,prip,pric,pricphrq,priforce_chem_phrq,  &
       privel,prigfb,pribcf,priwel
8008 FORMAT(tr5,2A/tr5,11F10.2)
  READ(fuins,*) prt_bc
  IF (print_rde) WRITE(furde,8308) 'PRT_BC,[3.9.1.1]', prt_bc
8308 FORMAT(tr5,A/tr5,l5)
  ! ... ***special patch pnambc
       prislm = -prislm
       prikd = -prikd
       prip = -prip
       pric = -pric
       pricphrq = -pricphrq
       priforce_chem_phrq = -priforce_chem_phrq
       privel = -privel
       prigfb = -prigfb
       pribcf = -pribcf
       priwel = -priwel
  !      IF(PRIP.NE.0.OR.PRIC.NE.0) THEN
  !         READ(FUINS,*) IPRPTC
  !         if (print_rde) WRITE(FURDE,8009) 'IPRPTC,[3.9.2]',IPRPTC
  ! 8009    FORMAT(TR5,A/TR5,8I5)
  !      ENDIF
  READ(fuins,*) prihdf_conc, prihdf_head, prihdf_vel
  if (print_rde) WRITE(furde,8108) 'prihdf_conc, prihdf_head, prihdf_vel, [3.9.2]',  &
       prihdf_conc, prihdf_head, prihdf_vel
8108 FORMAT(tr5,A/tr5,11F10.2)
  prihdf_conc = -prihdf_conc
  prihdf_head = -prihdf_head
  prihdf_vel = -prihdf_vel
  READ(fuins,*) prtichead
  if (print_rde) WRITE(furde,8208) 'prtichead, [3.9.2.1]', prtichead
8208 FORMAT(tr5,A/tr5,l5)
  READ(fuins,*) chkptd,pricpd,savldo
  if (print_rde) WRITE(furde,8010) 'CHKPTD,PRICPD,SAVLDO [3.9.3]',  &
       chkptd,pricpd,savldo
8010 FORMAT(tr5,a/tr5,l5,f5.2,l5)
  ! ... ***special patch
  pricpd = -pricpd
  ! ... Contour plots, vector plots
  READ(fuins,*) cntmaph,primaphead,cntmapc,primapcomp,vecmap,primapv
  if (print_rde) WRITE(furde,8011) 'cntmaph,primaphead,cntmapc,primapcomp,vecmap,primapv,[3.10.1]',  &
       cntmaph,primaphead,cntmapc,primapcomp,vecmap,primapv
8011 FORMAT(tr5,a/tr5,3(l5,f8.2))
  ! ... ***special patch
  primaphead = -primaphead
  primapcomp = -primapcomp
  primapv = -primapv
  ! ... Well data time series
  READ(fuins,*) pri_well_timser
  if (print_rde) WRITE(furde,8111) 'pri_well_timser,[3.10.2]',  &
       pri_well_timser
8111 FORMAT(tr5,a/tr5,f10.2)
  ! ... ***special patch
  pri_well_timser = -pri_well_timser
  if (solute) then
     ! ... Print control index for .O.chem concentrations on a sub-grid
     icall = 8
     call irewi(iprint_chem, icall, 125)
     ! ... Print control index for .xyz.chem concentrations on a sub-grid
     icall = 9
     call irewi(iprint_xyz, icall, 125)
  endif
END SUBROUTINE read3
