SUBROUTINE efact(neqn,ipenv,envl,envut,diag)
  ! ... Factors a positive definite matrix A into L*U. The matrix A
  ! ...      is stored in envelope format. The algorithm is the standard
  ! ...      bordering method from George & Liu (1981) Computer Solution
  ! ...      of Large, Sparse, Positive Definite Systems
  USE machine_constants, ONLY: kdp
  USE mcc
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: neqn
  INTEGER, DIMENSION(:), INTENT(IN), TARGET :: ipenv
  REAL(kind=kdp), DIMENSION(:), INTENT(IN), TARGET :: envl, envut
  REAL(kind=kdp), DIMENSION(:), INTENT(INOUT), TARGET :: diag
  INTERFACE
     SUBROUTINE el1slv(neqn,ipenv,env,rhs)  
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) :: neqn  
       INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
       REAL(KIND=kdp), DIMENSION(:), INTENT(in) :: env
       REAL(KIND=kdp), DIMENSION(:), INTENT(inout) :: rhs
     END SUBROUTINE el1slv
     SUBROUTINE elslv(neqn,ipenv,env,diag,rhs)
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) :: neqn
       INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
       REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: env, diag
       REAL(kind=kdp), DIMENSION(:), INTENT(IN OUT) :: rhs
     END SUBROUTINE elslv
  END INTERFACE
  !
  REAL(KIND=kdp) :: g, temp, wt
  INTEGER :: count, i, iband, ifirst, iipenv, j, jstop, ops
  INTEGER, DIMENSION(:), POINTER :: ipenvv
  REAL(KIND=kdp), DIMENSION(:), POINTER :: envlv, envutv, diagv
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: efact.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  count=0
  ops=0
  IF(diag(1) <= 0.d0) THEN
     ! ... Matrix is not positive definite
     ierr(199)=.TRUE.
     RETURN
  END IF
  ! ... Loop over rows 2,...,NEQN of the matrix
  DO  i=2,neqn
     iipenv=ipenv(i)
     iband=ipenv(i+1)-iipenv
     temp=diag(i)
     IF(iband == 0) GO TO 20
     ifirst=i-iband
     ipenvv => ipenv(ifirst:neqn+1)
     envutv => envut(iipenv:ipenv(neqn+1)) 
     diagv => diag(ifirst:neqn)
     envlv => envl(iipenv:ipenv(neqn+1)) 
     ! ... Compute row I of the triangular factor
     CALL el1slv(iband,ipenvv,envl,envutv)
     ! ... ENVUT contains g now
     CALL elslv(iband,ipenvv,envut,diagv,envlv)
     ! ... ENVL contains W^T now
     jstop=ipenv(i+1)-1
     DO  j=iipenv,jstop
        g=envut(j)
        wt=envl(j)
        temp=temp-wt*g
     END DO
20   IF(temp <= 0.d0) THEN
        ierr(199)=.TRUE.
        RETURN
     END IF
     ! ... Put T into diagonal storage
     diag(i)=temp
     count=iband
     ops=ops+count
  END DO
END SUBROUTINE efact
