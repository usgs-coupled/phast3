SUBROUTINE sumcal_ss_flow
  ! ... Performs summary calculations at end of time step for steady flow
  USE machine_constants, ONLY: kdp, macheps5
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcch
  USE mcch_m
  USE mcg
  USE mcg_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m, ONLY: hdprnt, wt_elev
  USE PhreeqcRM
  IMPLICIT NONE
  !INCLUDE "RM_interface_F.f90.inc"
  CHARACTER(LEN=9) :: cibc
  REAL(KIND=kdp) :: denmfs, frac_flowresid, p1, pmfs, qfbc,  &
       qlim, qm_net, qn, qnp, u0, u1, u2, u6, uc,  &
       ufdt1, ufrac, up0, z0, z1, z2, zfsl, zm1, zmfs, zp1
  REAL(KIND=kdp) :: hrbc
  INTEGER :: a_err, da_err, i, icol, imod, iwel, j, jcol, k, kcol, kfs,  &
       l, l1, lc, ls, m, m0, m1, m1kp, mfs, mpmax, mt
  LOGICAL :: ierrw
  CHARACTER(LEN=130) :: logline1, logline2
  INTEGER :: status
  !     ------------------------------------------------------------------
  !...
  ufdt1 = fdtmth
  dpmax=0._kdp
  !!$  dhmax=0._kdp
  ! ... Allocate scratch space
  ALLOCATE (zfsn(nxy),  &
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: sumcal1_ss"  
     STOP  
  ENDIF
  DO  m=1,nxyz
     IF(ibc(m) == -1 .OR. frac(m) <= 0.) CYCLE
     ! ... Find maximum changes in dependent variables
     IF(ABS(dp(m)) >= ABS(dpmax)) THEN
        dpmax=dp(m)
        mpmax=m
     END IF
  END DO
  ! ... Decode into IMAX,JMAX,KMAX
  CALL mtoijk(mpmax,ipmax,jpmax,kpmax,nx,ny)
  dhmax = dpmax/(den0*gz)
  ! ... Test for steady-state flow done after flow balance calculation
  ! ... Check for unacceptable time step length
  IF(jtime > 2) THEN
     ! ... Algorithm from Aziz & Settari p.404
     IF(ABS(dpmax) > 1.5*dptas) tsfail=.TRUE.
     IF(tsfail) THEN
        itime=itime-1
        ntsfal=ntsfal+1
        IF(ntsfal > 5 .OR. deltim <= dtimmn) THEN
           ierr(170)=.TRUE.
           errexe=.TRUE.
        END IF
        WRITE(logline1,2001) '     Current time step length '//dots, cnvtmi*deltim,' ('//unittm//')'
2001    FORMAT(a60,1PG12.3,A)
        status = RM_ErrorMessage(rm_id, logline1)
        WRITE(logline1,3001) 'Maximum change in potentiometric head '//dots,  &
             cnvpi*dhmax,' ('//unitl//')',' at location (',  &
             cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(',unitl//')'
3001    FORMAT(A45,1PE14.4,A8,A,3(1PG10.3,A),A)
        status = RM_ErrorMessage(rm_id, logline1)
        DEALLOCATE (zfsn, &
             STAT = da_err)
        IF (da_err /= 0) THEN  
           PRINT *, "Array deallocation failed, sumcal_ss"  
           STOP  
        ENDIF
        RETURN
     END IF
  END IF
  !  time=time+deltim
  ! ... Update the dependent variables
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     ! ... Update the pressure field variable
     p(m)=p(m)+dp(m)
     ! ... Calculate new pore volumes for confined cells
     pv(m)=pv(m)+pmcv(m)*dp(m)
  END DO
  IF(fresur) THEN
     ! ... Calculate fraction of cell that is saturated
     ! ...      for cells that contained the free surface at start of this
     ! ...      time step
     ! ... Use only hydrostatic extrapolation, no interpolation to locate elevation
     ! ...      of free surface
     ! ... Will not handle case of water table moving down more than one cell
     ! ...      per time step
     ! ... Designed to handle movement of the upper regional boundary of saturation;
     ! ...     the free-surface boundary
     DO  mt=1,nxy
        m=mfsbc(mt)          ! ... w.t. cell at time n
        IF(m == 0) CYCLE     ! ... Column of dry cells
        ! ... Save previous frac for rate of free surface movement approximation
        zfsn(mt) = zfs(mt)
        WRITE(cibc,6001) ibc(m)
6001    FORMAT(i9.9)
        IF(cibc(1:1) == '1') CYCLE     ! Frac will be calculated below for 
                                       !  free surface in a specified pressure cell
        imod = MOD(m,nxy)
        k = (m-imod)/nxy + MIN(1,imod)
        IF(k == 1) THEN
           ! ... Bottom plane; hydrostatic
           IF(p(m) > 0._kdp) THEN
              up0=p(m)
              z0=z(1)
              zp1=z(2)
              zfs(mt) = up0/(den0*gz) + z0     ! Hydrostatic
              frac(m) = 2.*(zfs(mt)-z0)/(zp1-z0)
              !  Do not limit frac to < = 1 yet
              vmask(m) = 1
           ELSE
              frac(m) = 0._kdp     ! Falling water table giving empty column of cells
              vmask(m) = 0
           END IF
        ELSE IF(k == nz) THEN
           ! ... Top plane
           IF(p(m) > 0._kdp) THEN
              up0=p(m)
              zm1=z(k-1)
              z0=z(k)
              zfs(mt) = up0/(den0*gz) + z0     ! Hydrostatic
              frac(m) = (2.*zfs(mt)-(z0+zm1))/(z0-zm1)
              vmask(m) = 1
           ELSE
              up0=p(m)
              zm1=z(k-1)
              z0=z(k)
              zfs(mt) = up0/(den0*gz) + z0     ! Hydrostatic
              frac(m) = (2.*zfs(mt)-(z0+zm1))/(z0-zm1)
              vmask(m) = 0
           END IF
           IF(frac(m) < 0.) THEN
              ! ... Falling water table
              frac(m) = 0._kdp
              vmask(m) = 0
              ! ... Set saturation fraction of cell below
              IF(nz > 2) THEN
                 z1 = z(k)
                 z0 = z(k-1)
                 zm1=z(k-2)
                 frac(m-nxy)=(2.*zfs(mt)-(z0+zm1))/(z1-zm1)
                 frac(m-nxy)=MAX(0._kdp,frac(m-nxy))     
                 vmask(m-nxy) = 1                        
                 IF(frac(m-nxy) < 0.5_kdp) vmask(m-nxy) = 0
              ELSE
                 ! ... Bottom plane case for nz = 2
                 IF(p(m-nxy) > 0._kdp) THEN
                    up0=p(m-nxy)
                    z0=z(1)
                    z1=z(2)
                    zfs(mt)=up0/(den0*gz) + z0
                    frac(m-nxy)=2.*(zfs(mt)-z0)/(z1-z0)
                    !  Do not limit frac to < = 1 yet
                    frac(m-nxy)=MAX(0._kdp,frac(m-nxy))
                    vmask(m-nxy) = 1
                 ELSE
                    frac(m)=0._kdp      ! ... Empty column of cells
                    vmask(m-nxy) = 0
                 END IF
              ENDIF
           END IF
        ELSE
           ! ... Intermediate plane
           IF(ibc(m-nxy) == -1) THEN
              IF(p(m) > 0._kdp) THEN
                 up0=p(m)
                 z0=z(k)
                 zp1=z(k+1)
                 zfs(mt) = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = 2.*(zfs(mt)-z0)/(zp1-z0)
                 !  Do not limit frac to < = 1 yet
                 vmask(m) = 1
              ELSE
                 frac(m) = 0._kdp     ! ... Empty column of cells
                 vmask(m) = 0
              END IF
           ELSEIF(ibc(m+nxy) == -1) THEN
              ! ... Treat as top plane
              IF(p(m) > 0._kdp) THEN
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zfs(mt) = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfs(mt)-(z0+zm1))/(z0-zm1)
                 !  Do not limit frac to < = 1 yet
                 vmask(m) = 1
              ELSE
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zfs(mt) = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfs(mt)-(z0+zm1))/(z0-zm1)
                 frac(m) = MAX(0._kdp,frac(m))
                 vmask(m) = 0
              END IF
           ELSE
              ! ... True intermediate plane
              IF(p(m) > 0._kdp) THEN
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zp1=z(k+1)
                 zfs(mt) = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfs(mt)-(z0+zm1))/(zp1-zm1)
                 !  Do not limit frac to < = 1 yet
                 vmask(m) = 1
              ELSE
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zp1=z(k+1)
                 zfs(mt) = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfs(mt)-(z0+zm1))/(zp1-zm1)
                 vmask(m) = 0
              END IF
              IF(frac(m) < 0.) THEN
                 ! ... Falling water table
                 frac(m) = 0._kdp
                 vmask(m) = 0
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
                 zm1=z(k-1)
                 z0=z(k)
                 zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                 frac(m) = MAX(0._kdp,frac(m))
                 vmask(m) = 0
              END IF
           ELSE
              ! ... Intermediate plane
              IF(ibc(m-nxy) == -1) THEN
                 ! ... Treat as bottom plane
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
              ELSEIF(ibc(m+nxy) == -1) THEN
                 ! ... Treat as top plane
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
                    zm1=z(k-1)
                    z0=z(k)
                    zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                    frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                    frac(m) = MAX(0._kdp,frac(m))
                    vmask(m) = 0
                 END IF
              ELSE
                 ! ... True intermediate plane
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
           IF(k < nz) frac(m) = MIN(1._kdp,frac(m))
           IF(frac(m) <= 1.e-6_kdp) THEN
              frac(m) = 0._kdp
              vmask(m) = 0
           END IF
           frac(m) = MAX(0._kdp,frac(m))
           !           END IF
        END DO
     END IF
     ! ... Now adjust the region for rise of free surface as necessary
     ! ... Problems if f.s. rises more than one cell per time step
     DO  mt=1,nxy
        m=mfsbc(mt)          ! f.s. cell at time n
        IF(m == 0) CYCLE     !  Column of dry cells
        ! ... save rate of free surface movement
        dzfsdt(mt) = (zfs(mt) - zfsn(mt))/deltim
        WRITE(cibc,6001) ibc(m)
!!$        IF(cibc(1:1) == '1') CYCLE             ! ... Skip specified pressure cells
        IF(frac(m) > 1._kdp) THEN          ! ... Rewet cell above
           imod = MOD(m,nxy)
           k = (m-imod)/nxy + MIN(1,imod)
           !IF(k == nz .OR. ibc(m+nxy) == -1) CYCLE     !  Treat as top layer
           IF(k == nz) CYCLE
           IF(ibc(m+nxy) == -1) CYCLE
           ! ... Calculate pressure and fraction of saturation in m+nxy cell;
           ! ...      the new free-surface cell
           IF (frac(m) < 1._kdp + 1.e-6_kdp) CYCLE
           up0=p(m)
           z0=z(k)
           z1=z(k+1)
           ! ... Calculate fraction of cell that is newly saturated using
           ! ...      residual volume of fluid from cell below
           frac(m+nxy)=(frac(m)-1._kdp)*pv(m)/pv(m+nxy)
           !IF(k+1 == nz .OR. ibc(m+2*nxy) == -1) THEN
           IF(k+1 == nz) THEN
              zfs(mt)=.5*(z1+z0+frac(m+nxy)*(z1-z0))     ! half cell thickness
           else if (ibc(m+2*nxy) == -1) then
              zfs(mt)=.5*(z1+z0+frac(m+nxy)*(z1-z0))     ! half cell thickness
           ELSE
              z2=z(k+2)
              zfs(mt)=.5*(z1+z0+frac(m+nxy)*(z2-z0))     ! full cell thickness
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
           frac(m)=1._kdp
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
           WRITE(logline1,'(a)') &
                'WARNING: Free surface has moved more than one layer of cells in sumcal_ss_flow'
           status = RM_ScreenMessage(rm_id, logline1)
           status = RM_LogMessage(rm_id, logline1)
           WRITE(logline1,'(tr5,a,i6,a,i5,a,i5)')   &
                'Cell column:', mt,' (i,j):', icol, ',', jcol
           status = RM_ScreenMessage(rm_id, logline1)
           status = RM_LogMessage(rm_id, logline1)                      
        END IF
        IF(m1 == 0 .AND. .NOT.print_dry_col(mt)) THEN
           CALL mtoijk(mt,icol,jcol,kcol,nx,ny)
           WRITE(logline1,'(a)') 'WARNING: A column of cells has gone dry in sumcal_ss_flow'
           status = RM_ScreenMessage(rm_id, logline1)
           status = RM_LogMessage(rm_id, logline1)
           WRITE(logline1,'(tr5,a,i6,a,i5,a,i5)')   &
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
           IF(cibc(1:1) /= '1') p(m1kp)=pmfs-denmfs*gz*(z(kfs+k)-zmfs)
        END DO
     END DO
  END IF
  IF(nwel > 0) THEN
     ! ... Sum the injection rates and production rates for the wells
     tqwfp=0._kdp
     tqwhp=0._kdp
     tqwfi=0._kdp
     tqwhi=0._kdp
     totwfi=0._kdp
     totwfp=0._kdp
     totwhi=0._kdp
     totwhp=0._kdp
     DO  is=1,ns
        tqwsp(is)=0._kdp
        tqwsi(is)=0._kdp
        totwsi(is)=0._kdp
        totwsp(is)=0._kdp
     END DO
     ! ... Obtain well flow rates and conditions
     CALL wbbal
     DO  iwel=1,nwel
        IF(wqmeth(iwel) == 0) CYCLE
        IF(qwm(iwel) <= 0._kdp) THEN      ! ... Production wells
           ! ... Step total flow rates
           ! ... Production rate totals for all wells
           ! ... Cumulative amounts for each well
           stotfp = stotfp-ufdt1*qwm(iwel)
           tqwfp=tqwfp-qwm(iwel)
           stfwp(iwel) = stfwp(iwel)-ufdt1*qwm(iwel)
        ELSE                              ! ... Injection wells
           ! ... Step total flow rates
           ! ... Injection rate totals for all wells
           ! ... Cumulative amounts for each well
           stotfi = stotfi+ufdt1*qwm(iwel)
           tqwfi=tqwfi+qwm(iwel)
           stfwi(iwel) = stfwi(iwel)+ufdt1*qwm(iwel)
        END IF
        ! ... Cumulative amounts for each well and for all wells
!$$        wfpcum(iwel)=wfpcum(iwel)+stfwp(iwel)*deltim
!$$        wficum(iwel)=wficum(iwel)+stfwi(iwel)*deltim
        ! ... Convert step total flow rates to step total amounts and add net to
        ! ...      the sum for the wells
        stfwel=stfwel+(stfwi(iwel)-stfwp(iwel))*deltim
!$$        totwfp=totwfp+wfpcum(iwel)
!$$        totwfi=totwfi+wficum(iwel)
     END DO
  END IF
  ! ... Calculate specified P b.c. cell boundary flow rates 
!!$  IF(nsbc > 0) THEN
!!$     ! ... Fluid flows calculated in ITER
!!$     !...         CALL SBCFLO(1,DP,FRACNP,QFSBC,RHFSBC,VAFSBC)
!!$  END IF
!!$  erflg=.FALSE.
  DO l=1,nsbc
     m=msbc(l)
     IF(frac(m) <= 0._kdp) CYCLE
     WRITE(cibc,6001) ibc(m)
     ! ... Sum fluid and diffusive or associated solute fluxes
     ! ...      Flow rates calculated in SBCFLO
     IF(cibc(1:1) == '1') THEN
        IF(qfsbc(l) <= 0._kdp) THEN       ! ... Outflow boundary
           stotfp=stotfp-qfsbc(l)   ! .. wt factor included
        ELSE                              ! ... Inflow boundary
           stotfi=stotfi+qfsbc(l)   ! .. wt factor included
        END IF
!$$        sfsb(l)=qfsbc(l)
!$$        sfvsb(l)=qfsbc(l)/den0
        stfsbc=stfsbc+qfsbc(l)   ! .. wt factor included
     END IF
  END DO
  ! ... Compute total cumulative cell flow amounts
  ! ...      flow rate is over entire time step by balance calculation
!  DO  l=1,nsbc
!     ccfsb(l)=ccfsb(l)+sfsb(l)*deltim
!     ccfvsb(l)=ccfvsb(l)+sfvsb(l)*deltim
!  END DO
  ! ... Convert step total flow rates to step total amounts
  stfsbc=stfsbc*deltim
  ! ... Add to cumulative totals
!  tcfsbc=tcfsbc+stfsbc
  ! ... Specified flux b.c.
!$$  erflg=.FALSE.
  DO lc=1,nfbc_cells
     m = flux_seg_m(lc)
     qffbc(lc) = 0._kdp
!$$     qsfbc(lc,:) = 0._kdp
!$$     sffb(lc) = 0._kdp
!$$     sfvfb(lc) = 0._kdp
     IF(m == 0) CYCLE     ! ... dry column
     DO ls=flux_seg_first(lc),flux_seg_last(lc)
        ufrac = 1._kdp
        IF(ABS(ifacefbc(ls)) < 3) ufrac = frac(m)  
        IF(fresur .AND. ifacefbc(ls) == 3 .AND. frac(m) <= 0._kdp) THEN
           ! ... Redirect the flux from above to the free-surface cell
           l1 = MOD(m,nxy)
           IF(l1 == 0) l1 = nxy
           m = mfsbc(l1)
        ENDIF
        IF (m == 0) EXIT          ! ... dry column, skip to next flux b.c. cell
        qn = qfflx(ls)*areafbc(ls)
        IF(qn <= 0.) THEN              ! ... Outflow
           qfbc = den0*qn*ufrac
           qffbc(lc) = qffbc(lc) + qfbc
           stotfp = stotfp-ufdt1*qfbc
        ELSE                           ! ... Inflow
           qfbc = denfbc(ls)*qn*ufrac
           qffbc(lc) = qffbc(lc) + qfbc
           stotfi = stotfi+ufdt1*qfbc
        END IF
     END DO
!$$     sffb(l)=sffb(l)+qfbc
!$$     sfvfb(l)=sfvfb(l)+qn
     stffbc = stffbc+ufdt1*qfbc
  END DO
  ! ... Convert step total flow rates to step total amounts
  stffbc = stffbc*deltim
!$$  tcffbc=tcffbc+stffbc
  ! ... Aquifer leakage b.c.
  DO lc=1,nlbc_cells
     m = leak_seg_m(lc)
     qflbc(lc) = 0._kdp
!$$     sflb(lc) = 0._kdp
!$$     sfvlb(lc) = 0._kdp
     IF(m == 0) CYCLE
     ! ... Calculate current net aquifer leakage flow rate
     qm_net = 0._kdp
     DO ls=leak_seg_first(lc),leak_seg_last(lc)
        qnp = albc(ls) - blbc(ls)*dp(m)  
        IF(qnp <= 0._kdp) THEN           ! ... Outflow
           qm_net = qm_net + den0*qnp
        ELSE                            ! ... Inflow
           IF(fresur .AND. ifacelbc(ls) == 3) THEN
              ! ... Limit the flow rate for unconfined z-face leakage from above
              qlim = blbc(ls)*(denlbc(ls)*philbc(ls) - gz*(denlbc(ls)*(zelbc(ls)-0.5_kdp*bblbc(ls))  &
                   - 0.5_kdp*den0*bblbc(ls)))
              qnp = MIN(qnp,qlim)
           END IF
           qm_net = qm_net + denlbc(ls)*qnp
        ENDIF
     END DO
     qflbc(lc) = qm_net
     stflbc = stflbc + ufdt1*qflbc(lc)
     IF(qm_net <= 0._kdp) THEN           ! ... net outflow
	stotfp = stotfp - ufdt1*qflbc(lc)			
     ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
        stotfi = stotfi + ufdt1*qflbc(lc)
     END IF
  END DO
  ! ... Convert step total flow rates to step total amounts
  stflbc = stflbc*deltim
!$$  tcflbc=tcflbc+stflbc
  ! ... River leakage b.c.
  DO lc=1,nrbc_cells
      m = river_seg_m(lc)
      qfrbc(lc) = 0._kdp
      !$$     sfrb(lc) = 0._kdp
      !$$     sfvrb(lc) = 0._kdp
      IF(m == 0) CYCLE          ! ... dry column, skip to next river b.c. cell
      ! ... Calculate current net river leakage flow rate
      qm_net = 0._kdp
      DO ls=river_seg_first(lc),river_seg_last(lc)
          if (arbc(ls) .gt. 1.0e50_kdp) cycle
          qnp = arbc(ls) - brbc(ls)*dp(m)
          hrbc = phirbc(ls)/gz
          if(hrbc > zerbc(ls)) then      ! ... treat as river
              IF(qnp <= 0._kdp) THEN          ! ... Outflow
                  qm_net = qm_net + den0*qnp
              ELSE                            ! ... Inflow
                  ! ... Limit the flow rate for a river leakage
                  qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                  - 0.5_kdp*den0*bbrbc(ls)))
                  qnp = MIN(qnp,qlim)
                  qm_net = qm_net + denrbc(ls)*qnp
              ENDIF
          else                           ! ... treat as drain 
              IF(qnp <= 0._kdp) THEN           ! ... Outflow
                  qm_net = qm_net + den0*qnp
                  !qfbc = den(m)*qnp
                  !qfrbc(lc) = qfrbc(lc) + qfbc
                  !stotfp = stotfp-ufdt1*qfbc
              ELSE                            ! ... Inflow
                  qfbc = 0._kdp
                  !qfrbc(lc) = qfrbc(lc) + qfbc
                  !stotfi = stotfi+ufdt1*qfbc
              end IF
          end if            
      END DO
      qfrbc(lc) = qm_net
      stfrbc = stfrbc + ufdt1*qfrbc(lc)
      IF(qm_net <= 0._kdp) THEN           ! ... net outflow
          stotfp = stotfp - ufdt1*qfrbc(lc)			
      ELSEIF(qm_net > 0._kdp) THEN        ! ... net inflow
          stotfi = stotfi + ufdt1*qfrbc(lc)
      else                       ! ... no inflow or outflow; treat as drain
          qnp = 0._kdp
          qfbc = 0._kdp
          !stotfi = stotfi + ufdt1*qfbc
          !sfvrb(lc) = sfvrb(lc) + qnp
      ENDIF
  END DO
  ! ... Convert step total flow rates to step total amounts
  stfrbc = stfrbc*deltim
  ! ... Do not update the indices connecting river to aquifer yet!
  ! ... Drain leakage b.c.
!!$  erflg=.FALSE.
  DO lc=1,ndbc_cells
      m = drain_seg_m(lc)
      qfdbc(lc) = 0._kdp
      !$$     sfdb(lc) = 0._kdp
      !$$     sfvdb(lc) = 0._kdp
      IF(m == 0) CYCLE
      DO ls=drain_seg_first(lc),drain_seg_last(lc)
          if (adbc(ls) .gt. 1.0e50_kdp) cycle
          qnp = adbc(ls) - bdbc(ls)*dp(m)
          IF(qnp <= 0._kdp) THEN           ! ... Outflow
              qfbc = den0*qnp
              qfdbc(lc) = qfdbc(lc) + qfbc
              stotfp = stotfp - ufdt1*qfbc
          ELSE                            ! ... Inflow
              qfbc = 0._kdp
              !qfdbc(lc) = qfdbc(lc) + qfbc
              !stotfi = stotfi + ufdt1*qfbc
          ENDIF
      END DO
      !$$     sfdb(lc)=sfdb(lc) + qfdbc(lc)
      !$$     sfvdb(lc)=sfvdb(lc) + qm_net/den0   ! *** Only valid for constant density
      stfdbc = stfdbc + ufdt1*qfdbc(lc)
  END DO
  ! ... Convert step total flow rates to step total amounts
  stfdbc = stfdbc*deltim
  ! ... Do not update the indices connecting drain to aquifer yet!
!!$  ! ... Calculate aquifer influence function boundary flow rates
!!$  !... *** not implemented for PHAST
!!$  erflg=.FALSE.
!!$  DO  l=1,naifc
!!$     m=maifc(l)
!!$     IF(m == 0) CYCLE
!!$     qnp=aaif(l)+baif(l)*dp(m)
!!$     ! ... Update aquifer influence function cumulative net inflow
!!$     wcaif(l)=wcaif(l)+qnp*deltim
!!$     IF(qnp <= 0.) THEN
!!$        ! ... Outflow
!!$        uden=den(m)
!!$        qfaif(l)=uden*qnp
!!$        stotfp=stotfp-0.5*qfaif(l)
!!$     ELSE
!!$        ! ... Inflow
!!$        uden=denoar(l)
!!$        qfaif(l)=uden*qnp
!!$        stotfi=stotfi+0.5*qfaif(l)
!!$     END IF
!!$!     sfaif(l)=sfaif(l)+qfaif(l)
!!$!     sfvaif(l)=sfvaif(l)+qnp
!!$     stfaif=stfaif+0.5*uden*wcaif(l)
!!$  END DO
!!$  ! ... Compute cumulative cell flow amounts
!!$!  DO  l=1,naifc
!!$!     ccfaif(l)=ccfaif(l)+0.5*sfaif(l)*deltim
!!$!     ccfvai(l)=ccfvai(l)+0.5*sfvaif(l)*deltim
!!$!  END DO
!!$  ! ... Convert step total flow rates to step total amounts
!!$  ! ... Following line suspended because WCAIF is cumulative total flow.
!!$  !...            STFAIF=STFAIF*DELTIM
!!$!  tcfaif=tcfaif+stfaif
  ! ... Calculate the internal zone flow rates if requested
  IF(ABS(pri_zf) > 0. .or. ABS(pri_zf_tsv) > 0.) CALL zone_flow_ss
  ! ... Calculate total fluid mass, fluid volume in region
  ! ... Calculate head field and water-table elevation (if desired for printout)
  fir=0._kdp
  firv=0._kdp
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     IF(frac(m) <= 0._kdp) CYCLE
     u0=pv(m)*frac(m)
     u1=0._kdp
     fir=fir+u0*den0
     firv=firv+u0
     IF(ABS(prip) > 0. .OR. ABS(prihdf_head) > 0. .OR. ABS(primaphead) > 0.) THEN
        ! ... Calculate head field
        imod = MOD(m,nxy)
        k = (m-imod)/nxy + MIN(1,imod)
        hdprnt(m)=z(k)+p(m)/(den0*gz)
     END IF
  END DO
  IF(fresur .AND. (ABS(prip) > 0. .OR. ABS(primaphead) > 0.)) THEN
     ! ... Calculate water-table elevation
     DO mt=1,nxy
        m = mfsbc(mt)
        IF (m > 0) THEN
           wt_elev(mt) = z_node(m) + p(m)/(den0*gz)
        END IF
     END DO
  END IF
  ! ... Change in fluid over time step
  dfir=fir-firn
  ! ... Test for steady-state flow
  frac_flowresid = (stotfi-stotfp)/(0.5*(stotfi+stotfp)+macheps5)
  WRITE(logline1,3001) '     Maximum change in potentiometric head '//dots,  &
       cnvpi*dhmax,' ('//TRIM(unitl)//')',' at location (',  &
       cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax),')(',TRIM(unitl)//')'
  WRITE(logline2,3001) '     Fractional flow residual '//dots,frac_flowresid
    status = RM_LogMessage(rm_id, logline1)
    status = RM_LogMessage(rm_id, logline2)
    status = RM_ScreenMessage(rm_id, logline1)
    status = RM_ScreenMessage(rm_id, logline2)
  IF((ABS(dpmax) <= eps_p) .AND. ABS(frac_flowresid) <= eps_flow) converge_ss = .TRUE.
  ! ... Convert step total flow rates to step total amounts
  stotfi=stotfi*deltim
  stotfp=stotfp*deltim
!  totfi=totfi+stotfi
!  totfp=totfp+stotfp
  ! ... Fluid mass balance calculations
  sfres=dfir-stotfi+stotfp
!  tfres=fir-fir0-totfi+totfp
  u1=MAX(ABS(dfir),stotfi,stotfp)
  sfresf = 1.e99_kdp
  IF(u1 > 0.) sfresf=sfres/u1
!  u1=MAX(ABS(fir-fir0),totfi,totfp)
!  IF(u1 > 0.) tfresf=tfres/u1
  DEALLOCATE (zfsn, &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, sumcal_ss"  
     STOP  
  ENDIF
END SUBROUTINE sumcal_ss_flow
