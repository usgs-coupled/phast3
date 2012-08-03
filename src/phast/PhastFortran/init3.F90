SUBROUTINE init3
  ! ... Resets time varying b.c. rate data at each time of b.c. change, TIMCHG
  USE machine_constants, ONLY: bgreal, kdp
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
  USE mg3_m
  USE print_control_mod
  IMPLICIT NONE
  INTERFACE
     SUBROUTINE load_indx_bc(ibct,indx1_bc,indx2_bc,mxf_bc,mbc,nbc)
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) :: ibct
       INTEGER, DIMENSION(:), INTENT(OUT) :: indx1_bc, indx2_bc
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: mxf_bc
       INTEGER, DIMENSION(:), INTENT(IN) :: mbc
       INTEGER, INTENT(IN) :: nbc
     END SUBROUTINE load_indx_bc
  END INTERFACE
  INTRINSIC INDEX
  CHARACTER(LEN=130) :: logline1
  REAL(KIND=kdp) :: uq, uqh, utime, utimchg
  REAL(KIND=kdp) :: up0, p1, z0, z1, zfsl, zm1, zp1
  INTEGER :: a_err, da_err, ic, icol, imod, iis, iwel, jcol, k, kcol,  &
       l, ls, m, m1, mt, nsa, tag
  !  INTEGER :: int_real_type, mpi_array_type
  !  INTEGER, DIMENSION(1) :: array_bcst_i
  !  REAL(KIND=kdp), DIMENSION(2) :: array_bcst_r
  !$$  REAL(KIND=kdp), PARAMETER :: nodat = bgreal*1.e-15_kdp
  !  INTEGER, DIMENSION(:), ALLOCATABLE :: req_send
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  !     nsa = MAX(ns,1)
  !     ALLOCATE(req_send(1:nsa),  &
  !          STAT = a_err)
  !     IF (a_err /= 0) THEN
  !        PRINT *, "Array allocation failed: init3"
  !        STOP
  !     ENDIF
  !  ! ... Convert the data to S.I. time units if necessary
  ! ...      even if an error abort is set
  IF(tmunit > 1) CALL etom2
  ! ... Load well data
  IF(rdwtd) THEN
     ! ... The following loads the specified well injection concentrations
     IF(solute) THEN
        DO  iwel=1,nwel
           indx2_wel(iwel) = -1
           mxf_wel(iwel) = 1._kdp
        END DO
        CALL RM_setup_boundary_conditions(rm_id, nwel,indx1_wel,indx2_wel,  &
             mxf_wel,cwkt,nwel)
     END IF
     DO  iwel=1,nwel
        IF(wqmeth(iwel) == 12 .OR. wqmeth(iwel) == 13) THEN
           DO  iis=1,ns
              cwkts(iwel,iis) = cwkt(iwel,iis)
           END DO
        END IF
!!$        !            IF(WQMETH(IWEL).EQ.50) PWSUR(IWEL)=PWSURS(IWEL)
!!$        !            IF(WQMETH(IWEL).EQ.30) PWKTS(IWEL)=PWKT(IWEL)
     END DO

  END IF
  ! ... Specified value b.c.
  IF(rdspbc .OR. rdscbc) THEN
     ! ... Load the mass fractions for
     ! ...      specified pressure nodes into the b.c. arrays
     ! ... CSBC can also be the specified temperatures and mass fractions ***** not presently
     ! ... The following loads the associated and specified concentrations
     IF(solute) THEN
        !$$        CALL load_indx_bc(1,indx1_sbc,indx2_sbc,mxf_sbc,msbc,nsbc)
        CALL RM_setup_boundary_conditions(rm_id, nsbc, indx1_sbc, indx2_sbc, mxf_sbc,  &
             csbc, nsbc_seg)

        ! ***** special patch for b.c. install for 3 components
        !        csbc(1:nsbc_seg,1) = mxf_sbc(1:nsbc_seg)
        !        csbc(1:nsbc_seg,2) = 2._kdp*mxf_sbc(1:nsbc_seg)
        !        csbc(1:nsbc_seg,3) = 4._kdp*mxf_sbc(1:nsbc_seg)
     END IF

     IF(fresur) THEN
        ! ... Calculate fraction of specified pressure cell that is
        ! ...      saturated, only after time of change
        ! ... *** This will not work for specified pressure cells above or below 
        ! ... ***    non-specified pressure cells because the specified pressure
        ! ... ***    may not be compatible with the i.c. or current pressure of
        ! ... ***    the adjacent cell for a valid interpolation
        DO  l=1,nsbc
           m=msbc(l)
           ! ... Only needed for cells above free surface to handle resaturation ??
           ! ...      All pressures are valid
           !****try for all cells. what if f.s. is lower now after pressure input?
           !           IF(frac(m) <= 0.) THEN
           imod = MOD(m,nxy)
           k = (m-imod)/nxy + MIN(1,imod)
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
                 frac(m) = 0._kdp       ! draining cell is empty
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
                 zfsl = up0/(den0*gz) + z0     ! hydrostatic
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
                    zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                    frac(m) = 2.*(zfsl-z0)/(zp1-z0)
                    frac(m) = MIN(1._kdp,frac(m))
                    vmask(m) = 1
                 ELSE
                    frac(m) = 0._kdp       ! ... Empty column of cells
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
                 IF(p(m) >=  0._kdp) THEN
                    up0=p(m)
                    z0=z(k)
                    zp1=z(k+1)
                    zm1=z(k-1)
                    zfsl = up0/(den0*gz) + z0     ! Hydrostatic
                    frac(m) = (2.*zfsl-(z0+zm1))/(zp1-zm1)
                    frac(m)=MIN(1._kdp,frac(m))
                    vmask(m) = 1
                 ELSE
                    up0=p(m)
                    z0=z(k)
                    zp1=z(k+1)
                    zm1=z(k-1)
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
  END IF

  ! ... Reset the pointer to the cell containing the free surface
  ! ...      at each node location over the horizontal area
  ! ... also set frac to one for all cells below the f.s. cell
  ! ... Allows for resaturation of cell columns by specified head (pressure) b.c.
  DO mt=1,nxy
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
     IF(m1 == 0 .AND. .NOT.print_dry_col(mt)) THEN
        CALL mtoijk(mt,icol,jcol,kcol,nx,ny)
        WRITE(logline1,'(a/tr5,a,i6,a,i5,a,i5)')   &
             'WARNING: A column of cells is dry in init3',  &
             'Cell column:', mt,' (i,j):', icol, ',', jcol
        CALL screenprt_c(logline1)
        CALL logprt_c(logline1)
        print_dry_col(mt) = .TRUE.
     END IF
  END DO
  ! ... Specified flux b.c.
  IF(rdflxq) THEN
     DO  ls=1,nfbc_seg
        !$$        qfbcv(ls) = qfbcv(ls)*areafbc(ls)     ! ... Calculate the flux*area to get flow rates
        denfbc(ls) = den0
     END DO
     IF(solute) THEN                          ! ... Load the associated concentrations
        !$$        CALL load_indx_bc(2, indx1_fbc, indx2_fbc, mxf_fbc, mfbc, nfbc_seg)
        CALL RM_setup_boundary_conditions(rm_id, nfbc_seg, indx1_fbc, indx2_fbc, mxf_fbc,  &
             cfbc, nfbc_seg)
     END IF
  END IF
!!$  IF(rdflxs) THEN
!!$     DO  ls=1,nfbc_seg
!!$        DO  iis=1,ns               ! ... Calculate the flux*area to get flow rates
!!$           qsfbc(lc,iis) = qsflx(ls,iis)*areafbc(ls)
!!$        END DO
!!$     END DO
!!$  END IF
  ! *** no broadcast of qsflx as no pure diffusive solute b.c. is enabled at present
  ! ... Aquifer leakage b.c.
  IF(rdlbc) THEN
     DO  ls=1,nlbc_seg
        denlbc(ls) = den0
        vislbc(ls) = vis0
     END DO
     IF(solute) THEN               ! ... Load the associated concentrations
        CALL RM_setup_boundary_conditions(rm_id, nlbc_seg, indx1_lbc, indx2_lbc, mxf_lbc,  &
             clbc, nlbc_seg)
     END IF
  END IF
  ! ... River leakage b.c.
  IF(rdrbc) THEN
     DO  ls=1,nrbc_seg
        denrbc(ls) = den0
        visrbc(ls) = vis0
     END DO
     IF(solute) THEN               ! ... Load the associated concentrations
        CALL RM_setup_boundary_conditions(rm_id, nrbc_seg, indx1_rbc, indx2_rbc, mxf_rbc,  &
             crbc, nrbc_seg)
     END IF
  END IF
  ! ... Drain leakage b.c.
  visdbc = vis0
!!$  ! ... Load the associated temperatures and mass fractions for a.i.f.
!!$  ! ...      b.c. cells
!!$  ! ...  *** not implemented for PHAST
  IF(rdcalc) THEN
     ! ... The time conversions needed even if in metric units to handle
     ! ...      user time step selection
     deltim = cnvtm*deltim
     deltim_sav = 0._kdp
     ! ... save deltim for transient simulation after possible ss simulation
     deltim_transient = deltim  
     IF(autots .OR. (steady_flow .AND. time <= 0.0_kdp)) THEN
        dtimmn = cnvtm*dtimmn
        dtimmx = cnvtm*dtimmx
!!$        dtimu=cnvtm*dtimu
        ! ... If automatic time step, set the default controls if necessary
        IF(dptas <= 0.) dptas=5.e4_kdp
        IF(dttas <= 0.) dttas=5._kdp
        IF(dtimmn <= 0.) dtimmn=1.e4_kdp
        IF(dtimmx <= 0.) dtimmx=1.e7_kdp
        deltim = dtimmn
     END IF
  END IF
  jtime=0
  timchg = cnvtm*timchg
!!$  ! ... Needed in case no new calculation information is read
!!$  IF(autots .OR. (steady_flow .AND. time <= 0.0_kdp)) deltim=dtimmn

  ! ... Set first time for printout of each output file
  ! ... TIMPRTxxx and PRIMIN are in user time marching units
!!$  IF(nwel == 0) THEN
!!$     priwel = 0._kdp
!!$     pri_well_timser = 0._kdp
!!$  END IF
!!$  IF(.NOT.chkptd) pricpd=0._kdp
!!$  IF(.NOT.cntmaph) primaphead=0._kdp
!!$  IF(.NOT.cntmapc) primapcomp=0._kdp
!!$  IF(.NOT.vecmap) primapv=0._kdp
!!$  IF (.NOT.solute) THEN
!!$     primapcomp = 0._kdp
!!$     prihdf_conc = 0._kdp
!!$     pricphrq = 0._kdp
!!$     priforce_chem_phrq = 0._kdp
!!$     pri_well_timser = 0._kdp
!!$  ENDIF
  utime=cnvtmi*time
  utimchg=cnvtmi*timchg
  ! ... Set print_time for each variable and set next_print_time to be the minimum
  ! ...     of print_times and utimchg
  CALL pc_set_print_times(utime, utimchg)
  ! ... Set the next time for printout by user time units
  timprtnxt = next_print_time

  !  DEALLOCATE(req_send,  &
  !       STAT = da_err)
  !  IF (da_err /= 0) THEN
  !     PRINT *, "Array deallocation failed: init3"
  !     STOP
  !  ENDIF

END SUBROUTINE init3
