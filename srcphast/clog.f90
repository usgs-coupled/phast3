SUBROUTINE clog(string)  
  !.....Writes a string to the CLOG file
  USE f_units, ONLY: fuclog
  CHARACTER(LEN=*) :: string  
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: clog.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  WRITE(fuclog,'(A)') string  
END SUBROUTINE clog
