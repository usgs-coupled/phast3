SUBROUTINE ldind(idir)
  ! ... Loads the IND array with a natural numbering in the permutation
  ! ...      of x, y, and z specified by idir
  ! ... This is the permutation mapping back to the natural numbering.
  ! ... The inverse of this mapping applied to the basic reordering
  ! ...      strategy gives the final reordering.
  ! ... IND(MP) - Natural node number of permuted node number MP
  USE mcg
  USE mcs, only: ind
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: idir
  INTEGER :: i, incli, inclj, inclk, j, k, l, li, lj, lk
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF (idir == 1) THEN
     incli = 1
     inclj = nx
     inclk = nxy
  ELSE IF (idir == 2) THEN
     incli = 1
     inclj = nx*nz
     inclk = nx
  ELSE IF (idir == 3) THEN
     incli = ny
     inclj = 1
     inclk = nxy
  ELSE IF (idir == 4) THEN
     incli = nz*ny
     inclj = 1
     inclk = ny
  ELSE IF (idir == 5) THEN
     incli = nz
     inclj = nx*nz
     inclk = 1
  ELSE IF (idir == 6) THEN
     incli = ny*nz
     inclj = nz
     inclk = 1
  END IF
  l = 0
  lk = 1
  DO  k=1,nz
     lj = lk
     DO  j=1,ny
        li = lj
        DO  i=1,nx
           l = l+1
           ind(li) = l
           li = li+incli
        END DO
        lj = lj+inclj
     END DO
     lk = lk+inclk
  END DO
END SUBROUTINE ldind
