! ... $Id: xfer_to_manager.F90,v 1.5 2011/01/29 00:18:54 klkipp Exp klkipp $
SUBROUTINE sbc_gather
  USE mcb
  USE mcc
  USE mcm_m
  USE mcv
#if defined(USE_MPI)
  USE mpi_mod
#endif
  USE XP_module
  IMPLICIT NONE
  INTEGER :: i, tag
  !     ------------------------------------------------------------------
  IF ((.NOT. solute) .OR. (nsbc <= 0)) RETURN
  IF (.NOT. xp_group) RETURN

  IF (.NOT. solute) RETURN

#if defined(USE_MPI)
  tag = 0
  DO i = 1, ns
     IF (component_map(i) > 0) THEN
        IF (mpi_myself == component_map(i)) THEN
           CALL MPI_SEND(xp_list(local_component_map(i))%vassbc, 7*nsbc, MPI_DOUBLE_PRECISION, &
                manager, tag, world, ierrmpi)
           CALL MPI_SEND(xp_list(local_component_map(i))%rhssbc, nsbc, MPI_DOUBLE_PRECISION, &
                manager, tag, world, ierrmpi)
        ELSE IF (mpi_myself == manager) THEN
           CALL MPI_RECV(vassbc(:,:,i), 7*nsbc, MPI_DOUBLE_PRECISION, &
                component_map(i), tag, world, MPI_STATUS_IGNORE, ierrmpi)
           CALL MPI_RECV(rhssbc(:,i), nsbc, MPI_DOUBLE_PRECISION, &
                component_map(i), tag, world, MPI_STATUS_IGNORE, ierrmpi)
        ENDIF
     ENDIF
  ENDDO
#endif

  IF (mpi_myself == 0) THEN
     DO i = 1, ns
        IF (component_map(i) == 0) THEN
           vassbc(:,:,i) = xp_list(local_component_map(i))%vassbc
           rhssbc(:,i) =  xp_list(local_component_map(i))%rhssbc
        ENDIF
     ENDDO
  ENDIF
END SUBROUTINE sbc_gather

SUBROUTINE c_gather
  USE mcc
  USE mcg
  USE mcv
  USE mcv_m
#if defined(USE_MPI)
  USE mpi_mod
#endif
  USE XP_module
  IMPLICIT NONE
  INTEGER :: i, tag
  !     ------------------------------------------------------------------
  IF (.NOT. solute) RETURN
  IF (.NOT. xp_group) RETURN

#if defined(USE_MPI)
  tag = 0
  DO i = 1, ns
     IF (component_map(i) > 0) THEN
        IF (mpi_myself == component_map(i)) THEN
           CALL MPI_SEND(xp_list(local_component_map(i))%c_w, nxyz, MPI_DOUBLE_PRECISION, &
                manager, tag, world, ierrmpi)
           CALL MPI_SEND(xp_list(local_component_map(i))%dc, nxyz + 1, MPI_DOUBLE_PRECISION, &
                manager, tag, world, ierrmpi)
        ELSE IF (mpi_myself == manager) THEN
           CALL MPI_RECV(c(:,i), nxyz, MPI_DOUBLE_PRECISION, &
                component_map(i), tag, world, MPI_STATUS_IGNORE, ierrmpi)
           CALL MPI_RECV(dc(:,i), nxyz + 1, MPI_DOUBLE_PRECISION, &
                component_map(i), tag, world, MPI_STATUS_IGNORE, ierrmpi)
        ENDIF
     ENDIF
  ENDDO
#endif

  IF (mpi_myself == 0) THEN
     DO i = 1, ns
        IF (component_map(i) == 0) THEN
           c(:,i) = xp_list(local_component_map(i))%c_w
           dc(:,i) = xp_list(local_component_map(i))%dc
        ENDIF
     ENDDO
  ENDIF

END SUBROUTINE c_gather
