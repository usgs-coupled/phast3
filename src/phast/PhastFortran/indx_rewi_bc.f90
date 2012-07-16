SUBROUTINE indx_rewi_bc(ipar1,ipar2,par3,ip,icall,ier)
  ! ... Reads, writes, and unpacks the integer and real data representing
  ! ... icall=113 associated solution for specified pressure
  ! ... icall=13 specified concentration
  ! ... icall=213 associated solution for specified flux
  ! ... icall=313 associated solution for leakage
  ! ... icall=513 associated solution for river leakage
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  IMPLICIT NONE
  INTRINSIC INDEX
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
     FUNCTION uppercase(string) RESULT(outstring)
       IMPLICIT NONE
       CHARACTER(LEN=*), INTENT(IN) :: string
       CHARACTER(LEN=LEN(string)) :: outstring
     END FUNCTION uppercase
  END INTERFACE
  !
  INTEGER :: a_err, da_err, i, i1, i2, ic, imod, j, j1, j2, k, k1, k2, m, m1, m2, ms, nxyzs
!!$  CHARACTER(LEN=2) :: cicall
!$$  CHARACTER(LEN=130), EXTERNAL :: uppercase
  CHARACTER(LEN=130) :: line
  REAL(kind=kdp) :: x1, x2, y1, y2, z1, z2
  LOGICAL :: erflg
  INTEGER, DIMENSION(:), ALLOCATABLE :: uipar1, uipar2
  REAL(kind=kdp), DIMENSION(:), ALLOCATABLE :: upar
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ALLOCATE (uipar1(nxyz), uipar2(nxyz), upar(nxyz), &
       stat = a_err)
  IF (a_err.NE.0) THEN  
     PRINT *, "Array allocation failed: indx_rewi_bc"  
     STOP  
  ENDIF
  IF(icall == 113) THEN
     if (print_rde) WRITE(furde,2001)
2001 FORMAT(/tr5, '**Specified Head Boundary Conditions-',  &
          'Associated Solutions** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('-'))
  ELSE IF(icall == 13) THEN
     if (print_rde) WRITE(furde,2002)
2002 FORMAT(/tr5, '**Specified Concentration Boundary Conditions** ',  &
          '(Read Echo,[2.15])'/ tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('-'))
  ELSE IF(icall == 213) THEN
     if (print_rde) WRITE(furde,2003)
2003 FORMAT(/tr5, '**Specified Flux Boundary Conditions-',  &
          'Associated Solutions** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('-'))
  ELSE IF(icall == 313) THEN
     if (print_rde) WRITE(furde,2004)
2004 FORMAT(/tr5, '**Leakage Boundary Conditions-',  &
          'Associated Solutions** (Read Echo,[2.15])'/  &
          tr35,'Region',tr30,'     Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,80('-'))
  END IF
  if (print_rde) WRITE(furde,2106) 'Modification code: 1-replace, ',  &
       '2-multiply, 3-add, 4-node-by-node, 5-linear interpolate'
2106 FORMAT(/tr5,2A/(tr18,2A/))
11 READ(fuins,'(a)') line  
  line = uppercase(line)
  ic=INDEX(line(1:20),'END')
  IF(ic > 0) GO TO 99
  READ(line,*) x1,x2,y1,y2,z1,z2
  ! ... Read the data; always node by node
!  READ(fuins,*) ipar1(1,1),imod       ! after spbc, ipar1(1,1) has information, can't overwrite
  READ(fuins,*) j1, imod
  ! ... Echo write the data
  if (print_rde) WRITE(furde,2008) x1,x2,y1,y2,z1,z2,ip,imod
2008 FORMAT(tr1,6(1PG11.4),tr5,2I6)
  x1=cnvl*x1
  x2=cnvl*x2
  y1=cnvl*y1
  y2=cnvl*y2
  z1=cnvl*z1
  z2=cnvl*z2
  j1=1
  j2=1
  erflg=.FALSE.
  CALL incidx(x1,x2,nx,x,i1,i2,erflg)
  IF(.NOT.cylind) CALL incidx(y1,y2,ny,y,j1,j2,erflg)
  CALL incidx(z1,z2,nz,z,k1,k2,erflg)
  ! ... Error check
  IF(erflg) ierr(ier)=.TRUE.
  IF(i2 > nx .OR. i1 > i2) ierr(ier)=.TRUE.
  IF(j1 < 0 .OR. j2 > ny .OR. j1 > j2) ierr(ier)=.TRUE.
  IF(k1 < 0 .OR. k2 > nz .OR. k1 > k2) ierr(ier)=.TRUE.
  IF(imod /= 4) ierr(ier)=.TRUE.
  ! ... Unpack the data
  IF(imod == 4) THEN
     ! ... Node by node input
     nxyzs=(i2-i1+1)*(j2-j1+1)*(k2-k1+1)
     ! ... Read data for entire subregion of nodes
     ! ... Each of the three parameters is read in turn
     READ(fuins,*) (uipar1(ms),ms=1,nxyzs)
     READ(fuins,*) (uipar2(ms),ms=1,nxyzs)
     READ(fuins,*) (upar(ms),ms=1,nxyzs)
     ! ... Install the data
     ms=0
     DO  k=k1,k2
        DO  j=j1,j2
           DO  i=i1,i2
              ms=ms+1
              m=cellno(i,j,k)
              ipar1(ip,m)=uipar1(ms)
              ipar2(ip,m)=uipar2(ms)
              par3(ip,m)=upar(ms)
           END DO
        END DO
     END DO
     DO  k=k1,k2
        DO  j=j1,j2
           !               DO 80 I=I1,I2
           m1=cellno(i1,j,k)
           m2=cellno(i2,j,k)
           if (print_rde) WRITE(furde,2018) 'ip =',ip,m1,' -',m2, (ipar1(ip,m),m=m1,m2)
2018       FORMAT(tr1,a,i3,tr5,i6,a,i6/(10I8))
           !   80          CONTINUE
        END DO
     END DO
     DO  k=k1,k2
        DO  j=j1,j2
           !               DO 110 I=I1,I2
           m1=cellno(i1,j,k)
           m2=cellno(i2,j,k)
           if (print_rde) WRITE(furde,2018) 'ip =',ip,m1,' -',m2, (ipar2(ip,m),m=m1,m2)
           !  110          CONTINUE
        END DO
     END DO
     DO  k=k1,k2
        DO  j=j1,j2
           !               DO 140 I=I1,I2
           m1=cellno(i1,j,k)
           m2=cellno(i2,j,k)
           if (print_rde) WRITE(furde,2019) 'ip =',ip,m1,' -',m2, (par3(ip,m),m=m1,m2)
           2019       FORMAT(tr1,a,i3,tr5,i6,a,i6/(10F8.1))
           !  140          CONTINUE
        END DO
     END DO
  END IF
  GO TO 11
99 continue
  DEALLOCATE (uipar1, uipar2, upar, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: indx_rewi_bc"  
     STOP  
  ENDIF
  RETURN
END SUBROUTINE indx_rewi_bc
