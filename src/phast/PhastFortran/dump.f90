SUBROUTINE dump_hst
  ! ... Dumps selected common blocks and the partitioned large arrays
  ! ...      to disc for checkpoint or restart
  USE f_units, ONLY: fuorst, fuclog, fulp
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcch
  USE mcch_m
  USE mcg
  USE mcg_m
  USE mcm
  USE mcm_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcs
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  IMPLICIT NONE
  CHARACTER(LEN=130) :: logline1, logline2, logline3
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF(savldo) REWIND fuorst
  ! ... Write the file for restart in future run
  !****much repair needed****
!!$  WRITE(fuorst) &
!!$       IBC,MAIFC,METBC,MFBC,MFSBC,MHCBC,MLBC,MRBC,MSBC, &
!!$       IDMPTM, &
!!$       I1Z, I2Z, J1Z, J2Z, K1Z, K2Z, NAXES, &
!!$       CI,CIN,CIR,CIRL,CIRH,IND,IP1,IP1R,IPENV,MAR,MAR1, &
!!$       &     MRNO,MORD, &
!!$       indx1_wel, indx2_wel, IW, JW, LCBW, LCTW, mwel, nkswel, welidno, WQMETH
!!$  WRITE(fuorst) &  
!!$       CSBC, PSBC, TSBC, &
!!$       CCFSB, CCFVSB, CCHSB, CCSSB, cfbc, &
!!$       DENFBC, QFFBC, QHFBC, QSFBC, TFLX, CCFFB, CCFVFB, CCHFB, CCSFB, &
!!$       ALBC, BBLBC, BLBC, CLBC, DENLBC, KLBC, PHILBC, TLBC, VISLBC, &
!!$       ZELBC, &
!!$       ARBC, BBRBC, BRBC, CRBC, DENRBC, KRBC, PHIRBC, TRBC, VISRBC, &
!!$       ZERBC, &
!!$       CCFLB, CCFVLB, CCHLB, CCSLB,  &
!!$       CCFRB, CCFVRB, CCHRB, CCSRB, &
!!$       A1ETBC, A2ETBC, BETBC,  &
!!$       QETBC, ZLSETB, CCFETB, CCFVEB, CCHETB, CCSETB,  &
!!$       AAIF, BAIF, CAIF, DENOAR, &
!!$       PAIF, TAIF, VAIFC, WCAIF, CCFAIF, CCFVAI, CCHAIF, CCSAIF, A1HC, &
!!$       A2HC, A3HC, CCHHCB, DQHCDT, DTHHC, KARHC, QHCBC, THCBC, TPHCBC,  &
!!$       ZHCBC, &
!!$       DMPTM, DCTAS, TELC, &
!!$       ARX, ARY, ARZ, ARXFBC, ARYFBC, ARZFBC, ARZETB, &
!!$       RF, RH, RH1, RS, RS1, &
!!$       RM, X, Y, Z, X_NODE, Y_NODE, Z_NODE, &
!!$       EHWKT, EHWSUR, HTCWR, KTHAWR, KTHWR, mxf_wel, &
!!$       PWK, PWKT, PWKTS, PWSUR, &
!!$       PWSURS, QWV, TABWR, TATWR, TWK, TWKT, TWSRKT, TWSUR, WBOD,  &
!!$       WFRAC, WI, WFICUM, WFPCUM, WHICUM, WHPCUM, WSICUM, WSPCUM,  &
!!$       WRANGL, WRID, &
!!$       WRISL, WRRUF, WSF, XW, YW, ZWB, ZWT, &
!!$       TOTWSI, TOTWSP 
!!$  WRITE(fuorst) & 
!!$       TITLE,PLBL,TLBL,CLBL,DASH,DOTS, &
!!$       UNITM,UNITL,UNITTM,UNITH,UNITT,UNITP,UNITHF,UNITEP,UNITVS, &
!!$       UTULBL,F1NAME,F2NAME,F3NAME,NAME,RXLBL,MFLBL 
!!$  WRITE(fuorst) &
!!$       IAIF, LNZ1, LNZ2, LNZ3, LNZ4, LNZ7, NSBC, NFBC, &
!!$       NLBC, NRBC, NETBC, NAIFC, NHCBC, NHCN, NZTPHC, &
!!$       iprptc,ltcom,maxitn,ntsfal,ORENPR,PRIBCF,PRICPD,PRIDV, &
!!$       PRIGFB,PRIKD,PRIMAPComp, primaphead, PRIMAPV, &
!!$       PRIMIN, &
!!$       PRIP,prit,PRIC,PRISLM,pri_well_timser,PRIVEL,PRIWEL,SLMETH,TMUNIT, &
!!$       NPMZ, NX, NXY, NXYZ, NY, NZ, &
!!$       NPEHDT, NEHST, NTEHDT, &
!!$       IDIR, &
!!$       MAXIT1, &
!!$       MAXIT2, NBN, NRN, NOHST, ND4N, NPRIST, NRAL, NSDR, NSTSLV, &
!!$       NSTSOR, NTSOPT, &
!!$       ITIME, NMAPR, NRSTTP, NS, &
!!$       MAXORD, MAXPTS, METH, MXITQW, NWEL
!!$  WRITE(fuorst)  &
!!$       FRESUR, &
!!$       AUTOTS, CHKPTD, cntmapc, cntmaph, CROSD, CYLIND, EEUNIT, &
!!$       GAUSEL, HEAT, MILU, SAVLDO, SCALMF, SOLUTE, &
!!$       TSFAIL, VECMAP, &
!!$       CWATCH, WRCALC
!!$  WRITE(fuorst) &
!!$       ABOAR, ANGOAR, BOAR, F1AIF, F2AIF, FTDAIF, KOAR, &
!!$       POROAR, RIOAR, VISOAR, VOAR, &
!!$       DPTAS, DTIMMN, DTIMMX, DTIMU, DTTAS, EPS, &
!!$       EPSFS, TELP, TELT, TIMPRT, TOLDEN, TOLDNC, TOLDNT, &
!!$       BP, BT, CNVTM, CNVCN, CNVD, CNVDF, CNVHC, CNVHE, &
!!$       CNVHF, CNVHTC, CNVFF, CNVL, CNVL2, CNVL3, CNVM, CNVME, CNVMF, &
!!$       CNVP, CNVSF, CNVTHC, CNVVF, CNVVL, CNVVS, CNVT1, CNVT2, CNVTMI, &
!!$       CNVCNI, CNVDI, CNVDFI, CNVHCI, CNVHEI, CNVHFI, CNVHTI, CNVFFI, &
!!$       CNVLI, CNVL2I, CNVL3I, CNVMI, CNVMEI, CNVMFI, CNVPI, CNVSFI, &
!!$       CNVTCI, CNVVFI, CNVVLI, CNVVSI, CNVT1I, CNVT2I, CPF, DECLAM, &
!!$       DEN0, DENC, DENP, DENT, DM, EH0, FDSMTH, FDTMTH, GX, GY, GZ, &
!!$       KTHF, P0, P0H, PAATM, T0, T0H, VISFAC, W0, W1, &
!!$       EPSOMG, EPSSLV, &
!!$       DELTIM, EHIR, EHIR0, EHIRN, FIR, FIR0, FIRN,  &
!!$       FIRV0, &
!!$       FIRV, TIME, TOTFI, TOTFP, TOTHI, TOTHP, &
!!$       TCFAIF, TCFETB, TCFFBC, TCFLBC, TCFRBC, TCFSBC, TCHAIF, &
!!$       TCHETB, TCHFBC, TCHHCB, TCHLBC, TCHRBC, TCHSBC, &
!!$       DAMWRC, DENWKT, DENWRK, DTADZW, DZMIN, EH00, EOD, &
!!$       EPSWR, QWR, TAMBI, TOLDPW, TOLFPW, TOLQW, TOTWFI, TOTWFP,  &
!!$       TOTWHI, TOTWHP
  nrsttp=nrsttp+1
  idmptm(nrsttp)=itime
  dmptm(nrsttp)=cnvtmi*time
  ! ... Write a message to the output file
  write(logline1,2001) 'Dump File Written at Time ',cnvtmi*time,' ('//unittm//')'
2001 FORMAT(a,1PG12.4,A)
  WRITE(fulp,2011) trim(logline1)
2011 FORMAT(/tr10,a)
     CALL logprt_c(logline1)
  IF(savldo) THEN
     logline1 = 'Dump File from Previous Time was Overwritten'
     WRITE(fulp,2012) trim(logline1)
2012 FORMAT(tr15,2A)
    CALL logprt_c(logline1)
  END IF
END SUBROUTINE dump_hst
