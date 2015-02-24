SUBROUTINE dealloc_arr
  ! ... Deallocates the arrays
  USE mcb
  USE mcb_m
  USE mcb2_m
  USE mcc
  USE mcc_m
  USE mcch
  USE mcg
  USE mcm
  USE mcm_m
  USE mcn
  USE mcp
  USE mcp_m
  USE mcs
  USE mcs2
  USE mct_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  USE mg2_m
  USE XP_module, ONLY: Transporter, xp_list, xp_destroy
  IMPLICIT NONE
  INTEGER :: da_err, i, j
  !     ------------------------------------------------------------------
  !...
  !$$  IF (mpi_myself == 0) THEN
  ! ... Deallocate from init1
  ! ... Deallocate program control information: mcc and mcc_m
  DEALLOCATE (iprint_chem, iprint_xyz,  &
       lprnt1, lprnt2,  &
       vmask,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 1"
     STOP
  ENDIF
  ! ... Deallocate node information arrays: mcn
  DEALLOCATE (rm, x, y, z, x_node, y_node, z_node,  &
       x_face, y_face, z_face,  pv, &
       pv0, volume, por, &
       phreeqc_density, &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 2"  
     STOP
  ENDIF
  ! ... Deallocate boundary condition information: mcb and mcb_m
  DEALLOCATE(ibc, char_ibc, ibc_string,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 3"  
     STOP
  ENDIF
  ! ... Deallocate character strings for output: mcch
  DEALLOCATE(caprnt,  & 
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 5"  
     STOP
  ENDIF
  ! ... Deallocate character strings for output: mcch_m
  DEALLOCATE(comp_name,  & 
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 5.1"
     STOP
  ENDIF
  ! ... Deallocate dependent variable arrays: mcv
  DEALLOCATE (dzfsdt, dp, dt,  &
       sxx, syy, szz, vxx, vyy, vzz,  &
       zfs,  &
       eh, frac, sat, frac_icchem, p, t,  &
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 6"  
     STOP
  ENDIF
  ! ... Deallocate dependent variable arrays: mcv_m
  ! ...      component arrays
  DEALLOCATE (icmax, jcmax, kcmax,  &
       indx_sol1_ic, indx_sol2_ic,  &
       vx_node, vy_node, vz_node,  &
       dc,  &
       dcmax, dsir, dsir_chem,  &
       stsaif, stsetb, stsfbc, stslbc,  &
       stsrbc, stsdbc, stssbc, stswel,  &
       ssresf, ssres, stotsi, stotsp,  &
       tsres, tsresf,  &
       qsfx, qsfy, qsfz,  &
       sir, sir0, sirn, sir_prechem,  &
       totsi, totsp, tdsir_chem, tcsaif, tcsetb,  &
       tcsfbc, tcslbc, tcsrbc, tcsdbc, tcssbc,  &
       c, ic_mxfrac,   &
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 7"  
     STOP
  ENDIF
  ! ... Deallocate program control information: mcc_m
  DEALLOCATE (dctas,  &
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 8"  
     STOP
  ENDIF
  ! ... Deallocate matrix of difference equations arrays: mcm
  DEALLOCATE (rf,  &
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 9"  
     STOP
  ENDIF
  ! ... Deallocate well information: mcw_m
  DEALLOCATE(totwsi, totwsp,  &
       tqwsi, tqwsp, u10,  &
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed: dealloc_arr, init1, point 10"
     STOP
  ENDIF
  ! ... Deallocate from read2
  ! ... Deallocate the parameter arrays: mcp
  DEALLOCATE (rcppm,  &
       abpm, alphl, alphth, alphtv, tort, poros,  &
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed: dealloc_arr, read2, point 2"
     STOP
  ENDIF
  ! ... Deallocate the parameter arrays: mcp_m
  DEALLOCATE (kx, ky, kz, kxx, kyy, kzz,  &
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "Array deallocation failed: dealloc_arr, read2, point 3"
     STOP
  ENDIF
  ! ... Deallocate region geometry information: mcg
  DEALLOCATE(i1z, i2z, j1z, j2z, k1z, k2z,  &
       STAT = da_err)
  IF(da_err /= 0) THEN  
     PRINT * , "Array deallocation failed: dealloc_arr, read2, point 4"
     STOP
  ENDIF
  IF(nwel > 0) THEN
     ! ... Deallocate the well arrays: mcw and mcw_m
     DEALLOCATE (welidno, xw, yw, wbod, wqmeth,  &
          mwel, wcfl, wcfu, zwb, zwt,  &
          dwb, dwt,  &
          wfrac, nkswel,  &
          mxf_wel,  &
          wrangl,  &
          wrid,  &
          wrruf,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, read2, point 6"  
        STOP
     ENDIF
  END IF
  IF(nsbc > 0) THEN
     ! ... Deallocate specified value b.c. arrays: mcb and mcb_m
     DEALLOCATE (msbc,  &
          psbc, psbc_n, csbc, indx1_sbc, indx2_sbc, mxf_sbc,  &
          STAT = da_err)
     IF (da_err /= 0) THEN
        PRINT *, "array deallocation failed: dealloc_arr, read2, svbc.2"
        STOP
     ENDIF
  END IF

  IF(nfbc > 0) THEN
     ! ... Deallocate specified flux b.c. arrays: mcb and mcb_m          
     DEALLOCATE (mfbc, ifacefbc, areafbc,  &
          qfflx, qfflx_n, denfbc, qsflx, qsflx_n,  &
          cfbc, cfbc_n, indx1_fbc, indx2_fbc, mxf_fbc,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, read2, flux.2"  
        STOP
     ENDIF
  END IF

  IF(nlbc > 0) THEN
     ! ... Deallocate leakage b.c. arrays: mcb and mcb_m
     DEALLOCATE (mlbc, ifacelbc, arealbc,  &
          albc, blbc,  &
          klbc, bblbc, zelbc, &
          philbc, philbc_n, denlbc, vislbc,  &
          clbc, clbc_n, indx1_lbc, indx2_lbc, mxf_lbc,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, read2, leak.2"  
        STOP
     ENDIF
  END IF

  IF(nrbc > 0) THEN
     ! ...      Deallocate river arrays: mcb and mcb_m
     DEALLOCATE (mrbc, arearbc,  &
          arbc, brbc,  &
          krbc, bbrbc, zerbc,  &
          mrseg_bot,  &
          phirbc, phirbc_n, &
          denrbc, visrbc,  &
          crbc, crbc_n, indx1_rbc, indx2_rbc, mxf_rbc,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, read2, river.2"  
        STOP
     ENDIF
  END IF

  IF(ndbc > 0) THEN
     ! ...      Deallocate drain arrays: mcb and mcb_m
     DEALLOCATE (mdbc, areadbc,  &
          adbc, bdbc,  &
          kdbc, bbdbc, zedbc,  &
          mdseg_bot, &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array allocation failed: dealloc_arr, read2, drain.2"  
        STOP
     ENDIF
  END IF
  IF(num_flo_zones > 0) THEN
      ! ... Deallocate zone arrays for local flow rates: mcb2_m
      do i = 1, num_flo_zones
          ! zone_ib is type internal_bndry_zone
          if (allocated(zone_ib)) then 
              if (zone_ib(i)%num_int_faces > 0) then
                  DEALLOCATE(zone_ib(i)%mcell_no,  &  
                  zone_ib(i)%face_indx,  &        
                  STAT = da_err)
                  IF (da_err /= 0) THEN  
                      PRINT *, "array deallocation failed: dealloc_arr, read2, flow zones.1.2"  
                      STOP
                  ENDIF
              endif 
          endif
          ! zone_col is type zone_volume
          if (allocated(zone_col)) then
              if (zone_col(i)%num_xycol > 0) then
                  DEALLOCATE(zone_col(i)%i_no,  &  
                  zone_col(i)%j_no,  &  
                  zone_col(i)%kmin_no,  &  
                  zone_col(i)%kmax_no,  &        
                  STAT = da_err)
                  IF (da_err /= 0) THEN  
                      PRINT *, "array deallocation failed: dealloc_arr, read2, flow zones.1.2"  
                      STOP
                  ENDIF
              endif 
          endif
          ! lnk_cfbc2zon is type zone_cbc_cells
          if (allocated(lnk_cfbc2zon)) then
              if (lnk_cfbc2zon(i)%num_bc > 0) then
                  DEALLOCATE(lnk_cfbc2zon(i)%lcell_no,  &  
                  lnk_cfbc2zon(i)%mxy_no,  &  
                  lnk_cfbc2zon(i)%icz_no,  &        
                  STAT = da_err)
                  IF (da_err /= 0) THEN  
                      PRINT *, "array deallocation failed: dealloc_arr, read2, flow zones.1.2"  
                      STOP
                  ENDIF
              endif  
          endif
          ! lnk_crbc2zon is type zone_cbc_cells
          if (allocated(lnk_crbc2zon)) then
              if (lnk_crbc2zon(i)%num_bc > 0) then
                  DEALLOCATE(lnk_crbc2zon(i)%lcell_no,  &  
                  lnk_crbc2zon(i)%mxy_no,  &  
                  lnk_crbc2zon(i)%icz_no,  &        
                  STAT = da_err)
                  IF (da_err /= 0) THEN  
                      PRINT *, "array deallocation failed: dealloc_arr, read2, flow zones.1.2"  
                      STOP
                  ENDIF
              endif    
          endif
          ! lnk_bc2zon is type zone_bc_cells
          if (allocated(lnk_bc2zon)) then
              do j = 1, 4
                  if (lnk_bc2zon(i,j)%num_bc > 0) then
                      DEALLOCATE(lnk_bc2zon(i,j)%lcell_no,  &    
                      STAT = da_err)
                      IF (da_err /= 0) THEN  
                          PRINT *, "array deallocation failed: dealloc_arr, read2, flow zones.1.2"  
                          STOP
                      ENDIF
                  endif     
              enddo
          endif
          ! seg_well is type well_segments
          if (nwel > 0) then
              if (allocated(seg_well)) then 
                  if (seg_well(i)%num_wellseg > 0) then
                      DEALLOCATE(seg_well(i)%iwel_no, seg_well(i)%ks_no, STAT = da_err)
                      IF (da_err /= 0) THEN  
                          PRINT *, "array deallocation failed: dealloc_arr, read2, flow zones.1.1"  
                          STOP
                      ENDIF
                  endif
              endif 
          endif
          
      enddo

      DEALLOCATE (zone_title, zone_number, &
          zone_ib, lnk_bc2zon, seg_well,  &
          zone_filename_heads,  &
          zone_write_heads,  &
          STAT = da_err)
      IF (da_err /= 0) THEN  
          PRINT *, "array deallocation failed: dealloc_arr, read2, flow zones.1.3"  
          STOP
      ENDIF
     !IF(fresur .AND. (nfbc > 0 .OR. nrbc > 0)) THEN
        ! ... Deallocate space for zone volume cell index data,
        ! ...     optional flux bc data, optional river bc data: mcb2_m
        DEALLOCATE(zone_col, lnk_cfbc2zon, lnk_crbc2zon,  &
             STAT = da_err)
        IF (da_err /= 0) THEN  
           PRINT *, "array deallocation failed: dealloc_arr, read2, flow zones.1.4"  
           STOP
        ENDIF
     !END IF
  END IF
  ! ... Deallocate init2_1 arrays
  ! ... Deallocate the mask for cross dispersion calculation: mcg
  DEALLOCATE (xd_mask,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: dealloc_arr, init2.1, number 1"  
     STOP
  ENDIF

  ! ... Deallocate geometry information: mcg 
  DEALLOCATE (arx, ary, arz, grid2chem, &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: dealloc_arr, init2.1, number 2"
     STOP
  ENDIF

  ! ... Deallocate parameter arrays: mcp
  DEALLOCATE (tx, ty, tz, tfx, tfy, tfz,  &
       tsx, tsy, tsz, tsxy, tsxz, tsyx, tsyz, tszx, tszy,  &
       pmcv, pmhv, pmchv, pvk,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: dealloc_arr, init2.1, number 3"
     STOP
  ENDIF

!!$  ! ... Deallocate geometry information: mg2_m
!!$  DEALLOCATE (arxbc, arybc, arzbc, delz,  &
!!$       STAT = da_err)
!!$  IF (da_err /= 0) THEN  
!!$     PRINT *, "Array deallocation failed: dealloc_arr, init2.1, number 4"
!!$     STOP
!!$  ENDIF

  ! ... Deallocate space for boundary cell structure: mcb_m
  DEALLOCATE (b_cell,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 5"  
     STOP
  ENDIF

  IF(nwel > 0) THEN
     ! ... Deallocate more well arrays: mcw
     DEALLOCATE (iw, jw, wi,  &
          qwlyr, qflyr, qflyr_n, dqwdpl,  &
          denwk, pwk, cwk, twk, udenw,  &
          dpwkt, tfw,  &
          qwm, qwm_n, qwv, qwv_n, qhw,  &
          rhsw, vaw,  &
          pwsurs, pwkt,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: dealloc_arr, init2.1, number 7"  
        STOP  
     ENDIF

     ! ... Deallocate more well arrays: mcw_m
     DEALLOCATE (indx1_wel, indx2_wel,  &
          wficum, wfpcum, wsicum, wspcum,  &
          qslyr, qsw, qsw_n,  &
          stfwp, sthwp, stswp,  &
          stfwi, sthwi, stswi,  &
          cwkt, cwkts,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: dealloc_arr, init2.1, number 8"  
        STOP
     ENDIF
  END IF

  IF(nsbc > 0) THEN  
     ! ... Deallocate specified value b.c. arrays: mcb
     DEALLOCATE (qfsbc, qhsbc,  &
          fracnp,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 9"  
        STOP
     ENDIF
     ! ... Deallocate specified value b.c. arrays: mcb_m
     DEALLOCATE (qssbc,  &
          sfsb, sfvsb, sssb,  &
          ccfsb, ccfvsb, ccssb,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 10"  
        STOP
     ENDIF
     ! ... Deallocate difference equations arrays: mcm
     DEALLOCATE (vafsbc, rhfsbc,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 11"  
        STOP
     ENDIF
     ! ... Deallocate difference equations arrays: mcm_m
     DEALLOCATE (vassbc, rhssbc,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 12"  
        STOP
     ENDIF
  END IF

  IF(nfbc > 0) THEN
     ! ... Deallocate specified flux b.c. arrays: mcb
     DEALLOCATE (qffbc, qfbcv, qhfbc,  &
          flux_seg_m, flux_seg_first, flux_seg_last,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 13, flux"  
        STOP
     ENDIF
     ! ... Deallocate specified flux b.c. arrays: mcb_m
     DEALLOCATE (qsfbc,  &
          sffb, sfvfb, ssfb,  &
          ccffb, ccfvfb, ccsfb,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 14, flux"  
        STOP
     ENDIF
  END IF

  IF(nlbc > 0) THEN
     ! ... Deallocate leakage b.c. arrays: mcb
     DEALLOCATE (qflbc,  & 
          leak_seg_m, leak_seg_first, leak_seg_last,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 15, leak"  
        STOP
     ENDIF
     ! ... Deallocate leakage b.c. arrays: mcb_m
     DEALLOCATE (qslbc,  &
          sflb, sfvlb, sslb,  &
          ccflb, ccfvlb,  ccslb,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 16, leak"  
        STOP
     ENDIF
  END IF

  IF(nrbc > 0) THEN  
     ! ... Deallocate river leakage b.c. arrays: mcb
     DEALLOCATE (qfrbc, &
          river_seg_m, river_seg_first, river_seg_last,  &
          mrbc_bot, mrbc_top,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed:  dealloc_arr, init2.1, number 17, river"  
        STOP
     ENDIF
     ! ... Deallocate river leakage b.c. arrays: mcb_m
     DEALLOCATE (qsrbc,  &
          sfrb, sfvrb, ssrb,  &
          ccfrb, ccfvrb, ccsrb,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 18, river"  
        STOP
     ENDIF
  END IF

  IF(ndbc > 0) THEN  
     ! ... Deallocate drain b.c. arrays: mcb
     DEALLOCATE (qfdbc, &
          drain_seg_m, drain_seg_first, drain_seg_last,  &
          mdbc_bot,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 19, drain"  
        STOP
     ENDIF
     ! ... Deallocate drain b.c. arrays: mcb_m
     DEALLOCATE (qsdbc,  &
          sfdb, sfvdb, ssdb,  &
          ccfdb, ccfvdb,  ccsdb,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 20, drain"  
        STOP
     ENDIF
  END IF

  IF(num_flo_zones > 0) THEN
     ! ... Deallocate the arrays for accumulation of zonal flow rates: mcv_m
     DEALLOCATE (qfzoni, qfzonp, qfzoni_int, qfzonp_int,  &
          qfzoni_sbc, qfzonp_sbc,  &
          qfzoni_fbc, qfzonp_fbc, qfzoni_lbc, qfzonp_lbc, qfzoni_rbc, qfzonp_rbc,  &
          qfzoni_dbc, qfzonp_dbc, qfzoni_wel, qfzonp_wel,  &
          qszoni, qszonp, qszoni_int, qszonp_int,  &
          qszoni_sbc, qszonp_sbc,  &
          qszoni_fbc, qszonp_fbc, qszoni_lbc, qszonp_lbc, qszoni_rbc, qszonp_rbc,  &
          qszoni_dbc, qszonp_dbc, qszoni_wel, qszonp_wel,  &
          qface_in, qface_out, &
          STAT = da_err)
     IF (da_err /= 0) THEN
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 21"
        STOP
     ENDIF
  END IF

  ! ... Deallocate solver space: mcs
  DEALLOCATE (cin,  &
       STAT = da_err)
  IF (da_err /= 0) THEN
     PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 22"
     STOP
  ENDIF

  IF(slmeth == 1) THEN
     ! ... Deallocate solver arrays: mcs
     DEALLOCATE (ind, mrno, mord,  &
          ip1, ip1r, ipenv,  &
          ci, cir, cirh, cirl,  &
          STAT = da_err)
     IF (da_err /= 0) THEN
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 24"
        STOP
     ENDIF
     ! ... Deallocate space for the solver: mcs2
     DEALLOCATE(diagra, envlra, envura,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 25"
        STOP
     ENDIF
  ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN
     ! ... Deallocate solver arrays: mcs
     DEALLOCATE (ind, mrno, mord, ci, cir, cirh, cirl,  &
          STAT = da_err)
     IF (da_err /= 0) THEN
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 26"
        STOP
     ENDIF
     ! ... Deallocate space for the solver: mcs2
     DEALLOCATE(ap, bbp, ra, rr, sss, xx, ww, zz, sumfil,  &
          STAT = da_err)
     IF (da_err /= 0) THEN
        PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 27"
        STOP
     ENDIF
  END IF

  ! ... Deallocate space for the assembly of difference equations: mcm
  DEALLOCATE(va, rhs,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 28"
     STOP
  ENDIF
  ! ... Deallocate more solver arrays: mcs
  DEALLOCATE(diagc, diagr,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 29"
     STOP
  ENDIF

  ! ... Deallocate free surface, water table arrays: mcb and mg2_m
  DEALLOCATE (mfsbc, hdprnt, wt_elev, print_dry_col,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "array deallocation failed: dealloc_arr, init2.1, number 30"  
     STOP  
  ENDIF

  ! ... Deallocate printout arrays: mct_m
  DEALLOCATE (aprnt1, aprnt2, aprnt3, aprnt4,  &
       c_mol,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: dealloc_arr, write2_1, number 1"
     STOP  
  ENDIF

  IF (local_ns > 0) THEN
     DO i = 1, local_ns
        CALL XP_destroy(xp_list(i))
     ENDDO
     DEALLOCATE (xp_list,  &
          STAT = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: dealloc_arr, xp_list"
        STOP  
     ENDIF
  ENDIF

  IF (solute) THEN
      DEALLOCATE (component_map, local_component_map,  &
           STAT = da_err)
      IF (da_err /= 0) THEN  
         PRINT *, "Array deallocation failed: dealloc_arr, component_map"
         STOP  
      ENDIF
  ENDIF

END SUBROUTINE dealloc_arr
