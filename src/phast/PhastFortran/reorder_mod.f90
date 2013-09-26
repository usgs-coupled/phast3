MODULE reorder_mod
! ... Routines to reorder the mesh node numbering for various orderings, and
! ...     to load the index arrays containing the ordering information
  USE mcs
  IMPLICIT NONE
  PUBLIC :: reordr
  PRIVATE :: d4ord, d4zord, rbord, ldind, ldci, ldcir, ldmar1, ldipen

CONTAINS

  SUBROUTINE reordr(slmeth)
    ! ... Establishes the renumbering of the mesh points for the selected
    ! ...      method of equation solution
    USE mcg
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: slmeth
    !
    INTEGER :: i, n1, n2, n3
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: reorder_mod.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp $'
    !     ------------------------------------------------------------------
    !...
    IF(slmeth == 1) THEN
       ! ... Set the renumbering order for the direct solver based on mesh
       ! ...      dimensions
       ! ...    IDIR    order of increasing no. of points
       ! ...     1      zyx
       ! ...     2      yzx
       ! ...     3      zxy
       ! ...     4      xzy
       ! ...     5      yxz
       ! ...     6      xyz
       IF(nz <= nx .AND. nz <= ny) THEN
          IF(ny <= nx) THEN
             idir=1
          ELSE
             idir=3
          END IF
       ELSE IF(ny <= nx .AND. ny <= nz) THEN
          IF(nx <= nz) THEN
             idir=5
          ELSE
             idir=2
          END IF
       ELSE IF(nx <= ny .AND. nx <= nz) THEN
          IF(ny <= nz) THEN
             idir=6
          ELSE
             idir=4
          END IF
       END IF
    END IF
    ! ... Set the upper limits depending on the direction selected
    IF(idir == 1) THEN
       n1 = nx
       n2 = ny
       n3 = nz
    ELSE IF(idir == 2) THEN
       n1 = nx
       n2 = nz
       n3 = ny
    ELSE IF(idir == 3) THEN
       n1 = ny
       n2 = nx
       n3 = nz
    ELSE IF(idir == 4) THEN
       n1 = ny
       n2 = nz
       n3 = nx
    ELSE IF(idir == 5) THEN
       n1 = nz
       n2 = nx
       n3 = ny
    ELSE IF(idir == 6) THEN
       n1 = nz
       n2 = ny
       n3 = nx
    END IF
    IF (slmeth == 1) THEN
       ! ... Load MORD using D4ORD and N1,N2,N3
       CALL d4ord(n1,n2,n3)
    ELSE IF (slmeth == 3) THEN
       ! ... Load MORD using RBORD and N1,N2,N3
       CALL rbord(n1,n2,n3)
    ELSE IF (slmeth == 5) THEN
       ! ... Load MORD using D4ZORD and N1,N2,N3
       CALL d4zord(n1,n2,n3)
    END IF
    ! ... Get the permutation mapping
    CALL ldind(idir)
    ! ... Now apply the permutation mapping to the ordering strategy
    DO  i=1,nxyz
       mrno(ind(i)) = mord(i)
    END DO
    ! ... Load indexing arrays used by the solvers, GCGRIS and TFRDS
    CALL ldci
    CALL ldcir
    CALL ldmar1
    ! ... Load pointer arrays for envelope storage; direct solver
    IF(slmeth == 1) CALL ldipen
  END SUBROUTINE reordr

  SUBROUTINE d4ord(nx,ny,nz)
    ! ... Renumbers the mesh points to partition the array to give a
    ! ...      reduced matrix
    ! ... Applies the alternating diagonal reordering strategy, D4, as
    ! ...      defined by Price & Coats
    ! ... Selection of the direction sequence for the permutation to
    ! ...      give the final ordering is done in the REORDR calling routine
    ! ... Used for direct solver
!!$    USE mcg
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: nx, ny, nz
    INTEGER :: i, i1, i2, i3, isum, j, k, m, md4, nx1, nx2, nx3, nxy
    LOGICAL :: odd
    !     ------------------------------------------------------------------
    !...
    nxy = nx*ny
    ! ... First set of diagonal planes has odd sum of indices
    odd = .true.
    isum = 3
    md4 = 0
    nd4n = 0
    ! ... Only IDIR = 1 is used for the basic reordering
    ! ...    IDIR    Order of increasing no. of points
    ! ...     1      zyx
    ! ...     2      yzx
    ! ...     3      zxy
    ! ...     4      xzy
    ! ...     5      yxz
    ! ...     6      xyz
    ! ... Find first IJK set for this diagonal plane
    nx3 = nz
    nx2 = ny
    nx1 = nx
    ! ... Start of the loop on diagonal planes
10  i3 = isum-2
    i3 = MIN(i3,nx3)
    i2 = isum-i3-1
    i2 = MIN(i2,nx2)
    i1 = isum-i3-i2
20  k = i3
    j = i2
    i = i1
    m = cellno(i,j,k)
    mord(m) = 0
    ! ... Don't skip excluded cells
    !...  IF(ibc(m) > -1) THEN
    ! ... D4 cell number
    md4 = md4+1
    IF(odd) nrn = md4
    ! ... Count the number of nodes in the rectangular region
    ! ...     All cells are counted now even if excluded
    ! ...     This is same as for iterative solvers
    nd4n = nd4n+1
    mord(m) = md4
    !...  END IF
    ! ... Find subsequent I,J, for given K  (or permutation)
    i2 = i2-1
    IF (i2 >= 1) THEN
       i1 = i1+1
       IF(i1 <= nx1) GO TO 20
    END IF
    i3 = i3-1
    IF(i3 < 1) GO TO 30
    i2 = isum-i3-1
    i2 = MIN(i2,nx2)
    i1 = isum-i3-i2
    IF(i1 <= nx1) GO TO 20
    ! ... Set up for next plane
30  isum = isum+2
    IF(isum <= nx+ny+nz) GO TO 10
    IF(odd) THEN
       ! ... Set up for planes with even sum of indices
       odd=.NOT.odd
       isum=4
       GO TO 10
    END IF
    nbn = nd4n-nrn

  CONTAINS

    FUNCTION cellno(i,j,k) RESULT (mcellno)
      IMPLICIT NONE
      INTEGER, INTENT(IN) :: i,j,k
      INTEGER :: mcellno
      ! ...
      mcellno=(k-1)*nxy+(j-1)*nx+i
    END FUNCTION cellno

  END SUBROUTINE d4ord

  SUBROUTINE d4zord(nx,ny,nz)
    ! ... Renumbers the mesh points to partition the array to give a
    ! ...      reduced matrix
    ! ... Used for the generalized conjugate-gradient solver
    ! ... Uses alternate diagonal renumbering with zig-zag across the
    ! ...      planes
!!$    USE mcg
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: nx, ny, nz
    INTEGER :: i, i1, i2, i3, idirl, iplane, isum, isweep,  &
         j, k, m, md4, n1, n2, n3, nxy
    INTEGER, DIMENSION(6), PARAMETER :: idirev = (/2,1,4,3,6,5/)
    LOGICAL :: odd
    !     ------------------------------------------------------------------
    !...
    nxy = nx*ny
    ! ... First set of diagonal planes has odd sum of indices
    odd = .true.
    isum = 3
    iplane = 1
    isweep = 1
    md4 = 0
    nd4n = 0
    ! ...    IDIRL    order X1 decreasing, for each X1, X2 decreases and X3
    ! ...                  increases
    ! ...     1      ZYX
    ! ...     2      ZXY
    ! ...     3      YXZ
    ! ...     4      YZX
    ! ...     5      XYZ
    ! ...     6      XZY
10  CONTINUE
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
    IF(idirl == 1 .OR. idirl == 2) n3=nz
    IF(idirl == 3 .OR. idirl == 4) n3=ny
    IF(idirl == 5 .OR. idirl == 6) n3=nx
    IF(idirl == 1 .OR. idirl == 5) n2=ny
    IF(idirl == 2 .OR. idirl == 3) n2=nx
    IF(idirl == 4 .OR. idirl == 6) n2=nz
    IF(idirl == 1 .OR. idirl == 4) n1=nx
    IF(idirl == 2 .OR. idirl == 6) n1=ny
    IF(idirl == 3 .OR. idirl == 5) n1=nz
    i3 = isum-2
    i3 = MIN(i3,n3)
    i2 = isum-i3-1
    i2 = MIN(i2,n2)
    i1 = isum-i3-i2
    IF(MOD(isweep,2) == 0) THEN
       IF(iplane == 1) idirl=2
       IF(iplane == 2) idirl=4
       IF(iplane == 3) idirl=5
    ELSE
       IF(iplane == 1) idirl=1
       IF(iplane == 2) idirl=3
       IF(iplane == 3) idirl=6
    END IF
    IF(idirl == 1 .OR. idirl == 2) n3=nz
    IF(idirl == 3 .OR. idirl == 4) n3=ny
    IF(idirl == 5 .OR. idirl == 6) n3=nx
    IF(idirl == 1 .OR. idirl == 5) n2=ny
    IF(idirl == 2 .OR. idirl == 3) n2=nx
    IF(idirl == 4 .OR. idirl == 6) n2=nz
    IF(idirl == 1 .OR. idirl == 4) n1=nx
    IF(idirl == 2 .OR. idirl == 6) n1=ny
    IF(idirl == 3 .OR. idirl == 5) n1=nz
30  IF(idirl == 1 .OR. idirl == 2) k=i3
    IF(idirl == 4 .OR. idirl == 6) k=i2
    IF(idirl == 3 .OR. idirl == 5) k=i1
    IF(idirl == 3 .OR. idirl == 4) j=i3
    IF(idirl == 1 .OR. idirl == 5) j=i2
    IF(idirl == 2 .OR. idirl == 6) j=i1
    IF(idirl == 5 .OR. idirl == 6) i=i3
    IF(idirl == 2 .OR. idirl == 3) i=i2
    IF(idirl == 1 .OR. idirl == 4) i=i1
    m = cellno(i,j,k)
    mord(m) = 0
    ! ... Renumber the excluded cells as normal
    md4=md4+1
    IF(odd) nrn = md4
    ! ... Total number of points renumbered
    nd4n = nd4n+1
    ! ... D4 node number
    mord(m) = md4
    ! ... Find subsequent I,J, for given K (or permutation)
    i2 = i2-1
    IF(i2 >= 1) THEN
       i1 = i1+1
       IF(i1 <= n1) GO TO 30
    END IF
    isweep = isweep+1
    idirl = idirev(idirl)
    IF(idirl == 1 .OR. idirl == 5) n2=ny
    IF(idirl == 2 .OR. idirl == 3) n2=nx
    IF(idirl == 4 .OR. idirl == 6) n2=nz
    IF(idirl == 1 .OR. idirl == 4) n1=nx
    IF(idirl == 2 .OR. idirl == 6) n1=ny
    IF(idirl == 3 .OR. idirl == 5) n1=nz
    i3 = i3-1
    IF (i3 < 1) GO TO 40
    i2 = isum-i3-1
    i2 = MIN(i2,n2)
    i1 = isum-i3-i2
    IF(i1 > n1) GO TO 40
    GO TO 30
    ! ... Set up for next plane
40  isum = isum+2
    iplane = iplane+1
    IF(iplane > 3) iplane = 1
    isweep = 1
    IF(isum <= nx+ny+nz) GO TO 10
    IF(odd) THEN
       ! ... Set up for planes with even sum of indices
       odd = .NOT.odd
       isum = 4
       iplane = 1
       isweep = 1
       GO TO 10
    END IF
    nbn = nd4n-nrn

  CONTAINS

    FUNCTION cellno(i,j,k) RESULT (mcellno)
      IMPLICIT NONE
      INTEGER, INTENT(IN) :: i,j,k
      INTEGER :: mcellno
      ! ...
      mcellno = (k-1)*nxy+(j-1)*nx+i
    END FUNCTION cellno

  END SUBROUTINE d4zord

  SUBROUTINE rbord(nx,ny,nz)
    ! ... Loads the index array with the red-black ordering strategy
    ! ... Applies the red-black reordering strategy
    ! ... Selection of the direction sequence for the permutation to
    ! ...      give the final ordering is done in the REORDR calling routine
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: nx, ny, nz
    !
    INTEGER :: ix, iy, iz, m, m1, mmod, nxyz
    !     ------------------------------------------------------------------
    !...
    nxyz = nx*ny*nz
    nrn = (nxyz+MOD(nxyz,2))/2
    nbn = nxyz-nrn
    DO  m=1,nxyz
       ! ... Calculate the red-black number for a given natural
       ! ...      node number,M
       mmod = MOD(m,2)
       m1 = (m+mmod)/2
       CALL mtoijk(m,ix,iy,iz,nx,ny)
       ! ... Is sum of indices even or odd?
       IF (MOD(ix+iy+iz,2) == 1) THEN        ! ...   It's a red node
          mord(m) = m1
       ELSE                                  ! ...   It's a black node
          mord(m) = nrn+m1
       END IF
    END DO
  END SUBROUTINE rbord

  SUBROUTINE ldind(idir)
    ! ... Loads the IND array with a natural numbering in the permutation
    ! ...      of x, y, and z specified by idir
    ! ... This is the permutation mapping back to the natural numbering.
    ! ... The inverse of this mapping applied to the basic reordering
    ! ...      strategy gives the final reordering.
    ! ... IND(MP) - Natural node number of permuted node number MP
    USE mcg
    IMPLICIT NONE
    INTEGER, INTENT(IN) :: idir
    INTEGER :: i, incli, inclj, inclk, j, k, l, li, lj, lk
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

  SUBROUTINE ldci
    ! ... Loads the CI array for connected nodes based on the renumbered
    ! ...      mesh
    USE mcg
    IMPLICIT NONE
    INTEGER :: j, kx, ky, kz, m, ma
    INTEGER, DIMENSION(6) :: i
    !     ------------------------------------------------------------------
    DO  m=1,nxyz
       CALL mtoijk(m,kx,ky,kz,nx,ny)
       ma = mrno(m)
       ! ... MA is non zero for all cells in the rectangular mesh
       ! ...      Excluded cells get a trivial equation
       !..     IF(ma > 0) THEN
       i(1) = m-nxy
       i(2) = m-nx
       i(3) = m-1
       i(4) = m+1
       i(5) = m+nx
       i(6) = m+nxy
       ! ... I is natural node number
       DO  j=1,6
          IF ((i(j) >= 1) .AND. (i(j) <= nxyz)) ci(j,ma) = mrno(i(j))
       END DO
       ! ... Modify indices for ends of node rows
       IF (kz == 1) ci(1,ma) = 0
       IF (ky == 1) ci(2,ma) = 0
       IF (kx == 1) ci(3,ma) = 0
       IF (kx == nx) ci(4,ma) = 0
       IF (ky == ny) ci(5,ma) = 0
       IF (kz == nz) ci(6,ma) = 0
    END DO
  END SUBROUTINE ldci

  SUBROUTINE ldcir
    ! ... Loads the CIR, CIRL, CIRH index arrays for the generalized
    ! ...      conjugate gradient solver
    ! ... These arrays are pointers for the reduced matrix, RA
    IMPLICIT NONE
    INTEGER :: ibn, ix, iy, j, k, kk
    !     ------------------------------------------------------------------
    !...
    DO  k=1,nbn
       cirl(1,k)=0
       cirh(1,k)=0
    END DO
    DO  k=1,nbn
       kk = nrn+k
       ! ... Lower level
       ix = ci(1,kk)
       IF (ix == 0) THEN
          DO  j=1,5
             cir(j,k) = 0
          END DO
       ELSE
          DO  j=1,5
             iy = ci(j,ix)
             IF (iy == 0) THEN
                cir(j,k) = 0
             ELSE
                ibn = iy-nrn
                cir(j,k) = ibn
                IF (ibn < k) THEN
                   cirl(1,k) = cirl(1,k)+1
                   cirl(cirl(1,k)+1,k) = j
                END IF
                IF (ibn > k) THEN
                   cirh(1,k) = cirh(1,k)+1
                   cirh(cirh(1,k)+1,k) = j
                END IF
             END IF
          END DO
       END IF
       ! ... Same level
       ix = ci(2,kk)
       IF (ix == 0) THEN
          DO  j=6,8
             cir(j,k) = 0
          END DO
       ELSE
          DO  j=2,4
             iy = ci(j,ix)
             IF (iy == 0) THEN
                cir(j+4,k) = 0
             ELSE
                ibn = iy-nrn
                cir(j+4,k) = ibn
                IF (ibn < k) THEN
                   cirl(1,k) = cirl(1,k)+1
                   cirl(cirl(1,k)+1,k) = j+4
                END IF
                IF (ibn > k) THEN
                   cirh(1,k) = cirh(1,k)+1
                   cirh(cirh(1,k)+1,k) = j+4
                END IF
             END IF
          END DO
       END IF
       ix = ci(3,kk)
       IF (ix == 0) THEN
          cir(9,k) = 0
       ELSE
          iy = ci(3,ix)
          IF (iy == 0) THEN
             cir(9,k) = 0
          ELSE
             ibn = iy-nrn
             cir(9,k) = ibn
             IF (ibn < k) THEN
                cirl(1,k) = cirl(1,k)+1
                cirl(cirl(1,k)+1,k) = 9
             END IF
             IF (ibn > k) THEN
                cirh(1,k) = cirh(1,k)+1
                cirh(cirh(1,k)+1,k) = 9
             END IF
          END IF
       END IF
       cir(10,k) = k
       ix = ci(4,kk)
       IF (ix == 0) THEN
          cir(11,k) = 0
       ELSE
          iy = ci(4,ix)
          IF (iy == 0) THEN
             cir(11,k) = 0
          ELSE
             ibn = iy-nrn
             cir(11,k) = ibn
             IF (ibn < k) THEN
                cirl(1,k) = cirl(1,k)+1
                cirl(cirl(1,k)+1,k) = 11
             END IF
             IF (ibn > k) THEN
                cirh(1,k) = cirh(1,k)+1
                cirh(cirh(1,k)+1,k) = 11
             END IF
          END IF
       END IF
       ix = ci(5,kk)
       IF (ix == 0) THEN
          DO  j=12,14
             cir(j,k) = 0
          END DO
       ELSE
          DO  j=3,5
             iy = ci(j,ix)
             IF (iy == 0) THEN
                cir(j+9,k) = 0
             ELSE
                ibn = iy-nrn
                cir(j+9,k) = ibn
                IF (ibn < k) THEN
                   cirl(1,k) = cirl(1,k)+1
                   cirl(cirl(1,k)+1,k) = j+9
                END IF
                IF (ibn > k) THEN
                   cirh(1,k) = cirh(1,k)+1
                   cirh(cirh(1,k)+1,k) = j+9
                END IF
             END IF
          END DO
       END IF
       ! ... Upper level
       ix = ci(6,kk)
       IF (ix == 0) THEN
          DO  j=15,19
             cir(j,k) = 0
          END DO
       ELSE
          DO  j=2,6
             iy = ci(j,ix)
             IF (iy == 0) THEN
                cir(j+13,k) = 0
             ELSE
                ibn = iy-nrn
                cir(j+13,k) = ibn
                IF (ibn < k) THEN
                   cirl(1,k) = cirl(1,k)+1
                   cirl(cirl(1,k)+1,k) = j+13
                END IF
                IF (ibn > k) THEN
                   cirh(1,k) = cirh(1,k)+1
                   cirh(cirh(1,k)+1,k) = j+13
                END IF
             END IF
          END DO
       END IF
    END DO
  END SUBROUTINE ldcir

  SUBROUTINE ldmar1  
    ! ... Loads the M1 array
    ! ... The MAR1 array relates the reduced matrix, RA, to the ILU
    ! ...      decomposition matrices.
    ! ... MAR1 depends on the order of ILU factorization, and
    ! ...      this is for order 1 factorization only.
    !... *** This Could Be Done In Blockdata ***
    IMPLICIT NONE
    !     ------------------------------------------------------------------
    !...
    mar1(1,1) = 10  
    mar1(1,2) = 15  
    mar1(1,3) = 16  
    mar1(1,4) = 17  
    mar1(1,5) = 18  
    mar1(1,6) = 0  
    mar1(1,7) = 0  
    mar1(1,8) = 0  
    mar1(1,9) = 0  
    mar1(1,10) = 19  
    mar1(1,11) = 0  
    mar1(1,12) = 0  
    mar1(1,13) = 0  
    mar1(1,14) = 0  
    mar1(1,15) = 0  
    mar1(1,16) = 0  
    mar1(1,17) = 0  
    mar1(1,18) = 0  
    mar1(1,19) = 0  
    ! ... 
    mar1(2,1) = 5  
    mar1(2,2) = 10  
    mar1(2,3) = 12  
    mar1(2,4) = 13  
    mar1(2,5) = 14  
    mar1(2,6) = 15  
    mar1(2,7) = 16  
    mar1(2,8) = 17  
    mar1(2,9) = 0  
    mar1(2,10) = 18  
    mar1(2,11) = 0  
    mar1(2,12) = 0  
    mar1(2,13) = 0  
    mar1(2,14) = 0  
    mar1(2,15) = 19  
    mar1(2,16) = 0  
    mar1(2,17) = 0  
    mar1(2,18) = 0  
    mar1(2,19) = 0  
    ! ... 
    mar1(3,1) = 4  
    mar1(3,2) = 8  
    mar1(3,3) = 10  
    mar1(3,4) = 11  
    mar1(3,5) = 13  
    mar1(3,6) = 0  
    mar1(3,7) = 15  
    mar1(3,8) = 0  
    mar1(3,9) = 16  
    mar1(3,10) = 17  
    mar1(3,11) = 0  
    mar1(3,12) = 18  
    mar1(3,13) = 0  
    mar1(3,14) = 0  
    mar1(3,15) = 0  
    mar1(3,16) = 19  
    mar1(3,17) = 0  
    mar1(3,18) = 0  
    mar1(3,19) = 0  
    ! ... 
    mar1(4,1) = 3  
    mar1(4,2) = 7  
    mar1(4,3) = 9  
    mar1(4,4) = 10  
    mar1(4,5) = 12  
    mar1(4,6) = 0  
    mar1(4,7) = 0  
    mar1(4,8) = 15  
    mar1(4,9) = 0  
    mar1(4,10) = 16  
    mar1(4,11) = 17  
    mar1(4,12) = 0  
    mar1(4,13) = 18  
    mar1(4,14) = 0  
    mar1(4,15) = 0  
    mar1(4,16) = 0  
    mar1(4,17) = 19  
    mar1(4,18) = 0  
    mar1(4,19) = 0  
    ! ... 
    mar1(5,1) = 2  
    mar1(5,2) = 6  
    mar1(5,3) = 7  
    mar1(5,4) = 8  
    mar1(5,5) = 10  
    mar1(5,6) = 0  
    mar1(5,7) = 0  
    mar1(5,8) = 0  
    mar1(5,9) = 0  
    mar1(5,10) = 15  
    mar1(5,11) = 0  
    mar1(5,12) = 16  
    mar1(5,13) = 17  
    mar1(5,14) = 18  
    mar1(5,15) = 0  
    mar1(5,16) = 0  
    mar1(5,17) = 0  
    mar1(5,18) = 19  
    mar1(5,19) = 0  
    ! ... 
    mar1(6,1) = 0  
    mar1(6,2) = 5  
    mar1(6,3) = 0  
    mar1(6,4) = 0  
    mar1(6,5) = 0  
    mar1(6,6) = 10  
    mar1(6,7) = 12  
    mar1(6,8) = 13  
    mar1(6,9) = 0  
    mar1(6,10) = 14  
    mar1(6,11) = 0  
    mar1(6,12) = 0  
    mar1(6,13) = 0  
    mar1(6,14) = 0  
    mar1(6,15) = 18  
    mar1(6,16) = 0  
    mar1(6,17) = 0  
    mar1(6,18) = 0  
    mar1(6,19) = 0  
    ! ... 
    mar1(7,1) = 0  
    mar1(7,2) = 4  
    mar1(7,3) = 5  
    mar1(7,4) = 0  
    mar1(7,5) = 0  
    mar1(7,6) = 8  
    mar1(7,7) = 10  
    mar1(7,8) = 11  
    mar1(7,9) = 12  
    mar1(7,10) = 13  
    mar1(7,11) = 0  
    mar1(7,12) = 14  
    mar1(7,13) = 0  
    mar1(7,14) = 0  
    mar1(7,15) = 17  
    mar1(7,16) = 18  
    mar1(7,17) = 0  
    mar1(7,18) = 0  
    mar1(7,19) = 0  
    ! ... 
    mar1(8,1) = 0  
    mar1(8,2) = 3  
    mar1(8,3) = 0  
    mar1(8,4) = 5  
    mar1(8,5) = 0  
    mar1(8,6) = 7  
    mar1(8,7) = 9  
    mar1(8,8) = 10  
    mar1(8,9) = 0  
    mar1(8,10) = 12  
    mar1(8,11) = 13  
    mar1(8,12) = 0  
    mar1(8,13) = 14  
    mar1(8,14) = 0  
    mar1(8,15) = 16  
    mar1(8,16) = 0  
    mar1(8,17) = 18  
    mar1(8,18) = 0  
    mar1(8,19) = 0  
    ! ... 
    mar1(9,1) = 0  
    mar1(9,2) = 0  
    mar1(9,3) = 4  
    mar1(9,4) = 0  
    mar1(9,5) = 0  
    mar1(9,6) = 0  
    mar1(9,7) = 8  
    mar1(9,8) = 0  
    mar1(9,9) = 10  
    mar1(9,10) = 11  
    mar1(9,11) = 0  
    mar1(9,12) = 13  
    mar1(9,13) = 0  
    mar1(9,14) = 0  
    mar1(9,15) = 0  
    mar1(9,16) = 17  
    mar1(9,17) = 0  
    mar1(9,18) = 0  
    mar1(9,19) = 0  
    ! ... 
    mar1(10,1) = 1  
    mar1(10,2) = 2  
    mar1(10,3) = 3  
    mar1(10,4) = 4  
    mar1(10,5) = 5  
    mar1(10,6) = 6  
    mar1(10,7) = 7  
    mar1(10,8) = 8  
    mar1(10,9) = 9  
    mar1(10,10) = 10  
    mar1(10,11) = 11  
    mar1(10,12) = 12  
    mar1(10,13) = 13  
    mar1(10,14) = 14  
    mar1(10,15) = 15  
    mar1(10,16) = 16  
    mar1(10,17) = 17  
    mar1(10,18) = 18  
    mar1(10,19) = 19  
    ! ... 
    mar1(11,1) = 0  
    mar1(11,2) = 0  
    mar1(11,3) = 0  
    mar1(11,4) = 3  
    mar1(11,5) = 0  
    mar1(11,6) = 0  
    mar1(11,7) = 0  
    mar1(11,8) = 7  
    mar1(11,9) = 0  
    mar1(11,10) = 9  
    mar1(11,11) = 10  
    mar1(11,12) = 0  
    mar1(11,13) = 12  
    mar1(11,14) = 0  
    mar1(11,15) = 0  
    mar1(11,16) = 0  
    mar1(11,17) = 16  
    mar1(11,18) = 0  
    mar1(11,19) = 0  
    ! ... 
    mar1(12,1) = 0  
    mar1(12,2) = 0  
    mar1(12,3) = 2  
    mar1(12,4) = 0  
    mar1(12,5) = 4  
    mar1(12,6) = 0  
    mar1(12,7) = 6  
    mar1(12,8) = 0  
    mar1(12,9) = 7  
    mar1(12,10) = 8  
    mar1(12,11) = 0  
    mar1(12,12) = 10  
    mar1(12,13) = 11  
    mar1(12,14) = 13  
    mar1(12,15) = 0  
    mar1(12,16) = 15  
    mar1(12,17) = 0  
    mar1(12,18) = 17  
    mar1(12,19) = 0  
    ! ... 
    mar1(13,1) = 0  
    mar1(13,2) = 0  
    mar1(13,3) = 0  
    mar1(13,4) = 2  
    mar1(13,5) = 3  
    mar1(13,6) = 0  
    mar1(13,7) = 0  
    mar1(13,8) = 6  
    mar1(13,9) = 0  
    mar1(13,10) = 7  
    mar1(13,11) = 8  
    mar1(13,12) = 9  
    mar1(13,13) = 10  
    mar1(13,14) = 12  
    mar1(13,15) = 0  
    mar1(13,16) = 0  
    mar1(13,17) = 15  
    mar1(13,18) = 16  
    mar1(13,19) = 0  
    ! ... 
    mar1(14,1) = 0  
    mar1(14,2) = 0  
    mar1(14,3) = 0  
    mar1(14,4) = 0  
    mar1(14,5) = 2  
    mar1(14,6) = 0  
    mar1(14,7) = 0  
    mar1(14,8) = 0  
    mar1(14,9) = 0  
    mar1(14,10) = 6  
    mar1(14,11) = 0  
    mar1(14,12) = 7  
    mar1(14,13) = 8  
    mar1(14,14) = 10  
    mar1(14,15) = 0  
    mar1(14,16) = 0  
    mar1(14,17) = 0  
    mar1(14,18) = 15  
    mar1(14,19) = 0  
    ! ... 
    mar1(15,1) = 0  
    mar1(15,2) = 1  
    mar1(15,3) = 0  
    mar1(15,4) = 0  
    mar1(15,5) = 0  
    mar1(15,6) = 2  
    mar1(15,7) = 3  
    mar1(15,8) = 4  
    mar1(15,9) = 0  
    mar1(15,10) = 5  
    mar1(15,11) = 0  
    mar1(15,12) = 0  
    mar1(15,13) = 0  
    mar1(15,14) = 0  
    mar1(15,15) = 10  
    mar1(15,16) = 12  
    mar1(15,17) = 13  
    mar1(15,18) = 14  
    mar1(15,19) = 18  
    ! ... 
    mar1(16,1) = 0  
    mar1(16,2) = 0  
    mar1(16,3) = 1  
    mar1(16,4) = 0  
    mar1(16,5) = 0  
    mar1(16,6) = 0  
    mar1(16,7) = 2  
    mar1(16,8) = 0  
    mar1(16,9) = 3  
    mar1(16,10) = 4  
    mar1(16,11) = 0  
    mar1(16,12) = 5  
    mar1(16,13) = 0  
    mar1(16,14) = 0  
    mar1(16,15) = 8  
    mar1(16,16) = 10  
    mar1(16,17) = 11  
    mar1(16,18) = 13  
    mar1(16,19) = 17  
    ! ... 
    mar1(17,1) = 0  
    mar1(17,2) = 0  
    mar1(17,3) = 0  
    mar1(17,4) = 1  
    mar1(17,5) = 0  
    mar1(17,6) = 0  
    mar1(17,7) = 0  
    mar1(17,8) = 2  
    mar1(17,9) = 0  
    mar1(17,10) = 3  
    mar1(17,11) = 4  
    mar1(17,12) = 0  
    mar1(17,13) = 5  
    mar1(17,14) = 0  
    mar1(17,15) = 7  
    mar1(17,16) = 9  
    mar1(17,17) = 10  
    mar1(17,18) = 12  
    mar1(17,19) = 16  
    ! ... 
    mar1(18,1) = 0  
    mar1(18,2) = 0  
    mar1(18,3) = 0  
    mar1(18,4) = 0  
    mar1(18,5) = 1  
    mar1(18,6) = 0  
    mar1(18,7) = 0  
    mar1(18,8) = 0  
    mar1(18,9) = 0  
    mar1(18,10) = 2  
    mar1(18,11) = 0  
    mar1(18,12) = 3  
    mar1(18,13) = 4  
    mar1(18,14) = 5  
    mar1(18,15) = 6  
    mar1(18,16) = 7  
    mar1(18,17) = 8  
    mar1(18,18) = 10  
    mar1(18,19) = 15  
    ! ... 
    mar1(19,1) = 0  
    mar1(19,2) = 0  
    mar1(19,3) = 0  
    mar1(19,4) = 0  
    mar1(19,5) = 0  
    mar1(19,6) = 0  
    mar1(19,7) = 0  
    mar1(19,8) = 0  
    mar1(19,9) = 0  
    mar1(19,10) = 1  
    mar1(19,11) = 0  
    mar1(19,12) = 0  
    mar1(19,13) = 0  
    mar1(19,14) = 0  
    mar1(19,15) = 2  
    mar1(19,16) = 3  
    mar1(19,17) = 4  
    mar1(19,18) = 5  
    mar1(19,19) = 10  
  END SUBROUTINE ldmar1

  SUBROUTINE ldipen
    ! ... Loads the IPENV pointer array for the RA reduced matrix
    ! ... Used to generate the envelope storage
    IMPLICIT NONE
    INTEGER :: ibn, ibncol, ic, idiff, jc, jrnrow, ma, mm
    !     ------------------------------------------------------------------
    !...
    ipenv(1) = 1
    ibn = 0
    DO  ma=nrn+1,nd4n
       ibn = ibn+1
       ! ... Find minimum black-node column less than or equal to the
       ! ...      black-node row
       mm = ma
       DO  ic=1,6
          jrnrow = ci(ic,ma)
          IF(jrnrow > 0) THEN
             DO  jc=1,6
                ibncol = ci(jc,jrnrow)
                IF(ibncol > 0) mm = MIN(ibncol,mm)
             END DO
          END IF
       END DO
       idiff = ibn-(mm-nrn)
       ipenv(ibn+1) = ipenv(ibn)+idiff
    END DO
  END SUBROUTINE ldipen

END MODULE reorder_mod
