SUBROUTINE sbcflo(iequ,ddv,ufracnp,qdvsbc,rhssbc,vasbc)
  ! ... Calculates the flow rates at specified value b.c. cells
  ! ... QDV is the average flow rate over the time step for CT differencing
  ! ...     or the flow rate at the end of the time step for BT differencing
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb_m
  USE mcs
  USE mcv
  USE mcv_m
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: iequ
  REAL(KIND=kdp), DIMENSION(0:), INTENT(IN) :: ddv
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: ufracnp
  REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: qdvsbc
  REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: rhssbc
  REAL(KIND=kdp), DIMENSION(:,:), INTENT(IN) :: vasbc
  !
  CHARACTER(LEN=9) :: cibc
  INTEGER :: l, m, mijkm, mijkp, mijmk, mijpk, mimjk, mipjk
  INTEGER, PARAMETER :: icxm=3, icxp=4, icym=2, icyp=5, iczm=1, iczp=6
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: sbcflo.f90 3780 2009-11-18 21:28:13Z dlpark $'
  !     ------------------------------------------------------------------
  !...
  DO  l=1,nsbc
     m=msbc(l)
     qdvsbc(l) = 0._kdp
     ! ... Explicit treatment of f.s.b.c.
     IF(frac(m) <= 0.) CYCLE
     WRITE(cibc,6001) ibc(m)
6001 FORMAT(i9.9)
     IF((iequ == 1 .AND. cibc(1:1) == '1') .OR.  &
          (iequ == 2 .AND. cibc(4:4) == '1') .OR.  &
          (iequ == 3 .AND. cibc(7:7) == '1')) THEN
        mimjk=ABS(cin(3,m))
        mipjk=ABS(cin(4,m))
        mijmk=ABS(cin(2,m))
        mijpk=ABS(cin(5,m))
        mijkm=ABS(cin(1,m))
        mijkp=ABS(cin(6,m))
        ! ... Evaluate the difference equation residual flow rate
        qdvsbc(l)=vasbc(icxm,l)*  &
             ddv(mimjk)+vasbc(icxp,l)*ddv(mipjk)+vasbc(icym,l)*  &
             ddv(mijmk)+vasbc(icyp,l)*ddv(mijpk)+vasbc(iczm,l)*  &
             ddv(mijkm)+vasbc(iczp,l)*ddv(mijkp)+vasbc(7,l)*ddv(m)- rhssbc(l)
     END IF
  END DO
END SUBROUTINE sbcflo
