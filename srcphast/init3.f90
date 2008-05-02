SUBROUTINE init3
  ! ... Resets time varying b.c. rate data at each
  ! ...      time of b.c. change, TIMCHG
  USE machine_constants, ONLY: bgreal, kdp
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcv
  USE mcw
  USE mg3
  USE print_control_mod
  IMPLICIT NONE
  INTERFACE
     SUBROUTINE load_indx_bc(ibct,indx1_bc,indx2_bc,mxf_bc,mbc,nbc)
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) :: ibct
       INTEGER, DIMENSION(:), INTENT(OUT) :: indx1_bc, indx2_bc
       REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: mxf_bc
       INTEGER, DIMENSION(:), INTENT(IN) :: mbc
       INTEGER, INTENT(IN) :: nbc
     END SUBROUTINE load_indx_bc
  END INTERFACE
  INTRINSIC INDEX
  CHARACTER(LEN=9) :: cibc
  REAL(kind=kdp) :: uq, uqh, utime, utimchg
  REAL(kind=kdp) :: up0, p1, z0, z1, zfsl, zm1, zp1
  INTEGER :: da_err, ic, imod, iis, iwel, k, l, ls, m, m1, mt
  REAL(KIND=kdp), PARAMETER :: nodat = bgreal*1.e-15_kdp
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Convert the data to S.I. time units if necessary
  ! ...      even if an error abort is set
  IF(tmunit > 1) CALL etom2
  ! ... Load well data
  IF(rdwtd) THEN
     ! ... The following loads the specified well injection concentrations
     IF(solute) THEN
        DO  iwel=1,nwel
           indx2_wel(iwel)=-1
           mxf_wel(iwel)=1.d0
        END DO
        CALL setup_boundary_conditions(nwel,indx1_wel,indx2_wel,  &
             mxf_wel,cwkt,nwel)
     END IF
     DO  iwel=1,nwel
        IF(wqmeth(iwel) == 12.OR.wqmeth(iwel) == 13) THEN
           DO  iis=1,ns
              cwkts(iwel,iis)=cwkt(iwel,iis)
           END DO
        END IF
        !            IF(WQMETH(IWEL).EQ.50) PWSUR(IWEL)=PWSURS(IWEL)
        !            IF(HEAT.AND.WQMETH(IWEL).LE.30) TWKT(IWEL)=TWSRKT(IWEL)
        !            IF(WQMETH(IWEL).EQ.30) PWKTS(IWEL)=PWKT(IWEL)
     END DO
  END IF
  IF(rdspbc .OR. rdstbc .OR. rdscbc) THEN
     ! ... Load the mass fractions for
     ! ...      specified pressure nodes into the b.c. arrays
     ! ... CSBC can also be the specified temperatures and
     ! ...      mass fractions ***** not presently
     ! ... The following loads the associated and specified concentrations
     IF(solute) THEN
!$$        CALL load_indx_bc(1,indx1_sbc,indx2_sbc,mxf_sbc,msbc,nsbc)
        CALL setup_boundary_conditions(nsbc,indx1_sbc,indx2_sbc, mxf_sbc,  &
             csbc, nsbc_seg)
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
                 zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
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
                 zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
                 frac(m) = (2.*zfsl-(z0+zm1))/(z0-zm1)
                 vmask(m) = 1
              ELSE
                 up0=p(m)
                 zm1=z(k-1)
                 z0=z(k)
                 zfsl = up0/(den(m)*gz) + z0     ! hydrostatic
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
                    frac(m) = 0._kdp       ! ... Empty column of cells
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
                    zm1=z(k-1)
                    z0=z(k)
                    zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
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
                    zfsl = up0/(den(m)*gz) + z0     ! Hydrostatic
                    frac(m) = (2.*zfsl-(z0+zm1))/(zp1-zm1)
                    frac(m)=MIN(1._kdp,frac(m))
                    vmask(m) = 1
                 ELSE
                    up0=p(m)
                    z0=z(k)
                    zp1=z(k+1)
                    zm1=z(k-1)
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
           !           END IF
        END DO
     END IF
  END IF
  ! ... Reset the pointer to the cell containing the free surface
  ! ...      at each node location over the horizontal area
  ! ... also set frac to one for all cells below the f.s. cell
  DO mt=1,nxy
     m1 = nxyz-nxy+mt
750  IF(frac(m1) > 0._kdp) go to 760  
     m1 = m1-nxy
     IF(m1 > 0) go to 750
     m1 = 0
760  mfsbc(mt) = m1
     DO m=m1-nxy,1,-nxy
        frac(m) = 1._kdp
  END DO
           END DO
  ! ... Specified flux b.c.
  IF(rdflxq) THEN
     DO  ls=1,nfbc_seg
!$$        qfbcv(ls) = qfbcv(ls)*areafbc(ls)     ! ... Calculate the flux*area to get flow rates
        denfbc(ls) = den0
     END DO
     IF(solute) THEN                          ! ... Load the associated concentrations
!$$        CALL load_indx_bc(2, indx1_fbc, indx2_fbc, mxf_fbc, mfbc, nfbc_seg)
        CALL setup_boundary_conditions(nfbc_seg, indx1_fbc, indx2_fbc, mxf_fbc,  &
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
  ! ... Aquifer leakage b.c.
  IF(rdlbc) THEN
     DO  ls=1,nlbc_seg
        denlbc(ls) = den0
        vislbc(ls) = -visfac
     END DO
     IF(solute) THEN               ! ... Load the associated concentrations
        CALL setup_boundary_conditions(nlbc_seg, indx1_lbc, indx2_lbc, mxf_lbc,  &
             clbc, nlbc_seg)
     END IF
  END IF
  ! ... River leakage b.c.
  IF(rdrbc) THEN
     DO  ls=1,nrbc_seg
        denrbc(ls) = den0
        visrbc(ls) = -visfac
     END DO
     ! ... Load the associated concentrations
     IF(solute) THEN
        CALL setup_boundary_conditions(nrbc_seg,indx1_rbc,indx2_rbc, mxf_rbc,  &
             crbc, nrbc_seg)
     END IF
  END IF
  ! ... Drain leakage b.c.
     visdbc = -visfac
!!$  ! ... Load the associated temperatures and mass fractions for a.i.f.
!!$  ! ...      b.c. cells
!!$  ! ...  *** not implemented for PHAST
!!$  IF(rdaif) THEN
!!$     DO  l=1,naifc
!!$        m=maifc(l)
!!$        IF(udenbc(m) < nodat) denoar(l)=udenbc(m)
!!$        IF(heat.AND.utbc(m) < nodat) taif(l)=utbc(m)
!!$        !**         IF(SOLUTE.AND.UCBC(M).LT.NODAT) CAIF(L)=UCBC(M)
!!$     END DO
!!$  END IF
  ! ... The time conversions needed even if in metric units, due to
  ! ...      user time step selection
  IF(rdcalc) THEN
     deltim = cnvtm*deltim
     deltim_sav = 0._kdp
     ! ... save deltim for transient simulation after possible ss simulation
     deltim_transient = deltim  
     IF(autots .OR. (steady_flow .AND. time <= 0.0_kdp)) THEN
        dtimmn=cnvtm*dtimmn
        dtimmx=cnvtm*dtimmx
!!$        dtimu=cnvtm*dtimu
        ! ... If automatic time step, set the default controls if necessary
        IF(dptas <= 0.) dptas=5.d4
        IF (dttas <= 0.) dttas=5.d0
        !        DO  iis=1,ns
        !            IF(DCTAS(iis).LE.0.) DCTAS(iis)=???? 0.10
        !        END DO
        IF (dtimmn <= 0.) dtimmn=1.d4
        IF (dtimmx <= 0.) dtimmx=1.d7
        deltim=dtimmn
     END IF
  END IF
  jtime=0
  timchg=cnvtm*timchg
  ! ... Needed in case no new calculation information is read
  IF(autots .OR. (steady_flow .AND. time <= 0.0_kdp)) deltim=dtimmn
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
  ! sets print_time for each variable and sets next_print_time to be minimum
  ! of print_time's and utimchg
  CALL pc_set_print_times(utime, utimchg)


!!$  IF(pribcf > 0._kdp) THEN
!!$     timprbcf=(1._kdp+INT(utime/pribcf))*pribcf
!!$  ELSE
!!$     timprbcf=utimchg
!!$  ENDIF
!!$  IF(pricpd > 0._kdp) THEN
!!$     timprcpd=(1._kdp+INT(utime/pricpd))*pricpd
!!$  ELSE
!!$     timprcpd=utimchg
!!$  ENDIF
!!$  IF(prigfb > 0._kdp) THEN
!!$     timprgfb=(1._kdp+INT(utime/prigfb))*prigfb
!!$  ELSE
!!$     timprgfb=utimchg
!!$  ENDIF
!!$  IF(prikd > 0._kdp) THEN
!!$     timprkd=(1._kdp+INT(utime/prikd))*prikd
!!$  ELSE
!!$     timprkd=utimchg
!!$  ENDIF
!!$  IF(primaphead > 0._kdp) THEN
!!$     timprmaph=(1._kdp+INT(utime/primaphead))*primaphead
!!$  ELSE
!!$     timprmaph=utimchg
!!$  ENDIF
!!$  IF(primapcomp > 0._kdp) THEN
!!$     timprmapc=(1._kdp+INT(utime/primapcomp))*primapcomp
!!$  ELSE
!!$     timprmapc=utimchg
!!$  ENDIF
!!$  IF(primapv > 0._kdp) THEN
!!$     timprmapv=(1._kdp+INT(utime/primapv))*primapv
!!$  ELSE
!!$     timprmapv=utimchg
!!$  ENDIF
!!$  IF(prip > 0._kdp) THEN
!!$     timprp=(1._kdp+INT(utime/prip))*prip
!!$  ELSE
!!$     timprp=utimchg
!!$  ENDIF
!!$  IF(pric > 0._kdp) THEN
!!$     timprc=(1._kdp+INT(utime/pric))*pric
!!$  ELSE
!!$     timprc=utimchg
!!$  ENDIF
!!$  IF(pricphrq > 0._kdp) THEN
!!$     timprcphrq=(1._kdp+INT(utime/pricphrq))*pricphrq
!!$  ELSE
!!$     timprcphrq=utimchg
!!$  ENDIF
!!$  IF(priforce_chem_phrq > 0._kdp) THEN
!!$     timprfchem=(1._kdp+INT(utime/priforce_chem_phrq))*priforce_chem_phrq
!!$  ELSE
!!$     timprfchem=utimchg
!!$  ENDIF
!!$  IF(prislm > 0._kdp) THEN
!!$     timprslm=(1._kdp+INT(utime/prislm))*prislm
!!$  ELSE
!!$     timprslm=utimchg
!!$  ENDIF
!!$!  if (print_restart%freq > 0._kdp) THEN
!!$!     print_restart%time_print = (1._kdp+INT(utime/print_restart%freq))*print_restart%freq
!!$!  ELSE 
!!$!     print_restart%time_print = utimchg
!!$!  ENDIF
!!$  CALL pc_set_print_time_init3(print_restart, utime, utimchg)
!!$  IF(privel > 0._kdp) THEN
!!$     timprvel=(1._kdp+INT(utime/privel))*privel
!!$  ELSE
!!$     timprvel=utimchg
!!$  ENDIF
!!$  IF(priwel > 0._kdp) THEN
!!$     timprwel=(1._kdp+INT(utime/priwel))*priwel
!!$  ELSE
!!$     timprwel=utimchg
!!$  ENDIF
!!$  IF(pri_well_timser > 0._kdp) THEN
!!$     timprtem=(1._kdp+INT(utime/pri_well_timser))*pri_well_timser
!!$  ELSE
!!$     timprtem=utimchg
!!$  ENDIF
!!$  IF(prihdf_head > 0._kdp) THEN
!!$     timprhdfh=(1._kdp+INT(utime/prihdf_head))*prihdf_head
!!$  ELSE
!!$     timprhdfh=utimchg
!!$  ENDIF
!!$  IF(prihdf_vel > 0._kdp) THEN
!!$     timprhdfv=(1._kdp+INT(utime/prihdf_vel))*prihdf_vel
!!$  ELSE
!!$     timprhdfv=utimchg
!!$  ENDIF
!!$  IF(prihdf_conc > 0._kdp) THEN
!!$     timprhdfcph=(1._kdp+INT(utime/prihdf_conc))*prihdf_conc
!!$  ELSE
!!$     timprhdfcph=utimchg
!!$  ENDIF
!!$  IF(steady_flow) THEN
!!$     ! ... Move stop signs for print to end of time period for steady-state
!!$     ! ...     parameters
!!$!     timprkd = utimchg   ! decided to print out as defined by prikd regardless
!!$     timprmaph = utimchg
!!$     timprmapv = utimchg
!!$     timprp = utimchg
!!$     timprvel = utimchg
!!$     timprhdfh=utimchg
!!$     timprhdfv=utimchg
!!$  END IF
  ! ... Set the next time for printout by user time units
!!$  timprtnxt=MIN(utimchg,timprbcf, timprcpd, timprgfb,  &
!!$       timprhdfh, timprhdfv, timprhdfcph,  &
!!$       timprkd, timprmapc, timprmaph, timprmapv, &
!!$       timprp, timprc, timprcphrq, timprfchem, timprslm, timprtem, timprvel, timprwel, &
!!$       print_restart%print_time)
!!$  ! ... Turn off all print control flags that may have been set for i.c. or s.s. output
!!$  prslm = .FALSE.
!!$  prvel = .FALSE.
!!$  prmapv = .FALSE.
!!$  prhdfv = .FALSE.
  timprtnxt = next_print_time
END SUBROUTINE init3
