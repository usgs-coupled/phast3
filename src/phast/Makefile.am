AM_CPPFLAGS=-I$(srcdir)/PhreeqcRM -I$(srcdir)/PhreeqcRM/IPhreeqcPhast -I$(srcdir)/PhreeqcRM/IPhreeqcPhast/IPhreeqc -I$(srcdir)/PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp $(BOOST_CPPFLAGS)

AM_FCFLAGS=-I$(srcdir)/PhreeqcRM/IPhreeqcPhast/IPhreeqc

FCDEFS=-DHDF5_CREATE

dist_bin_SCRIPTS = phast

if BUILD_MPI
bin_PROGRAMS = phast-mpi
FCDEFS+=-DUSE_MPI
else
if BUILD_OPENMP
bin_PROGRAMS = phast-openmp
FCDEFS+=-DUSE_OPENMP
else
bin_PROGRAMS = phast-ser
endif #BUILD_OPENMP
endif #BUILD_MPI 

PHAST_SRC=\
	FileHandler.cpp\
	FileHandler.h\
	gzstream.cxx\
	gzstream.h\
	hdf.cpp\
	hdf.h\
	phast_main.cpp\
	TM_interface.cpp\
	TM_interface.h\
	KDtree/Cell_Face.h\
	KDtree/kdtree2.cpp\
	KDtree/KDtree.cpp\
	KDtree/KDtree.h\
	KDtree/Point.cpp\
	KDtree/Point.h\
	PhastFortran/aplbce_flow.f90\
	PhastFortran/aplbci_flow.F90\
	PhastFortran/asembl_flow.f90\
	PhastFortran/asmslp_flow.F90\
	PhastFortran/calcc.f90\
	PhastFortran/calc_frac2.F90\
	PhastFortran/calc_velocity.f90\
	PhastFortran/clog.f90\
	PhastFortran/closef.F90\
	PhastFortran/coeff_flow.F90\
	PhastFortran/coeff_trans.F90\
	PhastFortran/create_mapping.f90\
	PhastFortran/dealloc_arr.F90\
	PhastFortran/dealloc_arr_worker.F90\
	PhastFortran/dump.f90\
	PhastFortran/error1.f90\
	PhastFortran/error2.f90\
	PhastFortran/error3.f90\
	PhastFortran/error4.f90\
	PhastFortran/errprt.f90\
	PhastFortran/etom1.f90\
	PhastFortran/etom2.f90\
	PhastFortran/hdf_f.F90\
	PhastFortran/ifrd.inc\
	PhastFortran/ifwr.inc\
	PhastFortran/incidx.f90\
	PhastFortran/indx_rewi_bc.f90\
	PhastFortran/indx_rewi.f90\
	PhastFortran/init1.F90\
	PhastFortran/init2_1.F90\
	PhastFortran/init2_1_xfer.F90\
	PhastFortran/init2_2.f90\
	PhastFortran/init2_3.f90\
	PhastFortran/init2_post_ss.F90\
	PhastFortran/init3.F90\
	PhastFortran/init3_xfer.F90\
	PhastFortran/interpolate_mod.f90\
	PhastFortran/ldchar_bc.f90\
	PhastFortran/ldchar.f90\
	PhastFortran/ld_seg_mod.f90\
	PhastFortran/mach_mod.f90\
	PhastFortran/Makefile\
	PhastFortran/modules_g.f90\
	PhastFortran/modules_manager.f90\
	PhastFortran/mpi_mod.F90\
	PhastFortran/mtoijk.f90\
	PhastFortran/nintrp.f90\
	PhastFortran/openf.F90\
	PhastFortran/phast_manager.F90\
	PhastFortran/phast_spmd.F90\
	PhastFortran/phast_worker.F90\
	PhastFortran/Pointers_to_fortran.h\
	PhastFortran/prchar.f90\
	PhastFortran/printar.f90\
	PhastFortran/print_control_mod.f90\
	PhastFortran/read1.F90\
	PhastFortran/read1_xfer.F90\
	PhastFortran/read2.F90\
	PhastFortran/read2_xfer.F90\
	PhastFortran/read3.F90\
	PhastFortran/read3_xfer.F90\
	PhastFortran/reorder_mod.f90\
	PhastFortran/revisions\
	PhastFortran/rewi_mod.f90\
	PhastFortran/rhsn.f90\
	PhastFortran/rhsn_flow.f90\
	PhastFortran/rhsn_manager.F90\
	PhastFortran/rhsn_ss_flow.f90\
	PhastFortran/sbcflo.f90\
	PhastFortran/scale_jds_mod.f90\
	PhastFortran/set_component_map.F90\
	PhastFortran/simulate_ss_flow.f90\
	PhastFortran/solver_direct_mod.f90\
	PhastFortran/solver_iter_mod.f90\
	PhastFortran/stonb.f90\
	PhastFortran/sumcal0_manager.F90\
	PhastFortran/sumcal1.F90\
	PhastFortran/sumcal1_manager.F90\
	PhastFortran/sumcal2.f90\
	PhastFortran/sumcal_ss_flow.f90\
	PhastFortran/terminate_phast.F90\
	PhastFortran/terminate_phast_worker.F90\
	PhastFortran/timestep.F90\
	PhastFortran/time_step_save.F90\
	PhastFortran/timestep_ss_flow.f90\
	PhastFortran/timestep_worker.F90\
	PhastFortran/update_print_flags.f90\
	PhastFortran/uppercase.f90\
	PhastFortran/wbbal.f90\
	PhastFortran/wbcflo.f90\
	PhastFortran/wellsc.f90\
	PhastFortran/wellsc_ss_flow.f90\
	PhastFortran/wellsr.f90\
	PhastFortran/wellsr_ss_flow.f90\
	PhastFortran/welris.f90\
	PhastFortran/wfdydz.f90\
	PhastFortran/write1.f90\
	PhastFortran/write2_1.f90\
	PhastFortran/write2_2.f90\
	PhastFortran/write3.f90\
	PhastFortran/write3_ss_flow.f90\
	PhastFortran/write4.f90\
	PhastFortran/write5.f90\
	PhastFortran/write5_ss_flow.f90\
	PhastFortran/write6.f90\
	PhastFortran/xfer_to_manager.F90\
	PhastFortran/xfer_to_workers.F90\
	PhastFortran/XP_aplbce.f90\
	PhastFortran/XP_aplbci.F90\
	PhastFortran/XP_asembl.f90\
	PhastFortran/XP_asmslc.F90\
	PhastFortran/XP_crsdsp.f90\
	PhastFortran/XP_etom2.f90\
	PhastFortran/XP_module.F90\
	PhastFortran/XP_rhsn.f90\
	PhastFortran/XP_sumcal1.f90\
	PhastFortran/XP_wbcflo.f90\
	PhastFortran/XP_wellsc.f90\
	PhastFortran/XP_wellsr.f90\
	PhastFortran/zone_flow.f90\
	PhastFortran/zone_flow_ss.f90\
	PhreeqcRM/PhreeqcRM.cpp\
	PhreeqcRM/RM_interface.F90\
	PhreeqcRM/RM_interface_C.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqcPhast.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqcPhast.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqcPhastLib.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqcPhastLib.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/fwrap.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/fwrap.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/thread.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/CSelectedOutput.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/CSelectedOutput.hxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/CVar.hxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/Debug.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/ErrorReporter.hxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqc.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqc.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqc.hpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqcCallbacks.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqcLib.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/Var.c\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/Var.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/Version.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/IPhreeqcF.f\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/advection.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/basicsubs.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cl1.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cvdense.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cvdense.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cvode.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cvode.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxKinetics.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxKinetics.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxMix.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/cxxMix.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dense.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dense.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dumper.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dumper.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/dw.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/gases.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/global_structures.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/input.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/integrate.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/inverse.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/isotopes.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/kinetics.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/mainsubs.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/model.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector_serial.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/nvector_serial.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/parse.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/phqalloc.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/phqalloc.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/phrqtype.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/pitzer.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/pitzer_structures.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/prep.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/print.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/read.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/readtr.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/runner.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/runner.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/sit.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/smalldense.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/smalldense.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/spread.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/step.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/structures.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/sundialsmath.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/sundialsmath.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/sundialstypes.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/tally.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/tidy.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/transport.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/utilities.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartHandler.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartHandler.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartObject.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ChartObject.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/CurveObject.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/CurveObject.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ExchComp.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ExchComp.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Exchange.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Exchange.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/GasComp.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/GasComp.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/GasPhase.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/GasPhase.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolution.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolution.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolutionComp.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ISolutionComp.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Keywords.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Keywords.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/KineticsComp.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/KineticsComp.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NA.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NameDouble.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NameDouble.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NumKeyword.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/NumKeyword.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PBasic.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PBasic.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_base.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_base.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PHRQ_io_output.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblage.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblage.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblageComp.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/PPassemblageComp.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Parser.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Parser.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Phreeqc.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Phreeqc.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Pressure.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Pressure.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Reaction.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Reaction.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/ReadClass.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SS.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SS.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SSassemblage.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SSassemblage.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SScomp.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SScomp.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SelectedOutput.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SelectedOutput.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Solution.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Solution.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SolutionIsotope.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SolutionIsotope.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBin.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBin.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBinList.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/StorageBinList.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Surface.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Surface.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceCharge.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceCharge.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceComp.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/SurfaceComp.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/System.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/System.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Temperature.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Temperature.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Use.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Use.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/UserPunch.cpp\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/UserPunch.h\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Utils.cxx\
	PhreeqcRM/IPhreeqcPhast/IPhreeqc/phreeqcpp/Utils.h


phast_openmp_SOURCES=$(PHAST_SRC)

phast_mpi_SOURCES=$(PHAST_SRC)

phast_ser_SOURCES=$(PHAST_SRC)

phast_openmp_LDADD = $(FCLIBS) $(HDF5_LDFLAGS)

phast_mpi_LDADD = $(FCLIBS) $(HDF5_LDFLAGS)

phast_ser_LDADD = $(FCLIBS) $(HDF5_LDFLAGS)

# We must override the default PPFCCOMPILE since ifort can't
# handle the FC_FUNC define correctly so $(DEFS) is replaced
# by $(FCDEFS)
#
PPFCCOMPILE = $(FC) $(FCDEFS) $(DEFAULT_INCLUDES) $(INCLUDES) \
	$(AM_CPPFLAGS) $(CPPFLAGS) $(AM_FCFLAGS) $(FCFLAGS)

# compile all C files as C++
#
COMPILE = $(CXXCOMPILE)

CLEANFILES=\
	$(SCRIPTS)\
	f_units.$(F90_MODEXT)\
	hdf_media.$(F90_MODEXT)\
	interpolate_mod.$(F90_MODEXT)\
	ld_seg_mod.$(F90_MODEXT)\
	machine_constants.$(F90_MODEXT)\
	mcb2.$(F90_MODEXT)\
	mcb.$(F90_MODEXT)\
	mcch.$(F90_MODEXT)\
	mcc.$(F90_MODEXT)\
	mcg.$(F90_MODEXT)\
	mcm.$(F90_MODEXT)\
	mcn.$(F90_MODEXT)\
	mcp.$(F90_MODEXT)\
	mcs2.$(F90_MODEXT)\
	mcs.$(F90_MODEXT)\
	mct.$(F90_MODEXT)\
	mcv.$(F90_MODEXT)\
	mcw.$(F90_MODEXT)\
	mg2.$(F90_MODEXT)\
	mg3.$(F90_MODEXT)\
	mpi_mod.$(F90_MODEXT)\
	phys_const.$(F90_MODEXT)\
	print_control_mod.$(F90_MODEXT)\
	rewi_mod.$(F90_MODEXT)

include .depend
