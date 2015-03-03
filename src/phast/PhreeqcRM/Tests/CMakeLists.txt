### tests
project(FortranAdvect Fortran)

# need to set for each project
if (PHREEQCRM_BUILD_MPI)
  if (CMAKE_CONFIGURATION_TYPES)
    SET(CMAKE_CONFIGURATION_TYPES "openmp_debug;openmp;mpi;mpi_debug" CACHE STRING 
    "Semicolon separated list of supported configuration types."
    FORCE)
  endif (CMAKE_CONFIGURATION_TYPES)
else (PHREEQCRM_BUILD_MPI)
  if (CMAKE_CONFIGURATION_TYPES)
    SET(CMAKE_CONFIGURATION_TYPES "openmp_debug;openmp" CACHE STRING 
    "Semicolon separated list of supported configuration types."
    FORCE)
  endif (CMAKE_CONFIGURATION_TYPES)
endif (PHREEQCRM_BUILD_MPI)

# source
SET(FortranAdvect_SOURCES
  advection_f90.F90
  ../RM_interface.F90
  species_f90.F90
)

add_library(FortranAdvect STATIC ${FortranAdvect_SOURCES})

# if found_fortran???
set_target_properties(FortranAdvect PROPERTIES COMPILE_DEFINITIONS "TEST_FORTRAN")


#{{
##if (OPENMP_FOUND)
##  set_target_properties(FortranAdvect PROPERTIES COMPILE_DEFINITIONS_OPENMP "USE_OPENMP")
##endif ()
#}}

project(TestRM CXX)

# need to set for each project
if (PHREEQCRM_BUILD_MPI)
  if (CMAKE_CONFIGURATION_TYPES)
    SET(CMAKE_CONFIGURATION_TYPES "openmp_debug;openmp;mpi;mpi_debug" CACHE STRING 
    "Semicolon separated list of supported configuration types."
    FORCE)
  endif (CMAKE_CONFIGURATION_TYPES)
else (PHREEQCRM_BUILD_MPI)
  if (CMAKE_CONFIGURATION_TYPES)
    SET(CMAKE_CONFIGURATION_TYPES "openmp_debug;openmp" CACHE STRING 
    "Semicolon separated list of supported configuration types."
    FORCE)
  endif (CMAKE_CONFIGURATION_TYPES)
endif (PHREEQCRM_BUILD_MPI)

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
SET(TestRM_SOURCES
  advection_c.c
  advection_cpp.cpp
  main.cpp
  species_c.c
  species_cpp.cpp
)

# test executable
add_executable(TestRM ${TestRM_SOURCES})

# if found_fortran???
set_target_properties(TestRM PROPERTIES COMPILE_DEFINITIONS "TEST_FORTRAN")

# library dependencies
if (PHREEQCRM_BUILD_MPI)
  SET(EXTRA_LIBS ${EXTRA_LIBS} PhreeqcRM FortranAdvect ${MPI_CXX_LIBRARIES})
else ()
  SET(EXTRA_LIBS ${EXTRA_LIBS} PhreeqcRM FortranAdvect)
endif ()


# include
message("PROJECT_SOURCE_DIR (Tests) = " ${PROJECT_SOURCE_DIR})
##include_directories("${PROJECT_SOURCE_DIR}")
##include_directories("${PROJECT_SOURCE_DIR}/IPhreeqcPhast")
##include_directories("${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc")
##include_directories("${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc/phreeqcpp")
##include_directories("${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc/phreeqcpp/PhreeqcKeywords")


# link 
target_link_libraries(TestRM ${EXTRA_LIBS})

# test compile and run
add_test(TestCompileAndRun TestRM)

# MPI test (TODO Need to check if this works in Cmake 2.8)
# 2.8 => change $<TARGET_FILE:TestRM>
# get_property(exe_location TARGET testrm PROPERTY LOCATION)
# message (STATUS "exe_location = ${exe_location}")
if (PHREEQCRM_BUILD_MPI)
  add_test(NAME TestMPI
           COMMAND ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} 3
           ${MPIEXEC_PREFLAGS}
           $<TARGET_FILE:TestRM>
           ${MPIEXEC_POSTFLAGS}
           CONFIGURATIONS mpi mpi_debug
           )
endif ()
