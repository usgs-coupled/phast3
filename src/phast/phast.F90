PROGRAM phast
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
#if defined(USE_MPI)
  USE mpi_mod
#endif
  IMPLICIT NONE
  INTEGER :: mpi_tasks, mpi_myself
  ! ... Set string for use with RCS ident command
  CHARACTER(LEN=80) :: ident_string='$Id$'
  !     ------------------------------------------------------------------
  !...
  ! ... Extract the version name for the header
  version_name = ' 2.0'
  !...
  mpi_tasks = 1
  mpi_myself = 0
#if defined(USE_MPI)
  CALL init_mpi(mpi_tasks, mpi_myself)
  if(mpi_myself == 0) then
     call phast_root(mpi_tasks, mpi_myself)
  else
     call phast_slave(mpi_tasks, mpi_myself)
  endif
#else
   call phast_root(mpi_tasks, mpi_myself)
#endif
END PROGRAM phast
