SUBROUTINE coeff_trans
  ! ... Calculates conductances, mass flow rates, velocities,
  ! ...      and advection and dispersion coefficients
  ! ...      for the transport equation
  ! ... These values are at time n.
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcv
  USE phys_const
  IMPLICIT NONE
  INTEGER :: i, imm, ipmz, j, k, m, mijmkp, mijpkm, mimjkp, mimjpk, mipjkm, mipjmk,  &
       mipjpk, mipjkp, mijpkp
  INTEGER :: mpi_array_type
  INTEGER, DIMENSION(4) :: mm
  LOGICAL :: ierrw
  REAL(KIND=kdp) :: tdx, tdxy, tdxz, tdy, tdyx, tdyz, tdz, tdzx,  &
       tdzy, u1, u2, u3, uden, udx, udxdy, udxdyi, udxdyo, udxdz,  &
       udy, udydz, udz, ufr, ufrac, updxdy, updxdz, updydz, uvel, uvis
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: coeff_trans.F90,v 1.1 2011/01/28 21:59:03 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Prepare to update solute conductances
  ! ... Zero the interfacial conductance and mass flow rates
  tsx = 0._kdp
  tsy = 0._kdp
  tsz = 0._kdp
  tsxy = 0._kdp
  tsxz = 0._kdp
  tsyx = 0._kdp
  tsyz = 0._kdp
  tszx = 0._kdp
  tszy = 0._kdp

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
                 ufrac=1._kdp
                 IF(fresur) ufrac=.5*(frac(m)+frac(m+1))
                 !$$                 tfx(m)=tx(m)*uden*ufrac/uvis
                 sxx(m)=-tfx(m)*((p(m+1)-p(m)) + uden*gx*(x(i+1)-x(i)))
                 vxx(m)=sxx(m)/(uden*ufrac*arx(m))
20               IF(j == j2z(ipmz) .OR. cylind) GO TO 30
                 ! ... Y-direction conductances, mass flow rates, interstitial velocities
                 mijpk=m+nx
                 IF(ibc(mijpk) == -1 .OR. frac(mijpk) <= 0.) GO TO 30
                 uden = den0
                 uvis = vis0
                 ufrac=1._kdp
                 IF(fresur) ufrac=.5*(frac(m)+frac(mijpk))
                 !$$                 tfy(m)=ty(m)*uden*ufrac/uvis
                 syy(m)=-tfy(m)*((p(mijpk)-p(m)) + uden*gy*(y(j+1)-y(j)))
                 vyy(m)=syy(m)/(uden*ufrac*ary(m))
30               IF(k == k2z(ipmz)) CYCLE
                 ! ... Z-direction conductances, mass flow rates, interstitial velocities
                 mijkp=m+nxy
                 IF(ibc(mijkp) == -1 .OR. frac(mijkp) <= 0._kdp .OR. frac(m) < 1._kdp) CYCLE
                 uden = den0
                 uvis = vis0
                 !$$                 tfz(m)=tz(m)*uden/uvis
                 szz(m)=-tfz(m)*((p(mijkp)-p(m)) + uden*gz*(z(k+1)-z(k)))
                 vzz(m)=szz(m)/(uden*arz(m))
              END IF
           END DO
        END DO
     END DO
  END DO
  IF(thru) RETURN
  ! ... Calculate dispersion coefficients at cell boundaries by element
  DO  ipmz=1,npmz
     IF(.NOT.cylind) THEN
        ! ... Cartesian case
        DO  k=k1z(ipmz),k2z(ipmz)-1
           udz=z(k+1)-z(k)
           DO  j=j1z(ipmz),j2z(ipmz)-1
              udy=y(j+1)-y(j)
              udydz=udy*udz*.25
              updydz=poros(ipmz)*udydz
              DO  i=i1z(ipmz),i2z(ipmz)-1
                 udx=x(i+1)-x(i)
                 udxdz=udx*udz*.25
                 udxdy=udx*udy*.25
                 updxdz=poros(ipmz)*udxdz
                 updxdy=poros(ipmz)*udxdy
                 ! ... X-direction cell face
                 mm(1)=cellno(i,j,k)
                 mm(2)=cellno(i,j+1,k)
                 mm(3)=mm(2)+nxy
                 mm(4)=mm(1)+nxy
                 DO  imm=1,4     ! ... contributions of this element to 4 cell faces
                    m=mm(imm)
                    mipjk=m+1
                    IF(frac(m) <= 0. .OR. frac(mipjk) <= 0.) CYCLE
                    mijmk=m-nx
                    mipjmk=m+1-nx
                    mijkm=m-nxy
                    mipjkm=m+1-nxy
                    u1=vxx(m)
                    u2=0._kdp
                    u3=0._kdp
                    ! ... Interpolate y and z velocities to x face
                    IF(imm == 1 .OR. imm == 4) THEN
                       u2=.5*(vyy(m)+vyy(mipjk))
                    ELSE IF(imm == 2 .OR. imm == 3) THEN
                       u2=.5*(vyy(mijmk)+vyy(mipjmk))
                    END IF
                    IF(imm == 1 .OR. imm == 2) THEN
                       u3=.5*(vzz(m)+vzz(mipjk))
                    ELSE IF(imm == 3 .OR. imm == 4) THEN
                       u3=.5*(vzz(mijkm)+vzz(mipjkm))
                    END IF
                    uvel=SQRT(u1*u1+u2*u2+u3*u3)
                    tdx=0._kdp
                    tdxy=0._kdp
                    tdxz=0._kdp
                    IF(uvel > 0.) THEN
                       tdx=(alphl(ipmz)*u1*u1+alphth(ipmz)*(u2*u2)+alphtv(ipmz)*(u3*u3))/uvel
                       tdxy=(alphl(ipmz)-alphth(ipmz))*u1*u2/uvel
                       tdxz=(alphl(ipmz)-alphtv(ipmz))*u1*u3/uvel
                    END IF
                    ! ... Values at cell boundary face
                    uden = den0
                    ufrac=1._kdp
                    IF(fresur) ufrac =.5*(frac(m)+frac(mipjk))
                    tsx(m)=tsx(m)+(tdx+tort(ipmz)*dm)*uden*ufrac*updydz/udx
                    tsxy(m)=tsxy(m)+tdxy*uden*ufrac*updydz
                    tsxz(m)=tsxz(m)+tdxz*uden*ufrac*updydz
                 END DO
                 ! ... Y-direction cell face
                 mm(4)=mm(1)+1
                 mm(2)=mm(1)+nxy
                 mm(3)=mm(4)+nxy
                 DO  imm=1,4
                    m=mm(imm)
                    mijpk=m+nx
                    IF(frac(m) <= 0. .OR. frac(mijpk) <= 0.) CYCLE
                    mimjk=m-1
                    mimjpk=m-1+nx
                    mijkm=m-nxy
                    mijpkm=m+nx-nxy
                    u2=vyy(m)
                    u1=0._kdp
                    u3=0._kdp
                    ! ... Interpolate x and z velocities to y face
                    IF(imm == 1 .OR. imm == 2) THEN
                       u1=.5*(vxx(m)+vxx(mijpk))
                    ELSE IF(imm == 4 .OR. imm == 3) THEN
                       u1=.5*(vxx(mimjk)+vxx(mimjpk))
                    END IF
                    IF(imm == 1 .OR. imm == 4) THEN
                       u3=.5*(vzz(m)+vzz(mijpk))
                    ELSE IF(imm == 3 .OR. imm == 2) THEN
                       u3=.5*(vzz(mijkm)+vzz(mijpkm))
                    END IF
                    uvel=SQRT(u1*u1+u2*u2+u3*u3)
                    tdy=0._kdp
                    tdyx=0._kdp
                    tdyz=0._kdp
                    IF(uvel > 0.) THEN
                       tdy=(alphl(ipmz)*u2*u2+alphth(ipmz)*(u1*u1)+alphtv(ipmz)*(u3*u3))/uvel
                       tdyx=(alphl(ipmz)-alphth(ipmz))*u2*u1/uvel
                       tdyz=(alphl(ipmz)-alphtv(ipmz))*u2*u3/uvel
                    END IF
                    uden = den0
                    ufrac=1._kdp
                    IF(fresur) ufrac=.5*(frac(m)+frac(mijpk))
                    tsy(m)=tsy(m)+(tdy+tort(ipmz)*dm)*uden*ufrac*updxdz/udy
                    tsyx(m)=tsyx(m)+tdyx*uden*ufrac*updxdz
                    tsyz(m)=tsyz(m)+tdyz*uden*ufrac*updxdz
                 END DO
                 ! ... Z-direction cell face
                 mm(2)=mm(1)+1
                 mm(3)=mm(2)+nx
                 mm(4)=mm(1)+nx
                 DO  imm=1,4
                    m=mm(imm)
                    mijkp=m+nxy
                    IF(frac(mijkp) <= 0. .OR. frac(m) < 1._kdp) CYCLE
                    mimjk=m-1
                    mimjkp=m-1+nxy
                    mijmk=m-nx
                    mijmkp=m-nx+nxy
                    u3=vzz(m)
                    u1=0._kdp
                    u2=0._kdp
                    ! ... Interpolate x and y velocities to z face
                    IF(imm == 1 .OR. imm == 4) THEN
                       u1=.5*(vxx(m)+vxx(mijkp))
                    ELSE IF(imm == 2 .OR. imm == 3) THEN
                       u1=.5*(vxx(mimjk)+vxx(mimjkp))
                    END IF
                    IF(imm == 1 .OR. imm == 2) THEN
                       u2=.5*(vyy(m)+vyy(mijkp))
                    ELSE IF(imm == 3 .OR. imm == 4) THEN
                       u2=.5*(vyy(mijmk)+vyy(mijmkp))
                    END IF
                    uvel=SQRT(u1*u1+u2*u2+u3*u3)
                    tdz=0._kdp
                    tdzx=0._kdp
                    tdzy=0._kdp
                    IF(uvel > 0.) THEN
                       tdz=(alphl(ipmz)*u3*u3+alphtv(ipmz)*(u1*u1+u2*u2))/uvel
                       tdzx=(alphl(ipmz)-alphtv(ipmz))*u3*u1/uvel
                       tdzy=(alphl(ipmz)-alphtv(ipmz))*u3*u2/uvel
                    END IF
                    uden= den0
                    tsz(m)=tsz(m)+(tdz+tort(ipmz)*dm)*uden*updxdy/udz
                    tszx(m)=tszx(m)+tdzx*uden*updxdy
                    tszy(m)=tszy(m)+tdzy*uden*updxdy
                 END DO
              END DO
           END DO
        END DO
     ELSE
        ! ... Cylindrical case
        DO  k=k1z(ipmz),k2z(ipmz)-1
           udz=z(k+1)-z(k)
           DO  i=i1z(ipmz),i2z(ipmz)-1
              udx=x(i+1)-x(i)
              ! ... R-direction cell face
              udydz=pi*rm(i)*udz
              updydz=poros(ipmz)*udydz
              mm(1)=cellno(i,1,k)
              mm(2)=mm(1)+nxy
              DO  imm=1,2     ! ... contributions of this element to 2 cell face rings
                 m=mm(imm)
                 mipjk=m+1
                 IF(frac(m) <= 0. .OR. frac(mipjk) <= 0.) CYCLE
                 mijkm=m-nxy
                 mipjkm=m+1-nxy
                 u1=vxx(m)
                 u3=0._kdp
                 ! ... Interpolate  z velocities to rm face
                 ufr=(rm(i)-x(i))/(x(i+1)-x(i))
                 IF(imm == 1) THEN
                    u3=(1._kdp-ufr)*vzz(m)+ufr*vzz(mipjk)
                 ELSE IF(imm == 2) THEN
                    u3=(1._kdp-ufr)*vzz(mijkm)+ufr*vzz(mipjkm)
                 END IF
                 uvel=SQRT(u1*u1+u3*u3)
                 tdx=0._kdp
                 tdxz=0._kdp
                 IF(uvel > 0.) THEN
                    tdx=(alphl(ipmz)*u1*u1+alphtv(ipmz)*u3*u3)/uvel
                    tdxz=(alphl(ipmz)-alphtv(ipmz))*u1*u3/uvel
                 END IF
                 ! ... Values at cell boundary face
                 uden = den0
                 ufrac=1._kdp
                 IF(fresur) ufrac =.5*(frac(m)+frac(mipjk))
                 IF(solute) THEN
                    tsx(m)=tsx(m)+(tdx+tort(ipmz)*dm)*uden*ufrac*updydz/udx
                    tsxz(m)=tsxz(m)+tdxz*uden*ufrac*updydz
                 END IF
              END DO
              ! ... Z-direction cell face; annular ring
              mm(2)=mm(1)+1
              udxdyi=pi*(rm(i)*rm(i)-x(i)*x(i))
              udxdyo=pi*(x(i+1)*x(i+1)-rm(i)*rm(i))
              DO  imm=1,2
                 IF(imm == 1) updxdy=udxdyi*poros(ipmz)
                 IF(imm == 2) updxdy=udxdyo*poros(ipmz)
                 m=mm(imm)
                 mimjk=m-1
                 mimjkp=m-1+nxy
                 mijkp=m+nxy
                 IF(frac(mijkp) <= 0. .OR. frac(m) < 1._kdp) CYCLE
                 u3=vzz(m)
                 u1=0._kdp
                 ! ... Interpolate r velocities to z face
                 IF(imm == 1) THEN
                    u1=.5*(vxx(m)+vxx(mijkp))
                 ELSE IF(imm == 2) THEN
                    u1=.5*(vxx(mimjk)+vxx(mimjkp))
                 END IF
                 uvel=SQRT(u1*u1+u3*u3)
                 tdz=0._kdp
                 tdzx=0._kdp
                 IF(uvel > 0.) THEN
                    tdz=(alphl(ipmz)*u3*u3+alphtv(ipmz)*u1*u1)/uvel
                    tdzx=(alphl(ipmz)-alphtv(ipmz))*u3*u1/uvel
                 END IF
                 uden = den0
                 tsz(m)=tsz(m)+(tdz+tort(ipmz)*dm)*uden*updxdy/udz
                 tszx(m)=tszx(m)+tdzx*uden*updxdy
              END DO
           END DO
        END DO
     END IF
  END DO
  ! ... Check for negative dispersion coefficients
  IF(crosd) THEN
     ierrw = .FALSE.
     DO m=1,nxyz
        !!$  IF(tsx(m) <  0._kdp .or. tsy(m) <  0._kdp .or. tsz(m) <  0._kdp .or.  &
        !!$    tsxy(m) <  0._kdp .or. tsxz(m) <  0._kdp .or. tsyx(m) <  0._kdp .or.  &
        !!$    tsyz(m) <  0._kdp .or. tszx(m) <  0._kdp .or. tszy(m) <  0._kdp) ierr(171) = .true.
        IF(tsx(m) <  0._kdp .OR. tsy(m) <  0._kdp .OR. tsz(m) <  0._kdp .OR.  &
             tsxy(m) <  0._kdp .OR. tsxz(m) <  0._kdp .OR. tsyx(m) <  0._kdp .OR.  &
             tsyz(m) <  0._kdp .OR. tszx(m) <  0._kdp .OR. tszy(m) <  0._kdp) ierrw = .TRUE.
     END DO
     !$$      if(ierr(171)) errexe = .true.
     !$$      IF(ierrw) WRITE(*,*) 'WARNING: One or more negative dispersion coefficients computed'
     !***** warning output, retain here or move to root? 
     !**     IF(ierrw) CALL screenprt_c('WARNING: One or more negative dispersion coefficients computed');
  ENDIF
END SUBROUTINE coeff_trans
