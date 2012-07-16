! ... $Id: xfer_to_workers.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $
SUBROUTINE p_distribute
  ! ... Transfers pressure solution to worker processes
  ! ... Can be called by manager or worker
#if defined(USE_MPI)
  USE mcb
  USE mcc
  USE mcg
  USE mcp
  USE mcv
  USE mcv_m
  USE mpi_mod
  USE mpi_struct_arrays 
  IMPLICIT NONE
  !     ------------------------------------------------------------------
  ! ... Transfer p, frac, mfsbc
  IF (.NOT. xp_group) RETURN
  IF (mpi_tasks > 1) THEN
     IF (itime <= 0) THEN
        CALL MPI_BCAST(p, nxyz, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)   
        CALL MPI_BCAST(pv, nxyz, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)   
        CALL MPI_BCAST(frac, nxyz, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)   
        IF (fresur) THEN
           CALL MPI_BCAST(mfsbc, nxy, MPI_INTEGER, manager, &
                world, ierrmpi)   
        ENDIF
     ELSE
        IF (.NOT. steady_flow) THEN
           CALL MPI_BCAST(p, nxyz, MPI_DOUBLE_PRECISION, manager, &
                world, ierrmpi)   
           CALL MPI_BCAST(pv, nxyz, MPI_DOUBLE_PRECISION, manager, &
                world, ierrmpi)   
           IF (fresur) THEN
              CALL MPI_BCAST(frac, nxyz, MPI_DOUBLE_PRECISION, manager, &
                   world, ierrmpi)   
              CALL MPI_BCAST(mfsbc, nxy, MPI_INTEGER, manager, &
                   world, ierrmpi)   
           ENDIF
        ENDIF
     ENDIF
  ENDIF
#endif     
END SUBROUTINE p_distribute

SUBROUTINE c_distribute
  ! ... Transfers component concentrations to worker processes
  ! ... Can be called by manager or worker
  USE mcc
  USE mcg
  USE mcv
  USE mcv_m
  USE mpi_mod
  USE mpi_struct_arrays 
  USE XP_module
  IMPLICIT NONE
  INTEGER tag
  INTEGER :: iis
  !     ------------------------------------------------------------------
  IF (.NOT. solute .OR. .NOT. xp_group) RETURN

  ! ... Send concentration array to worker processes
  ! ...     Send iis component of c array to worker process iis using nonblocking
  ! ...         MPI send.
#if defined(USE_MPI)
  ! ... worker to managet transfer
  tag = 0
  DO iis=1,ns
     IF (component_map(iis) > 0) THEN
        IF (mpi_myself == 0) THEN
           CALL MPI_SEND(c(:,iis), nxyz, MPI_DOUBLE_PRECISION, &
                component_map(iis), tag, world, ierrmpi)
        ELSE IF (mpi_myself == component_map(iis)) THEN
           CALL MPI_RECV(xp_list(local_component_map(iis))%c_w, nxyz, MPI_DOUBLE_PRECISION, manager,  &
                tag, world, MPI_STATUS_IGNORE, ierrmpi) 
        ENDIF
     ENDIF
  ENDDO
#endif ! USE_MPI

  ! ... manager to worker transfer
  IF (mpi_myself == 0) THEN
     DO iis=1,ns
        IF (component_map(iis) == 0) THEN
           xp_list(local_component_map(iis))%c_w = c(:,iis)
        ENDIF
     ENDDO
  ENDIF
END SUBROUTINE c_distribute

SUBROUTINE flow_distribute
  ! ... Transmits flow conductances, change in pressure, b.c. flow rates        
  ! ... Can be called by manager or worker
#if defined(USE_MPI)
  USE mcb
  USE mcb_m
  USE mcc
  USE mcg
  USE mcp
  USE mcv
  USE mcv_m
  USE mpi_mod
  USE mpi_struct_arrays 
  IMPLICIT NONE
  INTEGER :: mpi_array_type 
  !     ------------------------------------------------------------------
  IF (.NOT. solute .OR. .NOT. xp_group) RETURN
  IF (mpi_tasks > 1) THEN
     ! ... Other data sent from steady_state result
     ! *** broadcast tfx, tfy, tfz from flow solution
     ! ... create MPI structure for three real arrays
     mpi_array_type = mpi_struct_array(tfx, tfy, tfz)
     ! ... broadcast real arrays to workers
     CALL MPI_BCAST(tfx, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)

     IF (.NOT. steady_flow) THEN
        ! *** broadcast dp
        CALL MPI_BCAST(dp, nxyz + 1, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)
     ENDIF

     IF (nsbc > 0) THEN 
        ! *** broadcast qfsbc from flow solution
        CALL MPI_BCAST(qfsbc, nsbc, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)
     ENDIF
     IF (nfbc > 0) THEN 
        ! *** broadcast qffbc from flow solution
        CALL MPI_BCAST(qffbc, nfbc, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)
     ENDIF
     IF (nlbc > 0) THEN 
        ! *** broadcast qflbc from flow solution
        CALL MPI_BCAST(qflbc, nlbc, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)

     ENDIF
     IF (nrbc > 0) THEN 
        ! *** broadcast qfrbc from flow solution
        CALL MPI_BCAST(qfrbc, nrbc, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi)
     ENDIF
     IF (ndbc > 0) THEN 
        ! *** broadcast qfdbc from flow solution
        CALL MPI_BCAST(qfdbc, ndbc, MPI_DOUBLE_PRECISION, manager, &
             world, ierrmpi) 
     ENDIF
     ! *** broadcast transient time step as reset
     CALL MPI_BCAST(deltim, 1, MPI_DOUBLE_PRECISION, manager, &
          world, ierrmpi) 
  ENDIF
#endif     
END SUBROUTINE flow_distribute

SUBROUTINE tfx_distribute
  ! ... Transfers flow conductance arrays to worker processes
#if defined(USE_MPI)
  USE mcc
  USE mcp
  USE mpi_mod
  USE mpi_struct_arrays
  IMPLICIT NONE
  INTEGER :: mpi_array_type
  !     ------------------------------------------------------------------
  IF (.NOT.solute) RETURN
  IF(.NOT.steady_flow) THEN
     ! *** broadcast tfx, tfy, tfz
     ! ... create MPI structure for three real arrays
     mpi_array_type = mpi_struct_array(tfx, tfy, tfz)
     ! ... broadcast real arrays to workers
     CALL MPI_BCAST(tfx, 1, mpi_array_type, manager, &
          world, ierrmpi)
     CALL MPI_TYPE_FREE(mpi_array_type,ierrmpi)
  END IF
#endif
END SUBROUTINE tfx_distribute
