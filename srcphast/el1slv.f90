SUBROUTINE el1slv(neqn,ipenv,env,rhs)  
  ! ... Envelope storage lower solve for unit lower triangular matrix
  !.... Solves a lower triangular system  L*y = b
  ! ... L is stored in envelope format and has a unitary diagonal
  ! ... modified from George & Liu (1981) Computer Solution of Large,
  ! ...      Sparse, Positive Definite Systems
  ! ... RHS is overwritten with the solution
  USE machine_constants, ONLY: kdp
  INTEGER, INTENT(IN) ::  neqn  
  INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: env
  REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: rhs
  !
  REAL(KIND=kdp) :: s  
  INTEGER :: i, iband, ifirst, k, kstop, kstrt, l, last  
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: el1slv.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  ! ... Find the position of the first non-zero in rhs and put it in IFIRST
  IFIRST = 0  
10 IFIRST = IFIRST + 1  
  IF( ABS( RHS( IFIRST) ) .GT.0.D0) GOTO 20  
  IF( IFIRST.LT.NEQN) GOTO 10  
  RETURN  
20 LAST = 0  
  ! ... LAST contains the position of the most recently computed non-zero
  ! ...      component of the solution.
  DO  I = IFIRST, NEQN  
     IBAND = IPENV( I + 1) - IPENV( I)  
     IF( IBAND.GE.I) IBAND = I - 1  
     S = RHS( I)  
     L = I - IBAND  
     RHS( I) = 0.D0  
     ! ... Row of the envelope is empty, or corresponding components of the
     ! ...      solution are all zeros.
     IF( IBAND.EQ.0.OR.LAST.LT.L) GOTO 40  
     KSTRT = IPENV( I + 1) - IBAND  
     KSTOP = IPENV( I + 1) - 1  
     DO  K = KSTRT, KSTOP  
        S = S - ENV( K) * RHS( L)  
        L = L + 1  
     END DO
40   IF( ABS( S) .GT.0.D0) THEN  
        RHS( I) = S  
        LAST = I  
     ENDIF
  END DO
END SUBROUTINE el1slv
