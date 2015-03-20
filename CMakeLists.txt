cmake_minimum_required (VERSION 2.8.10)

##enable_language(Fortran)

if (POLICY CMP0054)
  cmake_policy(PUSH)
  cmake_policy(SET CMP0054 OLD)
endif()
project(phast CXX C Fortran)
if (POLICY CMP0054)
  cmake_policy(POP)
endif()

### overide docdir on windows
##if(WIN32 AND NOT CMAKE_INSTALL_DOCDIR)
##  set(CMAKE_INSTALL_DOCDIR "" CACHE PATH "documentation root (doc)")
##  set(CMAKE_INSTALL_DOCDIR "doc")
##endif()

include(GNUInstallDirs)

# Disable deprecation warnings for standard C and STL functions in VS2005
# and later
if(MSVC_VERSION EQUAL 1400 OR MSVC_VERSION GREATER 1400)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE)
  ADD_DEFINITIONS(-D_SCL_SECURE_NO_WARNINGS)
endif() 

# check for openmp
find_package(OpenMP)
if (OPENMP_FOUND)
endif()

# check for boost
find_package(Boost 1.33)

# check for HDF5 (set environmental variable HDF5_DIR)
find_package(HDF5 NAMES hdf5)

# check for MPI
option(PHAST_BUILD_MPI "Build MPI configuration" "OFF")
if (PHAST_BUILD_MPI)
  cmake_policy(SET CMP0054 OLD)
  find_package(MPI)
  cmake_policy(SET CMP0054 NEW)
  
  if (MPI_CXX_FOUND)
  endif()
endif()

### tests
##enable_testing()
##
add_subdirectory(src)
