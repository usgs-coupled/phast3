SUBROUTINE ldcir
  ! ... Loads the CIR, CIRL, CIRH index arrays for the generalized
  ! ...      conjugate gradient solver
  ! ... These arrays are pointers for the reduced matrix, RA
  USE mcs
  IMPLICIT NONE
  INTEGER :: ibn, ix, iy, j, k, kk
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: ldcir.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  DO  k=1,nbn
     cirl(1,k)=0
     cirh(1,k)=0
  END DO
  DO  k=1,nbn
     kk = nrn+k
     ! ... Lower level
     ix = ci(1,kk)
     IF (ix == 0) THEN
        DO  j=1,5
           cir(j,k) = 0
        END DO
     ELSE
        DO  j=1,5
           iy = ci(j,ix)
           IF (iy == 0) THEN
              cir(j,k) = 0
           ELSE
              ibn = iy-nrn
              cir(j,k) = ibn
              IF (ibn < k) THEN
                 cirl(1,k) = cirl(1,k)+1
                 cirl(cirl(1,k)+1,k) = j
              END IF
              IF (ibn > k) THEN
                 cirh(1,k) = cirh(1,k)+1
                 cirh(cirh(1,k)+1,k) = j
              END IF
           END IF
        END DO
     END IF
     ! ... Same level
     ix = ci(2,kk)
     IF (ix == 0) THEN
        DO  j=6,8
           cir(j,k) = 0
        END DO
     ELSE
        DO  j=2,4
           iy = ci(j,ix)
           IF (iy == 0) THEN
              cir(j+4,k) = 0
           ELSE
              ibn = iy-nrn
              cir(j+4,k) = ibn
              IF (ibn < k) THEN
                 cirl(1,k) = cirl(1,k)+1
                 cirl(cirl(1,k)+1,k) = j+4
              END IF
              IF (ibn > k) THEN
                 cirh(1,k) = cirh(1,k)+1
                 cirh(cirh(1,k)+1,k) = j+4
              END IF
           END IF
        END DO
     END IF
     ix = ci(3,kk)
     IF (ix == 0) THEN
        cir(9,k) = 0
     ELSE
        iy = ci(3,ix)
        IF (iy == 0) THEN
           cir(9,k) = 0
        ELSE
           ibn = iy-nrn
           cir(9,k) = ibn
           IF (ibn < k) THEN
              cirl(1,k) = cirl(1,k)+1
              cirl(cirl(1,k)+1,k) = 9
           END IF
           IF (ibn > k) THEN
              cirh(1,k) = cirh(1,k)+1
              cirh(cirh(1,k)+1,k) = 9
           END IF
        END IF
     END IF
     cir(10,k) = k
     ix = ci(4,kk)
     IF (ix == 0) THEN
        cir(11,k) = 0
     ELSE
        iy = ci(4,ix)
        IF (iy == 0) THEN
           cir(11,k) = 0
        ELSE
           ibn = iy-nrn
           cir(11,k) = ibn
           IF (ibn < k) THEN
              cirl(1,k) = cirl(1,k)+1
              cirl(cirl(1,k)+1,k) = 11
           END IF
           IF (ibn > k) THEN
              cirh(1,k) = cirh(1,k)+1
              cirh(cirh(1,k)+1,k) = 11
           END IF
        END IF
     END IF
     ix = ci(5,kk)
     IF (ix == 0) THEN
        DO  j=12,14
           cir(j,k) = 0
        END DO
     ELSE
        DO  j=3,5
           iy = ci(j,ix)
           IF (iy == 0) THEN
              cir(j+9,k) = 0
           ELSE
              ibn = iy-nrn
              cir(j+9,k) = ibn
              IF (ibn < k) THEN
                 cirl(1,k) = cirl(1,k)+1
                 cirl(cirl(1,k)+1,k) = j+9
              END IF
              IF (ibn > k) THEN
                 cirh(1,k) = cirh(1,k)+1
                 cirh(cirh(1,k)+1,k) = j+9
              END IF
           END IF
        END DO
     END IF
     ! ... Upper level
     ix = ci(6,kk)
     IF (ix == 0) THEN
        DO  j=15,19
           cir(j,k) = 0
        END DO
     ELSE
        DO  j=2,6
           iy = ci(j,ix)
           IF (iy == 0) THEN
              cir(j+13,k) = 0
           ELSE
              ibn = iy-nrn
              cir(j+13,k) = ibn
              IF (ibn < k) THEN
                 cirl(1,k) = cirl(1,k)+1
                 cirl(cirl(1,k)+1,k) = j+13
              END IF
              IF (ibn > k) THEN
                 cirh(1,k) = cirh(1,k)+1
                 cirh(cirh(1,k)+1,k) = j+13
              END IF
           END IF
        END DO
     END IF
  END DO
END SUBROUTINE ldcir
