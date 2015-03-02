# tests

# Tests/advect.pqi
configure_file (
  "advect.pqi.in"
  "advect.pqi"
  )

# Tests/phreeqc.dat
configure_file (
  "phreeqc.dat.in"
  "phreeqc.dat"
  )
 
# Tests/units.pqi
configure_file (
  "units.pqi.in"
  "units.pqi"
  )

# source
SET(testrm_SOURCES
  advection_c.c
  advection_cpp.cpp
  main.cpp
  species_c.c
  species_cpp.cpp
)

# test executable
add_executable(testrm ${testrm_SOURCES})

# library dependencies
if (PHREEQCRM_BUILD_MPI)
  SET(EXTRA_LIBS ${EXTRA_LIBS} PhreeqcRM ${MPI_CXX_LIBRARIES})
else ()
  SET(EXTRA_LIBS ${EXTRA_LIBS} PhreeqcRM)
endif ()

# include
include_directories ("${PROJECT_SOURCE_DIR}")

# link 
target_link_libraries(testrm ${EXTRA_LIBS})

# test compile and run
add_test(TestCompileAndRun testrm)

# MPI test (TODO Need to check if this works in Cmake 2.8)
# 2.8 => change $<TARGET_FILE:testrm>
# get_property(exe_location TARGET testrm PROPERTY LOCATION)
# message (STATUS "exe_location = ${exe_location}")
if (PHREEQCRM_BUILD_MPI)
  add_test(NAME TestMPI
           COMMAND ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 3
           ${MPIEXEC_PREFLAGS}
           $<TARGET_FILE:testrm>
           ${MPIEXEC_POSTFLAGS}
           CONFIGURATIONS mpi mpi_debug
           )
endif ()
