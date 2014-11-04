SUBROUTINE sumcal2
  ! ... Performs summary calculations at end of time step
  ! ... This is block2 for after chemical reaction step
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
  USE mcw
  USE mcw_m
  USE mg2_m, ONLY: hdprnt
  USE PhreeqcRM
  IMPLICIT NONE
  !INCLUDE "RM_interface_F.f90.inc"
  INTEGER :: status
  !
  !$$  CHARACTER(LEN=50) :: aform = '(TR5,A45,T47,1PE12.4,TR1,A7,T66,A,3(1PG10.3,A),2A)'
  !$$  CHARACTER(LEN=46) :: aformt = '(TR5,A43,1PE12.4,TR1,A7,TR1,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=9) :: cibc
  CHARACTER(LEN=130) :: logline1
  REAL(KIND=kdp) :: denmfs, p1, pmfs,  &
       qlim, qm_in, qm_net, qn, qnp,  &
       u0, u1, ufdt0, ufdt1,  &
       ufrac, up0, z0, z1, z2, zfsl, zm1, zmfs, zp1
  INTEGER :: da_err, i, icol, imod, iwel, j, jcol, k, kcol, kfs, l, lc, l1, ls,  &
       m, m0, m1, m1kp, mfs, mt
  LOGICAL :: ierrw
  !     ------------------------------------------------------------------
  !...
  ufdt0 = 1._kdp - fdtmth
  ufdt1 = fdtmth
  ! ... Calculate total solute in region
  ! ...     after reaction step
  sir = 0._kdp
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     IF(frac(m) <= 0._kdp) CYCLE
     u0=pv(m)*frac(m)
     u1=0._kdp
     DO  is=1,ns
        sir(is) = sir(is)+den0*(u0+u1)*c(m,is)
     END DO
  END DO
  ! ... Change in fluid and solute over time step and by reaction
  dfir = fir-firn
  DO  is=1,ns
     dsir(is) = sir(is)-sirn(is)
     dsir_chem(is) = sir(is)-sir_prechem(is)
  END DO
  ! ... Cumulative totals
  ! ... Convert step total flow rates to step total amounts
  stotfi=stotfi*deltim
  stothi=stothi*deltim
  stotfp=stotfp*deltim
  stothp=stothp*deltim
  totfi=totfi+stotfi
  totfp=totfp+stotfp
  DO  is=1,ns
     stotsi(is) = stotsi(is)*deltim
     stotsp(is) = stotsp(is)*deltim
     totsi(is) = totsi(is) + stotsi(is)
     totsp(is) = totsp(is) + stotsp(is)
     tdsir_chem(is) = tdsir_chem(is) + dsir_chem(is)
  END DO
  ! ... Fluid mass and solute balance calculations
  sfres = dfir-stotfi+stotfp
  tfres = fir-fir0-totfi+totfp
  u1 = MAX(ABS(dfir),stotfi,stotfp)
  sfresf = 1.e99_kdp
  IF(u1 > 0.) sfresf=sfres/u1
  u1=MAX(ABS(fir-fir0),totfi,totfp)
  tfresf = 1.e99_kdp
  IF(u1 > 0.) tfresf=tfres/u1
  DO  is=1,ns
     ssres(is) = dsir(is) - stotsi(is) + stotsp(is) - dsir_chem(is)
     tsres(is) = sir(is) - sir0(is) - totsi(is) + totsp(is) - tdsir_chem(is)
     u1=MAX(ABS(dsir(is)),stotsi(is),stotsp(is),dsir_chem(is))
     ssresf(is) = 1.e99_kdp
     IF(u1 > 0.) ssresf(is)=ssres(is)/u1
     u1 = MAX(ABS(sir(is)-sir0(is)),totsi(is),totsp(is),ABS(tdsir_chem(is)))
     tsresf(is) = 1.e99_kdp
     IF(u1 > 0.) tsresf(is)=tsres(is)/u1
  END DO
  IF(.NOT.steady_flow) THEN          ! ... skip this if steady state flow
     ! ... Now update for next time step, by drying up cells, rewetting cells, reseting pointer
     IF(fresur) THEN
        ! ... Adjust fraction of cell that is saturated
        ! ...      for cells that contained the free surface at start of this
        ! ...      time step
        ! ... Use only hydrostatic extrapolation, no interpolation to locate elevation
        ! ...      of free surface
        ! ... Will not handle case of water table moving down more than one cell
        ! ...      per time step
        DO  mt=1,nxy
           m=mfsbc(mt)          ! ... w.t. cell at time n
           IF(m == 0) CYCLE     ! ... Column of dry cells; can not rewet
           imod = MOD(m,nxy)
           k = (m-imod)/nxy + MIN(1,imod)
           IF(k == 1) THEN           ! ... Bottom plane; hydrostatic
              IF(p(m) > 0._kdp) THEN
                 vmask(m) = 1
              ELSE
                 frac(m) = 0._kdp     ! Falling water table giving empty column of cells
                 vmask(m) = 0
              END IF
           ELSE IF(k == nz) THEN           ! ... Top plane
              IF(p(m) > 0._kdp) THEN
                 vmask(m) = 1
              ELSE
                 vmask(m) = 0
                 IF(frac(m) < 0.) THEN                 ! ... Falling water table
                    frac(m) = 0._kdp
                    ! ... Set saturation fraction of cell below
                    IF(nz > 2) THEN
                       z1 = z(k)
                       z0 = z(k-1)
                       zm1=z(k-2)
                       frac(m-nxy)=(2.*zfs(mt)-(z0+zm1))/(z1-zm1)
                       frac(m-nxy)=MAX(0._kdp,frac(m-nxy))     
                       vmask(m-nxy) = 1
                       IF(frac(m-nxy) < 0.5_kdp) vmask(m-nxy) = 0
                    ELSE                    ! ... Bottom plane case for nz = 2
                       IF(p(m-nxy) >= 0._kdp) THEN
                          up0=p(m-nxy)
                          z0=z(1)
                          z1=z(2)
                          zfs(mt) = up0/(den0*gz) + z0
                          frac(m-nxy) = 2.*(zfs(mt)-z0)/(z1-z0)
                          frac(m-nxy)=MAX(0._kdp,frac(m-nxy))
                          vmask(m-nxy) = 1
                       ELSE
                          frac(m-nxy) = 0._kdp      ! ... Empty column of cells
                          vmask(m-nxy) = 0
                       END IF
                    ENDIF
                 END IF
              END IF
           ELSE                  ! ... Intermediate plane
              IF(ibc(m-nxy) == -1) THEN       ! ... Treat as bottom plane
                 IF(p(m) > 0._kdp) THEN
                    vmask(m) = 1
                 ELSE
                    frac(m) = 0._kdp     ! ... Empty column of cells
                    vmask(m) = 0
                 END IF
              ELSEIF(ibc(m+nxy) == -1) THEN    ! ... Treat as top plane
                 IF(p(m) > 0._kdp) THEN
                    vmask(m) = 1
                 ELSE
                    frac(m) = MAX(0._kdp,frac(m))
                    vmask(m) = 0
                 END IF
              ELSE                            ! ... True intermediate plane
                 IF(p(m) > 0._kdp) THEN
                    vmask(m) = 1
                 ELSE
                    vmask(m) = 0
                    IF(frac(m) < 0.) THEN                    ! ... Falling water table
                       frac(m) = 0._kdp
                       ! ... Set saturation fraction of cell below
                       zm1=z(k-2)
                       z0=z(k-1)
                       z1=z(k)
                       frac(m-nxy)=(2.*zfs(mt)-(z0+zm1))/(z1-zm1)
                       frac(m-nxy)=MAX(0._kdp,frac(m-nxy))
                       vmask(m-nxy) = 1
                       IF(frac(m-nxy) < 0.5_kdp) vmask(m-nxy) = 0
                    END IF
                 END IF
              END IF
           END IF
           IF(frac(m) <= 1.e-6_kdp) THEN
              frac(m) = 0._kdp
              vmask(m) = 0
           END IF
        END DO
        ! ... Calculate fraction of specified pressure cell that is
        ! ...      saturated, only after time of change
        !*****This seems redundant. Done in INIT3. But at time zero, the i.c. pressure is used
        !*** ...  instead of b.c. pressure
        IF(jtime == 1) THEN
           DO  l=1,nsbc
              m=msbc(l)
              ! ... Only needed for cells above free surface to handle resaturation ??
              ! ...      All pressures are valid
              !****try for all cells. what if f.s. is lower now after pressure input?
              !           IF(frac(m) <= 0.) THEN
              CALL mtoijk(m,i,j,k,nx,ny)
              mt = cellno(i,j,1)
              IF(k == 1) THEN
                 ! ... Bottom plane; hydrostatic
                 IF(p(m) > 0._kdp) THEN
                    up0=p(m)
                    z0=z(1)
                    zp1=z(2)
                    zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                    frac(m) = 2.*(zfsl-z0)/(zp1-z0)
                    frac(m) = MIN(1._kdp,frac(m))
                    vmask(m) = 1
                 ELSE
                    frac(m) = 0._kdp
                    vmask(m) = 0
                 END IF
              ELSE IF(k == nz) THEN
                 ! ... Top plane
                 IF(p(m) > 0._kdp) THEN
                    up0=p(m)
                    zm1=z(k-1)
                    z0=z(k)
                    zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                    frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                    vmask(m) = 1
                 ELSE
                    up0=p(m)
                    zm1 = z(k-1)
                    z0 = z(k)
                    zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                    frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                    frac(m)=MAX(0._kdp,frac(m))
                    vmask(m) = 0
                 END IF
              ELSE              ! ... Intermediate plane
                 IF(ibc(m-nxy) == -1) THEN       ! ... Treat as bottom plane
                    IF(p(m) > 0._kdp) THEN
                       up0=p(m)
                       z0=z(k)
                       zp1=z(k+1)
                       zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                       frac(m) = 2.*(zfsl-z0)/(zp1-z0)
                       frac(m) = MIN(1._kdp,frac(m))
                       vmask(m) = 1
                    ELSE
                       frac(m) = 0._kdp
                       vmask(m) = 0
                    END IF
                 ELSEIF(ibc(m+nxy) == -1) THEN    ! ... Treat as top plane
                    IF(p(m) > 0._kdp) THEN
                       up0=p(m)
                       zm1=z(k-1)
                       z0=z(k)
                       zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                       frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                       frac(m) = MIN(1._kdp,frac(m))
                       vmask(m) = 1
                    ELSE
                       up0=p(m)
                       zm1 = z(k-1)
                       z0 = z(k)
                       zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                       frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                       frac(m) = MAX(0._kdp,frac(m))
                       vmask(m) = 0
                    END IF
                 ELSE                      ! ... True intermediate plane
                    IF(p(m) > 0._kdp) THEN
                       up0=p(m)
                       zm1=z(k-1)
                       z0=z(k)
                       zp1=z(k+1)
                       zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                       frac(m) = (2.*zfsl-(z0+zm1))/(zp1-zm1)
                       frac(m) = MIN(1._kdp,frac(m))
                       vmask(m) = 1
                    ELSE
                       up0=p(m)
                       zm1=z(k-1)
                       z0=z(k)
                       zp1=z(k+1)
                       zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                       frac(m) = (2.*zfsl-(z0+zm1))/(zp1-zm1)
                       frac(m)=MAX(0._kdp,frac(m))
                       vmask(m) = 0
                    END IF
                 END IF
              END IF
              IF(frac(m) <= 1.e-6_kdp) THEN
                 frac(m) = 0._kdp
                 vmask(m) = 0
              END IF
           END DO
        END IF
        ! ... Now adjust the region for rise of free surface as necessary
        ! ... Problems if f.s. rises more than one cell per time step
        DO  mt=1,nxy
           m=mfsbc(mt)          ! .. f.s. cell at time n
           IF(m == 0) CYCLE
           ! ... save rate of free surface movement
           ! ... not valid if cell has gone dry
           dzfsdt(mt) = (zfs(mt) - zfsn(mt))/deltim
           IF(frac(m) > 1._kdp) THEN
              imod = MOD(m,nxy)
              k = (m-imod)/nxy + MIN(1,imod)
              IF(k == nz) CYCLE          ! ... Overfilling allowed at top of mesh
              IF(ibc(m+nxy) == -1) CYCLE     !  Treat as top layer, with overfilling
              IF (frac(m) < 1._kdp + 1.e-6_kdp) CYCLE
              ! ... Calculate pressure and fraction of saturation in m+nxy cell;
              ! ...      the new free-surface cell
              up0=p(m)
              z0=z(k)
              z1=z(k+1)
              ! ... Calculate fraction of cell that is newly saturated using
              ! ...      residual volume of fluid from cell below
              frac(m+nxy)=(frac(m)-1._kdp)*pv(m)/pv(m+nxy)
              !IF(k+1 == nz .OR. ibc(m+2*nxy) == -1) THEN
              IF(k+1 == nz) THEN
                 zfs(mt)=.5_kdp*(z1+z0+frac(m+nxy)*(z1-z0))     ! half cell thickness
              ELSE IF (ibc(m+2*nxy) == -1) THEN
                 zfs(mt)=.5_kdp*(z1+z0+frac(m+nxy)*(z1-z0))     ! half cell thickness
              ELSE
                 z2=z(k+2)
                 zfs(mt)=.5_kdp*(z1+z0+frac(m+nxy)*(z2-z0))     ! full cell thickness
              END IF
              vmask(m+nxy) = 0
              IF(zfs(mt) >= z1) vmask(m+nxy) = 1
              p(m+nxy)=up0*(zfs(mt)-z1)/(zfs(mt)-z0)
              hdprnt(m+nxy)=z1+p(m+nxy)/(den0*gz)
              !$$           den(m+nxy)=den(m)
              !$$           vis(m+nxy)=vis(m)
              IF(solute) THEN
                 DO  is=1,ns
                    c(m+nxy,is)=c(m,is)
                 END DO
              END IF
              ! ... Now set saturated cell to frac of 1.
              frac(m) = 1._kdp
              vmask(m) = 1
           END IF
        END DO
        ! ... Reset the pointer to the cell containing the free surface
        ! ...      at each node location over the horizontal area
        ! ... also set all frac to one for cells below the f.s. cell
         DO  mt=1,nxy
            ierrw = .FALSE.
            m0 = mfsbc(mt)
            mfsbc(mt) = 0
            DO k=nz,1,-1
               m1 = (k-1)*nxy + mt
               IF (ibc(m1) >= 0) THEN
                  IF(frac(m1) > 0._kdp) THEN
                     mfsbc(mt) = m1
                     EXIT
                  END IF
               END IF
            END DO
            DO m=m1-nxy,1,-nxy
               frac(m) = 1._kdp
            END DO
            IF(ABS(m1 - m0) > nxy) THEN
               CALL mtoijk(mt,icol,jcol,kcol,nx,ny)
               WRITE(logline1,'(a)')  &
                    'WARNING: Free surface has moved more than one layer of cells in sumcal2'
               status = RM_ScreenMessage(rm_id, logline1)
               status = RM_LogMessage(rm_id, logline1)
               WRITE(logline1,'(tr5,a,i6,a,i5,a,i5)')   &
                    'Cell column:', mt,' (i,j):', icol, ',', jcol
               status = RM_ScreenMessage(rm_id, logline1)
               status = RM_LogMessage(rm_id, logline1)
            END IF
            IF(m1 == 0 .AND. .NOT.print_dry_col(mt)) THEN
               CALL mtoijk(mt,icol,jcol,kcol,nx,ny)
               WRITE(logline1,'(a)')  &
                    'WARNING: A column of cells has gone dry in sumcal2'
               status = RM_ScreenMessage(rm_id, logline1)
               status = RM_LogMessage(rm_id, logline1)
               WRITE(logline1,'(tr5,a,i6,a,i5,a,i5)')  &
                    'Cell column:', mt,' (i,j):', icol, ',', jcol
               status = RM_ScreenMessage(rm_id, logline1)
               status = RM_LogMessage(rm_id, logline1)
               print_dry_col(mt) = .TRUE.
            END IF
         END DO
        ! ... Calculate hydrostatic pressure for cells up to top of region
        ! ...      This gives a pressure field that may be used for an initial
        ! ...           condition for a future simulation
        DO  mt=1,nxy
           mfs=mfsbc(mt)
           IF(mfs == 0) CYCLE
           imod = MOD(mfs,nxy)
           kfs=(mfs-imod)/nxy + MIN(1,imod)
           zmfs=z(kfs)
           pmfs=p(mfs)
           denmfs = den0
           DO  k=1,nz-kfs
              m1kp=mfs+k*nxy
              ! ... Skip specified pressure cells
              WRITE(cibc,6001) ibc(m1kp)
6001          FORMAT(i9.9)
              IF(cibc(1:1) /= '1') p(m1kp)=pmfs-denmfs*gz*(z(kfs+k)-zmfs)
              IF(solute) THEN
                 DO  is=1,ns
                    c(m1kp,is)=0._kdp       ! Dry cell concentration
                 END DO
              END IF
           END DO
        END DO
     END IF
  END IF
  DEALLOCATE (zfsn, &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, sumcal2, number 1d"  
     STOP
  ENDIF
END SUBROUTINE sumcal2
