! ... Module files used for phast for definition of data groups
! ... These modules are used by the manager program
! ... $Id: modules_manager.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp $

MODULE mcb_m
  ! ... boundary condition information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  TYPE :: bndry_cell
     INTEGER :: m_cell, num_faces
     INTEGER, DIMENSION(3) :: face_indx
     REAL(KIND=kdp), DIMENSION(3) :: por_areabc, qfbc
  END TYPE bndry_cell
  CHARACTER(LEN=9), DIMENSION(:), ALLOCATABLE :: ibc_string
  INTEGER, DIMENSION(:), ALLOCATABLE :: indx1_sbc, indx2_sbc, indx1_fbc, indx2_fbc, &
       indx1_lbc, indx2_lbc, indx1_rbc, indx2_rbc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
       ccfsb, ccfvsb, cchsb,  &
       ccffb, ccfvfb, cchfb,  &
       ccflb, ccfvlb, cchlb,  &
       ccfrb, ccfvrb, cchrb,  &
       ccfdb, ccfvdb, cchdb,  &
       sfsb, sfvsb, shsb, sffb, sfvfb, shfb, sflb, sfvlb, shlb, &
       sfdb, sfvdb, shdb,  &
       sfrb, sfvrb, shrb, sfetb, sfvetb, shetb, sfaif, sfvaif, shaif, shhcb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: csbc, ccssb, cfbc, ccsfb, clbc,  &
       ccslb, crbc, ccsrb, ccsdb, ccsetb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: cfbc_n, clbc_n, crbc_n
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: qsfbc, qslbc, qsrbc, qsdbc, qsetbc, &
       qsaif, qsflx, qsflx_n,  &
       sssb, ssfb, sslb, ssrb, ssdb, ssetb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: qssbc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: mxf_sbc, mxf_fbc, mxf_lbc, mxf_rbc
  INTEGER :: iaif, lnz1, lnz2, lnz3, lnz4, lnz7
  REAL(KIND=kdp), DIMENSION(:), POINTER :: qssbcv
  TYPE (bndry_cell), DIMENSION(:), ALLOCATABLE :: b_cell
END MODULE mcb_m

MODULE mcb2_m
  ! ... boundary condition information; set 2
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  TYPE :: internal_bndry_zone
     INTEGER :: num_int_faces
     INTEGER, DIMENSION(:), POINTER :: mcell_no, face_indx
  END TYPE internal_bndry_zone
  TYPE :: zone_volume
     INTEGER :: num_xycol
     INTEGER, DIMENSION(:), POINTER :: i_no, j_no, kmin_no, kmax_no
  END TYPE zone_volume
  TYPE :: zone_cbc_cells
     INTEGER :: num_bc
     INTEGER, DIMENSION(:), POINTER :: lcell_no, mxy_no, icz_no
  END TYPE zone_cbc_cells
  TYPE :: zone_bc_cells
     INTEGER :: num_bc
     INTEGER, DIMENSION(:), POINTER :: lcell_no
  END TYPE zone_bc_cells
  TYPE :: well_segments
     INTEGER :: num_wellseg
     INTEGER, DIMENSION(:), POINTER :: iwel_no, ks_no
  END TYPE well_segments

  TYPE(internal_bndry_zone), DIMENSION(:), ALLOCATABLE :: zone_ib
  TYPE(zone_volume), DIMENSION(:), ALLOCATABLE :: zone_col
  TYPE(zone_cbc_cells), DIMENSION(:), ALLOCATABLE :: lnk_cfbc2zon, lnk_crbc2zon
  TYPE(zone_bc_cells), DIMENSION(:,:), ALLOCATABLE :: lnk_bc2zon
  TYPE(well_segments), DIMENSION(:), ALLOCATABLE :: seg_well
  CHARACTER(LEN=80), DIMENSION(:), ALLOCATABLE :: zone_title
  INTEGER, DIMENSION(:), ALLOCATABLE :: zone_number
  CHARACTER(LEN=140), DIMENSION(:), ALLOCATABLE :: zone_filename_heads
  LOGICAL, DIMENSION(:), ALLOCATABLE :: zone_write_heads
  INTEGER :: num_flo_zones
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: uzmwel
END MODULE mcb2_m

MODULE mcc_m
  ! ... program control information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: vmask
  INTEGER, DIMENSION(100) :: idmptm
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: dctas
  REAL(KIND=kdp), DIMENSION(100) :: dmptm
  REAL(KIND=kdp) :: pribcf, pricpd, pridv,  &
       prihdf_head, prihdf_vel, prihdf_conc, prihdf_intermediate, &
       prigfb, prikd, primapcomp, primaphead, primapv, primin, prip, prit, pric,  &
       pricphrq, priforce_chem_phrq, prislm, pri_well_timser, &
       privel, priwel, pri_zf, pri_zf_tsv
  REAL(KIND=kdp) :: timprbcf, timprcpd, timprdv,  &
       timprhdfh, timprhdfv, timprhdfcph, timprhdfi, &
       timprgfb, timprkd, timprmapc, timprmaph, timprmapv, timprp, timprc, timprcphrq,  &
       timprfchem, timprslm, timprtem, &
       timprvel, timprwel, timprzf, timprzf_tsv, timprtnxt
  ! ... print control flags for zone_flow heads + print_zone_flows_heads    
  REAL (KIND=kdp) :: pri_zf_xyzt, timprzf_xyzt
  LOGICAL :: przf_xyzt=.false.
  INTEGER :: ntprzf_xyzt
  LOGICAL :: ichwt, ichydp, pltzon, prtbc, prtdv, prtfp,  &
       prtic, prtichead=.FALSE., prtpmp, prtslm, prtwel, prt_kd, prt_bc, &
       prtic_c, prtic_mapc, prtic_p, prtic_maphead, prtic_conc, prtic_force_chem,  &
       prtss_vel, prtss_mapvel, prtic_well_timser,  &
       prtichdf_conc, prtichdf_head, prtsshdf_vel
  LOGICAL :: chkptd, cntmaph, cntmapc,  &
       savldo, vecmap
  LOGICAL :: prslm=.FALSE., prkd=.FALSE., prp=.FALSE., prc=.FALSE., prcphrq=.FALSE., &
       prf_chem_phrq=.FALSE., prvel=.FALSE., prgfb=.FALSE., prbcf=.FALSE., przf=.FALSE.,  &
       przf_tsv=.FALSE., prwel=.FALSE., prhdfi=.FALSE., &
       prhdfh=.FALSE., prhdfv=.FALSE., prhdfc=.FALSE., prmapc=.FALSE., prmaph=.FALSE., &
       prmapv=.FALSE., prtem=.FALSE., prcpd=.FALSE.
  INTEGER :: ntprbcf, ntprcpd, ntprhdfv, ntprhdfh, ntprgfb, ntprkd, ntprmapcomp,   &
       ntprmaphead, ntprmapv, ntprp, ntprzf, ntprzf_tsv, &
       ntprc, ntprvel, ntprwel, ntprtem
  REAL(KIND=kdp) ::  &
       timprt, growth_factor_ss = 2.0
  REAL(KIND=kdp) :: eps_p=1.d2, eps_flow=1.d-4
END MODULE mcc_m

MODULE mcch_m
  ! ... character strings for output
  IMPLICIT NONE
  SAVE
  CHARACTER(LEN=160) :: titleo, title
  CHARACTER(LEN=14) :: plbl = 'Pressures     ', tlbl = 'Temperatures  ', clbl = 'Mass Fractions'
  CHARACTER(LEN=15) :: name 
  CHARACTER(LEN=2) :: unitm, unitl
  CHARACTER(LEN=3) :: unith, unitp
  CHARACTER(LEN=5) :: unithf
  CHARACTER(LEN=10) :: unitep
  CHARACTER(LEN=4) :: unitvs
END MODULE mcch_m

MODULE mcg_m
  ! ... region geometry information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  LOGICAL :: tilt,unigrx,unigry,unigrz
  REAL(KIND=kdp) :: thetxz, thetyz, thetzz
END MODULE mcg_m

MODULE mcm_m
  ! ... matrix of difference equations information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: rhssbc
  REAL(KIND=kdp), DIMENSION(:,:,:), ALLOCATABLE, TARGET :: vassbc
END MODULE mcm_m

MODULE mcp_m
  ! ... parameter information
  USE machine_constants
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
       kx, ky, kz, kxx, kyy, kzz
  INTEGER :: npehdt = 10, nehst = 29, ntehdt = 14
  REAL(KIND=kdp) :: pinit, zpinit
  REAL(KIND=kdp) :: fdtmth_ssflow=1._kdp
END MODULE mcp_m

MODULE mct_m
  ! ... temporary arrays for output
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: aprnt1, aprnt2, aprnt3, aprnt4
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: c_mol
END MODULE mct_m

MODULE mcv_m
  ! ... dependent variable information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: icmax, jcmax, kcmax, icsbc, icfbc, iclbc, icrbc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
       vx_node, vy_node, vz_node,  &
       dcmax, dsir, dsir_chem, ssres, ssresf, stotsi, stotsp, stsaif, &
       stsetb, stsfbc, stslbc, stsrbc, stsdbc, stssbc, stswel, tsres, tsresf
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: qsfx, qsfy, qsfz
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: dc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
       sir, sir0, sirn, sir_prechem,  &
       totsi, totsp, tdsir_chem, tcsaif, tcsetb, tcsfbc, tcslbc, tcsrbc, tcsdbc, tcssbc
  INTEGER :: is
  INTEGER :: nmapr, nrsttp
  INTEGER :: ipmax, jpmax, kpmax
  REAL(KIND=kdp) :: ddnmax, dehir, dfir, dhmax, dpmax, dtmax,  &
       sfres, sfresf, shres, shresf, stfaif,  &
       stfetb, stffbc, stflbc, stfrbc, stfdbc, stfsbc, stfwel,  &
       sthaif, sthetb, sthfbc, sthhcb, sthlbc, &
       sthrbc, sthsbc, sthwel, stotfi, stotfp, stothi, stothp, tfres, tfresf, thres, thresf
  REAL(KIND=kdp) :: ehir, ehir0, ehirn, fir, fir0, firn,  &
       firv0, firv,  &
       totfi,  &
       totfp, tothi, tothp,  &
       tcfaif, tcfetb, tcffbc, tcflbc, tcfrbc, tcfdbc, tcfsbc, tchaif, tchetb,  &
       tchfbc, tchhcb, tchlbc, tchrbc, tchsbc
  INTEGER :: exchange_units, surface_units, ssassemblage_units,  &
       ppassemblage_units, gasphase_units, kinetics_units
  REAL(KIND=kdp), DIMENSION(:), POINTER :: dcv, qsfxis, qsfyis, qsfzis
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qfzoni, qfzonp, qfzoni_int, qfzonp_int,  &
       qfzoni_sbc, qfzonp_sbc,  &
       qfzoni_fbc, qfzonp_fbc, qfzoni_lbc, qfzonp_lbc, qfzoni_rbc, qfzonp_rbc,   &
       qfzoni_dbc, qfzonp_dbc, qfzoni_wel, qfzonp_wel
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: qszoni, qszonp, qszoni_int, qszonp_int,  &
       qszoni_sbc, qszonp_sbc,  &
       qszoni_fbc, qszonp_fbc, qszoni_lbc, qszonp_lbc, qszoni_rbc, qszonp_rbc,   &
       qszoni_dbc, qszonp_dbc, qszoni_wel, qszonp_wel
  REAL(KIND=kdp), DIMENSION(:,:,:), ALLOCATABLE :: qface_in, qface_out ! 0:ns,izn,6
END MODULE mcv_m

MODULE mcw_m
  ! ... well information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: indx1_wel, indx2_wel
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
       stfwi, sthwi, stfwp, sthwp, tqwsi, tqwsp, u10
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: stswi, stswp
  REAL(KIND=kdp), DIMENSION(:,:,:), ALLOCATABLE :: qslyr
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: qsw, qsw_n
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: cwkt, cwkts
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: mxf_wel,  &
       wficum, wfpcum, whicum, whpcum,  &
       totwsi, totwsp
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: wsicum, wspcum
  REAL(KIND=kdp), DIMENSION(:,:,:), ALLOCATABLE :: cwk
  REAL(KIND=kdp) :: tqwfi, tqwfp, tqwhi, tqwhp
  REAL(KIND=kdp) :: totwfi, totwfp, totwhi, totwhp
END MODULE mcw_m

MODULE mg2_m
  ! ... read group 2 global parameters
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: hdprnt, delz, arxbc, arybc, arzbc, hwt, &
       wt_elev
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: wcfl, wcfu
END MODULE mg2_m

MODULE mg3_m
  ! ... read group 3 global parameters
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: pnp, qff
END MODULE mg3_m

MODULE hdf_media_m
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  LOGICAL :: pr_hdf_media
  REAL(KIND=kdp) :: k_input_to_si, s_input_to_si, alpha_input_to_si
  REAL(KIND=kdp) :: fluid_density, fluid_compressibility, fluid_viscosity
  CHARACTER(LEN=120) :: k_units, s_units, alpha_units
END MODULE hdf_media_m
