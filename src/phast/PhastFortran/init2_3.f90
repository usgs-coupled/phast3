SUBROUTINE init2_3
  ! ... Initialize after READ2
  ! ... This is the last initialization group outside the P,T,C loop for
  ! ...      time marching
  ! ... Initialization block 2 after chemical reaction step
  USE machine_constants, ONLY: kdp
  USE mcg
  USE mcg_m
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE phys_const
  IMPLICIT NONE
  REAL(KIND=kdp) :: u0, u1, up0,  &
       udxyzi, udxyzo, udy, udydz, udz, ugdelx, &
       ugdely, ugdelz, upabd, upor, ut
  INTEGER :: iis, m
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: init2_3.f90 5055 2011-01-13 20:23:55Z dlpark $'
  !     ------------------------------------------------------------------
  !...
  DO  m = 1,nxyz  
     ! ... Initial solute(kg) in the region
     u0 = pv(m)*frac(m)  
     u1 = 0._kdp  
     DO  iis = 1,ns
        sir0(iis) = sir0(iis) + den0*(u0 + u1)*c(m,iis)  
        sir(iis) = sir0(iis)  
     END DO
  END DO
END SUBROUTINE init2_3
