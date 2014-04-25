
    Module sun_data
    double precision, DIMENSION(:), ALLOCATABLE :: x_nodes, y_nodes, z_nodes
    double precision :: a0(4), a(4), lambda(4), sumpi(4), c0(4), c(4)
    integer :: nx, ny, nz
    double precision :: xmin, xmax, ymin, ymax, zmin, zmax
    double precision :: y1_patch, y2_patch, z1_patch, z2_patch
    double precision :: vel, dispx, dispy, dispz
    integer :: nquad
    double precision :: time
    End Module sun_data

    PROGRAM SUN6_3
!.....From Wexler
!
!      ********************************************************
!      *                                                      *
!      *                   **** PATCHI ****                   *
!      *                                                      *
!      *   THREE-DIMENSIONAL GROUND-WATER SOLUTE TRANSPORT    *
!      *                                                      *
!      *    MODEL FOR A SEMI-INFINITE AQUIFER OF INFINITE     *
!      *                                                      *
!      *    WIDTH AND HEIGHT. PATCH SOURCE EXTENDING FROM     *
!      *                                                      *
!      *         Y1 TO Y2 AND Z1 TO Z2 LOCATED AT X=0         *
!      *                                                      *
!      *        GROUND-WATER FLOW IN X-DIRECTION ONLY         *
!      *                                                      *
!      *            VERSION CURRENT AS OF 04/01/90            *
!      *                                                      *
!      ********************************************************
!
!       THE FOLLOWING CARD MUST BE CHANGED IF PROBLEM DIMENSIONS ARE
!       GREATER THAN THOSE GIVEN HERE.
!         MAXX = MAXIMUM NUMBER OF X-VALUES
!         MAXY = MAXIMUM NUMBER OF Y-VALUES
!         MAXZ = MAXIMUM NUMBER OF Z-VALUES
!         MAXT = MAXIMUM NUMBER OF TIME VALUES
!         MAXXY = MAXX * MAXY
!         MAXXY2 = 2 * MAXX * MAXY
      PARAMETER (MAXX=100,MAXY=50,MAXZ=30,MAXT=20,MAXXY=5000,   &
      MAXXY2=10000)
      !
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*10 CUNITS,VUNITS,DUNITS,KUNITS,LUNITS,TUNITS
      REAL XP,YP,ZP,CP,TP,DELTA,XPC,YPC,XSCLP,YSCLP
      DIMENSION CXY(MAXX,MAXY),X(MAXX),Y(MAXY),Z(MAXZ),T(MAXT)
      COMMON /PDAT/ XP(MAXX),YP(MAXY),CP(MAXXY),XPC(50),YPC(50), &
         IFLAG(MAXXY2)
      COMMON /IOUNIT/ IN,IO
      CHARACTER*80 TITLE
      COMMON/CSCH/TITLE
!
!     PROGRAM VARIABLES
!
!           NOTE:  ANY CONSISTANT SET OF UNITS MAY BE USED IN THE
!           MODEL.  NO FORMAT STATEMENTS NEED TO BE CHANGED AS
!           LABELS FOR ALL VARIABLES ARE SPECIFIED IN MODEL INPUT.
!
!     C0       SOLUTE CONCENTRATION AT THE INFLOW BOUNDARY [M/L**3]
!     DX       LONGITUDINAL DISPERSION COEFFICIENT [L**2/T]
!     DY       TRANSVERSE (Y-DIRECTION) DISPERSION COEFFICIENT [L**2/T]
!     DZ       TRANSVERSE (Z-DIRECTION) DISPERSION COEFFICIENT [L**2/T]
!     VX       GROUND-WATER VELOCITY IN X-DIRECTION [L/T]
!     DK       FIRST-ORDER SOLUTE DECAY CONSTANT [1/T]
!     X        X-POSITION AT WHICH CONCENTRATION IS EVALUATED [L]
!     Y        Y-POSITION AT WHICH CONCENTRATION IS EVALUATED [L]
!     Z        Z-POSITION AT WHICH CONCENTRATION IS EVALUATED [L]
!     T        TIME AT WHICH CONCENTRATION IS EVALUATED [T]
!     CN       NORMALIZED CONCENTRATION C/C0 [DIMENSIONLESS]
!     CXY      SOLUTE CONCENTRATION C(X,Y,Z,T) [M/L**3]
!     WS       WIDTH OF PATCH SOLUTE SOURCE [L]
!     HS       HEIGHT OF PATCH SOLUTE SOURCE [L]
!     Y1       Y-COORDINATE OF LOWER LIMIT OF PATCH SOLUTE SOURCE [L]
!     Y2       Y-COORDINATE OF UPPER LIMIT OF PATCH SOLUTE SOURCE [L]
!     Z1       Z-COORDINATE OF LOWER LIMIT OF PATCH SOLUTE SOURCE [L]
!     Z2       Z-COORDINATE OF UPPER LIMIT OF PATCH SOLUTE SOURCE [L]
!
!     NX       NUMBER OF X-POSITIONS AT WHICH SOLUTION IS EVALUATED
!     NY       NUMBER OF Y-POSITIONS AT WHICH SOLUTION IS EVALUATED
!     NZ       NUMBER OF Z-POSITIONS AT WHICH SOLUTION IS EVALUATED
!     NT       NUMBER OF TIME VALUES AT WHICH SOLUTION IS EVALUATED
!     NMAX     NUMBER OF TERMS USED IN GAUSS-LEGENDRE NUMERICAL
!              INTEGRATION TECHNIQUE (MUST EQUAL 4, 20, 60, 104 OR 256)
!
!     IPLT     PLOT CONTROL. IF IPLT>0, CONTOUR MAPS ARE PLOTTED
!     XSCLP    SCALING FACTOR TO CONVERT X TO PLOTTER INCHES
!     YSCLP    SCALING FACTOR TO CONVERT Y TO PLOTTER INCHES
!     DELTA    CONTOUR INCREMENT FOR PLOT. (VALUE BETWEEN 0 AND 1.0)
!
!       CHARACTER VARIABLES USED TO SPECIFY UNITS FOR MODEL PARAMETERS
!     CUNITS   UNITS OF CONCENTRATION (M/L**3)
!     VUNITS   UNITS OF GROUND-WATER VELOCITY (L/T)
!     DUNITS   UNITS OF DISPERSION COEFFICIENT (L**2/T)
!     KUNITS   UNITS OF SOLUTE DECAY CONSTANT  (1/T)
!     LUNITS   UNITS OF LENGTH (L)
!     TUNITS   UNITS OF TIME (T)
!
!       DEFINE INPUT/OUTPUT FILES AND PRINT TITLE PAGE

      CALL Setup()
      CALL XY_Plane()
      CALL XZ_Plane()
      
!      
!      CALL OFILE
!      CALL WTITLE
!      WRITE(IO,201)
!!
!!       READ IN MODEL PARAMETERS
!      READ(IN,*) NX,NY,NZ,NT,NMAX,IPLT
!      WRITE(IO,205) NX,NY,NZ,NT,NMAX
!      nxy=nx*ny
!      nxyz=nxy*nz
!      READ(IN,*) CUNITS,VUNITS,DUNITS,KUNITS,LUNITS,TUNITS
!      READ(IN,*) C0,VX,DX,DY,DZ,DK
!      WRITE(IO,210) C0,CUNITS,VX,VUNITS,DX,DUNITS,DY,DUNITS,DZ,DUNITS, &
!        DK,KUNITS
!      READ(IN,*) Y1,Y2,Z1,Z2
!      WRITE(IO,212) Y1,LUNITS,Y2,LUNITS,Z1,LUNITS,Z2,LUNITS
!      READ(IN,*) (X(I),I=1,NX)
!      WRITE(IO,215) LUNITS
!      WRITE(IO,220) (X(I),I=1,NX)
!      READ(IN,*) (Y(I),I=1,NY)
!      WRITE(IO,216) LUNITS
!      WRITE(IO,220) (Y(I),I=1,NY)
!      READ(IN,*) (Z(I),I=1,NZ)
!      WRITE(IO,217) LUNITS
!      WRITE(IO,220) (Z(I),I=1,NZ)
!      READ(IN,*) (T(I),I=1,NT)
!      WRITE(IO,225) TUNITS
!      WRITE(IO,220) (T(I),I=1,NT)
!!..      IF(IPLT.GT.0) READ(IN,*) XSCLP,YSCLP,DELTA
!!..      IF(IPLT.GT.0) WRITE(IO,227) XSCLP,YSCLP,DELTA,CUNITS
!!.....Write static data to file 13 for visualization
!       WRITE(13,5001) TITLE
! 5001 FORMAT(A)
!      WRITE(13,5001) '    f    t    f    f'
!      WRITE(13,5003) NX,NY,nz,NXY,nxyz
! 5003 FORMAT(5I5)
!      WRITE(13,5002) (X(I),I=1,NX)
! 5002 FORMAT(10(1PG12.5))
!      WRITE(13,5002) (Y(J),J=1,NY)
!      WRITE(13,5002) (Z(K),K=1,NZ)
!!
!!       READ IN GAUSS-LEGENDRE POINTS AND WEIGHTING FACTORS
!      CALL GLQPTS (NMAX)
!!
!!       Begin time loop
!      DO 20 IT=1,NT
!!
!!       Begin z loop
!      DO 30 IZ=1,NZ
!!
!!       Begin x loop
!      DO 40 IX=1,NX
!!
!!     CALCULATE NORMALIZED CONCENTRATION FOR ALL Y AT X=X(IX) AND Z=Z(IZ)
!      DO 50 IY=1,NY
!          
!      CALL CNRMLP(DK,T(IT),X(IX),Y(IY),Z(IZ),Y1,Y2,Z1,Z2,DX, &
!        DY,DZ,VX,CN,NMAX)
!      CXY(IX,IY)=C0*CN
!50    CONTINUE
!40    CONTINUE
!!
!!       PRINT OUT TABLES OF CONCENTRATION VALUES
!      NPAGE=1+(NY-1)/9
!      DO 60 NP=1,NPAGE
!      IF(NP.EQ.1) WRITE(IO,230) T(IT),TUNITS,Z(IZ),LUNITS,LUNITS
!      IF(NP.NE.1) WRITE(IO,231) T(IT),TUNITS,Z(IZ),LUNITS,LUNITS
!      NP1=(NP-1)*9
!      NP2=9
!      IF((NP1+NP2).GT.NY) NP2=NY-NP1
!      WRITE(IO,235) (Y(NP1+J),J=1,NP2)
!      WRITE(IO,236) CUNITS,LUNITS
!      DO 70 IX=1,NX
!      WRITE(IO,240) X(IX),(CXY(IX,NP1+J),J=1,NP2)
!      IF(MOD(IX,45).NE.0) GO TO 70
!      WRITE(IO,231) T(IT),TUNITS,Z(IZ),LUNITS,LUNITS
!      WRITE(IO,235) (Y(NP1+J),J=1,NP2)
!      WRITE(IO,236) CUNITS,LUNITS
!70    IF(MOD(IX,5).EQ.0 .AND. MOD(IX,45).NE.0) WRITE(IO,241)
!60    CONTINUE
!!
!!       CONVERT X AND Y TO SINGLE PRECISION AND DIVIDE BY THE
!!       PLOT SCALING FACTORS. CONVERT C(X,Y) AND DIVIDE BY C0 TO PLOT
!!       CONTOUR MAPS OF NORMALIZED CONCENTRATION FOR EACH TIME VALUE.
!      IF(IPLT.gt.0) then
!      NXY=NX*NY
!      DO 80 I=1,NX
!      IP=(I-1)*NY
!      XP(I)=SNGL(X(I))
!      DO 80 J=1,NY
!      IF(I.EQ.1) YP(J)=SNGL(Y(J))
!      CP(IP+J)=SNGL(CXY(I,J)/C0)
!80    CONTINUE
!      TP=SNGL(T(IT))
!      ZP=SNGL(Z(IZ))
!      NXY2=NXY*2
!!..      CALL PLOT3D (XP,YP,ZP,CP,TP,DELTA,NX,NY,NXY,NXY2,IZ,NZ,IPLT,
!!..     1 TUNITS,LUNITS,XSCLP,YSCLP,XPC,YPC,IFLAG)
!       endif
!30    CONTINUE
!!.....Write to file 13 for visualization
!      WRITE(13,5015) 'Time =',TP
! 5015 FORMAT(TR5,A,1PG15.4)
!            WRITE(13,5012) 'Concentration'
! 5012       FORMAT(A80)
!            DO 25 J=1,NY
!   25             WRITE(13,5013) (CP(NY*(I-1)+J),I=1,NX)
! 5013       FORMAT(9(1PG14.6))
!20    CONTINUE
!      CLOSE (IN)
!      CLOSE (IO)
!      close(13)
!      STOP 'Calculations completed'
!!
!!        FORMAT STATEMENTS
!101   FORMAT(20I4)
!105   FORMAT(8A10)
!110   FORMAT(8F10.0)
!  201 FORMAT(/////1H ,'Analytical solution to the three-dimensional'  &
!          /1H ,'advective-dispersive solute transport equation'/      &
!          1H ,'for a semi-infinite aquifer of infinite widthextent'/  &
!          1H ,'and height with a continuous patch source at X=0.'     &
!          ///1H0,'INPUT DATA'/1H ,10(1H-))
!205   FORMAT(1H0,25X,'NUMBER OF X-COORDINATES (NX) = ',I4/1H ,25X,    &
!      'NUMBER OF Y-COORDINATES (NY) = ',I4/1H ,25X,                   &
!      'NUMBER OF Z-COORDINATES (NZ) = ',I4/1H ,25X,                   &
!      'NUMBER OF TIME VALUES (NT) = ',I4/1H ,25X,                     &
!      'NUMBER OF POINTS FOR NUMERICAL INTEGRATION (NMAX) = ',I4)
!210   FORMAT(1H0,'Solute Concentration on Region Boundary (C0) =',    &
!      1P1E13.6,1X,A10/1H ,                                            &
!      'Ground-water Velocity in X-direction (VX) =',1P1E13.6,1X,A10/  &
!      1H ,'Dispersion in the X-direction (DX) =',1P1E13.6,1X,A10/     &
!      1H ,'Dispersion in the Y-direction (DY) =',1P1E13.6,1X,A10/     &
!      1H ,'Dispersion in the Z-direction (DZ) =',1P1E13.6,1X,A10/     &
!      1H ,'First-order Solute Decay Rate (DK) =',1P1E13.6,1X,A10)
!212   FORMAT(1H0,'AQUIFER WIDTH (W) AND HEIGHT (H) ARE INFINITE'/     &
!      1H ,'SOLUTE SOURCE IS LOCATED BETWEEN Y1 =',1P1E13.6,1X,A10/    &
!      1H ,tr30,'and Y2 =',1P1E13.6,1X,A10/1H ,tr30,                   &
!      'Z1 =',1P1E13.6,1X,A10/1H ,tr25,                                &
!      'and Z2 =',1P1E13.6,1X,A10)
!215   FORMAT(1H0,'X-COORDINATES AT WHICH SOLUTE CONCENTRATIONS ',     &
!      'WILL BE CALCULATED, IN ',A10/1H ,78(1H-)/)
!216   FORMAT(1H0,'Y-COORDINATES AT WHICH SOLUTE CONCENTRATIONS ',     &
!      'WILL BE CALCULATED, IN ',A10/1H ,78(1H-)/)
!217   FORMAT(1H0,'Z-COORDINATES AT WHICH SOLUTE CONCENTRATIONS ',     &
!      'WILL BE CALCULATED, IN ',A10/1H ,78(1H-)/)
!220   FORMAT(1H ,5X,8F12.4)
!225   FORMAT(1H0,'TIMES AT WHICH SOLUTE CONCENTRATIONS '              & 
!      'WILL BE CALCULATED, IN ',A10/1H ,70(1H-)/)
!227   FORMAT(1H0,'PLOT SCALING FACTOR FOR X (XSCLP) =',1P1E13.6/      &
!      1H ,'PLOT SCALING FACTOR FOR Y (YSCLP) =',1P1E13.6/             &
!      1H ,'CONTOUR INCREMENT (DELTA) =',1P1E13.6,1X,A10)
!230   FORMAT(//15X,'Solute Concentration at time =',                  &
!      F12.4,1X,A10/35X,'and at Z =',F12.4,1X,A10/                     &
!      tr15,'Y-coordinate, in ',A10)
!231   FORMAT(//15X,'Solute Concentration at time =',                  &
!      F12.4,1X,A10,5X,'(continued)'/35X,'and at Z =',F12.4,1X,A10/    &
!      tr15,'Y-coordinate, in ',A10)
!235   FORMAT(1H ,tr10,9F12.4)
!236   FORMAT(1H ,tr9,'*',108(1H-)/                                    &
!      1H ,'X-COORDINATE,',2X,'!',44X,'SOLUTE CONCENTRATION, IN '      &
!      A10/1H ,'IN ',A10,2X,1H!/1H ,tr15,'!')
!240   FORMAT(1H ,F12.3,' !',9F11.5)
!241   FORMAT(1H ,tr14,' !')
      END
      SUBROUTINE CNRMLP(DK,T,X,Y,Z,Y1,Y2,Z1,Z2,DX,DY,DZ,VX,CN,NMAX)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      COMMON /IOUNIT/ IN,IO
      COMMON /GLPTS/ WN(256),ZN(256)
!
!       THIS ROUTINE CALCULATES THE NORMALIZED CONCENTRATION AT X,Y,Z
!       BASED ON THE ANALYTIC SOLUTION TO THE THREE-DIMENSIONAL
!       ADVECTIVE-DISPERSIVE SOLUTE TRANSPORT EQUATION FOR A SEMI-
!       INFINITE AQUIFER WITH INFINITE WIDTH AND HEIGHT. THE SOLUTE
!       SOURCE HAS A FINITE WIDTH AND HEIGHT, EXTENDING FROM Y=Y1 TO
!       Y=Y2 AND Z=Z1 TO Z=Z2. THE SOLUTE MAY BE SUBJECT TO FIRST-ORDER
!       CHEMICAL TRANSFORMATION. THE SOLUTION CONTAINS AN INTEGRAL
!       FROM 0 TO T**.25 WHICH IS EVALUATED NUMERICALLY USING A GAUSS-
!       LEGENDRE QUADRATURE TECHNIQUE.
!
      PI=3.14159265358979D0
      CN=0.0D0
!
!       FOR T=0, ALL CONCENTRATIONS EQUAL 0.0
      IF(T.LE.0.0D0) RETURN
!
!       FOR X=0.0, CONCENTRATIONS ARE SPECIFIED BY BOUNDARY CONDITIONS
      IF(X.GT.0.0D0) GO TO 10
      IF(Y.EQ.Y1.OR.Y.EQ.Y2) THEN
        IF(Z.GT.Z1.AND.Z.LT.Z2) CN=0.50D0
        IF(Z.EQ.Z1.OR.Z.EQ.Z2) CN=0.25D0
      END IF
      IF(Z.EQ.Z1.OR.Z.EQ.Z2) THEN
        IF(Y.GT.Y1.AND.Y.LT.Y2) CN=0.50D0
      END IF
      IF(Y.GT.Y1.AND.Y.LT.Y2.AND.Z.GT.Z1.AND.Z.LT.Z2) CN=1.0D0
      RETURN
!
!       START NUMERICAL INTEGRATION LOOP
10    SUM=0.0D0
      DO 20 I=1,NMAX
!
!       SCALE THE GAUSS-LEGENDRE COEFFICIENTS TO ACCOUNT FOR THE
!       NON-NORMALIZED LIMITS OF INTEGRATION
!       LIMITS OF INTEGRATION ARE FROM 0 TO T**0.25
      TT=T**0.250D0
      WI=WN(I)
      ZI=TT*(ZN(I)+1.0D0)/2.0D0
      ZSQ=ZI*ZI
      Z4=ZSQ*ZSQ
!
!       TERM 1
      XVT=X-VX*Z4
      EXP1=-XVT*XVT/(4.0D0*DX*Z4)-DK*Z4
      ERFC1=(Y1-Y)/(2.0D0*ZSQ*DSQRT(DY))
      CALL EXERFC(EXP1,ERFC1,Q1)
!
!       TERM 2
      ERFC2=(Y2-Y)/(2.0D0*ZSQ*DSQRT(DY))
      CALL EXERFC(EXP1,ERFC2,Q2)
!
!       TERM 3
      EXP2=0.0D0
      ERFC1=(Z1-Z)/(2.0D0*ZSQ*DSQRT(DZ))
      CALL EXERFC(EXP2,ERFC1,Q3)
      ERFC2=(Z2-Z)/(2.0D0*ZSQ*DSQRT(DZ))
      CALL EXERFC(EXP2,ERFC2,Q4)
      TERM=(Q1-Q2)*(Q3-Q4)*WI/(ZI*ZSQ)
      SUM=SUM+TERM
20    CONTINUE
      SUM=SUM*TT/2.0D0
      CN=SUM*X/(2.0D0*DSQRT(PI*DX))
      RETURN
    END
    
subroutine Setup()
    use sun_data
    implicit none
    integer i, j, l
    double precision pi, d
    
    ! spatial
    nx = 101
    xmin = 0.0d0 
    xmax = 100.0d0
    ny = 41
    ymin = 0.0d0
    ymax = 40.0d0
    nz = 26
    zmin = 0.0d0
    zmax = 25.0d0
    allocate (x_nodes(nx), y_nodes(ny), z_nodes(nz))
    do i = 1, nx
        x_nodes(i) = xmin + dble(i - 1)*(xmax/dble(nx - 1))
    enddo
    do i = 1, ny
        y_nodes(i) = ymin + dble(i - 1)*(ymax/dble(ny - 1))
    enddo
    do i = 1, nz
        z_nodes(i) = zmin + dble(i - 1)*(zmax/dble(nz - 1))
    enddo
    
    ! patch 15. 26. 10. 15. 
    y1_patch = 15.0d0
    y2_patch = 26.0d0
    z1_patch = 10.0d0
    z2_patch = 15.0d0
    
    ! lambdas
    lambda(1) = 0.05d0
    lambda(2) = 0.02d0
    lambda(3) = 0.01d0
    lambda(4) = 0.005d0
    
    ! velocity
    vel = 0.2d0
    
    ! dispersion
    dispx = 1.5d0 * vel
    dispy = 0.3d0 * dispx
    dispz = 0.1d0 * dispx
    
    ! initial concentrations
    c0(1) = 1.0d0
    c0(2) = 0.0d0
    c0(3) = 0.0d0
    c0(4) = 0.0d0
    
    ! a0
    do i = 1,4
        a0(i) = c0(i)
        do j = 1, i -1
            pi = 1.0d0
            do l = j, i - 1
                d = lambda(l) / (lambda(l) - lambda(i))
                pi = pi * d
            enddo
            a0(i) = a0(i) + pi * c0(j) 
        enddo
    enddo
    
    ! Gauss-Legendre quadrature points
    nquad = 104
    CALL GLQPTS (nquad)
    
    ! time
    time = 400.0d0
    
    return   
end subroutine Setup
subroutine XY_plane()
    use sun_data
    implicit none
    double precision :: ai_normalized, d, pi, z
    integer i, ix, iy, j, l
    double precision, allocatable, dimension(:) :: c_save_x
    allocate(c_save_x(nx))
    z = 13.0d0
    OPEN (20,FILE='Sun6_3.xy.out')
    write(20,'(a)') '         X         Y         Z         A         B         C         D'
    !write(20,'(102(f10.2))') z, (x_nodes(i), i = 1, nx)
    do iy=1,ny
        do ix=1,nx
            do i = 1, 4
                ! Calculate a
                CALL CNRMLP(lambda(i), time, x_nodes(ix), y_nodes(iy), z, &
                y1_patch, y2_patch, z1_patch, z2_patch, dispx, dispy, dispz, vel, ai_normalized, nquad)
                a(i) = ai_normalized * a0(i)
            enddo
            ! convert a to c
            do i = 1,4
                c(i) = a(i)
                do j = 1, i -1
                    pi = 1.0d0
                    do l = j, i - 1
                        d = lambda(l) / (lambda(l) - lambda(i))
                        pi = pi * d 
                    enddo
                    c(i) = c(i) - pi * c(j)
                enddo
            enddo   
            c_save_x(ix) = c(4)
            ! write x, y, z, A, B, C, D  
            write(20,'(7f10.5)') x_nodes(ix), y_nodes(iy), z, (c(i), i = 1,4)
        enddo
        !write(20,'(102(f10.4))') y_nodes(iy), (c_save_x(i), i = 1, nx)
    enddo
    close(20)
end subroutine XY_plane
subroutine XZ_plane()
    use sun_data
    implicit none
    double precision :: ai_normalized, d, pi, y
    integer i, ix, iz, j, l
    Y = 15.5d0
    OPEN (20,FILE='Sun6_3.xz.out')
    write(20,'(a)') '         X         Y         Z         A         B         C         D'
    do iz=1,nz
        do ix=1,nx
            do i = 1, 4
                ! Calculate a
                CALL CNRMLP(lambda(i), time, x_nodes(ix),y, z_nodes(iz), &
                y1_patch, y2_patch, z1_patch, z2_patch, dispx, dispy, dispz, vel, ai_normalized, nquad)
                a(i) = ai_normalized * a0(i)
            enddo
            ! convert a to c
            do i = 1,4
                c(i) = a(i)
                do j = 1, i -1
                    pi = 1.0d0
                    do l = j, i - 1
                        d = lambda(l) / (lambda(l) - lambda(i))
                        pi = pi * d 
                    enddo
                    c(i) = c(i) - pi * c(j)
                enddo
            enddo   
            ! write x, y, z, A, B, C, D  
            write(20,'(7f10.5)') x_nodes(ix), y, z_nodes(iz), (c(i), i = 1,4)
        enddo
    enddo
    close(20)
end subroutine XZ_plane