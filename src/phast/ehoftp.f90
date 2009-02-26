FUNCTION ehoftp( txx, pxx, erflg)  
  !.....Calculates the enthalpy as a function of temperature and pressure
  !.....Temperature should lie within 0 to 350 Deg.C
  !.....Pressure should lie within 0. to 2.2*10**7 Pa(absolute)
  USE machine_constants, ONLY: kdp
  USE mcp
  REAL(KIND=kdp) :: ehoftp  
!!$  EXTERNAL INTERP  
!!$  REAL(KIND=kdp) :: interp  
  REAL(KIND=kdp) :: pxx, txx  
  LOGICAL :: erflg  
  REAL(KIND=kdp) :: eh1, eh2, pabs
  REAL(KIND=kdp), DIMENSION(1) :: xx
  INTEGER :: nxx=1  
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  erflg = .false.  
!!$  pabs = pxx + paatm  
  !!$      eh1=interp(1,txx,xx(1),nehst,nxx,tehst,xx,ehst,erflg)
  !!$      eh2=interp(2,txx,pabs,ntehdt,npehdt,tehdt,paehdt,ehdt,erflg)
  !!$      ehoftp=eh1+eh2
  ehoftp = 0._kdp
END FUNCTION ehoftp
