SUBROUTINE ldci
  ! ... Loads the CI array for connected nodes based on the renumbered
  ! ...      mesh
  USE mcg
  USE mcs
  IMPLICIT NONE
  INTEGER :: j, kx, ky, kz, m, ma
  INTEGER, DIMENSION(6) :: i
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
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
        !..     END IF
  END DO
END SUBROUTINE ldci
