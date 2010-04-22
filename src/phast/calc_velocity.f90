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
  CHARACTER(LEN=9) :: cibc
  INTEGER :: i, ibf, ic, ij, ipmz, j, k, l, lc, ls, l1, m, mbc
  REAL(KIND=kdp) :: uden, ufrac, uvis, wt
  REAL(KIND=kdp) :: qface, qlim, qn, sumq, vapp, vzfs
  REAL(KIND=kdp), DIMENSION(3) :: pa, qs
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
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
     b_cell(l)%qfbc = 0._kdp         ! ... Zero the flow rate structure elements 
  END DO
  ! ... Specified flux b.c.
  DO l=1,nfbc_cells
     m = flux_seg_index(l)%m
     IF(m == 0) CYCLE          ! ... dry cell
     DO  lc=1,num_bndy_cells
        mbc = b_cell(lc)%m_cell
        IF(mbc == m) THEN               ! ... found the b.c. cell
           DO ls=flux_seg_index(l)%seg_first,flux_seg_index(l)%seg_last
              ufrac = 1._kdp
              IF(ABS(ifacefbc(ls)) < 3) ufrac = frac(mbc)
              IF(fresur .AND. ifacefbc(ls) == 3 .AND. frac(mbc) <= 0._kdp) THEN
                 ! ... Redirect the flux from above to the free-surface cell
                 l1 = MOD(mbc,nxy)
                 IF(l1 == 0) l1 = nxy
                 mbc = mfsbc(l1)
              ENDIF
              IF (mbc == 0) EXIT          ! ... skip to next flux b.c. cell
              qn = qfflx(ls)*areafbc(ls)
              IF(qn <= 0.) THEN        ! ... Outflow
                 qface = den(mbc)*qn*ufrac
              ELSE                     ! ... Inflow
                 qface = denfbc(ls)*qn*ufrac
              END IF
              DO ibf=1,b_cell(lc)%num_faces
                 IF(ifacefbc(ls) == 1) THEN
                    IF(b_cell(lc)%face_indx(ibf) == 3 .OR. b_cell(lc)%face_indx(ibf) == 4) EXIT
                 ELSEIF(ifacefbc(ls) == 2) THEN
                    IF(b_cell(lc)%face_indx(ibf) == 2 .OR. b_cell(lc)%face_indx(ibf) == 5) EXIT
                 ELSEIF(ABS(ifacefbc(ls)) == 3) THEN
                    IF(b_cell(lc)%face_indx(ibf) == 1 .OR. b_cell(lc)%face_indx(ibf) == 6) EXIT
                 END IF
              END DO
              b_cell(lc)%qfbc(ibf) = b_cell(lc)%qfbc(ibf) + qface
           END DO
           EXIT
        END IF
     END DO
  END DO
  ! ... Leakage b.c. terms
  DO  l=1,nlbc
     m = leak_seg_index(l)%m
     IF(m == 0) CYCLE              ! ... empty cell
     DO  lc=1,num_bndy_cells
        mbc = b_cell(lc)%m_cell
        IF(mbc == m) THEN               ! ... found the b.c. cell
           DO ls=leak_seg_index(l)%seg_first,leak_seg_index(l)%seg_last
              qn =  albc(ls) - blbc(ls)*dp(mbc)
              IF(qn <= 0._kdp) THEN           ! ... Outflow
                 qface = den(mbc)*qn
              ELSE                            ! ... Inflow
                 IF(fresur .AND. ifacelbc(ls) == 3) THEN
                    ! ... Limit the flow rate for vertical leakage from above
                    qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
                         - 0.5_kdp*den(mbc)*bblbc(ls)))
                    qn = MIN(qn,qlim)
                    qface = denlbc(ls)*qn
                 ELSE
                    qface = denlbc(ls)*qn
                 END IF
              ENDIF
              DO ibf=1,b_cell(lc)%num_faces
                 IF(ifacelbc(ls) == 1) THEN
                    IF(b_cell(lc)%face_indx(ibf) == 3 .OR. b_cell(lc)%face_indx(ibf) == 4) EXIT
                 ELSEIF(ifacelbc(ls) == 2) THEN
                    IF(b_cell(lc)%face_indx(ibf) == 2 .OR. b_cell(lc)%face_indx(ibf) == 5) EXIT
                 ELSEIF(ABS(ifacelbc(ls)) == 3) THEN
                    IF(b_cell(lc)%face_indx(ibf) == 1 .OR. b_cell(lc)%face_indx(ibf) == 6) EXIT
                 END IF
              END DO
              b_cell(lc)%qfbc(ibf) = b_cell(lc)%qfbc(ibf) + qface
           END DO
           EXIT
        END IF
     END DO
  END DO
  ! ... River leakage b.c. terms
  DO l=1,nrbc
     m = river_seg_index(l)%m     ! ... current communicating cell 
     IF(m == 0) CYCLE              ! ... dry column, skip to next river b.c. cell 
     DO  lc=1,num_bndy_cells
        mbc = b_cell(lc)%m_cell
        IF(mbc == m) THEN               ! ... found the b.c. cell
           DO ls=river_seg_index(l)%seg_first,river_seg_index(l)%seg_last
              qn = arbc(ls) - brbc(ls)*dp(mbc)  
              IF(qn <= 0._kdp) THEN           ! ... Outflow
                 qface = den(mbc)*qn
              ELSE                            ! ... Inflow
                 ! ... Limit the flow rate for a river leakage
                 qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                      - 0.5_kdp*den(mbc)*bbrbc(ls)))
                 qn = MIN(qn,qlim)
                 qface = denrbc(ls)*qn
              ENDIF
              DO ibf=1,b_cell(lc)%num_faces
                 IF(b_cell(lc)%face_indx(ibf) == 1 .OR. b_cell(lc)%face_indx(ibf) == 6) EXIT
              END DO
              b_cell(lc)%qfbc(ibf) = b_cell(lc)%qfbc(ibf) + qface
           END DO
           EXIT
        END IF
     END DO
  END DO
  ! ... Drain leakage b.c. terms
  DO l=1,ndbc
     m = drain_seg_index(l)%m     ! ... current communicating cell 
     IF(m == 0) CYCLE              ! ... empty cell
     DO  lc=1,num_bndy_cells
        mbc = b_cell(lc)%m_cell
        IF(mbc == m) THEN               ! ... found the b.c. cell
           DO ls=drain_seg_index(l)%seg_first,drain_seg_index(l)%seg_last
              qn = adbc(ls) - bdbc(ls)*dp(mbc)
              IF(qn <= 0._kdp) THEN           ! ... Outflow
                 qface = den(mbc)*qn
              ELSE                            ! ... Inflow, not allowed
                 qface = 0._kdp
              ENDIF
              DO ibf=1,b_cell(lc)%num_faces
                 IF(b_cell(lc)%face_indx(ibf) == 1 .OR. b_cell(lc)%face_indx(ibf) == 6) EXIT
              END DO
              b_cell(lc)%qfbc(ibf) = b_cell(lc)%qfbc(ibf) + qface
           END DO
           EXIT
        END IF
     END DO
  END DO
  DO  l=1,num_bndy_cells
     m = b_cell(l)%m_cell
     IF(ABS(frac(m)) <= 0._kdp) CYCLE        ! ... skip dry cells 
     DO ibf=1,b_cell(l)%num_faces
        ic = b_cell(l)%face_indx(ibf)
        IF(fresur .AND. ic == 6) CYCLE    ! ... f.s. velocity later
        qface = b_cell(l)%qfbc(ibf)/(den(m)*frac(m)*b_cell(l)%por_areabc(ibf))
        IF(ic >= 4) qface = -qface     ! ... Product of q vector with outward normal
        IF(ic == 3 .OR. ic == 4) THEN
           vx_node(m) = qface
        ELSEIF(ic == 2 .OR. ic == 5) THEN
           vy_node(m) = qface
        ELSEIF(ic == 1 .OR. ic == 6) THEN
           vz_node(m) = qface
        END IF
     END DO
  END DO
  ! ... Specified P b.c. flow rates
  DO l=1,nsbc
     m = msbc(l)
     IF(frac(m) <= 0._kdp) CYCLE
     WRITE(cibc,6001) ibc(m)
6001 FORMAT(i9.9)
     ! ... Sum fluid fluxes
     ! ...      Flow rates calculated in SBCFLO
     IF(cibc(1:1) == '1') THEN
        DO  lc=1,num_bndy_cells
           mbc = b_cell(lc)%m_cell
           IF(ABS(frac(mbc)) <= 0._kdp) CYCLE        ! ... skip dry cells 
           IF(mbc == m) THEN               ! ... found the b.c. cell
              qface = qfsbc(l)
              ! ... sum the internal face flow rates for apportionment
              sumq = 0._kdp
              DO ibf=1,b_cell(lc)%num_faces
                 ic = b_cell(lc)%face_indx(ibf)
                 IF(fresur .AND. ic == 6) CYCLE
                 IF(ic == 3) THEN
                    qs(ibf) = ABS(sxx(mbc))
                    pa(ibf) = frac(mbc)*b_cell(lc)%por_areabc(ibf)
                 ELSEIF(ic == 4) THEN
                    qs(ibf) = ABS(sxx(mbc-1))
                    pa(ibf) = frac(mbc)*b_cell(lc)%por_areabc(ibf)
                 ELSEIF(ic == 2) THEN
                    qs(ibf) = ABS(syy(mbc))
                    pa(ibf) = frac(mbc)*b_cell(lc)%por_areabc(ibf)
                 ELSEIF(ic == 5) THEN
                    qs(ibf) = ABS(syy(mbc-nx))
                    pa(ibf) = frac(mbc)*b_cell(lc)%por_areabc(ibf)
                 ELSEIF(ic == 1) THEN
                    qs(ibf) = ABS(szz(mbc))
                    pa(ibf) = b_cell(lc)%por_areabc(ibf)
                 ELSEIF(ic == 6) THEN
                    qs(ibf) = ABS(szz(mbc-nxy))
                    pa(ibf) = b_cell(lc)%por_areabc(ibf)
                 END IF
                 sumq = sumq + qs(ibf)
              END DO
              sumq = MAX(sumq,1.e-20_kdp)
              DO ibf=1,b_cell(lc)%num_faces
                 vapp = qface*(qs(ibf)/sumq)/(den(m)*pa(ibf))
                 ic = b_cell(lc)%face_indx(ibf)
                 IF(fresur .AND. ic == 6) CYCLE
                 IF(ic == 3) THEN
                    vx_node(mbc) = vapp
                 ELSEIF(ic == 4) THEN
                    vx_node(mbc) = -vapp
                 ELSEIF(ic == 2) THEN
                    vy_node(mbc) = vapp
                 ELSEIF(ic == 5) THEN
                    vy_node(mbc) = -vapp
                 ELSEIF(ic == 1) THEN
                    vz_node(mbc) = vapp
                 ELSEIF(ic == 6) THEN
                    vz_node(mbc) = -vapp
                 END IF
              END DO
              EXIT
           END IF
        END DO
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
           vzfs = dzfsdt(ij)
           CALL mtoijk(m,i,j,k,nx,ny)
           IF(k == 1) CYCLE
           wt = (z(k) - z_face(k-1))/(zfs(ij) - z_face(k-1))
           vz_node(m) = wt*vzfs + (1._kdp-wt)*vzz(m-nxy)
        END IF
     END DO
  END IF
END SUBROUTINE calc_velocity
