SUBROUTINE ldipen
  ! ... Loads the IPENV pointer array for the RA reduced matrix
  ! ... Used to generate the envelope storage
  USE mcs
  IMPLICIT NONE
  INTEGER :: ibn, ibncol, ic, idiff, jc, jrnrow, ma, mm
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: ldipen.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  ipenv(1)=1
  ibn=0
  DO  ma=nrn+1,nd4n
     ibn=ibn+1
     ! ... Find minimum black-node column less than or equal to the
     ! ...      black-node row
     mm=ma
     DO  ic=1,6
        jrnrow=ci(ic,ma)
        IF(jrnrow > 0) THEN
           DO  jc=1,6
              ibncol=ci(jc,jrnrow)
              IF(ibncol > 0) mm=MIN(ibncol,mm)
           END DO
        END IF
     END DO
     idiff=ibn-(mm-nrn)
     ipenv(ibn+1)=ipenv(ibn)+idiff
  END DO
END SUBROUTINE ldipen
