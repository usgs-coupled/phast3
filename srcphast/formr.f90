SUBROUTINE formr(ra)
  ! ... Form the product of the off-diagonal blocks,
  ! ...      scale and subtract from the black diagonal to get
  ! ...      the reduced matrix, RA.
  USE machine_constants, ONLY: kdp
  USE mcm
  USE mcs
  IMPLICIT NONE
  REAL(kind=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
  !
  REAL(kind=kdp) :: dd
  INTEGER :: i, irow, j, k, nrow
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
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
