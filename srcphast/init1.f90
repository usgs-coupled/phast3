SUBROUTINE init1  
  ! ... Initializes dimensions, unit labels, conversion factors
  USE mcch
  USE mcb
  USE mcc
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mct
  USE mcv
  USE mcw, ONLY: totwsi, totwsp, tqwsi, tqwsp, u10
  IMPLICIT NONE
  INTEGER :: a_err, da_err, iis, nsa
  CHARACTER(LEN=10), DIMENSION(:), ALLOCATABLE :: ucomp_name
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF (CYLIND) NY = 1  
  NXY = NX * NY  
  NXYZ = NXY * NZ  
  nxyzh = (nxyz+MOD(nxyz,2))/2
  ! ... Allocate mesh arrays
  ALLOCATE (caprnt(nxyz), iprint_chem(nxyz), iprint_xyz(nxyz),  &
       lprnt1(nxyz), lprnt2(nxyz), lprnt3(nxyz), lprnt4(nxyz),  &
       aprnt1(nxyz), aprnt2(nxyz), aprnt3(nxyz), aprnt4(nxyz), aprnt5(nxyz), aprnt6(nxyz), &
       aprnt7(nxyz), &
       rm(nx), x(nx), y(ny), z(nz), x_node(nxyz), y_node(nxyz), z_node(nxyz),  &
       xele(nxyz), yele(nxyz), zele(nxyz),  &
       x_face(nx-1), y_face(ny-1), z_face(nz-1),  &
       ibc(nxyz), &
       STAT = a_err)
  IF (a_err.NE.0) THEN  
     PRINT *, "Array allocation failed: init1"  
     STOP  
  ENDIF
  ibc = 0
  ! ... Set up units and metric to english (U.S. customary) conversion
  ! ...      factors, if necessary
  IF (TMUNIT.LE.1) THEN  
     UNITTM = 's'  
     UTULBL = 'seconds'  
     CNVTM = 1.D0  
     ELSEIF (TMUNIT.EQ.2) THEN  
     UNITTM = 'min'  
     UTULBL = 'minutes'  
     CNVTM = 60.D0  
     ELSEIF (TMUNIT.EQ.3) THEN  
     UNITTM = 'h'  
     UTULBL = 'hours'  
     CNVTM = 3600.D0  
     ELSEIF (TMUNIT.EQ.4) THEN  
     UNITTM = 'd'  
     UTULBL = 'days'  
     CNVTM = 86400.D0  
     ELSEIF (TMUNIT.EQ.6) THEN  
     UNITTM = 'yr'  
     UTULBL = 'years'  
     CNVTM = 3.155815D7  
  ENDIF
  CNVTMI = 1.D0 / CNVTM  
  IF (.NOT.EEUNIT) THEN  
     UNITM = 'kg'  
     UNITL = 'm '  
     UNITT = 'C'  
     UNITH = 'J  '  
     UNITHF = 'W    '  
     UNITP = 'Pa '  
     UNITEP = 'J/kg'  
     UNITVS = 'Pa-s'  
     CNVL = 1.D0  
     CNVM = 1.D0  
     CNVP = 1.D0  
     CNVVS = 1.D0  
     CNVCN = 1.D0  
     CNVHE = 1.D0  
     CNVME = 1.D0  
     CNVT1 = 1.D0  
     CNVT2 = 0.D0  
     CNVTHC = 1.D0  
     CNVHTC = 1.D0  
     CNVHF = 1.D0  
  ELSE        ! ... this should never be entered because phast.tmp is in SI units
     UNITM = 'lb'  
     UNITL = 'ft'  
     UNITT = 'F'  
     UNITH = 'BTU'  
     UNITHF = 'BTU/d'  
     UNITP = 'psi'  
     UNITEP = 'ft-lbf/lbm'  
     UNITVS = 'cp'  
     CNVL = .304800D0  
     CNVM = .4535924D0  
     CNVP = 6.894757D3  
     CNVVS = 0.0010D0  
     CNVCN = 144.D0 * 32.174D0  
     CNVHE = 1055.056D0  
     CNVME = 9.290304D-2  
     CNVT1 = .5555556D0  
     CNVT2 = 32.D0  
     CNVTHC = CNVHE / (3600.D0 * CNVL * CNVT1)  
     CNVHTC = CNVTHC / CNVL  
     CNVHF = CNVHTC * CNVT1  
  ENDIF
  CNVL2 = CNVL * CNVL  
  CNVL3 = CNVL2 * CNVL  
  CNVD = CNVM / CNVL3  
  CNVVF = CNVL3 / CNVTM  
  CNVFF = CNVVF / CNVL2  
  CNVMF = CNVM / (CNVTM * CNVL2)  
  CNVSF = CNVMF  
  CNVDF = CNVL2 / CNVTM  
  CNVVL = CNVL / CNVTM  
  CNVCN = CNVCN * CNVVL  
  CNVHC = CNVHE / (CNVM * CNVT1)  
  ! ... Calculate inverse conversion factors
  CNVLI = 1._kdp/CNVL
  CNVMI = 1._kdp/CNVM
  CNVPI = 1._kdp/CNVP
  CNVVSI = 1._kdp/CNVVS
  CNVCNI = 1._kdp/CNVCN
  CNVHEI = 1._kdp/CNVHE
  CNVMEI = 1._kdp/CNVME
  CNVT1I = 1._kdp/CNVT1
!  CNVTHCI = 1._kdp/CNVTHC
!  CNVHTCI = 1._kdp/CNVHTC
  CNVHFI = 1._kdp/CNVHF
  CNVL2I = 1._kdp/CNVL2
  CNVL3I = 1._kdp/CNVL3
  CNVDI = 1._kdp/CNVD
  CNVVFI = 1._kdp/CNVVF
  CNVFFI = 1._kdp/CNVFF
  CNVMFI = 1._kdp/CNVMF
  CNVSFI = 1._kdp/CNVSF
  CNVDFI = 1._kdp/CNVDF
  CNVVLI = 1._kdp/CNVVL
  CNVCNI = 1._kdp/CNVCN
  CNVHCI = 1._kdp/CNVHC
  CNVMFI = CNVMFI * CNVL2I  
  CNVT2I = 0._kdp
  IF (EEUNIT) CNVT2I = 32.0_kdp
  ! ... Allocate scratch space for component names
  ALLOCATE (UCOMP_NAME(100), &
  STAT = a_err)
  IF (a_err.NE.0) THEN  
     PRINT *, "Array allocation failed: init1"  
     STOP  
  ENDIF
  UCOMP_NAME=" "
  ! ... Start phreeqec and count number of components
  !      CALL PHREEQC_MAIN(SOLUTE, F1NAME, F2NAME, F3NAME)
  IF (SOLUTE) CALL COUNT_ALL_COMPONENTS (NS, UCOMP_NAME)  
  ! ... Allocate component arrays
  nsa = MAX(ns,1)
  ! ... Allocate dependent variable arrays
  ALLOCATE (COMP_NAME(NSA), ICMAX(NSA), JCMAX(NSA), KCMAX(NSA), &
       INDX_SOL1_IC(7,NXYZ), INDX_SOL2_IC(7,NXYZ), INDX_SOL1_BC(4,NXYZ), INDX_SOL2_BC(4,NXYZ), &
       AXSAV(NXYZ), AYSAV(NXYZ), AZSAV(NXYZ), DC(0:NXYZ,NSA), dfracdt(nxy), DP(0:NXYZ), DT(0:0), &
       sxx(nxyz), syy(nxyz), szz(nxyz), vxx(nxyz), vyy(nxyz), vzz(nxyz),  &
       vx_node(nxyz), vy_node(nxyz), vz_node(nxyz), vmask(nxyz), zfs(nxy),  &
       dcmax(nsa), dsir(nsa),  dsir_chem(nsa),  &
       qsfx(nxyz,nsa), qsfy(nxyz,nsa), qsfz(nxyz,nsa), &
       stsaif(nsa), stsetb(nsa), stsfbc(nsa), stslbc(nsa), &
       stsrbc(nsa), stssbc(nsa), stswel(nsa), ssresf(nsa), ssres(nsa), stotsi(nsa), stotsp(nsa), &
       tsres(nsa), tsresf(nsa), &
       dctas(nsa), telc(nsa),  &
       rf(nxyz), rh(1), rh1(1), rs(nxyz,nsa), rs1(nxyz,nsa), &
       c(nxyz,nsa), den(nxyz), eh(1), frac(nxyz), frac_icchem(nxyz),  &
       mxfrac(7,nxyz), p(nxyz), t(1), vis(nxyz), &
       sir(nsa), sir0(nsa), sirn(nsa), sir_prechem(nsa), &
       totsi(nsa), totsp(nsa), tdsir_chem(nsa), tcsaif(nsa), tcsetb(nsa), &
       tcsfbc(nsa), &
       tcslbc(nsa), tcsrbc(nsa), tcssbc(nsa), &
       totwsi(nsa), totwsp(nsa), &
       tqwsi(nsa), tqwsp(nsa), u10(nsa), c_mol(nxyz,nsa), &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: init1"  
     STOP  
  ENDIF
  indx_sol1_bc = -100
  c = 0._kdp
  zfs = -1.e20_kdp
  IF (SOLUTE) THEN  
     DO  IIS = 1, NS  
        COMP_NAME(IIS)  = ucomp_name(iis)
     END DO
  ENDIF
  DEALLOCATE (ucomp_name, &
  STAT = da_err)
  IF (da_err.NE.0) THEN  
     PRINT *, "Array deallocation failed: init1"  
     STOP  
  ENDIF
END SUBROUTINE init1
