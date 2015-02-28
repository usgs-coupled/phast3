cmake_minimum_required (VERSION 2.6)
project (PhreeqcRM)

### overide docdir on windows
##if(WIN32 AND NOT CMAKE_INSTALL_DOCDIR)
##  set(CMAKE_INSTALL_DOCDIR "" CACHE PATH "documentation root (doc)")
##  set(CMAKE_INSTALL_DOCDIR "doc")
##endif()

include(GNUInstallDirs)

# Disable deprecation warnings for standard C and STL functions in VS2005
# and later
IF(MSVC_VERSION EQUAL 1400 OR MSVC_VERSION GREATER 1400)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE)
  ADD_DEFINITIONS(-D_SCL_SECURE_NO_WARNINGS)
ENDIF(MSVC_VERSION EQUAL 1400 OR MSVC_VERSION GREATER 1400) 


# Copy Release to openmp
SET(CMAKE_CXX_FLAGS_OPENMP
    ${CMAKE_CXX_FLAGS_RELEASE} CACHE STRING
    "Flags used by the C++ compiler during openmp builds."
    FORCE)
SET(CMAKE_C_FLAGS_OPENMP
    ${CMAKE_C_FLAGS_RELEASE} CACHE STRING
    "Flags used by the C compiler during openmp builds."
    FORCE)
SET(CMAKE_EXE_LINKER_FLAGS_OPENMP
    ${CMAKE_EXE_LINKER_FLAGS_RELEASE} CACHE STRING
    "Flags used for linking binaries during openmp builds."
    FORCE)
SET(CMAKE_SHARED_LINKER_FLAGS_OPENMP
    ${CMAKE_SHARED_LINKER_FLAGS_RELEASE} CACHE STRING
    "Flags used by the shared libraries linker during openmp builds."
    FORCE)
MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_OPENMP
    CMAKE_C_FLAGS_OPENMP
    CMAKE_EXE_LINKER_FLAGS_OPENMP
    CMAKE_SHARED_LINKER_FLAGS_OPENMP)
    
# Copy Debug to openmp_debug
SET(CMAKE_CXX_FLAGS_OPENMP_DEBUG
    ${CMAKE_CXX_FLAGS_DEBUG} CACHE STRING
    "Flags used by the C++ compiler during debug openmp builds."
    FORCE)
SET(CMAKE_C_FLAGS_OPENMP_DEBUG
    ${CMAKE_C_FLAGS_DEBUG} CACHE STRING
    "Flags used by the C compiler during debug openmp builds."
    FORCE)
SET(CMAKE_EXE_LINKER_FLAGS_OPENMP_DEBUG
    ${CMAKE_EXE_LINKER_FLAGS_DEBUG} CACHE STRING
    "Flags used for linking binaries during debug openmp builds."
    FORCE)
SET(CMAKE_SHARED_LINKER_FLAGS_OPENMP_DEBUG
    ${CMAKE_SHARED_LINKER_FLAGS_DEBUG} CACHE STRING
    "Flags used by the shared libraries linker during debug openmp builds."
    FORCE)
MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_OPENMP_DEBUG
    CMAKE_C_FLAGS_OPENMP_DEBUG
    CMAKE_EXE_LINKER_FLAGS_OPENMP_DEBUG
    CMAKE_SHARED_LINKER_FLAGS_OPENMP_DEBUG)


# Copy Release to mpi
SET(CMAKE_CXX_FLAGS_MPI
    ${CMAKE_CXX_FLAGS_RELEASE} CACHE STRING
    "Flags used by the C++ compiler during mpi builds."
    FORCE)
SET(CMAKE_C_FLAGS_MPI
    ${CMAKE_C_FLAGS_RELEASE} CACHE STRING
    "Flags used by the C compiler during mpi builds."
    FORCE)
SET(CMAKE_EXE_LINKER_FLAGS_MPI
    ${CMAKE_EXE_LINKER_FLAGS_RELEASE} CACHE STRING
    "Flags used for linking binaries during mpi builds."
    FORCE)
SET(CMAKE_SHARED_LINKER_FLAGS_MPI
    ${CMAKE_SHARED_LINKER_FLAGS_RELEASE} CACHE STRING
    "Flags used by the shared libraries linker during mpi builds."
    FORCE)
MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_MPI
    CMAKE_C_FLAGS_MPI
    CMAKE_EXE_LINKER_FLAGS_MPI
    CMAKE_SHARED_LINKER_FLAGS_MPI)


# Copy Debug to mpi_debug
SET(CMAKE_CXX_FLAGS_MPI_DEBUG
    ${CMAKE_CXX_FLAGS_DEBUG} CACHE STRING
    "Flags used by the C++ compiler during debug mpi builds."
    FORCE)
SET(CMAKE_C_FLAGS_MPI_DEBUG
    ${CMAKE_C_FLAGS_DEBUG} CACHE STRING
    "Flags used by the C compiler during debug mpi builds."
    FORCE)
SET(CMAKE_EXE_LINKER_FLAGS_MPI_DEBUG
    ${CMAKE_EXE_LINKER_FLAGS_DEBUG} CACHE STRING
    "Flags used for linking binaries during debug mpi builds."
    FORCE)
SET(CMAKE_SHARED_LINKER_FLAGS_MPI_DEBUG
    ${CMAKE_SHARED_LINKER_FLAGS_DEBUG} CACHE STRING
    "Flags used by the shared libraries linker during debug mpi builds."
    FORCE)
MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_MPI_DEBUG
    CMAKE_C_FLAGS_MPI_DEBUG
    CMAKE_EXE_LINKER_FLAGS_MPI_DEBUG
    CMAKE_SHARED_LINKER_FLAGS_MPI_DEBUG)


    
if (CMAKE_CONFIGURATION_TYPES)
  SET(CMAKE_CONFIGURATION_TYPES "openmp_debug;openmp;mpi;mpi_debug" CACHE STRING 
  "Semicolon separated list of supported configuration types."
  FORCE)
endif (CMAKE_CONFIGURATION_TYPES)

# check for openmp
find_package(OpenMP)
if (OPENMP_FOUND)
  # openmp release
  SET(CMAKE_C_FLAGS_OPENMP
      "-DUSE_OPENMP ${CMAKE_C_FLAGS_OPENMP} ${OpenMP_C_FLAGS}" CACHE STRING
      "Flags used by the compiler during openmp builds."
      FORCE)
  SET(CMAKE_CXX_FLAGS_OPENMP
      "-DUSE_OPENMP ${CMAKE_CXX_FLAGS_OPENMP} ${OpenMP_CXX_FLAGS}" CACHE STRING
      "Flags used by the compiler during openmp builds."
      FORCE)

  # openmp debug
  SET(CMAKE_C_FLAGS_OPENMP_DEBUG
      "-DUSE_OPENMP ${CMAKE_C_FLAGS_OPENMP_DEBUG} ${OpenMP_C_FLAGS}" CACHE STRING
      "Flags used by the compiler during debug openmp builds."
      FORCE)
  SET(CMAKE_CXX_FLAGS_OPENMP_DEBUG
      "-DUSE_OPENMP ${CMAKE_CXX_FLAGS_OPENMP_DEBUG} ${OpenMP_CXX_FLAGS}" CACHE STRING
      "Flags used by the compiler during debug openmp builds."
      FORCE)
endif(OPENMP_FOUND)


# check for MPI
option(PHREEQCRM_BUILD_MPI "Build MPI configuration" "OFF")
if (PHREEQCRM_BUILD_MPI)
  cmake_policy(SET CMP0054 OLD)
  find_package(MPI)
  cmake_policy(SET CMP0054 NEW)
  if (MPI_CXX_FOUND)
    # mpi release
    SET(CMAKE_C_FLAGS_MPI
        "-DUSE_MPI ${CMAKE_C_FLAGS_MPI} ${MPI_C_COMPILE_FLAGS}" CACHE STRING
        "Flags used by the compiler during mpi builds."
        FORCE)
    SET(CMAKE_CXX_FLAGS_MPI
        "-DUSE_MPI ${CMAKE_CXX_FLAGS_MPI} ${MPI_CXX_COMPILE_FLAGS}" CACHE STRING
        "Flags used by the compiler during mpi builds."
        FORCE)
    if (MPI_C_INCLUDE_PATH)
      SET(CMAKE_C_FLAGS_MPI
          "-I\"${MPI_C_INCLUDE_PATH}\" ${CMAKE_C_FLAGS_MPI}" CACHE STRING
          "Flags used by the compiler during mpi builds."
          FORCE)
    endif(MPI_C_INCLUDE_PATH)
    if (MPI_CXX_INCLUDE_PATH)
      SET(CMAKE_CXX_FLAGS_MPI
          "-I\"${MPI_CXX_INCLUDE_PATH}\" ${CMAKE_CXX_FLAGS_MPI}" CACHE STRING
          "Flags used by the compiler during mpi builds."
          FORCE)
    endif(MPI_CXX_INCLUDE_PATH)
    
    # mpi debug
    SET(CMAKE_C_FLAGS_MPI_DEBUG
        "-DUSE_MPI ${CMAKE_C_FLAGS_MPI_DEBUG} ${MPI_C_COMPILE_FLAGS}" CACHE STRING
        "Flags used by the compiler during debug mpi builds."
        FORCE)
    SET(CMAKE_CXX_FLAGS_MPI_DEBUG
        "-DUSE_MPI ${CMAKE_CXX_FLAGS_MPI_DEBUG} ${MPI_CXX_COMPILE_FLAGS}" CACHE STRING
        "Flags used by the compiler during debug mpi builds."
        FORCE)
    if (MPI_C_INCLUDE_PATH)
      SET(CMAKE_C_FLAGS_MPI_DEBUG
          "-I\"${MPI_C_INCLUDE_PATH}\" ${CMAKE_C_FLAGS_MPI_DEBUG}" CACHE STRING
          "Flags used by the compiler during debug mpi builds."
          FORCE)
    endif(MPI_C_INCLUDE_PATH)
    if (MPI_CXX_INCLUDE_PATH)
      SET(CMAKE_CXX_FLAGS_MPI_DEBUG
          "-I\"${MPI_CXX_INCLUDE_PATH}\" ${CMAKE_CXX_FLAGS_MPI_DEBUG}" CACHE STRING
          "Flags used by the compiler during debug mpi builds."
          FORCE)
    endif(MPI_CXX_INCLUDE_PATH)  
  endif(MPI_CXX_FOUND)
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

SET(PhreeqcRM_SOURCES
PhreeqcRM.cpp
RM_interface_C.cpp
IPhreeqcPhast/IPhreeqcPhast.cxx
IPhreeqcPhast/IPhreeqcPhast.h
IPhreeqcPhast/IPhreeqcPhastLib.cpp
IPhreeqcPhast/IPhreeqcPhastLib.h
IPhreeqcPhast/IPhreeqc/thread.h
IPhreeqcPhast/IPhreeqc/CSelectedOutput.cpp
IPhreeqcPhast/IPhreeqc/CSelectedOutput.hxx
IPhreeqcPhast/IPhreeqc/CVar.hxx
IPhreeqcPhast/IPhreeqc/Debug.h
IPhreeqcPhast/IPhreeqc/ErrorReporter.hxx
IPhreeqcPhast/IPhreeqc/IPhreeqc.cpp
IPhreeqcPhast/IPhreeqc/IPhreeqc.h
IPhreeqcPhast/IPhreeqc/IPhreeqc.hpp
IPhreeqcPhast/IPhreeqc/IPhreeqcCallbacks.h
IPhreeqcPhast/IPhreeqc/IPhreeqcLib.cpp
IPhreeqcPhast/IPhreeqc/Var.c
IPhreeqcPhast/IPhreeqc/Var.h
IPhreeqcPhast/IPhreeqc/Version.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/advection.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/basicsubs.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/cl1.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/cvdense.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/cvdense.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/cvode.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/cvode.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxKinetics.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxKinetics.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxMix.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxMix.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/dense.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/dense.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/dumper.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/dumper.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/dw.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/gases.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/global_structures.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/input.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/integrate.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/inverse.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/isotopes.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/kinetics.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/mainsubs.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/model.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector_serial.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector_serial.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/parse.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/phqalloc.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/phqalloc.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/phrqtype.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/pitzer.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/pitzer_structures.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/prep.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/print.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/read.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/readtr.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/runner.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/runner.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/sit.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/smalldense.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/smalldense.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/spread.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/step.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/structures.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/sundialsmath.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/sundialsmath.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/sundialstypes.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/tally.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/tidy.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/transport.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/utilities.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartHandler.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartHandler.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartObject.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartObject.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/CurveObject.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/CurveObject.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/ExchComp.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/ExchComp.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Exchange.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/Exchange.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/GasComp.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/GasComp.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/GasPhase.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/GasPhase.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolution.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolution.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolutionComp.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolutionComp.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/KineticsComp.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/KineticsComp.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/NA.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/NameDouble.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/NameDouble.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/NumKeyword.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/NumKeyword.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/PBasic.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/PBasic.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_base.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_base.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io_output.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblage.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblage.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblageComp.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblageComp.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Parser.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/Parser.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Phreeqc.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/Phreeqc.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/PhreeqcKeywords/Keywords.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/PhreeqcKeywords/Keywords.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Pressure.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/Pressure.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Reaction.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/Reaction.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/ReadClass.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/SS.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/SS.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/SSassemblage.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/SSassemblage.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/SScomp.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/SScomp.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/SelectedOutput.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/SelectedOutput.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Solution.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/Solution.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/SolutionIsotope.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/SolutionIsotope.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBin.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBin.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBinList.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBinList.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Surface.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/Surface.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceCharge.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceCharge.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceComp.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceComp.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/System.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/System.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Temperature.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/Temperature.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Use.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/Use.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/UserPunch.cpp
IPhreeqcPhast/IPhreeqc/phreeqcpp/UserPunch.h
IPhreeqcPhast/IPhreeqc/phreeqcpp/Utils.cxx
IPhreeqcPhast/IPhreeqc/phreeqcpp/Utils.h
)

# setup include directories
include_directories("${PROJECT_SOURCE_DIR}/IPhreeqcPhast")
include_directories("${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc")
include_directories("${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc/phreeqcpp")
include_directories("${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc/phreeqcpp/PhreeqcKeywords")


## if (BUILD_FORTRAN)
##IPhreeqcPhast/IPhreeqc/fwrap1.cpp
##IPhreeqcPhast/IPhreeqc/fwrap2.cpp
##IPhreeqcPhast/IPhreeqc/fwrap3.cpp
##IPhreeqcPhast/IPhreeqc/fwrap4.cpp
##IPhreeqcPhast/IPhreeqc/fwrap5.cpp
##IPhreeqcPhast/IPhreeqc/fwrap6.cpp
## endif (BUILD_FORTRAN)


add_library(PhreeqcRM STATIC ${PhreeqcRM_SOURCES})



SET(PhreeqcRM_Headers
${PROJECT_SOURCE_DIR}/IrmResult.h
${PROJECT_SOURCE_DIR}/PhreeqcRM.h
${PROJECT_SOURCE_DIR}/RM_interface_C.h
${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqcPhast.h
${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc/IPhreeqc.h
${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc/IPhreeqc.hpp
${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc/IPhreeqcCallbacks.h
${PROJECT_SOURCE_DIR}/IPhreeqcPhast/IPhreeqc/Var.h
)

# install
install(TARGETS PhreeqcRM DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(FILES ${PhreeqcRM_Headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

# tests
enable_testing()

# Tests/advect.pqi
configure_file (
  "${PROJECT_SOURCE_DIR}/Tests/advect.pqi.in"
  "${PROJECT_BINARY_DIR}/Tests/advect.pqi"
  )

# Tests/phreeqc.dat
configure_file (
  "${PROJECT_SOURCE_DIR}/Tests/phreeqc.dat.in"
  "${PROJECT_BINARY_DIR}/Tests/phreeqc.dat"
  )

# Tests/units.pqi
configure_file (
  "${PROJECT_SOURCE_DIR}/Tests/units.pqi.in"
  "${PROJECT_BINARY_DIR}/Tests/units.pqi"
  )

SET(testrm_SOURCES
  ${PROJECT_SOURCE_DIR}/Tests/advection_c.c
  ${PROJECT_SOURCE_DIR}/Tests/advection_cpp.cpp
  ${PROJECT_SOURCE_DIR}/Tests/main.cpp
  ${PROJECT_SOURCE_DIR}/Tests/species_c.c
  ${PROJECT_SOURCE_DIR}/Tests/species_cpp.cpp
)

add_executable(testrm ${testrm_SOURCES})
SET(EXTRA_LIBS ${EXTRA_LIBS} PhreeqcRM)
include_directories ("${PROJECT_SOURCE_DIR}")
target_link_libraries(testrm ${EXTRA_LIBS})

add_test (
  NAME CompileAndRun
  COMMAND testrm
  WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/Tests
  )
