SUBROUTINE tfrds(diagra,envlra,envura)
  ! ... Triangular-factorization, reduced matrix, direct solver
  ! ... Direct solver for reduced linear equation system using
  ! ...      LU triangular factorization
  ! ... Reduced system by D4 reordering
  ! ... Algorithm adapted from George & Liu
  ! ... Storage is by envelope method in lower triangular, transposed
  ! ...      upper triangular, and diagonal arrays
  USE machine_constants, ONLY: kdp
  USE mcm
  USE mcs
  IMPLICIT NONE
  REAL(kind=kdp), DIMENSION(:), INTENT(OUT) :: diagra, envlra, envura
  INTERFACE
     SUBROUTINE efact(neqn,ipenv,envl,envut,diag)
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) :: neqn
       INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
       REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: envl, envut
       REAL(kind=kdp), DIMENSION(:), INTENT(INOUT) :: diag
     END SUBROUTINE efact
     SUBROUTINE el1slv(neqn,ipenv,env,rhs)  
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) ::  neqn  
       INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: env
       REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: rhs
     END SUBROUTINE el1slv
     SUBROUTINE euslv(neqn,ipenv,env,diag,rhs)
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) :: neqn
       INTEGER, DIMENSION(:), INTENT(IN) :: ipenv
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: env, diag
       REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: rhs
     END SUBROUTINE euslv
  END INTERFACE
  !
  REAL(KIND=kdp) :: uva, va7i
  INTEGER :: i, ibn, ibnrow, ic, ie, irn, jbncol, jc, joff, jrncol, mbnrow, nenvl
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: tfrds.f90,v $//$Revision: 2.1 $'
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
