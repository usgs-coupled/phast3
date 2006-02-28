SUBROUTINE elslv(neqn,ipenv,env,diag,rhs)
  ! ... Envelope storage lower solve
  ! ... Solves a lower triangular system  L*y = b
  ! ... L is stored in envelope format
  ! ... from George & Liu (1981) Computer Solution of Large, Sparse,
  ! ...      Positive Definite Systems
  ! ... RHS is overwritten with the solution
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: neqn
  INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: env, diag
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN OUT) :: rhs
  !
  REAL(KIND=kdp) :: s
  INTEGER :: i, iband, ifirst, k, kstop, kstrt, l, last
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Find the position of the first non-zero in rhs and put it in IFIRS
  ifirst=0
10 ifirst=ifirst+1
  IF(ABS(rhs(ifirst)) > 0.d0) GO TO 20
  IF(ifirst < neqn) GO TO 10
  RETURN
20 last=0
  ! ... LAST contains the position of the most recently computed non-zero
  ! ...      component of the solution.
  DO  i=ifirst,neqn
     iband=ipenv(i+1)-ipenv(i)
     IF(iband >= i) iband=i-1
     s=rhs(i)
     l=i-iband
     rhs(i)=0.d0
     ! ... Row of the envelope is empty, or corresponding components of the
     ! ...      solution are all zeros.
     IF(iband == 0.OR.last < l) GO TO 40
     kstrt=ipenv(i+1)-iband
     kstop=ipenv(i+1)-1
     DO  k=kstrt,kstop
        s=s-env(k)*rhs(l)
        l=l+1
     END DO
40   IF(ABS(s) > 0.d0) THEN
        rhs(i)=s/diag(i)
        last=i
     END IF
  END DO
END SUBROUTINE elslv
