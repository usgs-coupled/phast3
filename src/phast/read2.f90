SUBROUTINE read2  
  ! ... read all the data that are constant during the simulation
  USE f_units
  USE mcb
  USE mcb2
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcs
  USE mcv
  USE mcw
  USE mg2
  USE rewi_mod
  USE hdf_media
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
     FUNCTION uppercase(string) RESULT(outstring)
       IMPLICIT NONE
       CHARACTER(LEN=*), INTENT(IN) :: string
       CHARACTER(LEN=LEN(string)) :: outstring
     END FUNCTION uppercase
  END INTERFACE
  INTRINSIC index  
  CHARACTER(LEN=9) :: cibc  
  CHARACTER(LEN=130) :: line
  CHARACTER(LEN=130) :: ucline
  !$$  CHARACTER(LEN=130), EXTERNAL :: uppercase
  REAL(KIND=kdp) :: delx, dely, udelz, u1,  uwb, uxw, uyw, uzwb, uzwt, &
       udwb, udwt, &
       uwcfl, uwcfu, x1z, x2z, y1z, y2z, z1z, z2z
  INTEGER :: a_err, da_err
  INTEGER :: i, ic, icall, icol, ifc, ipmz, iwel, izn, j, k, ks, lc, ls, lsmax,  &
       m, nsa, umwel, uwelidno, uwq
  LOGICAL :: erflg
  LOGICAL :: temp_logical
  INTEGER :: nr, uibc
  INTEGER, DIMENSION(:), ALLOCATABLE :: ui1z, ui2z, uj1z, uj2z, uk1z, uk2z
  INTEGER, DIMENSION(:), ALLOCATABLE :: uwid, uwqm, unkswel
  INTEGER, DIMENSION(:,:), ALLOCATABLE :: uumwel
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: uuxw, uuyw, uuzwb, uuzwt, uudwb, uudwt, uwbod
  REAL(KIND=kdp), DIMENSION(:,:), ALLOCATABLE :: uuwcfl, uuwcfu
  INTEGER, DIMENSION(:), ALLOCATABLE :: umbc, uiface
  INTEGER, DIMENSION(:), ALLOCATABLE :: uzmic, uziface
  INTEGER, DIMENSION(:), ALLOCATABLE :: uzmbc
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: uabc, ubbbc, ukbc, uzebc
  CHARACTER(LEN=130) :: logline1, logline2
  ! ... set string for use with rcs ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... allocate space for read group 2 arrays
  !ALLOCATE (uzelb(nxyz), uklb(nxyz), ubblb(nxyz),  &
  ALLOCATE ( &
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
  ! ... Porous media physical properties
  ! ...      Porous media zones
  IF (print_rde) WRITE(furde, 8005) 'ipmz,x1z,x2z,y1z,', 'y2z,z1z,z2z,[2.8.1]'  
8005 FORMAT(tr5,2a/tr5,a/tr10,a)  
  npmz = 0
110 READ(fuins,'(a)') line  
  line = uppercase(line)
  ic=INDEX(line(1:20),'END')
  IF(ic > 0) GO TO 120
  READ(line, *) ipmz, x1z, x2z, y1z, y2z, z1z, z2z  
  IF (print_rde) WRITE(furde, 8006) ipmz, x1z, x2z, y1z, y2z, z1z, z2z  
8006 FORMAT(tr5,i5,6(1pg11.3))  
  npmz = MAX(npmz,ipmz)  
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
  ! ... Allocate the zone arrays
  ALLOCATE (abpm(npmz), alphl(npmz), alphth(npmz), alphtv(npmz), poros(npmz), &
       ss(npmz), &
       kthx(1), kthy(1), kthz(1),  &
       kx(npmz), ky(npmz), kz(npmz),  &
       kxx(npmz),kyy(npmz),kzz(npmz),rcppm(1), &
       i1z(npmz), i2z(npmz), j1z(npmz), j2z(npmz), k1z(npmz), k2z(npmz), &
       stat = a_err)
  IF(a_err /= 0) THEN  
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
  ! ... Permeability
  READ(fuins, *) (kxx(ipmz), ipmz = 1, npmz)  
  READ(fuins, *) (kyy(ipmz), ipmz = 1, npmz)  
  READ(fuins, *) (kzz(ipmz), ipmz = 1, npmz)  
  IF(cylind) THEN  
     kyy = 0._kdp
  ENDIF
  IF (print_rde) WRITE(furde,8007) '(kxx(ipmz),kyy(ipmz),kzz(ipmz),','ipmz=1,npmz),[2.9.1]', &
       (kxx(ipmz),kyy(ipmz),kzz(ipmz),ipmz=1,npmz)
8007 FORMAT(tr5,2a/(tr5,3(1pg12.4)))  
  ! ... Porosity
  READ(fuins,*) (poros(i), i = 1, npmz)  
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
  IF(solute .OR. heat) THEN  
     READ(fuins, *) (alphl(i), i = 1, npmz)  
     READ(fuins,*) (alphth(i),i=1,npmz)  
     READ(fuins,*) (alphtv(i),i=1,npmz)  
     IF (print_rde) WRITE(furde, 8008) '(alphl(i),alphth(i),alphtv(npmz),i=1,npmz)', '[2.11]', &
          (alphl(i),alphth(i),alphtv(npmz),i=1,npmz)
8008 FORMAT(tr5,2a/(tr5,3(1pg12.4)))  
  ENDIF
  ! ... Well bore model information
  IF(nwel > 0) THEN  
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
160  READ(fuins,'(a)') line  
     line = uppercase(line)
     ic=INDEX(line(1:20),'END')
     IF(ic > 0) GO TO 180
     READ(line, *) uwelidno, uxw, uyw, uzwb, uzwt, udwb, udwt, uwb, uwq  
     iwel = iwel + 1
     IF(iwel > nxy) GO TO 170  
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
     DO
        READ(fuins,'(a)') line
        line = uppercase(line)
        ic=INDEX(line(1:20),'END')
        IF(ic > 0) THEN
           unkswel(iwel) = ks
           GOTO 160
        ENDIF
        READ(line,*) umwel, uwcfl, uwcfu  
        ks = ks + 1
        m = umwel
        uumwel(iwel,ks) = umwel
        uuwcfl(iwel,ks) = uwcfl
        uuwcfu(iwel,ks) = uwcfu
        IF(ibc_string(m)(9:9) /= 'W') THEN
           cibc = ibc_string(m)(2:9)//'W'
           ibc_string(m) = cibc
        END IF
        IF (print_rde) WRITE(furde, 8010) '(mwel(iwel,ks),wcfl(iwel,ks),wcfu(iwel,ks), '//  &
             'ks=1,nkswel(iwel)),[2.13.2]',   &
             (uumwel(iwel,ks), uuwcfl(iwel,ks), uuwcfu(iwel,ks), ks=1,unkswel(iwel))
8010    FORMAT(tr5,a/tr5,8(i5,1pg10.2,1pg10.2,tr4))  
        ! ... no well riser calculations allowed in phast
     END DO
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
     IF (a_err /= 0) THEN  
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
  ! ... Boundary conditions
  ! ... Specified p,t,or c b.c.
  IF(nsbc > 0) THEN
     ! ... Allocate scratch space for specified value b.c. data
     ALLOCATE (umbc(nxyz),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, spec. value"  
        STOP
     ENDIF
     lsmax = 0
     IF (print_rde) WRITE(furde, 8005) '** Specified Value B.C. Parameters **',  &
          '  (read echo[2.16.3])',  &
          ' seg_no   msbc  svbc_type'
     DO
        READ(fuins,'(A)') line
        line = uppercase(line)
        ic=INDEX(line(1:20),'END')
        IF(ic > 0) EXIT
        READ(line,*) ls, umbc(ls), uibc
        IF (print_rde) WRITE(furde,8113) ls, umbc(ls), uibc
        m = umbc(ls)
        lsmax = MAX(ls, lsmax)
        WRITE(cibc,6001) uibc
        cibc(1:1) = cibc(7:7)
        cibc(4:4) = cibc(8:8)
        cibc(7:7) = cibc(9:9)
        cibc(8:8) = '0'
        cibc(9:9) = '0'
        READ(cibc,6001) ibc(m)
        IF(ibc_string(m)(8:8) /= 'S') THEN
           IF(cibc(7:7) == '1') cibc = ibc_string(m)(3:9)//'Ss'
           IF(cibc(7:7) == '0') cibc = ibc_string(m)(3:9)//'Sa'
           ibc_string(m) = cibc
        END IF
     END DO
     lc = 1
     m = umbc(1)
     DO ls=2,lsmax
        IF(umbc(ls) == m) CYCLE
        lc = lc+1
        m = umbc(ls)
     END DO
     nsbc_seg = lsmax
     nsbc_cells = lc
     nsbc = nsbc_cells
     nsa = MAX(ns,1)
     ALLOCATE (msbc(nsbc_seg),  &
          psbc(nsbc_seg), csbc(nsbc_seg,nsa), indx1_sbc(nsbc_seg), indx2_sbc(nsbc_seg), mxf_sbc(nsbc_seg),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, svbc.2"  
        STOP  
     ENDIF
     DO ls=1,nsbc_seg
        msbc(ls) = umbc(ls)
     END DO
     ! ... Deallocate scratch space for svbc data
     DEALLOCATE (umbc,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed"  
        STOP
     ENDIF
  ENDIF
  ! ... Specified flux b.c.
  IF(nfbc > 0) THEN
     ! ... Allocate scratch space for flux data
     ALLOCATE (umbc(nxyz), uiface(nxyz), uabc(nxyz),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, flux"  
        STOP
     ENDIF
     lsmax = 0
     IF (print_rde) WRITE(furde, 8005) '** Flux B.C. Parameters **',  &
          '  (read echo[2.16.3])',  &
          ' seg_no   mfbc', '     iface      afbc'
     DO
        READ(fuins,'(A)') line
        line = uppercase(line)
        ic=INDEX(line(1:20),'END')
        IF(ic > 0) EXIT
        READ(line,*) ls, umbc(ls), uiface(ls), uabc(ls)
        IF (print_rde) WRITE(furde,8113) ls, umbc(ls), uiface(ls), uabc(ls) 
8113    FORMAT(tr1,3i8,4(1pg11.3))
        m = umbc(ls)
        lsmax = MAX(ls, lsmax)
        WRITE(cibc,6001) ibc(m)
6001    FORMAT (i9.9)
        ifc = uiface(ls)
        IF(cibc(ifc:ifc) /= '2') THEN
           cibc(ifc:ifc) = '2'
           READ(cibc,6001) ibc(m)
        END IF
        IF(ibc_string(m)(9:9) /= 'F') THEN
           cibc = ibc_string(m)(2:9)//'F'
           ibc_string(m) = cibc
        END IF
     END DO
     lc = 1
     m = umbc(1)
     DO ls=2,lsmax
        IF(umbc(ls) == m) CYCLE
        lc = lc+1
        m = umbc(ls)
     END DO
     nfbc_seg = lsmax
     nfbc_cells = lc
     nfbc = nfbc_cells
     nsa = MAX(ns,1)
     ALLOCATE (mfbc(nfbc_seg), ifacefbc(nfbc_seg), areafbc(nfbc_seg),  &
          qfflx(nfbc_seg), denfbc(nfbc_seg), qsflx(nfbc_seg,nsa),  &
          cfbc(nfbc_seg,nsa), indx1_fbc(nfbc_seg), indx2_fbc(nfbc_seg), mxf_fbc(nfbc_seg),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, flux.2"  
        STOP  
     ENDIF
     DO ls=1,nfbc_seg
        mfbc(ls) = umbc(ls)
        ifacefbc(ls) = uiface(ls)
        areafbc(ls) = uabc(ls)
     END DO
     ! ... Deallocate scratch space for flux data
     DEALLOCATE (umbc, uiface, uabc,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed"  
        STOP
     ENDIF
  ENDIF
  ! ... Aquifer leakage b.c.
  IF(nlbc > 0) THEN  
     ! ... Allocate scratch space for leakage data
     ALLOCATE (umbc(nxyz), uiface(nxyz), uabc(nxyz), ukbc(nxyz), ubbbc(nxyz), uzebc(nxyz),  &
          stat = a_err)
     IF (a_err /= 0) THEN
        PRINT *, "array allocation failed: read2, leakage"  
        STOP
     ENDIF
     lsmax = 0
     IF (print_rde) WRITE(furde, 8005) '** Aquifer Leakage Parameters **',  &
          '  (read echo[2.16.3])',  &
          'seg_no   mlbc', '     iface    albc    klbc    bblbc   zelbc'
     DO
        READ(fuins,'(A)') line
        line = uppercase(line)
        ic=INDEX(line(1:20),'END')
        IF(ic > 0) EXIT
        READ(line,*) ls, umbc(ls), uiface(ls), uabc(ls), ukbc(ls), ubbbc(ls), uzebc(ls)  
        IF (print_rde) WRITE(furde,8113) ls, umbc(ls), uiface(ls), uabc(ls), ukbc(ls),  &
             ubbbc(ls), uzebc(ls)
        m = umbc(ls)
        lsmax = MAX(ls, lsmax)
        WRITE(cibc,6001) ibc(m)  
        ifc = uiface(ls)
        IF(cibc(ifc:ifc) /= '3') THEN
           cibc(ifc:ifc) = '3'
           READ(cibc,6001) ibc(m)
        END IF
        IF(ibc_string(m)(9:9) /= 'L') THEN
           cibc = ibc_string(m)(2:9)//'L'
           ibc_string(m) = cibc
        END IF
     END DO
     lc = 1
     m = umbc(1)
     DO ls=2,lsmax
        IF(umbc(ls) == m) CYCLE
        lc = lc+1
        m = umbc(ls)
     END DO
     nlbc_seg = lsmax
     nlbc_cells = lc
     nlbc = nlbc_cells
     nsa = MAX(ns,1)
     ALLOCATE (mlbc(nlbc_seg), ifacelbc(nlbc_seg), arealbc(nlbc_seg),  &
          albc(nlbc_seg), blbc(nlbc_seg),  &
          klbc(nlbc_seg), bblbc(nlbc_seg), zelbc(nlbc_seg), &
          philbc(nlbc_seg), denlbc(nlbc_seg), vislbc(nlbc_seg),  &
          clbc(nlbc_seg,nsa), indx1_lbc(nlbc_seg), indx2_lbc(nlbc_seg), mxf_lbc(nlbc_seg),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, leak.2"  
        STOP
     ENDIF
     DO ls=1,nlbc_seg
        mlbc(ls) = umbc(ls)
        ifacelbc(ls) = uiface(ls)
        arealbc(ls) = uabc(ls)
        klbc(ls) = ukbc(ls)
        bblbc(ls) = ubbbc(ls)
        zelbc(ls) = uzebc(ls)
     END DO
     ! ... Deallocate scratch space for leakage data
     DEALLOCATE (umbc, uiface, uabc, ukbc, ubbbc, uzebc,  &
          stat = da_err)
     IF (da_err /= 0) THEN
        PRINT *, "array deallocation failed"
        STOP
     ENDIF
  ENDIF
  ! ... River b.c. 
  IF(nrbc > 0) THEN  
     ! ... Allocate scratch space for river data
     ALLOCATE (umbc(nxy), uabc(nxy), ukbc(nxy), uzebc(nxy),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, river"  
        STOP
     ENDIF
     lsmax = 0
     IF (print_rde) WRITE(furde, 8005) '** River Leakage Parameters **',  &
          '  (read echo[2.16.3])',  &
          'seg_no   mrbc', '     arbc    kbrbc    zerbc'
     DO
        READ(fuins,'(A)') line
        line = uppercase(line)
        ic=INDEX(line(1:20),'END')
        IF(ic > 0) EXIT
        READ(line,*) ls, umbc(ls), uabc(ls), ukbc(ls), uzebc(ls)  
        IF (print_rde) WRITE(furde,8013) ls, umbc(ls), uabc(ls), ukbc(ls), uzebc(ls)  
8013    FORMAT(tr1,2i8,4(1pg11.3))
        m = umbc(ls)          ! ... surface trace cells  
        lsmax = MAX(ls, lsmax)
        WRITE(cibc,6001) ibc(m)  
        IF(cibc(3:3) /= '6' .AND. cibc(3:3) /= '8') THEN
           ibc(m) = ibc(m) + 6000000
        END IF
        IF(ibc_string(m)(9:9) /= 'R') THEN
           cibc = ibc_string(m)(2:9)//'R'
           ibc_string(m) = cibc
        END IF
     END DO
     lc = 1
     m = umbc(1)
     DO ls=2,lsmax
        IF(umbc(ls) == m) CYCLE
        lc = lc+1
        m = umbc(ls)
     END DO
     nrbc_seg = lsmax
     nrbc_cells = lc
     nrbc = nrbc_cells
     nsa = MAX(ns,1)
     ALLOCATE (mrbc(nrbc_seg), arearbc(nrbc_seg),  &
          arbc(nrbc_seg), brbc(nrbc_seg),  &
          krbc(nrbc_seg), bbrbc(nrbc_seg), zerbc(nrbc_seg),  &
          mrseg_bot(nrbc_seg),  &
          phirbc(nrbc_seg), denrbc(nrbc_seg), visrbc(nrbc_seg),  &
          crbc(nrbc_seg,nsa), indx1_rbc(nrbc_seg), indx2_rbc(nrbc_seg), mxf_rbc(nrbc_seg),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, river.2"  
        STOP
     ENDIF
     DO ls=1,nrbc_seg
        mrbc(ls) = umbc(ls)
        arearbc(ls) = uabc(ls)
        krbc(ls) = ukbc(ls)
        bbrbc(ls) = 1._kdp
        zerbc(ls) = uzebc(ls)      
     END DO
     ! ... deallocate scratch space for river data
     DEALLOCATE (umbc, uabc, ukbc, uzebc,  &
          stat = da_err)
     IF (da_err /= 0) THEN  
        PRINT *, "array deallocation failed"  
        STOP
     ENDIF
  ENDIF
  ! ... Drain b.c. 
  IF(ndbc > 0) THEN  
     ! ... Allocate scratch space for river data
     ALLOCATE (umbc(nxy), uabc(nxy), ukbc(nxy), uzebc(nxy),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, drain"  
        STOP
     ENDIF
     lsmax = 0
     IF (print_rde) WRITE(furde, 8005) '** Drain Parameters **',  &
          '  (read echo[2.16.3])',  &
          'seg_no   mdbc', '     adbc    kbdbc    zedbc'
     DO
        READ(fuins,'(A)') line
        line = uppercase(line)
        ic=INDEX(line(1:20),'END')
        IF(ic > 0) EXIT
        READ(line,*) ls, umbc(ls), uabc(ls), ukbc(ls), uzebc(ls)  
        IF (print_rde) WRITE(furde,8013) ls, umbc(ls), uabc(ls), ukbc(ls), uzebc(ls)  
        m = umbc(ls)          ! ... drain cells  
        lsmax = MAX(ls, lsmax)
        WRITE(cibc,6001) ibc(m)
        IF(cibc(3:3) /= '7' .AND. cibc(3:3) /= '9') THEN
           ibc(m) = ibc(m) + 7000000
        END IF
        IF(ibc_string(m)(9:9) /= 'D') THEN
           cibc = ibc_string(m)(2:9)//'D'
           ibc_string(m) = cibc
        END IF
     END DO
     lc = 1
     m = umbc(1)
     DO ls=2,lsmax
        IF(umbc(ls) == m) CYCLE
        lc = lc+1
        m = umbc(ls)
     END DO
     ndbc_seg = lsmax
     ndbc_cells = lc
     ndbc = ndbc_cells
     nsa = MAX(ns,1)
     ALLOCATE (mdbc(ndbc_seg), areadbc(ndbc_seg),  &
          adbc(ndbc_seg), bdbc(ndbc_seg),  &
          kdbc(ndbc_seg), bbdbc(ndbc_seg), zedbc(ndbc_seg),  &
          mdseg_bot(ndbc_seg),  &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, drain.2"  
        STOP
     ENDIF
     DO ls=1,ndbc_seg
        mdbc(ls) = umbc(ls)
        areadbc(ls) = uabc(ls)
        kdbc(ls) = ukbc(ls)
        bbdbc(ls) = 1._kdp
        zedbc(ls) = uzebc(ls)      
     END DO
     ! ... deallocate scratch space for drain data
     DEALLOCATE (umbc, uabc, ukbc, uzebc,  &
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
!!$     call rewi(ibc, icall, 104)  
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
  IF (temp_logical) adj_wr_ratio = 1 
  transient_fresur = 0
  IF (fresur .AND. .NOT.steady_flow) transient_fresur = 1
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
  READ(fuins,*) prtichdf_conc, prtichdf_head, prtsshdf_vel, pr_hdf_media
  IF (print_rde) WRITE(furde,8119) 'prtichdf_conc, prtichdf_head, prtsshdf_vel, pr_hdf_media[2.23.2.1]',  &
       prtichdf_conc, prtichdf_head, prtsshdf_vel, pr_hdf_media
8119 FORMAT(tr5,a/tr5,4l5)
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
  ! ...  more data for pr_hdf_media
  if (pr_hdf_media) then
    READ(fuins,*) k_units, k_input_to_si, fluid_density, fluid_viscosity
    IF (print_rde) WRITE(furde, "(tr5, a/tr5,a,1pg12.4,1pg12.4,1pg12.4)") &
        "C.2.23.2.2.1 .. K: units, input_to_si, fluid_density, fluid_viscosity ", &
        k_units, k_input_to_si, fluid_density, fluid_viscosity
    READ(fuins,*) s_units, s_input_to_si, fluid_compressibility
    IF (print_rde) WRITE(furde, "(tr5, a/tr5,a,1pg12.4,1pg12.4)") &
        "C.2.23.2.2.2 .. Storage: units, input_to_si, fluid_compressibility", &
        s_units, s_input_to_si, fluid_compressibility
    if (solute) then
        READ(fuins,*) alpha_units, alpha_input_to_si
        IF (print_rde) WRITE(furde, "(tr5, a/tr5,a,1pg12.4)") &
            "C.2.23.2.3.1 .. Alpha: units, input_to_si", &
            alpha_units, alpha_input_to_si 
    endif  
  endif
  
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
     CALL rewi(iprint_chem, icall, 125)
     ! ... Print control index for .chem.xyz.tsv concentrations on a sub-grid
     icall = 9
     CALL rewi(iprint_xyz, icall, 125)
  ENDIF
  ! ... Internal zones for flow rate tabulation
  READ(fuins,*) num_flo_zones
  IF (print_rde) WRITE(furde, 8011) 'num_flow_zones,[2.23.8]', num_flo_zones
  IF(num_flo_zones > 0) THEN
     ! ... Allocate space for internal boundary zone data
     ALLOCATE (zone_title(num_flo_zones),  &
          zone_ib(num_flo_zones), lnk_bc2zon(num_flo_zones,4),  &
          seg_well(num_flo_zones),  &
          zone_filename_heads(num_flo_zones),  &
          zone_write_heads(num_flo_zones), &
          stat = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: read2, flow zones.1"  
        STOP
     ENDIF
     !IF(fresur .AND. (nfbc > 0 .OR. nrbc > 0)) THEN
        ! ... Allocate space for zone volume cell index data,
        ! ...     optional flux bc data, optional river bc data
        ALLOCATE (zone_col(num_flo_zones), lnk_cfbc2zon(num_flo_zones),  &
             lnk_crbc2zon(num_flo_zones),  &
             stat = a_err)
        IF (a_err /= 0) THEN  
           PRINT *, "array allocation failed: read2, flow zones.1.1"  
           STOP
        ENDIF
     !END IF
     izn = 0
     DO
        READ(fuins,'(A)') line
        ucline = uppercase(line)
        ic=INDEX(ucline(1:20),'END')
        IF(ic > 0) EXIT
        izn = izn+1
        IF (print_rde) WRITE(furde,8015) '** Flow Zone No.',izn,' **'
8015    FORMAT(tr25,a,i3,a)
        READ(line,'(a)') zone_title(izn)
        IF (print_rde) WRITE(furde,'(tr5,a)') zone_title(izn)
        READ(fuins,'(A)') line
        READ(line,'(l,a)') zone_write_heads(izn), zone_filename_heads(izn)
        IF (print_rde) WRITE(furde,'(tr5,l,a)') zone_write_heads(izn), zone_filename_heads(izn)
        zone_filename_heads(izn) = ADJUSTL(zone_filename_heads(izn))

        IF((fresur .AND. (nfbc > 0 .OR. nrbc > 0)) .or. zone_write_heads(izn)) THEN
           IF (print_rde) WRITE(furde,8005) '** Flow Zone Volume Parameters **',  &
                '  (read echo[2.23.10])',' i_no   j_no   kmin_no   kmax_no'
           READ(fuins,*) zone_col(izn)%num_xycol
           ALLOCATE (zone_col(izn)%i_no(zone_col(izn)%num_xycol),  &
                zone_col(izn)%j_no(zone_col(izn)%num_xycol),  &
                zone_col(izn)%kmin_no(zone_col(izn)%num_xycol),  &
                zone_col(izn)%kmax_no(zone_col(izn)%num_xycol),  &
                stat = a_err)
           IF (a_err /= 0) THEN
              PRINT *, "array allocation failed: read2, flow zones.23.11"
              STOP
           ENDIF
           READ(fuins,*) (zone_col(izn)%i_no(icol), zone_col(izn)%j_no(icol),  &
                zone_col(izn)%kmin_no(icol), zone_col(izn)%kmax_no(icol),  &
                icol=1,zone_col(izn)%num_xycol)
           IF (print_rde) WRITE(furde,8223) (zone_col(izn)%i_no(icol), zone_col(izn)%j_no(icol),  &
                zone_col(izn)%kmin_no(icol), zone_col(izn)%kmax_no(icol),  &
                icol=1,zone_col(izn)%num_xycol)
8223       FORMAT(tr5,4i6)
        END IF
        IF (print_rde) WRITE(furde,8005) '** Flow Zone Face Parameters **',  &
             '  (read echo[2.23.13])',' cell_no    face index'
        READ(fuins,*) zone_ib(izn)%num_int_faces
        IF(zone_ib(izn)%num_int_faces > 0) THEN
           ALLOCATE (zone_ib(izn)%mcell_no(zone_ib(izn)%num_int_faces),  &
                zone_ib(izn)%face_indx(zone_ib(izn)%num_int_faces),  &
                uzmic(zone_ib(izn)%num_int_faces), uziface(zone_ib(izn)%num_int_faces),  &
                stat = a_err)
           IF (a_err /= 0) THEN
              PRINT *, "array allocation failed: read2, flow zones.23.13"
              STOP
           ENDIF
           READ(fuins,*) (uzmic(ifc), uziface(ifc), ifc=1,zone_ib(izn)%num_int_faces)
           IF (print_rde) WRITE(furde,8213) (uzmic(ifc), uziface(ifc),  &
                ifc=1,zone_ib(izn)%num_int_faces)
8213       FORMAT(tr1,10i6)
           zone_ib(izn)%mcell_no(:) = uzmic(:)
           zone_ib(izn)%face_indx(:) = uziface(:)
           DEALLOCATE(uzmic, uziface,  &
                stat = da_err)
           IF (da_err /= 0) THEN  
              PRINT *, "array deallocation failed: read2, flow zones.23.13"
              STOP
           ENDIF
        END IF
        IF(nsbc_cells > 0) THEN
           IF (print_rde) WRITE(furde, 8005) '** Flow Zone Specified Head B.C. Cells **',  &
                '  (read echo[2.23.15])',' cell_no'
           READ(fuins,*) lnk_bc2zon(izn,1)%num_bc
           IF(lnk_bc2zon(izn,1)%num_bc > 0) THEN
              ! ... Allocate scratch space for specified head cells
              ALLOCATE (lnk_bc2zon(izn,1)%lcell_no(lnk_bc2zon(izn,1)%num_bc),  &
                   uzmbc(lnk_bc2zon(izn,1)%num_bc),  &
                   stat = a_err)
              IF (a_err /= 0) THEN
                 PRINT *, "array allocation failed: read2, flow zones.23.15"
                 STOP
              ENDIF
              READ(fuins,*) (uzmbc(ic), ic=1,lnk_bc2zon(izn,1)%num_bc)
              IF (print_rde) WRITE(furde,8213) (uzmbc(ic), ic=1,lnk_bc2zon(izn,1)%num_bc)
              lnk_bc2zon(izn,1)%lcell_no(:) = uzmbc(:)          ! ... store the m cell numbers
              DEALLOCATE (uzmbc,  &
                   stat = da_err)
              IF (da_err /= 0) THEN  
                 PRINT *, "array deallocation failed: read2, flow zones.23.15"
                 STOP
              ENDIF
           END IF
        END IF
        IF(nfbc_cells > 0) THEN
           IF (print_rde) WRITE(furde, 8005) '** Flow Zone Flux B.C. Cells **',  &
                '  (read echo[2.23.17])',' cell_no'
           READ(fuins,*) lnk_bc2zon(izn,2)%num_bc
           IF(lnk_bc2zon(izn,2)%num_bc > 0) THEN
              ! ... Allocate scratch space for flux cells
              ALLOCATE (lnk_bc2zon(izn,2)%lcell_no(lnk_bc2zon(izn,2)%num_bc),  &
                   uzmbc(lnk_bc2zon(izn,2)%num_bc),  &
                   stat = a_err)
              IF (a_err /= 0) THEN
                 PRINT *, "array allocation failed: read2, flow zones.23.17"
                 STOP
              ENDIF
              READ(fuins,*) (uzmbc(ic), ic=1,lnk_bc2zon(izn,2)%num_bc)
              IF (print_rde) WRITE(furde,8213) (uzmbc(ic), ic=1,lnk_bc2zon(izn,2)%num_bc)
              lnk_bc2zon(izn,2)%lcell_no = uzmbc          ! ... store the m cell numbers
              DEALLOCATE (uzmbc,  &
                   stat = da_err)
              IF (da_err /= 0) THEN  
                 PRINT *, "array deallocation failed: read2, flow zones.23.17"
                 STOP
              ENDIF
           END IF
           IF(fresur) THEN
              IF (print_rde) WRITE(furde, 8005) '** Flow Zone Conditional Flux B.C. Cells **',  &
                   '  (read echo[2.23.19])',' cell_no'
              READ(fuins,*) lnk_cfbc2zon(izn)%num_bc
              IF(lnk_cfbc2zon(izn)%num_bc > 0) THEN
                 ! ... Allocate scratch space for flux cells
                 ALLOCATE (lnk_cfbc2zon(izn)%lcell_no(lnk_cfbc2zon(izn)%num_bc),  &
                      lnk_cfbc2zon(izn)%mxy_no(lnk_cfbc2zon(izn)%num_bc),  &
                      lnk_cfbc2zon(izn)%icz_no(lnk_cfbc2zon(izn)%num_bc),  &
                      stat = a_err)
                 IF (a_err /= 0) THEN
                    PRINT *, "array allocation failed: read2, flow zones.23.19"
                    STOP
                 ENDIF
                 ! ... Read mcell numbers into lnk array
                 READ(fuins,*) (lnk_cfbc2zon(izn)%lcell_no(ic),  &
                      ic=1,lnk_cfbc2zon(izn)%num_bc)
                 IF (print_rde) WRITE(furde,8213) (lnk_cfbc2zon(izn)%lcell_no(ic),  &
                      ic=1,lnk_cfbc2zon(izn)%num_bc)
              END IF
           END IF
        END IF
        IF(nlbc_cells > 0) THEN
           IF (print_rde) WRITE(furde, 8005) '** Flow Zone Leakage B.C. Cells **',  &
                '  (read echo[2.23.21])',' cell_no'
           READ(fuins,*) lnk_bc2zon(izn,3)%num_bc
           IF(lnk_bc2zon(izn,3)%num_bc > 0) THEN
              ! ... Allocate scratch space for leakage cells
              ALLOCATE (lnk_bc2zon(izn,3)%lcell_no(lnk_bc2zon(izn,3)%num_bc),  &
                   uzmbc(lnk_bc2zon(izn,3)%num_bc),  &
                   stat = a_err)
              IF (a_err /= 0) THEN
                 PRINT *, "array allocation failed: read2, flow zones.23.21"
                 STOP
              ENDIF
              READ(fuins,*) (uzmbc(ic), ic=1,lnk_bc2zon(izn,3)%num_bc)
              IF (print_rde) WRITE(furde,8213) (uzmbc(ic), ic=1,lnk_bc2zon(izn,3)%num_bc)
              lnk_bc2zon(izn,3)%lcell_no = uzmbc          ! ... store the m cell numbers
              DEALLOCATE (uzmbc,  &
                   stat = da_err)
              IF (da_err /= 0) THEN  
                 PRINT *, "array deallocation failed: read2, flow zones.23.21"
                 STOP
              ENDIF
           END IF
        END IF
        IF(fresur .AND. nrbc_cells > 0) THEN
           IF (print_rde) WRITE(furde, 8005) '** Flow Zone River Leakage B.C. Cells **',  &
                '  (read echo[2.23.23])',' cell_no'
           READ(fuins,*) lnk_crbc2zon(izn)%num_bc
           IF(lnk_crbc2zon(izn)%num_bc > 0) THEN
              ! ... Allocate scratch space for river leakage cells
              ALLOCATE (lnk_crbc2zon(izn)%lcell_no(lnk_crbc2zon(izn)%num_bc),  &
                   lnk_crbc2zon(izn)%mxy_no(lnk_crbc2zon(izn)%num_bc),  &
                   lnk_crbc2zon(izn)%icz_no(lnk_crbc2zon(izn)%num_bc),  &
                   stat = a_err)
              IF (a_err /= 0) THEN
                 PRINT *, "array allocation failed: read2, flow zones.23.23"
                 STOP
              ENDIF
              ! ... Read mcell numbers into lnk array
              READ(fuins,*) (lnk_crbc2zon(izn)%lcell_no(ic),  &
                   ic=1,lnk_crbc2zon(izn)%num_bc)
              IF (print_rde) WRITE(furde,8213) (lnk_crbc2zon(izn)%lcell_no(ic),  &
                   ic=1,lnk_crbc2zon(izn)%num_bc)
           END IF
        END IF
        IF(ndbc_cells > 0) THEN
           IF (print_rde) WRITE(furde, 8005) '** Flow Zone Drain B.C. Cells **',  &
                '  (read echo[2.23.25])',' cell_no'
           READ(fuins,*) lnk_bc2zon(izn,4)%num_bc
           IF(lnk_bc2zon(izn,4)%num_bc > 0) THEN
              ! ... Allocate scratch space for drain cells
              ALLOCATE (lnk_bc2zon(izn,4)%lcell_no(lnk_bc2zon(izn,4)%num_bc),  &
                   uzmbc(lnk_bc2zon(izn,4)%num_bc),  &
                   stat = a_err)
              IF (a_err /= 0) THEN
                 PRINT *, "array allocation failed: read2, flow zones.23.25"
                 STOP
              ENDIF
              READ(fuins,*) (uzmbc(ic), ic=1,lnk_bc2zon(izn,4)%num_bc)
              IF (print_rde) WRITE(furde,8213) (uzmbc(ic), ic=1,lnk_bc2zon(izn,4)%num_bc)
              lnk_bc2zon(izn,4)%lcell_no = uzmbc          ! ... store the m cell numbers
              DEALLOCATE (uzmbc,  &
                   stat = da_err)
              IF (da_err /= 0) THEN  
                 PRINT *, "array deallocation failed: read2, flow zones.23.25"
                 STOP
              ENDIF
           END IF
        END IF
        IF(nwel > 0) THEN
           IF(.NOT. ALLOCATED(uzmwel)) THEN
              ! ... Allocate scratch space for well segments
              ALLOCATE (uzmwel(nwel*nz,num_flo_zones),  &
                   stat = a_err)
              IF (a_err /= 0) THEN  
                 PRINT *, "array allocation failed: read2, flow zones.23.27"
                 STOP
              ENDIF
           END IF
           IF (print_rde) WRITE(furde, 8005) '** Flow Zone Well Segment Cells **',  &
                '  (read echo[2.23.27])',' cell_no'
           READ(fuins,*) seg_well(izn)%num_wellseg
           IF(seg_well(izn)%num_wellseg > 0 ) THEN
              ALLOCATE (seg_well(izn)%iwel_no(seg_well(izn)%num_wellseg),  &
                   seg_well(izn)%ks_no(seg_well(izn)%num_wellseg),  &
                   stat = a_err)
              IF (a_err /= 0) THEN
                 PRINT *, "array allocation failed: read2, flow zones.23.27"
                 STOP
              ENDIF
              READ(fuins,*) (uzmwel(ic,izn), ic=1,seg_well(izn)%num_wellseg)
              IF (print_rde) WRITE(furde,8213) (uzmwel(ic,izn), ic=1,seg_well(izn)%num_wellseg)
           END IF
        END IF
     END DO               ! ... finished with zone definitions
  END IF

END SUBROUTINE read2
