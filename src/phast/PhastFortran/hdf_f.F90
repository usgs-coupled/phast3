! ... $Id: hdf_f.F90,v 1.2 2013/09/26 22:49:48 klkipp Exp klkipp $
SUBROUTINE hdf_write_invariant(iso, l_mpi_myself)
  ! ... Preconditions:
  ! ...   Must be called before first call to EQUILIBRATE
  ! ...   
  ! ...   Valid mcg{NX, NY, NZ}         => READ1
  ! ...   Valid mcn{X, Y, Z}            => READ2
  ! ...   Valid mcw{NKSWEL, NWEL, MWEL} => READ2
  ! ...   Valid mcch{UTULBL}            => INIT1
  ! ...   Valid mcb{IBC}                => INIT2
  ! ...   Valid mcb{MSBC, nsbc}         => INIT2
  ! ...   Valid mcb{MFBC, nfbc}         => INIT2
  ! ...   Valid mcb{MLBC, nlbc}         => INIT2
  ! ...   Valid mcb{MRBC, nrbc}         => INIT2
  USE mcg, ONLY: nx, ny, nz
  USE mcn, ONLY: x, y, z
  USE mcw, ONLY: nkswel, nwel, mwel
  USE mcb, ONLY: ibc, msbc, nsbc, mfbc, nfbc, mlbc, nlbc, mrbc, nrbc_seg,  &
       mdbc, ndbc_seg, flux_seg_m, flux_seg_first, flux_seg_last,  &
       leak_seg_m, leak_seg_first, leak_seg_last, nfbc_cells, nlbc_cells   ! ... b.c. information
  USE mcch, ONLY: utulbl
  IMPLICIT NONE
  INTEGER :: l_mpi_myself
  INTEGER :: a_err, i
  INTEGER :: iwel
  INTEGER :: index, nwbc                           ! ... Well index and node count
  INTEGER, DIMENSION(:), ALLOCATABLE  :: mwbc      ! ... Well nodes
  INTEGER, DIMENSION(nfbc_cells) :: temp_fbc
  INTEGER, DIMENSION(nlbc_cells) :: temp_lbc
  INTEGER, DIMENSION(nrbc_seg) :: temp_rbc
  INTEGER, DIMENSION(ndbc_seg) :: temp_dbc
  INTEGER, INTENT(in) :: iso
  !     ------------------------------------------------------------------
  !...
  IF (l_mpi_myself == 0) THEN
     CALL HDF_INITIALIZE_INVARIANT(iso)
  ENDIF
  CALL HDF_WRITE_GRID(iso, x, y, z, nx, ny, nz, ibc, utulbl)
  IF (l_mpi_myself == 0) THEN
     ! ... Count Well nodes
     nwbc = 0
     DO iwel = 1,nwel
        nwbc = nwbc + nkswel(iwel)
     END DO
     !
     ! ... Store Well Nodes
     !
     ALLOCATE (mwbc(nwbc),  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array allocation failed: HDF_WRITE_INVARIANT, mwbc"
        STOP  
     ENDIF

     index = 1
     DO  iwel = 1,nwel
        DO i=1,nkswel(iwel)
           mwbc(index) = mwel(iwel,i)
           index = index + 1
        END DO
     END DO
     IF(nwbc > 0) CALL HDF_WRITE_FEATURE(iso, 'Wells', mwbc, nwbc)
     IF(nsbc > 0) CALL HDF_WRITE_FEATURE(iso, 'Specified', msbc, nsbc)
     !$$ if(nfbc > 0) CALL HDF_WRITE_FEATURE('Flux', mfbc, nfbc)
     IF(nfbc_cells > 0) THEN
        DO i = 1,nfbc_cells
           temp_fbc(i) = flux_seg_m(i)
        ENDDO
        CALL HDF_WRITE_FEATURE(iso, 'Flux', temp_fbc, nfbc_cells)
     ENDIF
     IF(nlbc_cells > 0) THEN
        DO i = 1,nlbc_cells
           temp_lbc(i) = leak_seg_m(i)
        ENDDO
        CALL HDF_WRITE_FEATURE(iso, 'Leaky', temp_lbc, nlbc_cells)
     ENDIF
     IF(nrbc_seg > 0) THEN
        DO i = 1,nrbc_seg
           temp_rbc(i) = mrbc(i)
        ENDDO
        CALL HDF_WRITE_FEATURE(iso, 'River', temp_rbc, nrbc_seg)
     ENDIF
     IF(ndbc_seg > 0) THEN
        DO i = 1,ndbc_seg
           temp_dbc(i) = mdbc(i)
        ENDDO
        CALL HDF_WRITE_FEATURE(iso, 'Drain', temp_dbc, ndbc_seg)
     END IF
     ! 
     ! ... Deallocate the Well Nodes
     !
     DEALLOCATE (mwbc,  &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "Array deallocation failed: HDF_WRITE_INVARIANT, mwbc"
        STOP  
     ENDIF
  ENDIF
  IF (l_mpi_myself == 0) THEN
     CALL HDF_FINALIZE_INVARIANT(iso)
  ENDIF
END SUBROUTINE hdf_write_invariant

SUBROUTINE HDF_BEGIN_TIME_STEP(iso)
  USE mcc, ONLY: solute
  USE mcc, ONLY: prhdfhi, prhdfci, prhdfvi
  USE mcv, ONLY: time
  USE mcp, ONLY: cnvtmi
  USE hdf_media_m, ONLY: pr_hdf_media
  IMPLICIT NONE
  INTEGER :: time_step_fscalar_count
  INTEGER, INTENT(in) :: iso
  !     ------------------------------------------------------------------
  !...
  !*****seems like this could be simplified with direct pass of integer flag***

  time_step_fscalar_count = 0
  IF (prhdfhi == 1) THEN
     time_step_fscalar_count = time_step_fscalar_count + 1
  ENDIF
  IF (pr_hdf_media) THEN
     time_step_fscalar_count = time_step_fscalar_count + 5
     IF (solute) THEN
        time_step_fscalar_count = time_step_fscalar_count + 4
     ENDIF
  ENDIF
  ! ... Open HDF file
  CALL HDF_OPEN_TIME_STEP(iso, time, cnvtmi, prhdfci, prhdfvi, time_step_fscalar_count)
END SUBROUTINE HDF_BEGIN_TIME_STEP

SUBROUTINE HDF_END_TIME_STEP(iso)
!!$  USE machine_constants, ONLY: kdp
  USE mcc,               ONLY:  prhdfhi, prhdfvi
  USE mcc_m,             ONLY: vmask, ntprhdfv, ntprhdfh
  USE mcch_m,            ONLY: unitl
  USE mcp,               ONLY: cnvli, cnvvli
  USE mcv,               ONLY: frac
  USE mcv_m,             ONLY: vx_node, vy_node, vz_node
  USE mg2_m,             ONLY: hdprnt
  USE hdf_media_m,       ONLY: pr_hdf_media
  IMPLICIT NONE
  INTEGER, INTENT(in) :: iso
  !     ------------------------------------------------------------------
  IF (prhdfhi == 1) THEN
     ! ... Write HDF current fluid head array
     ! ... NOTE: Don't need IBC array since hdf_write_invariant accounts for inactive cells
     CALL HDF_PRNTAR(iso, hdprnt, frac, cnvli, 'Fluid Head('//unitl//')')
     ntprhdfh = ntprhdfh+1
  END IF

  IF (pr_hdf_media) THEN
     ! ... Write HDF media properties arrays
     CALL media_hdf(iso)
     !pr_hdf_media = .FALSE.
  ENDIF

  IF (prhdfvi == 1) THEN
     ! ... Write HDF current velocity arrays
     ! ... Convert velocity to user units, this should be done only once
     vx_node = vx_node*cnvvli
     vy_node = vy_node*cnvvli
     vz_node = vz_node*cnvvli
     CALL HDF_VEL(iso, vx_node, vy_node, vz_node, vmask)
     ntprhdfv = ntprhdfv+1
  END IF
  ! ... Close HDF file
  CALL HDF_CLOSE_TIME_STEP(iso)

CONTAINS

  SUBROUTINE media_hdf(iso)
    ! ... Logic for volume weighting copied from init2_1
    USE machine_constants, ONLY: kdp
    USE mcb
    USE mcb_m
    USE mcb2_m
    USE mcc
    USE mcc_m
    USE mcg
    USE mcg_m
    USE mcm
    USE mcm_m
    USE mcn
    USE mcp
    USE mcp_m
    USE mcs
    USE mcs2
    USE mcv
    USE mcv_m
    USE mcw
    USE mcw_m
    USE mg2_m
    USE phys_const
    USE hdf_media_m
    !
    IMPLICIT NONE
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
       REAL(KIND=kdp) :: tort        ! tort
    END TYPE cell_properties

    REAL(KIND=kdp) :: udz, udy, udydz, udx, udxdy, udxdz, udxyz
    INTEGER :: a_err, da_err, i, j, k, m, imm, ipmz
    INTEGER, DIMENSION(8) :: mm
    REAL(KIND=kdp), DIMENSION(:), ALLOCATABLE :: aprnt, full
    REAL(KIND=kdp) :: conv
    CHARACTER (LEN=119) :: name
    TYPE(cell_properties), DIMENSION(:), ALLOCATABLE :: cell_props
    INTEGER, INTENT(in) :: iso
    !     ------------------------------------------------------------------
    ALLOCATE (cell_props(nxyz), &
         stat = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: media_hdf, cell_props"  
       STOP  
    ENDIF

    cell_props = cell_properties(.FALSE., 0, 0._kdp, 0._kdp, 0._kdp,  &
         0._kdp, 0._kdp, 0._kdp, 0._kdp, 0._kdp, 0._kdp, 0._kdp)
    !
    ! ... Calculate volume-weighted properties for each cell
    ! ...     even though some properties are weighted by facial area for conductances
    !
    DO ipmz = 1, npmz  
       DO k = k1z(ipmz), k2z(ipmz)-1  
          DO j = j1z(ipmz), j2z(ipmz)-1  
             udy = y(j+1) - y(j)  
             DO i = i1z(ipmz), i2z(ipmz)-1  
                udx = x(i+1) - x(i)  
                udxdy = udx*udy*0.25  
                mm(1) = cellno(i, j, k)  
                mm(2) = mm(1) + 1  
                mm(3) = mm(2) + nx  
                mm(4) = mm(1) + nx  
                mm(5) = mm(1) + nxy  
                mm(6) = mm(2) + nxy  
                mm(7) = mm(3) + nxy  
                mm(8) = mm(4) + nxy  
                udxyz = 0.5*udxdy*(z(k+1) - z(k))  
                DO imm=1,8  
                   m = mm(imm)  
                   cell_props(m)%active = .TRUE.
                   cell_props(m)%subdomains = cell_props(m)%subdomains + 1
                   cell_props(m)%volume     = cell_props(m)%volume     + udxyz

                   ! ...  convert hydraulic conductivity to user units
                   cell_props(m)%kxx        = cell_props(m)%kxx        + &
                        udxyz*(kxx(ipmz)/k_input_to_si/fluid_viscosity*fluid_density*grav)
                   cell_props(m)%kyy        = cell_props(m)%kyy        + &
                        udxyz*(kyy(ipmz)/k_input_to_si/fluid_viscosity*fluid_density*grav) 
                   cell_props(m)%kzz        = cell_props(m)%kzz        + &
                        udxyz*(kzz(ipmz)/k_input_to_si/fluid_viscosity*fluid_density*grav)

                   ! ...  porosity   
                   cell_props(m)%poros      = cell_props(m)%poros      + poros(ipmz)*udxyz

                   ! ...  convert specific storage to user units
                   cell_props(m)%storage    = cell_props(m)%storage    + &
                        udxyz*(abpm(ipmz) + poros(ipmz)*fluid_compressibility)*fluid_density*grav/s_input_to_si

                   ! ...  convert dispersivity to user units
                   IF (solute) THEN
                      cell_props(m)%alphl     = cell_props(m)%alphl     +  &
                           udxyz*(alphl(ipmz)/alpha_input_to_si)
                      cell_props(m)%alphth    = cell_props(m)%alphth    +  &
                           udxyz*(alphth(ipmz)/alpha_input_to_si)
                      cell_props(m)%alphtv    = cell_props(m)%alphtv    +  &
                           udxyz*(alphtv(ipmz)/alpha_input_to_si)
                      cell_props(m)%tort      = cell_props(m)%tort      +  &
                           udxyz*tort(ipmz)    
                   ENDIF
                END DO
             END DO
          END DO
       END DO
    END DO

    ! ...  Calculate the volume weighted values
    DO m = 1, nxyz
       IF (cell_props(m)%active) THEN
          cell_props(m)%kxx        = cell_props(m)%kxx/cell_props(m)%volume
          cell_props(m)%kyy        = cell_props(m)%kyy/cell_props(m)%volume
          cell_props(m)%kzz        = cell_props(m)%kzz/cell_props(m)%volume
          cell_props(m)%poros      = cell_props(m)%poros/cell_props(m)%volume
          cell_props(m)%storage    = cell_props(m)%storage/cell_props(m)%volume
          IF (solute) THEN
             cell_props(m)%alphl     = cell_props(m)%alphl/cell_props(m)%volume
             cell_props(m)%alphth    = cell_props(m)%alphth/cell_props(m)%volume
             cell_props(m)%alphtv    = cell_props(m)%alphtv/cell_props(m)%volume
             cell_props(m)%tort      = cell_props(m)%tort/cell_props(m)%volume
          ENDIF
       ENDIF
    END DO
    ! ... Save cell volumes into volume array for C routine calls.
    ! calculated in init2_1
    !    volume = cell_props%volume

    ! ...  Write data to HDF file
    ALLOCATE (aprnt(nxyz), full(nxyz), &
         stat = a_err)
    IF (a_err /= 0) THEN  
       PRINT *, "Array allocation failed: media_hdf, aprnt"  
       STOP
    ENDIF

    aprnt = 0
    full = 1.0_kdp
    conv = 1.0_kdp

    ! ...  Kxx
    DO m = 1, nxyz
       aprnt(m) = cell_props(m)%kxx
    END DO
    name = 'Kx '//TRIM(k_units)//' (cell vol avg)'
    CALL HDF_PRNTAR(iso, aprnt, full, conv, name)

    ! ...  Kyy
    DO m = 1, nxyz
       aprnt(m) = cell_props(m)%kyy
    END DO
    name = 'Ky '//TRIM(k_units)//' (cell vol avg)'
    CALL HDF_PRNTAR(iso, aprnt, full, conv, name)

    ! ...  Kzz
    DO m = 1, nxyz
       aprnt(m) = cell_props(m)%kzz
    END DO
    name = 'Kz '//TRIM(k_units)//' (cell vol avg)'
    CALL HDF_PRNTAR(iso, aprnt, full, conv, name)

    ! ...  Porosity
    DO m = 1, nxyz
       aprnt(m) = cell_props(m)%poros
    END DO
    CALL HDF_PRNTAR(iso, aprnt, full, conv, 'Porosity (cell vol avg)')

    ! ...  Storage
    DO m = 1, nxyz
       aprnt(m) = cell_props(m)%storage
    END DO
    name = 'Specific Storage '//TRIM(s_units)//' (cell vol avg)'
    CALL HDF_PRNTAR(iso, aprnt, full, conv, name)

    IF (solute) THEN  
       ! ...  Alpha l
       DO m = 1, nxyz
          aprnt(m) = cell_props(m)%alphl
       END DO
       name = 'Long disp '//TRIM(alpha_units)//' (cell vol avg)'
       CALL HDF_PRNTAR(iso, aprnt, full, conv, name)

       ! ...  Alpha th
       DO m = 1, nxyz
          aprnt(m) = cell_props(m)%alphth
       END DO
       name = 'Trans horiz disp '//TRIM(alpha_units)//' (cell vol avg)'
       CALL HDF_PRNTAR(iso, aprnt, full, conv, name)

       ! ...  Alpha tv
       DO m = 1, nxyz
          aprnt(m) = cell_props(m)%alphtv
       END DO
       name = 'Trans vert disp '//TRIM(alpha_units)//' (cell vol avg)'
       CALL HDF_PRNTAR(iso, aprnt, full, conv, name)

       ! ... Tortuosity
       DO m = 1, nxyz
          aprnt(m) = cell_props(m)%tort
       END DO
       name = 'Tortuosity (cell vol avg)'
       CALL HDF_PRNTAR(iso, aprnt, full, conv, name)     
    ENDIF

    DEALLOCATE (cell_props, aprnt, full,  &
         stat = da_err)
    IF (da_err /= 0) THEN  
       PRINT *, "Array deallocation failed: media_hdf, cell_props"  
       STOP
    ENDIF
  END SUBROUTINE media_hdf

END SUBROUTINE HDF_END_TIME_STEP

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! TODO
!
! Preconditions:
!   TODO
! Postconditions:
!   TODO
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SUBROUTINE write_hdf_intermediate()
  IMPLICIT NONE
  CALL HDF_INTERMEDIATE()  
END SUBROUTINE write_hdf_intermediate

SUBROUTINE calc_volume
! ... Logic for volume weighting copied from init2_1
  USE machine_constants, ONLY: kdp
  USE mcb_m
  USE mcb2_m
  USE mcc
  USE mcg
  USE mcm
  USE mcn
  USE mcp
  USE mcs
  USE mcs2
  USE mcv
  USE mcw
  USE mg2_m
  USE phys_const
  USE hdf_media_m
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
  
  IF (.NOT. solute) RETURN
!!$!  ALLOCATE (volume(nxyz), &
!!$!       stat = a_err)
!!$!  IF (a_err /= 0) THEN  
!!$!     PRINT *, "Array allocation failed: calc_porsosity_volume, volume"  
!!$!     STOP  
!!$!  ENDIF 
  volume = 0
  ALLOCATE (cell_props(nxyz), &
       stat = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "Array allocation failed: calc_porsosity_volume, cell_props"  
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
                 cell_props(m)%volume = cell_props(m)%volume + udxyz
              END DO
           END DO
        END DO
    END DO
  END DO
  
  ! ... Volume weight values
  DO m = 1, nxyz
     IF (cell_props(m)%active) THEN
        volume(m) = cell_props(m)%volume
     ENDIF
  END DO

  DEALLOCATE (cell_props, &
       stat = da_err)
  IF (da_err /= 0) THEN  
     PRINT *, "Array deallocation failed: calc_volume, cell_props"  
     STOP  
  ENDIF
END SUBROUTINE calc_volume
