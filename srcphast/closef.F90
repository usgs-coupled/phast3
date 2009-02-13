SUBROUTINE closef(mpi_myself)
  ! ... Closes and deletes files and writes indices of time values
  ! ...      at which dependent variables have been saved
  ! ... Also deallocates the arrays
  USE f_units
  USE mcb
  USE mcb2
  USE mcc
  USE mcch
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcs
  USE mcs2
  USE mct
  USE mcv
  USE mcw
  USE mg2, ONLY: hdprnt, wt_elev
#if defined(USE_MPI)
  USE mpi_mod
#endif
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: mpi_myself
  CHARACTER(LEN=6), DIMENSION(40) :: st
  INTEGER :: da_err, i1p, i2p, ifu, ip  
  CHARACTER(LEN=130) :: logline1, logline2, logline3
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Close and delete the stripped input file
  CLOSE(fuins,STATUS='DELETE')  
  IF(errexi) THEN
     logline1 = '          *** Simulation Aborted Due to Input Errors ***'
     logline2 = '               Please examine log file'
!!$     WRITE(*,'(//a/a/)') logline1,logline2
     CALL errprt_c(logline1)
     CALL errprt(1,200)  
     RETURN  
  ENDIF
  IF(errexe) THEN  
     logline1 = '          *** Simulation Aborted Due to Execution Errors ***'
     WRITE(logline2,3101) '               Time ..... ',cnvtmi*time,' ('//TRIM(unittm)//')'
3101 FORMAT(a,1pg12.4,a)
!!$     WRITE(*,9003) logline1,logline2
     CALL errprt_c(logline1)
     CALL errprt_c(logline2)
     CALL errprt(1,200)  
     RETURN  
  ENDIF
  logline1 = '                             ***** Simulation Completed ***** '
  WRITE(logline2,5004) '     Last time value calculated '//dots, cnvtmi* &
       time,' ('//TRIM(unittm)//')'
5004 FORMAT(a70,1pg11.4,a)  
  WRITE(logline3,5014) '     Last time step index '//dots,itime
5014 FORMAT(a70,i8)  
  DO  ifu=fup,fubcf
     WRITE(ifu,2003) TRIM(logline1)
2003 FORMAT(//TR10,A)
     WRITE(ifu,2004) TRIM(logline2)
     WRITE(ifu,2004) TRIM(logline3)
2004 FORMAT(tr10,a)  
  END DO
  WRITE(fuzf,2003) TRIM(logline1)
  WRITE(fuzf,2004) TRIM(logline2)
  WRITE(fuzf,2004) TRIM(logline3)
  CALL logprt_c(' ')
  CALL logprt_c(logline1)
  CALL logprt_c(logline2)
  CALL logprt_c(logline3)
  WRITE(fulp,2003) TRIM(logline1)
  WRITE(fulp,2004) TRIM(logline2)
  WRITE(fulp,2004) TRIM(logline3)
  IF(NMAPR > 0) THEN  
     WRITE(logline1,5005) '     Number of map records written '//DOTS, &
          NMAPR
5005 FORMAT(A70,I8)
     CALL logprt_c(logline1)
  ENDIF
  IF (mpi_myself == 0) THEN
     IF(CHKPTD) THEN  
        IF(ABS(pricpd) > 0._kdp) THEN
           logline1 = '     Check point dump made at the following times ('//TRIM(unittm)//')'
           WRITE(FULP,2004) TRIM(logline1)
           CALL logprt_c(logline1)
           i1p = - 9  
20         i1p = i1p + 10  
           i2p = MIN(i1p+9,nrsttp)  
           WRITE(fulp,2007) (idmptm(ip), ip=i1p,i2p)  
2007       FORMAT(tr5,10i10)  
           WRITE(fulp,2008) (cnvtmi*dmptm(ip), ip = i1p, i2p)  
2008       FORMAT(tr5,10(1pg12.5)/)  
           IF(i2p.LT.nrsttp) GOTO 20  
        ENDIF
        IF(ABS(pricpd) >= timchg) THEN  
           logline1 = '     Check point dump made at last time step'
           WRITE(fulp,2009) TRIM(logline1)
2009       FORMAT(tr10,2a)  
           CALL logprt_c(logline1)
        ENDIF
        WRITE(logline1,5005) '     Number of restart time planes written '//dots,nrsttp
        WRITE(fulp,2009) TRIM(logline1)
        CALL logprt_c(logline1)
        IF(savldo) THEN  
           logline1 = '     Only the most recent dump has been saved'
           WRITE(fulp,2009) TRIM(logline1)
           CALL logprt_c(logline1)
        ENDIF
     ENDIF
  ENDIF
  ! ... delete the read echo 'furde' file upon successful completion
!!$  st(furde) = 'delete'
!!$  if(errexi .or. errexe) st(furde) = 'keep  '
  ! ... delete file 'fuplt' if no plot data written
  st(fuplt) = 'delete'  
  IF(solute .AND. ntprtem > 0) st(fuplt) = 'keep  '  
  ! ... delete file 'fuorst' if no restart records written
  st(fuorst) = 'delete'  
  IF(nrsttp > 0) st(fuorst) = 'keep  '  
  ! ... delete file 'fupmap', file 'fupmp2', and file 'fuvmap'
  ! ...      if no screen or plotter map data written
  st(fupmap) = 'delete'  
  st(fupmp2) = 'delete'  
  st(fupmp3) = 'delete'  
  st(fuvmap) = 'delete'  
  st(fuich) = 'delete'
  IF (mpi_myself == 0) THEN
     IF(cntmapc) st(fupmap) = 'keep  '  
     IF(prtic_maphead .OR. ABS(primaphead) > 0._kdp) THEN
        st(fupmp2) = 'keep  '  
        st(fupmp3) = 'keep  '  
     END IF
     IF(ntprmapv > 0) st(fuvmap) = 'keep  '  
     IF(prtichead) st(fuich) = 'keep  '
  ENDIF
!!$  ! ... delete file 'fuich' if no initial condition head map data written
!!$  st(fuich) = 'keep  '  
!!$  if(.not.prtichead) st(fuich) = 'delete'  
  ! ... close and delete file 'fupzon' if no zone map data written
  st(fupzon) = 'delete'  
!!$  if(pltzon) st(fupzon) = 'keep  '  
  st(fulp) = 'keep  '
  st(fup) = 'delete'  
  IF(ntprp > 0) st(fup) = 'keep  '  
  st(fuwt) = 'delete'  
  IF(ntprp > 0) st(fuwt) = 'keep  '  
  st(fuc) = 'delete'  
  IF(ntprc > 0 .AND. solute) st(fuc) = 'keep  '  
  st(fuvel) = 'delete'  
  IF(ntprvel > 0) st(fuvel) = 'keep  '  
  st(fuwel) = 'delete'  
  IF(ntprwel > 0) st(fuwel) = 'keep  '  
  st(fubal) = 'delete'  
  IF(ntprgfb > 0) st(fubal) = 'keep  '  
  st(fukd) = 'delete'  
  IF(ntprkd > 0 .OR. prt_kd) st(fukd) = 'keep  '  
  st(fubcf) = 'delete'  
  IF(ntprbcf > 0) st(fubcf) = 'keep  '  
  st(fuzf) = 'delete'  
  IF(ntprzf > 0) st(fuzf) = 'keep  '  
  st(fuzf_tsv) = 'delete'  
  IF(ntprzf_tsv > 0) st(fuzf_tsv) = 'keep  '  
!!$  st(fut) = 'delete'  
!!$#if defined(MERGE_FILES)
!!$  CALL update_status(st)
!!$#endif
  ! ... Close the files
  IF(print_rde) CLOSE(furde,status='keep')  
  CLOSE(fuorst, status = st(fuorst))  
  CLOSE(fulp, status = st(fulp))  
  CLOSE(fup, status = st(fup))  
  CLOSE(fuwt, status = st(fuwt))  
  CLOSE(fuc, status = st(fuc))  
  CLOSE(fuvel, status = st(fuvel))  
  CLOSE(fuwel, status = st(fuwel))  
  CLOSE(fubal, status = st(fubal))  
  CLOSE(fukd, status = st(fukd))  
  CLOSE(fubcf, status = st(fubcf))  
  CLOSE(fuzf, status = st(fuzf))
  CLOSE(fuzf_tsv, status = st(fuzf_tsv))
  CLOSE(fuplt, status = st(fuplt))  
  CLOSE(fupmap, status = st(fupmap))  
  CLOSE(fupmp2, status = st(fupmp2))  
  CLOSE(fupmp3, status = st(fupmp3))  
  CLOSE(fuvmap, status = st(fuvmap))  
!!$  close(fupzon, status = st(fupzon))  
!!$  close(fubnfr, status = st(fubcf))  
  CLOSE(fuich, status = st(fuich))
  ! ... Close files and free memory in phreeqc
  CALL phreeqc_free(solute)  
  ! ... Deallocate the arrays
  IF (mpi_myself == 0) THEN
     ! ...      Deallocate mesh arrays
     DEALLOCATE (caprnt, lprnt1, lprnt2,  &
          aprnt1, aprnt2, aprnt3, aprnt4,  &
          rm, x, y, z,  &
          x_face, y_face, z_face,  &
          ibc, ibc_string,  &
          c_mol,  &
          xd_mask, vmask,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array allocation failed: closef: number 0"
     ENDIF
  ENDIF
  ! ... Allocate mesh arrays for chem slaves
  DEALLOCATE (x_node, y_node, z_node, iprint_chem, iprint_xyz,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: closef 0.1"  
     STOP
  ENDIF
  IF (mpi_myself == 0) THEN
     ! ...      Deallocate dependent variable arrays
     DEALLOCATE (comp_name, icmax, jcmax, kcmax, &
          dc, dzfsdt, dp, dt, &
          sxx, syy, szz, vxx, vyy, vzz, dcmax, dsir, &
          qsfx, qsfy, qsfz, &
          stsaif, stsetb, stsfbc, stslbc, &
          stsrbc, stssbc, stswel, ssresf, ssres, stotsi, stotsp, &
          tsres, tsresf, &
          dctas,  &
          rf, rs,  &
          den, eh, frac, p, t, vis, &
          sir, sir0, sirn, totsi, totsp, tcsaif, tcsetb, &
          tcsfbc, &
          tcslbc, tcsrbc, tcssbc, &
          totwsi, totwsp, &
          tqwsi, tqwsp, u10, zfs, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array allocation failed: closef: number 2"  
     ENDIF
     IF(num_flo_zones > 0) THEN
        ! ...      Deallocate zonal flow rate arrays
        DEALLOCATE (qfzoni, qfzonp, qszoni, qszonp,  &
             zone_ib, lnk_bc2zon, zone_title,  &
             qfzoni_sbc, qfzonp_sbc,  &
             qszoni_sbc, qszonp_sbc,  &
             qfzoni_fbc, qfzonp_fbc,  &
             qszoni_fbc, qszonp_fbc,  &
             qfzoni_lbc, qfzonp_lbc,  &
             qszoni_lbc, qszonp_lbc,  &
             qfzoni_rbc, qfzonp_rbc,  &
             qszoni_rbc, qszonp_rbc,  &
             qfzoni_dbc, qfzonp_dbc,  &
             qszoni_dbc, qszonp_dbc,  &
             qfzoni_wel, qfzonp_wel,  &
             qszoni_wel, qszonp_wel, seg_well,  &
             stat = da_err)
        IF (da_err /= 0) THEN
           PRINT *, "array deallocation failed: closef, number 2.0"
           STOP
        ENDIF
        IF(fresur) THEN
           DEALLOCATE (zone_col, lnk_cfbc2zon, lnk_crbc2zon,  &
                stat = da_err)
           IF (da_err /= 0) THEN
              PRINT *, "array deallocation failed: closef, number 2.05"
              STOP
           ENDIF
        END IF
     END IF
  ENDIF
  ! ... Deallocate dependent variable arrays for chem slaves
  DEALLOCATE (indx_sol1_ic, indx_sol2_ic,  &
       ic_mxfrac,  &
       c, frac_icchem,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: closef 2.1"  
     STOP
  ENDIF
  ! ...      Deallocate the zoned property arrays
  DEALLOCATE (abpm, alphl, alphth, alphtv, poros,  &
       kthx, kthy, kthz,  &
       kxx,kyy,kzz,rcppm, &
       i1z, i2z, j1z, j2z, k1z, k2z, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array allocation failed: closef: number 4"  
  ENDIF
  ! ...      Deallocate the final well arrays
  IF(nwel > 0) THEN
     DEALLOCATE (welidno, xw, yw, wbod, wqmeth, &
          mwel, &
                                ! wcf, &                   ! wcf deallocated in write2
          zwb, zwt, wfrac, nkswel, &
          mxf_wel, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array allocation failed: closef: number 5"  
     ENDIF
  ENDIF
  ! ...      Deallocate more well arrays
  IF (nwel > 0) THEN
     DEALLOCATE (iw, jw, wi, &
          wficum, wfpcum, &
          qwlyr, qflyr, dqwdpl, &
          denwk, pwk, twk, udenw, dpwkt, &
          qwm, qwv, qhw, stfwp, sthwp, &
          stfwi, sthwi, &
          indx1_wel, indx2_wel, &    
          pwsurs, pwkt, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 6"  
     ENDIF
  ENDIF
  IF (nsbc > 0 .AND. nwel > 0) THEN
     DEALLOCATE (wsicum, wspcum, &
          qslyr, cwk, qsw, stswp, &
          cwkt, cwkts, &
          stswi, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 7"  
     ENDIF
  ENDIF
  ! ...      Deallocate river arrays
  IF(nrbc > 0) THEN
     DEALLOCATE (mrbc, arearbc,  &
          arbc, brbc,  &
          krbc, bbrbc, zerbc,  &
          mrbc_bot, mrseg_bot,  &
          phirbc, denrbc, visrbc,  &
          crbc, indx1_rbc, indx2_rbc, mxf_rbc,  &
          qfrbc, ccfrb, ccfvrb, qsrbc, ccsrb,  &
          sfrb, sfvrb, ssrb,  &
          river_seg_index,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 8"  
     ENDIF
  ENDIF
  ! ...      Deallocate drain arrays
  IF(ndbc > 0) THEN
     DEALLOCATE (mdbc, areadbc,  &
          adbc, bdbc,  &
          kdbc, bbdbc, zedbc,  &
          mdbc_bot, mdseg_bot,  &
          qfdbc, ccfdb, ccfvdb, qsdbc, ccsdb,  &
          sfdb, sfvdb, ssdb,  &
          drain_seg_index,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 8.1"  
     ENDIF
  ENDIF
  ! ...      Deallocate conductance, capacitance arrays
  DEALLOCATE (tx, ty, tz, arx, ary, arz,  &
       pv, pmcv, pmhv, pmchv, pvk,  &
       tfx, tfy, tfz, thx, thy, thz, thxy, thxz, thyx, &
       thyz, thzx, thzy, &
       tsx, tsy, tsz, tsxy, tsxz, tsyx, tsyz, &
       tszx, tszy, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: closef: number 9"  
  ENDIF
  ! ...      Deallocate specified value b.c. arrays
  IF(nsbc > 0) THEN
     DEALLOCATE (msbc, indx1_sbc, indx2_sbc,  &
          fracnp, mxf_sbc, qfsbc, qhsbc, qssbc,  &
          sfsb, sfvsb, sssb,  &
          csbc, psbc,  &
          ccfsb, ccfvsb, ccssb,  &
          vafsbc, rhfsbc,  &
          vassbc, rhssbc,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 10"  
     ENDIF
  ENDIF
  ! ...      Deallocate specified flux b.c. arrays
  IF(nfbc > 0) THEN
     DEALLOCATE (mfbc, ifacefbc, areafbc,  &
          qfflx, denfbc,  &
          cfbc, indx1_fbc, indx2_fbc, mxf_fbc,  &
          qffbc, qfbcv, ccffb, ccfvfb, qsfbc, ccsfb, qhfbc,  &
          sffb, sfvfb, ssfb,  &
          flux_seg_index,  &
          qsflx,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 11"  
     ENDIF
  ENDIF
  ! ...      Deallocate leakage b.c. arrays
  IF(nlbc > 0) THEN
     DEALLOCATE (mlbc, ifacelbc, arealbc,  &
          albc, blbc,  &
          klbc, bblbc, zelbc, &
          philbc, denlbc, vislbc,  &
          clbc, indx1_lbc, indx2_lbc, mxf_lbc,  &
          qflbc, ccflb, ccfvlb, qslbc, ccslb,  &
          sflb, sfvlb, sslb,  &
          leak_seg_index,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 12"  
     ENDIF
  ENDIF
  ! ...      Deallocate solver space
  DEALLOCATE (cin, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array allocation failed: closef: number 13"  
  ENDIF
  IF(slmeth == 1) THEN
     DEALLOCATE (ind, mrno, mord, &
          ci, cir, cirh, cirl, &
          ip1, ip1r, ipenv, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 14"  
     ENDIF
     DEALLOCATE(diagra, envlra, envura, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 15"  
     ENDIF
  ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN
     DEALLOCATE (ind, mrno, mord, ci, cir, cirh, cirl, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 16"  
     ENDIF
     DEALLOCATE(ap, bbp, ra, rr, sss, &
          xx, ww, zz, sumfil, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "Array deallocation failed: closef: number 17"  
     ENDIF
  ENDIF
  ! ...      Deallocate space for the assembly of difference equations
  DEALLOCATE(va, rhs, cc34, cc35, diagc, diagr,  & 
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: closef: number 18"  
  ENDIF
  ! ...      Deallocate space for free surface and head print
  DEALLOCATE (mfsbc, hdprnt, wt_elev,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: closef: number 19"  
  ENDIF
END SUBROUTINE closef
