SUBROUTINE rfact(ra)
  ! ... Factors the reduced matrix, RA, to incomplete LU factors
  USE machine_constants, ONLY: kdp
  USE mcs
  IMPLICIT NONE
  REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
  !
  REAL(kind=kdp) :: dd
  INTEGER :: i, ii, irow, j, jj, k, l
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
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
