SUBROUTINE XP_asmslc(xp)
  ! ... Performs the assembly and solution of the concentration for the
  ! ...     solute transport equations for one selected component
  USE mcc
  USE mcg
  USE mcm
  USE mcs
  USE mcs2
  USE mcw
  USE XP_module
  USE scale_jds_mod
  USE solver_direct_mod
  USE solver_iter_mod
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTEGER :: m, ma, norm, iierr  
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: XP_asmslc.F90,v 1.3 2011/01/29 00:18:54 klkipp Exp klkipp $'
  integer j
  !     ------------------------------------------------------------------
  ! ... Assemble and solve the transport equation for one selected component
  IF (errexe) RETURN
! ***** some progress output
!  logline1 =  '     Beginning solute-transport calculation.'
!  CALL logprt_c(logline1)
!  CALL screenprt_c(logline1)
  xp%dc = 0._kdp
  ieq = 3
!  logline1 =  '          '//xp%comp_name
!  CALL logprt_c(logline1)
!  CALL screenprt_c(logline1)
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
    CALL errprt_c(logline1)
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
