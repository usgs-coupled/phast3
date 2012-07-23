MODULE solver_iter_mod

  USE machine_constants, ONLY: kdp
  USE mcm
  USE mcs
  IMPLICIT NONE
  PRIVATE; PUBLIC :: gcgris
!$$  PRIVATE :: abmult, armult, dbmult, formr, rfact, rfactm, lsolv, usolv,  &
!$$       vpsv
!$$  PRIVATE :: ident_string

CONTAINS

  SUBROUTINE gcgris(ap,bp,ra,rr,ss,xx,w,z,sumfil)
    ! ... Iterative solver for reduced linear equation system using
    ! ...      generalized conjugate gradient minimal residual method
    ! ...      with restarts
    ! ... A restarted ORTHOMIN method
    ! ... Reduced system by red-black or d4 zig-zag reordering
    USE f_units, ONLY: fuclog
    USE mcc
    USE mcc_m
    USE mcg
!!$    USE mcm
!!$  USE mcp, ONLY: cnvtmi
!!$    USE mcs
!!$  USE mcv, ONLY: itime, time
    USE print_control_mod
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT), TARGET :: ap
    REAL(KIND=kdp), DIMENSION(:,0:), INTENT(IN OUT), TARGET :: bp
    REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN OUT) :: rr
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN OUT) :: ss, w, z
    REAL(KIND=kdp), DIMENSION(:), INTENT(OUT), TARGET :: xx
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: sumfil
    !
    REAL(KIND=kdp) :: alpha, r00, r1, ranorm, rat, xnorm
    REAL(KIND=kdp), DIMENSION(0:nsdr-1) ::  delta
    REAL(KIND=kdp), DIMENSION(0:nsdr-2,0:nsdr-2) ::   h
    INTEGER :: i, icount, j, l, nrnp1
    REAL(KIND=kdp), DIMENSION(:), POINTER :: xx_b
    REAL(KIND=kdp), DIMENSION(:), POINTER :: apv, bpv, bpvlp, bpvj
    CHARACTER(LEN=130) :: logline1
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
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
50  CONTINUE
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
90  CONTINUE
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
9002   FORMAT(a,i4,tr4,1pe15.7)
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
!  This construct uses a lot of stack for some reason
!  Causes stack overflow for large problem  
!  rhs_b = xx_b
! Hopefully, this construct is equivalent,
! Avoids stack overflow
!  do i = 1, nxyz - nrnp1 + 1
!    rhs_b(i) = xx_b(i)
!    enddo
  do i = nrnp1, nxyz
    rhs(i) = xx(i)
    enddo
    NULLIFY(apv, bpv, bpvlp, bpvj)
  END SUBROUTINE gcgris

  SUBROUTINE abmult(x,y)  
    ! ... Multiplies A_r*y for black nodes
!!$    USE machine_constants, ONLY: kdp
!!$    USE mcm
!!$    USE mcs
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: x
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: y
    !
    REAL(KIND=kdp) :: s  
    INTEGER :: irn, jc, jcol  
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    DO  irn=1,nrn  
       s = 0.0_kdp
       DO  jc=1,6  
          jcol = ci(jc,irn)  
          IF(jcol > 0) s = s + va(jc,irn)*y(jcol-nrn)  
       END DO
       x(irn) = s  
    END DO
  END SUBROUTINE abmult

  SUBROUTINE armult(x,y)  
    ! ... Multiplies A*y for red nodes
!!$    USE machine_constants, ONLY: kdp
!!$    USE mcm
!!$    USE mcs
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: x
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: y  
    !
    REAL(KIND=kdp) ::  s  
    INTEGER :: i, ii, j, jcol  
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
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

  SUBROUTINE dbmult(x,y)
    ! ... Multiplies diag_A*Y for the black nodes
!!$    USE machine_constants, ONLY: kdp
!!$    USE mcm
!!$    USE mcs
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: x
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: y
    !
    INTEGER :: i, j
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    DO  i=1,nbn
       j = i+nrn
       x(i) = y(i)*va(7,j)
    END DO

  END SUBROUTINE dbmult

  SUBROUTINE formr(ra)
    ! ... Form the product of the off-diagonal blocks,
    ! ...      scale and subtract from the black diagonal to get
    ! ...      the reduced matrix, RA.
!!$    USE machine_constants, ONLY: kdp
!!$    USE mcm
!!$    USE mcs
    IMPLICIT NONE
    REAL(kind=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
    !
    REAL(kind=kdp) :: dd
    INTEGER :: i, irow, j, k, nrow
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    DO  k=1,nbn
       ra(10,k) = va(7,k+nrn)
    END DO
    DO  k=1,nrn
       dd = 1.0D0/va(7,k)
       DO  j=1,6
          va(j,k) = va(j,k)*dd
       END DO
    END DO
    DO  k=1,nrn
       DO  i=1,6
          irow = ci(i,k)
          IF (irow > 0) THEN
             dd = va(7-i,irow)
             nrow = irow-nrn
             DO  j=1,6
                IF (ci(j,k) > 0) ra(mar(i,j),nrow) = ra(mar(i,j),nrow)-dd*va(j,k)
             END DO
          END IF
       END DO
    END DO
  END SUBROUTINE formr

  SUBROUTINE rfact(ra)
    ! ... Factors the reduced matrix, RA, to incomplete LU factors
!!$    USE machine_constants, ONLY: kdp
!!$    USE mcs
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
    !
    REAL(KIND=kdp) :: dd
    INTEGER :: i, ii, irow, j, jj, k, l
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    DO  k=1,nbn-1
       DO  ii=1,cirh(1,k)
          i = cirh(ii+1,k)
          irow = cir(i,k)
          dd = ra(20-i,irow)/ra(10,k)
          ra(20-i,irow) = dd
          DO  jj=1,cirh(1,k)
             j = cirh(jj+1,k)
             l=mar1(i,j)
             IF(l > 0) ra(l,irow) = ra(l,irow)-dd*ra(j,k)
          END DO
       END DO
    END DO
  END SUBROUTINE rfact

  SUBROUTINE rfactm(ra,sumfil)
    ! ... Factors the reduced matrix, RA, to modified incomplete LU factors
!!$    USE machine_constants, ONLY: kdp
!!$    USE mcs
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: sumfil
    !
    REAL(KIND=kdp) :: dd
    INTEGER :: i, ii, irow, j, jj, k, l
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    DO  k=1,nbn-1
       ra(10,k) = ra(10,k)+sumfil(k)
       DO  ii=1,cirh(1,k)
          i = cirh(ii+1,k)
          irow = cir(i,k)
          dd = ra(mar1(i,10),irow)/ra(10,k)
          ra(mar1(i,10),irow) = dd
          DO  jj=1,cirh(1,k)
             j = cirh(jj+1,k)
             l = mar1(i,j)
             IF (l == 0) THEN
                sumfil(irow) = sumfil(irow)-dd*ra(j,k)
                CYCLE
             END IF
             ra(l,irow) = ra(l,irow)-dd*ra(j,k)
          END DO
       END DO
    END DO
    ra(10,nbn) = ra(10,nbn)+sumfil(nbn)
  END SUBROUTINE rfactm

  SUBROUTINE lsolv(ra,rr,w)
    ! ... Solves the lower triangular matrix equation, L*w=rr
!!$    USE machine_constants, ONLY: kdp
!!$    USE mcs
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: ra
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: rr
    REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: w
    !
    REAL(KIND=kdp) :: s
    INTEGER :: j, jcol, jj, k
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    w(1) = rr(1)
    DO  k=2,nbn
       s = rr(k)
       DO  jj=1,cirl(1,k)
          j = cirl(jj+1,k)
          jcol = cir(j,k)
          s = s-ra(j,k)*w(jcol)
       END DO
       w(k) = s
    END DO
  END SUBROUTINE lsolv

  SUBROUTINE usolv(yy,ra,w)
    ! ... Solves the upper triangular matrix equation, U*YY=W
    ! ... The black-node equations
!!$    USE machine_constants, ONLY: kdp
!!$    USE mcs
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: yy
    REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: ra
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: w
    !
    REAL(KIND=kdp) :: s
    INTEGER :: j, jcol, jj, k
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    yy(nbn) = w(nbn)/ra(10,nbn)
    DO  k=nbn-1,1,-1
       s = w(k)
       DO  jj=1,cirh(1,k)
          j = cirh(jj+1,k)
          jcol = cir(j,k)
          s = s - ra(j,k)*yy(jcol)
       END DO
       yy(k) = s/ra(10,k)
    END DO
  END SUBROUTINE usolv

  SUBROUTINE vpsv(x,y,z,s,n)
    ! ... Calculates a vector plus a scalar times a vector
    ! ...      x=y+s*z
    USE machine_constants, ONLY: kdp
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: x
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: y, z
    REAL(KIND=kdp), INTENT(IN) :: s
    INTEGER, INTENT(IN) :: n
    !
    INTEGER :: i
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_iter_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    DO  i=1,n
       x(i) = y(i)+s*z(i)
    END DO
  END SUBROUTINE vpsv

END MODULE solver_iter_mod
