SUBROUTINE XP_asembl(xp)
  ! ... Assembles the matrix coefficients and right hand side vector
  ! ...      for the solute equation
  USE machine_constants, ONLY: kdp
  USE mcb, only: ibc
  USE mcc
  USE mcg
  USE mcm
  USE mcn, only: z
  USE mcp
  USE mcs, only: mrno, cin
  USE mcv
  USE XP_module
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  CHARACTER(LEN=9) :: cibc
  REAL(KIND=kdp) :: cmx, cmy, cmz, cpx, cpy, cpz, dpmkm, dpmkp, dsxxm, dsxxp,  &
       dsyym, dsyyp, dszzm, dszzp, dx1, dx2, ehmx, ehmy, ehmz, ehpx, ehpy,  &
       ehpz, fracnzkp,  & 
       pmkm, pmkp, sxxm, sxxp, syym, syyp, szzm, szzp, tfxm, tfxp, tfym,  &
       tfyp, tfzm, tfzp, thxm, thxp, thym, thyp, thzm, thzp,  &
       tsxm, tsxp, tsym, tsyp, tszm, tszp, ucrosc, ucrost, ur1, ur2,  &
       urh, urs, utxm, utxp, utym, utyp, utzm, utzp, wtmx, wtmy,  &
       wtmz, wtpx, wtpy, wtpz, zkm, zkp
  INTEGER :: a_err, da_err, i, ibckm, ibckp, ic, j, k, m, ma
  INTEGER, PARAMETER :: icxm = 3, icxp = 4, icym = 2, icyp = 5, iczm = 1, iczp = 6
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: XP_asembl.f90,v 1.2 2011/01/19 17:50:19 klkipp Exp $'
  !     ------------------------------------------------------------------
  ! ... Dimension rs1 to be for one component
  ALLOCATE (xp%rs1(nxyz),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: XP_asembl, number 0"  
     STOP
  ENDIF
  !...
  ! ... Compute and assemble coefficients in difference equations
  ! ...      cell-by-cell
  rhs = 0
  DO  m=1,nxyz
     ma = mrno(m)
     svbc = .false.
     DO  ic=1,7
        va(ic,ma) = 0._kdp
     END DO
     ! ... Solve trivial equation for excluded cells, direct and iterative solvers
     IF(ibc(m) == -1) THEN
        va(7,ma) = 1._kdp
        rhs(ma) = 0._kdp
        CYCLE
     END IF
     WRITE(cibc,6001) ibc(m)
6001 FORMAT(i9.9)
     ! ... Conductances and free-surface b.c. treated explicitly
     ! ... Skip dry cells, unless they are specified value b.c.
     IF(cibc(7:7) /= '1' .AND. frac(m) <= 0.) CYCLE
     ! ... Decode M into K
     CALL mtoijk(m,i,j,k,nx,ny)
     tsxm = 0._kdp
     sxxm = 0._kdp
     mimjk = ABS(cin(3,m))
     IF(mimjk > 0) THEN
        tfxm = tfx(mimjk)
        tsxm = tsx(mimjk)
        sxxm = sxx(mimjk)
!!$        ! ... Calculate the spatial weights
!!$        wtmx = fdsmth
!!$        IF(sxxm < 0.) wtmx = 1._kdp-wtmx
     END IF
     tfxp = 0._kdp
     tsxp = 0._kdp
     sxxp = 0._kdp
     mipjk = ABS(cin(4,m))
     IF(mipjk > 0) THEN
        tfxp = tfx(m)
        tsxp = tsx(m)
        sxxp = sxx(m)
!!$        wtpx = fdsmth
!!$        IF(sxxp < 0.) wtpx = 1._kdp-wtpx
     END IF
     tfym = 0._kdp
     tsym = 0._kdp
     syym = 0._kdp
     mijmk = ABS(cin(2,m))
     IF(mijmk > 0) THEN
        tfym = tfy(mijmk)
        tsym = tsy(mijmk)
        syym = syy(mijmk)
!!$        wtmy = fdsmth
!!$        IF(syym < 0.) wtmy = 1._kdp-wtmy
     END IF
     tfyp = 0._kdp
     tsyp = 0._kdp
     syyp = 0._kdp
     mijpk = ABS(cin(5,m))
     IF(mijpk > 0) THEN
        tfyp = tfy(m)
        tsyp = tsy(m)
        syyp = syy(m)
!!$        wtpy = fdsmth
!!$        IF(syyp < 0.) wtpy = 1._kdp-wtpy
     END IF
     tfzm = 0._kdp
     tszm = 0._kdp
     szzm = 0._kdp
     dpmkm = 0._kdp
     pmkm = 0._kdp
     zkm = 0._kdp
     ibckm = -1
     mijkm = ABS(cin(1,m))
     IF(mijkm > 0) THEN
        tfzm = tfz(mijkm)
        tszm = tsz(mijkm)
        dpmkm = dp(mijkm)
        pmkm = p(mijkm)
        zkm = z(k-1)
        ibckm  =  ibc(mijkm)
        szzm = szz(mijkm)
!!$        wtmz = fdsmth
!!$        IF(szzm < 0.) wtmz = 1._kdp-wtmz
     END IF
     tfzp = 0._kdp
     tszp = 0._kdp
     szzp = 0._kdp
     dpmkp = 0._kdp
     pmkp = 0._kdp
     zkp = 0._kdp
     ibckp = -1
     fracnzkp = 0._kdp
     mijkp = ABS(cin(6,m))
     IF(mijkp > 0) THEN
        tfzp = tfz(m)
        tszp = tsz(m)
        dpmkp = dp(mijkp)
        pmkp = p(mijkp)
        zkp = z(k+1)
        ibckp = ibc(mijkp)
        fracnzkp = frac(mijkp)
        szzp = szz(m)
!!$        wtpz = fdsmth
!!$        IF(szzp < 0.) wtpz = 1._kdp-wtpz
     END IF
     ! ... Zero coefficients are used to suppress equation terms that are
     ! ...      not present due to geometry of boundaries and/or equations
     ! ...      that are not being solved
     ! ... Solute equation
     ! ... Calculate C's with current p, w
     IF(cibc(7:7) == '1') svbc = .true.
     CALL calcc(xp%c_w(m),xp%dc(m),den0,dp(m),dpmkm,dpmkp,  &
          dt(0),frac(m),fracnzkp,ibckm,ibckp,ieq,k,p(m),pmkm,pmkp,pmchv(1),  &
          pmcv(m),pmhv(1),pv(m),pvk(1),t(1),z(k),zkm,zkp,deltim)
     va(7,ma) = c11
     utxm = 0._kdp
     utxp = 0._kdp
     utym = 0._kdp
     utyp = 0._kdp
     utzm = 0._kdp
     utzp = 0._kdp
     ur1 = 0._kdp
     ucrosc = 0._kdp
     IF(crosd) CALL XP_crsdsp(xp, m,ucrosc)
     ! ... Save RS with cross derivative dispersive flux terms
     xp%rs1(m) = xp%rs(m) + ucrosc
     ! ... X-direction
     IF(mimjk > 0) THEN
        dsxxm = -tfxm*(dp(m)-dp(mimjk))
        sxxm = sxxm + dsxxm
        wtmx = fdsmth
        IF(sxxm < 0.) wtmx = 1._kdp-wtmx
        ur1 = ur1+urf3(wtmx,xp%c_w(mimjk),xp%c_w(m),dsxxm)
        utxm = tsxm + (1._kdp-wtmx)*sxxm
        va(icxm,ma) = -fdtmth*utxm
        va(7,ma) = va(7,ma) + fdtmth*(tsxm-wtmx*sxxm)
     END IF
     IF(mipjk > 0) THEN
        dsxxp = -tfxp*(dp(mipjk)-dp(m))
        sxxp = sxxp + dsxxp
        wtpx = fdsmth
        IF(sxxp < 0.) wtpx = 1._kdp-wtpx
        ur1 = ur1-urf3(wtpx,xp%c_w(m),xp%c_w(mipjk),dsxxp)
        utxp = tsxp - wtpx*sxxp
        va(icxp,ma) = -fdtmth*utxp
        va(7,ma) = va(7,ma) + fdtmth*(tsxp+(1._kdp-wtpx)*sxxp)
     END IF
     ! ... Y-direction
     IF(mijmk > 0) THEN
        dsyym = -tfym*(dp(m)-dp(mijmk))
        syym = syym + dsyym
        wtmy = fdsmth
        IF(syym < 0.) wtmy = 1._kdp-wtmy
        ur1 = ur1+urf3(wtmy,xp%c_w(mijmk),xp%c_w(m),dsyym)
        utym = tsym + (1._kdp-wtmy)*syym
        va(icym,ma) = -fdtmth*utym
        va(7,ma) = va(7,ma)+fdtmth*(tsym-wtmy*syym)
     END IF
     IF(mijpk > 0) THEN
        dsyyp = -tfyp*(dp(mijpk)-dp(m))
        syyp = syyp + dsyyp
        wtpy = fdsmth
        IF(syyp < 0.) wtpy = 1._kdp-wtpy
        ur1 = ur1-urf3(wtpy,xp%c_w(m),xp%c_w(mijpk),dsyyp)
        utyp = tsyp - wtpy*syyp
        va(icyp,ma) = -fdtmth*utyp
        va(7,ma) = va(7,ma)+fdtmth*(tsyp+(1._kdp-wtpy)*syyp)
     END IF
     ! ... Z-direction
     IF(mijkm > 0) THEN
        dszzm = -tfzm*(dp(m)-dp(mijkm))
        szzm = szzm + dszzm
        wtmz = fdsmth
        IF(szzm < 0.) wtmz = 1._kdp-wtmz
        ur1 = ur1+urf3(wtmz,xp%c_w(mijkm),xp%c_w(m),dszzm)
        utzm = tszm + (1._kdp-wtmz)*szzm
        va(iczm,ma) = -fdtmth*utzm
        va(7,ma) = va(7,ma)+fdtmth*(tszm-wtmz*szzm)
     END IF
     IF(mijkp > 0) THEN
        dszzp = -tfzp*(dp(mijkp)-dp(m))
        szzp = szzp + dszzp
        wtpz = fdsmth
        IF(szzp < 0.) wtpz = 1._kdp-wtpz
        ur1 = ur1-urf3(wtpz,xp%c_w(m),xp%c_w(mijkp),dszzp)
        utzp = tszp-wtpz*szzp
        va(iczp,ma) = -fdtmth*utzp
        va(7,ma) = va(7,ma)+fdtmth*(tszp+(1._kdp-wtpz)*szzp)
     END IF
     rhs(ma) = xp%rs1(m)+fdtmth*ur1-c13*dp(m)-csp*dpmkm-esp*dpmkp
  END DO
  DEALLOCATE (xp%rs1,  &
       STAT  =  da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: XP_asembl"  
     STOP
  ENDIF

CONTAINS

  FUNCTION urf3(wt,x1,x2,v) RESULT (adv_flux)
    ! ...      Advective flux or change in advective flux
    REAL(KIND=kdp) :: adv_flux
    REAL(KIND=kdp), INTENT(IN) :: v, wt, x1, x2
    ! ...
    adv_flux = ((1._kdp-wt)*x1+wt*x2)*v
  END FUNCTION urf3

END SUBROUTINE XP_asembl
