SUBROUTINE init2_2  
  ! ... Initialize after READ2
  ! ... This is the last initialization group outside the loop for
  ! ...      time marching
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcs
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE phys_const
  IMPLICIT NONE
  REAL(KIND=kdp) :: u0, u1, up0,  &
       udxyzi, udxyzo, udy, udydz, udz, ugdelx, &
       ugdely, ugdelz, upabd, upor, ut
  INTEGER :: iis, iwel, m, nr, nsa
  LOGICAL :: erflg, exbc
  INTEGER :: mp, n
  !     ------------------------------------------------------------------
  !...
  nr=nx
  nsa = MAX(ns,1)
  ! ... Initialize accumulation arrays and time counting and summation
  ! ...      variables
  fdtmth_tr = fdtmth     ! ... save the input time difference weight
  time = timrst*cnvtm
  time_phreeqc = time
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
  do  iis = 1,nsa  
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
!!$     if(heat) then  
!!$        whicum(iwel) = 0._kdp  
!!$        whpcum(iwel) = 0._kdp  
!!$     endif
     do  iis = 1, nsa  
        wsicum(iwel, iis) = 0._kdp  
        wspcum(iwel, iis) = 0._kdp  
     end do
  END DO
  DO m = 1,nxyz  
     IF(.NOT.fresur) THEN
        pv(m) = pv(m) + pmcv(m)*(p(m)-p0)
        ELSEIF(m <= nxyz-nxy) THEN
        IF(ABS(frac(m) - 1._kdp) <= 1.e-6_kdp .AND. frac(m+nxy) > 0.) &
             pv(m) = pv(m) + pmcv(m)*(p(m)-p0)
     ENDIF
     ! ... Initial fluid(kg), solute(kg) and pore volume(m^3)
     ! ...      in the region
     u0 = pv(m)*frac(m)
     !..         U1=PVK(M)*FRAC(M)
     u1 = 0._kdp  
     fir0 = fir0 + u0*den0
     firv0 = firv0 + u0
  END DO
  pv0 = pv
  fir = fir0  
  ! ... Set timchg to zero to force the first READ3 read in
  timchg = 0._kdp  
  ! ... Set steady flow convergence flag even if no steady i.c. to
  ! ...      be computed
  converge_ss = .false.
  ! ... Set defaults for well bore calculations
  !...  *** not applicable
!!$  IF(DAMWRC.LE.0.) DAMWRC = 2.0_kdp
!!$  IF(MXITQW.LE.0) MXITQW = 20  
!!$  IF(TOLFPW.LE.0.) TOLFPW = 1.e-3_kdp  
!!$  IF(TOLQW.LE.0.) TOLQW = 0.1_KDP  
!!$  IF(EPSWR.LE.0.) EPSWR = 1.e-3_kdp  
  ! ... Turn off Gauss elimination due to constant density
  GAUSEL = .FALSE.  
  ! ... Set defaults for iteration parameters
!!$  MAXITN = MAX(MAXITN, 5)  
  ! ... Use MAXITN for steady state flow iteration limit
!!$  maxitn = max(maxitn,200)
  ! ... Iterative solver default parameters
  IF(slmeth >= 3) THEN  
     IF(epsslv <= 0.) epsslv = 1.e-6_kdp  
     IF(maxit2 == 0) maxit2 = 100  
  ENDIF
  ! ... Set initial condition print control for velocity
  prtdv = .false.       ! ... always for constant density
  prvel = prtss_vel
  prmapv = prtss_mapvel
  prhdfv = prtsshdf_vel
  ! ... Zero the output record counters
  nrsttp = 0  
  nmapr = 0  
  ! ... Zero the output time plane counters
  ntprbcf = 0
  ntprcpd = 0
  ntprgfb = 0
  ntprzf = 0
  ntprzf_tsv = 0
  ntprkd = 0
  ntprmapcomp = 0
  ntprmaphead = 0
  ntprmapv = 0
  ntprhdfv = 0
  ntprhdfh = 0
  ntprp = 0
  ntprc = 0
  ntprvel = 0
  ntprwel = 0
  ntprtem = 0
  ntprzf_xyzt = 0
  IF(CYLIND) orenpr = 13  
END SUBROUTINE init2_2
