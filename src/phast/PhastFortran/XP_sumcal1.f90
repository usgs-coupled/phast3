SUBROUTINE XP_sumcal1(xp)
  ! ... Performs summary calculations at end of time step for the transport
  ! ...       equations
  ! ... This is the first block of sumcal. The second block follows the
  ! ...      chemical reaction calculations
  USE mcb, ONLY: ibc
  USE mcg, ONLY: nxyz
  USE mcp, ONLY:
  USE mcv, ONLY:
  USE XP_module, ONLY: Transporter
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  !
  INTEGER :: m
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: XP_sumcal1.f90,v 1.3 2011/01/29 00:18:54 klkipp Exp klkipp $'
  !     ------------------------------------------------------------------
  !...
  !!$ time = time + deltim  ! ... time is updated by manager
  ! ... Update the dependent variables
  DO  m=1,nxyz
     IF(ibc(m) == -1) CYCLE
     xp%c_w(m) = xp%c_w(m)+xp%dc(m)
     ! ... Update density, viscosity, and enthalpy
     !... *** not needed for PHAST
  END DO

END SUBROUTINE XP_sumcal1
