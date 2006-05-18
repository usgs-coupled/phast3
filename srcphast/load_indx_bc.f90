SUBROUTINE load_indx_bc(ibct,indx1_bc,indx2_bc,mxf_bc,mbc,nbc)
  ! ... Loads the index and mixing fraction arrays that are packed for
  ! ...      each b.c. type
  USE machine_constants, ONLY: kdp
  USE mcv
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: ibct
  INTEGER, DIMENSION(:), INTENT(OUT) :: indx1_bc, indx2_bc
  REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: mxf_bc
  INTEGER, DIMENSION(:), INTENT(IN) :: mbc
  INTEGER, INTENT(IN) :: nbc
  !
  INTEGER :: l, m
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF (ibct < 4) THEN
! ... Everything other than rivers are loaded in the mesh locations of the indx_sol arrays
     DO  l=1,nbc
        m=mbc(l)
        indx1_bc(l)=indx_sol1_bc(ibct,m)
        indx2_bc(l)=indx_sol2_bc(ibct,m)
        mxf_bc(l)=bc_mxfrac(ibct,m)
     END DO
  ELSE
! ... Rivers are loaded in the first nrbc positions of the indx_sol arrays
     DO  l=1,nbc
        indx1_bc(l)=indx_sol1_bc(ibct,l)
        indx2_bc(l)=indx_sol2_bc(ibct,l)
        mxf_bc(l)=bc_mxfrac(ibct,l)
     END DO
  END IF
END SUBROUTINE load_indx_bc
