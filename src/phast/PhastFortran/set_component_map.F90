#ifdef SKIP
SUBROUTINE set_component_map
  USE mcc
  USE mcv
  !USE XP_module, ONLY: xp_list
#if defined(USE_MPI)
  USE mpi_mod
#endif
  IMPLICIT NONE
  INTEGER a_err, i, j, nmembers
  INTEGER, DIMENSION(:), ALLOCATABLE :: members
  INTEGER :: mpi_xp_group_world
  !     ------------------------------------------------------------------
  !...
  IF (.NOT. solute) RETURN

  ALLOCATE (members(ns+1), & 
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: set_component_map 1"  
     STOP
  ENDIF
  IF (mpi_myself <= ns) THEN
     ALLOCATE (component_map(ns), local_component_map(ns), &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: set_component_map 2"  
        STOP
     ENDIF

     component_map = 0
     IF (mpi_tasks > 1) THEN 
        j = 1
        DO i = 1, ns
           component_map(i) = j
           j = j + 1
           IF (j >= mpi_tasks) j = 0
        ENDDO
     ENDIF
  ENDIF

#if defined(USE_MPI)
  if (mpi_myself == 0) then
    CALL MPI_BCAST(METHOD_SETCOMPONENTMAP, 1, MPI_INTEGER, manager, world_comm, ierrmpi)  
  endif
  ! ... make a world group
  CALL MPI_COMM_GROUP(MPI_COMM_WORLD, mpi_xp_group_world, ierrmpi)
  IF (ns < mpi_tasks) THEN
     ! ... subset world 
     DO i = 1, ns + 1
        members(i) = i - 1
     ENDDO
     nmembers = ns + 1
     ! ... include 
     CALL MPI_GROUP_INCL(mpi_xp_group_world, nmembers, members, mpi_xp_group, ierrmpi) 
     ! ... create subset of world from group
     CALL MPI_COMM_CREATE(world_comm, mpi_xp_group, mpi_xp_comm, ierrmpi)
     CALL MPI_GROUP_FREE(mpi_xp_group, ierrmpi)
  ELSE
     ! ...  create comm equal to world
     CALL MPI_COMM_CREATE(world_comm, mpi_xp_group_world, mpi_xp_comm, ierrmpi)
  ENDIF
  ! ...  world is transporter world, probably should rename later
  !world = mpi_xp_comm
  CALL MPI_GROUP_FREE(mpi_xp_group_world, ierrmpi)
  xp_comm = mpi_xp_comm
#endif

  xp_group = .TRUE. 
  IF (mpi_myself > ns) THEN
     xp_group = .FALSE.
  ENDIF

  IF (xp_group) THEN
     local_ns = 0
     local_component_map = 0
     DO i = 1, ns
        IF (component_map(i) == mpi_myself) THEN
           local_ns = local_ns + 1
           local_component_map(i) = local_ns
        ENDIF
     ENDDO
  ENDIF
  DEALLOCATE (members, & 
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array deallocation failed: set_component_map 1"  
     STOP
  ENDIF

END SUBROUTINE set_component_map
#else
SUBROUTINE set_component_map
  USE mcc
  USE mcv
#if defined(USE_MPI)
  USE mpi_mod
#endif
  IMPLICIT NONE
  INTEGER a_err, i, j, nmembers
  INTEGER, DIMENSION(:), ALLOCATABLE :: members
  INTEGER :: mpi_xp_group_world
  INTEGER :: nprocesses, max_processes, first_process, last_process
  !     ------------------------------------------------------------------
  !...
  IF (.NOT. solute) RETURN

  ALLOCATE (members(ns+1), & 
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array allocation failed: set_component_map 1"  
     STOP
  ENDIF
  
  ! How many transport processes will be used?
  max_processes = 1000
  nprocesses = mpi_tasks
  if (nprocesses .gt. max_processes) nprocesses = max_processes
  if (nprocesses .gt. ns) nprocesses = ns

  ! Can we use processes 1-processes?
  first_process = 0
  last_process = nprocesses - 1
  if (nprocesses < mpi_tasks) then
      first_process = 1
      last_process = nprocesses
  endif
  
  IF (mpi_myself <= last_process) THEN
     ALLOCATE (component_map(ns), local_component_map(ns), &
          STAT = a_err)
     IF (a_err /= 0) THEN  
        PRINT *, "array allocation failed: set_component_map 2"  
        STOP
     ENDIF

     component_map = 0
     IF (nprocesses > 1) THEN 
        j = first_process
        DO i = 1, ns
           component_map(i) = j
           j = j + 1
           IF (j > last_process) j = first_process
        ENDDO
     ENDIF
  ENDIF

#if defined(USE_MPI)
  if (mpi_myself == 0) then
    CALL MPI_BCAST(METHOD_SETCOMPONENTMAP, 1, MPI_INTEGER, manager, world_comm, ierrmpi)  
  endif
  ! ... make a world group
  CALL MPI_COMM_GROUP(MPI_COMM_WORLD, mpi_xp_group_world, ierrmpi)
  IF (last_process < mpi_tasks - 1) THEN
     ! ... subset world 
     DO i = 0, last_process 
        members(i + 1) = i 
     ENDDO
     nmembers = last_process + 1
     ! ... include 
     CALL MPI_GROUP_INCL(mpi_xp_group_world, nmembers, members, mpi_xp_group, ierrmpi) 
     ! ... create subset of world from group
     CALL MPI_COMM_CREATE(world_comm, mpi_xp_group, mpi_xp_comm, ierrmpi)
     CALL MPI_GROUP_FREE(mpi_xp_group, ierrmpi)
  ELSE
     ! ...  create comm equal to world
     CALL MPI_COMM_CREATE(world_comm, mpi_xp_group_world, mpi_xp_comm, ierrmpi)
  ENDIF
  ! ...  world is transporter world, probably should rename later
  !world = mpi_xp_comm
  CALL MPI_GROUP_FREE(mpi_xp_group_world, ierrmpi)
  xp_comm = mpi_xp_comm
#endif

  xp_group = .TRUE. 
  IF (mpi_myself > last_process) THEN
     xp_group = .FALSE.
  ENDIF

  IF (xp_group) THEN
     local_ns = 0
     local_component_map = 0
     DO i = 1, ns
        IF (component_map(i) == mpi_myself) THEN
           local_ns = local_ns + 1
           local_component_map(i) = local_ns
           print *, i, local_component_map(i), component_map(i), nprocesses
        ENDIF
     ENDDO
  ENDIF
  DEALLOCATE (members, & 
       STAT = a_err)
  IF (a_err /= 0) THEN  
     PRINT *, "array deallocation failed: set_component_map 1"  
     STOP
  ENDIF

END SUBROUTINE set_component_map    
#endif