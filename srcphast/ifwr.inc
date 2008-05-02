  INTERFACE
     SUBROUTINE prntar(ndim,array,lprnt,fu,cnv,ifmt,nnoppr)
       USE machine_constants, ONLY: kdp
       INTEGER, INTENT(IN) :: ndim
       REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: array
       INTEGER, DIMENSION(:), INTENT(IN) :: lprnt
       INTEGER, INTENT(IN) :: fu
       REAL(kind=kdp), INTENT(IN) :: cnv
       INTEGER, INTENT(IN) :: ifmt
       INTEGER, INTENT(IN) :: nnoppr
    END SUBROUTINE prntar
    SUBROUTINE ldchar(indx1,indx2,mfrac,ip,cmask,mask,indxdim)
      USE machine_constants, ONLY: kdp
      INTEGER, DIMENSION(:,:), INTENT(INOUT) :: indx1, indx2
      REAL(kind=kdp), DIMENSION(:,:), INTENT(INOUT) :: mfrac
      INTEGER, INTENT(IN) :: ip
      CHARACTER(LEN=11), DIMENSION(:), INTENT(OUT) :: cmask
      INTEGER, DIMENSION(:), INTENT(OUT) :: mask
      INTEGER, INTENT(IN) :: indxdim
    END SUBROUTINE ldchar
    SUBROUTINE ldchar_bc(indx1, indx2, mfrac, ip, cmask, mask, mbc)
      USE machine_constants, ONLY: kdp
      INTEGER, DIMENSION(:), INTENT(IN) :: indx1, indx2
      REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: mfrac
      INTEGER, INTENT(IN) :: ip
      CHARACTER(LEN=11), DIMENSION(:), INTENT(OUT) :: cmask
      INTEGER, DIMENSION(:), INTENT(OUT) :: mask
      INTEGER, DIMENSION(:), INTENT(IN) :: mbc
    END SUBROUTINE ldchar_bc
!!    SUBROUTINE ldchar_seg(seg_indx, bc_type, cmask, mask)
!!      use mcb
!!      type(rbc_indices), DIMENSION(:), INTENT(IN) :: seg_indx
!!      integer, dimension(:), intent(in) :: seg_indx
!!      INTEGER, INTENT(IN) :: bc_type
!!      CHARACTER(LEN=11), DIMENSION(:), INTENT(OUT) :: cmask
!!      INTEGER, DIMENSION(:), INTENT(OUT) :: mask
!!    END SUBROUTINE ldchar_seg
    SUBROUTINE prchar(ndim,carray,lprnt,fu,nnoppr)
      INTEGER, INTENT(IN) :: ndim
      CHARACTER(LEN=11), DIMENSION(:), INTENT(IN) :: carray
      INTEGER, DIMENSION(:), INTENT(IN) :: lprnt
      INTEGER, INTENT(IN) :: fu
      INTEGER, INTENT(IN) :: nnoppr
    END SUBROUTINE prchar
  END INTERFACE
