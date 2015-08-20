SUBROUTINE write4
  ! ... Writes out the velocity field after coeff_flow
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcch
  USE mcch_m
  USE mcg
  USE mcg_m
  USE mcn, ONLY: x, y, z
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE print_control_mod
  IMPLICIT NONE
  INCLUDE 'ifwr.inc'
  REAL(KIND=kdp) :: wt
  INTEGER :: i, ic, indx, j, k, m
!!$  REAL(KIND=kdp), DIMENSION(nxyz) :: vx_node, vy_node, vz_node
  !     ------------------------------------------------------------------
  !...
  rxlbl='X'
  if (steady_flow) then
    if (ntprvel > 0) prvel = .false.
    if (ntprmapv > 0) prmapv = .false.
    if (ntprhdfv > 0) prhdfv = .false.
  endif
  
  IF(prvel .OR. prmapv .OR. prhdfv) THEN
     CALL calc_velocity
     lprnt1 = 1
     lprnt2 = 1
     ! ... Mask out excluded cells for all velocity output
     DO  m=1,nxyz
        IF(ibc(m) == -1) THEN
           lprnt1(m) = -1
           lprnt2(m) = -1
        END IF
        ! ... Use vmask to mask out velocity output for uncovered nodes
        ! ...      (water table below the node)
        IF(vmask(m) == 0) THEN
           lprnt2(m) = -1
        END IF
     END DO
!!$     ! ... Mask out boundary cells for xyx velocity only
!!$     DO  m=1,nxyz
!!$        IF(frac(m) < 1._kdp) THEN
!!$           lprnt2(m) = -1
!!$           CYCLE
!!$        ELSE
!!$           DO ic=1,6
!!$              mc = ABS(cin(ic,m))
!!$              IF(mc == 0) THEN
!!$                 lprnt2(m) = -1
!!$                 EXIT
!!$              ELSEIF(frac(mc) < 0._kdp) THEN
!!$                 lprnt2(m) = -1
!!$                 EXIT
!!$              END IF
!!$           END DO
!!$        END IF
!!$     END DO
  END IF
  IF(prvel) THEN
     WRITE(fuvel,2001) '*** Output at End of Time Step No. ', itime,' ***'
2001 FORMAT(//tr30,a,i5,a)
     WRITE(fuvel,2002) 'Time '//dots,cnvtmi*time,'(',unittm,')'
2002 FORMAT(/tr25,a60,1PG12.3,tr2,3A)
     WRITE(fuvel,2005) rxlbl//'-direction - interstitial pore velocity ',  &
          'between '//rxlbl//'(I) and '//rxlbl//'(I+1) (', unitl,'/',unittm,')'
2005 FORMAT(/tr25,10A)
     CALL printar(2,vxx,lprnt1,fuvel,cnvvli,24,-100)
     IF(cylind) GO TO 20
     WRITE(fuvel,2005) 'Y-direction - interstitial pore velocity ',  &
          'between Y(J) and Y(J+1) (',unitl,'/',unittm,')'
     CALL printar(2,vyy,lprnt1,fuvel,cnvvli,24,-010)
20   CONTINUE
     WRITE(fuvel,2005) 'Z-direction - interstitial pore velocity ',  &
          'between Z(K) and Z(K+1) (',unitl,'/',unittm,')'
     CALL printar(2,vzz,lprnt1,fuvel,cnvvli,24,-001)
     WRITE(fuvel,2005) rxlbl//'-direction - interstitial pore velocity ',  &
          'at nodes (', unitl,'/',unittm,')'
     CALL printar(2,vx_node,lprnt2,fuvel,cnvvli,24,000)
     IF(.NOT.cylind) THEN
        WRITE(fuvel,2005) 'Y-direction - interstitial pore velocity ',  &
             'at nodes (',unitl,'/',unittm,')'
        CALL printar(2,vy_node,lprnt2,fuvel,cnvvli,24,000)
     END IF
     WRITE(fuvel,2005) 'Z-direction - interstitial pore velocity ',  &
          'at nodes (',unitl,'/',unittm,')'
     CALL printar(2,vz_node,lprnt2,fuvel,cnvvli,24,000)
     ntprvel = ntprvel+1
  END IF
  IF(prmapv) THEN
     ! ... Write to file FUVMAP for visualization
     DO m=1,nxyz
        CALL mtoijk(m,i,j,k,nx,ny)
        IF(lprnt2(m) == 1) THEN
           indx = 1
           WRITE(fuvmap,8003) cnvli*x(i),ACHAR(9),cnvli*y(j),ACHAR(9),cnvli*z(k),  &
                ACHAR(9),cnvtmi*time,ACHAR(9),indx,ACHAR(9),cnvvli*vx_node(m),  &
                ACHAR(9),cnvvli*vy_node(m),ACHAR(9),cnvvli*vz_node(m),ACHAR(9)
8003       FORMAT(4(1pg15.6,a),i5,a,3(1pg15.6,a))
        ELSE
           indx = 0
           WRITE(fuvmap,8003) cnvli*x(i),ACHAR(9),cnvli*y(j),ACHAR(9),cnvli*z(k),  &
                ACHAR(9),cnvtmi*time,ACHAR(9),indx,ACHAR(9)
        END IF
     END DO
!!$        WRITE(fuvmap,5001) 
!!$5001    FORMAT(a,i5,a,1PG12.3,3A)
!!$        WRITE(fuvmap,5002) rxlbl//'-direction - interstitial pore velocity '
!!$5002    FORMAT(tr5,a80)
!!$        WRITE(fuvmap,5003) (cnvvli*vxx(m),m=1,nxyz)
!!$5003    FORMAT(11(1PG11.3))
!!$        IF(.NOT.cylind) THEN
!!$           WRITE(fuvmap,5002) 'Y-direction - interstitial pore velocity '
!!$           WRITE(fuvmap,5003) (cnvvli*vyy(m),m=1,nxyz)
!!$        END IF
!!$        WRITE(fuvmap,5002) 'Z-direction - interstitial pore velocity '
!!$        WRITE(fuvmap,5003) (cnvvli*vzz(m),m=1,nxyz)
     ntprmapv = ntprmapv+1
  END IF
!!$  ! ... Set the next time for printout if by user time units
!!$  timprtnxt=MIN(utimchg,timprbcf, timprcpd, timprgfb,  &
!!$       timprhdfh, timprhdfv, timprhdfcph,  &
!!$       timprkd, timprmapc, timprmaph, timprmapv, &
!!$       timprp, timprc, timprcphrq, timprfchem, timprslm, timprtem, timprvel, timprwel)

END SUBROUTINE write4
