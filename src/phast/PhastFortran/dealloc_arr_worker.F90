SUBROUTINE dealloc_arr_worker
  ! ... Deallocates the array space used for the transport simulation
  ! *** extracted from closef routine
!!$  USE f_units
  USE mcb
  USE mcc
  USE mcch
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcs
  USE mcs2
  USE mcv
  USE mcw
  USE mg2_m
  USE XP_module, ONLY: Transporter, xp_list, xp_destroy
  IMPLICIT NONE
  INTEGER :: da_err, i
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: dealloc_arr_worker.F90,v 1.1 2013/09/19 20:41:58 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
    IF (.not.solute) THEN
        RETURN
    ENDIF

    ! ... Only solute
    DEALLOCATE (comp_name, &
        indx_sol1_ic, indx_sol2_ic, &
        STAT = da_err)
    IF (da_err /= 0) THEN  
        PRINT *, "Array allocation failed: phast_worker 2"  
        STOP  
    ENDIF
    ! ... Deallocate from init1
    ! ... Deallocate node information arrays: mcn
    DEALLOCATE (rm, x, y, z, x_node, y_node, z_node,  &
        x_face, y_face, z_face, pv, &
        pv0, volume, tort, &
        STAT = da_err)
    IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: dealloc_arr_worker, init1_trans, point 1"  
        STOP
    ENDIF
    ! ... Deallocate boundary condition information: mcb and mcb_m
    DEALLOCATE(ibc, char_ibc, &
        STAT = da_err)
    IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: dealloc_arr_worker, init1_trans, point 2"  
        STOP
    ENDIF
    ! ... Deallocate character strings for output: mcch
    DEALLOCATE(caprnt,  & 
        STAT = da_err)
    IF (da_err /= 0) THEN
        PRINT *, "Array deallocation failed: dealloc_arr_worker, init1_trans, point 3"  
        STOP
    ENDIF
    ! ... Deallocate dependent variable arrays: mcv
    DEALLOCATE (dzfsdt, dp, dt,  &
        sxx, syy, szz, vxx, vyy, vzz,  &
        zfs,  &
        eh, frac, frac_icchem, p, t,  &
        STAT = da_err)
    IF (da_err /= 0) THEN
        PRINT *, "Array deallocation failed: dealloc_arr_worker, init1_trans, point 4"  
        STOP
    ENDIF

    ! ... Deallocate from read2
    ! ... Deallocate the parameter arrays: mcp
    IF (xp_group) THEN
        DEALLOCATE (rcppm,  &
            abpm, alphl, alphth, alphtv, poros,  &
            STAT = da_err)
        IF (da_err /= 0) THEN
            PRINT *, "Array deallocation failed: dealloc_arr_worker, receive2_trans, point 7"
            STOP
        ENDIF

        ! ... Deallocate region geometry information: mcg
        DEALLOCATE(i1z, i2z, j1z, j2z, k1z, k2z,  &
            STAT = da_err)
        IF(da_err /= 0) THEN  
            PRINT * , "Array deallocation failed: dealloc_arr_worker, receive2_trans, point 8"
            STOP
        ENDIF
        IF(nwel > 0) THEN
            ! ... Deallocate the well arrays: mcw
            DEALLOCATE (welidno, xw, yw, wbod, wqmeth,  &
                mwel, wcfl, wcfu, zwb, zwt,  &
                dwb, dwt,  &
                wfrac, nkswel,  &
                wrangl, &
                wrruf, &   
                wrid, &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "array deallocation failed: dealloc_arr_worker, receive2_trans, point 9"  
                STOP
            ENDIF
        END IF
        IF(nsbc > 0) THEN
            ! ... Deallocate specified value b.c. arrays: mcb and mcb_w
            DEALLOCATE (msbc,  &
                psbc, psbc_n,  &
                STAT = da_err)
            IF (da_err /= 0) THEN
                PRINT *, "array deallocation failed: dealloc_arr_worker, receive2_trans, svbc.2"
                STOP
            ENDIF
        END IF
        IF(nfbc > 0) THEN
            ! ... Deallocate specified flux b.c. arrays: mcb !!$ and mcb_w
            DEALLOCATE (mfbc, ifacefbc, areafbc,  &
                qfflx, qfflx_n, denfbc,  &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "array deallocation failed: dealloc_arr_worker, receive2_trans, flux.2"  
                STOP
            ENDIF
        END IF
        IF(nlbc > 0) THEN
            ! ... Deallocate leakage b.c. arrays: mcb !$$and mcb_w
            DEALLOCATE (mlbc, ifacelbc, arealbc,  &
                albc, blbc,  &
                klbc, bblbc, zelbc, &
                philbc, philbc_n, denlbc, vislbc,  &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "array deallocation failed: dealloc_arr_worker, receive2_trans, leak.2"  
                STOP
            ENDIF
        END IF
        IF(nrbc > 0) THEN
            ! ...      Deallocate river arrays: mcb !$$and mcb_w
            DEALLOCATE (mrbc, arearbc,  &
                arbc, brbc,  &
                krbc, bbrbc, zerbc,  &
                mrseg_bot,  &
                phirbc, phirbc_n, denrbc, visrbc,  &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "array deallocation failed: dealloc_arr_worker, receive2_trans, river.2"  
                STOP
            ENDIF
        END IF
        IF(ndbc > 0) THEN
            ! ...      Deallocate drain arrays: mcb !$$and mcb_w
            DEALLOCATE (mdbc, areadbc,  &
                adbc, bdbc,  &
                kdbc, bbdbc, zedbc,  &
                mdseg_bot,  &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "array allocation failed: dealloc_arr_worker, receive2_trans, drain.2"  
                STOP
            ENDIF
        END IF

        ! ... Deallocate init2_1 arrays
        ! ... Deallocate the mask for cross dispersion calculation: mcg
        DEALLOCATE (xd_mask,  &
            STAT = da_err)
        IF (da_err /= 0) THEN  
            PRINT *, "Array deallocation failed: dealloc_arr_worker, init2.1_trans, number 1"  
            STOP
        ENDIF
        ! ... Deallocate geometry information: mcg 
        DEALLOCATE (arx, ary, arz, grid2chem, &
            STAT = da_err)
        IF (da_err /= 0) THEN  
            PRINT *, "Array deallocation failed: dealloc_arr_worker, init2.1_trans, number 2"
            STOP
        ENDIF
        ! ... Deallocate parameter arrays: mcp
        DEALLOCATE (tx, ty, tz, tfx, tfy, tfz,  &
            tsx, tsy, tsz, tsxy, tsxz, tsyx, tsyz, tszx, tszy,  &
            pmcv, pmhv, pmchv, pvk,  &
            STAT = da_err)
        IF (da_err /= 0) THEN  
            PRINT *, "Array deallocation failed: dealloc_arr_worker, init2.1_trans, number 3"
            STOP
        ENDIF
        IF(nwel > 0) THEN
            ! ... Deallocate more well arrays: mcw
            DEALLOCATE (iw, jw, wi,  &
                qwlyr, qflyr, dqwdpl,  &
                denwk, pwk, twk, udenw,  &
                dpwkt, tfw,  &
                qwm, qwv, qwv_n, qhw,  &
                rhsw, vaw,  &
                pwsurs, pwkt,  &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "Array deallocation failed: dealloc_arr_worker, init2.1_trans, number 7"  
                STOP  
            ENDIF
        END IF
        IF(nsbc > 0) THEN  
            ! ... Deallocate specified value b.c. arrays: mcb
            DEALLOCATE (qfsbc, qhsbc,  &
                fracnp,  &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 9"  
                STOP
            ENDIF
        END IF
        IF(nfbc > 0) THEN
            ! ... Deallocate specified flux b.c. arrays: mcb
            DEALLOCATE (qffbc, qfbcv, qhfbc,  &
                flux_seg_m, flux_seg_first, flux_seg_last,  &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 13, flux"  
                STOP
            ENDIF
        END IF
        IF(nlbc > 0) THEN
            ! ... Deallocate leakage b.c. arrays: mcb
            DEALLOCATE (qflbc,  & 
                leak_seg_m, leak_seg_first, leak_seg_last,  &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 15, leak"  
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
                PRINT *, "array deallocation failed:  dealloc_arr_worker, init2.1_trans, number 17, river"  
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
                PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 19, drain"  
                STOP
            ENDIF
        END IF
        ! ... Deallocate solver space: mcs
        DEALLOCATE (cin,  &
            STAT = da_err)
        IF (da_err /= 0) THEN
            PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 22"
            STOP
        ENDIF

        IF(slmeth == 1) THEN
            ! ... Deallocate solver arrays: mcs
            DEALLOCATE (ind, mrno, mord,  &
                ip1, ip1r, ipenv,  &
                ci, cir, cirh, cirl,  &
                STAT = da_err)
            IF (da_err /= 0) THEN
                PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 24"
                STOP
            ENDIF
            ! ... Deallocate space for the solver: mcs2
            DEALLOCATE(diagra, envlra, envura,  &
                STAT = da_err)
            IF (da_err /= 0) THEN  
                PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 25"
                STOP
            ENDIF
        ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN
            ! ... Deallocate solver arrays: mcs
            DEALLOCATE (ind, mrno, mord, ci, cir, cirh, cirl,  &
                STAT = da_err)
            IF (da_err /= 0) THEN
                PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 26"
                STOP
            ENDIF
            ! ... Deallocate space for the solver: mcs2
            DEALLOCATE(ap, bbp, ra, rr, sss, xx, ww, zz, sumfil,  &
             STAT = da_err)
            IF (da_err /= 0) THEN
                PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 27"
                STOP
            ENDIF
        END IF
        ! ... Deallocate space for the assembly of difference equations: mcm
        DEALLOCATE(va, rhs,  &
            STAT = da_err)
        IF (da_err /= 0) THEN  
            PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 28"
            STOP
        ENDIF
        ! ... Deallocate more solver arrays: mcs
        DEALLOCATE(diagc, diagr,  &
            STAT = da_err)
        IF (da_err /= 0) THEN  
            PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 29"
            STOP
        ENDIF
        ! ... Deallocate free surface: mcb
        DEALLOCATE (mfsbc, &
            STAT = da_err)
        IF (da_err /= 0) THEN  
            PRINT *, "array deallocation failed: dealloc_arr_worker, init2.1_trans, number 30"  
            STOP
        ENDIF

        DO i = 1, local_ns
            CALL XP_destroy(xp_list(i))
        ENDDO

        DEALLOCATE (xp_list,  &
            STAT = da_err)
        IF (da_err /= 0) THEN  
            PRINT *, "Array deallocation failed: dealloc_arr_worker, xp_list"
            STOP  
        ENDIF
    ENDIF ! xp_group

    IF (xp_group) THEN
        DEALLOCATE (component_map, local_component_map,  &
            STAT = da_err)
        IF (da_err /= 0) THEN  
            PRINT *, "Array deallocation failed: dealloc_arr_worker, component_map"
            STOP  
            ENDIF
    ENDIF
END SUBROUTINE dealloc_arr_worker
