SUBROUTINE ldchar_bc(indx1, indx2, mfrac, ip, cmask, mask, mbc)
  ! ... Loads the arrays for printing the indices and mixing fractions
  ! ... For boundary conditions
  USE machine_constants, ONLY: kdp
!!$  USE mcc
  USE mcg
  IMPLICIT NONE
  INTEGER, DIMENSION(:), INTENT(IN) :: indx1, indx2
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: mfrac
  INTEGER, INTENT(IN) :: ip
  CHARACTER (LEN=11), DIMENSION(:), INTENT(OUT) :: cmask
  INTEGER, DIMENSION(:), INTENT(OUT) :: mask
  INTEGER, DIMENSION(:), INTENT(IN) :: mbc
  !
  CHARACTER(LEN=3) :: cmfrac
  CHARACTER(LEN=3), DIMENSION(2) :: cindx
  INTEGER :: ib, id, jc, ls, m, nseg
  !     ------------------------------------------------------------------
  !...
  nseg = SIZE(indx1)
  DO  ls=1,nseg
     m = mbc(ls)
!     lprnt1(m)=-1
     mask(m)=0
     cmask(m)='           '
     WRITE(cindx(1),6001) indx1(ls)
     WRITE(cindx(2),6001) indx2(ls)
     6001 FORMAT(i3)
     WRITE(cmfrac,6002) mfrac(ls)
     6002 FORMAT(f3.1)
     ! ... Determine the number of characters in INDX1 and INDX2
     ib=1
     DO  id=1,2
        jc=1
        CALL stonb(cindx(id),jc,1)
        ! ... Find first blank character in CMASK(M)
20      IF(cmask(m)(ib:ib) /= ' ') THEN
           ib = ib+1
           GO TO 20
        END IF
        IF(ib > 1 .AND. ib <= 8) THEN
           cmask(m)(ib:ib) = ','
           ib = ib+1
        END IF
        IF(ib <= 11) cmask(m)(ib:) = cindx(id)(jc:3)
        !$$            MASK(M)=MASK(M)+1
        mask(m) = 1
     END DO
     ! ... Load in the mixing fraction
     ! ... Find next blank character in CMASK(M)
22   IF(cmask(m)(ib:ib) /= ' ') THEN
        ib = ib+1
        GO TO 22
     END IF
     IF(ib > 1 .AND. ib <= 8) THEN
        cmask(m)(ib:ib) = ','
        ib = ib+1
     END IF
     IF(ib <= 9) THEN
        cmask(m)(ib:) = cmfrac(1:3)
     ELSE
        cmask(m)(ib:) = '**'
     END IF
     !$$         LPRNT1(M)=1
  END DO
END SUBROUTINE ldchar_bc
