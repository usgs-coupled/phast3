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
  USE print_control_mod
  USE phys_const
  IMPLICIT NONE
  REAL(KIND=kdp) :: viscos  
  REAL(KIND=kdp) :: time_phreeqc, u0, u1, uc, ut
  INTEGER :: imod, iis, iwel, k, l, m, mt, nr, nsa
  CHARACTER(LEN=130) error_line
!!$  LOGICAL :: erflg
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  nr=nx
  nsa = MAX(ns,1)
  IF(nsbc > 0) THEN  
     ! ... Specified value b.c.
     ! ... Zero the arrays for specified value b.c.
     ccfsb = 0._kdp
     ccfvsb = 0._kdp
     ccssb = 0._kdp
  ENDIF
  IF(nfbc > 0) THEN  
     ! ... Specified flux b.c.
     ! ... Zero the arrays for flux b.c.
     ccffb = 0._kdp  
     ccfvfb = 0._kdp  
     ccsfb = 0._kdp  
  ENDIF
  IF(nlbc > 0) THEN  
     ! ... Aquifer leakage
     ! ... Zero the arrays for aquifer leakage
     ccflb = 0._kdp  
     ccfvlb = 0._kdp  
     ccslb = 0._kdp  
  ENDIF
  IF(nrbc > 0) THEN  
     ! ... River leakage
     ! ... Zero the arrays for river leakage
     ccfrb = 0._kdp  
     ccfvrb = 0._kdp  
     ccsrb = 0._kdp  
  ENDIF
  IF(ndbc > 0) THEN  
     ! ... Drain leakage
     ! ... Zero the arrays for drain leakage
     ccfdb = 0._kdp
     ccfvdb = 0._kdp
     ccsdb = 0._kdp
  ENDIF
!!$  IF( NAIFC.GT.0) THEN  
!!$     ! ... Aquifer influence functions b.c.
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
  ! ... Locate the heat conduction b.c. nodes and store thermal
  ! ...      diffusivities and thermal conductivities*areas
  !...*** not available in PHAST
  ! ... Calculate initial density, viscosity, and enthalpy distributions
  ut = t0
  uc = w0  
  DO  m = 1, nxyz  
     IF(ibc(m) == - 1 .OR. frac(m) <= 0._kdp) THEN
        ! dry cell or excluded cell values
        den(m) = 0._kdp
        vis(m) = 0._kdp
        IF(solute) THEN
           DO  is=1,ns
              c(m,is) = 0._kdp       
           END DO
        END IF
        CYCLE
     ENDIF
!!$     ERFLG = .FALSE.  
!!$     IF( HEAT) UT = T( M)  
     den(m) = den0  
     vis(m) = viscos(p(m),ut,uc)  
!!$     IF( HEAT) EH( M) = EHOFTP( UT, P( M), ERFLG)  
!!$     IF( ERFLG) THEN  
!!$        WRITE( FUCLOG, 9001) 'EHOFTP interpolation error in INIT2 '//'for &
!!$             &enthalpies of cells'
!!$9001    FORMAT      (TR5,A)  
!!$        IERR( 134) = .TRUE.  
!!$        ERREXE = .TRUE.  
!!$        RETURN  
!!$     ENDIF
     IF(.NOT.heat) THEN  
        ! ... Calculate initial head distribution
        imod = MOD(m,nxy)
        k = (m - imod)/nxy + MIN(1,imod)  
        hdprnt(m) = z(k) + p(m)/(den(m)*gz)  
     ENDIF
  END DO
  IF(fresur) THEN
     ! ... Calculate water-table elevation
     DO mt=1,nxy
        m = mfsbc(mt)
        IF (m > 0) THEN
           wt_elev(mt) = z_node(m) + p(m)/(den0*gz)
        END IF
     END DO
  END IF
  ! ... Reinitialize accumulation arrays and time counting and summation
  ! ...      variables
  !  time = 0._kdp
  time = timrst*cnvtm
  ! set print times starting with with restart time
  CALL pc_set_print_times(time*cnvtmi, timchg*cnvtmi)
  timprtnxt = next_print_time
  !  time_phreeqc = 0._kdp
  time_phreeqc = time
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
  tcfdbc = 0._kdp  
  DO  iis=1,nsa  
     totwsi(iis) = 0._kdp  
     totwsp(iis) = 0._kdp  
     sir0(iis) = 0._kdp  
     totsi(iis) = 0._kdp  
     totsp(iis) = 0._kdp  
     tcssbc(iis) = 0._kdp  
     tcsfbc(iis) = 0._kdp  
     tcslbc(iis) = 0._kdp  
     tcsrbc(iis) = 0._kdp  
     tcsdbc(iis) = 0._kdp
     tcsaif(iis) = 0._kdp
     tdsir_chem(iis) = 0._kdp
  END DO
  DO  iwel = 1, nwel
     wficum(iwel) = 0._kdp
     wfpcum(iwel) = 0._kdp
     IF(heat) THEN  
        whicum(iwel) = 0._kdp  
        whpcum(iwel) = 0._kdp  
     ENDIF
     DO  iis = 1, nsa  
        wsicum(iwel,iis) = 0._kdp  
        wspcum(iwel,iis) = 0._kdp  
     END DO
  END DO
  frac_icchem = frac
  DO m = 1, nxyz  
!     IF(.NOT.fresur) THEN
!        pv(m) = pv(m) + pmcv(m)*(p(m)-p0)
!     ELSEIF(m <= nxyz-nxy) THEN
!        IF(ABS(frac(m) - 1._kdp) <= 1.e-6_kdp .AND. frac(m+nxy) > 0.)  &
!             pv(m) = pv(m) + pmcv(m)*(p(m)-p0)
!     ENDIF
     if (pv(m) < 0) then
        WRITE( error_line, *) "Negative pore volume after steady-state calculation, cell ", m
        CALL errprt_c(error_line)
        WRITE( error_line, *) "Increase porosity, decrease specific storage, or use free surface boundary."
        CALL errprt_c(error_line)
        ERREXE = .TRUE.  
        RETURN        
     endif
     ! ... Initial fluid(kg), heat(j), solute(kg) and pore volume(m^3)
     ! ...      in the region
     u0 = pv(m)*frac(m)  
     !..         U1=PVK(M)*FRAC(M)
     u1 = 0._kdp  
     fir0 = fir0 + u0*den(m)
     firv0 = firv0 + u0  
!$$     IF(heat) ehir0 = ehir0 + u0*den(m)*eh(m) + pmhv(m)*t(m)
!!$     DO iis = 1, ns  
!!$        sir0(iis) = sir0(iis) + den(m)*(u0 + u1)*c(m,iis)  
!!$        sir(iis) = sir0(iis)  
!!$     END DO
  END DO
  fir = fir0  
  ehir = ehir0  
  ! ... Set defaults for well bore calculations
  !...  *** not applicable
!!$  IF(DAMWRC.LE.0.) DAMWRC = 2.0_kdp
!!$  IF(MXITQW.LE.0) MXITQW = 20  
!!$  IF(TOLFPW.LE.0.) TOLFPW = 1.e-3_kdp  
!!$  IF(TOLQW.LE.0.) TOLQW = 0.1_KDP  
!!$  IF(EPSWR.LE.0.) EPSWR = 1.e-3_kdp  
  ! ... Turn off Gauss elimination due to constant density
  gausel = .FALSE.  
  ! ... Zero the output record counters
  nrsttp = 0  
  nmapr = 0  
  dp = 0._kdp           ! ... dp=0 for steady state flow to transport
END SUBROUTINE init2_post_ss
