SUBROUTINE error2  
  ! ... Error detection routine for READ2
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  INTEGER :: i, nr
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: error2.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  ! ... Cylindrical coordinates
  nr=nx
  IF( CYLIND.AND.X( 1) .GE.X( NR) ) IERR( 21) = .TRUE.  
  ! ... Check for tilt greater than 45 deg.
  IF(THETXZ > 135._kdp.OR.THETYZ > 135._kdp.OR.THETZZ > 45._kdp) ierr(27) = .TRUE.
  IF( FRESUR.AND.TILT) IERR( 31) = .TRUE.  
  IF( HEAT.AND.FRESUR) IERR( 32) = .TRUE.  
  ! ... Initial conditions
  IF( ICHYDP.AND.ICHWT) IERR( 43) = .TRUE.  
  IF( ICHWT.AND..NOT.FRESUR) IERR( 44) = .TRUE.  
  DO  I = 6, 200  
     IF( IERR( I) ) ERREXI = .TRUE.  
  END DO
  IF( ERREXI) CALL ERRPRT( 6, 200)  
END SUBROUTINE error2
