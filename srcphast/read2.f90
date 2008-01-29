SUBROUTINE read2  
  ! ... read all the data that are constant during the simulation
  USE f_units
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcs
  USE mcv
  USE mcw
  USE mg2
  IMPLICIT NONE
  INCLUDE 'ifrd.inc'
  INTERFACE
     SUBROUTINE incidx(x1,x2,nx,xs,i1,i2,erflg)
       USE machine_constants, ONLY: kdp
       REAL(kind=kdp), INTENT(in) :: x1, x2
       INTEGER, INTENT(in) :: nx
       REAL(kind=kdp), DIMENSION(:), INTENT(in) :: xs
       INTEGER, INTENT(out) :: i1, i2
       LOGICAL, INTENT(inout) :: erflg
     END SUBROUTINE incidx
  END INTERFACE
  INTRINSIC index  
  CHARACTER(len=9) :: cibc  
  CHARACTER(len=80) :: line  
  REAL(KIND=kdp) :: delx, dely, udelz, u1,  uwb, uxw, uyw, uzwb, uzwt, &
       udwb, udwt, &
       uwcfl, uwcfu, x1z, x2z, y1z, y2z, z1z, z2z
  INTEGER :: a_err, da_err
  INTEGER :: i, ic, icall, ipmz, iwel, j, k, ks, lc, ls, m, nsa, umwel, &
       uwelidno, uwq
  LOGICAL :: erflg
  LOGICAL :: temp_logical
  INTEGER :: nr  
  INTEGER, DIMENSION(:), ALLOCATABLE :: ui1z, ui2z, uj1z, uj2z, uk1z, uk2z
  INTEGER, DIMENSION(:), ALLOCATABLE :: uwid, uwqm, unkswel
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: uumwel
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: uuxw, uuyw, uuzwb, uuzwt, uudwb, uudwt, uwbod
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: uuwcfl, uuwcfu
  INTEGER, DIMENSION(:), ALLOCATABLE :: umrbc
  REAL(kind=kdp), DIMENSION(:), ALLOCATABLE :: uarbc, ukrb, uzerb
  CHARACTER(len=130) :: logline1, logline2
  ! ... set string for use with rcs ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... allocate space for read group 2 arrays
  ALLOCATE (uzelb(nxyz), uklb(nxyz), ubblb(nxyz),  &
       hwt(nxyz), &
       ui1z(nxyz), ui2z(nxyz), uj1z(nxyz), uj2z(nxyz), uk1z(nxyz), uk2z(nxyz), &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: read2"  
     STOP  
  ENDIF
  nsa = MAX(ns,1)
  nr = nx
  WRITE(logline1,'(a)') 'Reading static data for flow and transport simulation'
  CALL logprt_c(logline1)
  IF(.NOT.cylind) THEN  
     ! ... read aquifer description - spatial mesh data
     ! ...      rectangular coordinates
     READ(fuins, *) unigrx, unigry, unigrz  
     IF (print_rde) WRITE(furde, 8001) 'unigrx,unigry,unigrz,[2.2a.1]', unigrx, &
          unigry, unigrz
8001 FORMAT(tr5,a/tr5,8l5)  
     IF(unigrx) THEN  
        READ(fuins, *) x(1), x(nx)  
        IF (print_rde) WRITE(furde, 8002) 'x(1),x(nx),[2.2a.2a]', x(1) , x(nx)  
8002    FORMAT(tr5,a/(tr2,7(1pg12.5)))  
        delx = (x(nx) - x(1))/(nx - 1)  
        DO  i = 1, nx - 1  
           x(i + 1) = x(i) + delx  
        END DO
     ELSE  
        READ(fuins, *) (x(i), i = 1, nx)  
        IF (print_rde) WRITE(furde, 8002) '(x(i),i=1,nx),[2.2a.2b]',(x(i),i=1,nx)
     ENDIF
     IF(unigry) THEN  
        READ(fuins, *) y(1), y(ny)  
        IF (print_rde) WRITE(furde, 8002) 'y(1),y(ny),[2.2a.3a]', y(1) , y(ny)  
        dely = (y(ny) - y(1))/(ny - 1)  
        DO  j = 1, ny - 1  
           y(j + 1) = y(j) + dely  
        END DO
     ELSE  
        READ(fuins, *) (y(i), i = 1, ny)  
        IF (print_rde) WRITE(furde, 8002) '(y(i),i=1,ny),[2.2a.3b]',(y(i),i=1,ny)
     ENDIF
     IF(unigrz) THEN  
        READ(fuins, *) z(1), z(nz)  
        IF (print_rde) WRITE(furde, 8002) 'z(1),z(nz),[2.2a.4a]', z(1) , z(nz)  
        udelz = (z(nz) - z(1))/(nz - 1)  
        DO  k = 1, nz - 1  
           z(k + 1) = z(k) + udelz  
        END DO
     ELSE  
        READ(fuins, *) (z(i), i = 1, nz)  
        IF (print_rde) WRITE(furde, 8002) '(z(i),i=1,nz),[2.2a.4b]', (z(i),i=1,nz)
     ENDIF
  ELSE  
     ! ... Cylindrical r-z grid - single well
     READ(fuins, *) x(1), x(nr), argrid  
     IF (print_rde) WRITE(furde, 8003) 'x(1),x(nr),argrid,[2.2b.1a]', x(1), x(nr) ,argrid
8003 FORMAT(tr5,a/tr5,2(1pg10.3),l5)  
     ! ... Radial cell node locations
     IF(.NOT.argrid) THEN  
        READ(fuins, *) (x(i), i = 1, nr)  
        IF (print_rde) WRITE(furde, 8002) '(x(i),i=1,nr),[2.2b.1b]', (x(i),i=1,nr)
     ELSEIF(argrid) THEN  
        ! ... divide the cylindrical grid
        u1 = (x(nr) / x(1)) **(1._kdp/(nr - 1._kdp))  
        ! ... r is node location
        DO  i = 1, nr - 1  
           x(i + 1) = x(i) * u1  
        END DO
     ENDIF
     ny = 1  
     y(1) = 0._kdp
     READ(fuins, *) unigrz  
     IF (print_rde) WRITE(furde, 8001) 'unigrz,[2.2b.2]', unigrz  
     IF(unigrz) THEN  
        READ(fuins, *) z(1), z(nz)  
        IF (print_rde) WRITE(furde, 8002) 'z(1),z(nz),[2.2b.3a]', z(1) , z(nz)  
        udelz = (z(nz) - z(1))/(nz - 1)  
        DO  k = 1, nz - 1  
           z(k + 1) = z(k) + udelz  
        END DO
     ELSE  
        READ(fuins, *) (z(i), i = 1, nz)  
        IF (print_rde) WRITE(furde, 8002) '(z(i),i=1,nz),[2.2b.3b]', (z(i),i=1,nz)
     ENDIF
  ENDIF
  ! ... load x,y,z coordinates for each cell
  DO  m = 1, nxyz  
     CALL mtoijk(m, i, j, k, nx, ny)  
     x_node(m) = x(i)  
     y_node(m) = y(j)  
     z_node(m) = z(k)  
  END DO
  ! ... calculate element centroids
  DO  i=1,nx-1  
     x_face(i) = .5*(x(i) + x(i+1))  
  END DO
  DO  j=1,ny-1  
     y_face(j) = .5*(y(j) + y(j+1))  
  END DO
  DO  k=1,nz-1  
     z_face(k) = .5*(z(k) + z(k+1))  
  END DO
  tilt = .FALSE.  
  IF(.NOT.cylind) THEN  
     READ(fuins, *) tilt  
     IF (print_rde) WRITE(furde, 8001) 'tilt,[2.3.1]', tilt  
     IF(tilt) THEN  
        READ(fuins, *) thetxz, thetyz, thetzz  
        IF (print_rde) WRITE(furde, 8002) 'thetxz,thetyz,thetzz,[2.3.2]', thetxz, thetyz, thetzz
     ENDIF
  ENDIF
  ! ... fluid compresibility
  READ(fuins, *) bp  
  IF (print_rde) WRITE(furde, 8002) 'bp,[2.4.1]', bp  
  ! ... w0 and w1 are minimum and maximum mass fractions for descaling
  ! ...      the input and rescaling the output
  ! ... fluid density data
  READ(fuins, *) p0, t0, w0, denf0  
  IF (print_rde) WRITE(furde, 8002) 'p0,t0,w0,denf0,[2.4.2]', p0, t0, w0, denf0  
  IF(solute) THEN  
     READ(fuins, *) w1, denf1  
     IF (print_rde) WRITE(furde, 8002) 'w1,denf1,[2.4.3]', w1, denf1  
  ENDIF
  ! ... fluid viscosity data factor
  READ(fuins, *) visfac  
  IF (print_rde) WRITE(furde, 8004) 'visfac,[2.4.4]', visfac  
8004 FORMAT(tr5,a/tr5,1pg10.3)  
  ! ... atmospheric presure (absolute)
  READ(fuins, *) paatm  
  IF (print_rde) WRITE(furde, 8002) 'paatm,[2.5.1]', paatm  
  ! ... reference pressure and temperature for enthalpy, linear variations
  READ(fuins, *) p0h, t0h  
  IF (print_rde) WRITE(furde, 8002) 'p0h,t0h,[2.5.2]', p0h, t0h  
  ! ... fluid thermal properties
  IF(heat) THEN  
     READ(fuins, *) cpf, kthf, bt  
     IF (print_rde) WRITE(furde, 8002) 'cpf,kthf,bt,[2.6]', cpf, kthf, bt  
  ENDIF
  IF(solute) THEN  
     ! ... solute properties
     READ(fuins, *) dm  
     IF (print_rde) WRITE(furde, 8002) 'dm,[2.7]', dm  
  ENDIF
  ! ... porous media physical properties
  ! ...      porous media zones
  IF (print_rde) WRITE(furde, 8005) 'ipmz,x1z,x2z,y1z,', 'y2z,z1z,z2z,[2.8.1]'  
8005 FORMAT(tr5,2a/tr5,a/tr10,a)  
  npmz = 0  
110 READ(fuins, '(a)') line  
  ic = INDEX(line(1:20) , 'END')  
  IF(ic == 0) ic = INDEX(line(1:20),'end')  
  IF(ic > 0) GOTO 120  
  BACKSPACE(unit = fuins)  
  READ(fuins, *) ipmz, x1z, x2z, y1z, y2z, z1z, z2z  
  IF (print_rde) WRITE(furde, 8006) ipmz, x1z, x2z, y1z, y2z, z1z, z2z  
8006 FORMAT(tr5,i5,6(1pg11.3))  
  npmz = MAX(npmz, ipmz)  
  uj1z(ipmz) = 1  
  uj2z(ipmz) = 1  
  erflg = .FALSE.  
  CALL incidx(x1z, x2z, nx-1, x_face, ui1z(ipmz), ui2z(ipmz), erflg)
  ui2z(ipmz) = ui2z(ipmz) + 1  
  IF(.NOT.cylind) THEN  
     CALL incidx(y1z, y2z, ny-1, y_face, uj1z(ipmz), uj2z(ipmz), erflg)
     uj2z(ipmz) = uj2z(ipmz) + 1  
  ENDIF
  CALL incidx(z1z, z2z, nz-1, z_face, uk1z(ipmz), uk2z(ipmz), erflg)
  uk2z(ipmz) = uk2z(ipmz) + 1  
  IF(erflg) THEN 
     logline1 = 'incidx interpolation error in read2, porous media zones'
     CALL errprt_c(logline1)
     WRITE(logline2, 9002) cnvli* x1z, cnvli* x2z, cnvli* y1z, cnvli* &
          y2z, cnvli* z1z, cnvli* z2z
9002 FORMAT(6(1pg13.4))
     CALL errprt_c(logline2)
     ierr(138) = .TRUE.  
     errexe = .TRUE.  
  ENDIF
  GOTO 110  
120 CONTINUE  
  ! ... allocate the zone arrays
  ALLOCATE (abpm(npmz), alphl(npmz), alphth(npmz), alphtv(npmz), poros(npmz), &
       kthx(1), kthy(1), kthz(1),  &
       kx(npmz), ky(npmz), kz(npmz),  &
       kxx(npmz),kyy(npmz),kzz(npmz),rcppm(1), &
       i1z(npmz), i2z(npmz), j1z(npmz), j2z(npmz), k1z(npmz), k2z(npmz), &
       stat = a_err)
  IF(a_err.NE.0) THEN  
     PRINT * , "array allocation failed: read2"  
     STOP  
  ENDIF
  DO ipmz = 1, npmz
     i1z(ipmz) = ui1z(ipmz)
     i2z(ipmz) = ui2z(ipmz)
     j1z(ipmz) = uj1z(ipmz)
     j2z(ipmz) = uj2z(ipmz)
     k1z(ipmz) = uk1z(ipmz)
     k2z(ipmz) = uk2z(ipmz)
  END DO
  ! ... permeability
  READ(fuins, *) (kxx(ipmz), ipmz = 1, npmz)  
  READ(fuins, *) (kyy(ipmz), ipmz = 1, npmz)  
  READ(fuins, *) (kzz(ipmz), ipmz = 1, npmz)  
  IF(cylind) THEN  
     DO  ipmz = 1, npmz  
        kyy(ipmz) = 0._kdp
     END DO
  ENDIF
  IF (print_rde) WRITE(furde,8007) '(kxx(ipmz),kyy(ipmz),kzz(ipmz),','ipmz=1,npmz),[2.9.1]', &
       (kxx(ipmz),kyy(ipmz),kzz(ipmz),ipmz=1,npmz)
8007 FORMAT(tr5,2a/(tr5,3(1pg12.4)))  
  ! ... porosity
  READ(fuins, *) (poros(i), i = 1, npmz)  
  IF (print_rde) WRITE(furde, 8002) '(poros(i),i=1,npmz),[2.9.2]', (poros(i) , i = 1, npmz)
  ! ... porous media compressibilities
  READ(fuins, *) (abpm(i), i = 1, npmz)  
  IF (print_rde) WRITE(furde, 8002) '(abpm(i),i=1,npmz),[2.9.3]', (abpm(i) , i =1, npmz)
!!$  IF(heat) THEN  
!!$     READ(fuins, *) (rcppm(i), i = 1, npmz)  
!!$     IF (print_rde) WRITE(furde, 8002) '(rcppm(i),i=1,npmz),[2.10.1]', (rcppm(i), i = 1, npmz)
!!$     READ(fuins, *) (kthxpm(i), kthypm(i), kthzpm(i), i = 1,npmz)
!!$     IF(cylind) THEN  
!!$        DO  ipmz = 1, npmz  
!!$           kthypm(ipmz) = 0.d0  
!!$        END DO
!!$     ENDIF
!!$     IF (print_rde) WRITE(furde, 8007) '(kthxpm(i),kthypm(i),kthzpm(i)', 'i=1,npmz),[2.10.2]', &
!!$          (kthxpm(i) , kthypm(i) , kthzpm(i) , i = 1, npmz)
!!$  ENDIF
  ! ... dispersivities for solute and heat
  IF(solute.OR.heat) THEN  
     READ(fuins, *) (alphl(i), i = 1, npmz)  
     READ(fuins,*) (alphth(i),i=1,npmz)  
     READ(fuins,*) (alphtv(i),i=1,npmz)  
     IF (print_rde) WRITE(furde, 8008) '(alphl(i),alphth(i),alphtv(npmz),i=1,npmz)', '[2.11]', &
          (alphl(i),alphth(i),alphtv(npmz),i=1,npmz)
8008 FORMAT(tr5,2a/(tr5,3(1pg12.4)))  
  ENDIF
  ! ... well bore model information
  IF(nwel.GT.0) THEN  
     ! ... Well bore location and structural data
     ! ... Allocate scratch space for well data
     ALLOCATE (uwid(nxy), uuxw(nxy), uuyw(nxy), uuzwb(nxy), uuzwt(nxy), &
          uudwb(nxy), uudwt(nxy), &
          uwbod(nxy), uwqm(nxy), uumwel(nxy,nz), &
          uuwcfl(nxy,nz), uuwcfu(nxy,nz), unkswel(nxy), &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2"  
        STOP  
     ENDIF
     uumwel = 0
     uuwcfl = 0.0_kdp
     uuwcfu = 0.0_kdp
     IF (print_rde) WRITE(furde, 8005) 'welidno(iwel),xw(iwel),yw(iwel),zwb(iwel),zwt(iwel),', &
          'dwb(iwel),dwt(iwel),wbod(iwel),wqmeth(iwel),[2.13.1]'
     iwel = 0  
160  READ(fuins, '(a)') line  
     ic = INDEX(line(1:20) , 'END')  
     IF(ic == 0) ic = INDEX(line(1:20) , 'end')  
     IF(ic > 0) THEN  
        nwel = iwel  
        GOTO 180  
     ENDIF
     BACKSPACE(unit = fuins)  
     READ(fuins, *) uwelidno, uxw, uyw, uzwb, uzwt, udwb, udwt, uwb, uwq  
     iwel = iwel + 1  
     IF(iwel.GT.nxy) GOTO 170  
     uwid(iwel) = uwelidno  
     uuxw(iwel) = uxw  
     uuyw(iwel) = uyw
     uuzwb(iwel) = uzwb
     uuzwt(iwel) = uzwt
     uudwb(iwel) = udwb
     uudwt(iwel) = udwt
     uwbod(iwel) = uwb  
     uwqm(iwel) = uwq  
     IF (print_rde) WRITE(furde, 8009) uwid(iwel), uuxw(iwel), uuyw(iwel), uuzwb(iwel),  &
          uuzwt(iwel), &
          uudwb(iwel), uudwt(iwel), uwbod(iwel), uwqm(iwel)
8009 FORMAT(tr5,i5,7(1pg10.3),i5)  
     ! ... Read well completion cells and screen lengths in lower and upper parts
     ks = 0  
165  READ(fuins, '(a)') line  
     ic = INDEX(line(1:20) , 'END')  
     IF(ic == 0) ic = INDEX(line(1:20),'end')  
     IF(ic > 0) THEN
        unkswel(iwel) = ks
        GOTO 159  
     ENDIF
     BACKSPACE(unit = fuins)  
     READ(fuins,*) umwel, uwcfl, uwcfu  
     ks = ks + 1  
     uumwel(iwel,ks) = umwel  
     uuwcfl(iwel,ks) = uwcfl
     uuwcfu(iwel,ks) = uwcfu
     GOTO 165  
159  CONTINUE  
     IF (print_rde) WRITE(furde, 8010) '(mwel(iwel,ks),wcfl(iwel,ks),wcfu(iwel,ks), '//  &
          'ks=1,nkswel(iwel)),[2.13.2]',   &
          (uumwel(iwel,ks), uuwcfl(iwel,ks), uuwcfu(iwel,ks), ks=1,unkswel(iwel))
8010 FORMAT(tr5,a/tr5,8(i5,1pg10.2,1pg10.2,tr4))  
     ! ... no well riser calculations allowed in phast
     GOTO 160  
170  ierr(116) = .TRUE.  
     RETURN  
180  CONTINUE  
     nwel=iwel
     ! ... allocate and load the final well arrays
     ALLOCATE (welidno(nwel), xw(nwel), yw(nwel), wbod(nwel), wqmeth(nwel),  &
          mwel(nwel,nz), wcfl(nwel,nz), wcfu(nwel,nz), zwb(nwel), zwt(nwel),  &
          dwb(nwel), dwt(nwel),  &
          wfrac(nwel), nkswel(nwel),  &
          mxf_wel(nwel), &
          stat = a_err)
     IF (a_err.NE.0) THEN  
        PRINT *, "array allocation failed: read2"  
        STOP  
     ENDIF
     DO iwel=1,nwel
        welidno(iwel) = uwid(iwel)  
        xw(iwel) = uuxw(iwel)  
        yw(iwel) = uuyw(iwel)  
        zwb(iwel) = uuzwb(iwel)
        zwt(iwel) = uuzwt(iwel)
        dwb(iwel) = uudwb(iwel)
        dwt(iwel) = uudwt(iwel)
        wbod(iwel) = uwbod(iwel)  
        wqmeth(iwel) = uwqm(iwel)  
        DO ks=1,nz
           mwel(iwel,ks) = uumwel(iwel,ks)
           wcfl(iwel,ks) = uuwcfl(iwel,ks)
           wcfu(iwel,ks) = uuwcfu(iwel,ks)
        END DO
        nkswel(iwel) = unkswel(iwel)
     END DO
     ! ... deallocate scratch space for well data and zones
     DEALLOCATE (ui1z, ui2z, uj1z, uj2z, uk1z, uk2z, &
          uwid, uuxw, uuyw, uuzwb, uuzwt, uudwb, uudwt, uwbod, uwqm, uumwel,  &
          uuwcfl, uuwcfu, unkswel, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed"  
        STOP  
     ENDIF
  ENDIF
  ! ... boundary conditions
  ! ... specified p,t,or c b.c.
  icall = 1  
  IF(nsbc.GT.0) CALL irewi(ibc, icall, 101)  
  ! ... specified flux b.c.
  icall = 2  
  IF(nfbc.GT.0) CALL irewi(ibc, icall, 102)  
  ! ... aquifer leakage b.c.
  IF(nlbc.GT.0) THEN  
     icall = 3  
     CALL irewi(ibc, icall, 103)  
     CALL rewi3(uklb, ubblb, uzelb, 31, 131)  
  ENDIF
  IF(nrbc > 0) THEN  
     ! ... river information
     ! ... allocate scratch space for river data
     ALLOCATE (umrbc(nxy), uarbc(nxy), ukrb(nxy), uzerb(nxy), &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2"  
        STOP  
     ENDIF
     ls = 0
     lc = 0
     READ(fuins, '(a)') line  
     ic = INDEX(line(1:20) , 'END')  
     IF(ic.EQ.0) ic = INDEX(line(1:20) , 'end')  
     IF(ic.GT.0) GOTO 230  
     IF (print_rde) WRITE(furde, 8005) '** river leakage parameters **',  &
          '  (read echo[2.16.3])',  &
          ' mrbc', '     arbc    kbrbc    zerbc'
     BACKSPACE(unit = fuins)  
210  READ(fuins, '(a)') line  
     ic = INDEX(line(1:20) , 'END')  
     IF(ic.EQ.0) ic = INDEX(line(1:20) , 'end')  
     IF(ic.GT.0) GOTO 230  
     BACKSPACE(unit = fuins)  
     ls = ls + 1  
     READ(fuins,*) umrbc(ls), uarbc(ls), ukrb(ls), uzerb(ls)  
     IF (print_rde) WRITE(furde,8013) umrbc(ls), uarbc(ls), ukrb(ls), uzerb(ls)  
8013 FORMAT(tr1,i10,4(1pg11.3))
     m = umrbc(ls)          ! ... surface trace cells  
     WRITE(cibc, 6001) ibc(m)  
6001 FORMAT (i9)  
     IF(cibc(3:3) /= '6' .AND. cibc(3:3) /= '8') THEN
        ibc(m) = ibc(m) + 6000000
        lc = lc + 1
     END IF
     GOTO 210
230  CONTINUE
     nrbc_seg = ls
     nrbc_cells = lc
     nrbc = nrbc_cells
     ALLOCATE (mrbc(nrbc_seg), arbc(nrbc_seg), brbc(nrbc_seg), krbc(nrbc_seg), bbrbc(nrbc_seg),  &
          mrbc_bot(nrbc), mrseg_bot(nrbc_seg), zerbc(nrbc_seg), &
          crbc(nrbc_seg,nsa), indx1_rbc(nrbc_seg), indx2_rbc(nrbc_seg), mxf_rbc(nrbc_seg),  &
          qfrbc(nrbc), ccfrb(nrbc), ccfvrb(nrbc), qsrbc(nrbc,nsa), ccsrb(nrbc,nsa), &
          sfrb(nrbc), sfvrb(nrbc), ssrb(nrbc,nsa), &
          phirbc(nrbc_seg), denrbc(nrbc_seg), visrbc(nrbc_seg), &
          river_seg_index(nrbc),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2"  
        STOP  
     ENDIF
     DO ls=1,nrbc_seg
        mrbc(ls) = umrbc(ls)  
        arbc(ls) = uarbc(ls)  
        krbc(ls) = ukrb(ls)  
        bbrbc(ls) = 1._kdp
        zerbc(ls) = uzerb(ls)      
     END DO
     ! ... deallocate scratch space for river data
     DEALLOCATE (umrbc, uarbc, ukrb, uzerb, &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed"  
        STOP  
     ENDIF
  ENDIF
!!$  if(naifc.gt.0) then  
!!$     !... ***  not implemented for phast
!!$     ! ... aquifer influence function b.c.
!!$     do 240 m = 1, nxyz  
!!$        uvaifc(m) = 1.d0  
!!$240  end do
!!$     icall = 4  
!!$     call irewi(ibc, icall, 104)  
!!$     call rewi(uvaifc, 41, 141)  
!!$     read(fuins, *) iaif  
!!$     if (print_rde) write(furde, 8014) 'iaif,[2.18.3]', iaif  
!!$8014 format   (tr5,a/tr5,8i5)  
!!$     if(iaif.eq.1) then  
!!$        ! ... pot aquifer influence function
!!$        read(fuins, *) aboar, poroar, voar  
!!$        if (print_rde) write(furde, 8002) 'aboar,poroar,voar,[2.18.4a]', aboar, &
!!$             poroar, voar
!!$     endif
!!$     if(iaif.eq.2) then  
!!$        ! ... transient, carter-tracy influence function
!!$        read(fuins, *) koar, aboar, visoar, poroar, boar, rioar, &
!!$             angoar
!!$        if (print_rde) write(furde, 8002) 'koar,aboar,visoar,poroar,boar,rioar,angoar,[2 &
!!$             &.18.4b]', koar, aboar, visoar, poroar, boar, rioar, angoar
!!$     endif
!!$  endif
  ! ... heat conduction b.c.
  !... ***  not available for phast
  READ(fuins, *) fresur, temp_logical
  IF (print_rde) WRITE(furde, 8001) 'fresur,[2.20], adjust_wr_ratio', fresur, temp_logical
  adj_wr_ratio = 0 
  if (temp_logical) adj_wr_ratio = 1 
  transient_fresur = 0
  if (fresur .AND. .NOT.steady_flow) transient_fresur = 1
  ! ... initial conditions
  ichydp = .FALSE.  
  ichwt = .FALSE.  
  READ(fuins, *) ichydp  
  IF (print_rde) WRITE(furde, 8001) 'ichydp,[2.21.1]', ichydp  
  IF(fresur) THEN  
     READ(fuins, *) ichwt  
     IF (print_rde) WRITE(furde, 8001) 'ichwt,[2.21.2]', ichwt  
  ENDIF
  ! ... i.c. distributions
  ! ... p at a z-level for hydrostatic pressure distribution
  IF(ichydp.AND..NOT.ichwt) THEN  
     READ(fuins, *) zpinit, pinit  
     IF (print_rde) WRITE(furde, 8002) 'zpinit,pinit,[2.21.3a]', zpinit, pinit  
  ELSEIF(fresur.AND.ichwt) THEN  
     CALL rewi(hwt, 102, 94)  
  ELSE  
     CALL rewi(p, 101, 93)  
  ENDIF
  ! ... temperature for the region for i.c.
!!$  IF(heat) THEN  
!!$     CALL rewi(t, 103, 95)  
!!$     ! ... temperature vs. distance i.c. for heat conduction b.c.
!!$     IF(nhcbc.GT.0) THEN  
!!$        READ(fuins, *) nztphc, (zthc(i), tvzhc(i), i = 1, &
!!$             nztphc)
!!$        IF (print_rde) WRITE(furde, 8015) 'nztphc,(zthc(i),tvzhc(i),i=1,nztphc),', &
!!$             '[2.21.5]', nztphc, (zthc(i) , tvzhc(i) , i = 1, nztphc)
!!$8015    FORMAT      (tr5,2a/tr5,i5/(tr5,12(1pg10.3)))  
!!$     ENDIF
!!$  ENDIF
  ! ... mass fraction for the region for i.c.
  IF(solute) THEN  
     CALL indx_rewi(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, 1, 03, 100)  
     CALL indx_rewi(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, 2, 03, 100)  
     CALL indx_rewi(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, 3, 03, 100)  
     CALL indx_rewi(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, 4, 03, 100)  
     CALL indx_rewi(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, 5, 03, 100)  
     CALL indx_rewi(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, 6, 03, 100)  
     CALL indx_rewi(indx_sol1_ic, indx_sol2_ic, ic_mxfrac, 7, 03, 100)  
  ENDIF
  ! ... calculation data - solution time & space differencing
  ! ...      method factors
  READ(fuins, *) fdsmth, fdtmth  
  IF (print_rde) WRITE(furde, 8002) 'fdsmth,fdtmth,[2.22.1]', fdsmth, fdtmth  
  crosd = .FALSE.
  IF(solute) THEN
     ! ... cross dispersion calculation
     READ(fuins,*) crosd
     IF (print_rde) WRITE(furde,8001) 'crosd,[2.22.1a]', crosd
     ! ... cross dispersion calculation
     READ(fuins,*) rebalance_fraction_f, rebalance_method_f
     IF (print_rde) WRITE(furde,"(tr5,a/tr5,1pg12.5)") 'rebalance_fraction', rebalance_fraction_f
     IF (print_rde) WRITE(furde,"(tr5,a/tr5,i12)") 'rebalance_method', rebalance_method_f
  ENDIF
  READ(fuins, *) tolden, maxitn  
  IF (print_rde) WRITE(furde, 8025) 'tolden,maxitn,[2.22.2]', tolden, maxitn  
8025 FORMAT(tr5,a/tr5,1pg10.4,i5)  
  IF(slmeth.EQ.3) THEN  
     ! ... red-black generalized conjugate gradient solver parameters
     READ(fuins, *) idir, milu, nsdr, epsslv, maxit2  
     IF (print_rde) WRITE(furde, 8018) 'idir,milu,nsdr,epsslv,maxit2,[2.22.4]', &
          idir, milu, nsdr, epsslv, maxit2
8018 FORMAT   (tr5,a/tr5,i5,l5,i5,1pg12.4,i5)  
  ENDIF
  IF(slmeth.EQ.5) THEN  
     ! ... d4 zig-zag generalized conjugate gradient solver data
     READ(fuins, *) idir, milu, nsdr, epsslv, maxit2  
     IF (print_rde) WRITE(furde, 8018) 'idir,milu,nsdr,epsslv,maxit2,[2.22.4]', &
          idir, milu, nsdr, epsslv, maxit2
  ENDIF
  ! ...  print requests for tables
  READ(fuins,*) prtpmp, prtfp, prtbc, prtslm, prtwel, prt_kd  
  IF (print_rde) WRITE(furde,8019) 'prtpmp,prtfp,prtbc,prtslm,prtwel,prt_kd,[2.23.1]',  &
       prtpmp, prtfp, prtbc, prtslm, prtwel, prt_kd
8019 FORMAT(tr5,2a/tr5,8l5)
  READ(fuins,*) prtic_c, prtic_mapc, prtic_p, prtic_maphead, prtss_vel, prtss_mapvel, &
       prtic_conc, prtic_force_chem
  IF (print_rde) WRITE(furde,8019) 'prtic_c, prtic_mapc, prtic_p, prtic_maphead, prtss_vel,'//  &
       'prtss_mapvel, '//  &
       'prtic_conc, prtic_force_chem, ',  &
       '[2.23.2]', prtic_c, prtic_mapc, prtic_p, prtic_maphead, prtss_vel, prtss_mapvel, &
       prtic_conc, prtic_force_chem
  ! ...  print requests for hdf files
  READ(fuins,*) prtichdf_conc, prtichdf_head, prtsshdf_vel
  IF (print_rde) WRITE(furde,8119) 'prtichdf_conc, prtichdf_head, prtsshdf_vel,[2.23.2.1]',  &
       prtichdf_conc, prtichdf_head, prtsshdf_vel
8119 FORMAT(tr5,a/tr5,3l5)
  ! set integer flags
  prhdfci = 0
  IF (prtichdf_conc) prhdfci = 1
  prhdfhi = 0
  IF (prtichdf_head) prhdfhi = 1
  prhdfvi = 0
  IF (prtsshdf_vel.AND.steady_flow) prhdfvi = 1
  prf_chem_phrqi = 0
  IF (prtic_force_chem) prf_chem_phrqi = 1
  prcphrqi = 0
  IF (prtic_conc) prcphrqi = 1
  prcpd = .FALSE.
  ! ... print-out orientation
  IF(.NOT.cylind) THEN  
     READ(fuins,*) orenpr  
     IF (print_rde) WRITE(furde,8014) 'orenpr,[2.23.3]', orenpr  
8014 FORMAT(tr5,a/tr5,8i5)
  ENDIF
  IF(prtpmp) THEN  
     READ(fuins,*) pltzon  
     IF (print_rde) WRITE(furde, 8001) 'pltzon,[2.23.4]', pltzon  
  ENDIF
  READ(fuins,*) prtic_well_timser
  IF (print_rde) WRITE(furde, 8011) 'prtic_well_timeseries,[2.23.5]', prtic_well_timser
8011 FORMAT(tr5,a/tr5,l5)  
  IF (solute) THEN
     icall = 8
     ! ... print conrol index for concentrations on a sub-grid
     CALL irewi(iprint_chem, icall, 125)
     ! ... Print control index for .xyz.chem concentrations on a sub-grid
     icall = 9
     call irewi(iprint_xyz, icall, 125)
  ENDIF
END SUBROUTINE read2
