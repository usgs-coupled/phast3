SUBROUTINE init1  
  ! ... Initializes dimensions, unit labels, conversion factors
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
  USE mct_m
  USE mcv
  USE mcv_m
  USE mcw_m, ONLY: totwsi, totwsp, tqwsi, tqwsp, u10
  USE print_control_mod
  USE mpi_mod
  IMPLICIT NONE
  INTEGER :: a_err, iis, nsa
  !     ------------------------------------------------------------------
#ifdef USE_MPI
  if (mpi_myself == 0) then
      CALL MPI_BCAST(METHOD_WORKERINIT1, 1, MPI_INTEGER, manager, world_comm, ierrmpi)  
      ! workers call worker_init1
  endif    
#endif
  IF (cylind) ny = 1  
  nxy = nx*ny  
  nxyz = nxy*nz  
  nxyzh = (nxyz+MOD(nxyz,2))/2
  mtp1 = nxyz - nxy + 1          ! ... first cell in top plane of global mesh
  ! ... Allocate program control information: mcc and mcc_m
  ALLOCATE (iprint_chem(nxyz), iprint_xyz(nxyz),  &
  lprnt1(nxyz), lprnt2(nxyz),  &
  vmask(nxyz),  &
  STAT = a_err)
  IF (a_err /= 0) THEN  
      PRINT *, "Array allocation failed: init1, point 1"
      STOP
  ENDIF
  ! ... Allocate node information arrays: mcn
  ALLOCATE (rm(nx), x(nx), y(ny), z(nz), x_node(nxyz), y_node(nxyz), z_node(nxyz),  &
  x_face(nx-1), y_face(ny-1), z_face(nz-1),  &
  pv0(nxyz), por(nxyz), volume(nxyz), &
  phreeqc_density(nxyz), &
  STAT = a_err)
  IF (a_err /= 0) THEN  
      PRINT *, "Array allocation failed: init1, point 2"  
      STOP  
  ENDIF
  ! ... Allocate boundary condition information: mcb and mcb_m
  ALLOCATE(ibc(nxyz), char_ibc(nxyz), ibc_string(nxyz),  &
  STAT = a_err)
  IF (a_err /= 0) THEN  
      PRINT *, "Array allocation failed: init1, point 3"  
      STOP  
  ENDIF
  !!$  ! ... store index numbers for natural numbering
  !!$  call mtoijk_orig
  volume = 0.0d0
  pv0 = 0.0d0
  por = 1.0d0
  ibc = 0
  ibc_string = '         '
  char_ibc =   '         '
  ! ... Set up units and metric to english (U.S. customary) conversion
  ! ...      factors, if necessary
  IF (tmunit == 1) THEN
      unittm = 's'  
      utulbl = 'seconds'  
      cnvtm = 1._kdp  
  ELSEIF (tmunit == 2) THEN
      unittm = 'min'  
      utulbl = 'minutes'  
      cnvtm = 60._kdp  
  ELSEIF (tmunit == 3) THEN
      unittm = 'h'  
      utulbl = 'hours'  
      cnvtm = 3600._kdp  
  ELSEIF (tmunit == 4) THEN
      unittm = 'd'  
      utulbl = 'days'  
      cnvtm = 86400._kdp  
  ELSEIF (tmunit == 6) THEN  
      unittm = 'yr'  
      utulbl = 'years'  
      cnvtm = 3.155815e7_kdp  
  ENDIF
  cnvtmi = 1._kdp/cnvtm  
  IF (.NOT.eeunit) THEN  
      unitm = 'kg'  
      unitl = 'm '  
      unitt = 'C'  
      unith = 'J  '  
      unithf = 'W    '  
      unitp = 'Pa '  
      unitep = 'J/kg'  
      unitvs = 'Pa-s'  
      cnvl = 1._kdp  
      cnvm = 1._kdp  
      cnvp = 1._kdp  
      cnvvs = 1._kdp  
      cnvcn = 1._kdp  
      cnvhe = 1._kdp  
      cnvme = 1._kdp  
      cnvt1 = 1._kdp  
      cnvt2 = 0._kdp  
      cnvthc = 1._kdp  
      cnvhtc = 1._kdp  
      cnvhf = 1._kdp  
  ELSE        ! ... this should never be entered because phast.tmp is in SI units
      unitm = 'lb'  
      unitl = 'ft'  
      unitt = 'F'  
      unith = 'BTU'  
      unithf = 'BTU/d'  
      unitp = 'psi'  
      unitep = 'ft-lbf/lbm'  
      unitvs = 'cp'  
      cnvl = .304800_kdp  
      cnvm = .4535924_kdp  
      cnvp = 6.894757e3_kdp  
      cnvvs = 0.0010_kdp  
      cnvcn = 144._kdp*32.174_kdp  
      cnvhe = 1055.056_kdp  
      cnvme = 9.290304e-2_kdp  
      cnvt1 = .5555556_kdp  
      cnvt2 = 32._kdp  
      cnvthc = cnvhe/(3600._kdp*cnvl*cnvt1)  
      cnvhtc = cnvthc/cnvl  
      cnvhf = cnvhtc*cnvt1  
  ENDIF
  cnvl2 = cnvl*cnvl  
  cnvl3 = cnvl2*cnvl  
  cnvd = cnvm/cnvl3  
  cnvvf = cnvl3/cnvtm  
  cnvff = cnvvf/cnvl2  
  cnvmf = cnvm/(cnvtm*cnvl2)  
  cnvsf = cnvmf  
  cnvdf = cnvl2/cnvtm  
  cnvvl = cnvl/cnvtm  
  cnvcn = cnvcn*cnvvl  
  cnvhc = cnvhe/(cnvm*cnvt1)  
  ! ... Calculate inverse conversion factors
  CNVLI = 1._kdp/CNVL
  cnvmi = 1._kdp/cnvm
  cnvpi = 1._kdp/cnvp
  cnvvsi = 1._kdp/cnvvs
  cnvcni = 1._kdp/cnvcn
  cnvhei = 1._kdp/cnvhe
  cnvmei = 1._kdp/cnvme
  cnvt1i = 1._kdp/cnvt1
  !  cnvthci = 1._kdp/cnvthc
  !  cnvhtci = 1._kdp/cnvhtc
  cnvhfi = 1._kdp/cnvhf
  cnvl2i = 1._kdp/cnvl2
  cnvl3i = 1._kdp/cnvl3
  cnvdi = 1._kdp/cnvd
  cnvvfi = 1._kdp/cnvvf
  cnvffi = 1._kdp/cnvff
  cnvmfi = 1._kdp/cnvmf
  cnvsfi = 1._kdp/cnvsf
  cnvdfi = 1._kdp/cnvdf
  cnvvli = 1._kdp/cnvvl
  cnvcni = 1._kdp/cnvcn
  cnvhci = 1._kdp/cnvhc
  cnvmfi = cnvmfi*cnvl2i  
  cnvt2i = 0._kdp
  IF (eeunit) cnvt2i = 32.0_kdp

  nsa = MAX(ns,1)
  ALLOCATE(caprnt(nxyz), & 
  STAT = a_err)
  IF (a_err /= 0) THEN
      PRINT *, "Array allocation failed: init1, point 5"  
      STOP
  ENDIF

  ! ... Allocate dependent variable arrays: mcv
  ALLOCATE (dzfsdt(nxy), dp(0:nxyz), dt(0:0),  &
  sxx(nxyz), syy(nxyz), szz(nxyz), vxx(nxyz), vyy(nxyz), vzz(nxyz),  &
  zfs(nxy),  &
  eh(1), frac(nxyz), sat(nxyz), frac_icchem(nxyz),  &
  p(nxyz), t(1),  &
  STAT = a_err)
  IF (a_err /= 0) THEN
      PRINT *, "Array allocation failed: init1, point 6"  
      STOP
  ENDIF
  dp = 0
  ! ... Allocate dependent variable arrays: mcv_m
  ! ...      component arrays
  ALLOCATE (icmax(nsa), jcmax(nsa), kcmax(nsa),  &
  indx_sol1_ic(7,nxyz), indx_sol2_ic(7,nxyz),  &
  vx_node(nxyz), vy_node(nxyz), vz_node(nxyz),  &
  dc(0:nxyz,nsa),  &
  dcmax(nsa), dsir(nsa), dsir_chem(nsa),  &
  stsaif(1), stsetb(1), stsfbc(nsa), stslbc(nsa),  &
  stsrbc(nsa), stsdbc(nsa), stssbc(nsa), stswel(nsa),  &
  ssresf(nsa), ssres(nsa), stotsi(nsa), stotsp(nsa),  &
  tsres(nsa), tsresf(nsa),  &
  qsfx(nxyz,nsa), qsfy(nxyz,nsa), qsfz(nxyz,nsa),  &
  sir(nsa), sir0(nsa), sirn(nsa), sir_prechem(nsa),  &
  totsi(nsa), totsp(nsa), tdsir_chem(nsa), tcsaif(nsa), tcsetb(nsa),  &
  tcsfbc(nsa), tcslbc(nsa), tcsrbc(nsa), tcsdbc(nsa), tcssbc(nsa),  &
  c(nxyz,nsa), ic_mxfrac(7,nxyz),   &
  STAT = a_err)
  IF (a_err /= 0) THEN
      PRINT *, "Array allocation failed: init1, point 7"  
      STOP
  ENDIF
  ! ... Allocate program control information: mcc_m
  ALLOCATE (dctas(nsa),  &
  STAT = a_err)
  IF (a_err /= 0) THEN
      PRINT *, "Array allocation failed: init1, point 8"  
      STOP
  ENDIF
  ! ... Allocate matrix of difference equations arrays: mcm
  ALLOCATE (rf(nxyz),  &
  STAT = a_err)
  IF (a_err /= 0) THEN
      PRINT *, "Array allocation failed: init1, point 9"  
      STOP
  ENDIF
  ! ... Allocate well information: mcw_m
  ALLOCATE(totwsi(nsa), totwsp(nsa),  &
  tqwsi(nsa), tqwsp(nsa), u10(nsa),  &
  STAT = a_err)
  IF (a_err /= 0) THEN
      PRINT *, "Array allocation failed: init1, point 10"
      STOP
  ENDIF
  c = 0._kdp
  zfs = -1.e20_kdp
  ! Done in phast_manager
  !  IF(solute) THEN  
  !     DO  iis=1,ns  
  !        comp_name(iis) = ucomp_name(iis)
  !     END DO
  !  ENDIF
  CALL pc_initialize         ! ... Initialize print control flags
END SUBROUTINE init1
