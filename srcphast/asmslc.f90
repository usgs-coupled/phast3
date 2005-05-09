SUBROUTINE ASMSLC  
  !.....Performs the assembly and solution of the concentration from the
  !.....     solute transport equations for each component
  USE machine_constants, ONLY: kdp
!!$  USE f_units
  USE mcc
  use mcch
  USE mcg
  USE mcm
!!$  USE mcp
  USE mcs
  USE mcs2
  USE mcv
  USE mcw
  IMPLICIT NONE
  INTERFACE
     SUBROUTINE gcgris(ap,bp,ra,rr,ss,xx,w,z,sumfil)
       USE machine_constants, ONLY: kdp
       REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT) :: ap
       REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT) :: bp
       REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN OUT) :: ra
       REAL(kind=kdp), DIMENSION(:), INTENT(IN OUT) :: rr
       REAL(kind=kdp), DIMENSION(:), INTENT(IN OUT) :: ss, w, z
       REAL(kind=kdp), DIMENSION(:), INTENT(INOUT) :: sumfil
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: xx
!!$       REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: xx, sumfil
     END SUBROUTINE gcgris
     SUBROUTINE tfrds(diagra,envlra,envura)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: diagra, envlra, envura
     END SUBROUTINE tfrds
  END INTERFACE
  !
  INTEGER :: m, ma  
  CHARACTER(LEN=130) :: logline1
  !.....Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !.....Assemble and solve the transport equation for each component
  IF (ERREXE) RETURN
  logline1 =  '     Beginning solute-transport calculation.'
  WRITE(*,'(a)') trim(logline1)
  CALL logprt_c(logline1)
  dc = 0._kdp
  ieq = 3  
  DO is = 1, ns  
     logline1 =  '          '//comp_name(is)
     WRITE(*,'(a)') trim(logline1)
     CALL logprt_c(logline1)
     itrn = 0  
30   itrn = itrn + 1
     CALL asembl  
     CALL aplbci  
  !.....Solve the matrix equations
  IF(slmeth == 1) THEN  
     !.....Direct solver
     CALL tfrds(diagra, envlra, envura)  
  ELSEIF(slmeth == 3 .OR. slmeth == 5) THEN  
     !.....Generalized conjugate gradient iterative solver on reduced matrix
     CALL gcgris(ap, bbp, ra, rr, sss, xx, ww, zz, sumfil)
  ENDIF
     IF( ERREXE) RETURN  
     !.....Solute equation has just been solved
     DCMAX(is) = 0._kdp
     DO  M = 1, NXYZ  
        MA = MRNO( M)  
        DC(M,IS) = RHS(MA)  
        IF(FRAC(M) .GT.0.) DCMAX(is) = MAX(DCMAX(is), ABS(DC(M,IS)))
     END DO
     !.....If adjustable time step, check for unacceptable time step length
     IF( AUTOTS.AND.JTIME.GT.2) THEN  
        !.....If DC is too large, abort the P,T,C iteration and reduce the time step
        IF( ABS( DCMAX( is) ) .GT.1.5* DCTAS( is) ) THEN  
           TSFAIL = .TRUE.  
           RETURN  
        ENDIF
     ENDIF
     !.....Do a second solute transport for explicit cross-derivative fluxes
     IF(CROSD .AND. ITRN < 2) GOTO 30  
  END DO
END SUBROUTINE ASMSLC
