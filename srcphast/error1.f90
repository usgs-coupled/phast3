SUBROUTINE error1  
  ! ... Error detection routine for READ1
  USE mcb
  USE mcc
  USE mcg
  IMPLICIT NONE
  INTEGER :: i
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ERREXI = .FALSE.  
  IF (NX.LT.2.OR.NY.LT.1.OR.NZ.LT.2) IERR (1) = .TRUE.  
  IF (NHCN.GT.10) IERR (5) = .TRUE.  
  IF (SLMETH.LE.0.OR.SLMETH.GT.5.OR.SLMETH.EQ.4) IERR (7) = .TRUE.  
  !  IF (RESTRT.AND. (LTCOMR.NE.LTCOM) ) IERR (8) = .TRUE.  
  IF (NAIFC.GT.0) IERR (48) = .TRUE.  
  IF (NHCBC.GT.0) IERR (49) = .TRUE.  
!!$  IF (NSDR.GT.LSDR) IERR (9) = .TRUE.  
!!$  IF (NSDR.GT.LSDR) THEN  
!!$     WRITE (ERMESS, 9001) 'Dimensioning error: NSDR[', NSDR, '] is greater than LSDR[',  &
!!$          LSDR, '];param5.inc'
!!$     9001 FORMAT(TR2,A,I5,A,I5,A)
!!$     CALL ERRPRT_C (ERMESS)  
!!$  ENDIF
  IF (SLMETH.NE.1.AND.SLMETH.NE.5) IERR (7) = .TRUE.  
!  IF (RESTRT.AND. (LTCOMR.NE.LTCOM) ) IERR (8) = .TRUE.  
  DO  I = 1, 49  
     IF(IERR(I)) ERREXI = .TRUE.  
  END DO
  IF (ERREXI) CALL ERRPRT(1,49)  
END SUBROUTINE error1
