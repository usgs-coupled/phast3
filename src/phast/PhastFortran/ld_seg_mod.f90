MODULE ld_seg_mod
  USE mcb
  USE mcb_m
  USE mcg
  USE mcg_m

CONTAINS

  SUBROUTINE ldchar_seg(seg_indx, bc_type, cmask, mask)
    ! ... Loads the arrays for printing the segment indices
    ! ... Called for each boundary condition type
    IMPLICIT NONE
    TYPE(rbc_indices), DIMENSION(:), INTENT(IN) :: seg_indx
    INTEGER, INTENT(IN) :: bc_type
    CHARACTER(LEN=11), DIMENSION(:), INTENT(OUT) :: cmask
    INTEGER, DIMENSION(:), INTENT(OUT) :: mask
    !
    CHARACTER(LEN=3), DIMENSION(2) :: cindx
    INTEGER :: ib, id, isf, isl, jc, lc, ls, m, ncell
    ! ... Set string for use with RCS ident command
    CHARACTER(LEN=80) :: ident_string='$Id: ld_seg_mod.f90,v 1.1 2013/09/19 20:41:58 klkipp Exp klkipp $'
    !     ------------------------------------------------------------------
    !...
    ncell = SIZE(seg_indx)
    DO  lc=1,ncell
       m = seg_indx(lc)%m
       mask(m) = 0
       cmask(m) = '           '
       WRITE(cindx(1),6001) seg_indx(lc)%seg_first
       WRITE(cindx(2),6001) seg_indx(lc)%seg_last
6001   FORMAT(i3)
       isf = seg_indx(lc)%seg_first
       isl = seg_indx(lc)%seg_last
       ib=1
       DO  id=1,2
          ! ... Skip to the first character in INDX1 or INDX2
          jc=1
          CALL stonb(cindx(id),jc,1)
          ! ... Find first blank character in CMASK(M)
20        IF(cmask(m)(ib:ib) /= ' ') THEN
             ib = ib+1
             GO TO 20
          END IF
          IF(ib > 1 .AND. ib < 11) THEN
             IF(isf == isl) THEN
                EXIT
             ELSEIF(isf+1 == isl) THEN
                cmask(m)(ib:ib) = ','
                ib = ib+1
             ELSE
                cmask(m)(ib:ib) = '-'
                ib = ib+1
             END IF
          END IF
          ! ... Load the segment number into the output string
          IF(ib <= 8+jc) THEN
             cmask(m)(ib:) = cindx(id)(jc:3)
          ELSE
             cmask(m)(ib:) = '**'
          END IF
          mask(m) = 1
       END DO
    END DO
  END SUBROUTINE ldchar_seg
END MODULE ld_seg_mod
