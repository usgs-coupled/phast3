SUBROUTINE init2_1
  ! ... initialize after read2
  ! ... initialization block 1 before chemical reactions
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcb2_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcm
  USE mcm_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcs
  USE mcs2
  USE mct_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m
  USE phys_const
  USE reorder_mod
  IMPLICIT NONE
  INCLUDE "RM_interface_F.f90.inc"
  INTEGER :: status
  !
  INTRINSIC index
  INTERFACE
     FUNCTION nintrp(xarg,nx,xs,erflg)
       USE machine_constants, ONLY: kdp
       REAL(KIND=kdp), INTENT(IN) :: xarg
       INTEGER, INTENT(IN) :: nx
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: xs
       LOGICAL, INTENT(INOUT) :: erflg
       INTEGER :: nintrp
     END FUNCTION nintrp
  END INTERFACE
  TYPE :: cell_subdom
     INTEGER :: num_sd
     LOGICAL, DIMENSION(8) :: sd_active
  END TYPE cell_subdom
  CHARACTER(LEN=9) :: cibc
  CHARACTER(LEN=130) :: logline1
  REAL(KIND=kdp) :: keffl, keffu, up0, rorw2, &
       uarz, uc, uden, udx, udxdy, udxdyi,  &
       udxdyo, udxdz, udxyz, udxyzi, udxyzo, udy, udydz, udz, ugdelx,  &
       ugdely, ugdelz, upabd, ut, uwi, x0, y0, z0, &
       zfsl, zm1, zp1
  INTEGER :: a_err, da_err, i, ic, icol, imm, imod, ipmz, iwel, j, jcol,  &
       k, k1, k2, kcol, kf, &
       kinc, kl, ks, kw, l, lc, ls, m, mb, m1, m2, &
       mk, mr, ms, msv, mt, nele, nks, nr, nsa
  INTEGER :: ibf, icz, isd, izn, lbc, mks, msd, nbc, nbf, t_findx
  INTEGER, DIMENSION(8) :: iisd=(/7,8,5,6,3,4,1,2/)
  INTEGER, DIMENSION(6) :: num_indx
  INTEGER, DIMENSION(8) :: face_x, face_y, face_z, mm
  LOGICAL :: erflg, no_ex
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: uarxbc, uarybc, uarzbc
  TYPE(cell_subdom), DIMENSION(:), ALLOCATABLE :: cell_sd
  LOGICAL :: all_dry, some_dry
  !     ------------------------------------------------------------------

  nr=nx
  nsa = MAX(ns,1)
  ! ... convert the data to s.i. time units if necessary
  ! ...      even if an error abort is set
  IF(tmunit > 1) CALL etom1  
  thetxz = 90._kdp  
  thetyz = 90._kdp  
  thetzz = 0._kdp  
  IF(cylind) THEN  
     ! ...    case of cylindrical grid - single well exclusive of
     ! ...       observation wells
     ! ...      heterogeneous in z only
     y(1) = 0._kdp  
     DO  i=1,nr-1  
        rm(i) = (x(i+1) - x(i))/LOG(x(i+1)/x(i))  
     END DO
  ENDIF
  ! ... calculate gx,gy,gz
  IF(tilt) THEN  
     gx = grav*COS(thetxz*twopi/ 360.)  
     gy = grav*COS(thetyz*twopi/ 360.)  
     gz = grav*COS(thetzz*twopi/ 360.)  
  ELSE  
     gx = 0._kdp  
     gy = 0._kdp  
     gz = grav  
  ENDIF
  ! ... Build the mask for cross dispersion calculation
  ! ...     identifying inactive neighbor nodes: mcg
  ALLOCATE (xd_mask(0:nx+1,0:ny+1,0:nz+1),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: init2.1, number 1"  
     STOP
  ENDIF
  ! ... Flag the active cells for cross-dispersion calculations
  xd_mask = .FALSE.
  DO  ipmz=1,npmz
     DO  k=k1z(ipmz),k2z(ipmz)
        DO  j=j1z(ipmz),j2z(ipmz)
           DO  i=i1z(ipmz),i2z(ipmz)
              xd_mask(i,j,k) = .TRUE.
           END DO
        END DO
     END DO
  END DO
  ! ... Identify excluded (inactive) cells from zone definitions
  DO  m=1,nxyz
     CALL mtoijk(m,i,j,k,nx,ny)
     IF(.NOT.xd_mask(i,j,k)) THEN
        ibc(m) = -1
        IF(ibc_string(m)(9:9) /= 'X') THEN
           cibc = ibc_string(m)(2:9)//'X'
           ibc_string(m) = cibc
        END IF
     END IF
  END DO
  IF(errexi) RETURN
!!$  ! ... load the element centroid arrays
!!$  DO ipmz=1,npmz
!!$     xele(ipmz) = 0.5_kdp*(x(i1z(ipmz))+x(i2z(ipmz)))
!!$     yele(ipmz) = 0.5_kdp*(y(j1z(ipmz))+y(j2z(ipmz)))
!!$     zele(ipmz) = 0.5_kdp*(z(k1z(ipmz))+z(k2z(ipmz)))
!!$  END DO
  t = 0._kdp
  IF(paatm <= 0._kdp) paatm = 1.01325e5_kdp
  ! ...  aquifer fluid density and viscosity at p0,t0,w0
  den0 = denf0  
  denp = 0._kdp  
  dent = 0._kdp  
  denc = 0._kdp  
  vis0 = abs(visfac)
  ! ... Allocate geometry information: mcg 
  ALLOCATE (arx(nxyz), ary(nxyz), arz(nxyz), grid2chem(nxyz), &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: init2.1, number 2"
     STOP
  ENDIF
  ! ... Allocate parameter arrays: mcp
  ! ...      conductance, capacitance arrays
  ALLOCATE (tx(nxyz), ty(nxyz), tz(nxyz), tfx(nxyz), tfy(nxyz), tfz(nxyz),  &
       tsx(nxyz), tsy(nxyz), tsz(nxyz), tsxy(nxyz), tsxz(nxyz), tsyx(nxyz), tsyz(nxyz),  &
       tszx(nxyz), tszy(nxyz),  &
       pv(nxyz), pmcv(nxyz), pmhv(1), pmchv(1), pvk(1),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: init2.1, number 3"
     STOP
  ENDIF
  tfx = 0._kdp
  tfy = 0._kdp
  tfz = 0._kdp
  ! ... Allocate geometry information: mg2_m and local
  ALLOCATE (arxbc(nxyz), arybc(nxyz), arzbc(nxyz),  &
       delz(nz),  &
       cell_sd(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: init2.1, number 4"
     STOP
  ENDIF
  ! ... calculate conductance zone by zone
  ! ...      zero the extensive interfacial property arrays
  tx = 0._kdp  
  ty = 0._kdp  
  tz = 0._kdp  
  ! ...      these are void space areas,i.e. area*porosity
  arx = 0._kdp  
  ary = 0._kdp  
  arz = 0._kdp  
  ! ...      these are total facial areas
  arxbc = 0._kdp  
  arybc = 0._kdp  
  arzbc = 0._kdp  
!!$  cell_sd%num_sd = 0     ! ...      The subdomain counter
!!$  cell_sd%sd_active = .FALSE.    ! ... init subdomain flags to inactive
  cell_sd = cell_subdom(0,(/.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE.,.FALSE./))
  ! ...      zero the extensive volumetric arrays
  pv = 0._kdp  
  pmcv = 0._kdp  
  pmhv = 0._kdp
  pmchv = 0._kdp
  pvk = 0._kdp
  ss = 0._kdp
  DO 210 ipmz=1,npmz  
     ! ... facial area properties
     IF(.NOT.cylind) THEN  
        DO 170 k = k1z(ipmz),k2z(ipmz)-1  
           udz = z(k + 1) - z(k)  
           delz(k) = udz  
           DO 160 j = j1z(ipmz),j2z(ipmz)-1
              udy = y(j + 1) - y(j)  
              udydz = udy*udz*.25
              DO 150 i = i1z(ipmz),i2z(ipmz)-1  
                 udx = x(i + 1) - x(i)  
                 udxdz = udx*udz*.25  
                 udxdy = udx*udy*.25  
                 ! ... x-direction conductance factors
                 mm(1) = cellno(i,j,k)  
                 mm(2) = cellno(i,j+1,k)  
                 mm(3) = mm(2) + nxy  
                 mm(4) = mm(1) + nxy  
                 DO 110 imm=1,4
                    m = mm(imm)  
                    tx(m) = tx(m) + kxx(ipmz)*udydz/udx  
                    arx(m) = arx(m) + udydz*poros(ipmz)  
                    arxbc(m) = arxbc(m) + udydz  
110              END DO
                 ! ... y-direction conductance factors
                 mm(2) = mm(1) + 1  
                 mm(3) = mm(2) + nxy  
                 mm(4) = mm(1) + nxy  
                 DO 120 imm=1,4
                    m = mm(imm)  
                    ty(m) = ty(m) + kyy(ipmz)*udxdz/udy  
                    ary(m) = ary(m) + udxdz*poros(ipmz)  
                    arybc(m) = arybc(m) + udxdz
120              END DO
                 ! ... z-direction conductance factors
                 mm(2) = mm(1) + 1  
                 mm(3) = mm(2) + nx  
                 mm(4) = mm(1) + nx  
                 DO 130 imm=1,4  
                    m = mm(imm)  
                    tz(m) = tz(m) + kzz(ipmz)*udxdy/udz  
                    arz(m) = arz(m) + udxdy*poros(ipmz)  
                    arzbc(m) = arzbc(m) + udxdy  
130              END DO
                 ! ... extensive volume properties
                 mm(5) = mm(1) + nxy  
                 mm(6) = mm(2) + nxy  
                 mm(7) = mm(3) + nxy  
                 mm(8) = mm(4) + nxy  
                 udxyz = .5*udxdy*(z(k + 1) - z(k))  
                 DO 140 imm=1,8  
                    m = mm(imm)  
                    pv(m) = pv(m) + poros(ipmz)*udxyz  
                    upabd = abpm(ipmz)*udxyz  
                    pmcv(m) = pmcv(m) + upabd  
!!$                    if(solute) pvk(m)=pvk(m)+dbkd(ipmz)*udxyz
!!$                    IF(heat) THEN  
!!$                       pmhv(m) = pmhv(m) + (1._kdp - poros(ipmz))*rcppm(ipmz)*udxyz
!!$                       pmchv(m) = pmchv(m) + upabd*rcppm(ipmz)  
!!$                    ENDIF
                    isd = iisd(imm)
                    cell_sd(m)%sd_active(isd) = .TRUE.
                    cell_sd(m)%num_sd = cell_sd(m)%num_sd+1
140              END DO
150           END DO
160        END DO
170     END DO
     ELSE               ! ... cylindrical case
        DO 200 k = k1z(ipmz),k2z(ipmz)-1  
           udz = z(k + 1) - z(k)  
           DO 190 i = i1z(ipmz), i2z(ipmz) - 1  
              udx = x(i + 1) - x(i)  
              ! ... r-direction conductance factors
              udydz = pi*rm(i)*udz  
              mm(1) = cellno(i,1,k)  
              mm(2) = mm(1) + nxy  
              DO 180 imm=1,2
                 m = mm(imm)  
                 tx(m) = tx(m) + kxx(ipmz)*udydz/udx  
                 arx(m) = arx(m) + udydz*poros(ipmz)  
                 arxbc(m) = arxbc(m) + pi*x(i)*udz  
180           END DO
              ! ... z-direction conductance factors
              mm(2) = mm(1) + 1  
              udxdyi = pi*(rm(i)*rm(i) - x(i)*x(i))  
              udxdyo = pi*(x(i + 1)*x(i + 1) - rm(i)*rm(i))
              tz(mm(1)) = tz(mm(1)) + kzz(ipmz)*udxdyi/udz
              tz(mm(2)) = tz(mm(2)) + kzz(ipmz)*udxdyo/udz
              arz(mm(1)) = arz(mm(1)) + udxdyi*poros(ipmz)  
              arz(mm(2)) = arz(mm(2)) + udxdyo*poros(ipmz)  
              arzbc(mm(1)) = arzbc(mm(1)) + udxdyi  
              arzbc(mm(2)) = arzbc(mm(2)) + udxdyo  
              ! ... extensive volume properties
              mm(3) = mm(2) + nxy  
              mm(4) = mm(1) + nxy  
              udxyzi = udxdyi*.5*udz  
              udxyzo = udxdyo*.5*udz  
              pv(mm(1)) = pv(mm(1)) + poros(ipmz)*udxyzi  
              pv(mm(4)) = pv(mm(4)) + poros(ipmz)*udxyzi  
              pv(mm(2)) = pv(mm(2)) + poros(ipmz)*udxyzo  
              pv(mm(3)) = pv(mm(3)) + poros(ipmz)*udxyzo  
              pmcv(mm(1)) = pmcv(mm(1)) + abpm(ipmz)*udxyzi
              pmcv(mm(4)) = pmcv(mm(4)) + abpm(ipmz)*udxyzi
              pmcv(mm(2)) = pmcv(mm(2)) + abpm(ipmz)*udxyzo
              pmcv(mm(3)) = pmcv(mm(3)) + abpm(ipmz)*udxyzo
              ! ... calculate specific storage distribution
              ss(mm(1)) = den0*gz*(abpm(ipmz) + poros(ipmz)*bp)
              ss(mm(2)) = den0*gz*(abpm(ipmz) + poros(ipmz)*bp)
              ss(mm(3)) = den0*gz*(abpm(ipmz) + poros(ipmz)*bp)
              ss(mm(4)) = den0*gz*(abpm(ipmz) + poros(ipmz)*bp)
              !$$                  if(solute) then
              !$$                     pvk(mm(1))=pvk(mm(1))+dbkd(ipmz)*udxyzi
              !$$                     pvk(mm(4))=pvk(mm(4))+dbkd(ipmz)*udxyzi
              !$$                     pvk(mm(2))=pvk(mm(2))+dbkd(ipmz)*udxyzo
              !$$                     pvk(mm(3))=pvk(mm(3))+dbkd(ipmz)*udxyzo
              !$$                  endif
              cell_sd(mm(1))%num_sd = cell_sd(mm(1))%num_sd+1
              cell_sd(mm(2))%num_sd = cell_sd(mm(2))%num_sd+1
              cell_sd(mm(3))%num_sd = cell_sd(mm(3))%num_sd+1
              cell_sd(mm(4))%num_sd = cell_sd(mm(4))%num_sd+1
190        END DO
200     END DO
     ENDIF
210 END DO
  pv0 = pv          ! ... save the initial pore volumes
  ! ... determine size needed for boundary cell array
  nbc = 0
  lprnt2 = 0
  DO  m=1,nxyz
     IF(cell_sd(m)%num_sd == 0) THEN        ! ... an exterior cell
        CYCLE
     ELSEIF(cell_sd(m)%num_sd < 8) THEN     ! ... a boundary cell
        nbc = nbc + 1
        lprnt2(nbc) = m      ! ... scratch storage
     END IF
  END DO
  ! ... allocate space for boundary cell structure: mcb_m and local
  ALLOCATE (b_cell(nbc),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: init2.1, number 5"  
     STOP
  ENDIF
  ALLOCATE (uarxbc(nxyz), uarybc(nxyz), uarzbc(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: init2.1, number 6"  
     STOP  
  ENDIF
  ! ... load the boundary cell array structure; part 1, geometry
  num_bndy_cells = nbc
  DO l = 1,num_bndy_cells
     b_cell(l)%m_cell = lprnt2(l)
  END DO
  DO  l=1,num_bndy_cells
     m = b_cell(l)%m_cell
     face_x = 0
     face_y = 0
     face_z = 0
     num_indx = 0          ! array(1:6)
     b_cell(l)%face_indx = 0
     b_cell(l)%por_areabc = 0._kdp
     DO msd=1,8
        IF(.NOT.cell_sd(m)%sd_active(msd)) THEN
           ! ... local subdomain msd is outside the active region
           SELECT CASE (msd)
           CASE (1,4,5,8)
              face_x(msd) = 3
              num_indx(3) = num_indx(3)+1
           CASE (2,3,6,7)
              face_x(msd) = 4
              num_indx(4) = num_indx(4)+1
           END SELECT
           SELECT CASE (msd)
           CASE (1,2,5,6)
              face_y(msd) = 2
              num_indx(2) = num_indx(2)+1
           CASE (3,4,7,8)
              face_y(msd) = 5
              num_indx(5) = num_indx(5)+1
           END SELECT
           SELECT CASE (msd)
           CASE (1,2,3,4)
              face_z(msd) = 1
              num_indx(1) = num_indx(1)+1
           CASE (5,6,7,8)
              face_z(msd) = 6
              num_indx(6) = num_indx(6)+1
           END SELECT
        END IF
     END DO
     IF(num_indx(3) > num_indx(4)) b_cell(l)%face_indx(1) = 3
     IF(num_indx(3) < num_indx(4)) b_cell(l)%face_indx(1) = 4
     IF(num_indx(2) > num_indx(5)) b_cell(l)%face_indx(2) = 2
     IF(num_indx(2) < num_indx(5)) b_cell(l)%face_indx(2) = 5
     IF(num_indx(1) > num_indx(6)) b_cell(l)%face_indx(3) = 1
     IF(num_indx(1) < num_indx(6)) b_cell(l)%face_indx(3) = 6
     nbf = 0
     DO ibf=1,3
        IF(b_cell(l)%face_indx(ibf) > 0) nbf = nbf+1
     END DO
     b_cell(l)%num_faces = nbf
     ! ... move exterior faces to top of list
     DO
        no_ex = .TRUE.
        DO ibf = 1,2
           IF(b_cell(l)%face_indx(ibf) <  b_cell(l)%face_indx(ibf+1)) THEN
              t_findx = b_cell(l)%face_indx(ibf)
              b_cell(l)%face_indx(ibf) = b_cell(l)%face_indx(ibf+1)
              b_cell(l)%face_indx(ibf+1) = t_findx
              no_ex = .FALSE.
           END IF
        END DO
        IF(no_ex) EXIT
     END DO
  END DO
  ! ... Calculate exterior face areas for boundary cells
  ! ... The correct sign will be given on outward normal vector for the
  ! ...      boundary faces
  DO  lbc=1,num_bndy_cells
     m = b_cell(lbc)%m_cell
     CALL mtoijk(m,i,j,k,nx,ny)
     IF(i > 1) THEN
        uarxbc(m) = arxbc(m-1)-arxbc(m)
     ELSE
        uarxbc(m) = -arxbc(m)
     END IF
     IF(j > 1) THEN
        uarybc(m) = arybc(m-nx)-arybc(m)
     ELSE
        uarybc(m) = -arybc(m)
     END IF
     IF(k > 1) THEN
        uarzbc(m) = arzbc(m-nxy)-arzbc(m)
     ELSE
        uarzbc(m) = -arzbc(m)
     END IF
  END DO
  ! ... Calculate porosity*area for exterior faces of boundary cells
  DO  lbc=1,num_bndy_cells
     m = b_cell(lbc)%m_cell
     DO ibf=1,b_cell(lbc)%num_faces
        ic = b_cell(lbc)%face_indx(ibf)
        IF(fresur .AND. ic == 6) CYCLE
        IF(ic == 3) THEN
           b_cell(lbc)%por_areabc(ibf) = (arx(m)/arxbc(m))*ABS(uarxbc(m))
        ELSEIF(ic == 4) THEN
           b_cell(lbc)%por_areabc(ibf) = (arx(m-1)/arxbc(m-1))*ABS(uarxbc(m))
        ELSEIF(ic == 2) THEN
           b_cell(lbc)%por_areabc(ibf) = (ary(m)/arybc(m))*ABS(uarybc(m))
        ELSEIF(ic == 5) THEN
           b_cell(lbc)%por_areabc(ibf) = (ary(m-nx)/arybc(m-nx))*ABS(uarybc(m))
        ELSEIF(ic == 1) THEN
           b_cell(lbc)%por_areabc(ibf) = (arz(m)/arzbc(m))*ABS(uarzbc(m))
        ELSEIF(ic == 6) THEN
           b_cell(lbc)%por_areabc(ibf) = (arz(m-nxy)/arzbc(m-nxy))*ABS(uarzbc(m))
        END IF
     END DO
  END DO
  ! ... Load exterior face areas for boundary cells
  DO  lbc=1,num_bndy_cells
     m = b_cell(lbc)%m_cell
     DO ibf=1,b_cell(lbc)%num_faces
        ic = b_cell(lbc)%face_indx(ibf)
        IF(ic == 3 .OR. ic == 4) THEN
           arxbc(m) = uarxbc(m)
        ELSEIF(ic == 2 .OR. ic == 5) THEN
           arybc(m) = uarybc(m)
        ELSEIF(ic == 1 .OR. ic == 6) THEN
           arzbc(m) = uarzbc(m)
        END IF
     END DO
  END DO
  ! *** todo--make ar_bc part of b_cell structure 
  IF(nwel > 0) THEN
     ! ... Allocate more well arrays: mcw
     ALLOCATE (iw(nwel), jw(nwel), wi(nwel,nz),  &
          qwlyr(nwel,nz), qflyr(nwel,nz), qflyr_n(nwel,nz), dqwdpl(nwel,nz),  &
          denwk(nwel,nz), pwk(nwel,nz), cwk(nwel,nz,nsa), twk(1,1), udenw(nz),  &
          dpwkt(nwel), tfw(nz),  &
          qwm(nwel), qwm_n(nwel), qwv(nwel), qwv_n(nwel), qhw(1),  &
          rhsw(nz), vaw(7,nz),  &
          pwsurs(nwel), pwkt(nwel),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: init2.1, number 7"  
        STOP  
     ENDIF
     ! ... Allocate more well arrays: mcw_m
     ALLOCATE (indx1_wel(nwel), indx2_wel(nwel),  &
          wficum(nwel), wfpcum(nwel), wsicum(nwel,nsa), wspcum(nwel,nsa),  &
          qslyr(nwel,nz,nsa), qsw(nwel,nsa), qsw_n(nwel,nsa),  &
          stfwp(nwel), sthwp(1), stswp(nwel,nsa),  &
          stfwi(nwel), sthwi(1), stswi(nwel,nsa),  &
          cwkt(nwel,nsa), cwkts(nwel,nsa),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: init2.1, number 8"  
        STOP  
     ENDIF
     pwsurs = 0._kdp
     qflyr = 0._kdp
     qflyr_n = 0._kdp
     !     qfw = 0._kdp
     qslyr = 0._kdp
     qsw = 0._kdp
     qsw_n = 0._kdp
     qwm = 0._kdp
     qwm_n = 0._kdp
     qwv = 0._kdp
     qwv_n = 0._kdp
     cwkt = 0._kdp
     ! ... Check for well completion in inactive cells
     DO iwel=1,nwel
        DO ks=1,nkswel(iwel)
           mks = mwel(iwel,ks)
           IF(ibc(mks) == -1) THEN
              ierr(57) = .TRUE.
              errexi = .TRUE.
           END IF
        END DO
     END DO
     IF(errexi) RETURN
     ! ... Calculate the well indices, and location indices
     DO iwel=1,nwel  
        iw(iwel) = 1  
        jw(iwel) = 1  
        erflg = .FALSE.  
        IF(.NOT.cylind) THEN  
           iw(iwel) = nintrp(xw(iwel), nx, x, erflg)  
           jw(iwel) = nintrp(yw(iwel), ny, y, erflg)  
        ENDIF
        IF(wqmeth(iwel) > 0) THEN  
           nks = nkswel(iwel)
           mb = mwel(iwel,1)
           mt = mwel(iwel,nks)
           wfrac(iwel) = 1._kdp  
           IF(.NOT.cylind) THEN
              uarz = ABS(arzbc(mwel(iwel,1)))  
              ! ...      Geometric factor
              rorw2 = 4.*uarz/(pi*wbod(iwel)*wbod(iwel))  
              IF(rorw2 <= 1._kdp) ierr(57) = .TRUE.
              uwi = twopi*wfrac(iwel)*(rorw2-1._kdp)/(0.5* &
                   (rorw2*LOG(rorw2) - (rorw2-1._kdp)))
           ELSE
              uwi = 1._kdp  
           ENDIF
           DO kw=1,nks
              mk = mwel(iwel,kw)  
              CALL mtoijk(mk, i, j, k, nx, ny)  
              ! ...      Effective permeability for the well indices
              keffl = 0._kdp
              keffu = 0._kdp
              nele = 0
              DO ipmz=1,npmz
                 IF(i1z(ipmz) <= iw(iwel) .AND. iw(iwel) <= i2z(ipmz) .AND.  &
                      j1z(ipmz) <= jw(iwel) .AND. jw(iwel) <= j2z(ipmz) .AND.  &
                      k1z(ipmz) < k .AND. k <= k2z(ipmz)) THEN
                    nele = nele +1
                    IF(.NOT.cylind) THEN
                       keffl = keffl + SQRT(kxx(ipmz)*kyy(ipmz))
                    ELSEIF(cylind) THEN  
                       keffl = keffl + kxx(ipmz)
                    ENDIF
                 ENDIF
                 IF(i1z(ipmz) <= iw(iwel) .AND. iw(iwel) <= i2z(ipmz) .AND.  &
                      j1z(ipmz) <= jw(iwel) .AND. jw(iwel) <= j2z(ipmz) .AND.  &
                      k1z(ipmz) <= k .AND. k < k2z(ipmz)) THEN
                    nele = nele +1
                    IF(.NOT.cylind) THEN
                       keffu = keffu + SQRT(kxx(ipmz)*kyy(ipmz))
                    ELSEIF(cylind) THEN  
                       keffu = keffu + kxx(ipmz)
                    ENDIF
                 ENDIF
                 IF(nele == 8) EXIT
              END DO
              wcfl(iwel,kw) = 0.25_kdp*wcfl(iwel,kw)*keffl
              wcfu(iwel,kw) = 0.25_kdp*wcfu(iwel,kw)*keffu
              wi(iwel,kw) = (wcfl(iwel,kw) + wcfu(iwel,kw))*uwi  
              ! ... Store effective permeability in wcfl, wcfu
              wcfl(iwel,kw) = 0.25_kdp*keffl
              wcfu(iwel,kw) = 0.25_kdp*keffu
           END DO
        ENDIF
     END DO
  END IF
  ! ... Specified value b.c.
  IF(nsbc > 0) THEN  
     ! ... Allocate specified value b.c. arrays: mcb
     ALLOCATE (qfsbc(nsbc), qhsbc(1),  &
          fracnp(nsbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 9"  
        STOP
     ENDIF
     ! ... Allocate specified value b.c. arrays: mcb_m
     ALLOCATE (qssbc(nsbc,nsa),  &
          sfsb(nsbc), sfvsb(nsbc), sssb(nsbc,nsa),  &
          ccfsb(nsbc), ccfvsb(nsbc), ccssb(nsbc,nsa),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 10"  
        STOP
     ENDIF
     ! ... Allocate difference equations arrays: mcm
     ALLOCATE (vafsbc(7,nsbc), rhfsbc(nsbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 11"  
        STOP
     ENDIF
     ! ... Allocate difference equations arrays: mcm_m
     ALLOCATE (vassbc(7,nsbc,nsa), rhssbc(nsbc,nsa),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 12"  
        STOP
     ENDIF

     ccfsb = 0._kdp  
     ccfvsb = 0._kdp  
     !$$     cchsb = 0._kdp  
     ccssb = 0._kdp  
  ENDIF

  ! ... Specified flux b.c.
  IF(nfbc > 0) THEN
     ! ... Allocate specified flux b.c. arrays: mcb
     ALLOCATE (qffbc(nfbc), qfbcv(nfbc), qhfbc(1),  &
          flux_seg_m(nfbc), flux_seg_first(nfbc), flux_seg_last(nfbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 13, flux"  
        STOP
     ENDIF
     ! ... Allocate specified flux b.c. arrays: mcb_m
     ALLOCATE (qsfbc(nfbc,nsa),  &
          sffb(nfbc), sfvfb(nfbc), ssfb(nfbc,nsa),  &
          ccffb(nfbc), ccfvfb(nfbc), ccsfb(nfbc,nsa),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 14, flux"  
        STOP
     ENDIF
     ! ... load the flux index structure; first and last segments per flux cell
     lc = 1
     ms = mfbc(1)
     flux_seg_m(lc) = ms
     flux_seg_first(lc) = 1
     DO ls=2,nfbc_seg
        ! ... This loop expects all segments attached to a given cell to be contiguous
        IF(mfbc(ls) == ms) CYCLE
        flux_seg_last(lc) = ls - 1
        flux_seg_first(lc+1) = ls
        lc = lc + 1
        ms = mfbc(ls)
        flux_seg_m(lc) = ms
     END DO
     flux_seg_last(lc) = nfbc_seg
     ! ... Zero the arrays for flux b.c.
     qfflx = 0._kdp
     qfflx_n = 0._kdp
     qsflx = 0._kdp
     qsflx_n = 0._kdp
     qffbc = 0._kdp
     qfbcv = 0._kdp
     qsfbc = 0._kdp
     qhfbc = 0._kdp
     ccffb = 0._kdp
     ccfvfb = 0._kdp
     ccsfb = 0._kdp
     cfbc = 0._kdp
     cfbc_n = 0._kdp
  ENDIF

  ! ... Aquifer leakage
  IF(nlbc > 0) THEN  
     ! ... Allocate leakage b.c. arrays: mcb
     ALLOCATE (qflbc(nlbc),  & 
          leak_seg_m(nlbc), leak_seg_first(nlbc), leak_seg_last(nlbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 15, leak"  
        STOP
     ENDIF
     qflbc = 0
     ! ... Allocate leakage b.c. arrays: mcb_m
     ALLOCATE (qslbc(nlbc,nsa),  &
          sflb(nlbc), sfvlb(nlbc), sslb(nlbc,nsa),  &
          ccflb(nlbc), ccfvlb(nlbc),  ccslb(nlbc,nsa),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 16, leak"  
        STOP
     ENDIF

     ! ... Load the leakage index structure; first and last segments per leakage cell
     lc = 1
     ms = mlbc(1)
     leak_seg_m(lc) = ms
     leak_seg_first(lc) = 1
     DO ls=2,nlbc_seg
        ! ... This loop expects all segments attached to a given cell to be contiguous
        IF(mlbc(ls) == ms) CYCLE
        leak_seg_last(lc) = ls - 1
        leak_seg_first(lc+1) = ls
        lc = lc + 1
        ms = mlbc(ls)
        leak_seg_m(lc) = ms
     END DO
     leak_seg_last(lc) = nlbc_seg
     DO ls=1,nlbc_seg
        klbc(ls) = klbc(ls)*arealbc(ls)/bblbc(ls)    ! ... include area and thickness into leakance 
     END DO
     ! ... Zero the arrays for aquifer leakage
     albc = 0._kdp
     qflbc = 0._kdp
     qslbc = 0._kdp
     ccflb = 0._kdp
     ccfvlb = 0._kdp
     ccslb = 0._kdp
     philbc = 0._kdp
     philbc_n = 0._kdp
     clbc = 0._kdp
     clbc_n = 0._kdp
  ENDIF

  ! ... River leakage
  IF(nrbc > 0) THEN  
     ! ... Allocate river leakage b.c. arrays: mcb
     ALLOCATE (qfrbc(nrbc), &
          river_seg_m(nrbc), river_seg_first(nrbc), river_seg_last(nrbc),  &
          mrbc_bot(nrbc), mrbc_top(nrbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 17, river"  
        STOP
     ENDIF

     ! ... Allocate river leakage b.c. arrays: mcb_m
     ALLOCATE (qsrbc(nrbc,nsa),  &
          sfrb(nrbc), sfvrb(nrbc), ssrb(nrbc,nsa),  &
          ccfrb(nrbc), ccfvrb(nrbc), ccsrb(nrbc,nsa),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 18, river"  
        STOP
     ENDIF
     ! ... Load the river index structure; first and last segments per river cell
     lc = 1
     ms = mrbc(1)
     mrbc_top(lc) = ms
     river_seg_m(lc) = ms
     river_seg_first(lc) = 1
     DO ls=2,nrbc_seg
        ! ... This loop expects all segments attached to a given cell to be contiguous
        IF(mrbc(ls) == ms) CYCLE
        river_seg_last(lc) = ls - 1
        river_seg_first(lc+1) = ls
        lc = lc + 1
        ms = mrbc(ls)
        mrbc_top(lc) = ms
     END DO
     river_seg_last(lc) = nrbc_seg
     ! ... Load the river cell and segment connections
     DO lc=1,nrbc_cells
        mrbc_bot(lc) = nxyz+1
        DO ls=river_seg_first(lc),river_seg_last(lc)
           krbc(ls) = krbc(ls)*arearbc(ls)    ! ... include area into leakance 
           ! ... connect the river segment to the cell containing river bottom
           erflg = .FALSE.  
           ks = nintrp(zerbc(ls) - bbrbc(ls), nz, z, erflg)  
           IF (erflg) THEN     ! ... out of range of mesh, use top or bottom cell
              IF ((zerbc(ls) - bbrbc(ls)) > z(nz)) THEN
                 ks = nz
              ELSE
                 ks = 1
              ENDIF
           ENDIF
           m = mrbc(ls)
           mr = m - (nz - ks)*nxy
           mrbc(ls) = mr
           mrseg_bot(ls) = mr            ! ... static index for river segment bottom
           ! ... ibc for river is always at the top of the mesh region
           mrbc_bot(lc) = MIN(mrbc_bot(lc),mr)     ! ... set to lowest river seg bottom
        END DO
        river_seg_m(lc) = mrbc_bot(lc)
     END DO
     ! ... Zero the arrays for river leakage
     arbc = 0._kdp
     qfrbc = 0._kdp  
     qsrbc = 0._kdp  
     ccfrb = 0._kdp  
     ccfvrb = 0._kdp  
     ccsrb = 0._kdp  
     phirbc = 0._kdp
     phirbc_n = 0._kdp
     crbc = 0._kdp
     crbc_n = 0._kdp
  ENDIF

  ! ... Drain leakage
  IF(ndbc > 0) THEN  
     ! ... Allocate drain b.c. arrays: mcb
     ALLOCATE (qfdbc(ndbc),  &
          drain_seg_m(ndbc), drain_seg_first(ndbc), drain_seg_last(ndbc),  &
          mdbc_bot(ndbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 19, drain"  
        STOP
     ENDIF
     ! ... Allocate drain b.c. arrays: mcb_m
     ALLOCATE (qsdbc(ndbc,nsa),  &
          sfdb(ndbc), sfvdb(ndbc), ssdb(ndbc,nsa),  &
          ccfdb(ndbc), ccfvdb(ndbc),  ccsdb(ndbc,nsa),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 20, drain"  
        STOP
     ENDIF

     ! ... Load the drain index structure; first and last segments per drain cell
     lc = 1
     ms = mdbc(1)
     drain_seg_m(lc) = ms
     drain_seg_first(lc) = 1
     DO ls=2,ndbc_seg
        ! ... This loop expects all segments attached to a given cell to be 
        ! ...      contiguous
        IF(mdbc(ls) == ms) CYCLE
        drain_seg_last(lc) = ls - 1
        drain_seg_first(lc+1) = ls
        lc = lc + 1
        ms = mdbc(ls)
     END DO
     drain_seg_last(lc) = ndbc_seg
     ! ... Load the drain cell and segment connections
     DO lc=1,ndbc_cells
        mdbc_bot(lc) = nxyz+1
        DO ls=drain_seg_first(lc),drain_seg_last(lc)
           kdbc(ls) = kdbc(ls)*areadbc(ls)    ! ... include area into leakance 
           ! ... connect the drain segment to the cell containing drain bottom
           !erflg = .FALSE.  
           !ks = nintrp(zedbc(ls) - bbdbc(ls), nz, z, erflg)
           !IF (erflg) THEN     ! ... out of range of mesh, use top or bottom cell
           !   IF ((zedbc(ls) - bbdbc(ls)) > z(nz)) THEN
           !      ks = nz
           !   ELSE
           !      ks = 1
           !   ENDIF
           !ENDIF
           m = mdbc(ls)
           !mr = m - (nz - ks)*nxy
           !mdbc(ls) = mr
           !mdseg_bot(ls) = mr            ! ... static index for drain segment bottom
           ! ... ibc for drain is always at the top of the mesh region
           !mdbc_bot(lc) = MIN(mdbc_bot(lc),mr)     ! ... set to lowest drain seg bottom
           mdbc_bot(lc) = m
        END DO
        drain_seg_m(lc) = mdbc_bot(lc)
     END DO
     ! ... Zero the arrays for drain leakage
     adbc = 0._kdp
     qfdbc = 0._kdp  
     qsdbc = 0._kdp  
     ccfdb = 0._kdp  
     ccfvdb = 0._kdp  
     ccsdb = 0._kdp  
  ENDIF
!!$  if(naifc.gt.0) then  
!!$     ! ... aquifer influence functions b.c.
!!$     !...  ** not available in phast
!!$  ! ... locate the heat conduction b.c. nodes and store thermal
!!$  ! ...      diffusivities and thermal conductivities*areas
!!$  !...*** not available in phast
  DEALLOCATE (arxbc, arybc, arzbc, delz, uarxbc, uarybc, uarzbc,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "array deallocation failed, init2.1, number d1"  
     STOP  
  ENDIF
  IF(num_flo_zones > 0) THEN
     ! ... Locate and load the lcell numbers for each internal zone for each b.c. type
     ! ...      for flowrate totalization 
     DO izn=1,num_flo_zones
        IF(nsbc_cells > 0) THEN
           DO ic=1,lnk_bc2zon(izn,1)%num_bc
              DO lc=1,nsbc
                 IF(msbc(lc) == lnk_bc2zon(izn,1)%lcell_no(ic)) THEN
                    lnk_bc2zon(izn,1)%lcell_no(ic) = lc
                    EXIT
                 END IF
              END DO
           END DO
        END IF
        IF(nfbc_cells > 0) THEN
           DO ic=1,lnk_bc2zon(izn,2)%num_bc
              DO lc=1,nfbc
                 IF(flux_seg_m(lc) == lnk_bc2zon(izn,2)%lcell_no(ic)) THEN
                    lnk_bc2zon(izn,2)%lcell_no(ic) = lc
                    EXIT
                 END IF
              END DO
           END DO
           IF(fresur) THEN
              DO ic=1,lnk_cfbc2zon(izn)%num_bc
                 DO lc=1,nfbc
                    IF(flux_seg_m(lc) == lnk_cfbc2zon(izn)%lcell_no(ic)) THEN
                       lnk_cfbc2zon(izn)%lcell_no(ic) = lc
                       CALL mtoijk(flux_seg_m(lc),i,j,k,nx,ny)
                       lnk_cfbc2zon(izn)%mxy_no(ic) = (j-1)*nx+i
                       DO icz=1,zone_col(izn)%num_xycol
                          IF(zone_col(izn)%i_no(icz) == i .AND. zone_col(izn)%j_no(icz) == j) THEN
                             lnk_cfbc2zon(izn)%icz_no(ic) = icz
                             EXIT
                          END IF
                       END DO
                       EXIT
                    END IF
                 END DO
              END DO
           END IF
        END IF
        IF(nlbc_cells > 0) THEN
           DO ic=1,lnk_bc2zon(izn,3)%num_bc
              DO lc=1,nlbc
                 IF(leak_seg_m(lc) == lnk_bc2zon(izn,3)%lcell_no(ic)) THEN
                    lnk_bc2zon(izn,3)%lcell_no(ic) = lc
                    EXIT
                 END IF
              END DO
           END DO
        END IF
        IF(nrbc_cells > 0 .AND. fresur) THEN
           DO ic=1,lnk_crbc2zon(izn)%num_bc
              DO lc=1,nrbc
                 IF(mrbc_top(lc) == lnk_crbc2zon(izn)%lcell_no(ic)) THEN
                    lnk_crbc2zon(izn)%lcell_no(ic) = lc
                    CALL mtoijk(mrbc_top(lc),i,j,k,nx,ny)
                    lnk_crbc2zon(izn)%mxy_no(ic) = (j-1)*nx+i
                    DO icz=1,zone_col(izn)%num_xycol
                       IF(zone_col(izn)%i_no(icz) == i .AND. zone_col(izn)%j_no(icz) == j) THEN
                          lnk_crbc2zon(izn)%icz_no(ic) = icz
!!$                      PRINT *,"Fail to link river to zone"
                          EXIT
!!$                      STOP
                       END IF
                    END DO
                    EXIT
                 END IF
              END DO
           END DO
        END IF
        IF(ndbc_cells > 0) THEN
           DO ic=1,lnk_bc2zon(izn,4)%num_bc
              DO lc=1,ndbc
                 IF(drain_seg_m(lc) == lnk_bc2zon(izn,4)%lcell_no(ic)) THEN
                    lnk_bc2zon(izn,4)%lcell_no(ic) = lc
                    EXIT
                 END IF
              END DO
           END DO
        END IF
        IF(nwel > 0) THEN
           DO ic=1,seg_well(izn)%num_wellseg
              DO iwel=1,nwel
                 DO ks=1,nz
                    IF(mwel(iwel,ks) == uzmwel(ic,izn)) THEN
                       seg_well(izn)%iwel_no(ic) = iwel
                       seg_well(izn)%ks_no(ic) = ks
                       EXIT
                    END IF
                 END DO
              END DO
           END DO
        END IF
     END DO
     IF(ALLOCATED(uzmwel)) DEALLOCATE (uzmwel,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: init2.1, number d2"  
        STOP  
     ENDIF
     ! ... Allocate the arrays for accumulation of zonal flow rates: mcv_m
     ALLOCATE(qfzoni(num_flo_zones), qfzonp(num_flo_zones),  &
          qszoni(nsa,num_flo_zones), qszonp(nsa,num_flo_zones),  &
          qfzoni_int(num_flo_zones), qfzonp_int(num_flo_zones),  &
          qszoni_int(nsa,num_flo_zones), qszonp_int(nsa,num_flo_zones),  &
          qfzoni_sbc(num_flo_zones), qfzonp_sbc(num_flo_zones),  &
          qszoni_sbc(nsa,num_flo_zones), qszonp_sbc(nsa,num_flo_zones),  &
          qfzoni_fbc(num_flo_zones), qfzonp_fbc(num_flo_zones),  &
          qszoni_fbc(nsa,num_flo_zones), qszonp_fbc(nsa,num_flo_zones),  &
          qfzoni_lbc(num_flo_zones), qfzonp_lbc(num_flo_zones),  &
          qszoni_lbc(nsa,num_flo_zones), qszonp_lbc(nsa,num_flo_zones),  &
          qfzoni_rbc(num_flo_zones), qfzonp_rbc(num_flo_zones),  &
          qszoni_rbc(nsa,num_flo_zones), qszonp_rbc(nsa,num_flo_zones),  &
          qfzoni_dbc(num_flo_zones), qfzonp_dbc(num_flo_zones),  &
          qszoni_dbc(nsa,num_flo_zones), qszonp_dbc(nsa,num_flo_zones),  &
          qfzoni_wel(num_flo_zones), qfzonp_wel(num_flo_zones),  &
          qszoni_wel(nsa,num_flo_zones), qszonp_wel(nsa,num_flo_zones),  &
          STAT = a_err)
     IF (a_err /= 0) THEN
        PRINT *, "array allocation failed: init2.1, number 21"
        STOP
     ENDIF
  END IF
  ! ... create cell connection list for natural numbering
  ! ... allocate solver space: mcs
  ALLOCATE (cin(6,nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN
     PRINT *, "array allocation failed: init2.1, number 22"
     STOP
  ENDIF
  DO m=1,nxyz  
     DO ic=1,6  
        cin(ic,m) = 0  
     END DO
     IF(ibc(m) == -1) CYCLE          ! ... skip excluded cells
     CALL mtoijk(m,i,j,k,nx,ny)  
     ! ... no connections outside the rectangular mesh of nodes
     ! ...      or to excluded cells
     ! ... left
     IF(i > 1) THEN
        IF (ibc(m-1) /= -1) cin(3,m) = m-1
     ENDIF
     ! ... right
     IF(i < nx) THEN
        IF (ibc(m+1) /= -1) cin(4,m) = m+1
     ENDIF
     ! ... front
     IF(j > 1) THEN
        IF (ibc(m-nx) /= -1) cin(2,m) = m-nx
     ENDIF
     ! ... back
     IF(j < ny) THEN
        IF (ibc(m+nx) /= -1) cin(5,m) = m+nx
     ENDIF
     ! ... below
     IF(k > 1) THEN
        IF (ibc(m-nxy) /= -1) cin(1,m) = m-nxy
     ENDIF
     ! ... above
     IF(k < nz) THEN
        IF (ibc(m+nxy) /= -1) cin(6,m) = m+nxy
     ENDIF
  END DO
  ! ... flag the specified value nodes in the cin array
  DO l=1,nsbc  
     msv = msbc(l)  
     DO ic=1,6  
        m=ABS(cin(ic,msv))
        IF(m /= 0) THEN
           IF(MOD(ic,2).EQ.0) THEN
              cin(ic-1,m)=-cin(ic-1,m)
           ELSE
              cin(ic+1,m)=-cin(ic+1,m)
           ENDIF
        ENDIF
     END DO
  END DO

  DEALLOCATE (cell_sd,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: init2.1, number 23d"
     STOP
  ENDIF
  ! ... tolerances for iterative solution of p,t,c equations
  ! ...      change in density
  !...***not applicable
  IF(slmeth == 1) THEN
     ! ... Allocate solver arrays: mcs
     ALLOCATE (ind(nxyz), mrno(nxyz), mord(nxyz),  &
          ip1(nxyzh), ip1r(nxyzh), ipenv(nxyzh+2),  &
          ci(6,nxyz), cir(lrcgd1,nxyzh), cirh(lrcgd2,nxyzh), cirl(lrcgd2,nxyzh),  &
          STAT = a_err)
     IF (a_err /= 0) THEN
        PRINT *, "array allocation failed: init2.1, number 24"
        STOP
     ENDIF
     ! ... establish d4 cell reordering for reduced matrix, ra
     CALL reordr(slmeth)  
     ! ... allocate space for the solver: mcs2
     ALLOCATE(diagra(nbn), envlra(ipenv(nbn+1)), envura(ipenv(nbn+1)),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: init2.1, number 25"
        STOP
     ENDIF
     ! ... primary and overhead storage
     nprist = nbn + 2*ipenv(nbn+1)  
     nohst = 9*nxyz + nbn + 1  
     nstslv = nprist + nohst  
  ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN
     ! ... Allocate solver arrays: mcs
     ALLOCATE (ind(nxyz), mrno(nxyz), mord(nxyz), ci(6,nxyz), cir(lrcgd1,nxyzh), &
          cirh(lrcgd2,nxyzh), cirl(lrcgd2,nxyzh), &
          STAT = a_err)
     IF (a_err /= 0) THEN
        PRINT *, "array allocation failed: init2.1, number 26"
        STOP
     ENDIF
     ! ... establish red-black or d4z cell reordering for reduced matrix, ra
     CALL reordr(slmeth)
     ! ... allocate space for the solver: mcs2
     ALLOCATE(ap(nrn,0:nsdr), bbp(nbn,0:nsdr), ra(lrcgd1,nbn), rr(nrn), sss(nbn),  &
          xx(nxyz), ww(nrn), zz(nbn), sumfil(nbn),  &
          STAT = a_err)
     IF (a_err /= 0) THEN
        PRINT *, "array allocation failed: init2.1, number 27"
        STOP
     ENDIF
     ! ... primary and overhead storage
     nprist = lrcgd1*nbn  
     nohst = 3*lrcgd1*nbn + 2*(nsdr + 1)*nbn + 10*nxyz + 5* &
          nbn + (nsdr - 1)*(nsdr - 1) + nsdr + 19*19 + 42
     nstslv = nprist + nohst  
  ENDIF
  ! ... allocate space for the assembly of difference equations: mcm
  ALLOCATE(va(7,nxyz), rhs(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: init2.1, number 28"
     STOP
  ENDIF

  ! ... Allocate more solver arrays: mcs
  ALLOCATE(diagc(nxyz), diagr(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: init2.1, number 29"
     STOP
  ENDIF
  ident_diagc = .TRUE.       !***** flag for diagnostic; column scaling
  ! ... initialize heat conduction b.c. temperatures
  ! ...***not available in phast
  ! ... initialize pressure if hydrostatic i.c.
  IF(ichydp) THEN  
     x0 = x(1)
     y0 = y(1)
     z0 = zpinit
     ! ... initialize top down or bottom up depending on zpinit
     k1 = 1  
     IF(zpinit > 0.5*(z(nz) + z(1))) k1 = nz  
     ! ...      first cell
     ugdelx = gx*(x(1) - x0)  
     ugdely = gy*(y(1) - y0)  
     ugdelz = gz*(z(k1) - z0)  
     m = cellno(1,1,k1)  
     ut = t0
     uc = w0
     uden = den0
     p(m) = (pinit - uden*ugdelz)/(1._kdp + .5*denp*ugdelz)
     ! ...       first layer, j=1 row
     DO  i = 2,nx
        m = cellno(i,1,k1)  
        ugdelx = gx*(x(i) - x(i-1))  
        uden = den0  
        p(m) = (p(m-1) - uden*ugdelx)/(1._kdp + .5*denp*ugdelx)
     END DO
     ! ...      first layer, remaining rows by column
     IF(.NOT.cylind) THEN  
        DO  j=2,ny
           ugdely = gy*(y(j) - y(j-1))
           DO  i=1,nx  
              m = cellno(i,j,k1)
              mijmk = m - nx  
              uden = den0  
              p(m) = (p(mijmk) - uden*ugdely)/(1._kdp + .5*denp*ugdely)
           END DO
        END DO
     ENDIF
     ! ...      remaining layers upward or downward
     IF(k1 == 1) THEN
        kf = 2
        kl = nz
        kinc = 1
     ELSE
        kf = nz-1
        kl = 1
        kinc = - 1
     ENDIF
     DO  k = kf, kl, kinc  
        ugdelz = gz*(z(k) - z(k-kinc))  
        DO  j = 1, ny
           DO  i = 1, nx
              m = cellno(i,j,k)
              mijkm = m - kinc*nxy  
              uden = den0  
              p(m) = (p(mijkm) - uden*ugdelz)/(1._kdp + .5*denp*ugdelz)
           END DO
        END DO
     END DO
  ENDIF
  IF(ichwt) THEN
     ! ... initialize pressure when water table elevation is input
     ! ...      done in vertical columns
     ! ... compressibility of fluid is neglected
     ! ...      top layer of cells
     !!$         udt=0._kdp
     !!$         udc=0._kdp
     DO  j = 1,ny
        DO  i = 1,nx
           m = cellno(i,j,nz)
           ugdelz = gz*(hwt(m) - z(nz))  
           uden = den0
           p(m) = uden*ugdelz
           ! ...      remaining layers
           DO  k2 = nz-1,1,-1
              m2 = cellno(i,j,k2)
              m1 = m2 + nxy  
              ugdelz = gz*(z(k2) - z(k2+1))
              uden = den0  
              p(m2) = p(m1) - uden*ugdelz
           END DO
        END DO
     END DO
  ENDIF

  ! ... Allocate free surface, water table arrays: mcb and mg2_m
  ALLOCATE (mfsbc(nxy), print_dry_col(nxy), hdprnt(nxyz), wt_elev(nxy),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: init2.1, number 30"  
     STOP  
  ENDIF
  hdprnt = 0._kdp
  wt_elev = 0._kdp
  ! ... initialize the fraction of cell that is saturated
  ! ...      all pressures are valid, dry cells initialized to
  ! ...           hydrostatic pressure, excluded cells set to frac of zero.
  ! ... this is slightly different than in sumcal, because the entire mesh has
  ! ...      pressures initialized
  ! ... suspended..interpolation of pressures is used which accounts for non-hydrostatic
  ! ...      conditions. hydrostatic extrapolation is used for top cells of region
  ! ...      or at land surface
  ! ... all fracs based on hydrostatic conditions 
  DO m=1,nxyz-nxy         ! ... do all but the top plane
     IF(ibc(m) == -1) THEN 
        frac(m) = 0._kdp
        frac_icchem(m) = 0._kdp
        vmask(m) = 0
     ELSEIF(.NOT.fresur) THEN  
        frac(m) = 1._kdp
        frac_icchem(m) = 1._kdp
        vmask(m) = 1
     ELSEIF(fresur) THEN
        frac_icchem(m) = 1._kdp
        imod = MOD(m,nxy)
        k = (m-imod)/nxy + MIN(1,imod)
        IF(k == 1) THEN
           ! ... bottom plane
           IF(p(m) > 0._kdp) THEN
              up0=p(m)
              z0=z(1)
              zp1=z(2)
              zfsl = up0/(den0*gz) + z0     ! Hydrostatic
              frac(m)=2.*(zfsl-z0)/(zp1-z0)
              frac(m)=MIN(1._kdp,frac(m))
              vmask(m) = 1
           ELSE
              frac(m)=0._kdp       ! draining cell is empty
              vmask(m) = 0
           END IF
        ELSE
           ! ... intermediate plane
           IF(ibc(m-nxy) == -1) THEN
              ! ... treat as bottom plane
              IF(p(m) > 0._kdp) THEN
                 up0=p(m)
                 z0=z(k)
                 zp1=z(k+1)
                 zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = 2.*(zfsl-z0)/(zp1-z0)
                 frac(m) = MIN(1._kdp,frac(m))
                 vmask(m) = 1
              ELSE
                 frac(m) = 0._kdp       ! ... Empty column of cells
                 vmask(m) = 0
              END IF
           ELSEIF(ibc(m+nxy) == -1) THEN
              ! ... treat as top plane
              IF(p(m) > 0._kdp) THEN
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zfsl = up0/(den0*gz) + z0     ! hydrostatic
                 frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                 frac(m) = MIN(1._kdp,frac(m))
                 vmask(m) = 1
              ELSE
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                 frac(m) = MAX(0._kdp,frac(m))
                 vmask(m) = 0
              END IF
           ELSE
              ! ... true intermediate plane
              IF(p(m) >= 0._kdp) THEN
                 up0=p(m)
                 z0=z(k)
                 zp1=z(k+1)
                 zm1=z(k-1)
                 zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfsl-(z0+zm1))/(zp1-zm1)
                 frac(m) = MIN(1._kdp,frac(m))
                 vmask(m) = 1
              ELSE
                 up0=p(m)
                 z0=z(k)
                 zp1=z(k+1)
                 zm1=z(k-1)
                 zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfsl-(z0+zm1))/(zp1-zm1)
                 frac(m) = MAX(0._kdp,frac(m))
                 vmask(m) = 0
              END IF
           END IF
        END IF
        IF(frac(m) <= 1.e-6_kdp) THEN
           frac(m) = 0._kdp
           vmask(m) = 0
        END IF
     END IF
  END DO
  DO m=nxyz-nxy+1,nxyz       ! ...      top plane 
     IF(ibc(m) ==  -1) THEN
        frac(m) = 0._kdp
        frac_icchem(m) = 0._kdp
        vmask(m) = 0
     ELSEIF(.NOT.fresur) THEN
        frac(m) = 1._kdp
        frac_icchem(m) = 1._kdp
        vmask(m) = 1
     ELSEIF(fresur) THEN
        !$$        den(m) = den0
        frac_icchem(m) = 1._kdp
        ! ... top plane
        k = nz
        IF(p(m) > 0._kdp) THEN
           up0=p(m)
           zm1=z(k-1)
           z0=z(k)
           zfsl = up0/(den0*gz) + z0     ! hydrostatic
           frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
           vmask(m) = 1
        ELSE
           up0=p(m)
           zm1=z(k-1)
           z0=z(k)
           zfsl = up0/(den0*gz) + z0     ! hydrostatic
           frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
           frac(m)=MAX(0._kdp,frac(m))
           vmask(m) = 0
        END IF
        IF(frac(m) <= 1.e-6_kdp) THEN
           frac(m) = 0._kdp
           vmask(m) = 0
        END IF
     END IF
  END DO
  ! ... set the pointer to the cell containing the free surface
  ! ...      at each node location over the horizontal area
  ! ... also set all frac to one for cells below the f.s. cell
  all_dry = .TRUE.
  some_dry = .FALSE.
  print_dry_col = .FALSE.
  DO mt=1,nxy
     mfsbc(mt) = 0
     DO k=nz,1,-1
        m1 = (k-1)*nxy + mt
        IF (ibc(m1) >= 0) THEN
           IF(frac(m1) > 0._kdp) THEN
              mfsbc(mt) = m1
              EXIT
           END IF
        END IF
     END DO
     DO m=m1-nxy,1,-nxy
        frac(m) = 1._kdp
     END DO
     IF(m1 == 0) THEN
        some_dry = .TRUE.
        CALL mtoijk(mt,icol,jcol,kcol,nx,ny)
        WRITE(logline1,'(a)')  'WARNING: A column of cells is dry in init2_1'
        status = RM_ScreenMessage(rm_id, logline1)
        status = RM_LogMessage(rm_id, logline1)
        WRITE(logline1,'(tr5,a,i6,a,i5,a,i5,i5)')   &
             'Cell column:', mt,' (i,j):', icol, ',', jcol
        status = RM_ScreenMessage(rm_id, logline1)
        status = RM_LogMessage(rm_id, logline1)
        print_dry_col(mt) = .TRUE.
     ELSE
        all_dry = .FALSE.
     END IF
  END DO
  IF (all_dry) ierr(40) = .TRUE.
  IF (some_dry) THEN
     status = RM_WarningMessage(rm_id, 'One or more cell columns are dry.')
  ENDIF
  DO m = 1,nxyz  
     IF(ibc(m) == - 1) THEN
        IF(solute) THEN
           DO  is=1,ns
              c(m,is) = 0._kdp
           END DO
        END IF
     ELSE
        ! ... calculate initial head distribution
        imod = MOD(m,nxy)
        k = (m-imod)/nxy + MIN(1,imod)
        hdprnt(m) = z(k) + p(m)/(den0*gz)
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
  IF(solute) THEN  
     IF(crosd) THEN
        ! ... cancel cross-dispersive term calculation if all
        ! ...      alpha_l equal alpha_t
        crosd = .FALSE.
        DO ipmz=1,npmz  
           IF(ABS(alphl(ipmz) - alphth(ipmz)) > 1.e-6_kdp) crosd = .TRUE.
           IF(ABS(alphl(ipmz) - alphtv(ipmz)) > 1.e-6_kdp) crosd = .TRUE.
        END DO
     ENDIF

     call calc_volume

  ENDIF
  ALLOCATE (aprnt1(nxyz), aprnt2(nxyz), aprnt3(nxyz), aprnt4(nxyz), &
       c_mol(nxyz,nsa),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: write2_1, number 1"
     STOP  
  ENDIF
! write char_ibc; apparently WRITE(cibc,...) is not thread safe in IFORT
  DO i = 1, nxyz
    IF (ibc(i) .ne. -1) THEN
        WRITE(char_ibc(i), 6001) ibc(i)
6001    FORMAT(i9.9)
    ENDIF
  ENDDO 

!!$  DEALLOCATE (axsav, aysav, azsav, hwt,  &
!!$       stat = da_err)
!!$  IF (da_err /= 0) THEN  
!!$     PRINT *, "Array deallocation failed: init2.1, number d3"  
!!$     STOP  
!!$  ENDIF
  DEALLOCATE (hwt,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: init2.1, number d4"  
     STOP
  ENDIF
END SUBROUTINE init2_1
