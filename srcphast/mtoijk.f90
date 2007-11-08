SUBROUTINE mtoijk_orig
  ! ... Returns the index (I,J,K) of the point with
  ! ...      natural index M.
  !
  USE mcg
  IMPLICIT NONE
  !
  INTEGER :: i, m, imod, kr
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  do m = 1, nxyz
     imod = MOD(m,nxy)
     cellijk(m)%iz = (m-imod)/nxy + MIN(1,imod)
     kr = imod
     IF (kr == 0) kr = nxy
     imod = MOD(kr,nx)
     cellijk(m)%iy = (kr-imod)/nx + MIN(1,imod)
     i = imod
     IF (i == 0) i = nx
     cellijk(m)%ix = i
  enddo
END SUBROUTINE mtoijk_orig
SUBROUTINE mtoijk(m,i,j,k,xnx,xny)
  USE mcg
  ! ... Returns the index (I,J,K) of the point with
  ! ...      natural index M.
  !
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: m
  INTEGER, INTENT(OUT) :: i, j, k
  INTEGER, INTENT(IN) :: xnx, xny
  !
  INTEGER :: imod, kr, xnxy
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  i = cellijk(m)%ix
  j = cellijk(m)%iy
  k = cellijk(m)%iz
END SUBROUTINE mtoijk
