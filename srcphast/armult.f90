SUBROUTINE armult(x,y)  
  !.....Multiplies A*y for red nodes
  USE machine_constants, ONLY: kdp
  USE mcm
  USE mcs
  IMPLICIT NONE
  REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: x
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: y  
  !
  REAL(KIND=kdp) ::  s  
  INTEGER :: i, ii, j, jcol  
  !.....Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  DO i=1,nbn  
     ii = i + nrn  
     s = 0._kdp
     DO  j=1,6  
        jcol = ci(j,ii)  
        IF(jcol > 0) s = s + va(j,ii)*y(jcol)  
     END DO
     x(i) = s  
  END DO
END SUBROUTINE armult
