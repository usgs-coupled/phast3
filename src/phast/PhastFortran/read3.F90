SUBROUTINE read3
  ! ... Reads time varying data at time of change during simulation;
  ! ...      well rates, boundary conditions
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcb_m
  USE mcb2_m, ONLY: num_flo_zones
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg3_m
  USE print_control_mod
  USE rewi_mod
  USE PhreeqcRM
  IMPLICIT NONE
  INCLUDE 'ifrd.inc'
  INTERFACE
     FUNCTION uppercase(string) RESULT(outstring)
       IMPLICIT NONE
       CHARACTER(LEN=*), INTENT(IN) :: string
       CHARACTER(LEN=LEN(string)) :: outstring
     END FUNCTION uppercase
  END INTERFACE
  CHARACTER(LEN=130) :: line
  REAL(KIND=kdp) :: uhbc, umxfrac, upsbc, uq, uqfflx, uqsflx
  INTEGER :: ic, icall, isegbc, iis, iwel, uwelseqno, uisolw,  &
       uisolbc1, uisolbc2
  INTEGER, SAVE :: ntd=0
  CHARACTER(LEN=130) :: logline1
  INTEGER :: status
  !-----------------------------------------------------------------------
  !...
  ! ... Check for end of simulation
  READ(fuins,*) thru
  IF (print_rde) WRITE(furde,8001) 'THRU,[3.1]or[3.99]',thru
8001 FORMAT(tr5,a/tr5,8L5)

  IF(thru) RETURN
  ntd = ntd+1
  WRITE(logline1,'(a,i2)') 'Reading transient data for simulation: Set ',ntd
    status = RM_LogMessage(rm_id, logline1)
  prtbc=.FALSE.
  prtslm=.FALSE.
  prtwel=.FALSE.
  ! ... Well information transient parameters
  IF(nwel > 0) THEN
     READ(fuins,*) rdwtd
     IF (print_rde) WRITE(furde,8001) 'RDWTD,[3.2.1]',rdwtd
     IF(rdwtd) THEN
        prtwel=.TRUE.
        IF (print_rde) WRITE(furde,8002) 'wel_seqno,qwv,indx_sol,[3.2.2]'
8002    FORMAT(tr5,2A)
        DO
           READ(fuins,'(A)') line
           line = uppercase(line)
           ic=INDEX(line(1:20),'END')
           IF(ic > 0) EXIT
           READ(line,*) uwelseqno,uq,uisolw
           IF (print_rde) WRITE(furde,8003) uwelseqno,uq,uisolw
8003       FORMAT(tr5,i5,tr2,1PG12.4,tr2,i5)
           IF(uwelseqno > nwel) THEN
              ierr(117)=.TRUE.
              EXIT
           END IF
           iwel=uwelseqno
           qwv(iwel)=cnvvf*uq
           indx1_wel(iwel)=uisolw
        END DO
     END IF
  END IF
  ! ... Specified value b.c.
  IF(nsbc > 0) THEN
     READ(fuins,*) rdspbc,rdstbc,rdscbc
     IF (print_rde) WRITE(furde,8001) 'RDSPBC,RDSTBC,RDSCBC,[3.3.1]', rdspbc,rdstbc,rdscbc
     IF(rdspbc) THEN
        ! ... Specified pressure b.c.
        IF (print_rde) WRITE(furde,8004)  '** Specified Pressure B.C. Parameters **',  &
             '  (read echo[3.5.5])',' ',  &
             '  isegsbc, psbc, isolsbc1, isolsbc2, mxfracsbc'
8004    FORMAT(tr5,2A/tr10,a)
        DO
           READ(fuins,'(A)') line
           line = uppercase(line)
           ic=INDEX(line(1:20),'END')
           IF(ic > 0) EXIT
           READ(line,*) isegbc, upsbc, uisolbc1, uisolbc2, umxfrac
           IF (print_rde) WRITE(furde,8005) isegbc, upsbc, uisolbc1, uisolbc2, umxfrac
8005       FORMAT(tr1,i8,1PG11.3,2I5,0Pf10.2)
           psbc(isegbc) = upsbc
           IF(solute) THEN
              indx1_sbc(isegbc) = uisolbc1
              indx2_sbc(isegbc) = uisolbc2
              mxf_sbc(isegbc) = umxfrac
           END IF
        END DO
     END IF
  END IF
  ! ... Specified flux b.c.
  IF(nfbc > 0) THEN
     READ(fuins,*) rdflxq,rdflxh,rdflxs
     IF (print_rde) WRITE(furde,8001) 'rdflxq,rdflxh,rdflxs,[3.4.1]', rdflxq,rdflxh,rdflxs
     IF(rdflxq) THEN
        ! ... Specified fluid flux b.c.
        ! ...      volumetric fluxes
        IF (print_rde) WRITE(furde,8004)  '** Flux B.C. Parameters **',  &
             '  (read echo[3.5.5])',' ',  &
             '  isegfbc, qfvfbc, isolfbc1, isolfbc2, mxfracfbc'
        DO
           READ(fuins,'(A)') line
           line = uppercase(line)
           ic=INDEX(line(1:20),'END')
           IF(ic > 0) EXIT
           READ(line,*) isegbc, uqfflx, uisolbc1, uisolbc2, umxfrac
           IF (print_rde) WRITE(furde,8005) isegbc, uqfflx, uisolbc1, uisolbc2, umxfrac
           qfflx(isegbc) = uqfflx
           indx1_fbc(isegbc) = uisolbc1
           indx2_fbc(isegbc) = uisolbc2
           mxf_fbc(isegbc) = umxfrac
        END DO
     END IF
     ! ... Solute diffusive fluxes for no flow b.c.
     ! ... *** this option is not functional for PHAST
     IF(rdflxs) THEN
        ! ... Specified solute flux b.c.
        IF (print_rde) WRITE(furde,8004)  '** Solute Flux B.C. Parameters **',  &
             '  (read echo[3.4.7])',' ',  &
             '  isegfbc, qsflx'
        DO  iis=1,ns
           DO
              READ(fuins,'(A)') line
              line = uppercase(line)
              ic=INDEX(line(1:20),'END')
              IF(ic > 0) EXIT
              READ(line,*) isegbc, uqsflx
              IF (print_rde) WRITE(furde,8005) isegbc, uqsflx
              qsflx(isegbc,iis) = uqsflx
           END DO
        END DO
     END IF
  END IF
  ! ... Aquifer leakage b.c. transient parameters
  IF(nlbc > 0) THEN
     READ(fuins,*) rdlbc
     IF (print_rde) WRITE(furde,8001) 'rdlbc,[3.5.1]',rdlbc
     IF(rdlbc) THEN
        IF (print_rde) WRITE(furde,8004)  '** Aquifer Leakage Parameters **',  &
             '  (read echo[3.5.2])',' ',  &
             '  iseglbc, hlbc, isollbc1, isollbc2, mxfraclbc'
        DO
           READ(fuins,'(A)') line
           line = uppercase(line)
           ic=INDEX(line(1:20),'END')
           IF(ic > 0) EXIT
           READ(line,*) isegbc, uhbc, uisolbc1, uisolbc2, umxfrac
           IF (print_rde) WRITE(furde,8005) isegbc, uhbc, uisolbc1, uisolbc2, umxfrac
           philbc(isegbc) = gz*uhbc
           indx1_lbc(isegbc) = uisolbc1
           indx2_lbc(isegbc) = uisolbc2
           mxf_lbc(isegbc) = umxfrac
        END DO
     END IF
  END IF
  ! ... River leakage b.c. transient parameters
  IF(nrbc > 0) THEN
     READ(fuins,*) rdrbc
     IF (print_rde) WRITE(furde,8001) 'RDRBC,[3.6.1]',rdrbc
     IF(rdrbc) THEN
        IF (print_rde) WRITE(furde,8004)  '** River Leakage Parameters **',  &
             '  (read echo[3.6.2])',' ',  &
             '  isegrbc, hrbc, isolrbc1, isolrbc2, mxfracrbc'
        DO
           READ(fuins,'(A)') line
           line = uppercase(line)
           ic=INDEX(line(1:20),'END')
           IF(ic > 0) EXIT
           READ(line,*) isegbc, uhbc, uisolbc1, uisolbc2, umxfrac
           IF (print_rde) WRITE(furde,8005) isegbc, uhbc, uisolbc1, uisolbc2, umxfrac
           phirbc(isegbc) = gz*uhbc
           indx1_rbc(isegbc) = uisolbc1
           indx2_rbc(isegbc) = uisolbc2
           mxf_rbc(isegbc) = umxfrac
        END DO
     END IF
  END IF

  READ(fuins,*) rdcalc
  IF (print_rde) WRITE(furde,8001) 'RDCALC,[3.7.1]',rdcalc
  IF(rdcalc) THEN
     prtslm=.TRUE.
     ! ... Calculation information
     READ(fuins,*) autots
     IF (print_rde) WRITE(furde,8001) 'AUTOTS,[3.7.2]',autots
     IF(.NOT.autots) THEN
        READ(fuins,*) deltim
        IF (print_rde) WRITE(furde,8006) 'DELTIM,[3.7.3A]',deltim
8006    FORMAT(tr5,a/tr5,10(1PG12.5))
     END IF
     IF(autots) THEN
        READ(fuins,*) dptas,dttas,dtimmn,dtimmx
        IF (print_rde) WRITE(furde,8007) 'DPTAS,DTTAS,DTIMMN,DTIMMX,',  &
             '[3.7.3B]',dptas,dttas,dtimmn,dtimmx
8007    FORMAT(tr5,2A/tr5,10(1PG12.5))
        IF(solute) THEN
           READ(fuins,*) (dctas(iis),iis=1,ns)
           IF (print_rde) WRITE(furde,8007) 'DCTAS(iis),iis=1,ns', '[3.7.3B]',(dctas(iis),iis=1,ns)
        END IF
        !...   *** well control not documented yet  ***
        !            READ(FUINS,*) DPTAS,DTTAS,DCTAS,DTIMMN,DTIMMX,DTIMU
        !            if (print_rde) WRITE(FURDE,8007) 'DPTAS,DTTAS,DCTAS,DTIMMN,DTIMMX,DTIMU',
        !     &           '[3.8.3B]',DPTAS,DTTAS,DCTAS,DTIMMN,DTIMMX,DTIMU
        ! 830        FORMAT(TR5,2A/TR5,10(1PG12.5))
     ELSEIF(steady_flow) THEN
        READ(fuins,*) dptas, dttas, dtimmn, dtimmx, growth_factor_ss
        IF (print_rde) WRITE(furde,8007) 'DPTAS,DTTAS,DTIMMN,DTIMMX,GROWTH_FACTOR_SS,',  &
             '[3.7.3B]',dptas, dttas, dtimmn, dtimmx, growth_factor_ss
     END IF
  END IF
  ! ... Time of next change in transient data
  READ(fuins,*) timchg
  IF (print_rde) WRITE(furde,8006) 'TIMCHG,[3.7.4]',timchg
  ! ... Output information
  ! ... Print interval for output tables at end of time step
  READ(fuins,*) prislm, prikd, prip, pric, pricphrq, priforce_chem_phrq, privel, prigfb,  &
       pribcf, priwel
  IF (print_rde) WRITE(furde,8008) 'PRISLM,PRIKD,PRIP,PRIC,PRICPHRQ,PRIFORCE_CHEM_PRHQ,PRIVEL,PRIGFB,',  &
       'PRIBCF,PRIWEL,[3.8.1]', prislm,prikd,prip,pric,pricphrq,priforce_chem_phrq,  &
       privel,prigfb,pribcf,priwel
8008 FORMAT(tr5,2A/tr5,11F10.2)
  ! ... Print boundary condition transient parameters
  READ(fuins,*) prt_bc
  IF (print_rde) WRITE(furde,8308) 'PRT_BC,[3.8.1.1]', prt_bc
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
  READ(fuins,*) prihdf_conc, prihdf_head, prihdf_vel, prihdf_intermediate
  IF (print_rde) WRITE(furde,8108) 'prihdf_conc, prihdf_head, prihdf_vel, prihdf_intermediate [3.8.2]',  &
       prihdf_conc, prihdf_head, prihdf_vel, prihdf_intermediate
8108 FORMAT(tr5,A/tr5,11F10.2)
  prihdf_conc = -prihdf_conc
  prihdf_head = -prihdf_head
  prihdf_vel = -prihdf_vel
  prihdf_intermediate = -prihdf_intermediate
  READ(fuins,*) prtichead
  IF (print_rde) WRITE(furde,8208) 'prtichead, [3.8.2.1]', prtichead
8208 FORMAT(tr5,A/tr5,l5)
  IF(num_flo_zones > 0) THEN
     READ(fuins,*) pri_zf, pri_zf_tsv, pri_zf_xyzt
     IF (print_rde) WRITE(furde,8111) 'pri_zf, pri_zf_tsv, pri_zf_xyzt[3.8.2.2]', &
        pri_zf, pri_zf_tsv, pri_zf_xyzt
     ! ... ***special patch
     pri_zf = -pri_zf
     pri_zf_tsv = -pri_zf_tsv
     pri_zf_xyzt = -pri_zf_xyzt
  END IF
  READ(fuins,*) chkptd,pricpd,savldo
  IF (print_rde) WRITE(furde,8010) 'CHKPTD,PRICPD,SAVLDO [3.8.3]',  &
       chkptd,pricpd,savldo
8010 FORMAT(tr5,a/tr5,l5,f5.2,l5)
  ! ... ***special patch
  pricpd = -pricpd
  ! ... Contour plots, vector plots
  READ(fuins,*) cntmaph,primaphead,cntmapc,primapcomp,vecmap,primapv
  IF (print_rde) WRITE(furde,8011) 'cntmaph,primaphead,cntmapc,primapcomp,vecmap,primapv,[3.9.1]',  &
       cntmaph,primaphead,cntmapc,primapcomp,vecmap,primapv
8011 FORMAT(tr5,a/tr5,3(l5,f8.2))
  ! ... ***special patch
  primaphead = -primaphead
  primapcomp = -primapcomp
  primapv = -primapv
  ! ... Well data time series
  READ(fuins,*) pri_well_timser, print_restart%print_interval, print_end_of_period
  IF (print_rde) WRITE(furde,8111) 'pri_well_timser,[3.9.2]',  &
       pri_well_timser, &
       print_restart%print_interval, &
       print_end_of_period
8111 FORMAT(tr5,a/tr5,f10.2, f10.2, l5)
  ! ... ***special patch
  pri_well_timser = -pri_well_timser
  print_restart%print_interval = -print_restart%print_interval
  IF (solute) THEN
     ! ... Print control index for .chem.txt concentrations on a sub-grid
     icall = 8
     CALL rewi(iprint_chem, icall, 125)
     ! ... Print control index for .chem.xyz.tsv concentrations on a sub-grid
     icall = 9
     CALL rewi(iprint_xyz, icall, 125)
  ENDIF

END SUBROUTINE read3
