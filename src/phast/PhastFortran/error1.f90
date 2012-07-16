SUBROUTINE error1  
  ! ... Error detection routine for READ1
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  IMPLICIT NONE
  INTEGER :: i
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  errexi = .FALSE.  
  IF (nx < 2 .OR. ny < 1 .OR. nz < 2) ierr(1) = .TRUE.  
  IF (nhcn > 10) ierr(5) = .TRUE.  
  IF (slmeth <= 0 .OR. slmeth > 5 .OR. slmeth == 4) ierr(7) = .TRUE.  
  !$$  IF (RESTRT.AND.(LTCOMR.NE.LTCOM) ) IERR(8) = .TRUE.  
  IF (naifc > 0) ierr(48) = .TRUE.  
  IF (nhcbc > 0) ierr(49) = .TRUE.  
!!$  IF (NSDR.GT.LSDR) IERR(9) = .TRUE.  
!!$  IF (NSDR.GT.LSDR) THEN  
!!$     WRITE (ERMESS, 9001) 'Dimensioning error: NSDR[', NSDR, '] is greater than LSDR[',  &
!!$          LSDR, '];param5.inc'
!!$     9001 FORMAT(TR2,A,I5,A,I5,A)
!!$     CALL ERRPRT_C (ERMESS)  
!!$  ENDIF
  IF (slmeth /= 1 .AND. slmeth /= 5) ierr(7) = .TRUE.  
!$$  IF (RESTRT.AND. (LTCOMR.NE.LTCOM) ) IERR(8) = .TRUE.  
  DO  i=1,49  
     IF(ierr(i)) errexi = .TRUE.  
  END DO
  IF (errexi) CALL errprt(1,49)  
END SUBROUTINE error1
