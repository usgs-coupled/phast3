! ... Module files used for phast for definition of data groups
! ... These modules are used by both manager and worker programs
! ... $Id: modules_g.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp $
MODULE f_units
  ! ... fortran unit assignments
  IMPLICIT NONE
  SAVE
  INTEGER, PARAMETER :: fuins=15, fulp=16, fuplt=7, fuorst=8, fuirst=9, fuinc=10, furde=11, &
       fupmap=13, fuvmap=14, fup=21, fut=29, fuc=22, fuvel=23, fud=30, fuvs=31, fuwel=24, &
       fubal=25, fukd=26, fubcf=27, fuclog=28, fubnfr=32, fupmp2=33, fupzon=34, fuich=35,  &
       fuzf=36, fuzf_tsv=37, fuwt=38, fupmp3=39, fuzf_heads=40, fuzf_chem_xyzt = 41, &
       fuzf_chem_raw = 42
  LOGICAL :: print_rde=.FALSE.
END MODULE f_units

MODULE mcb
  ! ... boundary condition information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  TYPE :: rbc_indices
     INTEGER :: m, seg_first, seg_last
  END TYPE rbc_indices
  INTEGER, DIMENSION(:), ALLOCATABLE :: ibc,  &
       maifc, mdbc, metbc, mfbc, mfsbc, mhcbc, mlbc, mrbc, msbc,  &
       mdbc_bot, mdseg_bot,  &
       mrbc_bot, mrbc_top, mrseg_bot,  &
       ifacefbc, ifacelbc
  CHARACTER(LEN=9), DIMENSION(:), ALLOCATABLE :: char_ibc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: fracnp
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: psbc, psbc_n, tsbc,  &
       areafbc, denfbc, tflx, qfflx, qfflx_n, &
       arealbc, albc, bblbc, blbc, denlbc, klbc, philbc, philbc_n, tlbc, vislbc, zelbc,  &
       arearbc, arbc, bbrbc, brbc, denrbc, krbc, phirbc, phirbc_n, trbc, visrbc, zerbc,  &
        areadbc, adbc, bbdbc, bdbc, kdbc, zedbc
  INTEGER :: iaif,  &
       nsbc=0, nsbc_cells=0, nsbc_seg=0,  &
       nfbc=0, nfbc_cells=0, nfbc_seg=0,  &
       nlbc=0, nlbc_cells=0, nlbc_seg=0,  &
       nrbc=0, nrbc_cells=0, nrbc_seg=0,  &
       ndbc=0, ndbc_cells=0, ndbc_seg=0,  &
       netbc=0, naifc=0,  &
       nhcbc=0, nhcn=0, nztphc=0, num_bndy_cells=0
  LOGICAL :: fresur
  INTEGER :: adj_wr_ratio
  REAL(KIND=kdp) :: visdbc
  INTEGER, DIMENSION(:), ALLOCATABLE :: flux_seg_m, flux_seg_first,  &
       flux_seg_last, leak_seg_m, leak_seg_first, leak_seg_last,  &
       river_seg_m, river_seg_first, river_seg_last,  &
       drain_seg_m, drain_seg_first, drain_seg_last
  LOGICAL, DIMENSION(:), ALLOCATABLE :: print_dry_col
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
       qfsbc, qhsbc, qffbc, qfbcv, qhfbc, qflbc, qhlbc, &
       qfrbc, qhrbc,  &
       qfdbc, qhdbc,  &
       qfetbc, qhetbc, qfaif, qhaif
END MODULE mcb

MODULE mcc
  ! ... program control information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: iprint_chem, iprint_xyz
  INTEGER, DIMENSION(:), ALLOCATABLE :: lprnt1, lprnt2, lprnt3, lprnt4
  LOGICAL, DIMENSION(200) :: ierr = .FALSE.
  INTEGER :: ieq, itnoc, itnop, itnot, itrn, jtime
  INTEGER :: iprptc, ltcom, maxitn, ntsfal, orenpr, &
       slmeth, tmunit
  LOGICAL :: argrid, comopt, errexe, errexi,  &
       rdaif=.FALSE., rdcalc, rdetbc=.FALSE., rdflxh=.FALSE., rdflxq=.FALSE.,  &
       rdflxs=.FALSE., rdlbc=.FALSE., &
       rdrbc=.FALSE., rdscbc=.FALSE., rdspbc=.FALSE., rdstbc=.FALSE., rdvaif=.FALSE.,  &
       rdwtd=.FALSE., restrt, svbc, solve, thru=.FALSE.
  LOGICAL :: autots, crosd, cylind, eeunit, gausel=.FALSE., heat, milu,  &
       scalmf, solute, tsfail
  LOGICAL :: oldstyle_head_file=.FALSE.
  LOGICAL :: steady_flow, converge_ss, use_callback=.true.
  REAL(KIND=kdp) :: timchg=0.0_kdp, timrst, rebalance_fraction_f = 0.5_kdp
  INTEGER :: rebalance_method_f
  REAL(KIND=kdp) :: dptas=0.0_kdp, dtimmn=0.0_kdp, dtimmx=0.0_kdp, dtimu=0.0_kdp, dttas=0.0_kdp, &
       eps = 1.e-5_kdp, epsfs,  &
       tolden, toldnc, toldnt
  INTEGER :: prcphrqi, prf_chem_phrqi, prslmi, prhdfci, prhdfhi, prhdfvi, prhdfii
  INTEGER :: mpi_tasks=1
  INTEGER :: mpi_myself=0
  INTEGER :: ipp_phrq_id=-1, rm_id=-1, ipp_temp_id=-1, ipp_phast_id=-1
END MODULE mcc

MODULE mcch
  ! ... character strings for output
  IMPLICIT NONE
  SAVE
  CHARACTER(LEN=11), DIMENSION(:), ALLOCATABLE :: caprnt
  CHARACTER(LEN=130) :: dash = '------------------------------------------------------------&
       &----------------------------------------------------------------------', &
       dots = '........................................................................&
       &..........................................................'
  CHARACTER(LEN=1) :: rxlbl, unitt
  CHARACTER(LEN=6) :: mflbl
  CHARACTER(LEN=3) :: unittm
  CHARACTER(LEN=8) :: utulbl
  CHARACTER(LEN=255) :: f1name, f2name, f3name
  CHARACTER(LEN=255), DIMENSION(:), ALLOCATABLE :: restart_files
  INTEGER :: num_restart_files
  CHARACTER(LEN=8) :: version_name="Parallel transport"
  CHARACTER(LEN=30), DIMENSION(:), ALLOCATABLE :: comp_name
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
  INTEGER, DIMENSION(:), ALLOCATABLE :: grid2chem
  !
CONTAINS
  FUNCTION cellno(i,j,k) 
    IMPLICIT NONE
    INTEGER :: cellno
    INTEGER, INTENT(in) :: i,j,k
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
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: rf
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
       xele, yele, zele, x_face, y_face, z_face, pv0, volume, por
END MODULE mcn

MODULE mcp
  ! ... parameter information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  &
       rcppm, tfx, tfy, tfz,  &
       tsx, tsxy, tsxz, tsy, tsyx, tsyz, tsz, tszx, tszy
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: abpm, alphl, alphth, alphtv, tort, &
       pmchv, pmcv, pmhv,  &
       pv, pvk, &
       poros, ss, tx, ty, tz
  REAL(KIND=kdp) :: denf0, denf1
  REAL(KIND=kdp) :: bp, bt, cnvtm, cnvcn, cnvd, cnvdf, cnvhc, cnvhe, cnvhf, cnvhtc, cnvff, &
       cnvl, cnvl2, cnvl3, cnvm, cnvme, cnvmf, cnvp, cnvsf, cnvthc, cnvvf, cnvvl, cnvvs, &
       cnvt1, cnvt2, cnvtmi, cnvcni, cnvdi, cnvdfi, cnvhci, cnvhei, cnvhfi, cnvhti, cnvffi, &
       cnvli, cnvl2i, cnvl3i, cnvmi, cnvmei, cnvmfi, cnvpi, cnvsfi, cnvtci, cnvvfi, cnvvli, &
       cnvvsi, cnvt1i, cnvt2i, cpf, declam, den0, denc, denp, dent, dm, eh0, fdsmth, fdtmth, &
       gx, gy, gz, kthf, p0, p0h, paatm, t0, t0h, visfac, vis0, w0, w1
  REAL(KIND=kdp) :: fdtmth_tr=0.0_kdp
  REAL(KIND=kdp), PARAMETER :: epssat = 1.e-6_kdp  
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
  INTEGER :: nthreads, max_transporters=1000
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

MODULE mcv
  ! ... dependent variable information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: axsav, aysav, azsav, dzfsdt, dp, dt, &
       sxx, syy, szz, vxx, vyy, vzz,  &
       zfs
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  eh, frac, sat, zfsn, frac_icchem,  &
       p, t
  INTEGER :: itime=0
  REAL(KIND=kdp) :: deltim, deltim_sav, deltim_transient, time, time_phreeqc
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: c, ic_mxfrac 
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: indx_sol1_ic, indx_sol2_ic
  INTEGER :: ns=0
  INTEGER, DIMENSION(:), ALLOCATABLE :: component_map, local_component_map
  INTEGER :: local_ns=0
  LOGICAL :: xp_group=.false.

END MODULE mcv

MODULE mcw
  ! ... well information
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  INTEGER, DIMENSION(:), ALLOCATABLE :: iw, jw, lcbw, lctw, nkswel, &
       welidno, wqmeth
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: mwel
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: dpwkt, tfw, qhw, qwm, qwm_n, rhsw, &
       udenw
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: qflyr, qflyr_n, qhlyr, qwlyr, vaw
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: dthawr, ehwkt, ehwsur, htcwr, kthawr, kthwr, &
       pwkt, pwkts, pwsur, pwsurs, qwv, qwv_n, tabwr, tatwr, twkt, twsrkt, twsur, wbod, &
       wfrac, wrangl, wrid, wrisl, wrruf, xw, yw, zwb, zwt, &
       dwb, dwt
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: denwk, dqwdpl, ehwk, &
       pwk, twk, wi, wsf
  INTEGER :: isign, nshut
  INTEGER, PARAMETER :: maxord=6, maxpts=10, meth=1
  INTEGER ::  mxitqw, nwel
  LOGICAL :: cwatch, wrcalc
  REAL(KIND=kdp) :: b0, b1, b2, c00, dengl, dntest, ehwend, gcosth, p00, pwrend, qhfac, t00, &
       twrend, wridt
  REAL(KIND=kdp) :: damwrc, denwkt, denwrk, dtadzw, dzmin, eh00, eod, epswr, qwr, tambi, toldpw, &
       tolfpw, tolqw
END MODULE mcw

MODULE phys_const
  ! ... physical and mathematical constants
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  SAVE
  REAL(KIND=kdp), PARAMETER :: pi = 3.1415926535898_kdp, grav = 9.80665_kdp, twopi = 2._kdp*pi
END MODULE phys_const

