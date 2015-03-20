#
# phastf
#
project(phastf Fortran)

SET(phastf_SOURCES
PhastFortran/XP_aplbce.f90
PhastFortran/XP_aplbci.F90
PhastFortran/XP_asembl.f90
PhastFortran/XP_asmslc.F90
PhastFortran/XP_crsdsp.f90
PhastFortran/XP_etom2.f90
PhastFortran/XP_module.f90
PhastFortran/XP_rhsn.f90
PhastFortran/XP_sumcal1.f90
PhastFortran/XP_wbcflo.f90
PhastFortran/XP_wellsc.f90
PhastFortran/XP_wellsr.f90
PhastFortran/aplbce_flow.f90
PhastFortran/aplbci_flow.F90
PhastFortran/asembl_flow.f90
PhastFortran/asmslp_flow.F90
PhastFortran/calc_velocity.f90
PhastFortran/calcc.f90
PhastFortran/clog.f90
PhastFortran/closef.F90
PhastFortran/coeff_flow.F90
PhastFortran/coeff_trans.F90
PhastFortran/create_mapping.f90
PhastFortran/dealloc_arr.F90
PhastFortran/dealloc_arr_worker.F90
PhastFortran/dump.f90
PhastFortran/error1.f90
PhastFortran/error2.f90
PhastFortran/error3.f90
PhastFortran/error4.f90
PhastFortran/errprt.f90
PhastFortran/etom1.f90
PhastFortran/etom2.f90
PhastFortran/hdf_f.F90
PhastFortran/ifrd.inc
PhastFortran/ifwr.inc
PhastFortran/incidx.f90
PhastFortran/indx_rewi.f90
PhastFortran/indx_rewi_bc.f90
PhastFortran/init1.F90
PhastFortran/init2_1.F90
PhastFortran/init2_1_xfer.F90
PhastFortran/init2_2.f90
PhastFortran/init2_3.f90
PhastFortran/init2_post_ss.F90
PhastFortran/init3.F90
PhastFortran/init3_xfer.F90
PhastFortran/interpolate_mod.f90
PhastFortran/ld_seg_mod.f90
PhastFortran/ldchar.f90
PhastFortran/ldchar_bc.f90
PhastFortran/mach_mod.f90
PhastFortran/modules_g.f90
PhastFortran/modules_manager.f90
PhastFortran/mpi_mod.F90
PhastFortran/mtoijk.f90
PhastFortran/nintrp.f90
PhastFortran/openf.F90
PhastFortran/phast_manager.F90
PhastFortran/phast_spmd.F90
PhastFortran/phast_worker.F90
PhastFortran/prchar.f90
PhastFortran/print_control_mod.f90
PhastFortran/printar.f90
PhastFortran/read1.F90
PhastFortran/read1_xfer.F90
PhastFortran/read2.F90
PhastFortran/read2_xfer.F90
PhastFortran/read3.F90
PhastFortran/read3_xfer.F90
PhastFortran/reorder_mod.f90
PhastFortran/rewi_mod.f90
PhastFortran/rhsn.f90
PhastFortran/rhsn_manager.F90
PhastFortran/rhsn_ss_flow.f90
PhastFortran/sbcflo.f90
PhastFortran/scale_jds_mod.f90
PhastFortran/set_component_map.F90
PhastFortran/simulate_ss_flow.f90
PhastFortran/solver_direct_mod.f90
PhastFortran/solver_iter_mod.f90
PhastFortran/stonb.f90
PhastFortran/sumcal1.F90
PhastFortran/sumcal1_manager.F90
PhastFortran/sumcal2.f90
PhastFortran/sumcal_ss_flow.f90
PhastFortran/terminate_phast.F90
PhastFortran/terminate_phast_worker.F90
PhastFortran/time_step_save.F90
PhastFortran/timestep.F90
PhastFortran/timestep_ss_flow.f90
PhastFortran/timestep_worker.F90
PhastFortran/update_print_flags.f90
PhastFortran/uppercase.f90
PhastFortran/wbbal.f90
PhastFortran/wbcflo.f90
PhastFortran/wellsc.f90
PhastFortran/wellsc_ss_flow.f90
PhastFortran/wellsr.f90
PhastFortran/wellsr_ss_flow.f90
PhastFortran/welris.f90
PhastFortran/wfdydz.f90
PhastFortran/write1.f90
PhastFortran/write2_1.f90
PhastFortran/write2_2.f90
PhastFortran/write3.f90
PhastFortran/write3_ss_flow.f90
PhastFortran/write4.f90
PhastFortran/write5.f90
PhastFortran/write5_ss_flow.f90
PhastFortran/write6.f90
PhastFortran/xfer_to_manager.F90
PhastFortran/xfer_to_workers.F90
PhastFortran/zone_flow.f90
PhastFortran/zone_flow_ss.f90
PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqc_interface.F90
PhreeqcRM/RM_interface.F90
)

add_library(phastf STATIC ${phastf_SOURCES})

#
# PhreeqcRM
#
project(PhreeqcRM CXX)

ADD_DEFINITIONS(-DSWIG_SHARED_OBJ)
ADD_DEFINITIONS(-DUSE_PHRQ_ALLOC)

ADD_DEFINITIONS(-DHDF5_CREATE)
ADD_DEFINITIONS(-DH5Dcreate_vers=1)
ADD_DEFINITIONS(-DH5Gcreate_vers=1)
ADD_DEFINITIONS(-DH5Eset_auto_vers=1)

if (PHAST_BUILD_MPI)
  ADD_DEFINITIONS(-DUSE_MPI)
else()
  if (OPENMP_FOUND)
    ADD_DEFINITIONS(-DUSE_OPENMP)
  endif()
endif()

SET(PhreeqcRM_SOURCES
PhreeqcRM/IPhreeqcPhast/IPhreeqc/CSelectedOutput.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/CSelectedOutput.hxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/CVar.hxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/Debug.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/ErrorReporter.hxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqc.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqc.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqc.hpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqcCallbacks.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqcLib.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqc_interface_F.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/Var.c
PhreeqcRM/IPhreeqcPhast/IPhreeqc/Var.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/Version.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartHandler.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartHandler.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartObject.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartObject.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/CurveObject.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/CurveObject.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ExchComp.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ExchComp.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Exchange.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Exchange.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/GasComp.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/GasComp.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/GasPhase.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/GasPhase.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolution.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolution.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolutionComp.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolutionComp.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/KineticsComp.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/KineticsComp.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NA.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NameDouble.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NameDouble.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NumKeyword.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NumKeyword.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PBasic.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PBasic.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_base.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_base.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io_output.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblage.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblage.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblageComp.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblageComp.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Parser.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Parser.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Phreeqc.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Phreeqc.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PhreeqcKeywords/Keywords.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PhreeqcKeywords/Keywords.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Pressure.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Pressure.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Reaction.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Reaction.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ReadClass.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SS.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SS.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SSassemblage.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SSassemblage.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SScomp.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SScomp.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SelectedOutput.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SelectedOutput.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Solution.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Solution.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SolutionIsotope.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SolutionIsotope.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBin.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBin.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBinList.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBinList.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Surface.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Surface.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceCharge.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceCharge.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceComp.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceComp.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/System.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/System.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Temperature.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Temperature.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Use.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Use.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/UserPunch.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/UserPunch.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Utils.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Utils.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/advection.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/basicsubs.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cl1.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cvdense.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cvdense.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cvode.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cvode.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxKinetics.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxKinetics.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxMix.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxMix.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dense.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dense.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dumper.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dumper.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dw.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/gases.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/global_structures.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/input.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/integrate.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/inverse.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/isotopes.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/kinetics.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/mainsubs.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/model.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector_serial.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector_serial.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/parse.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/phqalloc.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/phqalloc.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/phrqtype.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/pitzer.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/pitzer_structures.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/prep.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/print.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/read.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/readtr.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/runner.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/runner.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/sit.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/smalldense.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/smalldense.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/spread.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/step.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/structures.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/sundialsmath.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/sundialsmath.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/sundialstypes.h
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/tally.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/tidy.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/transport.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/utilities.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqc/thread.h
PhreeqcRM/IPhreeqcPhast/IPhreeqcPhast.cxx
PhreeqcRM/IPhreeqcPhast/IPhreeqcPhast.h
PhreeqcRM/IPhreeqcPhast/IPhreeqcPhastLib.cpp
PhreeqcRM/IPhreeqcPhast/IPhreeqcPhastLib.h
PhreeqcRM/PhreeqcRM.cpp
PhreeqcRM/RM_interface_C.cpp
PhreeqcRM/RM_interface_F.cpp
)

# setup include directories
include_directories(${Boost_INCLUDE_DIRS})
include_directories(${HDF5_INCLUDE_DIR})
include_directories("${PROJECT_SOURCE_DIR}/PhreeqcRM")
include_directories("${PROJECT_SOURCE_DIR}/PhreeqcRM/IPhreeqcPhast")
include_directories("${PROJECT_SOURCE_DIR}/PhreeqcRM/IPhreeqcPhast/IPhreeqc")
include_directories("${PROJECT_SOURCE_DIR}/PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp")
include_directories("${PROJECT_SOURCE_DIR}/PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PhreeqcKeywords")

add_library(PhreeqcRM STATIC ${PhreeqcRM_SOURCES})

#
# phast3
#
project(phast3 CXX)

SET(phast3_SOURCES
FileHandler.cpp
FileHandler.h
KDtree/Cell_Face.h
KDtree/KDtree.cpp
KDtree/KDtree.h
KDtree/Point.cpp
KDtree/Point.h
KDtree/kdtree2.cpp
TM_interface.cpp
TM_interface.h
gzstream.cxx
gzstream.h
hdf.cpp
hdf.h
phast.rc
phast_main.cpp
phast_version.h
resource.h
)


add_executable(phast3 ${phast3_SOURCES})

set(LINK_LIBS ${LINK_LIBS} phastf)
set(LINK_LIBS ${LINK_LIBS} PhreeqcRM)
set(LINK_LIBS ${LINK_LIBS} ${HDF5_LIBRARIES})

if (PHAST_BUILD_MPI)
  include_directories(${MPI_CXX_INCLUDE_PATH})
  if (MPI_Fortran_INCLUDE_PATH)
    if("${CMAKE_SIZEOF_VOID_P}" EQUAL 8)
      set(MS_MPI_ARCH_DIR amd64)
    else()
      set(MS_MPI_ARCH_DIR i386)
    endif()
    include_directories(${MPI_Fortran_INCLUDE_PATH}/${MS_MPI_ARCH_DIR})
  endif()
  set(LINK_LIBS ${LINK_LIBS} ${MPI_CXX_LIBRARIES})
  if (MPI_Fortran_LIBRARIES MATCHES "msmpi.lib$")
    STRING(REGEX REPLACE "msmpi.lib$" "msmpifec.lib" EXTRA_FORTRAN_LIB ${MPI_Fortran_LIBRARIES})
    SET(LINK_LIBS ${LINK_LIBS} ${EXTRA_FORTRAN_LIB})
  endif ()  
endif()

target_link_libraries(phast3 ${LINK_LIBS})

# install
install(TARGETS phast3 DESTINATION ${CMAKE_INSTALL_BINDIR})

### tests
##enable_testing()
##
##add_subdirectory(Tests)
