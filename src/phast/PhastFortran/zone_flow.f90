SUBROUTINE zone_flow
  ! ... Calculates flow rates for each internal zone
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcb2_m
  USE mcc, ONLY: cylind, solute
  USE mcch, only: comp_name
  USE mcg
  USE mcg_m
  USE mcn, ONLY: x, y, z
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  IMPLICIT NONE
  INTEGER :: i, icz, iis, ifc, ilc, iwel, izn, j, k, ks, kfs, lc, m, mfs
  INTEGER :: mijmkm, mijmkp, mijpkm, mijpkp, mimjkm,  &
       mimjkp, mimjmk, mimjpk, mipjkm, mipjkp, mipjmk, mipjpk
!!$  REAL(KIND=kdp) :: uden, ufrac, uvis, wt
  REAL(KIND=kdp) :: ucwt, ufdt1, wt
  REAL(KIND=kdp), DIMENSION(ns) :: ftxydm, ftxydp, ftxzdm, ftxzdp, ftyxdm, ftyxdp,  &
       ftyzdm, ftyzdp, ftzxdm, ftzxdp, ftzydm, ftzydp,  &
       sxxs, syys, szzs
  REAL(KIND=kdp) :: dxm, dxp, dym, dyp, dzm, dzp, wtx, wty, wtz
  integer :: min_is
  !     ------------------------------------------------------------------
  !...
  if (solute) then
      do is = 1, ns
          if (comp_name(is) .eq. "Charge") exit
      enddo
      min_is = is + 1
  endif
  
  ufdt1 = fdtmth
  ! ... Update conductance coefficients, mass flow rates, velocities
  CALL coeff_flow
  CALL coeff_trans
  ! ... Zero the flow rate accumulators
  qfzoni = 0._kdp
  qfzonp = 0._kdp
  qszoni = 0._kdp
  qszonp = 0._kdp
  qfzoni_int = 0._kdp
  qfzonp_int = 0._kdp
  qszoni_int = 0._kdp
  qszonp_int = 0._kdp
  qfzoni_sbc = 0._kdp
  qfzonp_sbc = 0._kdp
  qszoni_sbc = 0._kdp
  qszonp_sbc = 0._kdp
  qfzoni_fbc = 0._kdp
  qfzonp_fbc = 0._kdp
  qszoni_fbc = 0._kdp
  qszonp_fbc = 0._kdp
  qfzoni_lbc = 0._kdp
  qfzonp_lbc = 0._kdp
  qszoni_lbc = 0._kdp
  qszonp_lbc = 0._kdp
  qfzoni_rbc = 0._kdp
  qfzonp_rbc = 0._kdp
  qszoni_rbc = 0._kdp
  qszonp_rbc = 0._kdp
  qfzoni_dbc = 0._kdp
  qfzonp_dbc = 0._kdp
  qszoni_dbc = 0._kdp
  qszonp_dbc = 0._kdp
  qfzoni_wel = 0._kdp
  qfzonp_wel = 0._kdp
  qszoni_wel = 0._kdp
  qszonp_wel = 0._kdp
  ! ... Sum flow rates over internal faces for each zone
  DO  izn=1,num_flo_zones
     DO  ifc=1,zone_ib(izn)%num_int_faces
        m = zone_ib(izn)%mcell_no(ifc)
        CALL mtoijk(m,i,j,k,nx,ny)
        mimjk = xdcellno(i-1,j,k)
        mipjk = xdcellno(i+1,j,k)
        mijmk = xdcellno(i,j-1,k)
        mijpk = xdcellno(i,j+1,k)
        mijkm = xdcellno(i,j,k-1)
        mijkp = xdcellno(i,j,k+1)
        mipjpk = xdcellno(i+1,j+1,k)
        mipjmk = xdcellno(i+1,j-1,k)
        mipjkp = xdcellno(i+1,j,k+1)
        mipjkm = xdcellno(i+1,j,k-1)
        mimjpk = xdcellno(i-1,j+1,k)
        mimjmk = xdcellno(i-1,j-1,k)
        mimjkp = xdcellno(i-1,j,k+1)
        mimjkm = xdcellno(i-1,j,k-1)
        mijmkp = xdcellno(i,j-1,k+1)
        mijpkp = xdcellno(i,j+1,k+1)
        mijmkm = xdcellno(i,j-1,k-1)
        mijpkm = xdcellno(i,j+1,k-1)
        IF(zone_ib(izn)%face_indx(ifc) == 4) THEN
           ! ... X-direction mass flow rates
           ! ...  dispersive flux terms and advective flux terms 
           ! ...  including cross-dispersive flux terms
           ftxydp = 0._kdp
           ftxzdp = 0._kdp
           wt=fdsmth
           IF(sxx(m) < 0.) wt=1._kdp-wt
           DO  iis=min_is,ns                    ! ... No charge flows calculated
              ucwt=((1._kdp-wt)*c(m,iis)+wt*c(m+1,iis))
              sxxs(iis) = sxx(m)*ucwt - tsx(m)*(c(m+1,iis)-c(m,iis))
              ! ... If any of the 6 nodes needed for a gradient are excluded, 
              ! ...      that flux term is zero.
              IF(mijmk > 0 .AND. mijpk > 0) THEN
                 dyp = y(j+1)-y(j)
                 dym = y(j)-y(j-1)
                 wty = dym/(dym+dyp)
                 IF(mipjk > 0 .AND. mipjpk > 0 .AND. mipjmk > 0)  &
                      ftxydp(iis) = crdf1(tsxy(m),c(mipjpk,iis),c(mijpk,iis),  &
                      c(mipjk,iis),c(m,iis),c(mipjmk,iis),c(mijmk,iis),dyp,dym,wty)
              END IF
              IF(mijkm > 0 .AND. mijkp > 0) THEN
                 dzp = z(k+1)-z(k)
                 dzm = z(k)-z(k-1)
                 wtz = dzm/(dzm+dzp)
                 IF(mipjk > 0 .AND. mipjkp > 0 .AND. mipjkm > 0)  &
                      ftxzdp(iis) = crdf1(tsxz(m),c(mipjkp,iis),c(mijkp,iis),  &
                      c(mipjk,iis),c(m,iis),c(mipjkm,iis),c(mijkm,iis),dzp,dzm,wtz)
              END IF
           END DO
           IF (sxx(m) > 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) + sxx(m)
              qfzonp(izn) = qfzonp(izn) + sxx(m)
           ELSEIF (sxx(m) < 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) - sxx(m)
              qfzoni(izn) = qfzoni(izn) - sxx(m)
           END IF
           DO  iis=min_is,ns
              IF (sxxs(iis) > 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) + sxxs(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) + sxxs(iis)
              ELSEIF (sxxs(iis) < 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) - sxxs(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) - sxxs(iis)
              END IF
              IF (ftxydp(iis) > 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) + ftxydp(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) + ftxydp(iis)
              ELSEIF (ftxydp(iis) < 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) - ftxydp(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) - ftxydp(iis)
              END IF
              IF (ftxzdp(iis) > 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) + ftxzdp(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) + ftxzdp(iis)
              ELSEIF (ftxzdp(iis) < 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) - ftxzdp(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) - ftxzdp(iis)
              END IF
           END DO
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 3) THEN
           ! ... X-direction conductances, mass flow rates
           ! ...  dispersive flux terms and advective flux terms 
           ! ...  including cross-dispersive flux terms
           ftxydm = 0._kdp
           ftxzdm = 0._kdp
           wt=fdsmth
           IF(sxx(m-1) < 0.) wt=1._kdp-wt
           DO  iis=min_is,ns
              ucwt=((1._kdp-wt)*c(m-1,iis)+wt*c(m,iis))
              sxxs(iis) = sxx(m-1)*ucwt - tsx(m-1)*(c(m,iis)-c(m-1,iis))
              IF(mijmk > 0 .AND. mijpk > 0) THEN
                 dyp = y(j+1)-y(j)
                 dym = y(j)-y(j-1)
                 wty = dym/(dym+dyp)
                 IF(mimjk > 0 .AND. mimjpk > 0 .AND. mimjmk > 0)  &
                      ftxydm(iis) = crdf1(tsxy(m-1),c(mijpk,iis),c(mimjpk,iis),  &
                      c(m,iis),c(mimjk,iis),c(mijmk,iis),c(mimjmk,iis),dyp,dym,wty)
              END IF
              IF(mijkm > 0 .AND. mijkp > 0) THEN
                 dzp = z(k+1)-z(k)
                 dzm = z(k)-z(k-1)
                 wtz = dzm/(dzm+dzp)
                 IF(mimjk > 0 .AND. mimjkp > 0 .AND. mimjkm > 0)  &
                      ftxzdm(iis) = crdf1(tsxz(m-1),c(mijkp,iis),c(mimjkp,iis),  &
                      c(m,iis),c(mimjk,iis),c(mijkm,iis),c(mimjkm,iis),dzp,dzm,wtz)
              END IF
           END DO
           IF (sxx(m-1) < 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) - sxx(m-1)
              qfzonp(izn) = qfzonp(izn) - sxx(m-1)
           ELSEIF (sxx(m-1) > 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) + sxx(m-1)
              qfzoni(izn) = qfzoni(izn) + sxx(m-1)
           END IF
           DO  iis=min_is,ns
              IF (sxxs(iis) < 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) - sxxs(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - sxxs(iis)
              ELSEIF (sxxs(iis) > 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) + sxxs(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + sxxs(iis)
              END IF
              IF (ftxydm(iis) < 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) - ftxydm(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - ftxydm(iis)
              ELSEIF (ftxydm(iis) > 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) + ftxydm(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + ftxydm(iis)
              END IF
              IF (ftxzdm(iis) < 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) - ftxzdm(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - ftxzdm(iis)
              ELSEIF (ftxzdm(iis) > 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) + ftxzdm(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + ftxzdm(iis)
              END IF
           END DO
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 5 .AND. .NOT.cylind) THEN
           ! ... Y-direction conductances, mass flow rates
           ! ...  dispersive flux terms and advective flux terms 
           ! ...  including cross-dispersive flux terms
           ftyxdp = 0._kdp
           ftyzdp = 0._kdp
           wt=fdsmth
           IF(syy(m) < 0.) wt=1._kdp-wt
           DO  iis=min_is,ns
              ucwt=((1._kdp-wt)*c(m,iis)+wt*c(mijpk,iis))
              syys(iis) = syy(m)*ucwt - tsy(m)*(c(mijpk,iis)-c(m,iis))
              IF(mimjk > 0 .AND. mipjk > 0) THEN
                 dxp = x(i+1)-x(i)
                 dxm = x(i)-x(i-1)
                 wtx = dxm/(dxm+dxp)
                 IF(mijpk > 0 .AND. mipjpk > 0 .AND. mimjpk > 0)  &
                      ftyxdp(iis) = crdf1(tsyx(m),c(mipjpk,iis),c(mipjk,iis),  &
                      c(mijpk,iis),c(m,iis),c(mimjpk,iis),c(mimjk,iis),dxp,dxm,wtx)
              END IF
              IF(mijkm > 0 .AND. mijkp > 0) THEN
                 dzp = z(k+1)-z(k)
                 dzm = z(k)-z(k-1)
                 wtz = dzm/(dzm+dzp)
                 IF(mijpk > 0 .AND. mijpkp > 0 .AND. mijpkm > 0)  &
                      ftyzdp(iis) = crdf1(tsyz(m),c(mijpkp,iis),c(mijkp,iis),  &
                      c(mijpk,iis),c(m,iis),c(mijpkm,iis),c(mijkm,iis),dzp,dzm,wtz)
              END IF
           END DO
           IF (syy(m) > 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) + syy(m)
              qfzonp(izn) = qfzonp(izn) + syy(m)
           ELSEIF (syy(m) < 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) - syy(m)
              qfzoni(izn) = qfzoni(izn) - syy(m)
           END IF
           DO  iis=min_is,ns
              IF (syys(iis) > 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) + syys(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) + syys(iis)
              ELSEIF (syys(iis) < 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) - syys(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) - syys(iis)
              END IF
              IF (ftyxdp(iis) > 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) + ftyxdp(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) + ftyxdp(iis)
              ELSEIF (ftyxdp(iis) < 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) - ftyxdp(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) - ftyxdp(iis)
              END IF
              IF (ftyzdp(iis) > 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) + ftyzdp(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) + ftyzdp(iis)
              ELSEIF (ftyzdp(iis) < 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) - ftyzdp(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) - ftyzdp(iis)
              END IF
           END DO
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 2 .AND. .NOT.cylind) THEN
           ! ... Y-direction conductances, mass flow rates
           ! ...  dispersive flux terms and advective flux terms 
           ! ...  including cross-dispersive flux terms
           ftyxdm = 0._kdp
           ftyzdm = 0._kdp
           wt=fdsmth
           IF(syy(mijmk) < 0.) wt=1._kdp-wt
           DO  iis=min_is,ns
              ucwt=((1._kdp-wt)*c(mijmk,iis)+wt*c(m,iis))
              syys(iis) = syy(mijmk)*ucwt - tsy(mijmk)*(c(m,iis)-c(mijmk,iis))
              IF(mimjk > 0 .AND. mipjk > 0) THEN
                 dxp = x(i+1)-x(i)
                 dxm = x(i)-x(i-1)
                 wtx = dxm/(dxm+dxp)
                 IF(mijmk > 0 .AND. mipjmk > 0 .AND. mimjmk > 0)  &
                      ftyxdm(iis) = crdf1(tsyx(mijmk),c(mipjk,iis),c(mipjmk,iis),  &
                      c(m,iis),c(mijmk,iis),c(mimjk,iis),c(mimjmk,iis),dxp,dxm,wtx)
              END IF
              IF(mijkm > 0 .AND. mijkp > 0) THEN
                 dzp = z(k+1)-z(k)
                 dzm = z(k)-z(k-1)
                 wtz = dzm/(dzm+dzp)
                 IF(mijmk > 0 .AND. mijmkp > 0 .AND. mijmkm > 0)  &
                      ftyzdm(iis) = crdf1(tsyz(mijmk),c(mijkp,iis),c(mijmkp,iis),  &
                      c(m,iis),c(mijmk,iis),c(mijkm,iis),c(mijmkm,iis),dzp,dzm,wtz)
              END IF
           END DO
           IF (syy(mijmk) < 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) - syy(mijmk)
              qfzonp(izn) = qfzonp(izn) - syy(mijmk)
           ELSEIF (syy(mijmk) > 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) + syy(mijmk)
              qfzoni(izn) = qfzoni(izn) + syy(mijmk)
           END IF
           DO  iis=min_is,ns
              IF (syys(iis) < 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) - syys(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - syys(iis)
              ELSEIF (syys(iis) > 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) + syys(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + syys(iis)
              END IF
              IF (ftyxdm(iis) < 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) - ftyxdm(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - ftyxdm(iis)
              ELSEIF (ftyxdm(iis) > 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) + ftyxdm(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + ftyxdm(iis)
              END IF
              IF (ftyzdm(iis) < 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) - ftyzdm(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - ftyzdm(iis)
              ELSEIF (ftyzdm(iis) > 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) + ftyzdm(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + ftyzdm(iis)
              END IF
           END DO
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 6) THEN
           ! ... Z-direction conductances, mass flow rates
           ! ...  dispersive flux terms and advective flux terms 
           ! ...  including cross-dispersive flux terms
           ftzxdp = 0._kdp
           ftzydp = 0._kdp
           wt=fdsmth
           IF(szz(m) < 0.) wt=1._kdp-wt
           DO  iis=min_is,ns
              ucwt=((1._kdp-wt)*c(m,iis)+wt*c(mijkp,iis))
              szzs(iis) = szz(m)*ucwt - tsz(m)*(c(mijkp,iis)-c(m,iis))
              IF(mimjk > 0 .AND. mipjk > 0) THEN
                 dxp = x(i+1)-x(i)
                 dxm = x(i)-x(i-1)
                 wtx = dxm/(dxm+dxp)
                 IF(mijkp > 0 .AND. mipjkp > 0 .AND. mimjkp > 0)  &
                      ftzxdp(iis) = crdf1(tszx(m),c(mipjkp,iis),c(mipjk,iis),  &
                      c(mijkp,iis),c(m,iis),c(mimjkp,iis),c(mimjk,iis),dxp,dxm,wtx)
              END IF
              IF(mijmk > 0 .AND. mijpk > 0) THEN
                 dyp = y(j+1)-y(j)
                 dym = y(j)-y(j-1)
                 wty = dym/(dym+dyp)
                 IF(mijkp > 0 .AND. mijpkp > 0 .AND. mijmkp > 0)  &
                      ftzydp(iis) = crdf1(tszy(m),c(mijpkp,iis), c(mijpk,iis),  &
                      c(mijkp,iis),c(m,iis),c(mijmkp,iis),c(mijmk,iis),dyp,dym,wty)
              END IF
           END DO
           IF(fresur .AND. frac(m) < 1._kdp) THEN
              szz(m) = 0._kdp
              szzs(:) = 0._kdp
           END IF
           IF (szz(m) > 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) + szz(m)
              qfzonp(izn) = qfzonp(izn) + szz(m)
           ELSEIF (szz(m) < 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) - szz(m)
              qfzoni(izn) = qfzoni(izn) - szz(m)
           END IF
           DO  iis=min_is,ns
              IF (szzs(iis) > 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) + szzs(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) + szzs(iis)
              ELSEIF (szzs(iis) < 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) - szzs(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) - szzs(iis)
              END IF
              IF (ftzxdp(iis) > 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) + ftzxdp(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) + ftzxdp(iis)
              ELSEIF (ftzxdp(iis) < 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) - ftzxdp(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) - ftzxdp(iis)
              END IF
              IF (ftzydp(iis) > 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) + ftzydp(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) + ftzydp(iis)
              ELSEIF (ftzydp(iis) < 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) - ftzydp(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) - ftzydp(iis)
              END IF
           END DO
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 1) THEN
           ! ... Z-direction conductances, mass flow rates
           ! ...  dispersive flux terms and advective flux terms 
           ! ...  including cross-dispersive flux terms
           ftzxdm = 0._kdp
           ftzydm = 0._kdp
           wt=fdsmth
           IF(szz(mijkm) < 0.) wt=1._kdp-wt
           DO  iis=min_is,ns
              ucwt=((1._kdp-wt)*c(mijkm,iis)+wt*c(m,iis))
              szzs(iis) = szz(mijkm)*ucwt - tsz(mijkm)*(c(m,iis)-c(mijkm,iis))
              IF(mimjk > 0 .AND. mipjk > 0) THEN
                 dxp = x(i+1)-x(i)
                 dxm = x(i)-x(i-1)
                 wtx = dxm/(dxm+dxp)
                 IF(mijkm > 0 .AND. mipjkm > 0 .AND. mimjkm > 0)  &
                      ftzxdm(iis) = crdf1(tszx(mijkm),c(mipjk,iis),c(mipjkm,iis),  &
                      c(m,iis),c(mijkm,iis),c(mimjk,iis),c(mimjkm,iis),dxp,dxm,wtx)
              END IF
              IF(mijmk > 0 .AND. mijpk > 0) THEN
                 dyp = y(j+1)-y(j)
                 dym = y(j)-y(j-1)
                 wty = dym/(dym+dyp)
                 IF(mijkm > 0 .AND. mijpkm > 0 .AND. mijmkm > 0)  &
                      ftzydm(iis) = crdf1(tszy(mijkm),c(mijpk,iis),c(mijpkm,iis),  &
                      c(m,iis),c(mijkm,iis),c(mijmk,iis),c(mijmkm,iis),dyp,dym,wty)
              END IF
           END DO
           IF(fresur .AND. frac(mijkm) < 1._kdp) THEN
              szz(mijkm) = 0._kdp
              szzs(:) = 0._kdp
           END IF
           IF (szz(mijkm) < 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) - szz(mijkm)
              qfzonp(izn) = qfzonp(izn) - szz(mijkm)
           ELSEIF (szz(mijkm) > 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) + szz(mijkm)
              qfzoni(izn) = qfzoni(izn) + szz(mijkm)
           END IF
           DO  iis=min_is,ns
              IF (szzs(iis) < 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) - szzs(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - szzs(iis)
              ELSEIF (szzs(iis) > 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) + szzs(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + szzs(iis)
              END IF
              IF (ftzxdm(iis) < 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) - ftzxdm(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - ftzxdm(iis)
              ELSEIF (ftzxdm(iis) > 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) + ftzxdm(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + ftzxdm(iis)
              END IF
              IF (ftzydm(iis) < 0.) THEN
                 qszonp_int(iis,izn) = qszonp_int(iis,izn) - ftzydm(iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - ftzydm(iis)
              ELSEIF (ftzydm(iis) > 0.) THEN
                 qszoni_int(iis,izn) = qszoni_int(iis,izn) + ftzydm(iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + ftzydm(iis)
              END IF
           END DO
        END IF
     END DO
     ! ... Add in the boundary condition flow rates
     IF(nsbc > 0) THEN
        ! ... Specified head b.c. cell boundary flow rates
        ! ...      and associated solute flow rates
        DO ilc=1,lnk_bc2zon(izn,1)%num_bc
           lc = lnk_bc2zon(izn,1)%lcell_no(ilc)
           ! ... Fluid flow rates
           IF(qfsbc(lc) < 0._kdp) THEN       ! ... Outflow boundary
              qfzonp_sbc(izn) = qfzonp_sbc(izn) - qfsbc(lc)
              qfzonp(izn) = qfzonp(izn) - qfsbc(lc)
           ELSE                              ! ... Inflow boundary
              qfzoni_sbc(izn) = qfzoni_sbc(izn) + qfsbc(lc)
              qfzoni(izn) = qfzoni(izn) + qfsbc(lc)
           END IF
           ! ... Calculate advective heat and solute flows at specified
           ! ...      pressure b.c. cells
           DO  iis=min_is,ns
              IF(qfsbc(lc) < 0._kdp) THEN
                 qszonp_sbc(iis,izn) = qszonp_sbc(iis,izn) - qssbc(lc,iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - qssbc(lc,iis)
              ELSE
                 qszoni_sbc(iis,izn) = qszoni_sbc(iis,izn) + qssbc(lc,iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + qssbc(lc,iis)
              END IF
           END DO
        END DO
     END IF
     IF(nfbc > 0) THEN
        ! ... Specified flux b.c.
        DO ilc=1,lnk_bc2zon(izn,2)%num_bc
           lc = lnk_bc2zon(izn,2)%lcell_no(ilc)
           IF(qffbc(lc) < 0._kdp) THEN             ! ... Outflow
              qfzonp_fbc(izn) = qfzonp_fbc(izn) - ufdt1*qffbc(lc)
              qfzonp(izn) = qfzonp(izn) - ufdt1*qffbc(lc)
             DO  iis=min_is,ns
                 qszonp_fbc(iis,izn) = qszonp_fbc(iis,izn) - ufdt1*qsfbc(lc,iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - ufdt1*qsfbc(lc,iis)
              END DO
           ELSE                                    ! ... Inflow
              qfzoni_fbc(izn) = qfzoni_fbc(izn) + ufdt1*qffbc(lc)
              qfzoni(izn) = qfzoni(izn) + ufdt1*qffbc(lc)
              DO  iis=min_is,ns
                 qszoni_fbc(iis,izn) = qszoni_fbc(iis,izn) + ufdt1*qsfbc(lc,iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + ufdt1*qsfbc(lc,iis)
              END DO
           END IF
        END DO
        IF(fresur) THEN
           DO ilc=1,lnk_cfbc2zon(izn)%num_bc
              lc = lnk_cfbc2zon(izn)%lcell_no(ilc)
              mfs = mfsbc(lnk_cfbc2zon(izn)%mxy_no(ilc))
              CALL mtoijk(mfs,i,j,kfs,nx,ny)
              icz = lnk_cfbc2zon(izn)%icz_no(ilc)
              IF(kfs >= zone_col(izn)%kmin_no(icz) .AND. kfs <= zone_col(izn)%kmax_no(icz)) THEN
                 IF(qffbc(lc) < 0._kdp) THEN             ! ... Outflow
                    qfzonp_fbc(izn) = qfzonp_fbc(izn) - ufdt1*qffbc(lc)
                    qfzonp(izn) = qfzonp(izn) - ufdt1*qffbc(lc)
                    DO  iis=min_is,ns
                       qszonp_fbc(iis,izn) = qszonp_fbc(iis,izn) - ufdt1*qsfbc(lc,iis)
                       qszonp(iis,izn) = qszonp(iis,izn) - ufdt1*qsfbc(lc,iis)
                    END DO
                 ELSE                                    ! ... Inflow
                    qfzoni_fbc(izn) = qfzoni_fbc(izn) + ufdt1*qffbc(lc)
                    qfzoni(izn) = qfzoni(izn) + ufdt1*qffbc(lc)
                    DO  iis=min_is,ns
                       qszoni_fbc(iis,izn) = qszoni_fbc(iis,izn) + ufdt1*qsfbc(lc,iis)
                       qszoni(iis,izn) = qszoni(iis,izn) + ufdt1*qsfbc(lc,iis)
                    END DO
                 END IF
              END IF
           END DO
        END IF
     END IF
     IF(nlbc > 0) THEN
        ! ... Aquifer leakage b.c.
        DO ilc=1,lnk_bc2zon(izn,3)%num_bc
           lc = lnk_bc2zon(izn,3)%lcell_no(ilc)
           ! ... Fluid flow rates
           IF(qflbc(lc) < 0._kdp) THEN           ! ... outflow
              qfzonp_lbc(izn) = qfzonp_lbc(izn) - ufdt1*qflbc(lc)
              qfzonp(izn) = qfzonp(izn) - ufdt1*qflbc(lc)
              DO  iis=min_is,ns
                 qszonp_lbc(iis,izn) = qszonp_lbc(iis,izn) - ufdt1*qslbc(lc,iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - ufdt1*qslbc(lc,iis)
              END DO
           ELSEIF(qflbc(lc) > 0._kdp) THEN        ! ...  inflow
              qfzoni_lbc(izn) = qfzoni_lbc(izn) + ufdt1*qflbc(lc)
              qfzoni(izn) = qfzoni(izn) + ufdt1*qflbc(lc)
              DO  iis=min_is,ns
                 qszoni_lbc(iis,izn) = qszoni_lbc(iis,izn) + ufdt1*qslbc(lc,iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + ufdt1*qslbc(lc,iis)
              END DO
           END IF
        END DO
     END IF
     IF(fresur .AND. nrbc > 0) THEN
        ! ... River leakage b.c.
        DO ilc=1,lnk_crbc2zon(izn)%num_bc
           lc = lnk_crbc2zon(izn)%lcell_no(ilc)
           mfs = mfsbc(lnk_crbc2zon(izn)%mxy_no(ilc))
           CALL mtoijk(mfs,i,j,kfs,nx,ny)
           icz = lnk_crbc2zon(izn)%icz_no(ilc)
           IF(kfs >= zone_col(izn)%kmin_no(icz) .AND. kfs <= zone_col(izn)%kmax_no(icz)) THEN
              IF(qfrbc(lc) < 0._kdp) THEN           ! ... net outflow
                 qfzonp_rbc(izn) = qfzonp_rbc(izn) - ufdt1*qfrbc(lc)
                 qfzonp(izn) = qfzonp(izn) - ufdt1*qfrbc(lc)
                 DO  iis=min_is,ns
                    qszonp_rbc(iis,izn) = qszonp_rbc(iis,izn) - ufdt1*qsrbc(lc,iis)
                    qszonp(iis,izn) = qszonp(iis,izn) - ufdt1*qsrbc(lc,iis)
                 END DO
              ELSEIF(qfrbc(lc) > 0._kdp) THEN        ! ... net inflow
                 qfzoni_rbc(izn) = qfzoni_rbc(izn) + ufdt1*qfrbc(lc)
                 qfzoni(izn) = qfzoni(izn) + ufdt1*qfrbc(lc)
                 DO  iis=min_is,ns
                    qszoni_rbc(iis,izn) = qszoni_rbc(iis,izn) + ufdt1*qsrbc(lc,iis)
                    qszoni(iis,izn) = qszoni(iis,izn) + ufdt1*qsrbc(lc,iis)
                 END DO
              ENDIF
           END IF
        END DO
     END IF
     IF(ndbc > 0) THEN
        ! ... Drain leakage b.c.
        DO ilc=1,lnk_bc2zon(izn,4)%num_bc
           lc = lnk_bc2zon(izn,4)%lcell_no(ilc)
           qfzonp_dbc(izn) = qfzonp_dbc(izn) - ufdt1*qfdbc(lc)
           qfzonp(izn) = qfzonp(izn) - ufdt1*qfdbc(lc)
           DO  iis=min_is,ns
              qszonp_dbc(iis,izn) = qszonp_dbc(iis,izn) - ufdt1*qsdbc(lc,iis)
              qszonp(iis,izn) = qszonp(iis,izn) - ufdt1*qsdbc(lc,iis)
           END DO
        END DO
     END IF
     IF(nwel > 0) THEN
        ! ... Wells
        DO ilc=1,seg_well(izn)%num_wellseg
           iwel = seg_well(izn)%iwel_no(ilc)
           ks = seg_well(izn)%ks_no(ilc)
           IF(qflyr(iwel,ks) < 0._kdp) THEN           ! ... Production segment
              qfzonp_wel(izn) = qfzonp_wel(izn) - ufdt1*qflyr(iwel,ks)
              qfzonp(izn) = qfzonp(izn) - ufdt1*qflyr(iwel,ks)
              DO  iis=min_is,ns
                 qszonp_wel(iis,izn) = qszonp_wel(iis,izn) - ufdt1*qslyr(iwel,ks,iis)
                 qszonp(iis,izn) = qszonp(iis,izn) - ufdt1*qslyr(iwel,ks,iis)
              END DO
           ELSE                                       ! ... Injection segment
              qfzoni_wel(izn) = qfzoni_wel(izn) + ufdt1*qflyr(iwel,ks)
              qfzoni(izn) = qfzoni(izn) + ufdt1*qflyr(iwel,ks)
              DO  iis=min_is,ns
                 qszoni_wel(iis,izn) = qszoni_wel(iis,izn) + ufdt1*qslyr(iwel,ks,iis)
                 qszoni(iis,izn) = qszoni(iis,izn) + ufdt1*qslyr(iwel,ks,iis)
              END DO
           END IF
        END DO
     END IF
  END DO

CONTAINS

  FUNCTION crdf1(xtc,x2p,x1p,x2,x1,x2m,x1m,dxxp,dxxm,wt) RESULT (cross_flux)
    ! ... Function for cross derivative dispersive flux term
    IMPLICIT NONE
    REAL(KIND=kdp) :: cross_flux
    REAL(KIND=kdp), INTENT(IN) :: x1, x2, x1m, x2m, x1p, x2p, xtc, dxxp, dxxm, wt
    ! ...
    cross_flux = xtc*0.5_kdp*(wt*(x2p+x1p-x2-x1)/dxxp + (1._kdp-wt)*(x2+x1-x2m-x1m)/dxxm)
  END FUNCTION crdf1

  FUNCTION xdcellno(i,j,k) RESULT (mm)
    ! ... Function for cross-dispersion cell number
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: i, j, k
    INTEGER :: mm
    ! ...
    mm = 0
    IF(xd_mask(i,j,k)) mm = cellno(i,j,k)
  END FUNCTION xdcellno

END SUBROUTINE zone_flow

SUBROUTINE zone_flow_write_heads
  ! ... Writes heads for zones 
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb2_m
  USE mcch
  USE mcg
  USE mcn, ONLY: x, y, z
  USE mcp
  USE mcv
  USE mg2_m, ONLY: hdprnt
!!$  USE phys_const
  IMPLICIT NONE
  INTEGER :: ios
  INTEGER :: i, ii, jj, kk, m, izn
  REAL(KIND=kdp) :: current_time = 0
  INTEGER :: counter = 1
  SAVE current_time, counter
  CHARACTER * 130 file_name_base, file_name
  !     ------------------------------------------------------------------
  current_time = cnvtmi*time
  DO izn = 1, num_flo_zones
     IF (zone_write_heads(izn)) THEN
        file_name_base = zone_filename_heads(izn)
        file_name = trim(file_name_base) // ".heads.xyzt"
        IF (counter == 1) THEN
           ! ... delete file on first write
           OPEN(fuzf_heads,FILE=file_name,IOSTAT=ios,ACTION='WRITE',STATUS='REPLACE')
           WRITE(fuzf_heads,"(a20,a20,a20,a13,a6,a1,a20)") "X","Y","Z","T(",TRIM(unittm),")","Head"
        ELSE
           OPEN(fuzf_heads,FILE=file_name,IOSTAT=ios,ACTION='WRITE',POSITION='APPEND')
        ENDIF
        DO i = 1, zone_col(izn)%num_xycol
           ii = zone_col(izn)%i_no(i)
           jj = zone_col(izn)%j_no(i)
           DO kk = zone_col(izn)%kmin_no(i), zone_col(izn)%kmax_no(i)
              m = ii + (jj-1)*nx + (kk-1)*nxy
              IF (frac(m) > 0.0)THEN
                 WRITE(fuzf_heads,"(5(G20.10,A1))") cnvli*x(ii),ACHAR(9),cnvli*y(jj),ACHAR(9),cnvli*z(kk),  &
                      ACHAR(9),current_time,ACHAR(9),cnvli*hdprnt(m),ACHAR(9)      
              ENDIF
           END DO
        END DO
        CLOSE(fuzf_heads, status='KEEP')
     ENDIF
  END DO
  counter = counter + 1

END SUBROUTINE zone_flow_write_heads
SUBROUTINE zone_flow_write_chem
  ! ... Writes solution_raw for zones for zones 
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb2_m
  USE mcc
  USE mcc_m
  USE mcch
  USE mcg
  USE mcn, ONLY: x, y, z
  USE mcp
  USE mcv
  USE mpi_mod
  USE print_control_mod
  IMPLICIT NONE
  INTEGER ios
  INTEGER i, ii, jj, kk, m, izn
  REAL(KIND=kdp) :: current_time = 0
  INTEGER :: counter = 1
  INTEGER :: solution_number, solution_number_start, bc_soln_count
  SAVE current_time, counter, solution_number_start
  CHARACTER * 130 file_name_base, file_name
  INTEGER solution_list(nxyz), pos
 
  IF (.not. solute) RETURN
  if (print_zone_flows_xyzt%print_flag_integer == 0) return

  current_time = cnvtmi*time
  if (counter == 1) then
    solution_number_start = 10000000
  endif
  bc_soln_count = 1
  do izn = 1, num_flo_zones
      if (zone_write_heads(izn)) then
          file_name_base = zone_filename_heads(izn)
          if (counter == 1) then
              ! delete file on first write
              ! xyzt file
              file_name = trim(file_name_base) // ".soln.xyzt"
              OPEN(fuzf_chem_xyzt,FILE=file_name,IOSTAT=ios,ACTION='WRITE',STATUS='REPLACE')
              write(fuzf_chem_xyzt,"(a20,a20,a20,a13,a6,a1,a20)") "X","Y","Z","T(",TRIM(unittm),")","Soln_no"
              ! chem raw file
              file_name = trim(file_name_base) // ".soln.bc"
              OPEN(fuzf_chem_raw,FILE=file_name,IOSTAT=ios,ACTION='WRITE',STATUS='REPLACE')
              CLOSE(fuzf_chem_raw)
          else
              ! xyzt file
              file_name = trim(file_name_base) // ".soln.xyzt"
              OPEN(fuzf_chem_xyzt,FILE=file_name,IOSTAT=ios,ACTION='WRITE',POSITION='APPEND')
          endif

          solution_number = solution_number_start
          do i = 1, zone_col(izn)%num_xycol
              ii = zone_col(izn)%i_no(i)
              jj = zone_col(izn)%j_no(i)
              do kk = zone_col(izn)%kmin_no(i), zone_col(izn)%kmax_no(i)
                  m = ii + (jj-1)*nx + (kk-1)*nxy
                  if (frac(m) > 0.0) then
                      write(fuzf_chem_xyzt,"(4(G20.10,A1), I20, A1, A15, I10)") cnvli*x(ii), &
                      ACHAR(9),cnvli*y(jj),ACHAR(9),cnvli*z(kk), &
                      ACHAR(9),current_time,ACHAR(9),solution_number,ACHAR(9), &
                      "# Fortran cell ",m 
                      solution_number = solution_number + 1
                      solution_list(bc_soln_count) = m
                      bc_soln_count = bc_soln_count + 1
                  endif
              end do
          end do
          
          ! write raw solutions to file
          file_name = trim(file_name_base) // ".soln.bc"         
          CALL FH_WriteBcRaw(rm_id, c, solution_list, bc_soln_count - 1, solution_number_start, file_name)

          ! finish xyzt file
          CLOSE(fuzf_chem_xyzt, status='KEEP')
          solution_number_start = solution_number
      endif
  end do

  counter = counter + 1

END SUBROUTINE zone_flow_write_chem