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
  IMPLICIT NONE
  !     ------------------------------------------------------------------
  ! ... Transfer p, frac, mfsbc#ifdef USE_MPI  
  if (mpi_myself == 0) then
    CALL MPI_BCAST(METHOD_PDISTRIBUTE, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
  endif
  IF (.NOT. xp_group) RETURN
  IF (mpi_tasks > 1) THEN
     IF (itime <= 0) THEN
        CALL MPI_BCAST(p(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
             xp_comm, ierrmpi)   
        CALL MPI_BCAST(pv(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
             xp_comm, ierrmpi)   
        CALL MPI_BCAST(frac(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
             xp_comm, ierrmpi)   
        IF (fresur) THEN
           CALL MPI_BCAST(mfsbc(1), nxy, MPI_INTEGER, manager, &
                xp_comm, ierrmpi)   
        ENDIF
     ELSE
        IF (.NOT. steady_flow) THEN
           CALL MPI_BCAST(p(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
                xp_comm, ierrmpi)   
           CALL MPI_BCAST(pv(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
                xp_comm, ierrmpi)   
           IF (fresur) THEN
              CALL MPI_BCAST(frac(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
                   xp_comm, ierrmpi)   
              CALL MPI_BCAST(mfsbc(1), nxy, MPI_INTEGER, manager, &
                   xp_comm, ierrmpi)   
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
  USE XP_module, only: xp_list
  IMPLICIT NONE
  INTEGER tag
  INTEGER :: iis
  !     ------------------------------------------------------------------
#ifdef USE_MPI  
  if (mpi_myself == 0) then
    CALL MPI_BCAST(METHOD_CDISTRIBUTE, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
  endif
#endif 
  IF (.NOT. solute .OR. .NOT. xp_group) RETURN

  ! ... Send concentration array to worker processes
  ! ...     Send iis component of c array to worker process iis using nonblocking
  ! ...         MPI send.
#if defined(USE_MPI)
  CALL MPI_BCAST(time, 1, MPI_DOUBLE_PRECISION, manager, xp_comm, ierrmpi)
  ! ... worker to managet transfer
  tag = 0
  DO iis=1,ns
     IF (component_map(iis) > 0) THEN
        IF (mpi_myself == 0) THEN
           CALL MPI_SEND(c(:,iis), nxyz, MPI_DOUBLE_PRECISION, &
                component_map(iis), tag, xp_comm, ierrmpi)
        ELSE IF (mpi_myself == component_map(iis)) THEN
           CALL MPI_RECV(xp_list(local_component_map(iis))%c_w, nxyz, MPI_DOUBLE_PRECISION, manager,  &
                tag, xp_comm, MPI_STATUS_IGNORE, ierrmpi) 
        ENDIF
     ENDIF
  ENDDO
#endif 
! end USE_MPI

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
    IMPLICIT NONE
    !     ------------------------------------------------------------------
    if (mpi_myself == 0) then
        CALL MPI_BCAST(METHOD_FLOWDISTRIBUTE, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
    endif
    IF (.NOT. solute .OR. .NOT. xp_group) RETURN
    IF (mpi_tasks > 1) THEN
        ! ... Other data sent from steady_state result
        ! *** broadcast tfx, tfy, tfz from flow solution
        ! ... create MPI structure for three real arrays

        CALL MPI_BCAST(tfx(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
        CALL MPI_BCAST(tfy(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
        CALL MPI_BCAST(tfz(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
        IF (.NOT. steady_flow) THEN
            ! *** broadcast dp
            CALL MPI_BCAST(dp(0), nxyz + 1, MPI_DOUBLE_PRECISION, manager, &
                xp_comm, ierrmpi)
        ENDIF

        IF (nsbc > 0) THEN 
            ! *** broadcast qfsbc from flow solution
            CALL MPI_BCAST(qfsbc(1), nsbc, MPI_DOUBLE_PRECISION, manager, &
                xp_comm, ierrmpi)
        ENDIF
        IF (nfbc > 0) THEN 
            ! *** broadcast qffbc from flow solution
            CALL MPI_BCAST(qffbc(1), nfbc, MPI_DOUBLE_PRECISION, manager, &
                xp_comm, ierrmpi)
        ENDIF
        IF (nlbc > 0) THEN 
            ! *** broadcast qflbc from flow solution
            CALL MPI_BCAST(qflbc(1), nlbc, MPI_DOUBLE_PRECISION, manager, &
                xp_comm, ierrmpi)
        ENDIF
        IF (nrbc > 0) THEN 
            ! *** broadcast qfrbc from flow solution
            CALL MPI_BCAST(qfrbc(1), nrbc, MPI_DOUBLE_PRECISION, manager, &
                xp_comm, ierrmpi)
        ENDIF
        IF (ndbc > 0) THEN 
            ! *** broadcast qfdbc from flow solution
            CALL MPI_BCAST(qfdbc(1), ndbc, MPI_DOUBLE_PRECISION, manager, &
                xp_comm, ierrmpi) 
        ENDIF
        ! *** broadcast transient time step as reset
        CALL MPI_BCAST(deltim, 1, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi) 
    ENDIF
#endif     
END SUBROUTINE flow_distribute

SUBROUTINE tfx_distribute
    ! ... Transfers flow conductance arrays to worker processes
#if defined(USE_MPI)
    USE mcc
    USE mcg, only: nxyz
    USE mcp
    USE mpi_mod
    IMPLICIT NONE
    !     ------------------------------------------------------------------
    IF (.NOT.solute) RETURN
    IF(.NOT.steady_flow) THEN
        ! *** broadcast tfx, tfy, tfz
        ! ... create MPI structure for three real arrays

        CALL MPI_BCAST(tfx(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
        CALL MPI_BCAST(tfy(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
        CALL MPI_BCAST(tfz(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
            xp_comm, ierrmpi)
    END IF
#endif
END SUBROUTINE tfx_distribute
    
SUBROUTINE callback_distribute_static
  ! ... Transfer pv0, volume to all workers
#if defined(USE_MPI)
  USE mcb
  USE mcc
  USE mcg
  USE mcn
  USE mcp
  USE mcv
  USE mcv_m
  USE mpi_mod
  IMPLICIT NONE
  !     ------------------------------------------------------------------
  if (.not. solute) return
  if (mpi_myself == 0) then
      CALL MPI_BCAST(METHOD_CALLBACKDISTRIBUTESTATIC, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
  endif
  IF (mpi_tasks > 1) THEN
      CALL MPI_BCAST(pv0(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
      world_comm, ierrmpi)   
      CALL MPI_BCAST(volume(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
      world_comm, ierrmpi)   
      CALL MPI_BCAST(frac(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
      world_comm, ierrmpi)   
  ENDIF
#endif     
END SUBROUTINE callback_distribute_static
SUBROUTINE callback_distribute_frac
  ! ... Transfer frac to all workers
#if defined(USE_MPI)
  USE mcb
  USE mcc
  USE mcg
  USE mcp
  USE mcv
  USE mcv_m
  USE mpi_mod
  IMPLICIT NONE
  !     ------------------------------------------------------------------
  ! ... Transfer pv0, volume to all workers
  if (.not. solute .or. .not. steady_flow) return
  if (mpi_myself == 0) then
      CALL MPI_BCAST(METHOD_CALLBACKDISTRIBUTEFRAC, 1, MPI_INTEGER, manager, world_comm, ierrmpi) 
  endif
  IF (mpi_tasks > 1) THEN
      CALL MPI_BCAST(frac(1), nxyz, MPI_DOUBLE_PRECISION, manager, &
          world_comm, ierrmpi)   
  ENDIF
#endif     
END SUBROUTINE callback_distribute_frac