SUBROUTINE rbord(nx,ny,nz)
  ! ... Loads the index array with the red-black ordering strategy
  ! ... Applies the red-black reordering strategy
  ! ... Selection of the direction sequence for the permutation to
  ! ...      give the final ordering is done in the REORDR calling routine
  USE mcs
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: nx, ny, nz
  !
  INTEGER :: ix, iy, iz, m, m1, mmod, nxyz
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: rbord.f90,v $//$Revision: 2.1 $'
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
     IF (MOD(ix+iy+iz,2) == 1) THEN
        ! ...   It's a red node
        mord(m) = m1
     ELSE
        ! ...   It's a black node
        mord(m) = nrn+m1
     END IF
  END DO
END SUBROUTINE rbord
