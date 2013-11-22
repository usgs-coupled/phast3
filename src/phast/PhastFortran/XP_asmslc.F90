SUBROUTINE XP_asmslc_thread(xp)
  ! ... Performs the assembly and solution of the concentration for the
  ! ...     solute transport equations for one selected component
  USE machine_constants, ONLY: kdp
  USE mcc, only: slmeth, errexe, ierr, crosd, cylind
  USE mcg, only: nxyz
  USE mcm, only:
  USE mcs, only: col_scale, row_scale, ci, ident_diagc, mrno
  USE mcs2, only:
  USE mcw, only: wqmeth
  USE XP_module, ONLY: Transporter
  USE scale_jds_mod, only: rowscale, colscale
  USE solver_direct_mod, only: tfrds_thread
  USE solver_iter_mod, only: gcgris_thread
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTEGER :: m, ma, norm, iierr  
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: XP_asmslc.F90,v 1.1 2013/09/19 20:41:58 klkipp Exp $'
  integer j, itrn
  !     ------------------------------------------------------------------
  ! ... Assemble and solve the transport equation for one selected component
  IF (errexe) RETURN
! ***** some progress output
!  logline1 =  '     Beginning solute-transport calculation.'
!  CALL RM_LogMessage(logline1)
!  CALL RM_ScreenMessage(logline1)
  xp%dc = 0._kdp
  xp%ieq = 3
!  logline1 =  '          '//xp%comp_name
!  CALL RM_LogMessage(logline1)
!  CALL RM_ScreenMessage(logline1)
  itrn = 0
30   itrn = itrn + 1
  CALL XP_asembl_thread(xp)
  CALL XP_aplbci_thread(xp)
  ! ... Scale the matrix equations
  ! ...     row scaling only is default
  norm = 0          ! ... use L-infinity norm
  IF(row_scale) CALL rowscale(nxyz,norm,xp%va,xp%diagr,iierr)
  IF(col_scale) CALL colscale(nxyz,norm,xp%va,ci,xp%diagc,iierr)
! ***** some error output
  IF(iierr /= 0) THEN
     ierr(81) = .TRUE.
     WRITE(logline1,*) 'Error in scaling; component:',xp%iis_no,'  equation:', iierr
    CALL RM_ErrorMessage(logline1)
     RETURN
  END IF
  IF(col_scale) THEN
     IF(MINVAL(xp%diagc) /= 1._kdp .AND. MAXVAL(xp%diagc) /= 1._kdp)  &
          ident_diagc = .FALSE.
  END IF
  IF(row_scale) THEN
     DO ma=1,nxyz
        xp%rhs(ma) = xp%diagr(ma)*xp%rhs(ma)
     END DO
  END IF
  ! ... Solve the matrix equations
  IF(slmeth == 1) THEN  
     ! ... Direct solver
     CALL tfrds_thread(xp%diagra, xp%envlra, xp%envura, xp%rhs, xp)
  ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN
     ! ... Iterative solver
     CALL gcgris_thread(xp%ap, xp%bbp, xp%ra, xp%rr, xp%sss, xp%xx, xp%ww, xp%zz, xp%sumfil, xp%rhs, xp)
  ENDIF
  IF(errexe) RETURN
  ! ... Solute equation for one component has just been solved
!!$  dcmax(iis_no) = 0._kdp
  ! ... Descale the solution vector
  IF(col_scale) THEN
     DO ma=1,nxyz
        xp%rhs(ma) = xp%diagc(ma)*xp%rhs(ma)
     END DO
  END IF
  ! ... Extract the solution from the solution vector
  DO  m=1,nxyz
     ma = mrno(m)
     xp%dc(m) = xp%rhs(ma)
!!$     IF(frac(m) > 0.) dcmax = MAX(dcmax(xp%iis_no),ABS(xp%dc(m)))
  END DO
  ! ... If adjustable time step, check for unacceptable time step length
  ! *** only fixed time steps for solute in Phast
  ! ... Do a second solute transport for explicit cross-derivative fluxes
  IF(crosd .AND. itrn < 2) GOTO 30  
  ! ... Calculate layer solute flow rates for cylindrical single well
  IF(cylind) THEN
     IF(wqmeth(1) /= 11 .AND. wqmeth(1) /= 13) CALL XP_wbcflo(xp)
  ENDIF

END SUBROUTINE XP_asmslc_thread
SUBROUTINE XP_asmslc(xp)
  ! ... Performs the assembly and solution of the concentration for the
  ! ...     solute transport equations for one selected component
  USE mcc
  USE mcg
  USE mcm
  USE mcs
  USE mcs2
  USE mcw
  USE XP_module, only: Transporter
  USE scale_jds_mod
  USE solver_direct_mod
  USE solver_iter_mod
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTEGER :: m, ma, norm, iierr  
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: XP_asmslc.F90,v 1.1 2013/09/19 20:41:58 klkipp Exp $'
  integer j
  !     ------------------------------------------------------------------
  ! ... Assemble and solve the transport equation for one selected component
  IF (errexe) RETURN
! ***** some progress output
!  logline1 =  '     Beginning solute-transport calculation.'
!  CALL RM_LogMessage(logline1)
!  CALL RM_ScreenMessage(logline1)
  xp%dc = 0._kdp
  ieq = 3
!  logline1 =  '          '//xp%comp_name
!  CALL RM_LogMessage(logline1)
!  CALL RM_ScreenMessage(logline1)
  itrn = 0
30   itrn = itrn + 1
  CALL XP_asembl(xp)
  CALL XP_aplbci(xp)
  ! ... Scale the matrix equations
  ! ...     row scaling only is default
  norm = 0          ! ... use L-infinity norm
  IF(row_scale) CALL rowscale(nxyz,norm,va,diagr,iierr)
  IF(col_scale) CALL colscale(nxyz,norm,va,ci,diagc,iierr)
! ***** some error output
  IF(iierr /= 0) THEN
     ierr(81) = .TRUE.
     WRITE(logline1,*) 'Error in scaling; component:',xp%iis_no,'  equation:', iierr
    CALL RM_ErrorMessage(logline1)
     RETURN
  END IF
  IF(col_scale) THEN
     IF(MINVAL(diagc) /= 1._kdp .AND. MAXVAL(diagc) /= 1._kdp)  &
          ident_diagc = .FALSE.
  END IF
  IF(row_scale) THEN
     DO ma=1,nxyz
        rhs(ma) = diagr(ma)*rhs(ma)
     END DO
  END IF
  ! ... Solve the matrix equations
  IF(slmeth == 1) THEN  
     ! ... Direct solver
     CALL tfrds(diagra, envlra, envura)
  ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN
     ! ... Iterative solver
     CALL gcgris(ap, bbp, ra, rr, sss, xx, ww, zz, sumfil)
  ENDIF
  IF(errexe) RETURN
  ! ... Solute equation for one component has just been solved
!!$  dcmax(iis_no) = 0._kdp
  ! ... Descale the solution vector
  IF(col_scale) THEN
     DO ma=1,nxyz
        rhs(ma) = diagc(ma)*rhs(ma)
     END DO
  END IF
  ! ... Extract the solution from the solution vector
  DO  m=1,nxyz
     ma = mrno(m)
     xp%dc(m) = rhs(ma)
!!$     IF(frac(m) > 0.) dcmax = MAX(dcmax(xp%iis_no),ABS(xp%dc(m)))
  END DO
  ! ... If adjustable time step, check for unacceptable time step length
  ! *** only fixed time steps for solute in Phast
  ! ... Do a second solute transport for explicit cross-derivative fluxes
  IF(crosd .AND. itrn < 2) GOTO 30  
  ! ... Calculate layer solute flow rates for cylindrical single well
  IF(cylind) THEN
     IF(wqmeth(1) /= 11 .AND. wqmeth(1) /= 13) CALL XP_wbcflo(xp)
  ENDIF

END SUBROUTINE XP_asmslc

