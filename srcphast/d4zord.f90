SUBROUTINE d4zord(nx,ny,nz)
  ! ... Renumbers the mesh points to partition the array to give a
  ! ...      reduced matrix
  ! ... Used for the generalized conjugate-gradient solver
  ! ... Uses alternate diagonal renumbering with zig-zag across the
  ! ...      planes
  USE mcs
  INTEGER, INTENT(IN) :: nx, ny, nz
  INTEGER :: i, i1, i2, i3, idirl, iplane, isum, isweep,  &
       j, k, m, md4, n1, n2, n3, nxy
  INTEGER, DIMENSION(6), PARAMETER :: idirev = (/2,1,4,3,6,5/)
  LOGICAL :: odd
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  nxy=nx*ny
  ! ... First set of diagonal planes has odd sum of indices
  odd=.true.
  isum=3
  iplane=1
  isweep=1
  md4=0
  nd4n=0
  ! ...    IDIRL    order X1 decreasing, for each X1, X2 decreases and X3
  ! ...                  increases
  ! ...     1      ZYX
  ! ...     2      ZXY
  ! ...     3      YXZ
  ! ...     4      YZX
  ! ...     5      XYZ
  ! ...     6      XZY
10 CONTINUE
  IF(MOD(isweep,2) == 0) THEN
     ! ... Even sweeps
     IF(iplane == 1) idirl=2
     IF(iplane == 2) idirl=4
     IF(iplane == 3) idirl=5
  ELSE
     ! ... Odd sweeps
     IF(iplane == 1) idirl=1
     IF(iplane == 2) idirl=3
     IF(iplane == 3) idirl=6
  END IF
  ! ... Order the dimensions according to IDIRL
  ! ... Find first IJK set for this diagonal plane
  !....  ***RECODE THIS AND THE NEXT ONE***
  IF(idirl == 1.OR.idirl == 2) n3=nz
  IF(idirl == 3.OR.idirl == 4) n3=ny
  IF(idirl == 5.OR.idirl == 6) n3=nx
  IF(idirl == 1.OR.idirl == 5) n2=ny
  IF(idirl == 2.OR.idirl == 3) n2=nx
  IF(idirl == 4.OR.idirl == 6) n2=nz
  IF(idirl == 1.OR.idirl == 4) n1=nx
  IF(idirl == 2.OR.idirl == 6) n1=ny
  IF(idirl == 3.OR.idirl == 5) n1=nz
  i3=isum-2
  i3=MIN(i3,n3)
  i2=isum-i3-1
  i2=MIN(i2,n2)
  i1=isum-i3-i2
  IF(MOD(isweep,2) == 0) THEN
     IF(iplane == 1) idirl=2
     IF(iplane == 2) idirl=4
     IF(iplane == 3) idirl=5
  ELSE
     IF(iplane == 1) idirl=1
     IF(iplane == 2) idirl=3
     IF(iplane == 3) idirl=6
  END IF
  IF(idirl == 1.OR.idirl == 2) n3=nz
  IF(idirl == 3.OR.idirl == 4) n3=ny
  IF(idirl == 5.OR.idirl == 6) n3=nx
  IF(idirl == 1.OR.idirl == 5) n2=ny
  IF(idirl == 2.OR.idirl == 3) n2=nx
  IF(idirl == 4.OR.idirl == 6) n2=nz
  IF(idirl == 1.OR.idirl == 4) n1=nx
  IF(idirl == 2.OR.idirl == 6) n1=ny
  IF(idirl == 3.OR.idirl == 5) n1=nz
30 IF(idirl == 1.OR.idirl == 2) k=i3
  IF(idirl == 4.OR.idirl == 6) k=i2
  IF(idirl == 3.OR.idirl == 5) k=i1
  IF(idirl == 3.OR.idirl == 4) j=i3
  IF(idirl == 1.OR.idirl == 5) j=i2
  IF(idirl == 2.OR.idirl == 6) j=i1
  IF(idirl == 5.OR.idirl == 6) i=i3
  IF(idirl == 2.OR.idirl == 3) i=i2
  IF(idirl == 1.OR.idirl == 4) i=i1
  m=cellno(i,j,k)
  mord(m)=0
  ! ... Renumber the excluded cells as normal
  md4=md4+1
  IF(odd) nrn=md4
  ! ... Total number of points renumbered
  nd4n=nd4n+1
  ! ... D4 node number
  mord(m)=md4
  ! ... Find subsequent I,J, for given K (or permutation)
  i2=i2-1
  IF(i2 >= 1) THEN
     i1=i1+1
     IF(i1 <= n1) GO TO 30
  END IF
  isweep=isweep+1
  idirl=idirev(idirl)
  IF(idirl == 1.OR.idirl == 5) n2=ny
  IF(idirl == 2.OR.idirl == 3) n2=nx
  IF(idirl == 4.OR.idirl == 6) n2=nz
  IF(idirl == 1.OR.idirl == 4) n1=nx
  IF(idirl == 2.OR.idirl == 6) n1=ny
  IF(idirl == 3.OR.idirl == 5) n1=nz
  i3=i3-1
  IF (i3 < 1) GO TO 40
  i2=isum-i3-1
  i2=MIN(i2,n2)
  i1=isum-i3-i2
  IF(i1 > n1) GO TO 40
  GO TO 30
  ! ... Set up for next plane
40 isum=isum+2
  iplane=iplane+1
  IF(iplane > 3) iplane=1
  isweep=1
  IF(isum <= nx+ny+nz) GO TO 10
  IF(odd) THEN
     ! ... Set up for planes with even sum of indices
     odd=.NOT.odd
     isum=4
     iplane=1
     isweep=1
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

END SUBROUTINE d4zord
