SUBROUTINE irewi(ipar,icall,ier)
  ! ... Reads, error checks, writes, and unpacks the integer data
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcc
  USE mcg
  USE mcn
  USE mcp
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
       REAL(KIND=KDP), dimension(:), INTENT(IN) :: xs
       INTEGER, INTENT(OUT) :: i1, i2
       LOGICAL, INTENT(INOUT) :: erflg
     END SUBROUTINE incidx
  END INTERFACE
  !
  CHARACTER(LEN=2) :: cicall
  CHARACTER(LEN=9) :: cpar
  CHARACTER(LEN=6) :: cpari
  CHARACTER(LEN=80) :: line
  REAL(kind=kdp) :: x1, x2, y1, y2, z1, z2
  INTEGER :: a_err, da_err, i, i1, i2, ib, ic, iface, imod, ipar1, ipar2, ipari, j, j1, j2,  &
       k, k1, k2, m, m1, m2, ms, nxyzs, uipars
  LOGICAL :: erflg
  INTEGER, dimension(:), allocatable :: uipar
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$RCSfile: irewi.f90,v $//$Revision: 2.1 $'
  !     ------------------------------------------------------------------
  !...
  IF(icall== 1) THEN
     if (print_rde) WRITE(furde,2001)
     2001 FORMAT(/tr5,  &
          '** Specified Value B.C. Nodes ** (read echo,[2.14])'/  &
          tr35,'Region',tr30,'B.C. Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
  ELSE IF(icall == 2) THEN
     if (print_rde) WRITE(furde,2002)
     2002 FORMAT(/tr5,  &
          '** Specified Flux B.C. Cells ** (read echo,[2.15])'/tr35,  &
          'Region',tr30,'B.C. Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
  ELSE IF(icall == 3) THEN
     if (print_rde) WRITE(furde,2003)
     2003 FORMAT(/tr5,'** Aquifer and River Leakage B.C. Nodes ** ',  &
          '(read echo,[2.16.1])'/ tr35,'Region',tr30,'B.C. Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
  ELSE IF(icall == 4) THEN
     if (print_rde) WRITE(furde,2004)
     2004 FORMAT(/tr5,'** Aquifer Influence Function B.C. Nodes ** ',  &
          '(read echo,[2.18.1])'/ tr35,'Region',tr30,'B.C. Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
  ELSE IF(icall == 5) THEN
     if (print_rde) WRITE(furde,2005)
     2005 FORMAT(/tr5,'** Heat Conduction B.C. Nodes ** ',  &
          '(read echo,[2.19.1])'/ tr35,'Region',tr30,'B.C. Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
  ELSE IF(icall == 7) THEN
     if (print_rde) WRITE(furde,2006)
     2006 FORMAT(/tr5,'** Evapotranspiration B.C. Nodes ** ',  &
          '(read echo,[2.17.1])'/ tr35,'Region',tr30,'B.C. Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
  ELSE IF(icall == 8) THEN
     if (print_rde) WRITE(furde,2008)
     2008 FORMAT(/tr5,'** Mesh sub zones for .O.chem file ** ',  &
          '(read echo,[3.xxxx])'/ tr35,'Region',tr30,'Print Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
  ELSE IF(icall == 9) THEN
     if (print_rde) WRITE(furde,2009)
     2009 FORMAT(/tr5,'** Mesh sub zones for .xyz.chem file ** ',  &
          '(read echo,[3.xxxx])'/ tr35,'Region',tr30,'Print Code'/tr6,  &
          'X1         X2         Y1         Y2         ', 'Z1         Z2'/tr1,95('-'))
  END IF
  IF(icall == 5) icall=4
  WRITE(cicall,6001) icall
  6001 FORMAT(i2)
10 READ(fuins,'(A)') line
  ic=INDEX(line(1:20),'END')
  IF(ic == 0) ic=INDEX(line(1:20),'end')
  IF(ic > 0) GO TO 60
  BACKSPACE(UNIT=fuins)
  READ(fuins,*) x1,x2,y1,y2,z1,z2
  ! ... Read the data
  IF(icall /= 8 .AND. icall /= 9 ) THEN
     READ(fuins,*) ipari
     ! ... Echo write the data
     if (print_rde) WRITE(furde,2007) x1,x2,y1,y2,z1,z2,ipari
2007 FORMAT(tr1,6(1PG11.4),tr5,i6)
  else
     READ(fuins,*) ipari, imod
  ! ... Echo write the data
     if (print_rde) WRITE(furde,2017) x1,x2,y1,y2,z1,z2,ipari,imod
2017 FORMAT(tr1,6(1PG11.4),tr5,i6,tr5,i1)
  endif
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
  IF(i2 > nx.OR.i1 > i2) ierr(ier)=.TRUE.
  IF(j1 < 0.OR.j2 > ny.OR.j1 > j2) ierr(ier)=.TRUE.
  IF(k1 < 0.OR.k2 > nz.OR.k1 > k2) ierr(ier)=.TRUE.
!  IF(imod /= 1 .OR. imod /= 4) IERR(IER) = .TRUE.  
  IF(icall == 8 .OR. icall == 9) THEN
     ! ... Node by node input
     NXYZS = ( I2 - I1 + 1) * ( J2 - J1 + 1) * ( K2 - K1 + 1)  
     allocate (uipar(nxyzs), &
          stat = a_err)
     if (a_err.ne.0) then  
        print *, "Array allocation failed: rewi"  
        stop  
     endif
     ! ... Read data for entire subregion of nodes
     READ( FUINS, * ) ( UIPAR( MS), MS = 1, NXYZS)  
     ! ... Install the data into full nodal array space
     MS = 0  
     DO  K = K1, K2  
        DO  J = J1, J2  
           DO  I = I1, I2  
              MS = MS + 1  
              M = CELLNO( I, J, K)  
              IPAR( M) = UIPAR( MS)  
           END DO
           M1 = CELLNO( I1, J, K)  
           M2 = CELLNO( I2, J, K)  
           if (print_rde) WRITE( FURDE, 2014) M1, ' -', M2, ( IPAR( M) , M = M1, M2)  
2014       FORMAT         (TR1,I6,A,I6/10(1PG12.4))  
        END DO
     END DO
     deallocate (uipar, &
          stat = da_err)
     if (da_err.ne.0) then  
        print *, "Array deallocation failed: irewi"  
        stop  
     endif
  ELSE
     WRITE(cpari,6002) ipari
     6002 FORMAT(i6)
     ! ... Unpack the data
     DO  k=k1,k2
        DO  j=j1,j2
           DO  i=i1,i2
              m=cellno(i,j,k)
              IF(ipar(m) /= -1) THEN
                 iface=ipari/100000
                 IF(icall == 1) iface=1
                 WRITE(cpar,6004) ipar(m)
                 DO  ib=1,9
                    IF(cpar(ib:ib) == ' ') cpar(ib:ib)='0'
                 END DO
                 IF(cpari(4:4) == cicall(2:2)) THEN
                    IF((cpar(iface:iface) == '2'.AND.cpari(4:4) == '3')  &
                         .OR.(cpar(iface:iface) == '3'.AND.cpari(4:4)  == '2')) THEN
                       READ(cpar(iface:iface),6003) ipar1
                       READ(cpari(4:4),6003) ipar2
                       ipar1=ipar1+ipar2
                       WRITE(cpar(iface:iface),6003) ipar1
                    ELSE
                       cpar(iface:iface)=cpari(4:4)
                    END IF
                 END IF
                 IF(cpari(5:5) == cicall(2:2)) THEN
                    IF((cpar(iface+3:iface+3) == '2'.AND.  &
                         cpari(5:5) == '3').OR.(cpar(iface+3:iface+3)  &
                         == '3'.AND.cpari(5:5) == '2')) THEN
                       READ(cpar(iface+3:iface+3),6003) ipar1
                       READ(cpari(5:5),6003) ipar2
6003                   FORMAT(i1)
                       ipar1=ipar1+ipar2
                       WRITE(cpar(iface+3:iface+3),6003) ipar1
                    ELSE
                       cpar(iface+3:iface+3)=cpari(5:5)
                    END IF
                 END IF
                 IF(cpari(6:6) == cicall(2:2)) THEN
                    IF((cpar(iface+6:iface+6) == '2'.AND.cpari(6:6) ==  &
                         '3').OR.(cpar(iface+6:iface+6) == '3'.AND.  &
                         cpari(6:6) == '2')) THEN
                       READ(cpar(iface+6:iface+6),6003) ipar1
                       READ(cpari(6:6),6003) ipar2
                       ipar1=ipar1+ipar2
                       WRITE(cpar(iface+6:iface+6),6003) ipar1
                    ELSE
                       cpar(iface+6:iface+6)=cpari(6:6)
                    END IF
                 END IF
                 READ(cpar,6004) uipars
                 6004  FORMAT(i9)
                 ipar(m)=uipars
              END IF
           END DO
        END DO
     END DO
  ENDIF
  GO TO 10
60 RETURN
END SUBROUTINE irewi
