cmake_minimum_required(VERSION 3.16)

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

# check for openmp
option(PHAST_BUILD_OPENMP "Build OpenMP configuration" "OFF")
if (PHAST_BUILD_OPENMP)
  find_package(OpenMP REQUIRED) 
endif()

# check for boost
# set BOOST_ROOT using environment or cache variable
# ie 
#   cmake -DBOOST_ROOT:PATH=c:\boost_1_76_0 ..
# or
#   set BOOST_ROOT=c:\boost_1_76_0
#   cmake ..
find_package(Boost 1.33 REQUIRED)

# check for ZLIB
find_package(ZLIB REQUIRED)

# check for HDF5 (set environmental variable HDF5_DIR or HDF5_ROOT)
find_package(HDF5 1.8 REQUIRED)

# check for MPI
option(PHAST_BUILD_MPI "Build MPI configuration (Overrides OpenMP option)" "OFF")
if (PHAST_BUILD_MPI)
  # if(MSVC)
  #   SET(MPI_Fortran_LINK_FLAGS ${MPI_Fortran_LINK_FLAGS} "/NODEFAULTLIB:LIBCMT.lib")
  # endif()
  if(DEFINED ENV{MSMPI_INC} AND CMAKE_VERSION VERSION_GREATER 3.17)
    # cmakes findMPI is broken for MSMPI(Fortran) after 3.17
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")
  endif()
  find_package(MPI REQUIRED)
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
database/Tipping_Hurley.dat
database/wateq4f.dat
)

IF(WIN32)
  install (FILES ${phast_DATABASE} DESTINATION database)
ELSE()
  install (FILES ${phast_DATABASE} DESTINATION ${CMAKE_INSTALL_DOCDIR}/database)
ENDIF()

include(CTest)

# subdirs
add_subdirectory(doc)
add_subdirectory(examples)
#add_subdirectory(lib)
add_subdirectory(src)
add_subdirectory(test)

include(CPack)

message(STATUS "HDF5_DIR: ${HDF5_DIR}")
message(STATUS "HDF5_DEFINITIONS: ${HDF5_DEFINITIONS}")
message(STATUS "HDF5_INCLUDE_DIRS: ${HDF5_INCLUDE_DIRS}")
message(STATUS "HDF5_LIBRARIES: ${HDF5_LIBRARIES}")
message(STATUS "HDF5_HL_LIBRARIES: ${HDF5_HL_LIBRARIES}")
foreach(__lang IN LISTS HDF5_LANGUAGE_BINDINGS)
  message(STATUS "HDF5_${__lang}_DEFINITIONS: ${HDF5_${__lang}_DEFINITIONS}")
  message(STATUS "HDF5_${__lang}_INCLUDE_DIR: ${HDF5_${__lang}_INCLUDE_DIR}")
  message(STATUS "HDF5_${__lang}_INCLUDE_DIRS: ${HDF5_${__lang}_INCLUDE_DIRS}")
  message(STATUS "HDF5_${__lang}_LIBRARY: ${HDF5_${__lang}_LIBRARY}")
  message(STATUS "HDF5_${__lang}_LIBRARIES: ${HDF5_${__lang}_LIBRARIES}")
  message(STATUS "HDF5_${__lang}_HL_LIBRARY: ${HDF5_${__lang}_HL_LIBRARY}")
  message(STATUS "HDF5_${__lang}_HL_LIBRARIES: ${HDF5_${__lang}_HL_LIBRARIES}")
endforeach()
