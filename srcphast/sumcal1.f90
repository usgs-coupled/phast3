SUBROUTINE sumcal1
  ! ... Performs summary calculations at end of time step
  ! ... This is the first block of sumcal. The second block follows the
  ! ...      chemical reaction calculations
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcc
  USE mcch
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcv
  USE mcw
  USE mg2, ONLY: hdprnt, qfbcv
  IMPLICIT NONE
  INTERFACE
     SUBROUTINE sbcflo(iequ,ddv,ufracnp,qdvsbc,rhssbc,vasbc)
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) :: iequ
       REAL(KIND=kdp), DIMENSION(0:), INTENT(IN) :: ddv
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: ufracnp
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: qdvsbc
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: rhssbc
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: vasbc
     END SUBROUTINE sbcflo
  END INTERFACE
  !
!!$  CHARACTER(LEN=50) :: aform = '(TR5,A45,T47,1PE12.4,TR1,A7,T66,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=46) :: aformt = '(TR5,A43,1PE12.4,TR1,A7,TR1,A,3(1PG10.3,A),2A)'
  CHARACTER(LEN=9) :: cibc
  REAL(KIND=kdp) :: denmfs, p1, pmfs, qfbc,  &
       qlim, qm_in, qm_net, qn, qnp,  &
       u0, u1, ufdt0, ufdt1,  &
       ufrac, up0, z0, z1, z2, zfsl, zm1, zmfs, zp1
  REAL(KIND=kdp) :: u6
  REAL(KIND=kdp), PARAMETER :: epssat = 1.e-6_kdp  
  INTEGER :: a_err, da_err, i, imod, iwel, j, k, kfs, l, lc, l1, ls, m, m0, m1,  &
       m1kp, mfs, mt,  &
       nsa
  INTEGER :: mpmax, mtmax
  INTEGER, DIMENSION(:), ALLOCATABLE :: mcmax
  LOGICAL :: erflg, ierrw
  CHARACTER(LEN=130) :: logline1
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: cavg, sum_cqm_in
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: qsbc3, qsbc4
  REAL(KIND=kdp), DIMENSION(nxy) :: fracn
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: sumcal1.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  ufdt0 = 1._kdp - fdtmth
  ufdt1 = fdtmth
  dpmax=0._kdp
  dhmax=0._kdp
  dtmax=0._kdp
  DO  is=1,ns
     dcmax(is)=0._kdp
  END DO
  ! ... Allocate scratch space
  nsa = MAX(ns,1)
  ALLOCATE (mcmax(nsa),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: sumcal1"  
     STOP  
  ENDIF
  DO  m=1,nxyz
     IF(ibc(m) == -1.OR.frac(m) <= 0.) CYCLE
     ! ... Find maximum changes in dependent variables
     IF(ABS(dp(m)) >= ABS(dpmax)) THEN
        dpmax=dp(m)
        mpmax=m
     END IF
!!$     IF(heat) THEN
!!$        IF((ABS(dt(m)) >= ABS(dtmax))) THEN
!!$           dtmax=dt(m)
!!$           mtmax=m
!!$        END IF
!!$     END IF
     IF(solute) THEN
        DO  is=1,ns
           IF((ABS(dc(m,is)) >= ABS(dcmax(is)))) THEN
              dcmax(is)=dc(m,is)
              mcmax(is)=m
           END IF
        END DO
     END IF
  END DO
  ! ... Decode into IMAX,JMAX,KMAX
  CALL mtoijk(mpmax,ipmax,jpmax,kpmax,nx,ny)
  dhmax=dpmax/(den0*gz)
!!$  IF(heat) CALL mtoijk(mtmax,itmax,jtmax,ktmax,nx,ny)
  DO  is=1,ns
     CALL mtoijk(mcmax(is),icmax(is),jcmax(is),kcmax(is),nx,ny)
  END DO
  DEALLOCATE (mcmax, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, sumcal1"  
     STOP  
  ENDIF
  ! ... Check for unacceptable time step length
  ! ...  ***not used at present ***
  IF(autots .AND. jtime > 2) THEN
     ! ... Algorithm from Aziz & Settari p.404
     IF(ABS(dpmax) > 1.5*dptas) tsfail=.TRUE.
     IF(ABS(dtmax) > 1.5*dttas) tsfail=.TRUE.
     DO  is=1,ns
        IF(ABS(dcmax(is)) > 1.5*dctas(is)) tsfail=.TRUE.
     END DO
     IF(tsfail) THEN
        itime=itime-1
        ntsfal=ntsfal+1
        IF(ntsfal > 5.OR.deltim <= dtimmn) THEN
           ierr(170)=.TRUE.
           errexe=.TRUE.
        END IF
        WRITE(logline1,2001) 'Current time step length '//dots,cnvtmi*deltim,'  ('//unittm//')'
2001    FORMAT(a60,1PG12.3,A)
        CALL logprt_c(logline1)
        WRITE(logline1,2002) 'Current time step length .....',cnvtmi*deltim,'  ('//unittm//')'
2002    FORMAT(a,1PG12.3,A)
        WRITE(*,2012) TRIM(logline1)
2012    FORMAT(/tr5,a)
        WRITE(logline1,5001) 'Maximum change in potentiometric head '//dots,  &
             cnvpi*dhmax,' ('//unitl//')',' at location (',  &
             cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax), ')(',unitl//')'
5001    FORMAT(A45,1PE14.4,A8,A,3(1PG10.3,A),A)
        CALL logprt_c(logline1)
        WRITE(*,aformt) 'Maximum change in potentiometric head '//dots,  &
             cnvpi*dhmax,'('//unitl//')','at location (',  &
             cnvli*x(ipmax),',',cnvli*y(jpmax),',',cnvli*z(kpmax), ')(',unitl,')'
!!$        IF(heat) THEN
!!$           WRITE(fuclog,aform) 'Maximum change in temperature '//dots,  &
!!$                cnvt1i*dtmax+cnvt2i,'(Deg.'//unitt//')',  &
!!$                'at location (',cnvli*x(itmax),',',  &
!!$                cnvli*y(jtmax),',',cnvli*z(ktmax),')(',unitl,')'
!!$           WRITE(*,aformt) 'Maximum change in temperature '//dots,  &
!!$                cnvt1i*dtmax+cnvt2i,'(Deg.'//unitt//')','at location (',cnvli*x(itmax),',',  &
!!$                cnvli*y(jtmax),',',cnvli*z(ktmax),')(',unitl,')'
!!$        END IF
        DO  is=1,ns
           WRITE(logline1,3102) 'Component no. ',is,'  ',comp_name(is)
3102       FORMAT(a,i4,a,a)
           CALL logprt_c(logline1)
           WRITE(*,2102) 'Component no. ',is,comp_name(is)
2102       FORMAT(/tr10,a,i4,tr2,a)
           u6=dcmax(is)
           WRITE(logline1,5001) 'Maximum change in '//mflbl//'fraction '//dots,  &
                u6,'(-)','at location (',cnvli*x(icmax(is)),',',cnvli*y(jcmax(is)),',',  &
                cnvli*z(kcmax(is)),' )(',unitl//')'
           CALL logprt_c(logline1)
           WRITE(*,aformt) 'Maximum change in '//mflbl//'fraction '//dots,  &
                u6,'(-)','at location (',  &
                cnvli*x(icmax(is)),',',cnvli*y(jcmax(is)),',',  &
                cnvli*z(kcmax(is)),')(',unitl,')'
        END DO
        RETURN
     END IF
  END IF
  time = time + deltim
  ! ... Update the dependent variables
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     IF(.NOT.steady_flow .OR. itime > 1) THEN
        ! ... Skip pressure and pore volume if steady state i.c. was just calculated
        p(m)=p(m)+dp(m)
        ! ... Calculate new pore volumes for confined cells
        pv(m)=pv(m)+pmcv(m)*dp(m)
     END IF
!!$     IF(heat) THEN
!!$        t(m)=t(m)+dt(m)
!!$        !            UT=T(M)
!!$        pmhv(m)=pmhv(m)+pmchv(m)*dp(m)
!!$     END IF
     DO  is=1,ns
        c(m,is)=c(m,is)+dc(m,is)
     END DO
     ! ... Update density, viscosity, and enthalpy
     !... *** not needed for PHAST
  END DO
  ! ... Flow and transport have been done; Update free surface but no resaturation
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
        IF(m == 0) CYCLE     ! ... Column of dry cells; can not rewet
        ! ... Save previous frac for rate of free surface movement approximation
        fracn(mt) = frac(m)
        WRITE(cibc,6001) ibc(m)
6001    FORMAT(i9)
!!$        IF(cibc(1:1) == '1') CYCLE     ! Frac is already calculated in INIT3 for 
        ! ... Do the specified pressure cells anyway so that a compatible pressure field
        ! ...    is used for interpolation
        !   free surface in a specified pressure cell
        imod = MOD(m,nxy)
        k = (m-imod)/nxy + MIN(1,imod)
        IF(k == 1) THEN
           ! ... Bottom plane; hydrostatic
           IF(p(m) > 0._kdp) THEN
              up0=p(m)
              z0=z(1)
              zp1=z(2)
              zfs(mt) = up0/(den(m)*gz) + z0     ! Hydrostatic
              frac(m) = 2.*(zfs(mt)-z0)/(zp1-z0)
              !  Do not limit frac to < = 1 yet
              vmask(m) = 1
           ELSE
              frac(m) = epssat     ! ... don't let cell go dry yet
              vmask(m) = 0
           END IF
        ELSE IF(k == nz) THEN
           ! ... Top plane
           IF(p(m) > 0._kdp) THEN
              up0=p(m)
              zm1=z(k-1)
              z0=z(k)
              zfs(mt) = up0/(den(m)*gz) + z0     ! Hydrostatic
              frac(m) = (2.*zfs(mt)-(z0+zm1))/(z0-zm1)
              !  Do not limit frac to < = 1 yet
              vmask(m) = 1
           ELSE
              up0=p(m)
              zm1=z(k-1)
              z0=z(k)
              zfs(mt) = up0/(den(m)*gz) + z0     ! Hydrostatic
              frac(m) = (2.*zfs(mt)-(z0+zm1))/(z0-zm1)
              vmask(m) = 0
              IF(frac(m) < 0.) THEN                 ! ... Falling water table
                 frac(m) = epssat     
                 ! ... do not set saturation fraction of cell below yet
              END IF
           END IF
        ELSE
           ! ... Intermediate plane
           IF(ibc(m-nxy) == -1) THEN
              ! ... Treat as bottom plane
              IF(p(m) > 0._kdp) THEN
                 up0=p(m)
                 z0=z(k)
                 zp1=z(k+1)
                 zfs(mt) = up0/(den(m)*gz) + z0     ! Hydrostatic
                 frac(m) = 2.*(zfs(mt)-z0)/(zp1-z0)
                 !  Do not limit frac to < = 1 yet
                 vmask(m) = 1
              ELSE
                 frac(m) = epssat     ! ... do not empty column of cells yet
                 vmask(m) = 0
              END IF
           ELSEIF(ibc(m+nxy) == -1) THEN
              ! ... Treat as top plane
              IF(p(m) > 0._kdp) THEN
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zfs(mt) = up0/(den(m)*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfs(mt)-(z0+zm1))/(z0-zm1)
                 !  Do not limit frac to < = 1 yet
                 vmask(m) = 1
              ELSE
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zfs(mt) = up0/(den(m)*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfs(mt)-(z0+zm1))/(z0-zm1)
                 frac(m) = MAX(epssat,frac(m))      ! ... do not empty yet
                 vmask(m) = 0
              END IF
           ELSE
              ! ... True intermediate plane
              IF(p(m) > 0._kdp) THEN
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zp1=z(k+1)
                 zfs(mt) = up0/(den(m)*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfs(mt)-(z0+zm1))/(zp1-zm1)
                 !  Do not limit frac to < = 1 yet
                 vmask(m) = 1
              ELSE
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zp1=z(k+1)
                 zfs(mt) = up0/(den(m)*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfs(mt)-(z0+zm1))/(zp1-zm1)
                 vmask(m) = 0
                 IF(frac(m) < 0.) THEN                 ! ... Falling water table
                    frac(m) = epssat
                 END IF
              END IF
           END IF
        END IF
     END DO
     ! ... Calculate fraction of specified pressure cell that is
     ! ...      saturated, only after time of change
     !*****This seems redundant. Done in INIT3. But at time zero, the i.c. pressure is used
     !*** ...  instead of b.c. pressure
     ! ... The psbc are not applied until assembly so init3 only has p at time level n.
     !***  could use psbc directly, but time of application to frac would not be right.
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
                 zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
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
                 zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                 vmask(m) = 1
              ELSE
                 up0=p(m)
                 zm1 = z(k-1)
                 z0 = z(k)
                 zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                 frac(m)=MAX(0._kdp,frac(m))
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
                    zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
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
                    zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
                    frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                    frac(m) = MIN(1._kdp,frac(m))
                    vmask(m) = 1
                 ELSE
                    up0=p(m)
                    zm1 = z(k-1)
                    z0 = z(k)
                    zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
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
                    zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
                    frac(m) = (2.*zfsl-(z0+zm1))/(zp1-zm1)
                    frac(m) = MIN(1._kdp,frac(m))
                    vmask(m) = 1
                 ELSE
                    up0=p(m)
                    zm1=z(k-1)
                    z0=z(k)
                    zp1=z(k+1)
                    zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
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
     ! ... Do not adjust the region for rise of free surface
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
        IF(qwm(iwel) <= 0._kdp) THEN     ! ... Production wells
           ! ... Step total flow rates
           ! ... Production rate totals for all wells
           ! ... Cumulative amounts for each well
           stotfp = stotfp-ufdt1*qwm(iwel)
           tqwfp=tqwfp-qwm(iwel)
           stfwp(iwel) = stfwp(iwel)-ufdt1*qwm(iwel)
!!$           IF(heat) THEN
!!$              stothp=stothp-ufdt1*qhw(iwel)
!!$              tqwhp=tqwhp-qhw(iwel)
!!$              sthwp(iwel)=sthwp(iwel)-ufdt1*qhw(iwel)
!!$           END IF
           DO  is=1,ns
              stotsp(is) = stotsp(is)-ufdt1*qsw(iwel,is)
              tqwsp(is)=tqwsp(is)-qsw(iwel,is)
              stswp(iwel,is) = stswp(iwel,is)-ufdt1*qsw(iwel,is)
           END DO
        ELSE                             ! ... Injection wells
           ! ... Step total flow rates
           ! ... Injection rate totals for all wells
           ! ... Cumulative amounts for each well
           stotfi = stotfi+ufdt1*qwm(iwel)
           tqwfi=tqwfi+qwm(iwel)
           stfwi(iwel) = stfwi(iwel)+ufdt1*qwm(iwel)
!!$           IF(heat) THEN
!!$              stothi=stothi+ufdt1*qhw(iwel)
!!$              tqwhi=tqwhi+qhw(iwel)
!!$              sthwi(iwel)=sthwi(iwel)+ufdt1*qhw(iwel)
!!$           END IF
           DO  is=1,ns
              stotsi(is) = stotsi(is)+ufdt1*qsw(iwel,is)
              tqwsi(is)=tqwsi(is)+qsw(iwel,is)
              stswi(iwel,is) = stswi(iwel,is)+ufdt1*qsw(iwel,is)
           END DO
        END IF
        ! ... Cumulative amounts for each well and for all wells
        wfpcum(iwel)=wfpcum(iwel)+stfwp(iwel)*deltim
        wficum(iwel)=wficum(iwel)+stfwi(iwel)*deltim
        ! ... Convert step total flow rates to step total amounts and add net to
        ! ...      the sum for the wells
        stfwel=stfwel+(stfwi(iwel)-stfwp(iwel))*deltim
!!$        sthwel=sthwel+(sthwi(iwel)-sthwp(iwel))*deltim
        DO  is=1,ns
           stswel(is)=stswel(is)+(stswi(iwel,is)-stswp(iwel,is))*deltim
        END DO
        totwfp=totwfp+wfpcum(iwel)
        totwfi=totwfi+wficum(iwel)
!!$        IF(heat) THEN
!!$           whpcum(iwel)=whpcum(iwel)+sthwp(iwel)*deltim
!!$           whicum(iwel)=whicum(iwel)+sthwi(iwel)*deltim
!!$           totwhp=totwhp+whpcum(iwel)
!!$           totwhi=totwhi+whicum(iwel)
!!$        END IF
        DO  is=1,ns
           wspcum(iwel,is)=wspcum(iwel,is)+stswp(iwel,is)*deltim
           wsicum(iwel,is)=wsicum(iwel,is)+stswi(iwel,is)*deltim
           totwsp(is)=totwsp(is)+wspcum(iwel,is)
           totwsi(is)=totwsi(is)+wsicum(iwel,is)
        END DO
     END DO
  END IF
  ! ... Calculate specified P,C b.c. cell boundary flow rates and amounts
  ! ...      and associated solute flow rates and amounts
  IF(nsbc > 0) THEN
     ! ... Fluid flows calculated in ASMSLP
     !...         CALL SBCFLO(1,DP,FRACNP,QFSBC,RHFSBC,VAFSBC)
!!$     IF(heat) CALL sbcflo(2,dt,fracnp,qhsbc,rhhsbc,vahsbc)
     DO  is=1,ns
        dcv => dc(0:,is)
        qssbcv => qssbc(:,is)
        rhsbcv => rhssbc(:,is)
        vasbcv => vassbc(:,:,is)
        CALL sbcflo(3,dcv,fracnp,qssbcv,rhsbcv,vasbcv)
     END DO
  END IF
  erflg=.FALSE.
  DO l=1,nsbc
     m=msbc(l)
     ! ... In case of specified head in dry cells
     sfsb(l) = 0._kdp
     sfvsb(l) = 0._kdp
     DO  is=1,ns
        sssb(l,is) = 0._kdp
     END DO
     IF(frac(m) <= 0._kdp) CYCLE
     WRITE(cibc,6001) ibc(m)
     ! ... Sum fluid and diffusive or associated heat and solute fluxes
     ! ...      Flow rates calculated in SBCFLO
     IF(cibc(1:1) == '1') THEN
        IF(qfsbc(l) <= 0._kdp) THEN       ! ... Outflow boundary
           stotfp=stotfp-qfsbc(l)   ! .. wt factor included
        ELSE                              ! ... Inflow boundary
           stotfi=stotfi+qfsbc(l)   ! .. wt factor included
        END IF
        sfsb(l)=qfsbc(l)
        sfvsb(l)=qfsbc(l)/den(m)
        stfsbc=stfsbc+qfsbc(l)   ! .. wt factor included
        ! ... Calculate advective heat and solute flows at specified
        ! ...      pressure b.c. cells
!!$        IF(heat.AND.cibc(4:4) /= '1') THEN
!!$           IF(qfsbc(l) <= 0._kdp) THEN
!!$              ! ... Outflow boundary
!!$              qhsbc(l)=qfsbc(l)*(eh(m)-ufdt0*cpf*dt(m))
!!$              stothp=stothp-qhsbc(l)
!!$           ELSE
!!$              qhsbc(l)=qfsbc(l)*ehoftp(tsbc(l),p(m),erflg)
!!$              stothi=stothi+qhsbc(l)
!!$           END IF
!!$           !               SHSB(L)=QHSBC(L)
!!$           !               STHSBC=STHSBC+QHSBC(L)
!!$        END IF
        IF(cibc(7:7) /= '1') THEN
           DO  is=1,ns
              IF(qfsbc(l) <= 0._kdp) THEN
!!$                 qssbc(l,is)=qfsbc(l)*c(m,is)
                 qssbc(l,is)=qfsbc(l)*(c(m,is)-ufdt0*dc(m,is))
                 stotsp(is) = stotsp(is)-qssbc(l,is)     ! .. wt factor included
              ELSE
                 qssbc(l,is)=qfsbc(l)*csbc(l,is)
                 stotsi(is) = stotsi(is)+qssbc(l,is)     ! .. wt factor included
              END IF
              sssb(l,is)=qssbc(l,is)
              stssbc(is) = stssbc(is)+qssbc(l,is)   ! .. wt factor included
           END DO
        END IF
     END IF
!!$     IF(cibc(4:4) == '1') THEN
!!$        IF(qhsbc(l) <= 0) THEN
!!$           ! ... Outflow boundary
!!$           stothp=stothp-qhsbc(l)
!!$        ELSE
!!$           ! ... Inflow boundary
!!$           stothi=stothi+qhsbc(l)
!!$        END IF
!!$        !            SHSB(L)=QHSBC(L)
!!$        !            STHSBC=STHSBC+QHSBC(L)
!!$     END IF
     IF(cibc(7:7) == '1') THEN
        DO  is=1,ns
           IF(qssbc(l,is) <= 0) THEN              ! ... Outflow boundary
              stotsp(is) = stotsp(is)-qssbc(l,is)     ! .. wt factor included
           ELSE                                   ! ... Inflow boundary
              stotsi(is) = stotsi(is)+qssbc(l,is)     ! .. wt factor included
           END IF
           sssb(l,is)=qssbc(l,is)
           stssbc(is) = stssbc(is)+qssbc(l,is)     ! .. wt factor included
        END DO
     END IF
  END DO
  ! ... Compute total cumulative cell flow amounts
  ! ...      flow rate is over entire time step by balance calculation
  DO  l=1,nsbc
     ccfsb(l) = ccfsb(l)+sfsb(l)*deltim
     ccfvsb(l) = ccfvsb(l)+sfvsb(l)*deltim
!!$     CCHSB(L)=CCHSB(L)+SHSB(L)*DELTIM
     DO  is=1,ns
        ccssb(l,is) = ccssb(l,is)+sssb(l,is)*deltim
     END DO
  END DO
  ! ... Convert step total flow rates to step total amounts
  stfsbc=stfsbc*deltim
!!$  STHSBC=STHSBC*DELTIM
  ! ... Add to cumulative totals
  tcfsbc=tcfsbc+stfsbc
!!$  TCHSBC=TCHSBC+STHSBC
  DO  is=1,ns
     stssbc(is)=stssbc(is)*deltim
     tcssbc(is)=tcssbc(is)+stssbc(is)
  END DO
  ! ... Specified flux b.c.
  erflg=.FALSE.
  ! ... Allocate scratch space
  ALLOCATE (qsbc3(nsa), qsbc4(nsa), &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: sumcal1"  
     STOP
  ENDIF
  DO  l=1,nfbc
     m=mfbc(l)
     ufrac=frac(m)
     ! ... Identify the cell containing the free surface
     IF(l >= lnz2) THEN
        l1=MOD(m,nxy)
        IF(l1 == 0) l1=nxy
        m=mfsbc(l1)
        IF(m == 0) CYCLE
        ufrac=1._kdp
     END IF
     qn=qfbcv(l)
     IF(qn <= 0._kdp) THEN     ! ... Outflow
        qfbc=den(m)*qn*ufrac
        qffbc(l) = qfbc
        stotfp = stotfp-ufdt1*qfbc
!!$        qhbc=qfbc*eh(m)
!!$        stothp=stothp-ufdt1*qhbc
        DO  is=1,ns
           qsbc3(is)=qfbc*c(m,is)
           stotsp(is) = stotsp(is)-ufdt1*qsbc3(is)
        END DO
     ELSE                      ! ... Inflow
        qfbc=denfbc(l)*qn*ufrac
        qffbc(l) = qfbc
        stotfi = stotfi+ufdt1*qfbc
        DO  is=1,ns
           qsbc3(is)=qfbc*cflx(l,is)
           stotsi(is) = stotsi(is)+ufdt1*qsbc3(is)
        END DO
     END IF
     sffb(l)=sffb(l)+qfbc
     sfvfb(l)=sfvfb(l)+qn
     stffbc = stffbc+ufdt1*qfbc
!!$     IF(heat) THEN
!!$        qhbc2=qhfbc(l)*ufrac
!!$        IF(qhbc2 <= 0._kdp) THEN
!!$           stothp=stothp-0.5*qhbc2
!!$        ELSE
!!$           stothi=stothi+0.5*qhbc2
!!$        END IF
!!$        !            SHFB(L)=SHFB(L)+QHBC+QHBC2
!!$        !            STHFBC=STHFBC+0.5*(QHBC2+QHBC)
!!$     END IF
     DO  is=1,ns
        qsbc4(is)=qsfbc(l,is)*ufrac
        IF(qsbc4(is) <= 0._kdp) THEN
           stotsp(is) = stotsp(is)-ufdt1*qsbc4(is)
        ELSE
           stotsi(is) = stotsi(is)+ufdt1*qsbc4(is)
        END IF
        ssfb(l,is) = ssfb(l,is)+qsbc4(is)+qsbc3(is)
        stsfbc(is) = stsfbc(is)+ufdt1*(qsbc4(is)+qsbc3(is))
     END DO
  END DO
  ! ... Compute cumulative cell flow amounts
  DO  l=1,nfbc
     ccffb(l) = ccffb(l)+0.5*sffb(l)*deltim
     ccfvfb(l) = ccfvfb(l)+0.5*sfvfb(l)*deltim
!!$     CCHFB(L)=CCHFB(L)+0.5*SHFB(L)*DELTIM
     DO  is=1,ns
        ccsfb(l,is)=ccsfb(l,is)+0.5*ssfb(l,is)*deltim
     END DO
  END DO
  DEALLOCATE (qsbc3, qsbc4, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, sumcal1"  
     STOP
  ENDIF
  ! ... Convert step total flow rates to step total amounts
  stffbc=stffbc*deltim
!!$  sthfbc=sthfbc*deltim
  tcffbc=tcffbc+stffbc
!!$  tchfbc=tchfbc+sthfbc
  DO  is=1,ns
     stsfbc(is)=stsfbc(is)*deltim
     tcsfbc(is)=tcsfbc(is)+stsfbc(is)
  END DO
  ! ... Calculate aquifer leakage flow rates
  erflg=.FALSE.
  DO  l=1,nlbc
     DO  is=1,ns
        sslb(l,is)=0
     END DO
     m=mlbc(l)
     IF(frac(m) <= 0._kdp .OR. m == 0) CYCLE
     qnp=albc(l) - blbc(l)*dp(m)
     IF(qnp < 0._kdp) THEN        ! ... Outflow
        qflbc(l)=den(m)*qnp
        stotfp = stotfp-ufdt1*qflbc(l)
!!$        IF(heat) THEN
!!$           qhlbc(l)=qflbc(l)*eh(m)
!!$           stothp=stothp-ufdt1*qhlbc(l)
!!$        END IF
        DO  is=1,ns
           qslbc(l,is)=qflbc(l)*c(m,is)
           stotsp(is) = stotsp(is)-ufdt1*qslbc(l,is)
        END DO
     ELSE                         ! ... Inflow
        qflbc(l)=denlbc(l)*qnp
        stotfi = stotfi+ufdt1*qflbc(l)
!!$        IF(heat) THEN
!!$          qhlbc(l)=qflbc(l)*ehoftp(tlbc(l),p(m),erflg)
!!$          stothi=stothi+ufdt1*qhlbc(l)
!!$        END IF
        DO  is=1,ns
           qslbc(l,is)=qflbc(l)*clbc(l,is)
           stotsi(is) = stotsi(is)+ufdt1*qslbc(l,is)
        END DO
     END IF
     sflb(l)=sflb(l)+qflbc(l)
     sfvlb(l)=sfvlb(l)+qnp
!!$     SHLB(L)=SHLB(L)+QHLBC(L)
     stflbc = stflbc+ufdt1*qflbc(l)
!!$     STHLBC=STHLBC+ufdt1*QHLBC(L)
     DO  is=1,ns
        sslb(l,is)=sslb(l,is)+qslbc(l,is)
        stslbc(is) = stslbc(is)+ufdt1*qslbc(l,is)
     END DO
  END DO
  ! ... Compute cumulative cell flow amounts
  DO  l=1,nlbc
     m=mlbc(l)
     IF(frac(m) <= 0._kdp) CYCLE
     ccflb(l)=ccflb(l)+0.5*sflb(l)*deltim
     ccfvlb(l)=ccfvlb(l)+0.5*sfvlb(l)*deltim
!!$     CCHLB(L)=CCHLB(L)+0.5*SHLB(L)*DELTIM
     DO  is=1,ns
        ccslb(l,is)=ccslb(l,is)+0.5*sslb(l,is)*deltim
     END DO
  END DO
  ! ... Convert step total flow rates to step total amounts
  stflbc=stflbc*deltim
!!$  sthlbc=sthlbc*deltim
  tcflbc=tcflbc+stflbc
!!$  tchlbc=tchlbc+sthlbc
  DO  is=1,ns
     stslbc(is)=stslbc(is)*deltim
     tcslbc(is)=tcslbc(is)+stslbc(is)
  END DO
  ! ... Calculate river leakage flow rates
  erflg=.FALSE.
  ALLOCATE (cavg(nsa), sum_cqm_in(nsa),  &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: sumcal1"  
     STOP  
  ENDIF
  DO lc=1,nrbc_cells
     m = river_seg_index(lc)%m
     IF(m == 0) CYCLE
     ! ... Calculate current net aquifer leakage flow rate
     ! ...      Possible attenuation included explicitly
     qm_net = 0._kdp
     DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
        qnp = arbc(ls) - brbc(ls)*dp(m)  
        IF(qnp < 0._kdp) THEN           ! ... Outflow
           qm_net = qm_net + den(m)*qnp
        ELSE                            ! ... Inflow
           ! ... Limit the flow rate for a river leakage
           qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*(zerbc(ls)-0.5_kdp*bbrbc(ls))  &
                - 0.5_kdp*den(m)*bbrbc(ls)))
           qnp = MIN(qnp,qlim)
           qm_net = qm_net + denrbc(ls)*qnp
        ENDIF
     END DO
     qfrbc(lc) = qm_net
     IF(qm_net < 0._kdp) THEN        ! ... Outflow
        stotfp = stotfp - ufdt1*qfrbc(lc)
        DO  is=1,ns
           qsrbc(lc,is) = qfrbc(lc)*c(m,is)
           stotsp(is) = stotsp(is) - ufdt1*qsrbc(lc,is)
        END DO
     ELSEIF(qm_net > 0._kdp) THEN    ! ... Inflow
        qm_in = 0._kdp
        sum_cqm_in = 0._kdp
        DO ls=river_seg_index(lc)%seg_first,river_seg_index(lc)%seg_last
           qnp = arbc(ls) - brbc(ls)*dp(m)
           IF(qnp > 0._kdp) THEN  ! ... Inflow
              ! ... Limit the flow rate for a river leakage
              qlim = brbc(ls)*(denrbc(ls)*phirbc(ls) - gz*(denrbc(ls)*  &
                   (zerbc(ls)-0.5_kdp*bbrbc(ls)) - 0.5_kdp*den(m)*bbrbc(ls)))
              qnp = MIN(qnp,qlim)
              qm_in = qm_in + denrbc(ls)*qnp
              DO is=1,ns
                 sum_cqm_in(is) = sum_cqm_in(is) + denrbc(ls)*qnp*crbc(ls,is)  
              END DO
           ENDIF
        END DO
        DO is=1,ns
           cavg(is) = sum_cqm_in(is)/qm_in
        END DO
        stotfi = stotfi + ufdt1*qfrbc(lc)
        DO is=1,ns
           qsrbc(lc,is) = qfrbc(lc)*cavg(is)
           stotsi(is) = stotsi(is) + ufdt1*qsrbc(lc,is)
        END DO
     END IF
     sfrb(lc)=sfrb(lc)+qfrbc(lc)
     sfvrb(lc)=sfvrb(lc)+qm_net/den0   ! *** Only valid for constant density
     stfrbc = stfrbc+ufdt1*qfrbc(lc)
     DO  is=1,ns
        ssrb(lc,is)=ssrb(lc,is)+qsrbc(lc,is)
        stsrbc(is) = stsrbc(is)+ufdt1*qsrbc(lc,is)
     END DO
  END DO
  ! ... Compute cumulative cell flow amounts
  DO lc=1,nrbc
     ccfrb(lc) = ccfrb(lc)+0.5*sfrb(lc)*deltim
     ccfvrb(lc) = ccfvrb(lc)+0.5*sfvrb(lc)*deltim
     DO is=1,ns
        ccsrb(lc,is) = ccsrb(lc,is)+0.5*ssrb(lc,is)*deltim
     END DO
  END DO
  ! ... Convert step total flow rates to step total amounts
  ! ...     and sum for cumulative amounts
  stfrbc=stfrbc*deltim
!!$  sthrbc=sthrbc*deltim
  tcfrbc=tcfrbc+stfrbc
!!$  tchrbc=tchrbc+sthrbc
  DO  is=1,ns
     stsrbc(is)=stsrbc(is)*deltim
     tcsrbc(is)=tcsrbc(is)+stsrbc(is)
  END DO
  DEALLOCATE (cavg, sum_cqm_in, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed, sumcal1"  
     STOP
  ENDIF
  ! ... Do not update the indices connecting river to aquifer yet!
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
!!$        IF(heat) THEN
!!$           qhaif(l)=qfaif(l)*eh(m)
!!$           stothp=stothp-0.5*qhaif(l)
!!$        END IF
!!$        IF(solute) THEN
!!$           !               QSAIF(L)=QFAIF(L)*C(M)
!!$           !               STOTSP=STOTSP-0.5*QSAIF(L)
!!$        END IF
!!$     ELSE
!!$        ! ... Inflow
!!$        uden=denoar(l)
!!$        qfaif(l)=uden*qnp
!!$        stotfi=stotfi+0.5*qfaif(l)
!!$!        IF(heat) THEN
!!$!           qhaif(l)=qfaif(l)*ehoftp(taif(l),p(m),erflg)
!!$!           stothi=stothi+0.5*qhaif(l)
!!$!        END IF
!!$        IF(solute) THEN
!!$           !               QSAIF(L)=QFAIF(L)*CAIF(M)
!!$           !               STOTSI=STOTSI+0.5*QSAIF(L)
!!$        END IF
!!$     END IF
!!$     sfaif(l)=sfaif(l)+qfaif(l)
!!$     sfvaif(l)=sfvaif(l)+qnp
!!$     !         SHAIF(L)=SHAIF(L)+QHAIF(L)
!!$     !         SSAIF(L)=SSAIF(L)+QSAIF(L)
!!$     stfaif=stfaif+0.5*uden*wcaif(l)
!!$     !         STHAIF=STHAIF+0.5*QHAIF(L)
!!$     !         STSAIF=STSAIF+0.5*QSAIF(L)
!!$  END DO
!!$  ! ... Compute cumulative cell flow amounts
!!$  DO  l=1,naifc
!!$     ccfaif(l)=ccfaif(l)+0.5*sfaif(l)*deltim
!!$     ccfvai(l)=ccfvai(l)+0.5*sfvaif(l)*deltim
!!$     !         CCHAIF(L)=CCHAIF(L)+0.5*SHAIF(L)*DELTIM
!!$     !         CCSAIF(L)=CCSAIF(L)+0.5*SSAIF(L)*DELTIM
!!$  END DO
!!$  ! ... Convert step total flow rates to step total amounts
!!$  ! ... Following line suspended because WCAIF is cumulative total flow.
!!$  !...            STFAIF=STFAIF*DELTIM
!!$  sthaif=sthaif*deltim
!!$  !      STSAIF=STSAIF*DELTIM
!!$  tcfaif=tcfaif+stfaif
!!$  tchaif=tchaif+sthaif
!!$  !      TCSAIF=TCSAIF+STSAIF
!!$  ! ... Heat conduction b.c.
!!$  !... *** not implemented for PHAST
!!$  IF(heat) THEN
!!$     DO  l=1,nhcbc
!!$        ! ... Update heat flow rates
!!$        m=mhcbc(l)
!!$        qhcbc(l)=qhcbc(l)+dqhcdt(l)*dt(m)
!!$        IF(qhcbc(l) > 0._kdp) THEN
!!$           ! ... Inflow boundary
!!$           stothi=stothi+0.5*qhcbc(l)
!!$        ELSE
!!$           ! ... Outflow boundary
!!$           stothp=stothp-0.5*qhcbc(l)
!!$        END IF
!!$        !            SHHCB(L)=SHHCB(L)+QHCBC(L)
!!$        !            STHHCB=STHHCB+0.5*QHCBC(L)
!!$     END DO
!!$     ! ... Compute total cumulative cell flow amounts
!!$     DO  l=1,nhcbc
!!$        cchhcb(l)=cchhcb(l)+0.5*shhcb(l)*deltim
!!$     END DO
!!$     ! ... Convert step total flow rate to step total amount
!!$     sthhcb=sthhcb*deltim
!!$     tchhcb=tchhcb+sthhcb
!!$  END IF
  ! ... Calculate total fluid mass, fluid volume, solute in region
  ! ...      of active cells before chemical reaction step
  ! ... Calculate mass of each aqueous solute component in region
  ! ...      of active cells before chemical reaction step
  fir = 0._kdp
  firv = 0._kdp
  ehir = 0._kdp
  sir_prechem = 0._kdp
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     IF(frac(m) <= 0._kdp) CYCLE
     u0=pv(m)*frac(m)
     u1=0._kdp
     fir = fir+u0*den(m)
     firv = firv+u0
     DO  is=1,ns
        sir_prechem(is) = sir_prechem(is) + den(m)*(u0+u1)*c(m,is)
     END DO
     IF(ABS(prip) > 0. .OR. ABS(prihdf_head) > 0. .OR. ABS(primaphead) > 0.) THEN
        ! ... Calculate head field
        imod = MOD(m,nxy)
        k = (m-imod)/nxy + MIN(1,imod)
        hdprnt(m) = z(k)+p(m)/(den(m)*gz)
     END IF
  END DO

END SUBROUTINE sumcal1
