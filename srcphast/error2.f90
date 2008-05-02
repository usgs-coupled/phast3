SUBROUTINE error2  
  ! ... Error detection routine for READ2
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  INTEGER :: i, nr
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Cylindrical coordinates
  nr=nx
  IF(cylind .AND. x(1) >= x(nr)) ierr(21) = .TRUE.  
  ! ... Check for tilt greater than 45 deg.
  IF(thetxz > 135._kdp .OR. thetyz > 135._kdp .OR. thetzz > 45._kdp) ierr(27) = .TRUE.
  IF( fresur .AND. tilt) ierr(31) = .TRUE.  
  IF( heat .AND. fresur) ierr(32) = .TRUE.  
  ! ... Initial conditions
  IF(ichydp .AND. ichwt) ierr(43) = .TRUE.  
  IF(ichwt .AND. .NOT.fresur) ierr(44) = .TRUE.  
  DO  i=6,200  
     IF(ierr(i)) errexi = .TRUE.  
  END DO
  IF(errexi) CALL errprt(6,200)  
END SUBROUTINE error2
