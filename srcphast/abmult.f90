SUBROUTINE abmult(x,y)  
  !.....Multiplies A_r*y for black nodes
  USE machine_constants, ONLY: kdp
  USE mcm
  USE mcs
  IMPLICIT NONE
  REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: x
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: y
  !
  REAL(KIND=kdp) :: s  
  INTEGER :: irn, jc, jcol  
  !.....Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: abmult.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  DO  irn = 1, nrn  
     s = 0.0_kdp
     DO  jc=1,6  
        jcol = ci(jc,irn)  
        IF(jcol > 0) s = s + va(jc,irn)*y(jcol-nrn)  
     END DO
     x(irn) = s  
  END DO
END SUBROUTINE abmult
