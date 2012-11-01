SUBROUTINE read3_xfer_m
#if defined(USE_MPI)
  USE machine_constants, ONLY: kdp
  USE mcb
  USE mcc
  USE mcw
  USE mpi_mod
  USE mpi_struct_arrays
  IMPLICIT NONE
  !INTEGER :: int_real_type, mpi_array_type
  INTEGER, DIMENSION(2) :: array_bcst_i
  REAL(KIND=kdp), DIMENSION(2) :: array_bcst_r
  !     ------------------------------------------------------------------
  IF (.NOT. solute) RETURN

  ! *** 1 broadcast thru
  array_bcst_i(1) = 0
  IF (thru) array_bcst_i(1) = 1 
  CALL MPI_BCAST(array_bcst_i(1), 1, MPI_INTEGER, manager,  &
       world, ierrmpi)
!  int_real_type = mpi_struct_array(array_bcst_i,array_bcst_r)
!  CALL MPI_BCAST(array_bcst_i, 1, int_real_type, manager,  &
!       world, ierrmpi)
!  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)
  IF(thru) RETURN

  ! ... 2 receive? broadcast? the flag for rdwtd
  IF(nwel > 0) THEN
     array_bcst_i(1) = 0
     IF (rdwtd) array_bcst_i(1) = 1
     CALL MPI_BCAST(array_bcst_i(1), 1, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  !*** 3 broadcast rdspbc, rdscbc
  IF(nsbc > 0) THEN
     array_bcst_i(1) = 0
     IF (rdspbc) array_bcst_i(1) = 1
     array_bcst_i(2) = 0
     IF (rdscbc) array_bcst_i(2) = 1
     CALL MPI_BCAST(array_bcst_i(1), 2, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  ! *** 4 broadcast rdflxq, rdflxs
  IF(nfbc > 0) THEN
     array_bcst_i(1) = 0
     IF (rdflxq) array_bcst_i(1) = 1
     array_bcst_i(2) = 0
     IF (rdflxs) array_bcst_i(2) = 1
     CALL MPI_BCAST(array_bcst_i(1), 2, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  ! *** 5 broadcast rdlbc
  IF(nlbc > 0) THEN
     array_bcst_i(1) = 0
     IF (rdlbc) array_bcst_i(1) = 1
     CALL MPI_BCAST(array_bcst_i(1), 1, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  ! *** 6 broadcast rdrbc
  IF(nrbc > 0) THEN
     array_bcst_i(1) = 0
     IF (rdrbc) array_bcst_i(1) = 1
     CALL MPI_BCAST(array_bcst_i(1), 1, MPI_INTEGER, manager, &
          world, ierrmpi)
  END IF

  ! *** 7 broadcast rdcalc
  array_bcst_i(1) = 0
  IF (rdcalc) array_bcst_i(1) = 1
  CALL MPI_BCAST(array_bcst_i(1), 1, MPI_INTEGER, manager, &
       world, ierrmpi)

#endif 
! end USE_MPI
END SUBROUTINE read3_xfer_m

SUBROUTINE read3_xfer_w
  ! ... Receives time varying data at time of change during simulation;
  ! ...      well rates, boundary conditions
#if defined(USE_MPI)
  USE machine_constants, ONLY: kdp
  USE f_units
  USE mcb
  USE mcc
  USE mcg
  USE mcp
  USE mcv
  USE mcw
  USE mpi_mod
  USE mpi_struct_arrays
  USE print_control_mod
  USE rewi_mod
  IMPLICIT NONE
  INTEGER :: a_err, ic, icall, isegbc, iis, iwel, uwelseqno, uisolw,  &
       uisolbc1, uisolbc2
  INTEGER, SAVE :: ntd=0
  !INTEGER :: int_real_type, mpi_array_type
  INTEGER, DIMENSION(2) :: array_recv_i
  REAL(KIND=kdp), DIMENSION(2) :: array_recv_r
  CHARACTER(LEN=130) :: logline1
  !-----------------------------------------------------------------------
  !...
  ! ... Component number is iis_no
  ! ... Check for end of simulation
  ! ... receive the flag for thru 
  ! *** 1 broadcast receive thru
    CALL MPI_BCAST(array_recv_i(1), 1, MPI_INTEGER, manager,  &
        world, ierrmpi)
!  int_real_type = mpi_struct_array(array_recv_i,array_recv_r)
!  CALL MPI_BCAST(array_recv_i, 1, int_real_type, manager,  &
!       world, ierrmpi)
!  CALL MPI_TYPE_FREE(int_real_type,ierrmpi)

  thru = .FALSE.
  IF (array_recv_i(1) == 1) thru = .TRUE.

  IF(thru) RETURN
  ntd = ntd+1
  !***** Progress output message
  WRITE(logline1,'(a,i2)') 'Receiving transient data for simulation: Set ',ntd
  CALL logprt_c(logline1)

  ! ... 2 receive the flag for rdwtd
  IF(nwel > 0) THEN
     ! ... receive the flag for rdwtd
     CALL MPI_BCAST(array_recv_i(1), 1, MPI_INTEGER, manager, &
          world, ierrmpi)
     rdwtd = .FALSE.
     IF (array_recv_i(1) == 1) rdwtd = .TRUE.
  END IF

  !*** 3 broadcast rdspbc, rdscbc
  IF(nsbc > 0) THEN
     ! ... Receive specified pressure b.c. and assoc concentration
     CALL MPI_BCAST(array_recv_i(1), 2, MPI_INTEGER, manager, &
          world, ierrmpi)
     rdspbc = .FALSE.
     IF (array_recv_i(1) == 1) rdspbc = .TRUE.
     rdscbc = .FALSE.
     IF (array_recv_i(2) == 1) rdscbc = .TRUE.
  END IF

  ! *** 4 broadcast rdflxq, rdflxs
  IF(nfbc > 0) THEN
     ! ... Receive specified fluid flux b.c.
     ! ...      volumetric fluxes
     CALL MPI_BCAST(array_recv_i(1), 2, MPI_INTEGER, manager, &
          world, ierrmpi)

     rdflxq = .FALSE.
     IF (array_recv_i(1) == 1) rdflxq = .TRUE.
     ! ... Solute diffusive fluxes for no flow b.c.
     ! ... Specified solute flux b.c.
     rdflxs = .FALSE.
     IF (array_recv_i(2) == 1) rdflxs = .TRUE.
  END IF

  ! *** 5 broadcast rdlbc
  IF(nlbc > 0) THEN
     CALL MPI_BCAST(array_recv_i(1), 1, MPI_INTEGER, manager, &
          world, ierrmpi)
     rdlbc = .FALSE.
     IF (array_recv_i(1) == 1) rdlbc = .TRUE.
  END IF

  ! *** 6 broadcast rdrbc
  IF(nrbc > 0) THEN
     CALL MPI_BCAST(array_recv_i(1), 1, MPI_INTEGER, manager, &
          world, ierrmpi)
     rdrbc = .FALSE.
     IF (array_recv_i(1) == 1) rdrbc = .TRUE.
  END IF

  ! *** 7 broadcast rdcalc
  CALL MPI_BCAST(array_recv_i(1), 1, MPI_INTEGER, manager, &
       world, ierrmpi)
  rdcalc = .FALSE.
  IF (array_recv_i(1) == 1) rdcalc = .TRUE.
#endif 
! end USE_MPI
END SUBROUTINE read3_xfer_w
