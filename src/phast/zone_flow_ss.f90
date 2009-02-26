SUBROUTINE zone_flow_ss
  ! ... Calculates flow rates for each internal zone
  ! ... Version for steady-state flow simulation
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb2
  USE mcc, ONLY: cylind
  USE mcg
  USE mcn, ONLY: x, y, z
  USE mcp
  USE mcv
  USE mcw
!!$  USE phys_const
  IMPLICIT NONE
  !$$  CHARACTER(LEN=9) :: cibc
  INTEGER :: i, icz, ifc, ilc, iwel, izn, j, k, ks, kfs, lc, m, mfs
  REAL(KIND=kdp) :: ufdt1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: zone_flow_ss.f90,v 1.5 2008/10/21 17:52:28 klkipp Exp $'
  !     ------------------------------------------------------------------
  ufdt1 = fdtmth
  ! ... Update conductance coefficients, mass flow rates, velocities
  CALL coeff_ss_flow
  ! ... Zero the flow rate accumulators
  qfzoni = 0._kdp
  qfzonp = 0._kdp
  qfzoni_int = 0._kdp
  qfzonp_int = 0._kdp
  qfzoni_sbc = 0._kdp
  qfzonp_sbc = 0._kdp
  qfzoni_fbc = 0._kdp
  qfzonp_fbc = 0._kdp
  qfzoni_lbc = 0._kdp
  qfzonp_lbc = 0._kdp
  qfzoni_rbc = 0._kdp
  qfzonp_rbc = 0._kdp
  qfzoni_dbc = 0._kdp
  qfzonp_dbc = 0._kdp
  qfzoni_wel = 0._kdp
  qfzonp_wel = 0._kdp
  ! ... Sum flow rates over internal faces for each zone
  DO  izn=1,num_flo_zones
     DO  ifc=1,zone_ib(izn)%num_int_faces
        m = zone_ib(izn)%mcell_no(ifc)
        CALL mtoijk(m,i,j,k,nx,ny)
        IF(zone_ib(izn)%face_indx(ifc) == 4) THEN
           ! ... X-direction mass flow rates
           IF (sxx(m) > 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) + sxx(m)
              qfzonp(izn) = qfzonp(izn) + sxx(m)
           ELSEIF (sxx(m) < 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) - sxx(m)
              qfzoni(izn) = qfzoni(izn) - sxx(m)
           END IF
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 3) THEN
           ! ... X-direction mass flow rates
           IF (sxx(m-1) < 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) - sxx(m-1)
              qfzonp(izn) = qfzonp(izn) - sxx(m-1)
           ELSEIF (sxx(m-1) > 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) + sxx(m-1)
              qfzoni(izn) = qfzoni(izn) + sxx(m-1)
           END IF
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 5 .AND. .NOT.cylind) THEN
           ! ... Y-direction mass flow rates
           mijpk=m+nx
           IF (syy(m) > 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) + syy(m)
              qfzonp(izn) = qfzonp(izn) + syy(m)
           ELSEIF (syy(m) < 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) - syy(m)
              qfzoni(izn) = qfzoni(izn) - syy(m)
           END IF
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 2 .AND. .NOT.cylind) THEN
           ! ... Y-direction mass flow rates
           mijmk = m-nx
           IF (syy(mijmk) < 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) - syy(mijmk)
              qfzonp(izn) = qfzonp(izn) - syy(mijmk)
           ELSEIF (syy(mijmk) > 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) + syy(mijmk)
              qfzoni(izn) = qfzoni(izn) + syy(mijmk)
           END IF
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 6) THEN
           ! ... Z-direction mass flow rates
           mijkp = m+nxy
           IF(fresur .AND. frac(m) < 1._kdp) THEN
              szz(m) = 0._kdp
           END IF
           IF (szz(m) > 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) + szz(m)
              qfzonp(izn) = qfzonp(izn) + szz(m)
           ELSEIF (szz(m) < 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) - szz(m)
              qfzoni(izn) = qfzoni(izn) - szz(m)
           END IF
           IF (szz(mijkm) < 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) - szz(mijkm)
              qfzonp(izn) = qfzonp(izn) - szz(mijkm)
           ELSEIF (szz(mijkm) > 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) + szz(mijkm)
              qfzoni(izn) = qfzoni(izn) + szz(mijkm)
           END IF
        ELSEIF(zone_ib(izn)%face_indx(ifc) == 1) THEN
           ! ... Z-direction mass flow rates
           mijkm = m-nxy
           IF(fresur .AND. frac(mijkm) < 1._kdp) THEN
              szz(mijkm) = 0._kdp
           END IF
           IF (szz(mijkm) < 0.) THEN
              qfzonp_int(izn) = qfzonp_int(izn) - szz(mijkm)
              qfzonp(izn) = qfzonp(izn) - szz(mijkm)
           ELSEIF (szz(mijkm) > 0.) THEN
              qfzoni_int(izn) = qfzoni_int(izn) + szz(mijkm)
              qfzoni(izn) = qfzoni(izn) + szz(mijkm)
           END IF
        END IF
     END DO

     ! ... Add in the boundary condition flow rates
     IF(nsbc > 0) THEN
        ! ... Specified head b.c. cell boundary flow rates
        DO ilc=1,lnk_bc2zon(izn,1)%num_bc
           lc = lnk_bc2zon(izn,1)%lcell_no(ilc)
           ! ... Fluid flow rates
           IF(qfsbc(lc) < 0._kdp) THEN       ! ... Outflow boundary
              qfzonp_sbc(izn) = qfzonp_sbc(izn) - qfsbc(lc)
              qfzonp(izn) = qfzonp(izn) - qfsbc(lc)
           ELSE                              ! ... Inflow boundary
              qfzoni_sbc(izn) = qfzoni_sbc(izn) + qfsbc(lc)
              qfzoni(izn) = qfzoni(izn) + qfsbc(lc)
           END IF
        END DO
     END IF
     IF(nfbc > 0) THEN
        ! ... Specified flux b.c.
        DO ilc=1,lnk_bc2zon(izn,2)%num_bc
           lc = lnk_bc2zon(izn,2)%lcell_no(ilc)
           IF(qffbc(lc) < 0._kdp) THEN             ! ... Outflow
              qfzonp_fbc(izn) = qfzonp_fbc(izn) - ufdt1*qffbc(lc)
              qfzonp(izn) = qfzonp(izn) - ufdt1*qffbc(lc)
           ELSE                                    ! ... Inflow
              qfzoni_fbc(izn) = qfzoni_fbc(izn) + ufdt1*qffbc(lc)
              qfzoni(izn) = qfzoni(izn) + ufdt1*qffbc(lc)
           END IF
        END DO
        IF(fresur) THEN
           DO ilc=1,lnk_cfbc2zon(izn)%num_bc
              lc = lnk_cfbc2zon(izn)%lcell_no(ilc)
              mfs = mfsbc(lnk_cfbc2zon(izn)%mxy_no(ilc))
              CALL mtoijk(mfs,i,j,kfs,nx,ny)
              icz = lnk_cfbc2zon(izn)%icz_no(ilc)
              IF(kfs >= zone_col(izn)%kmin_no(icz) .AND. kfs <= zone_col(izn)%kmax_no(icz)) THEN
                 IF(qffbc(lc) < 0._kdp) THEN             ! ... Outflow
                    qfzonp_fbc(izn) = qfzonp_fbc(izn) - ufdt1*qffbc(lc)
                    qfzonp(izn) = qfzonp(izn) - ufdt1*qffbc(lc)
                 ELSE                                    ! ... Inflow
                    qfzoni_fbc(izn) = qfzoni_fbc(izn) + ufdt1*qffbc(lc)
                    qfzoni(izn) = qfzoni(izn) + ufdt1*qffbc(lc)
                 END IF
              END IF
           END DO
        END IF
     END IF
     IF(nlbc > 0) THEN
        ! ... Aquifer leakage b.c.
        DO ilc=1,lnk_bc2zon(izn,3)%num_bc
           lc = lnk_bc2zon(izn,3)%lcell_no(ilc)
           ! ... Fluid flow rates
           IF(qflbc(lc) < 0._kdp) THEN           ! ... outflow
              qfzonp_lbc(izn) = qfzonp_lbc(izn) - ufdt1*qflbc(lc)
              qfzonp(izn) = qfzonp(izn) - ufdt1*qflbc(lc)
           ELSEIF(qflbc(lc) > 0._kdp) THEN        ! ...  inflow
              qfzoni_lbc(izn) = qfzoni_lbc(izn) + ufdt1*qflbc(lc)
              qfzoni(izn) = qfzoni(izn) + ufdt1*qflbc(lc)
           END IF
        END DO
     END IF
     IF(fresur .AND. nrbc > 0) THEN
        ! ... River leakage b.c.
        DO ilc=1,lnk_crbc2zon(izn)%num_bc
           lc = lnk_crbc2zon(izn)%lcell_no(ilc)
           mfs = mfsbc(lnk_crbc2zon(izn)%mxy_no(ilc))
           CALL mtoijk(mfs,i,j,kfs,nx,ny)
           icz = lnk_crbc2zon(izn)%icz_no(ilc)
           IF(kfs >= zone_col(izn)%kmin_no(icz) .AND. kfs <= zone_col(izn)%kmax_no(icz)) THEN
              IF(qfrbc(lc) < 0._kdp) THEN           ! ... net outflow
                 qfzonp_rbc(izn) = qfzonp_rbc(izn) - ufdt1*qfrbc(lc)
                 qfzonp(izn) = qfzonp(izn) - ufdt1*qfrbc(lc)
              ELSEIF(qfrbc(lc) > 0._kdp) THEN        ! ... net inflow
                 qfzoni_rbc(izn) = qfzoni_rbc(izn) + ufdt1*qfrbc(lc)
                 qfzoni(izn) = qfzoni(izn) + ufdt1*qfrbc(lc)
              ENDIF
           END IF
        END DO
     END IF
     IF(ndbc > 0) THEN
        ! ... Drain leakage b.c.
        DO ilc=1,lnk_bc2zon(izn,4)%num_bc
           lc = lnk_bc2zon(izn,4)%lcell_no(ilc)
           qfzonp_dbc(izn) = qfzonp_dbc(izn) - ufdt1*qfdbc(lc)
           qfzonp(izn) = qfzonp(izn) - ufdt1*qfdbc(lc)
        END DO
     END IF
     IF(nwel > 0) THEN
        ! ... Wells
        DO ilc=1,seg_well(izn)%num_wellseg
           iwel = seg_well(izn)%iwel_no(ilc)
           ks = seg_well(izn)%ks_no(ilc)
           IF(qflyr(iwel,ks) < 0._kdp) THEN           ! ... Production segment
              qfzonp_wel(izn) = qfzonp_wel(izn) - ufdt1*qflyr(iwel,ks)
              qfzonp(izn) = qfzonp(izn) - ufdt1*qflyr(iwel,ks)
           ELSE                                       ! ... Injection segment
              qfzoni_wel(izn) = qfzoni_wel(izn) + ufdt1*qflyr(iwel,ks)
              qfzoni(izn) = qfzoni(izn) + ufdt1*qflyr(iwel,ks)
           END IF
        END DO
     END IF
  END DO

END SUBROUTINE zone_flow_ss
