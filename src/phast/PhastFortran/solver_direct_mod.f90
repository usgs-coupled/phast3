MODULE solver_direct_mod
! ... Routines for the direct solver based on LU factorization then
! ...     backsolving
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  PRIVATE; PUBLIC :: tfrds
! ..  PRIVATE :: efact, el1slv, elslv, euslv
! ..  PRIVATE :: ident_string

CONTAINS
  SUBROUTINE tfrds_thread(diagra,envlra,envura,xp)
    ! ... Triangular-factorization, reduced matrix, direct solver
    ! ... Direct solver for reduced linear equation system using
    ! ...      LU triangular factorization
    ! ... Reduced system by D4 reordering
    ! ... Algorithm adapted from George & Liu
    ! ... Storage is by envelope method in lower triangular, transposed
    ! ...      upper triangular, and diagonal arrays
    USE mcm, only: 
    USE mcs, only: nbn, ipenv, nrn, ci
    USE XP_module
    IMPLICIT NONE
    TYPE (Transporter) :: xp
    REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: diagra, envlra, envura
    !
    REAL(KIND=kdp) :: uva, va7i
    INTEGER :: i, ibn, ibnrow, ic, ie, irn, jbncol, jc, joff, jrncol, mbnrow, nenvl
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_direct_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    REAL(KIND=kdp), DIMENSION(:), allocatable, target :: my_vector
    !     ------------------------------------------------------------------
    !...
    nenvl=ipenv(nbn+1)-1
    DO  i=1,nenvl
       envlra(i)=0._kdp
       envura(i)=0._kdp
    END DO
    ! ... Load diagonal array of reduced, RA (A4), matrix
    DO  ibn=1,nbn
       diagra(ibn)=xp%va(7,nrn+ibn)
    END DO
    ! ... Scale the red equations by D_r^-1, A1^-1
    DO  irn=1,nrn
       va7i = 1.0_kdp/xp%va(7,irn)
       DO  ic=1,6
          xp%va(ic,irn) = xp%va(ic,irn)*va7i
       END DO
       xp%rhs(irn)=xp%rhs(irn)*va7i
    END DO
    ! ... Eliminate A3 and form reduced matrix RA (A4') loading it into
    ! ...      envelope storage
    DO  irn=1,nrn
       DO  ic=1,6
          mbnrow=ci(ic,irn)
          IF(mbnrow > 0) THEN
             uva=xp%va(7-ic,mbnrow)
             ibnrow=mbnrow-nrn
             DO  jc=1,6
                jrncol=ci(jc,irn)
                IF(jrncol > 0) THEN
                   IF(jrncol < mbnrow) THEN
                      ! ... Load into lower triangle matrix
                      joff=mbnrow-jrncol
                      ie=ipenv(ibnrow+1)-joff
                      envlra(ie)=envlra(ie)-uva*xp%va(jc,irn)
                   ELSE IF(jrncol == mbnrow) THEN
                      ! ... Load into diagonal matrix
                      diagra(ibnrow)=diagra(ibnrow)-uva*xp%va(jc,irn)
                   ELSE IF(jrncol > mbnrow) THEN
                      ! ... Load into upper triangle matrix
                      jbncol=jrncol-nrn
                      joff=jrncol-mbnrow
                      ie=ipenv(jbncol+1)-joff
                      envura(ie)=envura(ie)-uva*xp%va(jc,irn)
                   END IF
                END IF
             END DO
             ! ... Form the rhs of the reduced equation
             xp%rhs(mbnrow)=xp%rhs(mbnrow)-uva*xp%rhs(irn)
          END IF
       END DO
    END DO
    ! ... Solve the reduced system by LU factorization
    ! ...    Factor RA into L and U triangular factors
    CALL efact(nbn,ipenv,envlra,envura,diagra)
    my_vector = xp%rhs(nrn+1:nrn+nbn)
    !rhs_b => xp%rhs(nrn+1:nrn+nbn)
    xp%rhs_b = my_vector
    ! ...    Solve Ly=b
    CALL el1slv(nbn,ipenv,envlra,xp%rhs_b)
    ! ...    Back solve Ux=y
    CALL euslv(nbn,ipenv,envura,diagra,xp%rhs_b)
    ! ...    Back solve the upper half matrix
    DO  irn=1,nrn
       DO  jc=1,6
          ibn=ci(jc,irn)
          ! ... VA is from upper half, A2'
          IF(ibn > 0) xp%rhs(irn)=xp%rhs(irn)-xp%va(jc,irn)*xp%rhs(ibn)
       END DO
    END DO
  END SUBROUTINE tfrds_thread
  SUBROUTINE tfrds(diagra,envlra,envura)
    ! ... Triangular-factorization, reduced matrix, direct solver
    ! ... Direct solver for reduced linear equation system using
    ! ...      LU triangular factorization
    ! ... Reduced system by D4 reordering
    ! ... Algorithm adapted from George & Liu
    ! ... Storage is by envelope method in lower triangular, transposed
    ! ...      upper triangular, and diagonal arrays
    USE mcm
    USE mcs
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: diagra, envlra, envura
    !
    REAL(KIND=kdp) :: uva, va7i
    INTEGER :: i, ibn, ibnrow, ic, ie, irn, jbncol, jc, joff, jrncol, mbnrow, nenvl
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_direct_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    nenvl=ipenv(nbn+1)-1
    DO  i=1,nenvl
       envlra(i)=0._kdp
       envura(i)=0._kdp
    END DO
    ! ... Load diagonal array of reduced, RA (A4), matrix
    DO  ibn=1,nbn
       diagra(ibn)=va(7,nrn+ibn)
    END DO
    ! ... Scale the red equations by D_r^-1, A1^-1
    DO  irn=1,nrn
       va7i = 1.0_kdp/va(7,irn)
       DO  ic=1,6
          va(ic,irn) = va(ic,irn)*va7i
       END DO
       rhs(irn)=rhs(irn)*va7i
    END DO
    ! ... Eliminate A3 and form reduced matrix RA (A4') loading it into
    ! ...      envelope storage
    DO  irn=1,nrn
       DO  ic=1,6
          mbnrow=ci(ic,irn)
          IF(mbnrow > 0) THEN
             uva=va(7-ic,mbnrow)
             ibnrow=mbnrow-nrn
             DO  jc=1,6
                jrncol=ci(jc,irn)
                IF(jrncol > 0) THEN
                   IF(jrncol < mbnrow) THEN
                      ! ... Load into lower triangle matrix
                      joff=mbnrow-jrncol
                      ie=ipenv(ibnrow+1)-joff
                      envlra(ie)=envlra(ie)-uva*va(jc,irn)
                   ELSE IF(jrncol == mbnrow) THEN
                      ! ... Load into diagonal matrix
                      diagra(ibnrow)=diagra(ibnrow)-uva*va(jc,irn)
                   ELSE IF(jrncol > mbnrow) THEN
                      ! ... Load into upper triangle matrix
                      jbncol=jrncol-nrn
                      joff=jrncol-mbnrow
                      ie=ipenv(jbncol+1)-joff
                      envura(ie)=envura(ie)-uva*va(jc,irn)
                   END IF
                END IF
             END DO
             ! ... Form the rhs of the reduced equation
             rhs(mbnrow)=rhs(mbnrow)-uva*rhs(irn)
          END IF
       END DO
    END DO
    ! ... Solve the reduced system by LU factorization
    ! ...    Factor RA into L and U triangular factors
    CALL efact(nbn,ipenv,envlra,envura,diagra)
    rhs_b => rhs(nrn+1:nrn+nbn)
    ! ...    Solve Ly=b
    CALL el1slv(nbn,ipenv,envlra,rhs_b)
    ! ...    Back solve Ux=y
    CALL euslv(nbn,ipenv,envura,diagra,rhs_b)
    ! ...    Back solve the upper half matrix
    DO  irn=1,nrn
       DO  jc=1,6
          ibn=ci(jc,irn)
          ! ... VA is from upper half, A2'
          IF(ibn > 0) rhs(irn)=rhs(irn)-va(jc,irn)*rhs(ibn)
       END DO
    END DO
  END SUBROUTINE tfrds

  SUBROUTINE efact(neqn,ipenv,envl,envut,diag)
    ! ... Factors a positive definite matrix A into L*U. The matrix A
    ! ...      is stored in envelope format. The algorithm is the standard
    ! ...      bordering method from George & Liu (1981) Computer Solution
    ! ...      of Large, Sparse, Positive Definite Systems
    USE mcc
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: neqn
    INTEGER, DIMENSION(:), INTENT(IN), TARGET :: ipenv
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN), TARGET :: envl, envut
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT), TARGET :: diag
    !
    REAL(KIND=kdp) :: g, temp, wt
    INTEGER :: count, i, iband, ifirst, iipenv, j, jstop, ops
    INTEGER, DIMENSION(:), POINTER :: ipenvv
    REAL(KIND=kdp), DIMENSION(:), POINTER :: envlv, envutv, diagv
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_direct_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    count=0
    ops=0
    IF(diag(1) <= 0._kdp) THEN
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
20     IF(temp <= 0.d0) THEN
          ierr(199)=.TRUE.
          RETURN
       END IF
       ! ... Put T into diagonal storage
       diag(i)=temp
       count=iband
       ops=ops+count
    END DO
  END SUBROUTINE efact

  SUBROUTINE el1slv(neqn,ipenv,env,rhs)  
    ! ... Envelope storage lower solve for unit lower triangular matrix
    !.... Solves a lower triangular system  L*y = b
    ! ... L is stored in envelope format and has a unitary diagonal
    ! ... modified from George & Liu (1981) Computer Solution of Large,
    ! ...      Sparse, Positive Definite Systems
    ! ... RHS is overwritten with the solution
    IMPLICIT NONE
    INTEGER, INTENT(IN) ::  neqn  
    INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: env
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: rhs
    !
    REAL(KIND=kdp) :: s  
    INTEGER :: i, iband, ifirst, k, kstop, kstrt, l, last  
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_direct_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    ! ... Find the position of the first non-zero in rhs and put it in IFIRST
    ifirst = 0  
10  ifirst = ifirst + 1  
    IF(ABS(rhs(ifirst)) > 0._kdp) GOTO 20  
    IF(ifirst < neqn) GOTO 10  
    RETURN
20  last = 0
    ! ... LAST contains the position of the most recently computed non-zero
    ! ...      component of the solution.
    DO  i=ifirst,neqn  
       iband = ipenv(i+1) - ipenv(i)  
       IF(iband >= i) iband = i-1  
       s = rhs(i)
       l = i - iband  
       rhs(i) = 0_kdp  
       ! ... Row of the envelope is empty, or corresponding components of the
       ! ...      solution are all zeros.
       IF(iband == 0 .OR. last < l) GOTO 40  
       kstrt = ipenv(i+1) - iband  
       kstop = ipenv(i+1) - 1  
       DO  k=kstrt,kstop  
          s = s - env(k)*rhs(l)  
          l = l + 1  
       END DO
40     IF(ABS(s) > 0._kdp) THEN  
          rhs(i) = s  
          last = i  
       ENDIF
    END DO
  END SUBROUTINE el1slv

  SUBROUTINE elslv(neqn,ipenv,env,diag,rhs)
    ! ... Envelope storage lower solve
    ! ... Solves a lower triangular system  L*y = b
    ! ... L is stored in envelope format
    ! ... from George & Liu (1981) Computer Solution of Large, Sparse,
    ! ...      Positive Definite Systems
    ! ... RHS is overwritten with the solution
!!$    USE machine_constants, ONLY: kdp
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: neqn
    INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: env, diag
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN OUT) :: rhs
    !
    REAL(KIND=kdp) :: s
    INTEGER :: i, iband, ifirst, k, kstop, kstrt, l, last
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_direct_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    ! ... Find the position of the first non-zero in rhs and put it in IFIRS
    ifirst=0
10  ifirst=ifirst+1
    IF(ABS(rhs(ifirst)) > 0._kdp) GO TO 20
    IF(ifirst < neqn) GO TO 10
    RETURN
20  last=0
    ! ... LAST contains the position of the most recently computed non-zero
    ! ...      component of the solution.
    DO  i=ifirst,neqn
       iband=ipenv(i+1)-ipenv(i)
       IF(iband >= i) iband=i-1
       s=rhs(i)
       l=i-iband
       rhs(i)=0._kdp
       ! ... Row of the envelope is empty, or corresponding components of the
       ! ...      solution are all zeros.
       IF(iband == 0 .OR. last < l) GO TO 40
       kstrt=ipenv(i+1)-iband
       kstop=ipenv(i+1)-1
       DO  k=kstrt,kstop
          s=s-env(k)*rhs(l)
          l=l+1
       END DO
40     IF(ABS(s) > 0._kdp) THEN
          rhs(i)=s/diag(i)
          last=i
       END IF
    END DO
  END SUBROUTINE elslv

  SUBROUTINE euslv(neqn,ipenv,env,diag,rhs)
    ! ... Envelope storage upper solve
    ! ... Solves an upper triangular system  U*y = b
    ! ... U is stored in envelope format as U_transpose
    ! ...   from George & Liu (1981) Computer Solution of Large, Sparse,
    ! ...      Positive Definite Systems
    ! ... RHS is overwritten with the solution
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: neqn
    INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
    REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: env, diag
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: rhs
    !
    REAL(KIND=kdp) :: s
    INTEGER :: i, iband, k, kstop, kstrt, l
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: solver_direct_mod.f90,v 1.2 2011/01/06 23:10:03 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    i=neqn+1
10  i=i-1
    IF(i > 0) THEN
       IF(ABS(rhs(i)) > 0._kdp) THEN
          s=rhs(i)/diag(i)
          rhs(i)=s
          iband = ipenv(i+1)-ipenv(i)
          IF(iband >= i) iband = i-1
          IF(iband > 0) THEN
             kstrt = i-iband
             kstop = i-1
             l = ipenv(i+1)-iband
             DO  k=kstrt,kstop
                rhs(k) = rhs(k)-s*env(l)
                l = l+1
             END DO
          END IF
       END IF
       GO TO 10
    END IF
  END SUBROUTINE euslv

END MODULE solver_direct_mod
