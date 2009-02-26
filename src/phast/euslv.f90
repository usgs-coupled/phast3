SUBROUTINE euslv(neqn,ipenv,env,diag,rhs)
  ! ... Envelope storage upper solve
  ! ... Solves an upper triangular system  U*y = b
  ! ... U is stored in envelope format as U_transpose
  ! ...   from George & Liu (1981) Computer Solution of Large, Sparse,
  ! ...      Positive Definite Systems
  ! ... RHS is overwritten with the solution
  USE machine_constants, ONLY: kdp
  INTEGER, INTENT(IN) :: neqn
  INTEGER, dimension(:), INTENT(IN) :: ipenv
  REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: env, diag
  REAL(kind=kdp), DIMENSION(:), INTENT(INOUT) :: rhs
  !
  REAL(kind=kdp) :: s
  INTEGER :: i, iband, k, kstop, kstrt, l
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  i=neqn+1
10 i=i-1
  IF(i > 0) THEN
     IF(ABS(rhs(i)) > 0.d0) THEN
        s=rhs(i)/diag(i)
        rhs(i)=s
        iband=ipenv(i+1)-ipenv(i)
        IF(iband >= i) iband=i-1
        IF(iband > 0) THEN
           kstrt=i-iband
           kstop=i-1
           l=ipenv(i+1)-iband
           DO  k=kstrt,kstop
              rhs(k)=rhs(k)-s*env(l)
              l=l+1
           END DO
        END IF
     END IF
     GO TO 10
  END IF
END SUBROUTINE euslv
