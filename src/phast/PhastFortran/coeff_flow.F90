SUBROUTINE coeff_flow
  ! ... Calculates conductances, mass flow rates, and velocities
  ! ...      for the flow equation
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE phys_const
  IMPLICIT NONE
  INTEGER :: i, imm, ipmz, j, k, m, mijmkp, mijpkm, mimjkp, mimjpk, mipjkm, mipjmk,  &
       mipjpk, mipjkp, mijpkp
  INTEGER, DIMENSION(4) :: mm
  LOGICAL :: ierrw
  REAL(KIND=kdp) :: tdx, tdxy, tdxz, tdy, tdyx, tdyz, tdz, tdzx,  &
       tdzy, u1, u2, u3, uden, udx, udxdy, udxdyi, udxdyo, udxdz,  &
       udy, udydz, udz, ufr, ufrac, updxdy, updxdz, updydz, uvel, uvis
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: coeff_flow.F90,v 1.1 2013/09/19 20:41:58 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Prepare to calculate conductances
  ! ... Zero the interfacial conductance and mass flow rate arrays and
  ! ...      interstitial velocity arrays
  tfx = 0._kdp
  tfy = 0._kdp
  tfz = 0._kdp
  sxx = 0._kdp
  syy = 0._kdp
  szz = 0._kdp
  vxx = 0._kdp
  vyy = 0._kdp
  vzz = 0._kdp
  DO  ipmz=1,npmz
     DO  k=k1z(ipmz),k2z(ipmz)
        DO  j=j1z(ipmz),j2z(ipmz)
           DO  i=i1z(ipmz),i2z(ipmz)
              m=cellno(i,j,k)
              IF(ibc(m) /= -1 .AND. frac(m) > 0.) THEN
                 ! ... X-direction conductances, mass flow rates, interstitial velocities
                 IF(i == i2z(ipmz)) GO TO 20
                 IF(ibc(m+1) == -1 .OR. frac(m+1) <= 0.) GO TO 20
                 ! ... Values at cell boundary
                 uden = den0
                 uvis = vis0
                 ufrac = 1._kdp
                 IF(fresur) ufrac = .5*(frac(m)+frac(m+1))
                 tfx(m) = tx(m)*uden*ufrac/uvis
                 sxx(m) = -tfx(m)*((p(m+1)-p(m))+ uden*gx*(x(i+1)-x(i)))
                 vxx(m) = sxx(m)/(uden*ufrac*arx(m))
20               IF(j == j2z(ipmz) .OR. cylind) GO TO 30
                 ! ... Y-direction conductances, mass flow rates, interstitial velocities
                 mijpk=m+nx
                 IF(ibc(mijpk) == -1 .OR. frac(mijpk) <= 0.) GO TO 30
                 uden = den0
                 uvis = vis0
                 ufrac=1._kdp
                 IF(fresur) ufrac=.5*(frac(m)+frac(mijpk))
                 tfy(m)=ty(m)*uden*ufrac/uvis
                 syy(m)=-tfy(m)*((p(mijpk)-p(m))+ uden*gy*(y(j+1)-y(j)))
                 vyy(m)=syy(m)/(uden*ufrac*ary(m))
30               IF(k == k2z(ipmz)) CYCLE
                 ! ... Z-direction conductances, mass flow rates, interstitial velocities
                 mijkp=m+nxy
                 IF(ibc(mijkp) == -1 .OR. frac(mijkp) <= 0._kdp .OR. frac(m) < 1._kdp) CYCLE
                 uden = den0
                 uvis = vis0
                 tfz(m)=tz(m)*uden/uvis
                 szz(m)=-tfz(m)*((p(mijkp)-p(m))+ uden*gz*(z(k+1)-z(k)))
                 vzz(m)=szz(m)/(uden*arz(m))
              END IF
           END DO
        END DO
     END DO
  END DO

END SUBROUTINE coeff_flow
