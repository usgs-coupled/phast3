SUBROUTINE rewi3(par1,par2,par3,icall,ier)
  ! ... Reads, error checks, writes, and unpacks the real data for groups
  ! ...      of three variables
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  use mcch
  USE mcg
  USE mcn
  USE mct
  IMPLICIT NONE
  INTRINSIC INDEX
  REAL(kind=kdp), DIMENSION(:), INTENT(INOUT) :: par1, par2, par3
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
  END INTERFACE
  !
  CHARACTER(LEN=6), DIMENSION(3) :: label(3) = (/'Flow  ','Heat  ','Solute'/)
  CHARACTER(LEN=80) :: line
  REAL(KIND=kdp) :: x1, x2, y1, y2, z1, z2
  REAL(KIND=kdp), DIMENSION(3) :: var
  INTEGER :: a_err, da_err, i, i1, i2, ic, iv, j, j1, j2, k, k1, k2, m, m1,  &
       m2, ms, nxyzs
  INTEGER, DIMENSION(3) :: imod
  LOGICAL :: erflg
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: upar1, upar2, upar3
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  IF(icall == 1) THEN
     if (print_rde) WRITE(furde,2001)  &
          '** Aquifer Leakage Parameters  **  (read echo,[3.5.X])',  &
          'Region','m.c.- modification code',  &
          'X1       X2       Y1       Y2       Z1       Z2',  &
          'Potential','Density','Viscosity',  &
          '(',unitep,')','m.c.','(',unitm,'/',unitl,'^3)','m.c.',  &
          '(',unitvs,')','m.c.',dash
2001 FORMAT(/tr5,a/tr30,a,tr20,a/tr7,a/tr15,a,tr18,a,tr18,a/  &
          tr14,3A,tr5,a,tr6,5A,tr6,a,tr8,3A,tr8,a/tr1, a95)
  ELSE IF(icall >= 3.AND.icall <= 5) THEN
     if (print_rde) WRITE(furde,2002) '** Specified Flux B.C.  **  (read echo,[3.4.X])',  &
          label(icall-2), 'Region','(Amt/'//unitl//'^2-'//unittm//')',  &
          'm.c. - modification code',  &
          'X1       X2       Y1       Y2       Z1       Z2',  &
          'QFX','m.c.','QFY','m.c.','QFZ','m.c.',dash
2002 FORMAT(/tr5,a,tr3,a/tr35,a,tr15,a,tr5,a/tr10,a/tr15,a,tr5,a,  &
          tr6,a,tr5,a,tr6,a,tr5,a/tr1,a95)
  ELSE IF(icall == 6.OR.icall == 7) THEN
     if (print_rde) WRITE(furde,2003) '** Aquifer Initial Conditions - ',label(icall-5),  &
          '  (read echo,[2.21.X])',dash,  &
          'X1       X2       Y1       Y2       Z1       Z2', label(icall-5),dash
2003 FORMAT(/tr5,a,a10,a/tr5,a38/tr5,a,tr5,a10/tr5,a38)
  ELSE IF(icall == 31) THEN
     if (print_rde) WRITE(furde,2004)  &
          '** Aquifer Leakage Parameters  **  (read echo,[2.16.2])',  &
          'Region','m.c. - modification code',  &
          'X1       X2       Y1       Y2       Z1       Z2',  &
          'Aquitard','Thickness','Elevation of','Permeability',  &
          'of Aquitard','Outer Boundary',  &
          '(',unitl,'^2)','m.c.','(',unitl,')','m.c.','(',unitl,')', 'm.c.',dash
2004 FORMAT(/tr5,a/tr30,a,tr20,a/tr7,a/tr15,a,tr12,a,tr12,a/tr13,a,  &
          tr8,a,tr10,a/ tr14,3A,tr5,a,tr6,3A,tr6,a,tr8,3A,tr8,a/tr1,  &
          a95)
  ELSE IF(icall == 71) THEN
     if (print_rde) WRITE(furde,2005) '** Evapotranspiration Parameters  **',  &
          '(read echo,[2.17.2])', 'Region','m.c. - modification code',  &
          'X1       X2       Y1       Y2       Z1       Z2',  &
          'Land Surface','Depth to','      ', 'Elevation','Extinction','     ',  &
          '(',unitl,')','m.c.','(',unitl,')','m.c.',dash
2005 FORMAT(/tr5,a/tr30,a,tr20,a/tr7,a/tr15,a,tr12,a,tr12,a/tr13,a,  &
          tr8,a,tr10,a/ tr14,3A,tr5,a,tr6,3A,tr6,a/tr1,  &
          a95)
  END IF
  if (print_rde) WRITE(furde,2006) 'Modification code: 1-replace, ',  &
       '2-multiply, 3-add, 4-node-by-node, 5-linear interpolate'
2006 FORMAT(/tr5,2A/(tr18,2A/))
10 READ(fuins,'(A)') line
  ic=INDEX(line(1:20),'END')
  IF(ic == 0) ic=INDEX(line(1:20),'end')
  IF(ic > 0) GO TO 170
  BACKSPACE(UNIT=fuins)
  READ(fuins,*) x1,x2,y1,y2,z1,z2
  ! ... Read the modification data
  READ(fuins,*) (var(iv),imod(iv),iv=1,3)
  if (print_rde) WRITE(furde,2007) x1,x2,y1,y2,z1,z2,(var(iv),imod(iv),iv=1,3)
2007 FORMAT(tr5,6(1PG11.3)/tr7,3(tr3,1PG13.5,tr3,i3))
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
  IF(i2 > nx.OR.i1 > i2) ierr(ier)=.TRUE.
  IF(j1 <= 0.OR.j2 > ny.OR.j1 > j2) ierr(ier)=.TRUE.
  IF(k1 <= 0.OR.k2 > nz.OR.k1 > k2) ierr(ier)=.TRUE.
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
          stat = a_err)
     IF (a_err.NE.0) THEN  
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
     ! ... Deallocate scratch space
     DEALLOCATE (upar1, upar2, upar3, &
          stat = da_err)
     IF (da_err.NE.0) THEN  
        PRINT *, "Array deallocation failed"  
        STOP  
     ENDIF
     DO  k=k1,k2
        DO  j=j1,j2
           DO  i=i1,i2
              m1=cellno(i1,j,k)
              m2=cellno(i2,j,k)
              if (print_rde) WRITE(furde,2008) m1,' -',m2,(par1(m),m=m1,m2)
              2008 FORMAT(tr1,i6,a,i6/10(1PG12.4))
           END DO
        END DO
     END DO
     DO  k=k1,k2
        DO  j=j1,j2
           DO  i=i1,i2
              m1=cellno(i1,j,k)
              m2=cellno(i2,j,k)
              if (print_rde) WRITE(furde,2008) m1,' -',m2,(par2(m),m=m1,m2)
           END DO
        END DO
     END DO
     DO  k=k1,k2
        DO  j=j1,j2
           DO  i=i1,i2
              m1=cellno(i1,j,k)
              m2=cellno(i2,j,k)
              if (print_rde) WRITE(furde,2008) m1,' -',m2,(par3(m),m=m1,m2)
           END DO
        END DO
     END DO
  END IF
  GO TO 10
170 RETURN
END SUBROUTINE rewi3
