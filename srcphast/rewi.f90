SUBROUTINE rewi(par,icall,ier)  
  ! ... Reads, error checks, writes, and unpacks the real data
  USE machine_constants, ONLY: kdp
  USE f_units, only:furde, fuins, print_rde
  USE mcc
  USE mcch
  USE mcg
  USE mcn
  USE mcp
  USE mct
  IMPLICIT NONE
  INTRINSIC INDEX, NINT  
  REAL(KIND=kdp), DIMENSION(:), INTENT(OUT) :: par
  INTEGER, INTENT(IN) :: icall
  INTEGER, INTENT(IN) :: ier  
  INTERFACE
     SUBROUTINE incidx(x1,x2,nx,xs,i1,i2,erflg)
       USE machine_constants, ONLY: kdp
       REAL(KIND=KDP), INTENT(IN) :: x1, x2
       INTEGER, INTENT(IN) :: nx
       REAL(KIND=KDP), dimension(:), INTENT(IN) :: xs
       INTEGER, INTENT(OUT) :: i1, i2
       LOGICAL, INTENT(INOUT) :: erflg
     END SUBROUTINE incidx
     FUNCTION interp(ndim,xarg,yarg,nx,ny,xs,ys,fs,erflg)
       USE machine_constants, ONLY: bgint, kdp
       INTEGER, INTENT(IN) :: ndim
       REAL(KIND=KDP), INTENT(IN) :: xarg, yarg
       INTEGER, INTENT(IN) :: nx, ny
       REAL(KIND=KDP), DIMENSION(:), INTENT(IN) :: xs, ys
       REAL(KIND=KDP), DIMENSION(:,:), INTENT(IN) :: fs
       LOGICAL, INTENT(INOUT) :: erflg
       REAL(KIND=KDP) :: interp
     END FUNCTION interp
  END INTERFACE
  !
  CHARACTER(LEN=16), dimension(0:9) :: LABEL = (/ 'Potential Energy', &
       'Pressure        ', 'W.T. Elev.      ', &
       'Temperature     ', 'Mass Fraction   ', 'Density         ', 'Flow            ', &
       'Heat            ', &
       'Solute          ', 'Viscosity       '/)
  CHARACTER(LEN=80) :: LINE  
  REAL(KIND=kdp) :: var, x1, x2, y1, y2, z1, z2
  REAL(KIND=kdp), DIMENSION(2) :: xs
  REAL(KIND=kdp), DIMENSION(1) :: ys
  REAL(KIND=kdp), DIMENSION(2,1) :: fs
  INTEGER :: a_err, da_err, i, i1, i2, ic, idir, imod, j, j1, j2, k, k1, k2, m, m1, &
       m2, ms, nxyzs
  LOGICAL :: erflg  
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: upar
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF(icall == 1) THEN
     if (print_rde) WRITE(furde,2101)  &
          '** Aquifer Leakage Parameters  **  (read echo,[3.5.X])',  &
          'Region','m.c.- modification code',  &
          'X1       X2       Y1       Y2       Z1       Z2',  &
          'Potential','('//unitep//')','m.c.', dash
2101 FORMAT(/tr5,a/tr30,a,tr20,a/tr7,a,tr8,a,tr2,a,tr5,a/tr1,a95)
  ELSEIF(icall == 2) THEN
     if (print_rde) WRITE(furde,2101)  &
          '** Aquifer Leakage Parameters  **  (read echo,[3.5.X])',  &
          'Region','m.c.- modification code',  &
          'X1       X2       Y1       Y2       Z1       Z2',  &
          'Density','('//unitm//'/'//unitl//'^3)','m.c.',dash
  ELSEIF(icall == 3) THEN
     if (print_rde) WRITE(furde,2101)  &
          '** Aquifer Leakage Parameters  **  (read echo,[3.5.X])',  &
          'Region','m.c.- modification code',  &
          'X1       X2       Y1       Y2       Z1       Z2',  &
          'Viscosity','('//unitvs//')','m.c.',dash
  ELSEIF( ICALL.EQ.41) THEN  
     if (print_rde) WRITE( FURDE, 2001)  
2001 FORMAT   (/TR5, &
          &        '** Aquifer Influence Functions ** (read echo,[2.18.2])'/ &
          &        TR35,'Region',TR13,'Face Factor',TR5,'Modification Code'/ &
          &        TR6,'X1         X2         Y1         Y2         ', &
          &        'Z1         Z2'/TR1,95('-'))
     ELSEIF( ICALL/ 100.EQ.1) THEN  
     if (print_rde) WRITE( FURDE, 2002) LABEL( MOD( ICALL, 10) )  
2002 FORMAT   (/TR5, &
          &        '** Aquifer Initial Conditions ** (read echo,[2.21.X])'/ &
          &        TR35,'Region',TR10,'m.c. - modification code', &
          &        TR10,'B.C. Code'/TR6, &
          &        'X1         X2         Y1         Y2         ', &
          &        'Z1         Z2',TR8,A,TR3, &
          &        'm.c.'/TR1,95('-'))
     ELSEIF( ICALL.EQ.51) THEN  
     if (print_rde) WRITE( FURDE, 2003)  
2003 FORMAT   (/TR5,'** Thermal Diffusivity for Heat Conduction ', &
          &        'B.C. at these Cells ** (read echo,[2.19.3])'/ &
          &        TR35,'Region',TR30,'B.C. Code'/TR6, &
          &        'X1         X2         Y1         Y2         ', &
          &        'Z1         Z2',TR5, &
          &        'UDTHHC',TR10, &
          &        'Modification Code'/TR1,95('-'))
     ELSEIF( ICALL.EQ.52) THEN  
     if (print_rde) WRITE( FURDE, 2004)  
2004 FORMAT   (/TR5,'** Thermal Conductivity for Heat Conduction ', &
          &        'B.C. at these Cells ** (read echo,[2.19.4])'/ &
          &        TR35,'Region'/TR6, &
          &        'X1         X2         Y1         Y2         ', &
          &        'Z1         Z2',TR5, &
          &        'UKHCBC',TR10, &
          &        'Modification Code'/TR1,95('-'))
     ELSEIF( ICALL.EQ.31) THEN  
     if (print_rde) WRITE( FURDE, 2005)  
2005 FORMAT   (/TR5, &
          &        '** Aquifer Leakage Parameters ** (read echo,[3.5.X])'/ &
          &        TR35,'Region',TR13,'KLBC',TR10,'Modification Code'/TR6, &
          &        'X1         X2         Y1         Y2         ', &
          &        'Z1         Z2'/TR1,95('-'))
     ELSEIF( ICALL/ 10.EQ.33) THEN  
     if (print_rde) WRITE( FURDE, 2006) '** Aquifer Leakage Parameters ** (read echo,[3.5.X])', &
          'Region', LABEL( MOD( ICALL, 10) ) , 'Modification Code', &
          'X1         X2         Y1         Y2         ', 'Z1         Z2', &
          DOTS
2006 FORMAT   (TR5,A/TR35,A,TR13,A,TR10,A/TR6,2A/TR1,A95)  
     ELSEIF( ICALL/ 10.EQ.30) THEN  
     if (print_rde) WRITE(FURDE, 2007) LABEL(MOD(ICALL, 10)), LABEL(MOD(ICALL,10))
2007 FORMAT(/TR5, &
          &        '** Specified ',A,' B.C. **  (read echo,[3.3.X])'/ &
          &        TR35,'Region',TR20,'m.c. - modification code'/TR10, &
          &        'X1         X2         Y1         Y2         ', &
          &        'Z1         Z2',TR10,A,'m.c.'/TR1,95('-'))
     ELSEIF( ICALL/ 10.EQ.31) THEN  
     if (print_rde) WRITE( FURDE, 2008) '** ', LABEL(MOD(ICALL,10)), &
          ' for Inflow at Specified Pressure B.C. **  (read echo,', '[3.3.X])', &
          LABEL(MOD(ICALL,10))
2008 FORMAT   (/TR5,4A/ &
          &        TR35,'Region'/TR10, &
          &        'X1         X2         Y1         Y2         ', &
          &        'Z1         Z2',TR6,A,TR2,'m.c.'/TR1,95('-'))
     ELSEIF( ICALL/ 10.EQ.32) THEN  
     if (print_rde) WRITE( FURDE, 2009) '** ', LABEL( MOD( ICALL, 10) ) , ' for Inflow &
          & at Specified Fluid Flux B.C. **  (read ', 'echo,[3.4.X])', LABEL( &
          & MOD( ICALL, 10) )
2009 FORMAT   (/TR5,A,A,A,A/ &
          &        TR35,'Region',TR25,'m.c. - modification code'/TR10, &
          &        'X1         X2         Y1         Y2         ', &
          &        'Z1         Z2',TR8,A,2X,'M.C.'/TR1,95('-'))
     ELSEIF( ICALL.EQ.71) THEN  
     if (print_rde) WRITE( FURDE, 2010) '** ', 'Flux', ' for Evapotranspiration B.C. * &
          &*  (read ', 'echo,[3.6.X])', 'Region', 'm.c. - modification code', &
          & 'X1         X2         Y1         Y2         ', 'Z1         Z2', &
          &'QETBC', 'm.c.', DASH
2010 FORMAT   (/TR5,A,A,A,A/ &
          &        TR35,A,TR25,A/TR10,2A,TR8,A,2X,A/TR1,A95)
     ELSEIF( ICALL.EQ.321) THEN  
     if (print_rde) WRITE( FURDE, 2202) '** Specified Flux B.C.  **  (read echo,[3.5.X &
          &])', LABEL( MOD( ICALL, 10)  + 5) , 'REGION', '(AMT/', UNITL, '**2 &
          &-', UNITTM, ')', 'M.C.=MODIFICATION CODE', 'X1       X2       Y1 &
          &     Y2       Z1       Z2', 'QFX', 'm.c.', DOTS
2202 FORMAT   (/TR5,A,TR3,A/TR35,A,TR15,5A,TR5,A/TR10,A/TR10,A,TR5,A &
          &        /TR1,A80)
     ELSEIF( ICALL/ 10.EQ.34) THEN  
     if (print_rde) WRITE( FURDE, 2011) '** ', LABEL( MOD( ICALL, 10) ) , ' for Inflow at A.I.F. B.C. **  (read ', &
          'echo,[3.7.X])', LABEL( MOD( ICALL, 10) )
2011 FORMAT   (/TR5,A,A,A,A/ &
          &        TR5,'Region',TR40,'m.c. - modification code'/TR6, &
          &        TR35,'Region',TR30,'B.C. Code'/TR6, &
          &        'X1         X2         Y1         Y2         ', &
          &        'Z1         Z2',TR5,A,TR2,'m.c.'/TR1,95('-'))
  ENDIF
  if (print_rde) WRITE( FURDE, 2012) 'Modification code: 1-replace, ', '2-multiply, &
       & 3-add, 4-node-by-node, 5-linear interpolate'
2012 FORMAT(/TR5,2A/(TR18,2A/))  
10 READ( FUINS, '(A)') LINE  
  IC = INDEX( LINE( 1:20) , 'END')  
  IF( IC.EQ.0) IC = INDEX( LINE( 1:20) , 'end')  
  IF( IC.GT.0) GOTO 110  
  BACKSPACE( UNIT = FUINS)  
  READ( FUINS, * ) X1, X2, Y1, Y2, Z1, Z2  
  ! ... Read the modification data
  READ( FUINS, * ) VAR, IMOD  
  if (print_rde) WRITE( FURDE, 2013) X1, X2, Y1, Y2, Z1, Z2, VAR, IMOD  
2013 FORMAT(TR5,6(1PG11.3),TR2,1PG12.4,TR5,I1)  
  X1 = CNVL* X1  
  X2 = CNVL* X2  
  Y1 = CNVL* Y1  
  Y2 = CNVL* Y2  
  Z1 = CNVL* Z1  
  Z2 = CNVL* Z2  
  J1 = 1  
  J2 = 1  
  ERFLG = .FALSE.  
  CALL INCIDX( X1, X2, NX, X, I1, I2, ERFLG)  
  IF( .NOT.CYLIND) CALL INCIDX( Y1, Y2, NY, Y, J1, J2, ERFLG)  
  CALL INCIDX( Z1, Z2, NZ, Z, K1, K2, ERFLG)  
  ! ... Error check
  IF( ERFLG) IERR( IER) = .TRUE.  
  IF( I2.GT.NX.OR.I1.GT.I2) IERR( IER) = .TRUE.  
  IF( J1.LT.0.OR.J2.GT.NY.OR.J1.GT.J2) IERR( IER) = .TRUE.  
  IF( K1.LT.1.OR.K2.GT.NZ.OR.K1.GT.K2) IERR( IER) = .TRUE.  
  IF( IMOD.LE.0.OR.IMOD.GT.5) IERR( IER) = .TRUE.  
  IF( IMOD.LT.4) THEN  
     ! ... Install the mods
     DO 40 K = K1, K2  
        DO 30 J = J1, J2  
           DO 20 I = I1, I2  
              M = CELLNO( I, J, K)  
              IF( IMOD.EQ.1) PAR(M) = VAR  
              IF( IMOD.EQ.2) PAR(M) = PAR(M) * VAR  
              IF( IMOD.EQ.3) PAR(M) = PAR(M) + VAR  
20         END DO
30      END DO
40   END DO
     ELSEIF( IMOD.EQ.4) THEN  
        ! ... Node by node input
     NXYZS = ( I2 - I1 + 1) * ( J2 - J1 + 1) * ( K2 - K1 + 1)  
     allocate (upar(nxyzs), &
          stat = a_err)
     if (a_err.ne.0) then  
        print *, "Array allocation failed: rewi"  
        stop  
     endif
     ! ... Read data for entire subregion of nodes
     READ( FUINS, * ) ( UPAR( MS), MS = 1, NXYZS)  
     ! ... Install the data into full nodal array space
     MS = 0  
     DO 70 K = K1, K2  
        DO 60 J = J1, J2  
           DO 50 I = I1, I2  
              MS = MS + 1  
              M = CELLNO( I, J, K)  
              PAR( M) = UPAR( MS)  
50         END DO
           M1 = CELLNO( I1, J, K)  
           M2 = CELLNO( I2, J, K)  
           if (print_rde) WRITE( FURDE, 2014) M1, ' -', M2, ( PAR( M) , M = M1, M2)  
2014       FORMAT         (TR1,I6,A,I6/10(1PG12.4))  
60      END DO
70   END DO
     deallocate (upar, &
          stat = da_err)
     if (da_err.ne.0) then  
        print *, "Array deallocation failed"  
        stop  
     endif
     ELSEIF(imod == 5) THEN  
        ! ... Linear segment interpolation
     READ(FUINS,*) XS(1),FS(1,1),XS(2),FS(2,1)
     if (print_rde) WRITE(FURDE,2013) XS(1),FS(1,1),XS(2),FS(2,1)
     XS(1) = CNVL*XS(1)
     XS(2) = CNVL*XS(2)
     IDIR = NINT(VAR)
     ERFLG = .FALSE.
     DO k = k1, k2  
        DO j = j1, j2  
           DO i = i1, i2  
              m = CELLNO(i,j,k)  
              IF(idir == 1) THEN  
                 par(m) = interp(1,x(i),ys(1),2,1,xs,ys,fs,erflg)
                 ! ... ys not used for 1-d interpolation
              ELSEIF(idir == 2) THEN  
                 par(m) = interp(1,y(j),ys(1),2,1,xs,ys,fs,erflg)
              ELSEIF(idir == 3) THEN  
                 par(m) = interp(1,z(k),ys(1),2,1,xs,ys,fs,erflg)
              ENDIF
           END DO
        END DO
     END DO
     IF( ERFLG) THEN  
        IERR( IER) = .TRUE.  
        ERREXI = .TRUE.  
     ENDIF
  ENDIF
  GOTO 10  
110 RETURN  
END SUBROUTINE rewi
