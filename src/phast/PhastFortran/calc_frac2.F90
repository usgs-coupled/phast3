    subroutine calc_frac2()
    USE machine_constants, ONLY: kdp
    USE mcb, only: fresur, ibc, mfsbc, msbc, nsbc, print_dry_col
    !USE mcb_m
    USE mcc, only: jtime, rm_id, solute, steady_flow
    USE mcc_m, only: vmask
    USE mcg, only: cellno, nxyz, nxy, nx, ny, nz
    !USE mcg_m
    USE mcn, only: z, z_node
    USE mcp, only: den0, gz, pv, epssat
    !USE mcp_m
    USE mcv, only: c, deltim, dzfsdt, frac, ns, p, zfs, zfsn
    USE mcv_m, only: is, fir, firv
    !USE mcw
    !USE mcw_m
    USE mg2_m, ONLY: hdprnt, wt_elev
    USE PhreeqcRM
    IMPLICIT NONE
    INTEGER :: status
    CHARACTER(LEN=9) :: cibc
    CHARACTER(LEN=130) :: logline1
    REAL(KIND=kdp) :: denmfs, p1, pmfs,  &
    qlim, qm_in, qm_net, qn, qnp,  &
    u0, u1, ufdt0, ufdt1,  &
    ufrac, up0, z0, z1, z2, zfsl, zm1, zmfs, zp1
    INTEGER :: da_err, i, icol, imod, iwel, j, jcol, k, kcol, kfs, l, lc, l1, ls,  &
    m, m0, m1, m1kp, mfs, mt
    LOGICAL :: ierrw


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
                        IF(frac(m) <= epssat) THEN                 ! ... Falling water table
                            frac(m) = 0._kdp
                            ! ... Set saturation fraction of cell below
                            IF(nz > 2) THEN
                                z1 = z(k)
                                z0 = z(k-1)
                                zm1=z(k-2)
                                ! Set new water table based on the pressure in the cell with the old water table
                                zfs(mt) = z_node(m) + p(m)/(den0*gz)
                                ! Set pressure to correspond to new water table
                                p(m-nxy)=(zfs(mt) - z_node(m-nxy))*(den0*gz)
                                frac(m-nxy)=(2.*zfs(mt)-(z0+zm1))/(z1-zm1)
                                frac(m-nxy)=MAX(0._kdp,frac(m-nxy))     
                                vmask(m-nxy) = 1
                                IF(frac(m-nxy) < 0.5_kdp) vmask(m-nxy) = 0
                            ELSE                    ! ... Bottom plane case for nz = 2
                                IF(p(m-nxy) >= 0._kdp) THEN
                                    up0=p(m-nxy)
                                    z0=z(1)
                                    z1=z(2)
                                    ! Set new water table based on the pressure in the cell with the old water table
                                    zfs(mt) = z_node(m) + p(m)/(den0*gz)
                                    ! Set pressure to correspond to new water table
                                    p(m-nxy)=(zfs(mt) - z_node(m-nxy))*(den0*gz)
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
                            IF(frac(m) <= epssat) THEN                    ! ... Falling water table
                                frac(m) = 0._kdp
                                ! ... Set saturation fraction of cell below
                                if (k > 2) then
                                    zm1=z(k-2)
                                    z0=z(k-1)
                                    z1=z(k)
                                    ! Set new water table based on the pressure in the cell with the old water table
                                    zfs(mt) = z_node(m) + p(m)/(den0*gz)
                                    ! Set pressure to correspond to new water table
                                    p(m-nxy)=(zfs(mt) - z_node(m-nxy))*(den0*gz)
                                    frac(m-nxy)=(2.*zfs(mt)-(z0+zm1))/(z1-zm1)
                                    frac(m-nxy)=MAX(0._kdp,frac(m-nxy))
                                    vmask(m-nxy) = 1
                                    IF(frac(m-nxy) < 0.5_kdp) vmask(m-nxy) = 0
                                else if (k .eq. 2) then
                                    z0=z(k-1)
                                    z1=z(k)
                                    ! Set new water table based on the pressure in the cell with the old water table
                                    zfs(mt) = z_node(m) + p(m)/(den0*gz)
                                    ! Set pressure to correspond to new water table
                                    p(m-nxy)=(zfs(mt) - z_node(m-nxy))*(den0*gz)
                                    frac(m-nxy) = 2.*(zfs(mt)-z0)/(z1-z0)
                                    frac(m-nxy)=MAX(0._kdp,frac(m-nxy))
                                    vmask(m-nxy) = 1
                                    IF(frac(m-nxy) < 0.5_kdp) vmask(m-nxy) = 0                           
                                else
                                    stop "check logic of dropping water table"
                                endif
                            END IF
                        END IF
                    END IF
                END IF
                IF(frac(m) <= epssat) THEN
                    frac(m) = 0._kdp
                    vmask(m) = 0
                END IF
            END DO
    
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
                    IF (frac(m) < 1._kdp + epssat) CYCLE
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
!                DO  k=1,nz-kfs
!                    m1kp=mfs+k*nxy
!                    ! ... Skip specified pressure cells
!                    WRITE(cibc,6001) ibc(m1kp)
!6001                FORMAT(i9.9)
!                    IF(cibc(1:1) /= '1') p(m1kp)=pmfs-denmfs*gz*(z(kfs+k)-zmfs)
!                    IF(solute) THEN
!                        DO  is=1,ns
!                            c(m1kp,is)=0._kdp       ! Dry cell concentration
!                        END DO
!                    END IF
!                END DO
            END DO
        END IF
    END IF


end subroutine calc_frac2