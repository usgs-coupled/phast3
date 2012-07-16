SUBROUTINE XP_etom2(xp)
  ! ... Converts time varying data at time of change during simulation
  ! ...      from U.S. customary to metric units
  USE mcb
  USE mcc
  USE mcp
  USE XP_module
  IMPLICIT NONE
  TYPE (Transporter) :: xp
  INTEGER :: ls
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id: XP_etom2.f90,v 1.2 2011/01/19 17:50:19 klkipp Exp $'
  !     ------------------------------------------------------------------
  !...
  ! ... Specified fluid flux b.c. - input by segment number
  IF(nfbc > 0) THEN  
     ! ... If any flux segment values are read, all flux segments must be read
     IF(rdflxq) THEN
        DO  ls=1,nfbc_seg
!$$           qfflx(ls) = cnvff*qfflx(ls)
        END DO
     ENDIF
     ! ... Solute diffusive fluxes for no flow b.c.
     IF(rdflxs) THEN
        DO  ls=1,nfbc_seg
           xp%qsflx(ls) = cnvsf*xp%qsflx(ls)
        END DO
     ENDIF
  ENDIF
  ! ... Aquifer or river leakage b.c.
  ! ... Drain b.c.
END SUBROUTINE XP_etom2
