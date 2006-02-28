SUBROUTINE d4ord(nx,ny,nz)
  ! ... Renumbers the mesh points to partition the array to give a
  ! ...      reduced matrix
  ! ... Applies the alternating diagonal reordering strategy, D4, as
  ! ...      defined by Price & Coats
  ! ... Selection of the direction sequence for the permutation to
  ! ...      give the final ordering is done in the REORDR calling routine
  ! ... Used for direct solver
  use mcs
  INTEGER, INTENT(IN) :: nx, ny, nz
  INTEGER :: i, i1, i2, i3, isum, j, k, m, md4, nx1, nx2, nx3, nxy
  LOGICAL :: odd
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  nxy=nx*ny
  ! ... First set of diagonal planes has odd sum of indices
  odd=.true.
  isum=3
  md4=0
  nd4n=0
  ! ... Only IDIR = 1 is used for the basic reordering
  ! ...    IDIR    Order of increasing no. of points
  ! ...     1      zyx
  ! ...     2      yzx
  ! ...     3      zxy
  ! ...     4      xzy
  ! ...     5      yxz
  ! ...     6      xyz
  ! ... Find first IJK set for this diagonal plane
  nx3=nz
  nx2=ny
  nx1=nx
  ! ... Start of the loop on diagonal planes
10 i3=isum-2
  i3=MIN(i3,nx3)
  i2=isum-i3-1
  i2=MIN(i2,nx2)
  i1=isum-i3-i2
20 k=i3
  j=i2
  i=i1
  m=cellno(i,j,k)
  mord(m)=0
  ! ... Don't skip excluded cells
  !...  IF(ibc(m) > -1) THEN
  ! ... D4 cell number
  md4=md4+1
  IF(odd) nrn=md4
  ! ... Count the number of nodes in the rectangular region
  ! ...     All cells are counted now even if excluded
  ! ...     This is same as for iterative solvers
  nd4n=nd4n+1
  mord(m)=md4
  !...  END IF
  ! ... Find subsequent I,J, for given K  (or permutation)
  i2=i2-1
  IF (i2 >= 1) THEN
     i1=i1+1
     IF(i1 <= nx1) GO TO 20
  END IF
  i3=i3-1
  IF(i3 < 1) GO TO 30
  i2=isum-i3-1
  i2=MIN(i2,nx2)
  i1=isum-i3-i2
  IF(i1 <= nx1) GO TO 20
  ! ... Set up for next plane
30 isum=isum+2
  IF(isum <= nx+ny+nz) GO TO 10
  IF(odd) THEN
     ! ... Set up for planes with even sum of indices
     odd=.NOT.odd
     isum=4
     GO TO 10
  END IF
  nbn=nd4n-nrn

CONTAINS

  FUNCTION cellno(i,j,k) RESULT (mcellno)
    IMPLICIT NONE
    INTEGER :: mcellno
    INTEGER, INTENT(IN) :: i,j,k
    ! ...
    mcellno=(k-1)*nxy+(j-1)*nx+i
  END FUNCTION cellno

END SUBROUTINE d4ord
