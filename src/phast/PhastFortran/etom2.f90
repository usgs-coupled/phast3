SUBROUTINE etom2  
  ! ... Converts time varying data at time of change during simulation
  ! ...      from U.S. customary to metric units
  USE mcb
  USE mcb_m
  USE mcc
  USE mcc_m
  USE mcg
  USE mcg_m
  USE mcp
  USE mcp_m
  USE mcv
  USE mcv_m
  USE mg3_m
  IMPLICIT NONE
  INTEGER :: iis, ls, m, mt  
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Specified fluid flux b.c. - input by segment number
  IF(nfbc > 0) THEN  
     ! ... If any flux segment values are read, all flux segments must be read
     IF(rdflxq) THEN
        DO  ls=1,nfbc_seg
           qfflx(ls) = cnvff*qfflx(ls)
        END DO
     ENDIF
     ! ... Solute diffusive fluxes for no flow b.c.
     IF(rdflxs) THEN
        DO  iis=1,ns  
           DO  ls=1,nfbc_seg
              qsflx(ls,iis) = cnvsf*qsflx(ls,iis)
           END DO
        END DO
     ENDIF
  ENDIF
  ! ... Aquifer or river leakage b.c.
  ! ... Drain b.c.
END SUBROUTINE etom2
