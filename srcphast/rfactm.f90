SUBROUTINE rfactm(ra,sumfil)
  ! ... Factors the reduced matrix, RA, to modified incomplete LU factors
  USE machine_constants, ONLY: kdp
  USE mcs
  IMPLICIT NONE
  REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: ra
  REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: sumfil
  !
  REAL(kind=kdp) :: dd
  INTEGER :: i, ii, irow, j, jj, k, l
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: rfactm.f90,v $//$Revision: 2.1 $'
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
