MODULE scale_jds_mod
  ! ... Module for row or column scaling of the linear equations 
  ! ...      stored in jagged diagonal format (Barrett et al, 1994, p. 61)
  ! ...      (Saad, 2001, p.91)
  USE machine_constants, ONLY: kdp
  IMPLICIT NONE
  PUBLIC :: rowscale, colscale

CONTAINS

  SUBROUTINE rowscale(nrow,norm,a,diag,ierr)
    ! ... Scales the rows of matrix A such that their norms are one
    ! ... Choices of norms: 1-norm, 2-norm, max-norm (infinity-norm).
    ! ... B' = Diag*B
    ! ... B is in compressed jagged diagonal format; B(1:n,1:nd)
    ! ... A is in compressed jagged diagonal format transposed; A(1:nd,1:n)
    !----------------------------------------------------------------------
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: nrow    ! ... The column dimension of A and the row dimension of B
    INTEGER, INTENT(IN) :: norm     ! ... norm selector. 1: 1-norm,
    ! ... 2: 2-norm, 0: max-norm
    REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: a     ! ... Matrix A in jagged
    ! ... diagonal format transposed
    ! ... Patch since explicit shape arrays clash with Java using Visual Fortran90 v6.0
!!$  REAL(KIND=kdp), DIMENSION(nrow), INTENT(OUT) :: diag  ! ... Diagonal matrix of scale factors
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: diag     ! ... Diagonal matrix of scale factors
    REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: b     ! ... Matrix B in jagged
    ! ... diagonal format 
    INTEGER, INTENT(OUT) :: ierr              ! ... error message. 0 : Normal return
    ! ...   i > 0 : Row number i is a zero row
    !
    INTEGER :: i, nd
    INTEGER :: a_err, da_err
    !     ------------------------------------------------------------------
    !...
    nd = SIZE(a,1)          ! ... maximum number of diagonals (elements) per row
    ALLOCATE (b(nrow,nd),  &
         stat = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: rowscale, number 1"  
       STOP  
    ENDIF
    b = TRANSPOSE(a)
    CALL rownorms(norm,b,diag)
    ierr = 0
    DO  i=1,nrow
       IF (diag(i) == 0.0_kdp) THEN
          ierr = i
          RETURN
       ELSE
          diag(i) = 1.0_kdp/diag(i)
       END IF
    END DO
    ! ... Scale matrix B
    CALL diamua(diag,b)
    a = TRANSPOSE(b)
    DEALLOCATE (b,  &
         stat = da_err)
    IF (da_err /= 0) THEN  
       PRINT *, "array deallocation failed, number 1"  
       STOP  
    ENDIF

  CONTAINS

    SUBROUTINE rownorms(norm,b,diag)
      ! ... Calculates the norms of each row of B. (choice of three norms)
      !-----------------------------------------------------------------
      IMPLICIT NONE
      INTEGER, INTENT(IN) :: norm     ! ... norm selector. 1:1-norm,
      ! ... 2:2-norm, 0: max-norm
      REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: b   ! ... Matrix B in jagged
      ! ... diagonal format 
      REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: diag     ! ... the norms
      !
      REAL(KIND=kdp) :: scal
      INTEGER :: ii, jd, nd
      !     ------------------------------------------------------------------
      !...
      ! ... nrow is known from host
      nd = SIZE(b,2)
      DO  ii=1,nrow
         ! ... Compute the norm of each row
         scal = 0.0_kdp
         IF (norm == 0) THEN
            DO  jd=1,nd
               scal = MAX(scal,ABS(b(ii,jd)))
            END DO
         ELSE IF (norm == 1) THEN
            DO  jd=1,nd
               scal = scal + ABS(b(ii,jd))
            END DO
         ELSE
            DO  jd=1,nd
               scal = scal + b(ii,jd)*b(ii,jd)
            END DO
         END IF
         IF (norm == 2) scal = SQRT(scal)
         diag(ii) = scal
      END DO
    END SUBROUTINE rownorms

    SUBROUTINE diamua(diag,b)
      ! ... Calculates a diagonal matrix times a matrix; B' = Diag*B (in place)
      !-----------------------------------------------------------------
      IMPLICIT NONE
      REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: diag  ! ... diagonal matrix
      REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: b    ! ... Matrix B in jagged
      ! ... diagonal format
      !
      REAL(KIND=kdp) :: scal
      INTEGER :: ii, jd, nd
      !     ------------------------------------------------------------------
      !...
      ! ... nrow is known from host
      nd = SIZE(b,2)
      DO  ii=1,nrow
         scal = diag(ii)
         DO  jd=1,nd
            b(ii,jd) = scal*b(ii,jd)
         END DO
      END DO
    END SUBROUTINE diamua

  END SUBROUTINE rowscale

  SUBROUTINE colscale(nrow,norm,a,ci,diag,ierr)
    ! ... Scales the columns of matrix A such that their norms are one
    ! ... Choices of norms: 1-norm, 2-norm, max-norm (infinity-norm).
    ! ... B' = B*Diag
    ! ... B is in compressed jagged diagonal format; B(1:n,1:nd)
    ! ... A is in compressed jagged diagonal format transposed; A(1:nd,1:n)
    !----------------------------------------------------------------------
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: nrow    ! ... The column dimension of A and the row dimension of B
    INTEGER, INTENT(IN) :: norm     ! ... norm selector. 1: 1-norm,
    ! ... 2: 2-norm, 0: max-norm
    REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: a     ! ... Matrix A in jagged
    ! ... diagonal format transposed
    INTEGER, DIMENSION(:,:), INTENT(IN) :: ci     ! ... column index for A or B
    ! ... Patch since explicit shape arrays clash with Java using Visual Fortran90 v6.0
!!$  REAL(KIND=kdp), DIMENSION(nrow), INTENT(OUT) :: diag  ! ... Diagonal matrix of scale factors
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: diag     ! ... Diagonal matrix of scale factors
    REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: b     ! ... Matrix B in jagged
    ! ... diagonal format 
    INTEGER, INTENT(OUT) :: ierr              ! ... error message. 0 : Normal return
    ! ...   i > 0: Column number i is a zero column
    !
    INTEGER :: j, nd
    INTEGER :: a_err, da_err
    !     ------------------------------------------------------------------
    !...
    nd = SIZE(a,1)
    ALLOCATE (b(nrow,nd),  &
         stat = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: colscale, number 1"  
       STOP  
    ENDIF
    b = TRANSPOSE(a)
    CALL colnorms(norm,b,diag)
    ierr = 0
    DO  j=1,nrow
       IF (diag(j) == 0.0_kdp) THEN
          ierr = j
          RETURN
       ELSE
          diag(j) = 1.0_kdp/diag(j)
       END IF
    END DO
    ! ... Scale matrix B
    CALL amudia(b,diag)
    a = TRANSPOSE(b)
    DEALLOCATE (b,  &
         stat = da_err)
    IF (da_err /= 0) THEN  
       PRINT *, "array deallocation failed, number 2"  
       STOP  
    ENDIF

  CONTAINS

    SUBROUTINE colnorms(norm,b,diag)
      ! ... Calculates the norms of each row of B. (choice of three norms)
      !-----------------------------------------------------------------
      IMPLICIT NONE
      INTEGER, INTENT(IN) :: norm     ! ... norm selector. 1: 1-norm,
      ! ... 2: 2-norm, 0: max-norm
      REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: b     ! ... Matrix B in jagged
      ! ... diagonal format 
      REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: diag     ! ... the norms
      !
      INTEGER :: ii, j, jd, nd
      !     ------------------------------------------------------------------
      !...
      ! ... nrow is known from host
      nd = SIZE(b,2)
      diag = 0.0_kdp
      DO  ii=1,nrow
         DO  jd=1,nd
            IF(jd <=6) THEN
               j = ci(jd,ii)
            ELSE
               j = ii
            END IF
            ! ... update the norm of each column
            IF (norm == 0) THEN     ! ... Linf-norm
               diag(j) = MAX(diag(j),ABS(b(ii,jd)))
            ELSE IF (norm == 1) THEN     ! ... L1-norm
               diag(j) = diag(j) + ABS(b(ii,jd))
            ELSE     ! ... L2-norm
               diag(j) = diag(j)+b(ii,jd)*b(ii,jd)
            END IF
         END DO
      END DO
      IF (norm == 2) THEN
         DO  j=1,nrow
            diag(j) = SQRT(diag(j))
         END DO
      END IF
    END SUBROUTINE colnorms

    SUBROUTINE amudia(b,diag)
      ! ... Calculates a matrix times a diagonal matrix; B' = B*Diag  (in place)
      !-----------------------------------------------------------------
      IMPLICIT NONE
      REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: b    ! ... Matrix B in jagged
      ! ... diagonal format
      REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: diag  ! ... diagonal matrix
      !
      INTEGER :: ii, j, jd, nd
      !     ------------------------------------------------------------------
      !...
      ! ... nrow is known from host
      nd = SIZE(b,2)
      DO  ii=1,nrow
         DO  jd=1,nd
            IF(jd <=6) THEN
               j = ci(jd,ii)
            ELSE
               j = ii
            END IF
            b(ii,jd) = b(ii,jd)*diag(j)
         END DO
      END DO
    END SUBROUTINE amudia

  END SUBROUTINE colscale

END MODULE scale_jds_mod
