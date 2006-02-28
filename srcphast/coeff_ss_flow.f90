SUBROUTINE coeff_ss_flow
  !NOT NEEDED FOR CONSTANT DENSITY FLOW
  ! ... Calculates conductances, velocities, and auto
  ! ...      time step
  ! ...      for the right hand side
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcv
  USE phys_const
  REAL(kind=kdp) :: uden, ufrac, uvis
  INTEGER :: i, ipmz, j, k, m
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Prepare to update conductances
  ! ... Zero the interfacial conductance and mass flow rate arrays 
     tfx = 0._kdp
     tfy = 0._kdp
     tfz = 0._kdp
     IF(solute) THEN
        tsx = 0._kdp
        tsy = 0._kdp
        tsz = 0._kdp
        tsxy = 0._kdp
        tsxz = 0._kdp
        tsyx = 0._kdp
        tsyz = 0._kdp
        tszx = 0._kdp
        tszy = 0._kdp
     END IF
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
              IF(ibc(m) /= -1.AND.frac(m) > 0.) THEN
                 ! ... X-direction conductances, mass flow rates, interstitial velocities
                 IF(i == i2z(ipmz)) GO TO 20
                 IF(ibc(m+1) == -1.OR.frac(m+1) <= 0.) GO TO 20
                 ! ... Values at cell boundary
                 uden=.5*(den(m)+den(m+1))
                 uvis=.5*(vis(m)+vis(m+1))
                 ufrac=1.d0
                 IF(fresur) ufrac=.5*(frac(m)+frac(m+1))
                 tfx(m)=tx(m)*uden*ufrac/uvis
                 sxx(m)=-tfx(m)*((p(m+1)-p(m))+ uden*gx*(x(i+1)-x(i)))
!                 vxx(m)=sxx(m)/(uden*ufrac*arx(m))
20               IF(j == j2z(ipmz).OR.cylind) GO TO 30
                 ! ... Y-direction conductances, mass flow rates, interstitial velocities
                 mijpk=m+nx
                 IF(ibc(mijpk) == -1.OR.frac(mijpk) <= 0.) GO TO 30
                 uden=.5*(den(m)+den(mijpk))
                 uvis=.5*(vis(m)+vis(mijpk))
                 ufrac=1.d0
                 IF(fresur) ufrac=.5*(frac(m)+frac(mijpk))
                 tfy(m)=ty(m)*uden*ufrac/uvis
                 syy(m)=-tfy(m)*((p(mijpk)-p(m))+ uden*gy*(y(j+1)-y(j)))
!                 vyy(m)=syy(m)/(uden*ufrac*ary(m))
30               IF(k == k2z(ipmz)) CYCLE
                 ! ... Z-direction conductances, mass flow rates, interstitial velocities
                 mijkp=m+nxy
                 IF(ibc(mijkp) == -1.OR.frac(mijkp) <= 0._kdp.OR.frac(m) < 1._kdp) CYCLE
                 uden=.5*(den(m)+den(mijkp))
                 uvis=.5*(vis(m)+vis(mijkp))
                 tfz(m)=tz(m)*uden/uvis
                 szz(m)=-tfz(m)*((p(mijkp)-p(m))+ uden*gz*(z(k+1)-z(k)))
!                 vzz(m)=szz(m)/(uden*arz(m))
              END IF
           END DO
        END DO
     END DO
  END DO
END SUBROUTINE coeff_ss_flow
