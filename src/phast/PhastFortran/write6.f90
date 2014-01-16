SUBROUTINE write6
  ! ... Writes out the conductances and dispersive conductances
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
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE print_control_mod
  IMPLICIT NONE
  INCLUDE 'ifwr.inc'
  INTEGER :: m
  !     ------------------------------------------------------------------
  !...
  IF(prkd) THEN
     WRITE(fukd,2001) dash
     2001 FORMAT(tr1,a120)
     WRITE(fukd,2002) '*** Start of Time Step No. ',itime,' ***'
     2002 FORMAT(/tr40,a,i4,a)
     WRITE(fukd,2003) 'Properties evaluated at time ',cnvtmi*time,'('//unittm//')'
     2003 FORMAT(/tr20,a,tr3,1PG10.3,tr2,a)
     ntprkd = ntprkd+1
  END IF
  DO  m=1,nxyz
     IF(ibc(m) == -1) THEN
        lprnt1(m)=-1
     ELSE
        lprnt1(m)=1
     END IF
  END DO
  IF(prkd) THEN
     WRITE (fukd,2005) rxlbl//'-direction - Fluid Conductance between ',  &
          rxlbl//'(I) and ', rxlbl//'(I+1) (',unitm,'/',unittm,'-',unitp,')'
     2005 FORMAT(/tr25,10A)
     CALL printar(2,tfx,lprnt1,fukd,cnvcni,24,-100)
     IF(.NOT.cylind) THEN
        WRITE(fukd,2005) 'Y-direction - Fluid Conductance between Y(J) and ',  &
             'Y(J+1) (',unitm,'/',unittm,'-',unitp,')'
        CALL printar(2,tfy,lprnt1,fukd,cnvcni,24,-010)
     END IF
     WRITE(fukd,2005) 'Z-direction - Fluid Conductance between Z(K) and ',  &
          'Z(K+1) (',unitm,'/',unittm,'-',unitp,')'
     CALL printar(2,tfz,lprnt1,fukd,cnvcni,24,-001)
     IF(solute) THEN
        WRITE(fukd,2005) rxlbl//'-direction - Solute Dispersive Conductance ',  &
             'between ',rxlbl//'(I) and '//rxlbl//'(I+1) ('// unitm//'/'//unittm//')'
        CALL printar(2,tsx,lprnt1,fukd,cnvmfi,24,-100)
        IF(crosd) THEN
           IF(.NOT.cylind) THEN
              WRITE(fukd,2005) 'XY-direction - Solute Dispersive Conductance ',  &
                   'between X(I) and X(I+1) (',unitm,'/',unittm,')'
              CALL printar(2,tsxy,lprnt1,fukd,cnvmfi,24,-100)
           END IF
           WRITE(fukd,2005) rxlbl//'XZ-direction - Solute Dispersive Conductance ',  &
                'between '//rxlbl//'(I) and '//rxlbl//'(I+1) '// '(',unitm,'/',unittm,')'
           CALL printar(2,tsxz,lprnt1,fukd,cnvmfi,24,-100)
           IF(.NOT.cylind) THEN
              WRITE(fukd,2005) 'YX-direction - Solute Dispersive Conductance ',  &
                   'between Y(J) and Y(J+1) (',unitm,'/',unittm,')'
              CALL printar(2,tsyx,lprnt1,fukd,cnvmfi,24,-010)
           END IF
        END IF
        IF(.NOT.cylind) THEN
           WRITE(fukd,2005) 'Y-direction - Solute Dispersive Conductance ',  &
                'between Y(J) and Y(J+1) (',unitm,'/',unittm,')'
           CALL printar(2,tsy,lprnt1,fukd,cnvmfi,24,-010)
           IF(crosd) THEN
              WRITE(fukd,2005) 'YZ-direction - Solute Dispersive Conductance ',  &
                   'between Y(J) and Y(J+1) (',unitm,'/',unittm,')'
              CALL printar(2,tsyz,lprnt1,fukd,cnvmfi,24,-010)
           END IF
        END IF
        IF(crosd) THEN
           WRITE(fukd,2005) 'Z'//rxlbl//'-direction - Solute Dispersive '//  &
                'Conductance ', 'between Z(K) and Z(K+1) (',unitm,'/',unittm,')'
           CALL printar(2,tszx,lprnt1,fukd,cnvmfi,24,-001)
           IF(.NOT.cylind) THEN
              WRITE(fukd,2005) 'ZY-direction - Solute Dispersive Conductance ',  &
                   'between Z(K) and Z(K+1) (',unitm,'/',unittm,')'
              CALL printar(2,tszy,lprnt1,fukd,cnvmfi,24,-001)
           END IF
        END IF
        WRITE(fukd,2005) 'Z-direction - Solute Dispersive Conductance ',  &
             'between Z(K) and Z(K+1) (',unitm,'/',unittm,')'
        CALL printar(2,tsz,lprnt1,fukd,cnvmfi,24,-001)
     END IF
  END IF
!!$  ! ... Set the next time for printout if by user time units
!!$       timprtnxt=MIN(utimchg,timprbcf, timprcpd, timprgfb,  &
!!$            timprhdfh, timprhdfv, timprhdfcph,  &
!!$            timprkd, timprmapc, timprmaph, timprmapv, &
!!$            timprp, timprc, timprcphrq, timprfchem, timprslm, timprtem, timprvel, timprwel)
END SUBROUTINE write6
