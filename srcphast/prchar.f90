SUBROUTINE prchar(ndim,carray,lprnt,fu,nnoppr)
  ! ... Prints out slices of a character array with
  ! ...      selected format
  ! ... CARRAY - The full 3-dimensional array
  ! ... CNV - Factor for units conversion
  ! ... Selects layers or slices, single or multiple
  ! ... NNOPPR - Number of nodes or planes printed
  ! ...      For NDIM=1: Number of nodes printed
  ! ...      For NDIM=2:
  ! ...      -100 - NX-1 planes; -010 - NY-1 planes; -001 - NZ-1 planes
  ! ...       100 - One X-plane;010 - One Y-plane;001 - One Z-plane
  ! ...       000 - All planes printed
  USE mcc
  USE mcg
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: ndim
  CHARACTER(LEN=11), DIMENSION(:), INTENT(IN) :: carray
  INTEGER, DIMENSION(:), INTENT(IN) :: lprnt
  INTEGER, INTENT(IN) :: fu
  INTEGER, INTENT(IN) :: nnoppr
  !
  CHARACTER(LEN=1) :: blank = ' ', ir3lbl, rprn = ')'
  CHARACTER(LEN=11), DIMENSION(10) :: caprnt
  CHARACTER(LEN=2) :: cn3
  CHARACTER(LEN=4) :: i11x = ',11X'
  CHARACTER(LEN=84) :: iform
  CHARACTER(LEN=7) :: ii4 = '(I4,TR2'
  CHARACTER(LEN=6) :: na1
  INTEGER :: i, iir2, ior, ir2, ir3, ir3p, m, n1, n2, n3, nnpr, npr2,  &
       npr3, nxpr, nypr, nzpr
  LOGICAL :: prwin
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  iform = blank
  ior=MOD(ABS(orenpr),10)
  iform(1:)=ii4
  IF(ndim == 1) iform(1:)='(TR4,'
  na1(1:6) = ',A11'//'  '
  IF(ndim == 1) THEN
     nxpr=nnoppr
     npr3=1
  ELSE
     nxpr=nx
     IF(nnoppr/100 == -1) nxpr=nx-1
     nypr=ny
     IF(MOD(nnoppr,100)/10 == -1) nypr=ny-1
     IF(MOD(nnoppr,100)/10 == 1) nypr=1
     ! ... Print only one plane if one vertical slice
     !...     Suspended for now
     !...         IF(NY.EQ.2) NYPR=1
     nzpr=nz
     IF(MOD(nnoppr,10) == -1) nzpr=nz-1
     IF(MOD(nnoppr,10) == 1) nzpr=1
     IF(ior == 2) THEN
        ! ... Areal layers
        ir3lbl='K'
        npr3=nzpr
        npr2=nypr
        WRITE(fu,2001)
        2001    FORMAT(/tr20,'Areal Layers')
     ELSE IF(ior == 3) THEN
        ! ... Vertical slices
        ir3lbl='J'
        npr3=nypr
        npr2=nzpr
        WRITE(fu,2002)
        2002    FORMAT(/tr20,'Vertical Slices')
     END IF
  END IF
  DO  ir3=1,npr3
     IF(ndim == 1) GO TO 50
     nnpr=0
     DO  ir2=1,npr2
        DO  i=1,nxpr
           IF(ior == 2) m=(ir3-1)*nxy+(ir2-1)*nx+i
           IF(ior == 3) m=(ir2-1)*nxy+(ir3-1)*nx+i
           IF(lprnt(m) > 0) THEN
              nnpr=1
              EXIT
           END IF
        END DO
     END DO
     IF(nnpr == 0) CYCLE
     ir3p=ir3
     IF(MOD(nnoppr,10) == 1) ir3p=nz
     WRITE(fu,2003) ir3lbl,ir3p
     2003 FORMAT(/tr60,a1,' =',i3)
50   n1=1
     n2=10
60   n2=MIN(n2,nxpr)
     WRITE(fu,2004) (i,i=n1,n2)
     2004 FORMAT(/10I11)
     n3=n2-n1+1
     IF(ndim == 1) THEN
        WRITE(cn3,3001) n3
        3001    FORMAT(i2)
        DO  i=1,n3
           caprnt(i)(1:)=' '//carray(n1-1+i)(1:10)
        END DO
        iform(6:)=cn3//'('//na1(2:6)//'))'
        WRITE(fu,iform) (caprnt(i),i=1,n3)
     ELSE IF(ndim == 2) THEN
        prwin=.FALSE.
        DO  ir2=1,npr2
           iir2=npr2+1-ir2
           DO  i=1,n3
              IF(ior == 2) m=(ir3-1)*nxy+(iir2-1)*nx+n1-1+i
              IF(ior == 3) m=(iir2-1)*nxy+(ir3-1)*nx+n1-1+i
              IF(lprnt(m) > 0) prwin=.TRUE.
           END DO
        END DO
        IF(prwin) THEN
           DO  ir2=1,npr2
              iir2=ir2
              IF(orenpr > 0) iir2=npr2+1-ir2
              nnpr=0
              DO  i=1,n3
                 IF(ior == 2) m=(ir3-1)*nxy+(iir2-1)*nx+n1-1+i
                 IF(ior == 3) m=(iir2-1)*nxy+(ir3-1)*nx+n1-1+i
                 IF(lprnt(m) > 0) THEN
                    iform(8+(i-1)*6:)=na1
                    nnpr=nnpr+1
                    caprnt(nnpr)(1:)=' '//carray(m)(1:10)
                 ELSE
                    iform(8+(i-1)*6:)=i11x
                 END IF
              END DO
              IF(nnpr == 0) THEN
                 WRITE(fu,2005) iir2
                 2005 FORMAT(i4)
              ELSE
                 iform(8+n3*6:)=rprn
                 WRITE(fu,iform) iir2,(caprnt(i),i=1,nnpr)
              END IF
           END DO
        END IF
     END IF
     IF(n2 == nxpr) CYCLE
     n1=n1+10
     n2=n2+10
     WRITE(fu,2006)
     2006 FORMAT(/)
     GO TO 60
  END DO
  WRITE(fu,2006)
END SUBROUTINE prchar
