MODULE rewi_mod
  ! ... Reads, error checks, writes, and unpacks integer, real, or
  ! ...     a triple of real data arrays
  ! ... This module works only with full mesh arrays dimensioned nxyz
  USE machine_constants, ONLY: kdp
  USE f_units, ONLY:furde, fuins, print_rde
  USE mcc
  USE mcch
  USE mcg
  USE mcn
  USE mcp
  USE mct
  USE interpolate_mod
  IMPLICIT NONE
  INTERFACE rewi
     MODULE PROCEDURE irewi, rewi1, rewi3
  END INTERFACE
!$$  CHARACTER(LEN=130), EXTERNAL, PRIVATE :: uppercase
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80), PRIVATE :: ident_string=  &
       '$RCSfile: rewi_mod.f90,v $//$Revision: 1.3 $//$Date: 2008/10/03 23:07:56 $'
  PRIVATE :: irewi, rewi1, rewi3
CONTAINS

  SUBROUTINE rewi1(par,icall,ier)
    ! ... Reads, error checks, writes, and unpacks the real data
    IMPLICIT NONE
    INTRINSIC INDEX, NINT  
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: par
    INTEGER, INTENT(IN) :: icall
    INTEGER, INTENT(IN) :: ier
    INTERFACE
       SUBROUTINE incidx(x1,x2,nx,xs,i1,i2,erflg)
         USE machine_constants, ONLY: kdp
         IMPLICIT NONE
         REAL(KIND=KDP), INTENT(IN) :: x1, x2
         INTEGER, INTENT(IN) :: nx
         REAL(KIND=KDP), DIMENSION(:), INTENT(IN) :: xs
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
    CHARACTER(LEN=16), DIMENSION(0:9) :: label = (/ 'Potential Energy', &
         'Pressure        ', 'W.T. Elev.      ', &
         'Temperature     ', 'Mass Fraction   ', 'Density         ', 'Flow            ', &
         'Heat            ', &
         'Solute          ', 'Viscosity       '/)
    CHARACTER(LEN=130) :: line
    INTEGER :: a_err, da_err, i, i1, i2, ic, idir, imod, j, j1, j2, k, k1, k2, m, m1, &
         m2, ms, nxyzs
    LOGICAL :: erflg  
    REAL(KIND=kdp) :: var, x1, x2, y1, y2, z1, z2
    REAL(KIND=kdp), DIMENSION(2) :: xs
    REAL(KIND=kdp), DIMENSION(2) :: fs
    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: upar
    ! ----------------------------------------------------------------------------
    !...
    IF (print_rde) THEN
       IF(icall == 41) THEN
          WRITE(furde,2001)
2001      FORMAT(/tr5,  &
               '** Aquifer Influence Functions ** (read echo,[2.18.2])'/  &
               tr35,'Region',tr13,'Face Factor',tr5,'Modification Code'/  &
               tr6,'X1         X2         Y1         Y2         ',  &
               'Z1         Z2'/tr1,95('-'))
       ELSE IF(icall/100 == 1) THEN
          WRITE(furde,2002) label(MOD(icall,10))
2002      FORMAT(/tr5,  &
               '** Aquifer Initial Conditions ** (read echo,[2.21.X])'/  &
               tr35,'Region',tr10,'m.c. - modification code', tr10,'B.C. Code'/tr6,  &
               'X1         X2         Y1         Y2         ',  &
               'Z1         Z2',tr8,a,tr3, 'm.c.'/tr1,95('-'))
       ELSE IF(icall == 51) THEN
          WRITE(furde,2003)
2003      FORMAT(/tr5,'** Thermal Diffusivity for Heat Conduction ',  &
               'B.C. at these Cells ** (read echo,[2.19.3])'/  &
               tr35,'Region',tr30,'B.C. Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2',tr5,  &
               'UDTHHC',tr10, 'Modification Code'/tr1,95('-'))
       ELSE IF(icall == 52) THEN
          WRITE(furde,2004)
2004      FORMAT(/tr5,'** Thermal Conductivity for Heat Conduction ',  &
               'B.C. at these Cells ** (read echo,[2.19.4])'/ tr35,'Region'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2',tr5,  &
               'UKHCBC',tr10, 'Modification Code'/tr1,95('-'))
       ELSE IF(icall == 31) THEN
          WRITE(furde,2005)
2005      FORMAT(/tr5,  &
               '** Aquifer Leakage Parameters ** (read echo,[3.5.X])'/  &
               tr35,'Region',tr13,'KLBC',tr10,'Modification Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
       ELSE IF(icall/10 == 33) THEN
          WRITE(furde,2006) '** Aquifer Leakage Parameters ** (read echo,[3.5.X])',  &
               'Region',label(MOD(icall,10)),'Modification Code',  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2',dash
2006      FORMAT(tr5,a/tr35,a,tr13,a,tr10,a/tr6,2A/tr1,a95)
       ELSE IF(icall/10 == 30) THEN
          WRITE(furde,2007) label(MOD(icall,10)), label(MOD(icall,10))
2007      FORMAT(/tr5, '** Specified ',a,' B.C. **  (read echo,[3.3.X])'/  &
               tr35,'Region',tr20,'m.c. - modification code'/tr10,  &
               'X1         X2         Y1         Y2         ',  &
               'Z1         Z2',tr10,a,'m.c.'/tr1,95('-'))
       ELSE IF(icall/10 == 31) THEN
          WRITE(furde,2008) '** ', label(MOD(icall,10)),  &
               ' for Inflow at Specified Pressure B.C. **  (read echo,', '[3.3.X])',  &
               label(MOD(icall,10))
2008      FORMAT(/tr5,4A/ tr35,'Region'/tr10,  &
               'X1         X2         Y1         Y2         ',  &
               'Z1         Z2',tr6,a,tr2,'m.c.'/tr1,95('-'))
       ELSE IF(icall/10 == 32) THEN
          WRITE(furde,2009) '** ', label(MOD(icall,10)),  &
               ' for Inflow at Specified Fluid Flux B.C. **  (read ', 'echo,[3.4.X])'  &
               ,label(MOD(icall,10))
2009      FORMAT(/tr5,a,a,a,a/  &
               tr35,'Region',tr25,'m.c. - modification code'/tr10,  &
               'X1         X2         Y1         Y2         ',  &
               'Z1         Z2',tr8,a,2X,'m.c.'/tr1,95('-'))
       ELSE IF(icall == 71) THEN
          WRITE(furde,2010) '** ', 'Flux',  &
               ' for Evapotranspiration B.C. **  (read ',  &
               'echo,[3.6.X])','Region','m.c. - modification code',  &
               'X1         X2         Y1         Y2         ',  &
               'Z1         Z2','QETBC','m.c.',dash
2010      FORMAT(/tr5,a,a,a,a/ tr35,a,tr25,a/tr10,2A,tr8,a,2X,a/tr1,a95)
       ELSE IF(icall/10 == 34) THEN
          WRITE(furde,2011) '** ',label(MOD(icall,10)),  &
               ' for Inflow at A.I.F. B.C. **  (read ','echo,[3.7.X])',  &
               label(MOD(icall,10))
2011      FORMAT(/tr5,a,a,a,a/  &
               tr5,'Region',tr40,'m.c. - modification code'/tr6,  &
               tr35,'Region',tr30,'B.C. Code'/tr6,  &
               'X1         X2         Y1         Y2         ',  &
               'Z1         Z2',tr5,a,tr2,'m.c.'/tr1,95('-'))
       END IF
       WRITE(furde,2012) 'Modification code: 1-replace, ',  &
            '2-multiply, 3-add, 4-node-by-node, 5-linear interpolate'
2012   FORMAT(tr5,2A/(tr18,2A/))
    END IF
10  READ(fuins,'(A)') line
    line = uppercase(line)
    ic=INDEX(line(1:20),'END')
    IF(ic > 0) GO TO 110
    READ(line,*) x1,x2,y1,y2,z1,z2
    ! ... Read the modification data
    READ(fuins,*) var,imod
    IF (print_rde) WRITE(furde,2013) x1,x2,y1,y2,z1,z2,var,imod
2013 FORMAT(tr5,6(1PG11.3),tr2,1PG12.4,tr5,i1)
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
    IF(k1 < 1 .OR. k2 > nz .OR. k1 > k2) ierr(ier)=.TRUE.
    IF(imod <= 0 .OR. imod > 5) ierr(ier)=.TRUE.
    IF(imod < 4) THEN
       ! ... Install the mods
       DO  k=k1,k2
          DO  j=j1,j2
             DO  i=i1,i2
                m=cellno(i,j,k)
                IF(imod == 1) par(m)=var
                IF(imod == 2) par(m)=par(m)*var
                IF(imod == 3) par(m)=par(m)+var
             END DO
          END DO
       END DO
    ELSE IF(imod == 4) THEN
       ! ... Node by node input
       nxyzs=(i2-i1+1)*(j2-j1+1)*(k2-k1+1)
       ! ... Allocate scratch space
       ALLOCATE (upar(nxyzs), &
            STAT = a_err)
       IF (a_err /= 0) THEN  
          PRINT *, "Array allocation failed: rewi"  
          STOP
       ENDIF
       ! ... Read data for entire subregion of nodes
       READ(fuins,*) (upar(ms),ms=1,nxyzs)
       ! ... Install the data into full nodal array space
       ms=0
       DO  k=k1,k2
          DO  j=j1,j2
             DO  i=i1,i2
                ms=ms+1
                m=cellno(i,j,k)
                par(m)=upar(ms)
             END DO
             m1=cellno(i1,j,k)
             m2=cellno(i2,j,k)
             IF (print_rde) WRITE(furde,2014) m1,' -',m2,(par(m),m=m1,m2)
2014         FORMAT(tr1,i6,a,i6/10(1PG12.4))
          END DO
       END DO
       DEALLOCATE (upar, &
            STAT = da_err)
       IF (da_err /= 0) THEN  
          PRINT *, "Array deallocation failed"  
          STOP  
       ENDIF
    ELSE IF(imod == 5) THEN
       ! ... Linear segment interpolation
       READ(fuins,*) xs(1),fs(1),xs(2),fs(2)
       IF (print_rde) WRITE(furde,2013) xs(1),fs(1),xs(2),fs(2)
       xs(1)=cnvl*xs(1)
       xs(2)=cnvl*xs(2)
       idir=NINT(var)
       erflg=.FALSE.
       DO  k=k1,k2
          DO  j=j1,j2
             DO  i=i1,i2
                m=cellno(i,j,k)
                IF(idir == 1) THEN
                   par(m)=interp(x(i),2,xs,fs)
                ELSE IF(idir == 2) THEN
                   par(m)=interp(y(j),2,xs,fs)
                ELSE IF(idir == 3) THEN
                   par(m)=interp(z(k),2,xs,fs)
                END IF
             END DO
          END DO
       END DO
       IF(erflg) THEN
          ierr(ier)=.TRUE.
          errexi=.TRUE.
       END IF
    END IF
    GO TO 10
110 RETURN
  END SUBROUTINE rewi1

  SUBROUTINE irewi(ipar,icall,ier)
    ! ... Reads, error checks, writes, and unpacks the integer data
    IMPLICIT NONE
    INTRINSIC INDEX
    INTEGER, DIMENSION(:), INTENT(INOUT) :: ipar
    INTEGER, INTENT(INOUT) :: icall
    INTEGER, INTENT(IN) :: ier
    INTERFACE
       SUBROUTINE incidx(x1,x2,nx,xs,i1,i2,erflg)
         USE machine_constants, ONLY: kdp
         REAL(KIND=KDP), INTENT(IN) :: x1, x2
         INTEGER, INTENT(IN) :: nx
         REAL(KIND=KDP), DIMENSION(:), INTENT(IN) :: xs
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
    CHARACTER(LEN=2) :: cicall
    CHARACTER(LEN=9) :: cpar
    CHARACTER(LEN=6) :: cpari
    CHARACTER(LEN=130) :: line
    INTEGER :: a_err, da_err, i, i1, i2, ib, ic, iface, imod, ipar1, ipar2, ipari, j, j1, j2,  &
         k, k1, k2, m, m1, m2, ms, nxyzs, uipars
    LOGICAL :: erflg
    INTEGER, DIMENSION(:), ALLOCATABLE :: uipar
    REAL(KIND=kdp) :: x1, x2, y1, y2, z1, z2
    ! ----------------------------------------------------------------------------
    !...
    IF (print_rde) THEN
       IF(icall == 1) THEN
          WRITE(furde,2001)
2001      FORMAT(/tr5,  &
               '** Specified Value B.C. Cells ** (read echo,[2.14])'/  &
               tr35,'Region',tr30,'B.C. Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
       ELSE IF(icall == 2) THEN
          WRITE(furde,2002)
2002      FORMAT(/tr5,  &
               '** Specified Flux B.C. Cells ** (read echo,[2.15])'/tr35,  &
               'Region',tr30,'B.C. Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
       ELSE IF(icall == 3) THEN
          WRITE(furde,2003)
2003      FORMAT(/tr5,'** Aquifer and River Leakage B.C. Cells ** ',  &
               '(read echo,[2.16.1])'/ tr35,'Region',tr30,'B.C. Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
       ELSE IF(icall == 4) THEN
          WRITE(furde,2004)
2004      FORMAT(/tr5,'** Aquifer Influence Function B.C. Cells ** ',  &
               '(read echo,[2.18.1])'/ tr35,'Region',tr30,'B.C. Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
       ELSE IF(icall == 5) THEN
          WRITE(furde,2005)
2005      FORMAT(/tr5,'** Heat Conduction B.C. Cells ** ',  &
               '(read echo,[2.19.1])'/ tr35,'Region',tr30,'B.C. Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
       ELSE IF(icall == 7) THEN
          WRITE(furde,2006)
2006      FORMAT(/tr5,'** Evapotranspiration B.C. Cells ** ',  &
               '(read echo,[2.17.1])'/ tr35,'Region',tr30,'B.C. Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
       ELSE IF(icall == 8) THEN
          WRITE(furde,2008)
2008      FORMAT(/tr5,'** Mesh sub zones for .chem.txt file ** ',  &
               '(read echo,[3.xxxx])'/ tr35,'Region',tr30,'Print Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
       ELSE IF(icall == 9) THEN
          WRITE(furde,2009)
2009      FORMAT(/tr5,'** Mesh sub zones for .chem.xyz.tsv file ** ',  &
               '(read echo,[3.xxxx])'/ tr35,'Region',tr30,'Print Code'/tr6,  &
               'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
       END IF
    END IF
    IF(icall == 5) icall=4
    WRITE(cicall,6001) icall
6001 FORMAT(i2)
10  READ(fuins,'(A)') line
    line = uppercase(line)
    ic=INDEX(line(1:20),'END')
    IF(ic > 0) GO TO 60
    READ(line,*) x1,x2,y1,y2,z1,z2
    ! ... Read the data
    IF(icall /= 8 .AND. icall /= 9 ) THEN
       READ(fuins,*) ipari
       ! ... Echo write the data
       IF (print_rde) WRITE(furde,2007) x1,x2,y1,y2,z1,z2,ipari
2007   FORMAT(tr1,6(1PG11.4),tr5,i6)
    ELSE
       READ(fuins,*) ipari, imod
       ! ... Echo write the data
       IF (print_rde) WRITE(furde,2017) x1,x2,y1,y2,z1,z2,ipari,imod
2017   FORMAT(tr1,6(1PG11.4),tr5,i6,tr5,i1)
    ENDIF
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
    IF(icall == 8 .OR. icall == 9) THEN
       ! ... Node by node input
       nxyzs = (i2 - i1 + 1)*(j2 - j1 + 1)*(k2 - k1 + 1)  
       ALLOCATE (uipar(nxyzs), &
            stat = a_err)
       IF (a_err /= 0) THEN  
          PRINT *, "Array allocation failed: rewi"  
          STOP
       ENDIF
       ! ... Read data for entire subregion of nodes
       READ(fuins,*) (uipar(ms),ms=1,nxyzs)  
       ! ... Install the data into full nodal array space
       ms = 0
       DO  k = k1, k2  
          DO  j = j1, j2  
             DO  i = i1, i2  
                ms = ms + 1  
                m = cellno(i,j,k)  
                ipar(m) = uipar(ms)  
             END DO
             m1 = cellno(i1,j,k)  
             m2 = cellno(i2,j,k)  
             IF (print_rde) WRITE(furde,2014) m1, '-', m2,(ipar(m),m=m1,m2)  
2014         FORMAT(tr1,i6,a,i6/10(1pg12.4))  
          END DO
       END DO
       DEALLOCATE (uipar, &
            stat = da_err)
       IF (da_err /= 0) THEN  
          PRINT *, "Array deallocation failed: irewi"  
          STOP  
       ENDIF
    ELSE
       WRITE(cpari,6002) ipari
6002   FORMAT(i6)
       ! ... Unpack the data
       DO  k=k1,k2
          DO  j=j1,j2
             DO  i=i1,i2
                m=cellno(i,j,k)
                IF(ipar(m) /= -1) THEN
                   iface=ipari/100000
                   IF(icall == 1) iface=1
                   WRITE(cpar,6004) ipar(m)
6004               FORMAT(i9.9)
!!$                DO  ib=1,9
!!$                   IF(cpar(ib:ib) == ' ') cpar(ib:ib)='0'
!!$                END DO
                   IF(cpari(4:4) == cicall(2:2)) THEN
                      IF((cpar(iface:iface) == '2' .AND. cpari(4:4) == '3')  &
                           .OR. (cpar(iface:iface) == '3' .AND. cpari(4:4)  == '2')) THEN
                         READ(cpar(iface:iface),6003) ipar1
                         READ(cpari(4:4),6003) ipar2
                         ipar1=ipar1+ipar2
                         WRITE(cpar(iface:iface),6003) ipar1
                      ELSE
                         cpar(iface:iface)=cpari(4:4)
                      END IF
                   END IF
                   IF(cpari(5:5) == cicall(2:2)) THEN
                      IF((cpar(iface+3:iface+3) == '2' .AND. cpari(5:5) == '3') .OR.  &
                           (cpar(iface+3:iface+3) == '3' .AND. cpari(5:5) == '2')) THEN
                         READ(cpar(iface+3:iface+3),6003) ipar1
                         READ(cpari(5:5),6003) ipar2
6003                     FORMAT(i1)
                         ipar1=ipar1+ipar2
                         WRITE(cpar(iface+3:iface+3),6003) ipar1
                      ELSE
                         cpar(iface+3:iface+3)=cpari(5:5)
                      END IF
                   END IF
                   IF(cpari(6:6) == cicall(2:2)) THEN
                      IF((cpar(iface+6:iface+6) == '2' .AND. cpari(6:6) == '3') .OR.  &
                           (cpar(iface+6:iface+6) == '3' .AND. cpari(6:6) == '2')) THEN
                         READ(cpar(iface+6:iface+6),6003) ipar1
                         READ(cpari(6:6),6003) ipar2
                         ipar1=ipar1+ipar2
                         WRITE(cpar(iface+6:iface+6),6003) ipar1
                      ELSE
                         cpar(iface+6:iface+6)=cpari(6:6)
                      END IF
                   END IF
                   READ(cpar,6004) uipars
                   ipar(m)=uipars
                END IF
             END DO
          END DO
       END DO
    END IF
    GO TO 10
60  RETURN
  END SUBROUTINE irewi
  
  SUBROUTINE rewi3(par1,par2,par3,icall,ier)
    ! ... Reads, error checks, writes, and unpacks the real data for groups
    ! ...      of three variables
    IMPLICIT NONE
    REAL(KIND=kdp), DIMENSION(:), INTENT(INOUT) :: par1, par2, par3
    INTEGER, INTENT(IN) :: icall, ier
    INTERFACE
       SUBROUTINE incidx(x1,x2,nx,xs,i1,i2,erflg)
         USE machine_constants, ONLY: kdp
         REAL(KIND=KDP), INTENT(IN) :: x1, x2
         INTEGER, INTENT(IN) :: nx
         REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: xs
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
    INTRINSIC INDEX
    CHARACTER(LEN=6), DIMENSION(3) :: label=(/'Flow  ','Heat  ','Solute'/)
    CHARACTER(LEN=130) :: line
    INTEGER :: a_err, da_err, i, i1, i2, ic, iv, j, j1, j2, k, k1, k2, m, m1,  &
         m2, ms, nxyzs
    INTEGER, DIMENSION(3) :: imod
    LOGICAL :: erflg
    REAL(KIND=kdp) :: x1, x2, y1, y2, z1, z2
    REAL(KIND=kdp), DIMENSION(3) :: var
    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: upar1, upar2, upar3
    ! ----------------------------------------------------------------------------
    !...
    IF (print_rde) THEN
       IF(icall == 1) THEN
          WRITE(furde,2001)  &
               '** Aquifer Leakage Parameters  **  (read echo,[3.5.X])',  &
               'Region','m.c.- modification code',  &
               'X1       X2       Y1       Y2       Z1       Z2',  &
               'Potential','Density','Viscosity',  &
               '(',unitep,')','m.c.','(',unitm,'/',unitl,'^3)','m.c.',  &
               '(',unitvs,')','m.c.',dash
2001      FORMAT(/tr5,a/tr30,a,tr20,a/tr7,a/tr15,a,tr18,a,tr18,a/  &
               tr14,3A,tr5,a,tr6,5A,tr6,a,tr8,3A,tr8,a/tr1, a95)
       ELSE IF(icall >= 3.AND.icall <= 5) THEN
          WRITE(furde,2002) '** Specified Flux B.C.  **  (read echo,[3.4.X])',  &
               label(icall-2), 'Region','(Amt/'//unitl//'^2-'//unittm//')',  &
               'm.c. - modification code',  &
               'X1       X2       Y1       Y2       Z1       Z2',  &
               'QFX','m.c.','QFY','m.c.','QFZ','m.c.',dash
2002      FORMAT(/tr5,a,tr3,a/tr35,a,tr15,a,tr5,a/tr10,a/tr15,a,tr5,a,  &
               tr6,a,tr5,a,tr6,a,tr5,a/tr1,a95)
       ELSE IF(icall == 6.OR.icall == 7) THEN
          WRITE(furde,2003) '** Aquifer Initial Conditions - ',label(icall-5),  &
               '  (read echo,[2.21.X])',dash,  &
               'X1       X2       Y1       Y2       Z1       Z2', label(icall-5),dash
2003      FORMAT(/tr5,a,a10,a/tr5,a38/tr5,a,tr5,a10/tr5,a38)
       ELSE IF(icall == 31) THEN
          WRITE(furde,2004)  &
               '** Aquifer Leakage Parameters  **  (read echo,[2.16.2])',  &
               'Region','m.c. - modification code',  &
               'X1       X2       Y1       Y2       Z1       Z2',  &
               'Aquitard','Thickness','Elevation of','Permeability',  &
               'of Aquitard','Outer Boundary',  &
               '(',unitl,'^2)','m.c.','(',unitl,')','m.c.','(',unitl,')', 'm.c.',dash
2004      FORMAT(/tr5,a/tr30,a,tr20,a/tr7,a/tr15,a,tr12,a,tr12,a/tr13,a,  &
               tr8,a,tr10,a/ tr14,3A,tr5,a,tr6,3A,tr6,a,tr8,3A,tr8,a/tr1,  &
               a95)
       ELSE IF(icall == 71) THEN
          WRITE(furde,2005) '** Evapotranspiration Parameters  **',  &
               '(read echo,[2.17.2])', 'Region','m.c. - modification code',  &
               'X1       X2       Y1       Y2       Z1       Z2',  &
               'Land Surface','Depth to','      ', 'Elevation','Extinction','     ',  &
               '(',unitl,')','m.c.','(',unitl,')','m.c.',dash
2005      FORMAT(/tr5,a/tr30,a,tr20,a/tr7,a/tr15,a,tr12,a,tr12,a/tr13,a,  &
               tr8,a,tr10,a/ tr14,3A,tr5,a,tr6,3A,tr6,a/tr1,  &
               a95)
       END IF
       WRITE(furde,2006) 'Modification code: 1-replace, ',  &
            '2-multiply, 3-add, 4-node-by-node, 5-linear interpolate'
2006   FORMAT(/tr5,2A/(tr18,2A/))
    END IF
10  READ(fuins,'(A)') line
    line = uppercase(line)
    ic=INDEX(line(1:20),'END')
    IF(ic > 0) GO TO 170
    READ(line,*) x1,x2,y1,y2,z1,z2
    ! ... Read the modification data
    READ(fuins,*) (var(iv),imod(iv),iv=1,3)
    IF (print_rde) WRITE(furde,2007) x1,x2,y1,y2,z1,z2,(var(iv),imod(iv),iv=1,3)
2007 FORMAT(tr5,6(1PG11.3)/tr7,3(tr3,1PG13.5,tr3,i3))
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
    IF(j1 <= 0 .OR. j2 > ny .OR. j1 > j2) ierr(ier)=.TRUE.
    IF(k1 <= 0 .OR. k2 > nz .OR. k1 > k2) ierr(ier)=.TRUE.
    IF(imod(1) /= 4) THEN
       ! ... Install the mods
       DO  k=k1,k2
          DO  j=j1,j2
             DO  i=i1,i2
                m=cellno(i,j,k)
                IF(imod(1) == 1) par1(m)=var(1)
                IF(imod(2) == 1) par2(m)=var(2)
                IF(imod(3) == 1) par3(m)=var(3)
                IF(imod(1) == 2) par1(m)=par1(m)*var(1)
                IF(imod(2) == 2) par2(m)=par2(m)*var(2)
                IF(imod(3) == 2) par3(m)=par3(m)*var(3)
                IF(imod(1) == 3) par1(m)=par1(m)+var(1)
                IF(imod(2) == 3) par2(m)=par2(m)+var(2)
                IF(imod(3) == 3) par3(m)=par3(m)+var(3)
             END DO
          END DO
       END DO
    ELSE IF(imod(1) == 4) THEN
       ! ... Node by node input
       nxyzs=(i2-i1+1)*(j2-j1+1)*(k2-k1+1)
       ! ... Allocate scratch space
       ALLOCATE (upar1(nxyz), upar2(nxyz), upar3(nxyz), &
            STAT = a_err)
       IF (a_err /= 0) THEN  
          PRINT *, "Array allocation failed: rewi3"  
          STOP
       ENDIF
       ! ... Read data for entire subregion of nodes
       ! ... Each of the three parameters is read in turn
       READ(fuins,*) (upar1(ms),ms=1,nxyzs)
       READ(fuins,*) (upar2(ms),ms=1,nxyzs)
       READ(fuins,*) (upar3(ms),ms=1,nxyzs)
       ! ... Install the data
       ms=0
       DO  k=k1,k2
          DO  j=j1,j2
             DO  i=i1,i2
                ms=ms+1
                m=cellno(i,j,k)
                par1(m)=upar1(ms)
                par2(m)=upar2(ms)
                par3(m)=upar3(ms)
             END DO
          END DO
       END DO
       DO  k=k1,k2
          DO  j=j1,j2
             DO  i=i1,i2
                m1=cellno(i1,j,k)
                m2=cellno(i2,j,k)
                IF (print_rde) WRITE(furde,2008) m1,' -',m2,(par1(m),m=m1,m2)
2008            FORMAT(tr1,i6,a,i6/10(1PG12.4))
             END DO
          END DO
       END DO
       ! ... Deallocate scratch space
       DEALLOCATE (upar1, upar2, upar3, &
            STAT = da_err)
       IF (da_err /= 0) THEN  
          PRINT *, "Array deallocation failed"  
          STOP
       ENDIF
       DO  k=k1,k2
          DO  j=j1,j2
             DO  i=i1,i2
                m1=cellno(i1,j,k)
                m2=cellno(i2,j,k)
                IF (print_rde) WRITE(furde,2008) m1,' -',m2,(par2(m),m=m1,m2)
             END DO
          END DO
       END DO
       DO  k=k1,k2
          DO  j=j1,j2
             DO  i=i1,i2
                m1=cellno(i1,j,k)
                m2=cellno(i2,j,k)
                IF (print_rde) WRITE(furde,2008) m1,' -',m2,(par3(m),m=m1,m2)
             END DO
          END DO
       END DO
    END IF
    GO TO 10
170 RETURN
  END SUBROUTINE rewi3
  
END MODULE rewi_mod
