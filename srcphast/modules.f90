! ... Module files used for phast for definition of data groups
! ... $Id$
MODULE f_units
! ... fortran unit assignments
  IMPLICIT NONE
  SAVE
  INTEGER, PARAMETER :: fuins=15, fulp=16, fuplt=7, fuorst=8, fuirst=9, fuinc=10, furde=11, &
           fupmap=13, fuvmap=14, fup=21, fut=29, fuc=22, fuvel=23, fud=30, fuvs=31, fuwel=24, &
           fubal=25, fukd=26, fubcf=27, fuclog=28, fubnfr=32, fupmp2=33, fupzon=34, fuich=35
  LOGICAL :: print_rde=.false.
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
     INTEGER :: m_cell, num_faces, num_same_bc
     INTEGER, DIMENSION(3) :: face_indx, bc_type, lbc_indx
     REAL(KIND=kdp), DIMENSION(3) :: por_areabc
  END TYPE bndry_cell
  TYPE :: rbc_indices
     INTEGER :: m, seg_first, seg_last
  END TYPE rbc_indices
  INTEGER, DIMENSION(:), ALLOCATABLE :: indx1_sbc, indx2_sbc, indx1_fbc, indx2_fbc, &
       indx1_lbc, indx2_lbc, indx1_rbc, indx2_rbc
  INTEGER, DIMENSION(:), ALLOCATABLE :: ibc,maifc,metbc,mfbc,mfsbc,mhcbc,mlbc,mrbc,msbc,  &
       mrbc_bot, mrseg_bot
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: fracnp, mxf_sbc, mxf_fbc, mxf_lbc, mxf_rbc, &
       qfsbc, qhsbc, qflbc, qhlbc, qfrbc, qhrbc, qfetbc, qhetbc, qfaif, qhaif, qsaif, &
       sfsb, sfvsb, shsb, sffb, sfvfb, shfb, sflb, sfvlb, shlb, &
       sfrb, sfvrb, shrb, sfetb, sfvetb, shetb, sfaif, sfvaif, shaif, shhcb, &
       ubblb, ubbrb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: qslbc, qsrbc, qsetbc, &
       sssb, ssfb, sslb, ssrb, ssetb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, target :: QSSBC
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: psbc, tsbc, ccfsb, ccfvsb, cchsb, &
       denfbc, qffbc, qhfbc, tflx, ccffb, ccfvfb, cchfb, albc, bblbc, blbc, denlbc, &
       klbc, philbc, tlbc, vislbc, zelbc, ccflb, ccfvlb, cchlb, &
       arbc, bbrbc, brbc, denrbc, krbc, phirbc, trbc, visrbc, zerbc, &
       ccfrb, ccfvrb, cchrb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: csbc, ccssb, cflx, qsfbc, ccsfb, clbc, &
       ccslb, crbc, ccsrb, ccsetb
  INTEGER :: iaif, lnz1, lnz2, lnz3, lnz4, lnz7, nsbc=0, nfbc=0, nlbc=0, nrbc=0, nrbc_cells=0, nrbc_seg=0,  &
       netbc=0, naifc=0,  &
       nhcbc=0, nhcn=0, nztphc=0, num_bndy_cells=0
  LOGICAL :: fresur
  INTEGER :: adj_wr_ratio, transient_fresur
!!$  REAL(KIND=kdp) :: ABOAR, ANGOAR, BOAR, F1AIF, F2AIF, FTDAIF, KOAR, POROAR, RIOAR, &
!!$       VISOAR, VOAR
  REAL(KIND=kdp), DIMENSION(:), pointer :: qssbcv
  TYPE (bndry_cell), DIMENSION(:), ALLOCATABLE :: b_cell
  TYPE (rbc_indices), DIMENSION(:), ALLOCATABLE :: river_seg_index
END MODULE mcb

MODULE mcc
! ... program control information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: iprint_chem, iprint_xyz
  INTEGER, DIMENSION(:), ALLOCATABLE :: lprnt1, lprnt2, lprnt3, lprnt4, vmask
  INTEGER, DIMENSION(100) :: idmptm
  LOGICAL, DIMENSION(200) :: ierr = .false.
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: dctas
  REAL(KIND=kdp), DIMENSION(100) :: dmptm
  INTEGER :: ieq, itnoc, itnop, itnot, itrn, jtime
  INTEGER :: iprptc, ltcom, maxitn, ntsfal, orenpr, &
       slmeth, tmunit
  REAL(KIND=kdp) :: pribcf, pricpd, pridv,  &
       prihdf_head, prihdf_vel, prihdf_conc,  &
       prigfb, prikd, primapcomp, primaphead, primapv, primin, prip, prit, pric,  &
       pricphrq, priforce_chem_phrq, prislm, pri_well_timser, &
       privel, priwel
  REAL(KIND=kdp) :: timprbcf, timprcpd, timprdv,  &
       timprhdfh, timprhdfv, timprhdfcph,  &
       timprgfb, timprkd, timprmapc, timprmaph, timprmapv, timprp, timprc, timprcphrq,  &
       timprfchem, timprslm, timprtem, &
       timprvel, timprwel, timprtnxt
  LOGICAL :: argrid, comopt, errexe, errexi, ichwt, ichydp, pltzon, prtbc, prtdv, prtfp,  &
       prtic, prtichead, prtpmp, prtslm, prtwel, prt_kd, prt_bc,  &
       prtic_c, prtic_mapc, prtic_p, prtic_maphead, prtic_conc, prtic_force_chem,  &
       prtss_vel, prtss_mapvel, prtic_well_timser,  &
       prtichdf_conc, prtichdf_head, prtsshdf_vel,  &
       rdaif=.false., rdcalc, rdetbc=.false., rdflxh=.false., rdflxq=.false.,  &
       rdflxs=.false., rdlbc=.false., &
       rdrbc=.false., rdscbc=.false., rdspbc=.false., rdstbc=.false., rdvaif=.false.,  &
       rdwtd=.false., restrt, svbc, solve, thru=.FALSE.
  LOGICAL :: autots, chkptd, cntmaph, cntmapc, crosd, cylind, eeunit, gausel, heat, milu,  &
       savldo, &
       scalmf, solute, tsfail, vecmap
  LOGICAL :: prslm=.false., prkd=.false., prp=.false., prc=.false., prcphrq=.false., &
       prf_chem_phrq=.false., prvel=.false., prgfb=.false., prbcf=.false., prwel=.false.,  &
       prhdfh=.false., prhdfv=.false., prhdfc=.false., prmapc=.false., prmaph=.false., &
       prmapv=.false., prtem=.false., prcpd=.false.
  INTEGER :: prcphrqi, prf_chem_phrqi, prslmi, prhdfci, prhdfhi, prhdfvi
  INTEGER :: ntprbcf, ntprcpd, ntprhdfv, ntprhdfh, ntprgfb, ntprkd, ntprmapcomp,   &
       ntprmaphead, ntprmapv, ntprp,  &
       ntprc, ntprvel, ntprwel, ntprtem
  LOGICAL :: steady_flow, converge_ss
  REAL(KIND=kdp) :: timchg, timrst, rebalance_fraction_f = 0.5_kdp
  REAL(KIND=kdp) :: dptas=0.0_kdp, dtimmn=0.0_kdp, dtimmx=0.0_kdp, dtimu=0.0_kdp, dttas=0.0_kdp, &
       eps = 1.e-5_kdp, epsfs, timprt, &
       tolden, toldnc, toldnt
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
  INTEGER :: npmz, nx, nxy, nxyz, ny, nz, nxyzh
  LOGICAL :: tilt,unigrx,unigry,unigrz
  REAL(KIND=kdp) :: thetxz, thetyz, thetzz
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
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: KTHX, KTHY, KTHZ,  &
       kx, ky, kz,  &
       KXX, KYY, KZZ, RCPPM, TFX, TFY, TFZ, THX, THXY, THXZ, THY, THYX, THYZ, THZ, THZX, THZY, &
       TSX, TSXY, TSXZ, TSY, TSYX, TSYZ, TSZ, TSZX, TSZY
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
  INTEGER, DIMENSION(6,6) :: mar = reshape((/10,5,4,3,2,1, 15,10,8,7,6,2, 16,12,10,9,7,3,  &
           17,13,11,10,8,4, 18,14,13,12,10,5, 19,18,17,16,15,10/), (/6,6/))
  INTEGER, DIMENSION(19,19) :: mar1
  INTEGER ::  idir, maxit1, maxit2, nbn, nrn, nohst, nd4n, nprist, &
       nral, nsdr, nstslv, nstsor, ntsopt
  REAL(KIND=kdp) :: epsomg, epsslv
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: diagc, diagr
  ! ... LRCGD1=37 and LRCGD2=18 if LU fill-in is desired,
  ! ...      otherwise LRCGD1=19 and LRCGD2=10 for no fill-in
  INTEGER, PARAMETER :: lsdr=5, lrcgd1=19, lrcgd2=10
  LOGICAL :: col_scale=.false., row_scale=.true.
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
  INTEGER, DIMENSION(:), ALLOCATABLE :: ICMAX, JCMAX, KCMAX, icsbc, icflx, iclbc, icrbc
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: indx_sol1_ic, indx_sol2_ic, indx_sol1_bc, indx_sol2_bc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: axsav, aysav, azsav, dzfsdt, dp, dt, &
       sxx, syy, szz, vxx, vyy, vzz,  &
       vx_node, vy_node, vz_node,  &
       dcmax, dsir, dsir_chem, ssres, ssresf, stotsi, stotsp, stsaif, &
       stsetb, stsfbc, stslbc, stsrbc, stssbc, stswel, tsres, tsresf, zfs
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: qsfx, qsfy, qsfz
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE, TARGET :: dc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  den, eh, frac, zfsn, frac_icchem,  &
       p, t, vis, sir, sir0, sirn, sir_prechem,  &
       totsi, totsp, tdsir_chem, tcsaif, tcsetb, tcsfbc, tcslbc, tcsrbc, tcssbc
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE ::  c, ic_mxfrac, bc_mxfrac
  INTEGER :: ipmax, itmax, jpmax, jtmax, kpmax, ktmax, is
  INTEGER :: itime, nmapr, nrsttp, ns=0
  REAL(KIND=kdp) :: DDNMAX, DEHIR, DFIR, dhmax, DPMAX, DTMAX,  &
       SFRES, SFRESF, SHRES, SHRESF, STFAIF,  &
       STFETB, STFFBC, STFLBC, STFRBC, STFSBC, STFWEL, STHAIF, STHETB, STHFBC, STHHCB, STHLBC, &
       STHRBC, STHSBC, STHWEL, STOTFI, STOTFP, STOTHI, STOTHP, TFRES, TFRESF, THRES, THRESF
  REAL(KIND=kdp) :: deltim, deltim_sav, deltim_transient, ehir, ehir0, ehirn, fir, fir0, firn,  &
       firv0, firv, time, &
       totfi, &
       totfp, tothi, tothp, tcfaif, tcfetb, tcffbc, tcflbc, tcfrbc, tcfsbc, tchaif, tchetb, &
       tchfbc, tchhcb, tchlbc, tchrbc, tchsbc
  REAL(KIND=kdp), DIMENSION(:), POINTER :: dcv, qsfxis, qsfyis, qsfzis
END MODULE mcv

MODULE mcw
! ... well information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: INDX1_WEL, INDX2_WEL, IW, JW, LCBW, LCTW, NKSWEL, &
       WELIDNO, WQMETH
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: MWEL
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: DPWKT, TFW, QHW, QWM, RHSW, &
       STFWI, STHWI, STFWP, STHWP, UDENW, TQWSI, TQWSP , U10
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: QFLYR, QHLYR, QSW, QWLYR, STSWI, STSWP, VAW
  REAL(KIND=kdp), DIMENSION(:,:,:), ALLOCATABLE :: QSLYR
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: DTHAWR, EHWKT, EHWSUR, HTCWR, KTHAWR, KTHWR, &
       MXF_WEL, PWKT, PWKTS, PWSUR, PWSURS, QWV, TABWR, TATWR, TWKT, TWSRKT, TWSUR, WBOD, &
       WFRAC, WFICUM, WFPCUM, WHICUM, WHPCUM, WRANGL, WRID, WRISL, WRRUF, XW, YW, ZWB, ZWT, &
       dwb, dwt, TOTWSI, TOTWSP
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: CWKT, CWKTS, DENWK, DQWDPL, EHWK, &
       PWK, TWK, WI, WSICUM, WSPCUM, WSF
  REAL(KIND=kdp), DIMENSION(:,:,:), ALLOCATABLE :: CWK
  INTEGER :: ISIGN, NSHUT
  INTEGER, PARAMETER :: MAXORD = 6, MAXPTS = 10, METH = 1
  INTEGER ::  MXITQW, NWEL
  LOGICAL :: CWATCH, WRCALC
  REAL(KIND=kdp) :: B0, B1, B2, C00, DENGL, DNTEST, EHWEND, GCOSTH, P00, PWREND, QHFAC, T00, &
       TQWFI, TQWFP, TQWHI, TQWHP, TWREND, WRIDT
  REAL(KIND=kdp) :: DAMWRC, DENWKT, DENWRK, DTADZW, DZMIN, EH00, EOD, EPSWR, QWR, TAMBI, TOLDPW, &
       TOLFPW, TOLQW, TOTWFI, TOTWFP, TOTWHI, TOTWHP
END MODULE mcw

MODULE mg2
! ... read group 2 global parameters
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: uxx, uklb, uzelb
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: wcfl, wcfu
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: hdprnt, delz, arxbc, arybc, arzbc, hwt, &
       qfbcv, uvka
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
