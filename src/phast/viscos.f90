FUNCTION viscos(p,t,c)  
  ! ... Calculates viscosity as a function of temperature and
  ! ...      concentration
  ! ... Viscosity in Pa-s = kg/m-sec; temperature input in Deg-C.;
  USE machine_constants, ONLY: kdp
  USE mcp
  IMPLICIT NONE
  REAL(KIND=kdp) :: viscos  
  REAL(KIND=kdp) :: c, p, t  
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF(visfac < 0._kdp) THEN  
     viscos = -visfac  
  ENDIF
END FUNCTION viscos
