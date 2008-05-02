SUBROUTINE indx_rewi(ipar1,ipar2,par3,ip,icall,ier)
  ! ... Reads, writes, and unpacks the integer data representing
  ! ... icall=03 initial solutions
  ! ... icall=113 ass. solution for specified pressure
  ! ... icall=13 specified concentration
  ! ... icall=213 ass. solution for specified flux
  ! ... icall=313 ass. solution for leakage
  ! ... icall=513 ass. solution for river leakage
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  IMPLICIT NONE
  INTEGER, DIMENSION(:,:), INTENT(INOUT) :: ipar1, ipar2
  REAL(KIND=kdp), DIMENSION(:,:), INTENT(INOUT) :: par3
  INTEGER, INTENT(IN) :: ip
  INTEGER, INTENT(IN) :: icall, ier
  INTERFACE
     SUBROUTINE incidx(x1,x2,nx,xs,i1,i2,erflg)
       USE machine_constants, ONLY: kdp
       REAL(KIND=KDP), INTENT(IN) :: x1, x2
       INTEGER, INTENT(IN) :: nx
       REAL(KIND=KDP), dimension(:), INTENT(IN) :: xs
       INTEGER, INTENT(OUT) :: i1, i2
       LOGICAL, INTENT(INOUT) :: erflg
     END SUBROUTINE incidx
  END INTERFACE
  !
  CHARACTER(LEN=130), EXTERNAL :: uppercase
  CHARACTER(LEN=130) :: line
  REAL(kind=kdp) :: x1, x2, y1, y2, z1, z2
  REAL(kind=kdp) ::  var3
!!$  REAL(kind=kdp), DIMENSION(2,1) :: fs
!!$  REAL(kind=kdp), DIMENSION(2) :: xs
!!$  REAL(kind=kdp), DIMENSION(1) :: ys
  INTEGER :: i, i1, i2, ic, ivar1, ivar2,  &
       j, j1, j2, k, k1, k2, m, m1, m2
  INTEGER, DIMENSION(3) :: imod
  LOGICAL :: erflg
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF(icall == 03.AND.ip == 1) THEN
     if (print_rde) WRITE(furde,2001)
2001 FORMAT(/tr5,  &
          '**Initial Conditions-Solutions** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('.'))
  ELSE IF(icall == 03.AND.ip == 2) THEN
     if (print_rde) WRITE(furde,2002)
2002 FORMAT(/tr5, '**Initial Conditions-Phases** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('.'))
  ELSE IF(icall == 03.AND.ip == 3) THEN
     if (print_rde) WRITE(furde,2003)
2003 FORMAT(/tr5,  &
          '**Initial Conditions-Exchange** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('.'))
  ELSE IF(icall == 03.AND.ip == 4) THEN
     if (print_rde) WRITE(furde,2004)
2004 FORMAT(/tr5, '**Initial Conditions-Surface** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('.'))
  ELSE IF(icall == 03.AND.ip == 5) THEN
     if (print_rde) WRITE(furde,2005)
2005 FORMAT(/tr5, '**Initial Conditions-Gas** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('.'))
  ELSE IF(icall == 03.AND.ip == 6) THEN
     if (print_rde) WRITE(furde,2015)
2015 FORMAT(/tr5,  &
          '**Initial Conditions-Solid Phases** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('.'))
  ELSE IF(icall == 03.AND.ip == 7) THEN
     if (print_rde) WRITE(furde,2025)
2025 FORMAT(/tr5,  &
          '**Initial Conditions-Kinetics** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('.'))
  END IF
  if (print_rde) WRITE(furde,2006) 'Modification code: 1-replace, ',  &
       '2-multiply, 3-add, 4-node-by-node, 5-linear interpolate'
2006 FORMAT(/tr5,2A/(tr18,2A/))
11 READ(fuins,'(a)') line  
  line = uppercase(line)
  ic=INDEX(line(1:20),'END')
  IF(ic > 0) GO TO 70
  READ(line,*) x1,x2,y1,y2,z1,z2
  ! ... Read the modification data
  READ(fuins,*) ivar1,imod(1),ivar2,imod(2),var3,imod(3)
  ! ... Echo write the mods
  if (print_rde) WRITE(furde,2008) x1,x2,y1,y2,z1,z2,ip,  &
       ivar1,imod(1),ivar2,imod(2),var3,imod(3)
2008 FORMAT(tr1,6(1PG11.3),tr5,i3/tr3,2I4,tr2,2I4,tr2,0Pf5.1,i4)
  !      X1=CNVL*X1
  !      X2=CNVL*X2
  !      Y1=CNVL*Y1
  !      Y2=CNVL*Y2
  !      Z1=CNVL*Z1
  !      Z2=CNVL*Z2
  j1=1
  j2=1
  erflg=.FALSE.
  CALL incidx(x1,x2,nx,x,i1,i2,erflg)
  IF(.NOT.cylind) CALL incidx(y1,y2,ny,y,j1,j2,erflg)
  CALL incidx(z1,z2,nz,z,k1,k2,erflg)
  ! ... Error check
  IF(erflg) ierr(ier)=.TRUE.
  !      IF(I2.GT.NX.OR.I1.GT.I2) IERR(IER)=.TRUE.
  !      IF(J1.LT.0.OR.J2.GT.NY.OR.J1.GT.J2) IERR(IER)=.TRUE.
  !      IF(K1.LT.0.OR.K2.GT.NZ.OR.K1.GT.K2) IERR(IER)=.TRUE.
  IF(imod(1) /= 1.AND.imod(1) /= 4) ierr(ier)=.TRUE.
  IF(imod(1) == 1) THEN
     ! ... Install the mods
     DO  k=k1,k2
        DO  j=j1,j2
           DO  i=i1,i2
              m=cellno(i,j,k)
              ipar1(ip,m)=ivar1
              ipar2(ip,m)=ivar2
              par3(ip,m)=var3
           END DO
        END DO
     END DO
  ELSE IF(imod(1) == 4) THEN
     ! ... Node by node input (must be line by line)
     m1=1
     m2=nxyz
     READ(fuins,*) (ipar1(ip,m), m=m1,m2)
     if (print_rde) WRITE(furde,2012) 'IP =',ip,m1,' -',m2,(ipar1(ip,m),m=m1,m2)
2012 FORMAT(tr1,a,i3,tr5,i6,a,i6/(10I8))
     READ(fuins,*) (ipar2(ip,m), m=m1,m2)
     if (print_rde) WRITE(furde,2012) 'IP =',ip,m1,' -',m2,(ipar2(ip,m),m=m1,m2)
     READ(fuins,*) (par3(ip,m), m=m1,m2)
     if (print_rde) WRITE(furde,2013) 'IP =',ip,m1,' -',m2,(par3(ip,m),m=m1,m2)
2013 FORMAT(tr1,a,i3,tr5,i6,a,i6/(10F8.1))
  END IF
  GO TO 11
70 CONTINUE
END SUBROUTINE indx_rewi
