SUBROUTINE init2_post_ss
  ! ... Initialize after the steady state flow simulation
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcv
  USE mcw
  USE mg2
  USE phys_const
  IMPLICIT NONE
  REAL(KIND=kdp) :: ehoftp, viscos  
  REAL(KIND=kdp) :: time_phreeqc, u0, u1, &
       uc, ut
  INTEGER :: imod, iis, iwel, k, l, m, nr, nsa
  LOGICAL :: erflg
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: init2_post_ss.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  nr=nx
  nsa = MAX(ns,1)
  ! ... Specified value b.c.
  DO  l = 1, nsbc  
     ccfsb( l) = 0._kdp  
     ccfvsb( l) = 0._kdp  
     cchsb( l) = 0._kdp  
     DO iis = 1, ns  
        ccssb( l, iis) = 0._kdp  
     END DO
  END DO
  ! ... Specified flux b.c.
  DO l = 1, nfbc  
     ccffb(l) = 0._kdp  
     ccfvfb(l) = 0._kdp  
     cchfb(l) = 0._kdp  
     DO  iis = 1, ns  
        ccsfb(l,iis) = 0._kdp  
     END DO
  END DO
  !.....Aquifer leakage
  DO l = 1, nlbc
     ccflb(l) = 0._kdp  
     ccfvlb(l) = 0._kdp  
     do iis=1,nsa  
        ccslb(l,iis) = 0._kdp  
     END DO
  END DO
  IF(nrbc > 0) THEN  
     !.....River leakage
     ! ... Zero the arrays for river leakage
     ccfrb = 0._kdp  
     ccfvrb = 0._kdp  
     ccsrb = 0._kdp  
  ENDIF
!!$  IF( NAIFC.GT.0) THEN  
!!$     !.....Aquifer influence functions b.c.
!!$     !...  ** Not available in PHAST
!!$     DO 530 L = 1, NAIFC  
!!$        QFAIF( L) = 0._KDP  
!!$        QHAIF( L) = 0._KDP  
!!$        QSAIF( L) = 0._KDP  
!!$        CCFAIF( L) = 0._KDP  
!!$        CCFVAI( L) = 0._KDP  
!!$        CCHAIF( L) = 0._KDP  
!!$        CCSAIF( L) = 0._KDP  
!!$530  END DO
!!$  ENDIF
  !.....Locate the heat conduction b.c. nodes and store thermal
  !.....     diffusivities and thermal conductivities*areas
  !...*** not available in PHAST
  !.....Calculate initial density, viscosity, and enthalpy distributions
  UT = T0  
  UC = W0  
  DO 780 M = 1, NXYZ  
     IF(ibc(m) == - 1 .or. frac(m) <= 0._kdp) THEN
        ! Dry cell or excluded cell values
        den(m) = 0._kdp
        vis(m) = 0._kdp
        IF(solute) THEN
           DO  is=1,ns
              c(m,is) = 0._kdp       
           END DO
        END IF
        cycle
     endif
     ERFLG = .FALSE.  
     IF( HEAT) UT = T( M)  
     DEN(M) = DEN0  
     VIS(M) = VISCOS(P(M),UT,UC)  
!!$     IF( HEAT) EH( M) = EHOFTP( UT, P( M), ERFLG)  
!!$     IF( ERFLG) THEN  
!!$        WRITE( FUCLOG, 9001) 'EHOFTP interpolation error in INIT2 '//'for &
!!$             &enthalpies of cells'
!!$9001    FORMAT      (TR5,A)  
!!$        IERR( 134) = .TRUE.  
!!$        ERREXE = .TRUE.  
!!$        RETURN  
!!$     ENDIF
     IF( .NOT.HEAT) THEN  
        !.....Calculate initial head distribution
        IMOD = MOD( M, NXY)  
        K = ( M - IMOD) / NXY + MIN( 1, IMOD)  
        HDPRNT( M) = Z( K) + P( M) / ( DEN( M) * GZ)  
     ENDIF
780 END DO
  !.....Reinitialize accumulation arrays and time counting and summation
  !.....     variables
  time = 0._kdp
  time_phreeqc = 0._kdp
  deltim = deltim_transient
  deltim_sav = 0._kdp
  itime = 0  
  fir0 = 0._kdp  
  firv0 = 0._kdp  
  ehir0 = 0._kdp  
  totfp = 0._kdp  
  tothp = 0._kdp  
  totfi = 0._kdp  
  tothi = 0._kdp  
  totwfi = 0._kdp  
  totwfp = 0._kdp  
  totwhi = 0._kdp  
  totwhp = 0._kdp  
  tcfsbc = 0._kdp  
  tchsbc = 0._kdp  
  tchaif = 0._kdp  
  tchfbc = 0._kdp  
  tchlbc = 0._kdp  
  !      tchhbc=0._kdp
  tcfaif = 0._kdp  
  tcffbc = 0._kdp  
  tcflbc = 0._kdp
  tcfrbc = 0._kdp  
  DO  iis = 1, nsa  
     totwsi( iis) = 0._kdp  
     totwsp( iis) = 0._kdp  
     sir0( iis) = 0._kdp  
     totsi( iis) = 0._kdp  
     totsp( iis) = 0._kdp  
     tcssbc( iis) = 0._kdp  
     tcsfbc( iis) = 0._kdp  
     tcslbc( iis) = 0._kdp  
     tcsrbc( iis) = 0._kdp  
     tcsaif( iis) = 0._kdp  
     tdsir_chem(iis) = 0._kdp
  END DO
  DO  iwel = 1, nwel  
     wficum( iwel) = 0._kdp  
     wfpcum( iwel) = 0._kdp  
     IF( heat) THEN  
        whicum( iwel) = 0._kdp  
        whpcum( iwel) = 0._kdp  
     ENDIF
     DO  iis = 1, nsa  
        wsicum(iwel,iis) = 0._kdp  
        wspcum(iwel,iis) = 0._kdp  
     END DO
  END DO

  frac_icchem = frac

  DO m = 1, nxyz  
     IF(.NOT.fresur) THEN
        pv(m) = pv(m) + pmcv(m)*(p(m)-p0)
     ELSEIF(m <= nxyz-nxy) THEN
        IF(ABS(frac(m) - 1._kdp) <= 1.D-6.AND.frac(m+nxy) > 0.) &
             pv(m) = pv(m) + pmcv(m)*(p(m)-p0)
     ENDIF
     !.....Initial fluid(kg), heat(j), solute(kg) and pore volume(m^3)
     !.....     in the region
     u0 = pv(m)*frac(m)  
     !..         U1=PVK(M)*FRAC(M)
     u1 = 0._kdp  
     fir0 = fir0 + u0* den(m)
     firv0 = firv0 + u0  
     if( heat) ehir0 = ehir0 + u0*den(m)*eh(m) + pmhv(m)*t(m)
!!$     DO iis = 1, ns  
!!$        sir0(iis) = sir0(iis) + den(m)*(u0 + u1)*c(m,iis)  
!!$        sir(iis) = sir0(iis)  
!!$     END DO
  END DO
  fir = fir0  
  ehir = ehir0  
  !.....Set defaults for well bore calculations
  !...  *** not applicable
!!$  IF(DAMWRC.LE.0.) DAMWRC = 2.0_kdp
!!$  IF(MXITQW.LE.0) MXITQW = 20  
!!$  IF(TOLFPW.LE.0.) TOLFPW = 1.e-3_kdp  
!!$  IF(TOLQW.LE.0.) TOLQW = 0.1_KDP  
!!$  IF(EPSWR.LE.0.) EPSWR = 1.e-3_kdp  
  !.....Turn off Gauss elimination due to constant density
  gausel = .FALSE.  
  !.....Zero the output record counters
  NRSTTP = 0  
  NMAPR = 0  
END SUBROUTINE init2_post_ss
