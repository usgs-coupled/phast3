SUBROUTINE reordr(slmeth)
  ! ... Establishes the renumbering of the mesh points for the selected
  ! ...      method of equation solution
  USE mcg
  USE mcs
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: slmeth
  !
  INTEGER :: i, n1, n2, n3
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: reordr.f90,v $//$Revision: 2.1 $'
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
     IF(nz <= nx.AND.nz <= ny) THEN
        IF(ny <= nx) THEN
           idir=1
        ELSE
           idir=3
        END IF
     ELSE IF(ny <= nx.AND.ny <= nz) THEN
        IF(nx <= nz) THEN
           idir=5
        ELSE
           idir=2
        END IF
     ELSE IF(nx <= ny.AND.nx <= nz) THEN
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
