SUBROUTINE media_hdf
! Logic for volume weighting copied from init2_1
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcb2
  USE mcc
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcs
  USE mcs2
  USE mcv
  USE mcw
  USE mg2
  USE phys_const
  USE hdf_media
  IMPLICIT NONE
  !

  INTRINSIC index
  INTERFACE
     FUNCTION nintrp(xarg,nx,xs,erflg)
       USE machine_constants, ONLY: kdp
       REAL(KIND=kdp), INTENT(IN) :: xarg
       INTEGER, INTENT(IN) :: nx
       REAL(KIND=kdp), DIMENSION(:), INTENT(IN) :: xs
       LOGICAL, INTENT(INOUT) :: erflg
       INTEGER :: nintrp
     END FUNCTION nintrp
  END INTERFACE
  TYPE :: cell_properties
     LOGICAL        :: active
     INTEGER        :: subdomains
     REAL(KIND=kdp) :: volume
     REAL(KIND=kdp) :: kxx         ! kxx
     REAL(KIND=kdp) :: kyy         ! kyy
     REAL(KIND=kdp) :: kzz         ! kzz
     REAL(KIND=kdp) :: poros       ! poros
     REAL(KIND=kdp) :: storage     ! abpm
     REAL(KIND=kdp) :: alphl       ! alphl
     REAL(KIND=kdp) :: alphth      ! alphth
     REAL(KIND=kdp) :: alphtv      ! alphtv
  END TYPE cell_properties

  REAL(KIND=kdp) :: udz, udy, udydz, udx, udxdy, udxdz, udxyz
  INTEGER :: a_err, da_err, i, j, k, m, imm, ipmz
  INTEGER, DIMENSION(8) :: mm
  REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: aprnt, full
  REAL(KIND=kdp) :: conv
  CHARACTER (LEN=119) :: name
  TYPE(cell_properties), DIMENSION(:), ALLOCATABLE :: cell_props
  !     ------------------------------------------------------------------
  ALLOCATE (cell_props(nxyz), &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: media_hdf, cell_props"  
     STOP  
  ENDIF

  cell_props = cell_properties(.FALSE., 0, 0._kdp, 0._kdp, 0._kdp, &
       0._kdp, 0._kdp, 0._kdp,0._kdp, 0._kdp, 0._kdp)

  DO ipmz = 1, npmz  
     DO k = k1z(ipmz), k2z(ipmz) - 1  
        DO j = j1z(ipmz), j2z(ipmz) - 1  
           udy = y(j + 1) - y(j)  
           DO i = i1z(ipmz), i2z(ipmz) - 1  
              udx = x(i + 1) - x(i)  
              udxdy = udx*udy*.25  
              mm(1) = cellno(i, j, k)  
              mm(2) = mm(1) + 1  
              mm(3) = mm(2) + nx  
              mm(4) = mm(1) + nx  
              mm(5) = mm(1) + nxy  
              mm(6) = mm(2) + nxy  
              mm(7) = mm(3) + nxy  
              mm(8) = mm(4) + nxy  
              udxyz = .5*udxdy*(z(k + 1) - z(k) )  
              DO imm = 1, 8  
                 m = mm(imm)  
                 cell_props(m)%active = .TRUE.
                 cell_props(m)%subdomains = cell_props(m)%subdomains + 1
                 cell_props(m)%volume     = cell_props(m)%volume     + udxyz
                 
                 ! convert to hydraulic conductivity to user units
                 cell_props(m)%kxx        = cell_props(m)%kxx        + &
                    udxyz * (kxx(ipmz) / k_input_to_si / fluid_viscosity * fluid_density * grav)
                 cell_props(m)%kyy        = cell_props(m)%kyy        + &
                    udxyz * (kyy(ipmz) / k_input_to_si / fluid_viscosity * fluid_density * grav) 
                 cell_props(m)%kzz        = cell_props(m)%kzz        + &
                    udxyz * (kzz(ipmz) / k_input_to_si / fluid_viscosity * fluid_density * grav)
                    
                 ! porosity   
                 cell_props(m)%poros      = cell_props(m)%poros      + poros(ipmz) * udxyz
                 
                 ! convert to specific storage to user units
                 cell_props(m)%storage    = cell_props(m)%storage    + &
                        udxyz * (abpm(ipmz) + poros(ipmz) * fluid_compressibility) * fluid_density * grav / s_input_to_si
  
                 ! convert dispersivity to user units    
                 if (solute) then
                    cell_props(m)%alphl     = cell_props(m)%alphl     + &
                        udxyz * (alphl(ipmz) / alpha_input_to_si)
                    cell_props(m)%alphth    = cell_props(m)%alphth    + &
                        udxyz * (alphth(ipmz) / alpha_input_to_si)
                    cell_props(m)%alphtv    = cell_props(m)%alphtv    + &
                        udxyz * (alphtv(ipmz) / alpha_input_to_si)
                 endif
              END DO
           END DO
        END DO
    END DO
  END DO
  
  ! Volume weight values
  DO m = 1, nxyz
     if (cell_props(m)%active) then
        cell_props(m)%kxx        = cell_props(m)%kxx / cell_props(m)%volume
        cell_props(m)%kyy        = cell_props(m)%kyy / cell_props(m)%volume
        cell_props(m)%kzz        = cell_props(m)%kzz / cell_props(m)%volume
        cell_props(m)%poros      = cell_props(m)%poros / cell_props(m)%volume
        cell_props(m)%storage    = cell_props(m)%storage / cell_props(m)%volume
        if (solute) then
           cell_props(m)%alphl     = cell_props(m)%alphl  / cell_props(m)%volume
           cell_props(m)%alphth    = cell_props(m)%alphth / cell_props(m)%volume
           cell_props(m)%alphtv    = cell_props(m)%alphtv / cell_props(m)%volume
        endif
     endif
  END DO

  ! Write data to HDF
  
  ALLOCATE (aprnt(nxyz), full(nxyz), &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array deallocation failed: media_hdf, aprnt"  
     STOP  
  ENDIF
  
  aprnt = 0
  full = 1.0_kdp
  conv = 1.0_kdp

  ! Kxx
  DO m = 1, nxyz
     aprnt(m) = cell_props(m)%kxx
  END DO
  name = 'Kx ' // TRIM(k_units) // ' (cell vol avg)'
  CALL prntar_hdf(aprnt, full, conv, name)

  ! Kyy
  DO m = 1, nxyz
     aprnt(m) = cell_props(m)%kyy
  END DO
  name = 'Ky ' // TRIM(k_units) // ' (cell vol avg)'
  CALL prntar_hdf(aprnt, full, conv, name)

  ! Kzz
  DO m = 1, nxyz
     aprnt(m) = cell_props(m)%kzz
  END DO
  name = 'Kz ' // TRIM(k_units) // ' (cell vol avg)'
  CALL prntar_hdf(aprnt, full, conv, name)

  ! Porosity
  DO m = 1, nxyz
     aprnt(m) = cell_props(m)%poros
  END DO
  CALL prntar_hdf(aprnt, full, conv, 'Porosity (cell vol avg)')

  ! Storage
  DO m = 1, nxyz
     aprnt(m) = cell_props(m)%storage
  END DO
  name = 'Specific Storage ' // TRIM(s_units) // ' (cell vol avg)'
  CALL prntar_hdf(aprnt, full, conv, name)

  if (solute) then  
     ! Alpha l
     DO m = 1, nxyz
        aprnt(m) = cell_props(m)%alphl
     END DO
     name = 'Long disp ' // TRIM(alpha_units) // ' (cell vol avg)'
     CALL prntar_hdf(aprnt, full, conv, name)
     
     ! Alpha th
     DO m = 1, nxyz
        aprnt(m) = cell_props(m)%alphth
     END DO
     name = 'Trans horiz disp ' // TRIM(alpha_units) // ' (cell vol avg)'
     CALL prntar_hdf(aprnt, full, conv, name)

     ! Alpha tv
     DO m = 1, nxyz
        aprnt(m) = cell_props(m)%alphtv
     END DO
     name = 'Trans vert disp ' // TRIM(alpha_units) // ' (cell vol avg)'
     CALL prntar_hdf(aprnt, full, conv, name)
  endif

  DEALLOCATE (cell_props, aprnt, full,  &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: media_hdf, cell_props"  
     STOP  
  ENDIF
END SUBROUTINE media_hdf
