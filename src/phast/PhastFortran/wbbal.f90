SUBROUTINE wbbal  
  ! ... Calculates a flow and heat balance over the wellbore
  ! ... Wells with a flow reversal in the well bore will not have a
  ! ...      realistic balance calculation.
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcc_m
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mcw
  USE mcw_m
  IMPLICIT NONE
  INTRINSIC int  
  REAL(KIND=kdp) :: uqhw, uqwm, uqwmi
  INTEGER :: a_err, da_err, iis, iwel, iwfss, ks, m, mkt, nks, nsa
  LOGICAL :: erflg, florev
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE ::  uqsw
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... Set string for use with rcs ident command
  CHARACTER(LEN=80) :: ident_string='$id: wbbal.f90,v 1.2 2009/08/10 23:41:00 klkipp exp $'
  !     ------------------------------------------------------------------
  !...
  erflg = .FALSE.  
  nsa = MAX(ns,1)
     ALLOCATE (uqsw(nsa),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: wbbal"  
        STOP
     ENDIF
  DO iwel = 1,nwel  
     IF( wqmeth(iwel) == 0) CYCLE
     !$$         wrcalc=.false.
     uqwm = - qwm(iwel)  
     iwfss = INT(SIGN(1._kdp,uqwm))  
     IF(ABS(uqwm) < 1.e-8_kdp) iwfss = 0  
     nks = nkswel(iwel)  
     !$$         mmkt=mwel(iwel,nks)
     DO 10 ks=1,nks  
        m = mwel(iwel, ks)  
        IF(.NOT.cylind) THEN  
           ! ... Update layer flow rates for line source/sink wells
           qwlyr(iwel,ks) = qwlyr(iwel,ks) + dqwdpl(iwel,ks)*(dp(m) - dpwkt(iwel))
           pwk(iwel,ks) = pwk(iwel,ks) + dpwkt(iwel)  
        ELSE  
           ! ... Update well bore pressure profile for cylindrical system
           pwk(iwel,ks) = p(m)  
        ENDIF
10   END DO
     IF(cylind) THEN  
        mkt = mwel(1,nks)  
        ! ... pwkt is at time n+1
        ! ...    should it be pwk(mkt)??
        pwkt(iwel) = p(mkt)  
     ELSE  
        pwkt(iwel) = pwk(iwel,nks)  
     ENDIF
     ! ... Sum mass, heat, and solute flow rates for the well
     ! ...      calculate new enthalpy, temperature, mass fraction,
     ! ...      density profiles
     florev = .FALSE.
     IF(iwfss >= 0) THEN  
        ! ... Production well
        uqwm = 0._kdp  
        uqhw = 0._kdp  
        DO 12 iis=1,ns  
           uqsw(iis) = 0._kdp  
12      END DO
        DO 20 ks=1,nks  
           m = mwel(iwel,ks)  
           IF(qwlyr(iwel,ks) < 0._kdp) THEN             ! ... Production layer
              qflyr(iwel,ks) = den0*qwlyr(iwel,ks)  
              uqwm = uqwm - qflyr(iwel,ks)  
              DO 13 iis=1,ns  
                 qslyr(iwel,ks,iis) = qflyr(iwel,ks)*c(m,iis)  
                 uqsw(iis) = uqsw(iis) - qslyr(iwel,ks,iis)  
                 cwk(iwel,ks,iis) = uqsw(iis)/uqwm  
13            END DO
           ELSE           ! ... injection layer from producing well (not allowed at layer kb, ks=1
              qflyr(iwel,ks) = denwk(iwel,ks)*qwlyr(iwel,ks)  
              uqwm = uqwm - qflyr(iwel,ks)  
              if (Ks .eq. 1 .and. ns .ge. 1) then
                STOP "Error in well calculation. Be sure all wells have at least a small pumping/injection rate."
              endif
              DO 14 iis=1,ns  
                 cwk(iwel,ks,iis) = cwk(iwel,ks-1,iis)  
                 qslyr(iwel,ks,iis) = qflyr(iwel,ks)*cwk(iwel,ks,iis)
                 uqsw(iis) = uqsw(iis) - qslyr(iwel,ks,iis)  
14            END DO
           ENDIF
           denwk(iwel,ks) = den0  
           IF(uqwm < 0._kdp) THEN  
              WRITE(logline1,9012) 'Production Well No. ', iwel, &
                   ' has down bore flow from level ', ks + 1, ' to ', ks, &
                   '; time plane n =', itime-1
9012          FORMAT(a,i4,a,i2,a,i2,a,i4)
              WRITE(logline2,9022) ' Flow Rate =', uqwm
9022          FORMAT(a,1pg10.2)
                CALL RM_WarningMessage(logline1)
                CALL RM_WarningMessage(logline2)
              WRITE(fuwel,9002) 'Production Well No. ', iwel, &
                   ' has down bore flow from level ', ks + 1, ' to ', ks, &
                   '; time plane n =', itime-1, ' Flow Rate =', uqwm
9002          FORMAT(tr10,a,i4,a,i2,a,i2,a,i4/tr15,a,1pg10.2)  
              florev = .TRUE.  
           ENDIF
20      END DO
        ELSEIF(iwfss < 0) THEN             ! ... Injection well
        uqwmi = uqwm  
        DO  iis=1,ns  
           uqsw(iis) = uqwm*cwkt(iwel,iis)  
        END DO
        DO 30 ks=nks,1,-1  
           m = mwel(iwel,ks)  
           IF(qwlyr(iwel,ks) > 0._kdp) THEN     ! ... Injection layer
              IF(ks == nks) THEN  
                 DO  iis=1,ns  
                    cwk(iwel,ks,iis) = cwkt(iwel,iis)  
                 END DO
              ELSE  
                 DO  iis=1,ns  
                    cwk(iwel,ks,iis) = cwk(iwel,ks+1,iis)  
                 END DO
              ENDIF
              denwk(iwel,ks) = den0
              qflyr(iwel,ks) = denwk(iwel,ks)*qwlyr(iwel,ks)
              uqwm = uqwm + qflyr( iwel, ks)  
              DO  iis=1,ns  
                 qslyr(iwel,ks,iis) = qflyr(iwel,ks)*cwk(iwel,ks,iis)
                 uqsw(iis) = uqsw(iis) + qslyr(iwel,ks,iis)  
              END DO
           ELSE                ! ... Production layer into injection well
              qflyr(iwel,ks) = den0*qwlyr(iwel,ks)
              uqwm = uqwm + qflyr(iwel,ks)  
              DO  iis=1,ns
                 qslyr(iwel,ks,iis) = qflyr(iwel,ks)*c(m,iis)  
                 uqsw(iis) = uqsw(iis) + qslyr(iwel,ks,iis)  
                 cwk(iwel,ks,iis) = uqsw(iis)/uqwm  
              END DO
              denwk(iwel,ks) = den0  
           ENDIF
           IF(ks > 1 .AND. uqwm/ABS(uqwmi) > 0.01_kdp) THEN  
              florev = .TRUE.
              WRITE(logline1,9012) 'Injection Well No. ', iwel, &
                   ' has up bore flow from level ', ks + 1, ' to ', ks, &
                   '; time plane n =', itime-1
              WRITE(logline2,9022) ' Flow Rate =', uqwm
                CALL RM_WarningMessage(logline1)
                CALL RM_WarningMessage(logline2)
              WRITE(fuwel, 9002) 'Injection Well No. ', iwel,  &
                   ' has up bore flow from level ', ks - 1, ' to ', ks,  &
                   '; time plane n =', itime,' Flow Rate =',uqwm
           ENDIF
30      END DO
        IF(ABS(uqwm/uqwmi) > 0.01_kdp) THEN
           ! ... Well has excess residual flow rate
           florev = .TRUE.
           WRITE(logline1,9012) 'Injection Well No. ', iwel,  &
                ' has >1% residual flow through well bottom',  &
                   '; time plane n =', itime-1
              WRITE(logline2,9022) ' Flow Rate =',uqwm
                CALL RM_ErrorMessage(logline1)
                CALL RM_ErrorMessage(logline2)
           WRITE(fuwel, 9002) 'Injection Well No. ', iwel, ' has >1% residual'//  &
                'flow through well bottom', '; time plane n =', itime-1,  &
                ' Flow Rate =', uqwm
        ENDIF
     ENDIF
     IF(florev) THEN
        logline1 =  'Well solute concentrations may be poor approximations (wbbal)'
        CALL RM_ErrorMessage(logline1)
        WRITE(fuwel,9003) 'Well solute concentrations may be poor approximations (wbbal)'
9003    FORMAT(tr10,a)  
        ierr(142) = .TRUE.
        errexe = .TRUE.
     ENDIF
     ! ... Cumulative amounts for each well, Save current fluid, heat, and
     ! ...       solute flow rates
     qwm(iwel) = 0._kdp
     DO  iis=1,ns  
        qsw(iwel,iis) = 0._kdp  
     END DO
     DO  ks=1,nks  
        qwm(iwel) = qwm(iwel) + qflyr(iwel,ks)  
        DO  iis=1,ns  
           qsw(iwel,iis) = qsw(iwel,iis) + qslyr(iwel,ks,iis)  
        END DO
     END DO
     DO  iis=1,ns  
        cwkt(iwel,iis) = cwk(iwel,nks,iis)  
     END DO
     ! ... Well riser calculations
     !...  ** not available in phast
   END DO
  DEALLOCATE (uqsw,  &
       STAT = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "array deallocation failed, wbbal"  
     STOP
  ENDIF
END SUBROUTINE wbbal
