SUBROUTINE asembl
  !.....Assembles the matrix coefficients and right hand side vector
  !.....     for either the flow, heat, or solute equation
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcs
  USE mcv
  USE mcw
  IMPLICIT NONE
  CHARACTER (LEN=9) :: cibc
  REAL(kind=kdp) :: cmx, cmy, cmz, cpx, cpy, cpz, dpmkm,dpmkp,dsxxm, dsxxp,  &
       dsyym, dsyyp, dszzm, dszzp, dx1, dx2, ehmx, ehmy, ehmz, ehpx, ehpy,  &
       ehpz, fracnzkp,  & 
       pmkm, pmkp, sxxm, sxxp, syym, syyp, szzm, szzp, tfxm, tfxp, tfym,  &
       tfyp, tfzm, tfzp, thxm, thxp, thym, thyp, thzm, thzp,  &
       tsxm, tsxp, tsym, tsyp, tszm, tszp, ucrosc, ucrost, ur1, ur2,  &
       urh, urs, utxm, utxp, utym, utyp, utzm, utzp, wtmx, wtmy,  &
       wtmz, wtpx, wtpy, wtpz, zkm, zkp
  INTEGER :: a_err, da_err, i, ibckm, ibckp, ic, j, k, m, ma, nsa
  INTEGER, PARAMETER :: icxm = 3, icxp = 4, icym = 2, icyp = 5, iczm = 1, iczp = 6
  !.....Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  nsa = MAX(ns,1)
  ALLOCATE (rs1(nxyz,nsa),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: asembl, number 0"  
     STOP  
  ENDIF
  !...
  !.....Compute and assemble coefficients in difference equations
  !.....     cell-by-cell
  DO  m=1,nxyz
     ma=mrno(m)
     svbc=.false.
     DO  ic=1,6
        va(ic,ma)=0._kdp
     END DO
     !.....Solve trivial equation for excluded cells, direct and iterative solvers
     IF(ibc(m) == -1) THEN
        va(7,ma)=1._kdp
        rhs(ma)=0._kdp
        CYCLE
     END IF
     WRITE(cibc,6001) ibc(m)
6001 FORMAT(i9)
     !.....Conductances and free-surface b.c. treated explicitly
     !.....Skip dry cells, unless they are specified value b.c.
     IF(((ieq == 1.AND.cibc(1:1) /= '1').OR.(ieq == 3.AND.cibc(7:7) /= '1')).AND. &
           frac(m) <= 0.) CYCLE
     !.....Decode M into K
     CALL mtoijk(m,i,j,k,nx,ny)
     tfxm=0._kdp
     thxm=0._kdp
     tsxm=0._kdp
     sxxm=0._kdp
     mimjk=ABS(cin(3,m))
     IF(mimjk > 0) THEN
        tfxm=tfx(mimjk)
        !            IF(HEAT) THXM=THX(MIMJK)
        IF(solute) tsxm=tsx(mimjk)
        sxxm=sxx(mimjk)
        !.....CALCULATE THE WEIGHTS
        wtmx=fdsmth
        IF(sxxm < 0.) wtmx=1._kdp-wtmx
     END IF
     tfxp=0._kdp
     thxp=0._kdp
     tsxp=0._kdp
     sxxp=0._kdp
     mipjk=ABS(cin(4,m))
     IF(mipjk > 0) THEN
        tfxp=tfx(m)
        !            IF(HEAT) THXP=THX(M)
        IF(solute) tsxp=tsx(m)
        sxxp=sxx(m)
        wtpx=fdsmth
        IF(sxxp < 0.) wtpx=1._kdp-wtpx
     END IF
     tfym=0._kdp
     thym=0._kdp
     tsym=0._kdp
     syym=0._kdp
     mijmk=ABS(cin(2,m))
     IF(mijmk > 0) THEN
        tfym=tfy(mijmk)
        !            IF(HEAT) THYM=THY(MIJMK)
        IF(solute) tsym=tsy(mijmk)
        syym=syy(mijmk)
        wtmy=fdsmth
        IF(syym < 0.) wtmy=1._kdp-wtmy
     END IF
     tfyp=0._kdp
     thyp=0._kdp
     tsyp=0._kdp
     syyp=0._kdp
     mijpk=ABS(cin(5,m))
     IF(mijpk > 0) THEN
        tfyp=tfy(m)
        !            IF(HEAT) THYP=THY(M)
        IF(solute) tsyp=tsy(m)
        syyp=syy(m)
        wtpy=fdsmth
        IF(syyp < 0.) wtpy=1._kdp-wtpy
     END IF
     tfzm=0._kdp
     thzm=0._kdp
     tszm=0._kdp
     szzm=0._kdp
     dpmkm=0._kdp
     pmkm=0._kdp
     zkm=0._kdp
     ibckm = -1
     mijkm=ABS(cin(1,m))
     IF(mijkm > 0) THEN
        tfzm=tfz(mijkm)
        !            IF(HEAT) THZM=THZ(MIJKM)
        IF(solute) tszm=tsz(mijkm)
        dpmkm=dp(mijkm)
        pmkm=p(mijkm)
        zkm=z(k-1)
        ibckm = ibc(mijkm)
        szzm=szz(mijkm)
        wtmz=fdsmth
        IF(szzm < 0.) wtmz=1._kdp-wtmz
     END IF
     tfzp=0._kdp
     thzp=0._kdp
     tszp=0._kdp
     szzp=0._kdp
     dpmkp=0._kdp
     pmkp=0._kdp
     zkp=0._kdp
     ibckp = -1
     fracnzkp = 0._kdp
     mijkp=ABS(cin(6,m))
     IF(mijkp > 0) THEN
        tfzp=tfz(m)
        !            IF(HEAT) THZP=THZ(M)
        IF(solute) tszp=tsz(m)
        dpmkp=dp(mijkp)
        pmkp=p(mijkp)
        zkp=z(k+1)
        ibckp = ibc(mijkp)
        fracnzkp = frac(mijkp)
        szzp=szz(m)
        wtpz=fdsmth
        IF(szzp < 0.) wtpz=1._kdp-wtpz
     END IF
     !.....Zero coefficients are used to suppress equation terms that are
     !.....     not present due to geometry of boundaries and/or equations
     !.....     that are not being solved
     IF(ieq == 1) THEN
        !.....Flow equation
        IF(cibc(1:1) == '1') svbc=.true.
        !... component 1 has been arbitrarily chosen to calculate coefficients
        !... should not make any difference, these are zero anyway for constant
        !... density
!....the f77 way
        CALL calcc(c(m,is),dc(m,is),den(m),dp(m),dpmkm,dpmkp,  &
             dt(0),frac(m),fracnzkp,ibckm,ibckp,ieq,k,p(m),pmkm,pmkp,pmchv(1),  &
             pmcv(m),pmhv(1),pv(m),pvk(1),t(1),z(k),zkm,zkp,deltim)
        !.....C34 and C35 are zero for SVBC and always for unmodified flow
        !.....     equation (no Gauss elimination)
        cc34(m)=c34
        cc35(m)=c35
        va(7,ma)=c33
        urh=0._kdp
        urs=0._kdp
        ucrosc=0._kdp
        ucrost=0._kdp
        IF(crosd) CALL crsdsp(m,ucrosc,ucrost)
        !.....Save RS and RH with cross derivative dispersive flux terms
        rs1(m,1) = 0._kdp
        IF(solute) rs1(m,1)=rs(m,1)+ucrosc
        utxm=0._kdp
        utxp=0._kdp
        utym=0._kdp
        utyp=0._kdp
        utzm=0._kdp
        utzp=0._kdp
        !.....X-direction
        IF(mimjk > 0) THEN
           ehmx = 0._kdp
!!$           IF(heat) THEN
!!$              urh=urh+urf1(thxm,dt(mimjk),dt(m),cpf*sxxm,wtmx)
!!$              ehmx=urf2(wtmx,eh(mimjk),eh(m),cpf*dt(mimjk),cpf*dt(m))
!!$           END IF
           urs = 0._kdp
           cmx = 0._kdp
           IF(solute) THEN
              urs=urs+urf1(tsxm,dc(mimjk,1),dc(m,1),sxxm,wtmx)
              cmx=urf2(wtmx,c(mimjk,1),c(m,1),dc(mimjk,1),dc(m,1))
           END IF
           utxm=tfxm*(1._kdp+c34*cmx+c35*ehmx)
           va(icxm,ma)=-fdtmth*utxm
           va(7,ma)=va(7,ma)+fdtmth*utxm
           !.....No terms for well in cylindrical system
        END IF
        IF(mipjk > 0) THEN
           ehpx = 0._kdp
!!$           IF(heat) THEN
!!$              urh=urh-urf1(thxp,dt(m),dt(mipjk),cpf*sxxp,wtpx)
!!$              ehpx=urf2(wtpx,eh(m),eh(mipjk),cpf*dt(m), cpf*dt(mipjk))
!!$           END IF
           urs = 0._kdp
           cpx = 0._kdp
           IF(solute) THEN
              urs=urs-urf1(tsxp,dc(m,1),dc(mipjk,1),sxxp,wtpx)
              cpx=urf2(wtpx,c(m,1),c(mipjk,1),dc(m,1),dc(mipjk,1))
           END IF
           utxp=tfxp*(1._kdp+c34*cpx+c35*ehpx)
           va(icxp,ma)=-fdtmth*utxp
           va(7,ma)=va(7,ma)+fdtmth*utxp
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(cylind.AND.i == 1) THEN
              vaw(icxp,k)=-fdtmth*tfxp
              vaw(7,k)=vaw(7,k)+fdtmth*tfxp
           END IF
        END IF
        !.....Y-direction
        IF(mijmk > 0) THEN
           ehmy = 0._kdp
!!$           IF(heat) THEN
!!$              urh=urh+urf1(thym,dt(mijmk),dt(m),cpf*syym,wtmy)
!!$              ehmy=urf2(wtmy,eh(mijmk),eh(m),cpf*dt(mijmk), cpf*dt(m))
!!$           END IF
           urs = 0._kdp
           cmy = 0._kdp
           IF(solute) THEN
              urs=urs+urf1(tsym,dc(mijmk,1),dc(m,1),syym,wtmy)
              cmy=urf2(wtmy,c(mijmk,1),c(m,1),dc(mijmk,1),dc(m,1))
           END IF
           utym=tfym*(1._kdp+c34*cmy+c35*ehmy)
           va(icym,ma)=-fdtmth*utym
           va(7,ma)=va(7,ma)+fdtmth*utym
        END IF
        IF(mijpk > 0) THEN
           ehpy = 0._kdp
!!$           IF(heat) THEN
!!$              urh=urh-urf1(thyp,dt(m),dt(mijpk),cpf*syyp,wtpy)
!!$              ehpy=urf2(wtpy,eh(m),eh(mijpk),cpf*dt(m), cpf*dt(mijpk))
!!$           END IF
           urs = 0._kdp
           cpy = 0._kdp
           IF(solute) THEN
              urs=urs-urf1(tsyp,dc(m,1),dc(mijpk,1),syyp,wtpy)
              cpy=urf2(wtpy,c(m,1),c(mijpk,1),dc(m,1),dc(mijpk,1))
           END IF
           utyp=tfyp*(1._kdp+c34*cpy+c35*ehpy)
           va(icyp,ma)=-fdtmth*utyp
           va(7,ma)=va(7,ma)+fdtmth*utyp
        END IF
        !.....Z-direction
        IF(mijkm > 0) THEN
           ehmz = 0._kdp
!!$           IF(heat) THEN
!!$              urh=urh+urf1(thzm,dt(mijkm),dt(m),cpf*szzm,wtmz)
!!$              ehmz=urf2(wtmz,eh(mijkm),eh(m),cpf*dt(mijkm), cpf*dt(m))
!!$           END IF
           urs = 0._kdp
           cmz = 0._kdp
           IF(solute) THEN
              urs=urs+urf1(tszm,dc(mijkm,1),dc(m,1),szzm,wtmz)
              cmz=urf2(wtmz,c(mijkm,1),c(m,1),dc(mijkm,1),dc(m,1))
           END IF
           utzm=tfzm*(1._kdp+c34*cmz+c35*ehmz)
           va(iczm,ma)=-fdtmth*utzm+cfp+c34*csp
           va(7,ma)=va(7,ma)+fdtmth*utzm
           IF(cylind.AND.i == 1) THEN
              vaw(iczm,k)=-fdtmth*tfzm
              vaw(7,k)=vaw(7,k)+fdtmth*tfzm
           END IF
        END IF
        IF(mijkp > 0) THEN
           ehpz = 0._kdp
!!$           IF(heat) THEN
!!$              urh=urh-urf1(thzp,dt(m),dt(mijkp),cpf*szzp,wtpz)
!!$              ehpz=urf2(wtpz,eh(m),eh(mijkp),cpf*dt(m), cpf*dt(mijkp))
!!$           END IF
           urs = 0._kdp
           cpz = 0._kdp
           IF(solute) THEN
              urs=urs-urf1(tszp,dc(m,1),dc(mijkp,1),szzp,wtpz)
              cpz=urf2(wtpz,c(m,1),c(mijkp,1),dc(m,1),dc(mijkp,1))
           END IF
           utzp=tfzp*(1._kdp+c34*cpz+c35*ehpz)
           va(iczp,ma)=-fdtmth*utzp+efp+c34*esp
           va(7,ma)=va(7,ma)+fdtmth*utzp
           IF(cylind.AND.i == 1) THEN
              vaw(iczp,k)=-fdtmth*tfzp
              vaw(7,k)=vaw(7,k)+fdtmth*tfzp
           END IF
        END IF
        !  with component 1
        rhs(ma)=rf(m)+c34*(rs1(m,1)+fdtmth*urs)
        IF(cylind.AND.i == 1) rhsw(k)=rf(m)-c31*dc(m,1)-c32*dt(0)
        !.....End of flow equation terms
!!$     ELSE IF(ieq == 2) THEN
!!$        !.....Heat equation
!!$        !...  not implemented for PHAST
!!$        ! calculate with component 1
!!$        !.....CALCULATE C'S WITH CURRENT DEN,P,T,C
!!$        IF(cibc(4:4) == '1') svbc=.true.
!!$        CALL calcc(c(m,is),dc(m,is),den(m),dp(m),dpmkm,dpmkp,  &
!!$             dt(0),frac(m),fracnzkp,ibckm,ibckp,ieq,k,p(m),pmkm,pmkp,pmchv(1),  &
!!$             pmcv(m),pmhv(1),pv(m),pvk(1),t(1),z(k),zkm,zkp,deltim)
!!$        !.....C24 IS ZERO FOR SVBC
!!$        cc24(m)=c24
!!$        va(7,ma)=c22
!!$        utxm=0._kdp
!!$        utxp=0._kdp
!!$        utym=0._kdp
!!$        utyp=0._kdp
!!$        utzm=0._kdp
!!$        utzp=0._kdp
!!$        ur1=0._kdp
!!$        ur2=0._kdp
!!$        urs=0._kdp
!!$        !.....X-DIRECTION
!!$        IF(mimjk > 0) THEN
!!$           dsxxm=-tfxm*(dp(m)-dp(mimjk))
!!$           sxxm=sxxm+dsxxm
!!$           wtmx=fdsmth
!!$           IF(sxxm < 0.) wtmx=1._kdp-wtmx
!!$           ur2=ur2+urf3(wtmx,eh(mimjk),eh(m),dsxxm)
!!$           IF(solute) THEN
!!$              urs=urs+urf1(tsxm,dc(mimjk,1),dc(m,1),sxxm,wtmx)
!!$              ur1=ur1+urf3(wtmx,c(mimjk,1),c(m,1),dsxxm)
!!$           END IF
!!$           utxm=thxm+(1._kdp-wtmx)*sxxm*cpf
!!$           va(icxm,ma)=-fdtmth*utxm
!!$           va(7,ma)=va(7,ma)+fdtmth*(thxm-wtmx*cpf*sxxm)
!!$        END IF
!!$        IF(mipjk > 0) THEN
!!$           dsxxp=-tfxp*(dp(mipjk)-dp(m))
!!$           sxxp=sxxp+dsxxp
!!$           wtpx=fdsmth
!!$           IF(sxxp < 0.) wtpx=1._kdp-wtpx
!!$           ur2=ur2-urf3(wtpx,eh(m),eh(mipjk),dsxxp)
!!$           IF(solute) THEN
!!$              urs=urs-urf1(tsxp,dc(m,1),dc(mipjk,1),sxxp,wtpx)
!!$              ur1=ur1-urf3(wtpx,c(m,1),c(mipjk,1),dsxxp)
!!$           END IF
!!$           utxp=thxp-wtpx*sxxp*cpf
!!$           va(icxp,ma)=-fdtmth*utxp
!!$           va(7,ma)=va(7,ma)+fdtmth*(thxp+(1._kdp-wtpx)*cpf*sxxp)
!!$        END IF
!!$        !.....Y-DIRECTION
!!$        IF(mijmk > 0) THEN
!!$           dsyym=-tfym*(dp(m)-dp(mijmk))
!!$           syym=syym+dsyym
!!$           wtmy=fdsmth
!!$           IF(syym < 0.) wtmy=1._kdp-wtmy
!!$           ur2=ur2+urf3(wtmy,eh(mijmk),eh(m),dsyym)
!!$           IF(solute) THEN
!!$              urs=urs+urf1(tsym,dc(mijmk,1),dc(m,1),syym,wtmy)
!!$              ur1=ur1+urf3(wtmy,c(mijmk,1),c(m,1),dsyym)
!!$           END IF
!!$           utym=thym+(1._kdp-wtmy)*syym*cpf
!!$           va(icym,ma)=-fdtmth*utym
!!$           va(7,ma)=va(7,ma)+fdtmth*(thym-wtmy*cpf*syym)
!!$        END IF
!!$        IF(mijpk > 0) THEN
!!$           dsyyp=-tfyp*(dp(mijpk)-dp(m))
!!$           syyp=syyp+dsyyp
!!$           wtpy=fdsmth
!!$           IF(syyp < 0.) wtpy=1._kdp-wtpy
!!$           ur2=ur2-urf3(wtpy,eh(m),eh(mijpk),dsyyp)
!!$           IF(solute) THEN
!!$              urs=urs-urf1(tsyp,dc(m,1),dc(mijpk,1),syyp,wtpy)
!!$              ur1=ur1-urf3(wtpy,c(m,1),c(mijpk,1),dsyyp)
!!$           END IF
!!$           utyp=thyp-wtpy*syyp*cpf
!!$           va(icyp,ma)=-fdtmth*utyp
!!$           va(7,ma)=va(7,ma)+fdtmth*(thyp+(1._kdp-wtpy)*cpf*syyp)
!!$        END IF
!!$        !.....Z-DIRECTION
!!$        IF(mijkm > 0) THEN
!!$           dszzm=-tfzm*(dp(m)-dp(mijkm))
!!$           szzm=szzm+dszzm
!!$           wtmz=fdsmth
!!$           IF(szzm < 0.) wtmz=1._kdp-wtmz
!!$           ur2=ur2+urf3(wtmz,eh(mijkm),eh(m),dszzm)
!!$           IF(solute) THEN
!!$              urs=urs+urf1(tszm,dc(mijkm,1),dc(m,1),szzm,wtmz)
!!$              ur1=ur1+urf3(wtmz,c(mijkm,1),c(m,1),dszzm)
!!$           END IF
!!$           utzm=thzm+(1._kdp-wtmz)*szzm*cpf
!!$           va(iczm,ma)=-fdtmth*utzm
!!$           va(7,ma)=va(7,ma)+fdtmth*(thzm-wtmz*cpf*szzm)
!!$        END IF
!!$        IF(mijkp > 0) THEN
!!$           dszzp=-tfzp*(dp(mijkp)-dp(m))
!!$           szzp=szzp+dszzp
!!$           wtpz=fdsmth
!!$           IF(szzp < 0.) wtpz=1._kdp-wtpz
!!$           ur2=ur2-urf3(wtpz,eh(m),eh(mijkp),dszzp)
!!$           IF(solute) THEN
!!$              urs=urs-urf1(tszp,dc(m,1),dc(mijkp,1),szzp,wtpz)
!!$              ur1=ur1-urf3(wtpz,c(m,1),c(mijkp,1),dszzp)
!!$           END IF
!!$           utzp=thzp-wtpz*szzp*cpf
!!$           va(iczp,ma)=-fdtmth*utzp
!!$           va(7,ma)=va(7,ma)+fdtmth*(thzp+(1._kdp-wtpz)*cpf*szzp)
!!$        END IF
!!$        !  with component 1
!!$        rhs(ma)=rh1(1)+fdtmth*ur2-c23*dp(m)+c24*(rs1(m,1)+ fdtmth*(ur1+urs))
!!$        !.....End of heat equation terms
     ELSE IF(ieq == 3) THEN
        !.....Solute equation
        !.....Calculate C's with current DEN,P,T,C
        IF(cibc(7:7) == '1') svbc=.true.
        CALL calcc(c(m,is),dc(m,is),den(m),dp(m),dpmkm,dpmkp,  &
             dt(0),frac(m),fracnzkp,ibckm,ibckp,ieq,k,p(m),pmkm,pmkp,pmchv(1),  &
             pmcv(m),pmhv(1),pv(m),pvk(1),t(1),z(k),zkm,zkp,deltim)
        va(7,ma)=c11
        utxm=0._kdp
        utxp=0._kdp
        utym=0._kdp
        utyp=0._kdp
        utzm=0._kdp
        utzp=0._kdp
        ur1=0._kdp
        ucrosc=0._kdp
        IF(crosd) CALL crsdsp(m,ucrosc,ucrost)
        !.....Save RS and RH with cross derivative dispersive flux terms
        IF(solute) rs1(m,is)=rs(m,is)+ucrosc
        !.....X-direction
        IF(mimjk > 0) THEN
           dsxxm=-tfxm*(dp(m)-dp(mimjk))
           sxxm=sxxm+dsxxm
           wtmx=fdsmth
           IF(sxxm < 0.) wtmx=1._kdp-wtmx
           ur1=ur1+urf3(wtmx,c(mimjk,is),c(m,is),dsxxm)
           utxm=tsxm+(1._kdp-wtmx)*sxxm
           va(icxm,ma)=-fdtmth*utxm
           va(7,ma)=va(7,ma)+fdtmth*(tsxm-wtmx*sxxm)
        END IF
        IF(mipjk > 0) THEN
           dsxxp=-tfxp*(dp(mipjk)-dp(m))
           sxxp=sxxp+dsxxp
           wtpx=fdsmth
           IF(sxxp < 0.) wtpx=1._kdp-wtpx
           ur1=ur1-urf3(wtpx,c(m,is),c(mipjk,is),dsxxp)
           utxp=tsxp-wtpx*sxxp
           va(icxp,ma)=-fdtmth*utxp
           va(7,ma)=va(7,ma)+fdtmth*(tsxp+(1._kdp-wtpx)*sxxp)
        END IF
        !.....Y-direction
        IF(mijmk > 0) THEN
           dsyym=-tfym*(dp(m)-dp(mijmk))
           syym=syym+dsyym
           wtmy=fdsmth
           IF(syym < 0.) wtmy=1._kdp-wtmy
           ur1=ur1+urf3(wtmy,c(mijmk,is),c(m,is),dsyym)
           utym=tsym+(1._kdp-wtmy)*syym
           va(icym,ma)=-fdtmth*utym
           va(7,ma)=va(7,ma)+fdtmth*(tsym-wtmy*syym)
        END IF
        IF(mijpk > 0) THEN
           dsyyp=-tfyp*(dp(mijpk)-dp(m))
           syyp=syyp+dsyyp
           wtpy=fdsmth
           IF(syyp < 0.) wtpy=1._kdp-wtpy
           ur1=ur1-urf3(wtpy,c(m,is),c(mijpk,is),dsyyp)
           utyp=tsyp-wtpy*syyp
           va(icyp,ma)=-fdtmth*utyp
           va(7,ma)=va(7,ma)+fdtmth*(tsyp+(1._kdp-wtpy)*syyp)
        END IF
        !.....Z-direction
        IF(mijkm > 0) THEN
           dszzm=-tfzm*(dp(m)-dp(mijkm))
           szzm=szzm+dszzm
           wtmz=fdsmth
           IF(szzm < 0.) wtmz=1._kdp-wtmz
           ur1=ur1+urf3(wtmz,c(mijkm,is),c(m,is),dszzm)
           utzm=tszm+(1._kdp-wtmz)*szzm
           va(iczm,ma)=-fdtmth*utzm
           va(7,ma)=va(7,ma)+fdtmth*(tszm-wtmz*szzm)
        END IF
        IF(mijkp > 0) THEN
           dszzp=-tfzp*(dp(mijkp)-dp(m))
           szzp=szzp+dszzp
           wtpz=fdsmth
           IF(szzp < 0.) wtpz=1._kdp-wtpz
           ur1=ur1-urf3(wtpz,c(m,is),c(mijkp,is),dszzp)
           utzp=tszp-wtpz*szzp
           va(iczp,ma)=-fdtmth*utzp
           va(7,ma)=va(7,ma)+fdtmth*(tszp+(1._kdp-wtpz)*szzp)
        END IF
        rhs(ma)=rs1(m,is)+fdtmth*ur1-c12*dt(0)-c13*dp(m) -csp*dpmkm-esp*dpmkp
        !.....End of solute terms
     END IF
  END DO
  DEALLOCATE (rs1,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: asembl"  
     STOP  
  ENDIF

CONTAINS

  FUNCTION urf1(tt,dx1,dx2,s,wt) RESULT (dcflux)
    !.....     Dispersive and convective flux
    REAL(KIND=kdp) :: dcflux
    REAL(KIND=kdp), INTENT(IN) :: dx1, dx2, s, tt, wt
    ! ...
    dcflux = -tt*(dx2-dx1) + s*((1._kdp-wt)*dx1 + wt*dx2)
  END FUNCTION urf1

  FUNCTION urf2(wt,x1,x2,dx1,dx2) RESULT (xp_interp)
    !.....     Interpolation to cell boundary
    REAL(KIND=kdp) :: xp_interp
    REAL(KIND=kdp), INTENT(IN) :: dx1, dx2, wt, x1, x2
    ! ...
    xp_interp = (1._kdp-wt)*(x1+dx1) + wt*(x2+dx2)
  END FUNCTION urf2

  FUNCTION urf3(wt,x1,x2,v) RESULT (adv_flux)
  !.....     Advective flux or change in advective flux
    REAL(KIND=kdp) :: adv_flux
    REAL(KIND=kdp), INTENT(IN) :: v, wt, x1, x2
    ! ...
    adv_flux = ((1._kdp-wt)*x1+wt*x2)*v
  END FUNCTION urf3

END SUBROUTINE asembl
