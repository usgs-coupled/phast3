SUBROUTINE crsdsp(m,ucrosc,ucrost)
  ! ... Calculates cross-dispersion terms for both heat and solute equations
  ! ... Explicit in time but iteratively updated
  ! ... Called for each cell
  USE machine_constants, ONLY: kdp
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcv
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: m
  REAL(KIND=kdp), INTENT(OUT) :: ucrosc, ucrost
  !
  INTEGER :: i, j, k, mijmkm, mijmkp, mijpkm, mijpkp, mimjkm,  &
       mimjkp, mimjmk, mimjpk, mipjkm, mipjkp, mipjmk, mipjpk
  REAL(KIND=kdp) :: ftxydm, ftxydp, ftxzdm, ftxzdp, ftyxdm, ftyxdp,  &
       ftyzdm, ftyzdp, ftzxdm, ftzxdp, ftzydm, ftzydp,  &
       dxm, dxp, dym, dyp, dzm, dzp, wtx, wty, wtz
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
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
  ucrost = 0._kdp
!!$  IF(heat) THEN
!!$     ! ... Heat equation terms
!!$     ftxydp=0._kdp
!!$     ftxydm=0._kdp
!!$     ftxzdp=0._kdp
!!$     ftxzdm=0._kdp
!!$     ftyxdp=0._kdp
!!$     ftyxdm=0._kdp
!!$     ftyzdp=0._kdp
!!$     ftyzdm=0._kdp
!!$     ftzxdp=0._kdp
!!$     ftzxdm=0._kdp
!!$     ftzydp=0._kdp
!!$     ftzydm=0._kdp
  ! ... If any of the 6 nodes needed for a gradient are excluded, 
  ! ...      that flux term is zero.
!!$     ! ... x-direction
!!$     IF(mijmk > 0.AND.mijpk > 0) THEN
!!$        IF(mipjk > 0) ftxydp=crdf1(thxy(m),tnp(mipjpk),tnp(mijpk),  &
!!$             tnp(mipjmk),tnp(mijmk))
!!$        IF(mimjk > 0) ftxydm=crdf1(thxy(m-1),tnp(mijpk),  &
!!$             tnp(mimjpk),tnp(mijmk),tnp(mimjmk))
!!$     END IF
!!$     IF(mijkm > 0.AND.mijkp > 0) THEN
!!$        IF(mipjk > 0) ftxzdp=crdf1(thxz(m),tnp(mipjkp),tnp(mijkp),  &
!!$             tnp(mipjkm),tnp(mijkm))
!!$        IF(mimjk > 0) ftxzdm=crdf1(thxz(m-1),tnp(mijkp),  &
!!$             tnp(mimjkp),tnp(mijkm),tnp(mimjkm))
!!$     END IF
!!$     ! ... y-direction
!!$     IF(mimjk > 0.AND.mipjk > 0) THEN
!!$        IF(mijpk > 0) ftyxdp=crdf1(thyx(m),tnp(mipjpk),tnp(mipjk),  &
!!$             tnp(mimjpk),tnp(mimjk))
!!$        IF(mijmk > 0) ftyxdm=crdf1(thyx(mijmk),tnp(mipjk),  &
!!$             tnp(mipjmk),tnp(mimjk),tnp(mimjmk))
!!$     END IF
!!$     IF (mijkm > 0.AND.mijkp > 0) THEN
!!$        IF(mijpk > 0) ftyzdp=crdf1(thyz(m),tnp(mijpkp),tnp(mijkp),  &
!!$             tnp(mijpkm),tnp(mijkm))
!!$        IF(mijmk > 0) ftyzdm=crdf1(thyz(mijmk),tnp(mijkp),  &
!!$             tnp(mijmkp),tnp(mijkm),tnp(mijmkm))
!!$     END IF
!!$     ! ... z-direction
!!$     IF(mimjk > 0.AND.mipjk > 0) THEN
!!$        IF(mijkp > 0) ftzxdp=crdf1(thzx(m),tnp(mipjkp),tnp(mipjk),  &
!!$             tnp(mimjkp),tnp(mimjk))
!!$        IF(mijkm > 0) ftzxdm=crdf1(thzx(mijkm),tnp(mipjk),  &
!!$             tnp(mipjkm),tnp(mimjk),tnp(mimjkm))
!!$     END IF
!!$     IF(mijmk > 0.AND.mijpk > 0) THEN
!!$        IF(mijkp > 0) ftzydp=crdf1(thzy(m),tnp(mijpkp),tnp(mijpk),  &
!!$             tnp(mijmkp),tnp(mijmk))
!!$        IF(mijkm > 0) ftzydm=crdf1(thzy(mijkm),tnp(mijpk),  &
!!$             tnp(mijpkm),tnp(mijmk),tnp(mijmkm))
!!$     END IF
!!$     ucrost=ftxydp+ftxzdp+ftyxdp+ftyzdp+ftzxdp+  &
!!$          ftzydp-ftxydm-ftxzdm-ftyxdm-ftyzdm-ftzxdm-ftzydm
!!$  END IF
  ucrosc = 0._kdp
  IF(solute) THEN
     ! ... Solute equation terms
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
             ftxydp=crdf1(tsxy(m),cnp(mipjpk,is),cnp(mijpk,is),  &
             cnp(mipjk,is),cnp(m,is),cnp(mipjmk,is),cnp(mijmk,is),dyp,dym,wty)
        IF(mimjk > 0 .AND. mimjpk > 0 .AND. mimjmk > 0)  &
             ftxydm=crdf1(tsxy(m-1),cnp(mijpk,is),cnp(mimjpk,is),  &
             cnp(m,is),cnp(mimjk,is),cnp(mijmk,is),cnp(mimjmk,is),dyp,dym,wty)
     END IF
     IF(mijkm > 0 .AND. mijkp > 0) THEN
        dzp = z(k+1)-z(k)
        dzm = z(k)-z(k-1)
        wtz = dzm/(dzm+dzp)
        IF(mipjk > 0 .AND. mipjkp > 0 .AND. mipjkm > 0)  &
             ftxzdp=crdf1(tsxz(m),cnp(mipjkp,is),cnp(mijkp,is),  &
             cnp(mipjk,is),cnp(m,is),cnp(mipjkm,is),cnp(mijkm,is),dzp,dzm,wtz)
        IF(mimjk > 0 .AND. mimjkp > 0 .AND. mimjkm > 0)  &
             ftxzdm=crdf1(tsxz(m-1),cnp(mijkp,is),cnp(mimjkp,is),  &
             cnp(m,is),cnp(mimjk,is),cnp(mijkm,is),cnp(mimjkm,is),dzp,dzm,wtz)
     END IF
     ! ... y-direction
     IF(mimjk > 0 .AND. mipjk > 0) THEN
        dxp = x(i+1)-x(i)
        dxm = x(i)-x(i-1)
        wtx = dxm/(dxm+dxp)
        IF(mijpk > 0 .AND. mipjpk > 0 .AND. mimjpk > 0)  &
             ftyxdp=crdf1(tsyx(m),cnp(mipjpk,is),cnp(mipjk,is),  &
             cnp(mijpk,is),cnp(m,is),cnp(mimjpk,is),cnp(mimjk,is),dxp,dxm,wtx)
        IF(mijmk > 0 .AND. mipjmk > 0 .AND. mimjmk > 0)  &
             ftyxdm=crdf1(tsyx(mijmk),cnp(mipjk,is),cnp(mipjmk,is),  &
             cnp(m,is),cnp(mijmk,is),cnp(mimjk,is),cnp(mimjmk,is),dxp,dxm,wtx)
     END IF
     IF(mijkm > 0 .AND. mijkp > 0) THEN
        dzp = z(k+1)-z(k)
        dzm = z(k)-z(k-1)
        wtz = dzm/(dzm+dzp)
        IF(mijpk > 0 .AND. mijpkp > 0 .AND. mijpkm > 0)  &
             ftyzdp=crdf1(tsyz(m),cnp(mijpkp,is),cnp(mijkp,is),  &
             cnp(mijpk,is),cnp(m,is),cnp(mijpkm,is),cnp(mijkm,is),dzp,dzm,wtz)
        IF(mijmk > 0 .AND. mijmkp > 0 .AND. mijmkm > 0)  &
             ftyzdm=crdf1(tsyz(mijmk),cnp(mijkp,is),cnp(mijmkp,is),  &
             cnp(m,is),cnp(mijmk,is),cnp(mijkm,is),cnp(mijmkm,is),dzp,dzm,wtz)
     END IF
     ! ... z-direction
     IF(mimjk > 0 .AND. mipjk > 0) THEN
        dxp = x(i+1)-x(i)
        dxm = x(i)-x(i-1)
        wtx = dxm/(dxm+dxp)
        IF(mijkp > 0 .AND. mipjkp > 0 .AND. mimjkp > 0)  &
             ftzxdp=crdf1(tszx(m),cnp(mipjkp,is),cnp(mipjk,is),  &
             cnp(mijkp,is),cnp(m,is),cnp(mimjkp,is),cnp(mimjk,is),dxp,dxm,wtx)
        IF(mijkm > 0 .AND. mipjkm > 0 .AND. mimjkm > 0)  &
             ftzxdm=crdf1(tszx(mijkm),cnp(mipjk,is),cnp(mipjkm,is),  &
             cnp(m,is),cnp(mijkm,is),cnp(mimjk,is),cnp(mimjkm,is),dxp,dxm,wtx)
     END IF
     IF(mijmk > 0 .AND. mijpk > 0) THEN
        dyp = y(j+1)-y(j)
        dym = y(j)-y(j-1)
        wty = dym/(dym+dyp)
        IF(mijkp > 0 .AND. mijpkp > 0 .AND. mijmkp > 0)  &
             ftzydp=crdf1(tszy(m),cnp(mijpkp,is), cnp(mijpk,is),  &
             cnp(mijkp,is),cnp(m,is),cnp(mijmkp,is),cnp(mijmk,is),dyp,dym,wty)
        IF(mijkm > 0 .AND. mijpkm > 0 .AND. mijmkm > 0)  &
             ftzydm=crdf1(tszy(mijkm),cnp(mijpk,is),cnp(mijpkm,is),  &
             cnp(m,is),cnp(mijkm,is),cnp(mijmk,is),cnp(mijmkm,is),dyp,dym,wty)
     END IF
     ucrosc = ftxydp+ftxzdp+ftyxdp+ftyzdp+ftzxdp+ftzydp-  &
          ftxydm-ftxzdm-ftyxdm-ftyzdm-ftzxdm-ftzydm
  END IF

  CONTAINS

    FUNCTION cnp(mm,is) result (c_np)
      ! ... Function for updated mass fraction
      INTEGER, INTENT(IN) :: mm, is
      REAL(KIND=kdp) :: c_np
      ! ...
      c_np = c(mm,is) + dc(mm,is)
    END FUNCTION cnp

!!$    FUNCTION tnp(mm) RESULT (t_np)
!!$      ! ... Function for updated temperature
!!$      INTEGER, INTENT(IN) :: mm
!!$      REAL(KIND=kdp) :: t_np
!!$      ! ...
!!$      t_np = t(mm) + dt(mm)
!!$    END FUNCTION tnp

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

END SUBROUTINE crsdsp
