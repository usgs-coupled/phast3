SUBROUTINE prntar(ndim,array,lprnt,fu,cnv,ifmt,nnoppr)
  ! ... Prints out the contents of 2-dimensional array with selected
  ! ...      format
  ! ... ARRAY - The full 3-dimensional array
  ! ... CNV - Factor for units conversion
  ! ... Selects layers or slices, single or multiple
  ! ... NNOPPR - Number of nodes or planes printed
  ! ...      for NDIM=1
  ! ...      number of nodes printed
  ! ...      for NDIM=2
  ! ...      -100 - NX-1 planes; -010 - NY-1 planes; -001 - NZ-1 planes
  ! ...      100 - One X-plane; 010 - One Y-plane; 001 - One Z-plane
  ! ...      000 - All planes printed
  USE machine_constants, ONLY: kdp
  USE mcc
  USE mcg
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: ndim
  REAL(kind=kdp), DIMENSION(:), INTENT(IN) :: array
  INTEGER, DIMENSION(:), INTENT(IN) :: lprnt
  INTEGER, INTENT(IN) :: fu
  REAL(kind=kdp), INTENT(IN) :: cnv
  INTEGER, INTENT(IN) :: ifmt
  INTEGER, INTENT(IN) :: nnoppr
  !
  CHARACTER(LEN=9) :: form
  CHARACTER(LEN=9), DIMENSION(8) :: aform = (/'  (F12.0)','  (F12.1)','  (F12.2)','  (F12.3)',  &
       '  (F12.4)','  (F12.5)','(1PG12.4)','(1PG12.5)'/)
  CHARACTER(LEN=12), DIMENSION(10) :: caprnt
  CHARACTER(LEN=1) :: ir3lbl
  CHARACTER(LEN=12) :: sp12 = '            '
  REAL(kind=kdp), DIMENSION(10) :: aprnt
  INTEGER :: i, iifmt, iir2, ior, ir2, ir3, ir3p, m, n1, n2, n3, nnpr,  &
       npr2, npr3, nxpr, nypr, nzpr
  LOGICAL :: prwin
  ! ... ORENPR: 12 - Areal layers; 13 - Vertical slices
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: prntar.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  ior=MOD(ABS(orenpr),10)
  IF(ifmt == 10) iifmt=1
  IF(ifmt == 11) iifmt=2
  IF(ifmt == 12) iifmt=3
  IF(ifmt == 13) iifmt=4
  IF(ifmt == 14) iifmt=5
  IF(ifmt == 15) iifmt=6
  IF(ifmt == 24) iifmt=7
  IF(ifmt == 25) iifmt=8
  FORM=aform(iifmt)
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
     !         IF(NY.EQ.2) NYPR=1
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
     IF(ndim == 1) GO TO 40
     nnpr=0
     DO  ir2=1,npr2
        DO  i=1,nxpr
           IF(ior == 2) m=(ir3-1)*nxy+(ir2-1)*nx+i
           IF(ior == 3) m=(ir2-1)*nxy+(ir3-1)*nx+i
           IF(lprnt(m) == 1) THEN
              nnpr=1
              EXIT
           END IF
        END DO
     END DO
     IF(nnpr == 0) CYCLE
     ir3p=ir3
     IF(MOD(nnoppr,10) == 1) ir3p=nz
     WRITE(fu,2003) ir3lbl,' =',ir3p
     2003 FORMAT(/tr60,a1,a,i3)
40   n1=1
     n2=10
50   n2=MIN(n2,nxpr)
     WRITE(fu,2004) (i,i=n1,n2)
     2004 FORMAT(/i12,9I12)
     n3=n2-n1+1
     IF(ndim == 1) THEN
        DO  i=1,n3
           aprnt(i)=cnv*array(n1-1+i)
           WRITE(caprnt(i),FORM) aprnt(i)
        END DO
        WRITE(fu,2005) (caprnt(i),i=1,n3)
        2005    FORMAT(tr3,10A12)
     ELSE IF(ndim == 2) THEN
        prwin=.FALSE.
        DO  ir2=1,npr2
           iir2=npr2+1-ir2
           DO  i=1,n3
              IF(ior == 2) m=(ir3-1)*nxy+(iir2-1)*nx+n1-1+i
              IF(ior == 3) m=(iir2-1)*nxy+(ir3-1)*nx+n1-1+i
              IF(lprnt(m) == 1) THEN
                 prwin=.TRUE.
                 EXIT
              END IF
           END DO
        END DO
        IF(prwin) THEN
           DO  ir2=1,npr2
              iir2=npr2+1-ir2
              DO  i=1,n3
                 IF(ior == 2) m=(ir3-1)*nxy+(iir2-1)*nx+n1-1+i
                 IF(ior == 3) m=(iir2-1)*nxy+(ir3-1)*nx+n1-1+i
                 IF(lprnt(m) == 1) THEN
                    aprnt(i)=cnv*array(m)
                    WRITE(caprnt(i),FORM) aprnt(i)
                 ELSE
                    WRITE(caprnt(i),3001) sp12
                    3001 FORMAT(a12)
                 END IF
              END DO
              IF(nnpr == 0) THEN
                 WRITE(fu,2006) iir2
                 2006 FORMAT(i3)
              ELSE
                 WRITE(fu,2007) iir2,(caprnt(i),i=1,n3)
                 2007 FORMAT(i3,10a12)
              END IF
           END DO
        END IF
     END IF
     IF(n2 == nxpr) CYCLE
     n1=n1+10
     n2=n2+10
     WRITE(fu,2008)
     2008 FORMAT(/)
     GO TO 50
  END DO
  WRITE(fu,2008)
END SUBROUTINE prntar
