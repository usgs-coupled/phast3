SUBROUTINE asembl_flow
  ! ... Assembles the matrix coefficients and right hand side vector
  ! ...      for the flow equation
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
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
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  IMPLICIT NONE
  CHARACTER (LEN=9) :: cibc
  REAL(KIND=kdp) :: cmx, cmy, cmz, cpx, cpy, cpz, dpmkm, dpmkp,  &
       dx1, dx2, ehmx, ehmy, ehmz, ehpx, ehpy,  &
       ehpz, fracnzkp,  & 
       pmkm, pmkp, sxxm, sxxp, syym, syyp, szzm, szzp, tfxm, tfxp, tfym,  &
       tfyp, tfzm, tfzp,  &
       ur1, ur2,  &
       urh, urs, utxm, utxp, utym, utyp, utzm, utzp, wtmx, wtmy,  &
       wtmz, wtpx, wtpy, wtpz, zkm, zkp
  INTEGER :: a_err, da_err, i, ibckm, ibckp, ic, j, k, m, ma, nsa
  INTEGER, PARAMETER :: icxm = 3, icxp = 4, icym = 2, icyp = 5, iczm = 1, iczp = 6
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: asembl_flow.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Compute and assemble coefficients in difference equations
  ! ...      cell-by-cell
  DO  m=1,nxyz
     ma=mrno(m)
     svbc=.false.
     DO  ic=1,6
        va(ic,ma)=0._kdp
     END DO
     ! ... Solve trivial equation for excluded cells, direct and iterative solvers
     IF(ibc(m) == -1) THEN
        va(7,ma)=1._kdp
        rhs(ma)=0._kdp
        CYCLE
     END IF
     WRITE(cibc,6001) ibc(m)
6001 FORMAT(i9.9)
     ! ... Conductances and free-surface b.c. treated explicitly
     ! ... Skip dry cells, unless they are specified value b.c.
     IF((ieq == 1 .AND. cibc(1:1) /= '1') .AND. frac(m) <= 0.) CYCLE
     ! ... Decode M into K
     CALL mtoijk(m,i,j,k,nx,ny)
     tfxm=0._kdp
     sxxm=0._kdp
     mimjk=ABS(cin(3,m))
     IF(mimjk > 0) THEN
        tfxm=tfx(mimjk)
        sxxm=sxx(mimjk)
        ! ... Calculate the weights
        wtmx=fdsmth
        IF(sxxm < 0.) wtmx=1._kdp-wtmx
     END IF
     tfxp=0._kdp
     sxxp=0._kdp
     mipjk=ABS(cin(4,m))
     IF(mipjk > 0) THEN
        tfxp=tfx(m)
        sxxp=sxx(m)
        wtpx=fdsmth
        IF(sxxp < 0.) wtpx=1._kdp-wtpx
     END IF
     tfym=0._kdp
     syym=0._kdp
     mijmk=ABS(cin(2,m))
     IF(mijmk > 0) THEN
        tfym=tfy(mijmk)
        syym=syy(mijmk)
        wtmy=fdsmth
        IF(syym < 0.) wtmy=1._kdp-wtmy
     END IF
     tfyp=0._kdp
     syyp=0._kdp
     mijpk=ABS(cin(5,m))
     IF(mijpk > 0) THEN
        tfyp=tfy(m)
        syyp=syy(m)
        wtpy=fdsmth
        IF(syyp < 0.) wtpy=1._kdp-wtpy
     END IF
     tfzm=0._kdp
     szzm=0._kdp
     dpmkm=0._kdp
     pmkm=0._kdp
     zkm=0._kdp
     ibckm = -1
     mijkm=ABS(cin(1,m))
     IF(mijkm > 0) THEN
        tfzm=tfz(mijkm)
        dpmkm=dp(mijkm)
        pmkm=p(mijkm)
        zkm=z(k-1)
        ibckm = ibc(mijkm)
        szzm=szz(mijkm)
        wtmz=fdsmth
        IF(szzm < 0.) wtmz=1._kdp-wtmz
     END IF
     tfzp=0._kdp
     szzp=0._kdp
     dpmkp=0._kdp
     pmkp=0._kdp
     zkp=0._kdp
     ibckp = -1
     fracnzkp = 0._kdp
     mijkp=ABS(cin(6,m))
     IF(mijkp > 0) THEN
        tfzp=tfz(m)
        dpmkp=dp(mijkp)
        pmkp=p(mijkp)
        zkp=z(k+1)
        ibckp = ibc(mijkp)
        fracnzkp = frac(mijkp)
        szzp=szz(m)
        wtpz=fdsmth
        IF(szzp < 0.) wtpz=1._kdp-wtpz
     END IF
     ! ... Zero coefficients are used to suppress equation terms that are
     ! ...      not present due to geometry of boundaries and/or equations
     ! ...      that are not being solved
     ! ... Flow equation
     IF(cibc(1:1) == '1') svbc=.true.
     !... component 1 has been arbitrarily chosen to calculate coefficients
     !... should not make any difference, these are zero anyway for constant
     !... density
     !....the f77 way
     CALL calcc(c(m,is),dc(m,is),den0,dp(m),dpmkm,dpmkp,  &
          dt(0),frac(m),fracnzkp,ibckm,ibckp,ieq,k,p(m),pmkm,pmkp,pmchv(1),  &
          pmcv(m),pmhv(1),pv(m),pvk(1),t(1),z(k),zkm,zkp,deltim)
     ! ... C34 and C35 are zero for SVBC and always for unmodified flow
     ! ...      equation (no Gauss elimination)
     va(7,ma)=c33
     urh=0._kdp
     urs=0._kdp
     utxm=0._kdp
     utxp=0._kdp
     utym=0._kdp
     utyp=0._kdp
     utzm=0._kdp
     utzp=0._kdp
     ! ... X-direction
     IF(mimjk > 0) THEN
        ehmx = 0._kdp
        urs = 0._kdp
        cmx = 0._kdp
        utxm = tfxm*(1._kdp+c34*cmx+c35*ehmx)
        va(icxm,ma) = -fdtmth*utxm
        va(7,ma) = va(7,ma)+fdtmth*utxm
        ! ... No terms for well in cylindrical system
     END IF
     IF(mipjk > 0) THEN
        ehpx = 0._kdp
        urs = 0._kdp
        cpx = 0._kdp
        utxp = tfxp*(1._kdp+c34*cpx+c35*ehpx)
        va(icxp,ma) = -fdtmth*utxp
        va(7,ma) = va(7,ma)+fdtmth*utxp
        CALL mtoijk(m,i,j,k,nx,ny)
        IF(cylind .AND. i == 1) THEN
           vaw(icxp,k) = -fdtmth*tfxp
           vaw(7,k) = vaw(7,k)+fdtmth*tfxp
        END IF
     END IF
     ! ... Y-direction
     IF(mijmk > 0) THEN
        ehmy = 0._kdp
        urs = 0._kdp
        cmy = 0._kdp
        utym = tfym*(1._kdp+c34*cmy+c35*ehmy)
        va(icym,ma) = -fdtmth*utym
        va(7,ma) = va(7,ma)+fdtmth*utym
     END IF
     IF(mijpk > 0) THEN
        ehpy = 0._kdp
        urs = 0._kdp
        cpy = 0._kdp
        utyp = tfyp*(1._kdp+c34*cpy+c35*ehpy)
        va(icyp,ma) = -fdtmth*utyp
        va(7,ma) = va(7,ma)+fdtmth*utyp
     END IF
     ! ... Z-direction
     IF(mijkm > 0) THEN
        ehmz = 0._kdp
        urs = 0._kdp
        cmz = 0._kdp
        utzm = tfzm*(1._kdp+c34*cmz+c35*ehmz)
        va(iczm,ma) = -fdtmth*utzm+cfp+c34*csp
        va(7,ma) = va(7,ma)+fdtmth*utzm
        IF(cylind .AND. i == 1) THEN
           vaw(iczm,k) = -fdtmth*tfzm
           vaw(7,k) = vaw(7,k)+fdtmth*tfzm
        END IF
     END IF
     IF(mijkp > 0) THEN
        ehpz = 0._kdp
        urs = 0._kdp
        cpz = 0._kdp
        utzp = tfzp*(1._kdp+c34*cpz+c35*ehpz)
        va(iczp,ma) = -fdtmth*utzp+efp+c34*esp
        va(7,ma) = va(7,ma)+fdtmth*utzp
        IF(cylind .AND. i == 1) THEN
           vaw(iczp,k) = -fdtmth*tfzp
           vaw(7,k) = vaw(7,k)+fdtmth*tfzp
        END IF
     END IF
     rhs(ma)=rf(m)
     IF(cylind .AND. i == 1) rhsw(k)=rf(m)-c31*dc(m,1)-c32*dt(0)
     ! ... End of flow equation terms
  END DO
END SUBROUTINE asembl_flow
