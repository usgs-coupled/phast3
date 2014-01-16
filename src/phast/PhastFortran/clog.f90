SUBROUTINE clog(string)  
  ! ... Writes a string to the CLOG file
  USE f_units, ONLY: fuclog
  CHARACTER(LEN=*) :: string  
  !     ------------------------------------------------------------------
  WRITE(fuclog,'(A)') string  
END SUBROUTINE clog
