SUBROUTINE calc_velocity
  ! ... Calculates conductances, velocities
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcv
  USE phys_const
  IMPLICIT NONE
  INTEGER :: i, ibf, ic, ij, ipmz, j, k, l, m
  REAL(KIND=kdp) :: uden,  &
       ufrac, uvis, wt
  REAL(KIND=kdp) :: qface, sumq, vapp, vzfs
  REAL(KIND=kdp), DIMENSION(3) :: pa, qs
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string=  &
       '$RCSfile: calc_velocity.f90,v $//$Revision: 2.1 $//$Date: 2004/12/16 20:17:39 $'
  !     ------------------------------------------------------------------
  ! ... Prepare to update conductances
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
  vx_node = 0._kdp
  vy_node = 0._kdp
  vz_node = 0._kdp
  DO  ipmz=1,npmz
     DO  k=k1z(ipmz),k2z(ipmz)
        DO  j=j1z(ipmz),j2z(ipmz)
           DO  i=i1z(ipmz),i2z(ipmz)
              m=cellno(i,j,k)
              IF(ibc(m) /= -1 .AND. frac(m) > 0.) THEN
                 ! ... X-direction conductances, mass flow rates, interstitial velocities
                 IF(i < i2z(ipmz)) THEN
                    IF(ibc(m+1) /= -1 .AND. frac(m+1) > 0.) THEN
                       ! ... Values at cell boundary
                       uden=.5*(den(m)+den(m+1))
                       uvis=.5*(vis(m)+vis(m+1))
                       ufrac = 1._kdp
                       IF(fresur) ufrac = .5*(frac(m)+frac(m+1))
                       tfx(m)=tx(m)*uden*ufrac/uvis
                       sxx(m)=-tfx(m)*((p(m+1)-p(m))+ uden*gx*(x(i+1)-x(i)))
                       vxx(m)=sxx(m)/(uden*ufrac*arx(m))
                    END IF
                 END IF
                 IF(j < j2z(ipmz) .AND. .NOT.cylind) THEN
                    mijpk=m+nx
                    IF(ibc(mijpk) /= -1 .AND. frac(mijpk) > 0.) THEN
                       ! ... Y-direction conductances, mass flow rates, interstitial velocities
                       uden=.5*(den(m)+den(mijpk))
                       uvis=.5*(vis(m)+vis(mijpk))
                       ufrac=1._kdp
                       IF(fresur) ufrac=.5*(frac(m)+frac(mijpk))
                       tfy(m)=ty(m)*uden*ufrac/uvis
                       syy(m)=-tfy(m)*((p(mijpk)-p(m))+ uden*gy*(y(j+1)-y(j)))
                       vyy(m)=syy(m)/(uden*ufrac*ary(m))
                    END IF
                 END IF
                 IF(k < k2z(ipmz)) THEN
                    mijkp=m+nxy
                    IF(ibc(mijkp) /= -1 .AND. frac(mijkp) > 0. .AND. frac(m) >= 1._kdp) THEN
                       ! ... Z-direction conductances, mass flow rates, interstitial velocities
                       uden=.5*(den(m)+den(mijkp))
                       uvis=.5*(vis(m)+vis(mijkp))
                       tfz(m)=tz(m)*uden/uvis
                       szz(m)=-tfz(m)*((p(mijkp)-p(m))+ uden*gz*(z(k+1)-z(k)))
                       vzz(m)=szz(m)/(uden*arz(m))
                    END IF
                 END IF
              END IF
           END DO
        END DO
     END DO
  END DO
  ! ... Interpolate velocity to node points
  DO m=1,nxyz
     CALL mtoijk(m,i,j,k,nx,ny)
     ! ... Only interior nodes of global mesh first
     IF(i > 1 .AND. i < nx) THEN
        wt = (x(i) - x_face(i-1))/(x_face(i) - x_face(i-1))
        vx_node(m) = ((1._kdp-wt)*vxx(m-1) + wt*vxx(m))
     END IF
     IF(j > 1 .AND. j < ny) THEN
        wt = (y(j) - y_face(j-1))/(y_face(j) - y_face(j-1))
        vy_node(m) = ((1._kdp-wt)*vyy(m-nx) + wt*vyy(m))
     END IF
     IF(k > 1 .AND. k < nz) THEN
        wt = (z(k) - z_face(k-1))/(z_face(k) - z_face(k-1))
        vz_node(m) = ((1._kdp-wt)*vzz(m-nxy) + wt*vzz(m))
     END IF
  END DO
  ! ... Calculate velocity at nodes on boundaries
  DO  l=1,num_bndy_cells
     m = b_cell(l)%m_cell
     IF(ABS(frac(m)) <= 0._kdp) CYCLE        ! ... skip dry cells 
     IF(b_cell(l)%num_same_bc == 1) THEN     ! ... all different b.c. types
        DO ibf=1,b_cell(l)%num_faces
           ic = b_cell(l)%face_indx(ibf)
           IF(fresur .AND. ic == 6) CYCLE    ! ... f.s. velocity later
           IF(b_cell(l)%bc_type(ibf) == 0) THEN
              qface = 0._kdp
           ELSEIF(b_cell(l)%bc_type(ibf) == 1) THEN
              qface = qfsbc(b_cell(l)%lbc_indx(ibf))
           ELSEIF(b_cell(l)%bc_type(ibf) == 2) THEN
              qface = qffbc(b_cell(l)%lbc_indx(ibf))
           ELSEIF(b_cell(l)%bc_type(ibf) == 3) THEN
              qface = qflbc(b_cell(l)%lbc_indx(ibf))
           elseif(b_cell(l)%bc_type(ibf) == 6 .or. b_cell(l)%bc_type(ibf) == 8) then
              qface = qfrbc(b_cell(l)%lbc_indx(ibf))
           END IF
           IF(ic >= 4) qface = -qface     ! ... Product of q vector with outward normal
!           if(abs(qface) > 0._kdp) then
              IF(ic == 3 .OR. ic == 4) THEN
                 vx_node(m) = qface/(den(m)*frac(m)*arx(m))
              ELSEIF(ic == 2 .OR. ic == 5) THEN
                 vy_node(m) = qface/(den(m)*frac(m)*ary(m))
              ELSEIF(ic == 1 .OR. ic == 6) THEN
                 vz_node(m) = qface/(den(m)*arz(m))
              END IF
!           end if
        END DO
     ELSEIF(b_cell(l)%num_same_bc == b_cell(l)%num_faces) THEN     ! ... all same b.c. types
        IF(b_cell(l)%bc_type(1) == 0) THEN
           qface = 0._kdp
        ELSEIF(b_cell(l)%bc_type(1) == 1) THEN
           qface = qfsbc(b_cell(l)%lbc_indx(1))
        ELSEIF(b_cell(l)%bc_type(1) == 2) THEN
           qface = qffbc(b_cell(l)%lbc_indx(1))
        ELSEIF(b_cell(l)%bc_type(1) == 3) THEN
           qface = qflbc(b_cell(l)%lbc_indx(1))
        elseif(b_cell(l)%bc_type(1) == 6 .or. b_cell(l)%bc_type(1) == 8) then
           qface = qfrbc(b_cell(l)%lbc_indx(ibf))
        END IF
        ! ... sum the internal face flow rates for apportionment
        sumq = 0._kdp
        DO ibf=1,b_cell(l)%num_faces
           ic = b_cell(l)%face_indx(ibf)
           IF(fresur .AND. ic == 6) CYCLE
           IF(ic == 3) THEN
              qs(ibf) = ABS(sxx(m))
              pa(ibf) = arx(m)*frac(m)
           ELSEIF(ic == 4) THEN
              qs(ibf) = ABS(sxx(m-1))
              pa(ibf) = -arx(m)*frac(m)
           ELSEIF(ic == 2) THEN
              qs(ibf) = ABS(syy(m))
              pa(ibf) = ary(m)*frac(m)
           ELSEIF(ic == 5) THEN
              qs(ibf) = ABS(syy(m-nx))
              pa(ibf) = -ary(m)*frac(m)
           ELSEIF(ic == 1) THEN
              qs(ibf) = ABS(szz(m))
              pa(ibf) = arz(m)
           ELSEIF(ic == 6) THEN
              qs(ibf) = ABS(szz(m-nxy))
              pa(ibf) = -arz(m)
           END IF
           sumq = sumq + qs(ibf)
        END DO
        sumq = MAX(sumq,1.e-20_kdp)
        DO ibf=1,b_cell(l)%num_faces
           vapp = qface*(qs(ibf)/sumq)/(den(m)*pa(ibf))
           ic = b_cell(l)%face_indx(ibf)
           IF(fresur .AND. ic == 6) CYCLE
           IF(ic == 3 .OR. ic == 4) THEN
              vx_node(m) = vapp
           ELSEIF(ic == 2 .OR. ic == 5) THEN
              vy_node(m) = vapp
           ELSEIF(ic == 1 .OR. ic == 6) THEN
              vz_node(m) = vapp
           END IF
        END DO
     ELSEIF(b_cell(l)%num_faces == 3 .AND. b_cell(l)%num_same_bc == 2) THEN 
        ! ... 3 faces, 2 same b.c. types
        ! ... Do the two faces with same b.c. type (first two)
        IF(b_cell(l)%bc_type(1) == 0) THEN
           qface = 0._kdp
        ELSEIF(b_cell(l)%bc_type(1) == 1) THEN
           qface = qfsbc(b_cell(l)%lbc_indx(1))
        ELSEIF(b_cell(l)%bc_type(1) == 2) THEN
           qface = qffbc(b_cell(l)%lbc_indx(1))
        ELSEIF(b_cell(l)%bc_type(1) == 3) THEN
           qface = qflbc(b_cell(l)%lbc_indx(1))
        elseif(b_cell(l)%bc_type(1) == 6 .or. b_cell(l)%bc_type(1) == 8) then
           qface = qfrbc(b_cell(l)%lbc_indx(ibf))
        END IF
        ! ... sum the internal face flow rates for apportionment
        sumq = 0._kdp
        DO ibf=1,2
           ic = b_cell(l)%face_indx(ibf)
           IF(fresur .AND. ic == 6) CYCLE
           IF(ic == 3) THEN
              qs(ibf) = ABS(sxx(m))
              pa(ibf) = arx(m)*frac(m)
           ELSEIF(ic == 4) THEN
              qs(ibf) = ABS(sxx(m-1))
              pa(ibf) = -arx(m)*frac(m)
           ELSEIF(ic == 2) THEN
              qs(ibf) = ABS(syy(m))
              pa(ibf) = ary(m)*frac(m)
           ELSEIF(ic == 5) THEN
              qs(ibf) = ABS(syy(m-nx))
              pa(ibf) = -ary(m)*frac(m)
           ELSEIF(ic == 1) THEN
              qs(ibf) = ABS(szz(m))
              pa(ibf) = arz(m)
           ELSEIF(ic == 6) THEN
              qs(ibf) = ABS(szz(m-nxy))
              pa(ibf) = -arz(m)
           END IF
           sumq = sumq + qs(ibf)
        END DO
        sumq = MAX(sumq,1.e-20_kdp)
        DO ibf=1,2
           ic = b_cell(l)%face_indx(ibf)
           IF(fresur .AND. ic == 6) CYCLE
           vapp = qface*(qs(ibf)/sumq)/(den(m)*pa(ibf))
           IF(ic == 3 .OR. ic == 4) THEN
              vx_node(m) = vapp
           ELSEIF(ic == 2 .OR. ic == 5) THEN
              vy_node(m) = vapp
           ELSEIF(ic == 1 .OR. ic == 6) THEN
              vz_node(m) = vapp
           END IF
        END DO
        ! ... Do the remaining face
        ibf = 3
        IF(b_cell(l)%bc_type(ibf) == 0) THEN
           qface = 0._kdp
        ELSEIF(b_cell(l)%bc_type(ibf) == 1) THEN
           qface = qfsbc(b_cell(l)%lbc_indx(ibf))
        ELSEIF(b_cell(l)%bc_type(ibf) == 2) THEN
           qface = qffbc(b_cell(l)%lbc_indx(ibf))
        ELSEIF(b_cell(l)%bc_type(ibf) == 3) THEN
           qface = qflbc(b_cell(l)%lbc_indx(ibf))
        elseif(b_cell(l)%bc_type(ibf) == 6 .or. b_cell(l)%bc_type(ibf) == 8) then
           qface = qfrbc(b_cell(l)%lbc_indx(ibf))
        END IF
        ic = b_cell(l)%face_indx(ibf)
        IF(fresur .AND. ic == 6) CYCLE
        IF(ic >= 4) qface = -qface     ! ... Product of q vector with outward normal
!        if(abs(qface) > 0._kdp) then
           IF(ic == 3 .OR. ic == 4) THEN
              vx_node(m) = qface/(den(m)*frac(m)*arx(m))
           ELSEIF(ic == 2 .OR. ic == 5) THEN
              vy_node(m) = qface/(den(m)*frac(m)*ary(m))
           ELSEIF(ic == 1 .OR. ic == 6) THEN
              vz_node(m) = qface/(den(m)*arz(m))
           END IF
!        end if
     END IF
  END DO
  IF(fresur) THEN
     ! ... Calculate velocity at nodes of cells with free surface
     DO ij=1,nxy
        m = mfsbc(ij)
        IF(m == 0) CYCLE
        IF(vmask(m) == 0) THEN
           vx_node(m) = 0._kdp
           vy_node(m) = 0._kdp
           vz_node(m) = 0._kdp
        ELSE
           vzfs = dfracdt(ij)*pv(m)/arz(m)
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(k == 1) CYCLE
           wt = (z(k) - z_face(k-1))/(zfs(ij) - z_face(k-1))
           vz_node(m) = wt*vzfs + (1._kdp-wt)*vzz(m-nxy)
        END IF
     END DO
  END IF
END SUBROUTINE calc_velocity
