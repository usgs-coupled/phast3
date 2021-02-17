! ... This module is used by both manager and worker programs
! ... $Id: mach_mod.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp $

MODULE machine_constants
  ! ... machine dependent parameters
  IMPLICIT NONE
  SAVE
  INTEGER, PARAMETER :: kdp = SELECTED_REAL_KIND(14,60)
  ! ... BGREAL: A large real number representable in single precision
  ! ... BGINT:  A large integer number representable in 4 bytes
  INTEGER, PARAMETER :: BGINT=9999
  REAL(KIND=kdp), PARAMETER :: bgreal=HUGE(1._kdp), one_plus_eps=1._kdp+5._kdp*EPSILON(1._kdp)
  REAL(KIND=kdp), PARAMETER :: macheps5=5._kdp*EPSILON(1._kdp)
END MODULE machine_constants
