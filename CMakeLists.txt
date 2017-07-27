if (WIN32)
cmake_minimum_required (VERSION 3.2.3)
else()
cmake_minimum_required (VERSION 2.8.10)
endif()

project(phast CXX C Fortran)

# set version numbers
set(PHAST_VERSION_MAJOR "3")
set(PHAST_VERSION_MINOR "0")
set(PHAST_VERSION_PATCH "0")
set(PHAST_REVISION "9000")

# set default windows installation path
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND WIN32)
  GetDefaultWindowsPrefixBase(CMAKE_GENERIC_PROGRAM_FILES)  
  SET(CMAKE_INSTALL_PREFIX "${CMAKE_GENERIC_PROGRAM_FILES}/USGS/${PROJECT_NAME}-${PHAST_VERSION_MAJOR}.${PHAST_VERSION_MINOR}.${PHAST_VERSION_PATCH}-${PHAST_REVISION}" CACHE PATH "Install path prefix, prepeneded onto install directories." FORCE)   
endif()

include(GNUInstallDirs)

# overide docdir on windows
if(WIN32 AND NOT CMAKE_INSTALL_DOCDIR)
  set(CMAKE_INSTALL_DOCDIR "" CACHE PATH "documentation root (doc)")
  set(CMAKE_INSTALL_DOCDIR "doc")
endif()

# Disable deprecation warnings for standard C and STL functions in VS2005
# and later
if(MSVC_VERSION EQUAL 1400 OR MSVC_VERSION GREATER 1400)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE)
  ADD_DEFINITIONS(-D_SCL_SECURE_NO_WARNINGS)
endif() 

# check for openmp
find_package(OpenMP)
if (OPENMP_FOUND)  
  option(PHAST_BUILD_OPENMP "Build OpenMP configuration" "ON")
else()
  option(PHAST_BUILD_OPENMP "Build OpenMP configuration" "OFF")
endif()
if (PHAST_BUILD_OPENMP)
  find_package(OpenMP REQUIRED) 
endif()

# check for boost
find_package(Boost 1.33)

# check for HDF5 (set environmental variable HDF5_DIR)
find_package(HDF5 NAMES hdf5)

# check for MPI
option(PHAST_BUILD_MPI "Build MPI configuration (Overrides OpenMP option)" "OFF")
if (PHAST_BUILD_MPI)
  cmake_policy(SET CMP0054 OLD)
  find_package(MPI REQUIRED)
  cmake_policy(SET CMP0054 NEW)
 
  ##if (MPI_CXX_FOUND)
  ##endif()
endif()

# database
SET(phast_DATABASE
database/Amm.dat
database/ColdChem.dat
database/core10.dat
database/frezchem.dat
database/iso.dat
database/llnl.dat
database/minteq.dat
database/minteq.v4.dat
database/phast.dat
database/pitzer.dat
database/sit.dat
database/wateq4f.dat
)

IF(WIN32)
  install (FILES ${phast_DATABASE} DESTINATION database)
ELSE()
  install (FILES ${phast_DATABASE} DESTINATION ${CMAKE_INSTALL_DOCDIR}/database)
ENDIF()

### tests
##enable_testing()
##

# subdirs
add_subdirectory(doc)
add_subdirectory(examples)
#add_subdirectory(lib)
add_subdirectory(src)

include(CPack)
