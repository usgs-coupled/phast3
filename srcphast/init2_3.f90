SUBROUTINE init2_3
  ! ... Initialize after READ2
  ! ... This is the last initialization outside the P,T,C loop for
  ! ...      time marching
  ! ... Initialization block 2 after chemical reaction step
  USE machine_constants, ONLY: kdp
!!$  USE mcb
!!$  USE mcc
  USE mcg
  USE mcp
!!$  USE mcs
  USE mcv
!!$  USE mcw
  USE phys_const
  IMPLICIT NONE
  REAL(KIND=kdp) :: u0, u1, up0,  &
       udxyzi, udxyzo, udy, udydz, udz, ugdelx, &
       ugdely, ugdelz, upabd, upor, ut
  INTEGER :: iis, m
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  DO 810 M = 1, NXYZ  
!     IF(.NOT.fresur) THEN
!        pv(m) = pv(m) + pmcv(m)*(p(m)-p0)
!        ELSEIF(m <= nxyz-nxy) THEN
!        IF(ABS(frac(m) - 1._kdp) <= 1.D-6.AND.frac(m+nxy) > 0.) &
!             pv(m) = pv(m) + pmcv(m)*(p(m)-p0)
!     ENDIF
     ! ... Initial fluid(kg), heat(j), solute(kg) and pore volume(m^3)
     ! ...      in the region
     U0 = PV( M) * FRAC( M)  
     !..         U1=PVK(M)*FRAC(M)
     U1 = 0._KDP  
!     FIR0 = FIR0 + U0* DEN( M)  
!     FIRV0 = FIRV0 + U0  
!     IF( HEAT) EHIR0 = EHIR0 + U0*DEN(M)*EH(M) + PMHV(M)*T(M)
     DO 809 IIS = 1, NS
        sir0(iis) = sir0(iis) + den(m)*(u0 + u1)*c(m,iis)  
        sir(iis) = sir0(iis)  
809  END DO
810 END DO
END SUBROUTINE init2_3
