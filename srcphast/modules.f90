! ... Module files used for phast for definition of data groups
! ... $Id$
MODULE f_units
  ! ... fortran unit assignments
  IMPLICIT NONE
  SAVE
  INTEGER, PARAMETER :: fuins=15, fulp=16, fuplt=7, fuorst=8, fuirst=9, fuinc=10, furde=11, &
       fupmap=13, fuvmap=14, fup=21, fut=29, fuc=22, fuvel=23, fud=30, fuvs=31, fuwel=24, &
       fubal=25, fukd=26, fubcf=27, fuclog=28, fubnfr=32, fupmp2=33, fupzon=34, fuich=35,  &
       fuzf=36
  LOGICAL :: print_rde=.FALSE.
END MODULE f_units

MODULE machine_constants
  ! ... machine dependent parameters
  IMPLICIT NONE
  SAVE
  INTEGER, PARAMETER :: kdp = SELECTED_REAL_KIND(14,60)
  ! ... BGREAL: A large real number representable in single precision
  ! ... BGINT:  A large integer number representable in 4 bytes
  INTEGER, PARAMETER :: BGINT=9999
  REAL(KIND=kdp), PARAMETER :: bgreal=HUGE(1._kdp), one_plus_eps=1._kdp+5._kdp*EPSILON(1._kdp)
  REAL(KIND=kdp), PARAMETER :: macheps5=5._kdp*EPSILON(1._kdp)
END MODULE machine_constants

MODULE mcb
  ! ... boundary condition information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  TYPE :: bndry_cell
     INTEGER :: m_cell, num_faces
     INTEGER, DIMENSION(3) :: face_indx
     REAL(KIND=kdp), DIMENSION(3) :: por_areabc, qfbc
  END TYPE bndry_cell
  TYPE :: rbc_indices
     INTEGER :: m, seg_first, seg_last
  END TYPE rbc_indices
  INTEGER, DIMENSION(:), ALLOCATABLE :: indx1_sbc, indx2_sbc, indx1_fbc, indx2_fbc, &
       indx1_lbc, indx2_lbc, indx1_rbc, indx2_rbc
  INTEGER, DIMENSION(:), ALLOCATABLE :: ibc,  &
       maifc, mdbc, metbc, mfbc, mfsbc, mhcbc, mlbc, mrbc, msbc,  &
       mdbc_bot, mdseg_bot,  &
       mrbc_bot, mrbc_top, mrseg_bot,  &
       ifacefbc, ifacelbc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: fracnp,  &
       qfsbc, qhsbc, qffbc, qfbcv, qhfbc, qflbc, qhlbc, qfrbc, qhrbc,  &
       qfdbc, qhdbc,  &
       qfetbc, qhetbc, qfaif, qhaif, qsaif,  &
       ccfsb, ccfvsb, cchsb,  &
       ccffb, ccfvfb, cchfb,  &
       ccflb, ccfvlb, cchlb,  &
       ccfrb, ccfvrb, cchrb,  &
       ccfdb, ccfvdb, cchdb,  &
       sfsb, sfvsb, shsb, sffb, sfvfb, shfb, sflb, sfvlb, shlb, &
       sfdb, sfvdb, shdb,  &
       sfrb, sfvrb, shrb, sfetb, sfvetb, shetb, sfaif, sfvaif, shaif, shhcb, &
       ubblb, ubbrb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: csbc, ccssb, cfbc, ccsfb, clbc, &
       ccslb, crbc, ccsrb, ccsdb, ccsetb,  &
       qsflx
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: qsfbc, qslbc, qsrbc, qsdbc, qsetbc, &
       sssb, ssfb, sslb, ssrb, ssdb, ssetb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: qssbc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: psbc, tsbc,  &
       areafbc, denfbc, tflx, qfflx, &
       arealbc, albc, bblbc, blbc, denlbc, klbc, philbc, tlbc, vislbc, zelbc,  &
       arearbc, arbc, bbrbc, brbc, denrbc, krbc, phirbc, trbc, visrbc, zerbc,  &
       areadbc, adbc, bbdbc, bdbc, kdbc, zedbc,  &
       mxf_sbc, mxf_fbc, mxf_lbc, mxf_rbc
  INTEGER :: iaif, lnz1, lnz2, lnz3, lnz4, lnz7,  &
       nsbc=0, nsbc_cells=0, nsbc_seg=0,  &
       nfbc=0, nfbc_cells=0, nfbc_seg=0,  &
       nlbc=0, nlbc_cells=0, nlbc_seg=0,  &
       nrbc=0, nrbc_cells=0, nrbc_seg=0,  &
       ndbc=0, ndbc_cells=0, ndbc_seg=0,  &
       netbc=0, naifc=0,  &
       nhcbc=0, nhcn=0, nztphc=0, num_bndy_cells=0
  LOGICAL :: fresur
  INTEGER :: adj_wr_ratio, transient_fresur
  REAL(KIND=kdp) :: visdbc
!!$  REAL(KIND=kdp) :: ABOAR, ANGOAR, BOAR, F1AIF, F2AIF, FTDAIF, KOAR, POROAR, RIOAR, &
!!$       VISOAR, VOAR
  REAL(KIND=kdp), DIMENSION(:), POINTER :: qssbcv
  TYPE (bndry_cell), DIMENSION(:), ALLOCATABLE :: b_cell
  TYPE (rbc_indices), DIMENSION(:), ALLOCATABLE :: flux_seg_index, leak_seg_index,  &
       river_seg_index, drain_seg_index
END MODULE mcb

MODULE mcb2
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
!!$  TYPE :: zone_contents
!!$     INTEGER :: num_int_faces, num_svbc, num_fbc, num_lbc, num_rbc, num_dbc,  &
!!$          num_wellseg
!!$  END TYPE zone_contents
  !
  TYPE(internal_bndry_zone), DIMENSION(:), ALLOCATABLE :: zone_ib
  TYPE(zone_volume), DIMENSION(:), ALLOCATABLE :: zone_col
  TYPE(zone_cbc_cells), DIMENSION(:), ALLOCATABLE :: lnk_cfbc2zon, lnk_crbc2zon
  TYPE(zone_bc_cells), DIMENSION(:,:), ALLOCATABLE :: lnk_bc2zon
  TYPE(well_segments), DIMENSION(:), ALLOCATABLE :: seg_well
  CHARACTER(LEN=80), DIMENSION(:), ALLOCATABLE :: zone_title
  INTEGER :: num_flo_zones
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: uzmwel
END MODULE mcb2

MODULE mcc
  ! ... program control information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: iprint_chem, iprint_xyz
  INTEGER, DIMENSION(:), ALLOCATABLE :: lprnt1, lprnt2, lprnt3, lprnt4, vmask
  INTEGER, DIMENSION(100) :: idmptm
  LOGICAL, DIMENSION(200) :: ierr = .FALSE.
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: dctas
  REAL(KIND=kdp), DIMENSION(100) :: dmptm
  INTEGER :: ieq, itnoc, itnop, itnot, itrn, jtime
  INTEGER :: iprptc, ltcom, maxitn, ntsfal, orenpr, &
       slmeth, tmunit
  REAL(KIND=kdp) :: pribcf, pricpd, pridv,  &
       prihdf_head, prihdf_vel, prihdf_conc,  &
       prigfb, prikd, primapcomp, primaphead, primapv, primin, prip, prit, pric,  &
       pricphrq, priforce_chem_phrq, prislm, pri_well_timser, &
       privel, priwel, pri_zon_flo
  REAL(KIND=kdp) :: timprbcf, timprcpd, timprdv,  &
       timprhdfh, timprhdfv, timprhdfcph,  &
       timprgfb, timprkd, timprmapc, timprmaph, timprmapv, timprp, timprc, timprcphrq,  &
       timprfchem, timprslm, timprtem, &
       timprvel, timprwel, timprzf, timprtnxt
  LOGICAL :: argrid, comopt, errexe, errexi, ichwt, ichydp, pltzon, prtbc, prtdv, prtfp,  &
       prtic, prtichead=.FALSE., prtpmp, prtslm, prtwel, prt_kd, prt_bc, prt_zon_flo,  &
       prtic_c, prtic_mapc, prtic_p, prtic_maphead, prtic_conc, prtic_force_chem,  &
       prtss_vel, prtss_mapvel, prtic_well_timser,  &
       prtichdf_conc, prtichdf_head, prtsshdf_vel,  &
       rdaif=.FALSE., rdcalc, rdetbc=.FALSE., rdflxh=.FALSE., rdflxq=.FALSE.,  &
       rdflxs=.FALSE., rdlbc=.FALSE., &
       rdrbc=.FALSE., rdscbc=.FALSE., rdspbc=.FALSE., rdstbc=.FALSE., rdvaif=.FALSE.,  &
       rdwtd=.FALSE., restrt, svbc, solve, thru=.FALSE.
  LOGICAL :: autots, chkptd, cntmaph, cntmapc, crosd, cylind, eeunit, gausel, heat, milu,  &
       savldo, &
       scalmf, solute, tsfail, vecmap
  LOGICAL :: oldstyle_head_file=.FALSE.
  LOGICAL :: prslm=.FALSE., prkd=.FALSE., prp=.FALSE., prc=.FALSE., prcphrq=.FALSE., &
       prf_chem_phrq=.FALSE., prvel=.FALSE., prgfb=.FALSE., prbcf=.FALSE., przf=.FALSE.,  &
       prwel=.FALSE.,  &
       prhdfh=.FALSE., prhdfv=.FALSE., prhdfc=.FALSE., prmapc=.FALSE., prmaph=.FALSE., &
       prmapv=.FALSE., prtem=.FALSE., prcpd=.FALSE.
  INTEGER :: prcphrqi, prf_chem_phrqi, prslmi, prhdfci, prhdfhi, prhdfvi
  INTEGER :: ntprbcf, ntprcpd, ntprhdfv, ntprhdfh, ntprgfb, ntprkd, ntprmapcomp,   &
       ntprmaphead, ntprmapv, ntprp, ntprzf,  &
       ntprc, ntprvel, ntprwel, ntprtem
  LOGICAL :: steady_flow, converge_ss
  REAL(KIND=kdp) :: timchg, timrst, rebalance_fraction_f = 0.5_kdp
  INTEGER :: rebalance_method_f
  REAL(KIND=kdp) :: dptas=0.0_kdp, dtimmn=0.0_kdp, dtimmx=0.0_kdp, dtimu=0.0_kdp, dttas=0.0_kdp, &
       eps = 1.e-5_kdp, epsfs, timprt, &
       tolden, toldnc, toldnt, growth_factor_ss = 2.0
  REAL(KIND=kdp) :: eps_p=1.d2, eps_flow=1.d-4
END MODULE mcc

MODULE mcch
  ! ... character strings for output
  IMPLICIT NONE
  SAVE
  CHARACTER(LEN=11), DIMENSION(:), ALLOCATABLE :: caprnt
  CHARACTER(LEN=10), DIMENSION(:), ALLOCATABLE :: comp_name
  CHARACTER(LEN=160) :: titleo, title
  CHARACTER(LEN=14) :: plbl = 'Pressures     ', tlbl = 'Temperatures  ', clbl = 'Mass Fractions'
  CHARACTER(LEN=130) :: dash = '------------------------------------------------------------&
       &----------------------------------------------------------------------', &
       dots = '........................................................................&
       &..........................................................'
  CHARACTER(LEN=255) :: f1name, f2name, f3name
  CHARACTER(LEN=15) :: name 
  CHARACTER(LEN=1) :: rxlbl, unitt
  CHARACTER(LEN=6) :: mflbl
  CHARACTER(LEN=2) :: unitm, unitl
  CHARACTER(LEN=3) :: unittm, unith, unitp
  CHARACTER(LEN=5) :: unithf
  CHARACTER(LEN=10) :: unitep
  CHARACTER(LEN=4) :: unitvs
  CHARACTER(LEN=8) :: utulbl
  CHARACTER(LEN=8) :: version_name
END MODULE mcch

MODULE mcg
  ! ... region geometry information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: i1z, i2z, j1z, j2z, k1z, k2z
  LOGICAL, DIMENSION(:,:,:), ALLOCATABLE :: xd_mask
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: arx, ary, arz, arxfbc, aryfbc, arzfbc, arzetb
  INTEGER, DIMENSION(3) :: naxes
  INTEGER :: mijkm, mijkp, mijmk, mijpk, mimjk, mipjk
  INTEGER :: mtp1
  INTEGER :: npmz, nx, nxy, nxyz, ny, nz, nxyzh
  LOGICAL :: tilt,unigrx,unigry,unigrz
  REAL(KIND=kdp) :: thetxz, thetyz, thetzz
  TYPE :: CellIndices
     INTEGER ix, iy, iz
  END TYPE CellIndices
  TYPE (CellIndices), DIMENSION(:), ALLOCATABLE :: cellijk
  !
CONTAINS
  FUNCTION cellno(i,j,k) 
    IMPLICIT NONE
    INTEGER :: cellno
    INTEGER :: i,j,k
    cellno=(k-1)*nxy+(j-1)*nx+i
  END FUNCTION cellno
  !
END MODULE mcg

MODULE mcm
  ! ... matrix of difference equations information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: cc24, cc34, cc35, rhfsbc, urr1
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE, TARGET :: rhs
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: va, vafsbc
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: rhssbc
  REAL(KIND=kdp), DIMENSION(:,:,:), ALLOCATABLE, TARGET :: vassbc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: rf
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: rs, rs1
  REAL(KIND=kdp) :: c11, c12, c13, c21, c22, c23, c24, c31, c32, c33, c34, c35, cfp, csp, &
       efp, esp
  REAL(KIND=kdp), DIMENSION(:), POINTER :: rhs_r, rhs_b, rhsbcv
  REAL(KIND=kdp), DIMENSION(:,:), POINTER :: vasbcv
END MODULE mcm

MODULE mcn
  ! ... node information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: rm, x, y, z, x_node, y_node, z_node, &
       xele, yele, zele, x_face, y_face, z_face, pv0
END MODULE mcn

MODULE mcp
  ! ... parameter information
  USE machine_constants
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: kthx, kthy, kthz,  &
       kx, ky, kz,  &
       kxx, kyy, kzz, rcppm, tfx, tfy, tfz, thx, thxy, thxz, thy, thyx, thyz, thz, thzx, thzy, &
       tsx, tsxy, tsxz, tsy, tsyx, tsyz, tsz, tszx, tszy
!!$  ! ... Coefficients for the Fanchi approximating equation to the Van Everdingen and Hurst A.I.F.
!!$  REAL(KIND=kdp), DIMENSION(0:3) :: BBAIF = (/-0.82092D0,3.68D-4,-0.28908D0,-0.02882D0/)
!!$! ... Set up the tables of fluid properties
!!$! ... from Keenan et.al. steam tables (1969)
!!$! ...    Saturated water enthalpy (J/kg) vs. temperature (deg.C)
!!$  REAL(KIND=kdp), DIMENSION(14) :: TEHDT = (/0.,20.,40.,60.,80.,100.,120.,140.,160.,180.,200., &
!!$       260.,300.,350./)
!!$  REAL(KIND=kdp), DIMENSION(32) :: TEHST = (/0.,10.,20.,30.,40.,50.,60.,70.,80.,90.,100., &
!!$             120.,140.,160.,180.,200.,220.,240.,250.,260.,270.,280.,290.,300.,310., &
!!$             320.,330.,340.,350.,0.,0.,0./)
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: abpm, alphl, alphth, alphtv, pmchv, pmcv, pmhv,  &
       pv, pvk, &
       poros, ss, tx, ty, tz
  INTEGER :: npehdt = 10, nehst = 29, ntehdt = 14
  REAL(KIND=kdp) :: denf0, denf1, pinit, zpinit
  REAL(KIND=kdp) :: bp, bt, cnvtm, cnvcn, cnvd, cnvdf, cnvhc, cnvhe, cnvhf, cnvhtc, cnvff, &
       cnvl, cnvl2, cnvl3, cnvm, cnvme, cnvmf, cnvp, cnvsf, cnvthc, cnvvf, cnvvl, cnvvs, &
       cnvt1, cnvt2, cnvtmi, cnvcni, cnvdi, cnvdfi, cnvhci, cnvhei, cnvhfi, cnvhti, cnvffi, &
       cnvli, cnvl2i, cnvl3i, cnvmi, cnvmei, cnvmfi, cnvpi, cnvsfi, cnvtci, cnvvfi, cnvvli, &
       cnvvsi, cnvt1i, cnvt2i, cpf, declam, den0, denc, denp, dent, dm, eh0, fdsmth, fdtmth, &
       gx, gy, gz, kthf, p0, p0h, paatm, t0, t0h, visfac, w0, w1
  REAL(KIND=kdp) :: fdtmth_ssflow=1._kdp, fdtmth_trans
END MODULE mcp

MODULE mcs
  ! ... equation solver information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: ind, ip1, ip1r, ipenv, mrno, mord
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: ci, cin, cir, cirl, cirh
  ! ... MAR for RCG solver
  ! ... The M array relates the local 19-point stencil indices of the
  ! ...      reduced matrix to the VA matrix. 
  INTEGER, DIMENSION(6,6) :: mar = RESHAPE((/10,5,4,3,2,1, 15,10,8,7,6,2, 16,12,10,9,7,3,  &
       17,13,11,10,8,4, 18,14,13,12,10,5, 19,18,17,16,15,10/), (/6,6/))
  INTEGER, DIMENSION(19,19) :: mar1
  INTEGER ::  idir, maxit1, maxit2, nbn, nrn, nohst, nd4n, nprist, &
       nral, nsdr, nstslv, nstsor, ntsopt
  REAL(KIND=kdp) :: epsomg, epsslv
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: diagc, diagr
  ! ... LRCGD1=37 and LRCGD2=18 if LU fill-in is desired,
  ! ...      otherwise LRCGD1=19 and LRCGD2=10 for no fill-in
  INTEGER, PARAMETER :: lsdr=5, lrcgd1=19, lrcgd2=10
  LOGICAL :: col_scale=.FALSE., row_scale=.TRUE.
  LOGICAL :: ident_diagc
END MODULE mcs

MODULE mcs2
  ! ... equation solver data arrays
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE, SAVE :: diagra, envlra, envura, rr, sss, ww, xx, zz, &
       sumfil
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, SAVE :: ap, bbp, ra
END MODULE mcs2

MODULE mct
  ! ... temporary arrays for output
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: aprnt1, aprnt2, aprnt3, aprnt4
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: c_mol
END MODULE mct

MODULE mcv
  ! ... dependent variable information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: icmax, jcmax, kcmax, icsbc, icfbc, iclbc, icrbc
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: indx_sol1_ic, indx_sol2_ic
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: axsav, aysav, azsav, dzfsdt, dp, dt, &
       sxx, syy, szz, vxx, vyy, vzz,  &
       vx_node, vy_node, vz_node,  &
       dcmax, dsir, dsir_chem, ssres, ssresf, stotsi, stotsp, stsaif, &
       stsetb, stsfbc, stslbc, stsrbc, stsdbc, stssbc, stswel, tsres, tsresf, zfs
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: qsfx, qsfy, qsfz
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: dc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  den, eh, frac, zfsn, frac_icchem,  &
       p, t, vis, sir, sir0, sirn, sir_prechem,  &
       totsi, totsp, tdsir_chem, tcsaif, tcsetb, tcsfbc, tcslbc, tcsrbc, tcsdbc, tcssbc
!$$  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE ::  c, ic_mxfrac, bc_mxfrac
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE ::  c, ic_mxfrac
  INTEGER :: ipmax, itmax, jpmax, jtmax, kpmax, ktmax, is
  INTEGER :: itime, nmapr, nrsttp, ns=0
  REAL(KIND=kdp) :: ddnmax, dehir, dfir, dhmax, dpmax, dtmax,  &
       sfres, sfresf, shres, shresf, stfaif,  &
       stfetb, stffbc, stflbc, stfrbc, stfdbc, stfsbc, stfwel,  &
       sthaif, sthetb, sthfbc, sthhcb, sthlbc, &
       sthrbc, sthsbc, sthwel, stotfi, stotfp, stothi, stothp, tfres, tfresf, thres, thresf
  REAL(KIND=kdp) :: deltim, deltim_sav, deltim_transient, ehir, ehir0, ehirn, fir, fir0, firn,  &
       firv0, firv, time, &
       totfi, &
       totfp, tothi, tothp,  &
       tcfaif, tcfetb, tcffbc, tcflbc, tcfrbc, tcfdbc, tcfsbc, tchaif, tchetb, &
       tchfbc, tchhcb, tchlbc, tchrbc, tchsbc
  REAL(KIND=kdp), DIMENSION(:), POINTER :: dcv, qsfxis, qsfyis, qsfzis
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qfzoni, qfzonp, qfzoni_sbc, qfzonp_sbc,  &
       qfzoni_fbc, qfzonp_fbc,  qfzoni_lbc, qfzonp_lbc,  qfzoni_rbc, qfzonp_rbc,   &
       qfzoni_dbc, qfzonp_dbc,  qfzoni_wel, qfzonp_wel
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE ::  qszoni, qszonp, qszoni_sbc, qszonp_sbc,  &
       qszoni_fbc, qszonp_fbc,  qszoni_lbc, qszonp_lbc,  qszoni_rbc, qszonp_rbc,   &
       qszoni_dbc, qszonp_dbc,  qszoni_wel, qszonp_wel
END MODULE mcv

MODULE mcw
  ! ... well information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: indx1_wel, indx2_wel, iw, jw, lcbw, lctw, nkswel, &
       welidno, wqmeth
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: mwel
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: dpwkt, tfw, qhw, qwm, rhsw, &
       stfwi, sthwi, stfwp, sthwp, udenw, tqwsi, tqwsp , u10
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: qflyr, qhlyr, qsw, qwlyr, stswi, stswp, vaw
  REAL(KIND=kdp), DIMENSION(:,:,:), ALLOCATABLE :: qslyr
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: dthawr, ehwkt, ehwsur, htcwr, kthawr, kthwr, &
       mxf_wel, pwkt, pwkts, pwsur, pwsurs, qwv, tabwr, tatwr, twkt, twsrkt, twsur, wbod, &
       wfrac, wficum, wfpcum, whicum, whpcum, wrangl, wrid, wrisl, wrruf, xw, yw, zwb, zwt, &
       dwb, dwt, totwsi, totwsp
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: cwkt, cwkts, denwk, dqwdpl, ehwk, &
       pwk, twk, wi, wsicum, wspcum, wsf
  REAL(KIND=kdp), DIMENSION(:,:,:), ALLOCATABLE :: cwk
  INTEGER :: isign, nshut
  INTEGER, PARAMETER :: maxord=6, maxpts=10, meth=1
  INTEGER ::  mxitqw, nwel
  LOGICAL :: cwatch, wrcalc
  REAL(KIND=kdp) :: b0, b1, b2, c00, dengl, dntest, ehwend, gcosth, p00, pwrend, qhfac, t00, &
       tqwfi, tqwfp, tqwhi, tqwhp, twrend, wridt
  REAL(KIND=kdp) :: damwrc, denwkt, denwrk, dtadzw, dzmin, eh00, eod, epswr, qwr, tambi, toldpw, &
       tolfpw, tolqw, totwfi, totwfp, totwhi, totwhp
END MODULE mcw

MODULE mg2
  ! ... read group 2 global parameters
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: uxx, uklb, uzelb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: wcfl, wcfu
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: hdprnt, delz, arxbc, arybc, arzbc, hwt, &
       uvka
END MODULE mg2

MODULE mg3
  ! ... read group 3 global parameters
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: pnp, qff, qffx, qffy, qffz, qhfx, qhfy, qhfz, &
       tnp, ucbc, udenbc, udenlb, uphilb, uphirb, uqetb, uqs, utbc, uvislb
END MODULE mg3

MODULE phys_const
  ! ... physical and mathematical constants
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), PARAMETER :: pi = 3.1415926535898_kdp, grav = 9.80665_kdp, twopi = 2._kdp*pi
END MODULE phys_const
