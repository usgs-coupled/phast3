  interface
     SUBROUTINE irewi(ipar,icall,ier)
       INTEGER, DIMENSION(:), INTENT(INOUT) :: ipar
       INTEGER, INTENT(INOUT) :: icall
       INTEGER, INTENT(IN) :: ier
     end subroutine irewi
     SUBROUTINE indx_rewi(ipar1,ipar2,par3,ip,icall,ier)
       USE machine_constants, ONLY: kdp
       INTEGER, dimension(:,:), INTENT(OUT) :: ipar1, ipar2
       REAL(kind=kdp), dimension(:,:), INTENT(OUT) :: par3
       INTEGER, INTENT(IN) :: ip
       INTEGER, INTENT(IN) :: icall
       INTEGER, INTENT(IN) :: ier
     end subroutine indx_rewi
     SUBROUTINE indx_rewi_bc(ipar1,ipar2,par3,ip,icall,ier)
       USE machine_constants, ONLY: kdp
       INTEGER, dimension(:,:), INTENT(OUT) :: ipar1, ipar2
       real(kind=kdp), dimension(:,:), INTENT(OUT) :: par3
       INTEGER, INTENT(IN) :: ip
       INTEGER, INTENT(IN) :: icall
       INTEGER, INTENT(IN) :: ier
     end subroutine indx_rewi_bc
     SUBROUTINE rewi(par,icall,ier)  
       USE machine_constants, ONLY: kdp
       REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: par
       INTEGER, INTENT(IN) :: icall
       INTEGER, INTENT(IN) :: ier  
     end subroutine rewi
     SUBROUTINE rewi3(par1,par2,par3,icall,ier)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), DIMENSION(:), INTENT(INOUT) :: par1, par2, par3
       INTEGER, INTENT(IN) :: icall
       INTEGER, INTENT(IN) :: ier
     end subroutine rewi3
  end interface
