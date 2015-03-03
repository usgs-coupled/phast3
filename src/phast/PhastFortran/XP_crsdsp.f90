SUBROUTINE XP_crsdsp_thread(xp, m, ucrosc)
  ! ... Calculates cross-dispersion terms for solute equations
  ! ... Explicit in time but iteratively updated
  ! ... Called for each cell
  USE machine_constants, ONLY: kdp
  USE mcg, ONLY: nx, ny, cellno, xd_mask
  USE mcn, ONLY: x, y, z
  USE mcp, ONLY:
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTEGER, INTENT(IN) :: m
  REAL(KIND=kdp), INTENT(OUT) :: ucrosc
  !
  INTEGER :: i, j, k, mijmkm, mijmkp, mijpkm, mijpkp, mimjkm,  &
       mimjkp, mimjmk, mimjpk, mipjkm, mipjkp, mipjmk, mipjpk
  REAL(KIND=kdp) :: ftxydm, ftxydp, ftxzdm, ftxzdp, ftyxdm, ftyxdp,  &
       ftyzdm, ftyzdp, ftzxdm, ftzxdp, ftzydm, ftzydp,  &
       dxm, dxp, dym, dyp, dzm, dzp, wtx, wty, wtz
  INTEGER :: mijmk, mijpk, mipjk, mimjk, mijkm, mijkp
  !     ------------------------------------------------------------------
  !...
  ! ... Decode M into I,J,K
  CALL mtoijk(m,i,j,k,nx,ny)
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

  mijmk = xdcellno(i,j-1,k)
  mijpk = xdcellno(i,j+1,k)
  mipjk = xdcellno(i+1,j,k)
  mimjk = xdcellno(i-1,j,k)
  mijkm = xdcellno(i,j,k-1)
  mijkp = xdcellno(i,j,k+1)

  ucrosc = 0._kdp
  ftxydp = 0._kdp
  ftxydm = 0._kdp
  ftxzdp = 0._kdp
  ftxzdm = 0._kdp
  ftyxdp = 0._kdp
  ftyxdm = 0._kdp
  ftyzdp = 0._kdp
  ftyzdm = 0._kdp
  ftzxdp = 0._kdp
  ftzxdm = 0._kdp
  ftzydp = 0._kdp
  ftzydm = 0._kdp
  ! ... If any of the 6 nodes needed for a gradient are excluded, 
  ! ...      that flux term is zero.
  ! ... x-direction
  IF(mijmk > 0 .AND. mijpk > 0) THEN
     dyp = y(j+1)-y(j)
     dym = y(j)-y(j-1)
     wty = dym/(dym+dyp)
     IF(mipjk > 0 .AND. mipjpk > 0 .AND. mipjmk > 0)  &
          ftxydp=crdf1(xp%tsxy(m),cnp(mipjpk),cnp(mijpk),  &
          cnp(mipjk),cnp(m),cnp(mipjmk),cnp(mijmk),dyp,dym,wty)
     IF(mimjk > 0 .AND. mimjpk > 0 .AND. mimjmk > 0)  &
          ftxydm=crdf1(xp%tsxy(m-1),cnp(mijpk),cnp(mimjpk),  &
          cnp(m),cnp(mimjk),cnp(mijmk),cnp(mimjmk),dyp,dym,wty)
  END IF
  IF(mijkm > 0 .AND. mijkp > 0) THEN
     dzp = z(k+1)-z(k)
     dzm = z(k)-z(k-1)
     wtz = dzm/(dzm+dzp)
     IF(mipjk > 0 .AND. mipjkp > 0 .AND. mipjkm > 0)  &
          ftxzdp=crdf1(xp%tsxz(m),cnp(mipjkp),cnp(mijkp),  &
          cnp(mipjk),cnp(m),cnp(mipjkm),cnp(mijkm),dzp,dzm,wtz)
     IF(mimjk > 0 .AND. mimjkp > 0 .AND. mimjkm > 0)  &
          ftxzdm=crdf1(xp%tsxz(m-1),cnp(mijkp),cnp(mimjkp),  &
          cnp(m),cnp(mimjk),cnp(mijkm),cnp(mimjkm),dzp,dzm,wtz)
  END IF
  ! ... y-direction
  IF(mimjk > 0 .AND. mipjk > 0) THEN
     dxp = x(i+1)-x(i)
     dxm = x(i)-x(i-1)
     wtx = dxm/(dxm+dxp)
     IF(mijpk > 0 .AND. mipjpk > 0 .AND. mimjpk > 0)  &
          ftyxdp=crdf1(xp%tsyx(m),cnp(mipjpk),cnp(mipjk),  &
          cnp(mijpk),cnp(m),cnp(mimjpk),cnp(mimjk),dxp,dxm,wtx)
     IF(mijmk > 0 .AND. mipjmk > 0 .AND. mimjmk > 0)  &
          ftyxdm=crdf1(xp%tsyx(mijmk),cnp(mipjk),cnp(mipjmk),  &
          cnp(m),cnp(mijmk),cnp(mimjk),cnp(mimjmk),dxp,dxm,wtx)
  END IF
  IF(mijkm > 0 .AND. mijkp > 0) THEN
     dzp = z(k+1)-z(k)
     dzm = z(k)-z(k-1)
     wtz = dzm/(dzm+dzp)
     IF(mijpk > 0 .AND. mijpkp > 0 .AND. mijpkm > 0)  &
          ftyzdp=crdf1(xp%tsyz(m),cnp(mijpkp),cnp(mijkp),  &
          cnp(mijpk),cnp(m),cnp(mijpkm),cnp(mijkm),dzp,dzm,wtz)
     IF(mijmk > 0 .AND. mijmkp > 0 .AND. mijmkm > 0)  &
          ftyzdm=crdf1(xp%tsyz(mijmk),cnp(mijkp),cnp(mijmkp),  &
          cnp(m),cnp(mijmk),cnp(mijkm),cnp(mijmkm),dzp,dzm,wtz)
  END IF
  ! ... z-direction
  IF(mimjk > 0 .AND. mipjk > 0) THEN
     dxp = x(i+1)-x(i)
     dxm = x(i)-x(i-1)
     wtx = dxm/(dxm+dxp)
     IF(mijkp > 0 .AND. mipjkp > 0 .AND. mimjkp > 0)  &
          ftzxdp=crdf1(xp%tszx(m),cnp(mipjkp),cnp(mipjk),  &
          cnp(mijkp),cnp(m),cnp(mimjkp),cnp(mimjk),dxp,dxm,wtx)
     IF(mijkm > 0 .AND. mipjkm > 0 .AND. mimjkm > 0)  &
          ftzxdm=crdf1(xp%tszx(mijkm),cnp(mipjk),cnp(mipjkm),  &
          cnp(m),cnp(mijkm),cnp(mimjk),cnp(mimjkm),dxp,dxm,wtx)
  END IF
  IF(mijmk > 0 .AND. mijpk > 0) THEN
     dyp = y(j+1)-y(j)
     dym = y(j)-y(j-1)
     wty = dym/(dym+dyp)
     IF(mijkp > 0 .AND. mijpkp > 0 .AND. mijmkp > 0)  &
          ftzydp=crdf1(xp%tszy(m),cnp(mijpkp), cnp(mijpk),  &
          cnp(mijkp),cnp(m),cnp(mijmkp),cnp(mijmk),dyp,dym,wty)
     IF(mijkm > 0 .AND. mijpkm > 0 .AND. mijmkm > 0)  &
          ftzydm=crdf1(xp%tszy(mijkm),cnp(mijpk),cnp(mijpkm),  &
          cnp(m),cnp(mijkm),cnp(mijmk),cnp(mijmkm),dyp,dym,wty)
  END IF
  ucrosc = ftxydp+ftxzdp+ftyxdp+ftyzdp+ftzxdp+ftzydp-  &
       ftxydm-ftxzdm-ftyxdm-ftyzdm-ftzxdm-ftzydm

CONTAINS

  FUNCTION cnp(mm) result (c_np)
    ! ... Function for updated mass fraction
    INTEGER, INTENT(IN) :: mm
    REAL(KIND=kdp) :: c_np
    ! ...
    c_np = xp%c_w(mm) + xp%dc(mm)
  END FUNCTION cnp

  FUNCTION crdf1(xtc,x2p,x1p,x2,x1,x2m,x1m,dxxp,dxxm,wt) RESULT (cross_flux)
    ! ... Function for cross derivative dispersive flux term
    REAL(KIND=kdp) :: cross_flux
    REAL(KIND=kdp), INTENT(IN) :: x1, x2, x1m, x2m, x1p, x2p, xtc, dxxp, dxxm, wt
    ! ...
    cross_flux = xtc*0.5_kdp*(wt*(x2p+x1p-x2-x1)/dxxp + (1._kdp-wt)*(x2+x1-x2m-x1m)/dxxm)
  END FUNCTION crdf1


  FUNCTION xdcellno(i,j,k) RESULT (mm)
    ! ... Function for cross-dispersion cell number
    INTEGER, INTENT(IN) :: i,j,k
    INTEGER :: mm
    ! ...
    mm = 0
    IF(xd_mask(i,j,k)) mm = cellno(i,j,k)
  END FUNCTION xdcellno

END SUBROUTINE XP_crsdsp_thread
SUBROUTINE XP_crsdsp(xp, m, ucrosc)
  ! ... Calculates cross-dispersion terms for solute equations
  ! ... Explicit in time but iteratively updated
  ! ... Called for each cell
  USE machine_constants, ONLY: kdp
  USE mcg
  USE mcn
  USE mcp
  USE XP_module, only: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTEGER, INTENT(IN) :: m
  REAL(KIND=kdp), INTENT(OUT) :: ucrosc
  !
  INTEGER :: i, j, k, mijmkm, mijmkp, mijpkm, mijpkp, mimjkm,  &
       mimjkp, mimjmk, mimjpk, mipjkm, mipjkp, mipjmk, mipjpk
  REAL(KIND=kdp) :: ftxydm, ftxydp, ftxzdm, ftxzdp, ftyxdm, ftyxdp,  &
       ftyzdm, ftyzdp, ftzxdm, ftzxdp, ftzydm, ftzydp,  &
       dxm, dxp, dym, dyp, dzm, dzp, wtx, wty, wtz
  !     ------------------------------------------------------------------
  !...
  ! ... Decode M into I,J,K
  CALL mtoijk(m,i,j,k,nx,ny)
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
  ucrosc = 0._kdp
  ftxydp = 0._kdp
  ftxydm = 0._kdp
  ftxzdp = 0._kdp
  ftxzdm = 0._kdp
  ftyxdp = 0._kdp
  ftyxdm = 0._kdp
  ftyzdp = 0._kdp
  ftyzdm = 0._kdp
  ftzxdp = 0._kdp
  ftzxdm = 0._kdp
  ftzydp = 0._kdp
  ftzydm = 0._kdp
  ! ... If any of the 6 nodes needed for a gradient are excluded, 
  ! ...      that flux term is zero.
  ! ... x-direction
  IF(mijmk > 0 .AND. mijpk > 0) THEN
     dyp = y(j+1)-y(j)
     dym = y(j)-y(j-1)
     wty = dym/(dym+dyp)
     IF(mipjk > 0 .AND. mipjpk > 0 .AND. mipjmk > 0)  &
          ftxydp=crdf1(tsxy(m),cnp(mipjpk),cnp(mijpk),  &
          cnp(mipjk),cnp(m),cnp(mipjmk),cnp(mijmk),dyp,dym,wty)
     IF(mimjk > 0 .AND. mimjpk > 0 .AND. mimjmk > 0)  &
          ftxydm=crdf1(tsxy(m-1),cnp(mijpk),cnp(mimjpk),  &
          cnp(m),cnp(mimjk),cnp(mijmk),cnp(mimjmk),dyp,dym,wty)
  END IF
  IF(mijkm > 0 .AND. mijkp > 0) THEN
     dzp = z(k+1)-z(k)
     dzm = z(k)-z(k-1)
     wtz = dzm/(dzm+dzp)
     IF(mipjk > 0 .AND. mipjkp > 0 .AND. mipjkm > 0)  &
          ftxzdp=crdf1(tsxz(m),cnp(mipjkp),cnp(mijkp),  &
          cnp(mipjk),cnp(m),cnp(mipjkm),cnp(mijkm),dzp,dzm,wtz)
     IF(mimjk > 0 .AND. mimjkp > 0 .AND. mimjkm > 0)  &
          ftxzdm=crdf1(tsxz(m-1),cnp(mijkp),cnp(mimjkp),  &
          cnp(m),cnp(mimjk),cnp(mijkm),cnp(mimjkm),dzp,dzm,wtz)
  END IF
  ! ... y-direction
  IF(mimjk > 0 .AND. mipjk > 0) THEN
     dxp = x(i+1)-x(i)
     dxm = x(i)-x(i-1)
     wtx = dxm/(dxm+dxp)
     IF(mijpk > 0 .AND. mipjpk > 0 .AND. mimjpk > 0)  &
          ftyxdp=crdf1(tsyx(m),cnp(mipjpk),cnp(mipjk),  &
          cnp(mijpk),cnp(m),cnp(mimjpk),cnp(mimjk),dxp,dxm,wtx)
     IF(mijmk > 0 .AND. mipjmk > 0 .AND. mimjmk > 0)  &
          ftyxdm=crdf1(tsyx(mijmk),cnp(mipjk),cnp(mipjmk),  &
          cnp(m),cnp(mijmk),cnp(mimjk),cnp(mimjmk),dxp,dxm,wtx)
  END IF
  IF(mijkm > 0 .AND. mijkp > 0) THEN
     dzp = z(k+1)-z(k)
     dzm = z(k)-z(k-1)
     wtz = dzm/(dzm+dzp)
     IF(mijpk > 0 .AND. mijpkp > 0 .AND. mijpkm > 0)  &
          ftyzdp=crdf1(tsyz(m),cnp(mijpkp),cnp(mijkp),  &
          cnp(mijpk),cnp(m),cnp(mijpkm),cnp(mijkm),dzp,dzm,wtz)
     IF(mijmk > 0 .AND. mijmkp > 0 .AND. mijmkm > 0)  &
          ftyzdm=crdf1(tsyz(mijmk),cnp(mijkp),cnp(mijmkp),  &
          cnp(m),cnp(mijmk),cnp(mijkm),cnp(mijmkm),dzp,dzm,wtz)
  END IF
  ! ... z-direction
  IF(mimjk > 0 .AND. mipjk > 0) THEN
     dxp = x(i+1)-x(i)
     dxm = x(i)-x(i-1)
     wtx = dxm/(dxm+dxp)
     IF(mijkp > 0 .AND. mipjkp > 0 .AND. mimjkp > 0)  &
          ftzxdp=crdf1(tszx(m),cnp(mipjkp),cnp(mipjk),  &
          cnp(mijkp),cnp(m),cnp(mimjkp),cnp(mimjk),dxp,dxm,wtx)
     IF(mijkm > 0 .AND. mipjkm > 0 .AND. mimjkm > 0)  &
          ftzxdm=crdf1(tszx(mijkm),cnp(mipjk),cnp(mipjkm),  &
          cnp(m),cnp(mijkm),cnp(mimjk),cnp(mimjkm),dxp,dxm,wtx)
  END IF
  IF(mijmk > 0 .AND. mijpk > 0) THEN
     dyp = y(j+1)-y(j)
     dym = y(j)-y(j-1)
     wty = dym/(dym+dyp)
     IF(mijkp > 0 .AND. mijpkp > 0 .AND. mijmkp > 0)  &
          ftzydp=crdf1(tszy(m),cnp(mijpkp), cnp(mijpk),  &
          cnp(mijkp),cnp(m),cnp(mijmkp),cnp(mijmk),dyp,dym,wty)
     IF(mijkm > 0 .AND. mijpkm > 0 .AND. mijmkm > 0)  &
          ftzydm=crdf1(tszy(mijkm),cnp(mijpk),cnp(mijpkm),  &
          cnp(m),cnp(mijkm),cnp(mijmk),cnp(mijmkm),dyp,dym,wty)
  END IF
  ucrosc = ftxydp+ftxzdp+ftyxdp+ftyzdp+ftzxdp+ftzydp-  &
       ftxydm-ftxzdm-ftyxdm-ftyzdm-ftzxdm-ftzydm

CONTAINS

  FUNCTION cnp(mm) result (c_np)
    ! ... Function for updated mass fraction
    INTEGER, INTENT(IN) :: mm
    REAL(KIND=kdp) :: c_np
    ! ...
    c_np = xp%c_w(mm) + xp%dc(mm)
  END FUNCTION cnp

  FUNCTION crdf1(xtc,x2p,x1p,x2,x1,x2m,x1m,dxxp,dxxm,wt) RESULT (cross_flux)
    ! ... Function for cross derivative dispersive flux term
    REAL(KIND=kdp) :: cross_flux
    REAL(KIND=kdp), INTENT(IN) :: x1, x2, x1m, x2m, x1p, x2p, xtc, dxxp, dxxm, wt
    ! ...
    cross_flux = xtc*0.5_kdp*(wt*(x2p+x1p-x2-x1)/dxxp + (1._kdp-wt)*(x2+x1-x2m-x1m)/dxxm)
  END FUNCTION crdf1


  FUNCTION xdcellno(i,j,k) RESULT (mm)
    ! ... Function for cross-dispersion cell number
    INTEGER, INTENT(IN) :: i,j,k
    INTEGER :: mm
    ! ...
    mm = 0
    IF(xd_mask(i,j,k)) mm = cellno(i,j,k)
  END FUNCTION xdcellno

END SUBROUTINE XP_crsdsp
