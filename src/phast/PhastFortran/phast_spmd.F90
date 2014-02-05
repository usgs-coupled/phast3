SUBROUTINE phast_sub(l_mpi_tasks, l_mpi_myself)
  ! ... A three dimensional flow and solute transport code based
  ! ...      upon finite differences and fully coupled equation system
  ! ... Based upon HST3D Version 2.0
  ! ... File Usage:
  ! ...      FUTRM - Monitor screen {standard output} and
  ! ...                  keyboard {standard input}
  ! ...      FUINS  - Input without comments
  ! ...      FULP  - Output to line printer
  ! ...      FUPLT - Output temporal plot file
  ! ...      FUORST - Output checkpoint dump file for restart
  ! ...      FUIRST - Input restart file from checkpoint dump
  ! ...      FUINC  - Input file with comments
  ! ...      FURDE  - Read echo of input data
  ! ...      FUPMAP  - Pressure, temperature, mass fraction for
  ! ...                    plotter or monitor screen maps
  ! ...      FUVMAP  - Velocity components for vector plots
  ! ...      FUP  - Pressure field
  ! ...      FUT  - Temperature field
  ! ...      FUC  - Concentration field
  ! ...      FUVEL  - Velocity field
  ! ...      FUWEL  - Well output
  ! ...      FUBAL  - Balance tables
  ! ...      FUKD  - Conductance fields
  ! ...      FUBCF  - Boundary condition flow rates
  ! ...      FUD  - Density field
  ! ...      FUVS  - Viscosity field
  USE mcch, ONLY: version_name
  USE mcc
#if defined(USE_MPI)
  USE mpi_mod
#endif
  IMPLICIT NONE
  INTEGER :: l_mpi_tasks, l_mpi_myself
  !     ------------------------------------------------------------------
  !...
  ! ... Extract the version name for the header
  version_name = ' @VERSION@'
  !...
#if defined(USE_MPI)
  world_comm = MPI_COMM_WORLD
  mpi_tasks = l_mpi_tasks
  mpi_myself = l_mpi_myself   
  IF (mpi_myself == manager) THEN
     CALL phast_manager        ! ... the manager's tasks    
  ELSE                       
     CALL phast_worker         ! ... the worker's tasks
  ENDIF
  !print *, "End of phast_spmd. ", mpi_myself
#else
  call phast_manager
#endif
END SUBROUTINE phast_sub
