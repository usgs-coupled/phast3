SUBROUTINE gcgris(ap,bp,ra,rr,ss,xx,w,z,sumfil)
  ! ... Iterative solver for reduced linear equation system using
  ! ...      generalized conjugate gradient minimal residual method
  ! ...      with restarts
  ! ... A restarted ORTHOMIN method
  ! ... Reduced system by red-black or d4 zig-zag reordering
  USE machine_constants, ONLY: kdp
  USE f_units, ONLY: fuclog
  USE mcc
  USE mcg
  USE mcm
!!$  USE mcp, ONLY: cnvtmi
  USE mcs
!!$  USE mcv, ONLY: itime, time
  USE print_control_mod
  IMPLICIT NONE
  REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT), TARGET :: ap
  REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT), TARGET :: bp
  REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
  REAL(kind=kdp), DIMENSION(:), INTENT(IN OUT) :: rr
  REAL(kind=kdp), DIMENSION(:), INTENT(IN OUT) :: ss, w, z
  REAL(kind=kdp), DIMENSION(:), INTENT(OUT), TARGET :: xx
  REAL(kind=kdp), DIMENSION(:), INTENT(INOUT) :: sumfil
  INTERFACE
     SUBROUTINE abmult(x,y)  
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:), INTENT(out) :: x
       REAL(kind=kdp), DIMENSION(:), INTENT(in) :: y
     END SUBROUTINE abmult
     SUBROUTINE armult(x,y)  
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: x
       REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: y  
     END SUBROUTINE armult
     SUBROUTINE dbmult(x,y)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: x
       REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: y
     END SUBROUTINE dbmult
     SUBROUTINE formr(ra)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
     END SUBROUTINE formr
     SUBROUTINE rfact(ra)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
     END SUBROUTINE rfact
     SUBROUTINE rfactm(ra,sumfil)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
       REAL(kind=kdp), DIMENSION(:), INTENT(INOUT) :: sumfil
     END SUBROUTINE rfactm
     SUBROUTINE lsolv(ra,rr,w)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:,:), INTENT(IN) :: ra
       REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: rr
       REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: w
     END SUBROUTINE lsolv
     SUBROUTINE usolv(yy,ra,w)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: yy
       REAL(kind=kdp), DIMENSION(:,:), INTENT(IN) :: ra
       REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: w
     END SUBROUTINE usolv
     SUBROUTINE vpsv(x,y,z,s,n)
       USE machine_constants, ONLY: kdp
       REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: x
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: y
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: z
       REAL(KIND=kdp), INTENT(IN) :: s
       INTEGER, INTENT(IN) :: n
     END SUBROUTINE vpsv
  END INTERFACE
  !
  REAL(kind=kdp) :: alpha, r00, r1, ranorm, rat, xnorm
  REAL(kind=kdp), DIMENSION(0:nsdr-1) ::  delta
  REAL(kind=kdp), DIMENSION(0:nsdr-2,0:nsdr-2) ::   h
  INTEGER :: i, icount, j, l, nrnp1
  REAL(kind=kdp), DIMENSION(:), POINTER :: xx_b
  REAL(KIND=kdp), DIMENSION(:), POINTER :: apv, bpv, bpvlp, bpvj
  CHARACTER(LEN=130) :: logline1
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  r00 = SQRT(DOT_PRODUCT(rhs,rhs))
     xx = 0.0_kdp
  ! ... Debug output
!***  activate debug output to phast fuclog file, if needed
!$$  WRITE(fuclog,*) 'Current R00, L2(RHS): ', r00
  ! ... If R00 is tiny, then xx is a solution, skip out
  IF (r00 <= 2._kdp*EPSILON(1._kdp)) RETURN
  DO  i=1,nbn
     sumfil(i) = 0.0_kdp
     DO  j=1,lrcgd1
        ra(j,i) = 0.0_kdp
     END DO
  END DO
  ! ... Multiply the 2 off-diagonal blocks, scale
  ! ... Subract from the black diagonal and factor the result to
  ! ...      obtain the reduced matrix, RA
  CALL formr(ra)
  ! ... Calculate the E-norm of RA
  DO  i=1,nbn
     DO  j=1,lrcgd1
        sumfil(1) = sumfil(1) + ra(j,i)*ra(j,i)
     END DO
  END DO
  ranorm = SQRT(sumfil(1))
  ! ... Debug output
!!$  WRITE(fuclog,*) 'Current ra-norm: ', ranorm
  SUMFIL(1) = 0.0_kdp
  IF (milu) THEN
     CALL rfactm(ra,sumfil)
  ELSE
     CALL rfact(ra)
  END IF
  ! ... Scale the red RHS by inv(D(R))
  DO  i=1,nrn
     rhs(i) = rhs(i)/va(7,i)
  END DO
  ! ... Form the RHS of the reduced system
  nrnp1 = nrn+1
  rhs_r => rhs(1:nrn)
  rhs_b => rhs(nrnp1:nxyz)
  xx_b => xx(nrnp1:nxyz)
  CALL armult(w,rhs_r)
  CALL vpsv(rhs_b,rhs_b,w,-1.0_kdp,nbn)
  ! ... The rhs is now stored in the bottom half of RHS
  ! ... Start of generalized conjugate gradient solver
  ! ... Form the initial residual
  CALL abmult(rr,xx_b)
  CALL armult(w,rr)
  CALL dbmult(rr,xx_b)
  CALL vpsv(w,rr,w,-1.0_kdp,nbn)
  ! ... W now has R*X_black
  CALL vpsv(rr,rhs_b,w,-1.0_kdp,nbn)
  ! ... Compute the standard Omin iterates XX(1) thru XX(S)
  ! ...    Form the initial direction
  icount = 0
50 CONTINUE
  CALL lsolv(ra,rr,w)
  bpv => bp(:,0)
  CALL usolv(bpv,ra,w)
  DO  l=0,nsdr-1
     icount = icount+1
     apv => ap(:,l)
     bpv => bp(:,l)
     CALL abmult(apv,bpv)
     CALL armult(w,apv)
     CALL dbmult(apv,bpv)
     CALL vpsv(apv,apv,w,-1.0_kdp,nbn)
     delta(l) = DOT_PRODUCT(apv(:nbn),apv(:nbn))
     alpha = DOT_PRODUCT(rr(:nbn),apv(:nbn))/delta(l)
     ! ...   Update the solution
     CALL vpsv(xx_b,xx_b,bpv,alpha,nbn)
     ! ...   Update the residual
     CALL vpsv(rr,rr,apv,-alpha,nbn)
     r1 = SQRT(DOT_PRODUCT(rr(:nbn),rr(:nbn)))
     ! ...   Use criterion #1 of Templates p.54
     xnorm = SQRT(DOT_PRODUCT(xx_b,xx_b))
! ... Debug output
!$$     WRITE(fuclog,*) 'Current x-norm: ', xnorm
     rat = r1/(ranorm*xnorm+r00)
     !..    rat=r1/r00            ! ...   Alternate: criterion #2
! ... Debug output
!$$     WRITE(fuclog,*) 'Current relative residual: ', rat
!$$     WRITE(fuclog,*) 'Current residual: ', r1
     IF(icount > maxit2) GO TO 90
     ! ... Test for convergence
     IF (r1 <= epsslv*(ranorm*xnorm+r00)) GO TO 120
     IF (l < nsdr-1) THEN
        CALL lsolv(ra,rr,w)
        CALL usolv(ss,ra,w)
        CALL abmult(w,ss)
        CALL armult(z,w)
        CALL dbmult(w,ss)
        CALL vpsv(w,w,z,-1.0_kdp,nbn)
        DO  i=0,l
           apv => ap(:,i)
           h(i,l) = DOT_PRODUCT(w(:nbn),apv(:nbn))/delta(i)
        END DO
        bpvlp => bp(:,l+1)
        CALL vpsv(bpvlp,ss,bpv,-h(l,l),nbn)
        DO  j=0,l-1
           bpvj => bp(:,j)
           CALL vpsv(bpvlp,bpvlp,bpvj,-h(j,l),nbn)
        END DO
     END IF
  END DO
  GO TO 50
90 CONTINUE
  WRITE(logline1,9001) 'Restarted Conjugate-Gradient Solver Reached Maximum Iterations: ',maxit2
  9001 FORMAT(A,i5)
!!$  WRITE(fulp,'(/tr10,A)') logline1
  CALL errprt_c(logline1)
  ierr(139) = .TRUE.
  errexe = .TRUE.
  ! ... Convergence achieved
120 CONTINUE
  IF(prslm) THEN
!!$     WRITE(*,9002) 'No. of solver iterations, Relative residual: ',icount,rat
     WRITE(logline1,9002) '          No. of solver iterations, Relative residual: ',icount,rat
9002 FORMAT(a,i4,tr4,1pe15.7)
     CALL logprt_c(logline1)
  ENDIF
  IF(icount < 2) THEN
     logline1 = '  Number of iterations is too few (<2); check convergence tolerance'
     CALL warnprt_c(logline1)
  ENDIF
  ! ... Backsolve for the red solution from the black half
  CALL abmult(w,xx_b)
  CALL vpsv(rhs_r,rhs_r,w,-1.0_kdp,nrn)
  ! ... Set RHS_black equal to X_black
  rhs_b = xx_b
  NULLIFY(apv, bpv, bpvlp, bpvj)
END SUBROUTINE gcgris
