SUBROUTINE etom2  
  ! ... Converts time varying data at time of change during simulation
  ! ...      from U.S. customary to metric units
  USE mcb
  USE mcc
  USE mcg
  USE mcp
  USE mcv
  USE mg3
  IMPLICIT NONE
  INTEGER :: iis, m, mt  
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Specified fluid flux b.c. - input by x,y,z range
  IF(nfbc > 0) THEN  
     ! ... If any flux node values are read, all flux nodes must be read
     IF(RDFLXQ) THEN  
        DO  M = 1, NXYZ  
           qff(m) = cnvff*qff(m)
!           QFFX(M) = CNVFF* QFFX(M)  
!           QFFY(M) = CNVFF* QFFY(M)  
!           QFFZ(M) = CNVFF* QFFZ(M)  
        END DO
     ENDIF
     ! ... Heat and solute diffusive fluxes for no flow b.c.
!!$     IF(RDFLXH) THEN  
!!$        DO  M = 1, NXYZ  
!!$           QHFX(M) = CNVHF* QHFX(M)  
!!$           QHFY(M) = CNVHF* QHFY(M)  
!!$           QHFZ(M) = CNVHF* QHFZ(M)  
!!$        END DO
!!$     ENDIF
     IF(RDFLXS) THEN  
        do  iis = 1, ns  
           DO  M = 1, NXYZ  
              QSFX(M, IIS) = CNVSF* QSFX(M, IIS)  
              QSFY(M, IIS) = CNVSF* QSFY(M, IIS)  
              QSFZ(M, IIS) = CNVSF* QSFZ(M, IIS)  
           END DO
        end do
     ENDIF
  ENDIF
  ! ... Aquifer or river leakage b.c.
  ! ... Evapotranspiration b.c.
!!$  IF(NETBC.GT.0.AND.RDETBC) THEN  
!!$     DO  MT = 1, NXY  
!!$        UQETB(NXYZ - NXY + MT) = CNVFF* UQETB(NXYZ - NXY + MT)  
!!$     END DO
!!$  ENDIF
END SUBROUTINE etom2
