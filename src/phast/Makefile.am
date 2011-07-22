AM_CPPFLAGS=-I$(srcdir)/phreeqcpp -I$(srcdir)/phreeqcpp/phreeqc $(BOOST_CPPFLAGS)

FCDEFS=-DHDF5_CREATE

dist_bin_SCRIPTS = phast

if BUILD_MPI
  bin_PROGRAMS = phast-mpi
  FCDEFS+=-DUSE_MPI -DMERGE_FILES
else
  bin_PROGRAMS = phast-ser
endif

PHAST_SRC=\
	abmult.f90\
	aplbce.f90\
	aplbce_ss_flow.f90\
	aplbci.f90\
	armult.f90\
	asembl.f90\
	asmslc.f90\
	asmslp.f90\
	asmslp_ss_flow.f90\
	bsode.f90\
	calc_velocity.f90\
	calcc.f90\
	clog.f90\
	closef.F90\
	coeff.f90\
	coeff_ss_flow.f90\
	crsdsp.f90\
	cxxHstSubs.cxx\
	d4ord.f90\
	d4zord.f90\
	dbmult.f90\
	dump.f90\
	efact.f90\
	ehoftp.f90\
	el1slv.f90\
	elslv.f90\
	error1.f90\
	error2.f90\
	error3.f90\
	error4.f90\
	errprt.f90\
	etom1.f90\
	etom2.f90\
	euslv.f90\
	formr.f90\
	gcgris.f90\
	gzstream.cxx\
	gzstream.h\
	hdf.c\
	hdf_f.f90\
	hst.cxx\
	hst.h\
	hstsubs.c\
	hunt.f90\
	ifrd.inc\
	ifwr.inc\
	incidx.f90\
	indx_rewi.f90\
	indx_rewi_bc.f90\
	init1.f90\
	init2_1.f90\
	init2_2.f90\
	init2_3.f90\
	init2_post_ss.f90\
	init3.f90\
	interpolate_mod.f90\
	ld_seg_mod.f90\
	ldchar.f90\
	ldchar_bc.f90\
	ldci.f90\
	ldcir.f90\
	ldind.f90\
	ldipen.f90\
	ldmar1.f90\
	lsolv.f90\
	media_hdf.f90\
	modules.f90\
	mtoijk.f90\
	nintrp.f90\
	openf.F90\
	phast.F90\
	phast_files.c\
	phast_files.h\
	phast_main.cpp\
	phast_root.F90\
	phastproto.h\
	Pointers_to_fortran.h\
	prchar.f90\
	print_control_mod.f90\
	prntar.f90\
	rbord.f90\
	read1.f90\
	read2.f90\
	read3.f90\
	reordr.f90\
	rewi_mod.f90\
	rfact.f90\
	rfactm.f90\
	rhsn.f90\
	rhsn_ss_flow.f90\
	sbcflo.f90\
	scale_jds.f90\
	simulate_ss_flow.f90\
	stonb.f90\
	sumcal1.f90\
	sumcal2.f90\
	sumcal_ss_flow.f90\
	terminate_phast.F90\
	tfrds.f90\
	timstp.f90\
	timstp_ss_flow.f90\
	update_print_flags.f90\
	uppercase.f90\
	usolv.f90\
	viscos.f90\
	vpsv.f90\
	wbbal.f90\
	wbcflo.f90\
	wellsc.f90\
	wellsc_ss_flow.f90\
	wellsr.f90\
	wellsr_ss_flow.f90\
	welris.f90\
	wfdydz.f90\
	write1.f90\
	write2_1.f90\
	write2_2.f90\
	write3.f90\
	write3_ss_flow.f90\
	write4.f90\
	write5.f90\
	write5_ss_flow.f90\
	write6.f90\
	zone_flow.f90\
	zone_flow_ss.f90\
	phreeqcpp/cxxKinetics.cxx\
	phreeqcpp/cxxKinetics.h\
	phreeqcpp/cxxMix.cxx\
	phreeqcpp/cxxMix.h\
	phreeqcpp/Dictionary.cxx\
	phreeqcpp/Dictionary.h\
	phreeqcpp/dumper.cpp\
	phreeqcpp/dumper.h\
	phreeqcpp/Exchange.cxx\
	phreeqcpp/Exchange.h\
	phreeqcpp/ExchComp.cxx\
	phreeqcpp/ExchComp.h\
	phreeqcpp/GasPhase.cxx\
	phreeqcpp/GasPhase.h\
	phreeqcpp/ISolutionComp.cxx\
	phreeqcpp/ISolutionComp.h\
	phreeqcpp/ISolution.cxx\
	phreeqcpp/ISolution.h\
	phreeqcpp/KineticsComp.cxx\
	phreeqcpp/KineticsComp.h\
	phreeqcpp/NameDouble.cxx\
	phreeqcpp/NameDouble.h\
	phreeqcpp/NumKeyword.cxx\
	phreeqcpp/NumKeyword.h\
	phreeqcpp/Parser.cxx\
	phreeqcpp/Parser.h\
	phreeqcpp/Phreeqc_class.h\
	phreeqcpp/Phreeqc.h\
	phreeqcpp/PPassemblageComp.cxx\
	phreeqcpp/PPassemblageComp.h\
	phreeqcpp/PPassemblage.cxx\
	phreeqcpp/PPassemblage.h\
	phreeqcpp/Reaction.cxx\
	phreeqcpp/Reaction.h\
	phreeqcpp/ReadClass.cxx\
	phreeqcpp/runner.cpp\
	phreeqcpp/runner.h\
	phreeqcpp/Solution.cxx\
	phreeqcpp/Solution.h\
	phreeqcpp/SolutionIsotope.cxx\
	phreeqcpp/SolutionIsotope.h\
	phreeqcpp/SolutionIsotopeList.cxx\
	phreeqcpp/SolutionIsotopeList.h\
	phreeqcpp/SSassemblage.cxx\
	phreeqcpp/SSassemblage.h\
	phreeqcpp/SSassemblageSS.cxx\
	phreeqcpp/SSassemblageSS.h\
	phreeqcpp/StorageBin.cxx\
	phreeqcpp/StorageBin.h\
	phreeqcpp/StorageBinList.cpp\
	phreeqcpp/StorageBinList.h\
	phreeqcpp/SurfaceCharge.cxx\
	phreeqcpp/SurfaceCharge.h\
	phreeqcpp/SurfaceComp.cxx\
	phreeqcpp/SurfaceComp.h\
	phreeqcpp/Surface.cxx\
	phreeqcpp/Surface.h\
	phreeqcpp/System.cxx\
	phreeqcpp/System.h\
	phreeqcpp/Temperature.cxx\
	phreeqcpp/Temperature.h\
	phreeqcpp/test.xml\
	phreeqcpp/Utils.cxx\
	phreeqcpp/Utils.h\
	phreeqcpp/phreeqc/advection.c\
	phreeqcpp/phreeqc/basic.c\
	phreeqcpp/phreeqc/basic.h\
	phreeqcpp/phreeqc/basicsubs.c\
	phreeqcpp/phreeqc/cl1.c\
	phreeqcpp/phreeqc/cvdense.c\
	phreeqcpp/phreeqc/cvdense.h\
	phreeqcpp/phreeqc/cvode.c\
	phreeqcpp/phreeqc/cvode.h\
	phreeqcpp/phreeqc/dense.c\
	phreeqcpp/phreeqc/dense.h\
	phreeqcpp/phreeqc/dw.c\
	phreeqcpp/phreeqc/global.h\
	phreeqcpp/phreeqc/global_structures.h\
	phreeqcpp/phreeqc/input.c\
	phreeqcpp/phreeqc/input.h\
	phreeqcpp/phreeqc/integrate.c\
	phreeqcpp/phreeqc/inverse.c\
	phreeqcpp/phreeqc/isotopes.c\
	phreeqcpp/phreeqc/kinetics.c\
	phreeqcpp/phreeqc/kinetics.h\
	phreeqcpp/phreeqc/mainsubs.c\
	phreeqcpp/phreeqc/model.c\
	phreeqcpp/phreeqc/nvector.c\
	phreeqcpp/phreeqc/nvector.h\
	phreeqcpp/phreeqc/nvector_serial.c\
	phreeqcpp/phreeqc/nvector_serial.h\
	phreeqcpp/phreeqc/output.c\
	phreeqcpp/phreeqc/output.h\
	phreeqcpp/phreeqc/p2c.h\
	phreeqcpp/phreeqc/p2clib.c\
	phreeqcpp/phreeqc/parse.c\
	phreeqcpp/phreeqc/phqalloc.c\
	phreeqcpp/phreeqc/phqalloc.h\
	phreeqcpp/phreeqc/phrqproto.h\
	phreeqcpp/phreeqc/phrqtype.h\
	phreeqcpp/phreeqc/pitzer.c\
	phreeqcpp/phreeqc/pitzer.h\
	phreeqcpp/phreeqc/pitzer_structures.c\
	phreeqcpp/phreeqc/pitzer_structures.h\
	phreeqcpp/phreeqc/prep.c\
	phreeqcpp/phreeqc/print.c\
	phreeqcpp/phreeqc/read.c\
	phreeqcpp/phreeqc/readtr.c\
	phreeqcpp/phreeqc/sit.c\
	phreeqcpp/phreeqc/smalldense.c\
	phreeqcpp/phreeqc/smalldense.h\
	phreeqcpp/phreeqc/spread.c\
	phreeqcpp/phreeqc/step.c\
	phreeqcpp/phreeqc/structures.c\
	phreeqcpp/phreeqc/sundialsmath.c\
	phreeqcpp/phreeqc/sundialsmath.h\
	phreeqcpp/phreeqc/sundialstypes.h\
	phreeqcpp/phreeqc/tally.c\
	phreeqcpp/phreeqc/tidy.c\
	phreeqcpp/phreeqc/transport.c\
	phreeqcpp/phreeqc/utilities.c\
	KDtree/Cell_Face.h\
	KDtree/KDtree.cpp\
	KDtree/KDtree.h\
	KDtree/kdtree2.cpp\
	KDtree/kdtree2.hpp\
	KDtree/Point.cpp\
	KDtree/Point.h

PHAST_MPI_SRC=\
	mpimod.F90\
	merge.c\
	phast_slave.F90\
	slavesubs.c

phast_ser_SOURCES=$(PHAST_SRC)

phast_mpi_SOURCES=$(PHAST_SRC) $(PHAST_MPI_SRC)

phast_ser_LDADD = $(FCLIBS) $(HDF5_LDFLAGS)

phast_mpi_LDADD = $(FCLIBS) $(HDF5_LDFLAGS)


# We must override the default PPFCCOMPILE since ifort can't
# handle the FC_FUNC define correctly so $(DEFS) is replaced
# by $(FCDEFS)
#
PPFCCOMPILE = $(FC) $(FCDEFS) $(DEFAULT_INCLUDES) $(INCLUDES) \
	$(AM_CPPFLAGS) $(CPPFLAGS) $(AM_FCFLAGS) $(FCFLAGS)

# compile all C files as C++
#
COMPILE = $(CXXCOMPILE)

abmult.$(OBJEXT):            modules.$(OBJEXT)
aplbce.$(OBJEXT):            modules.$(OBJEXT)
aplbce_ss_flow.$(OBJEXT):    modules.$(OBJEXT)
aplbci.$(OBJEXT):            modules.$(OBJEXT)
armult.$(OBJEXT):            modules.$(OBJEXT)
asembl.$(OBJEXT):            modules.$(OBJEXT)
asmslc.$(OBJEXT):            modules.$(OBJEXT)
asmslp.$(OBJEXT):            modules.$(OBJEXT)
asmslp_ss_flow.$(OBJEXT):    modules.$(OBJEXT)
bsode.$(OBJEXT):             modules.$(OBJEXT)
calc_velocity.$(OBJEXT):     modules.$(OBJEXT)
calcc.$(OBJEXT):             modules.$(OBJEXT)
clog.$(OBJEXT):              modules.$(OBJEXT)
closef.$(OBJEXT):            modules.$(OBJEXT) mpimod.$(OBJEXT)
coeff.$(OBJEXT):             modules.$(OBJEXT)
coeff_ss_flow.$(OBJEXT):     modules.$(OBJEXT)
crsdsp.$(OBJEXT):            modules.$(OBJEXT)
d4ord.$(OBJEXT):             modules.$(OBJEXT)
d4zord.$(OBJEXT):            modules.$(OBJEXT)
dbmult.$(OBJEXT):            modules.$(OBJEXT)
dump.$(OBJEXT):              modules.$(OBJEXT)
efact.$(OBJEXT):             modules.$(OBJEXT)
ehoftp.$(OBJEXT):            modules.$(OBJEXT)
el1slv.$(OBJEXT):            modules.$(OBJEXT)
elslv.$(OBJEXT):             modules.$(OBJEXT)
error1.$(OBJEXT):            modules.$(OBJEXT)
error2.$(OBJEXT):            modules.$(OBJEXT)
error3.$(OBJEXT):            modules.$(OBJEXT) print_control_mod.$(OBJEXT)
error4.$(OBJEXT):            modules.$(OBJEXT) ifwr.inc
errprt.$(OBJEXT):            modules.$(OBJEXT)
etom1.$(OBJEXT):             modules.$(OBJEXT)
etom2.$(OBJEXT):             modules.$(OBJEXT)
euslv.$(OBJEXT):             modules.$(OBJEXT)
formr.$(OBJEXT):             modules.$(OBJEXT)
gcgris.$(OBJEXT):            modules.$(OBJEXT) print_control_mod.$(OBJEXT)
hdf_f.$(OBJEXT):             modules.$(OBJEXT)	
hunt.$(OBJEXT):              modules.$(OBJEXT)
incidx.$(OBJEXT):            modules.$(OBJEXT)
indx_rewi.$(OBJEXT):         modules.$(OBJEXT)
indx_rewi_bc.$(OBJEXT):      modules.$(OBJEXT)
init1.$(OBJEXT):             modules.$(OBJEXT)
init2_1.$(OBJEXT):           modules.$(OBJEXT)
init2_2.$(OBJEXT):           modules.$(OBJEXT)
init2_3.$(OBJEXT):           modules.$(OBJEXT)
init2_post_ss.$(OBJEXT):     modules.$(OBJEXT) print_control_mod.$(OBJEXT)
init3.$(OBJEXT):             modules.$(OBJEXT) print_control_mod.$(OBJEXT)
interpolate_mod.$(OBJEXT):   modules.$(OBJEXT)
ldchar.$(OBJEXT):            modules.$(OBJEXT)
ldchar_bc.$(OBJEXT):         modules.$(OBJEXT)
ldci.$(OBJEXT):              modules.$(OBJEXT)
ldcir.$(OBJEXT):             modules.$(OBJEXT)
ldind.$(OBJEXT):             modules.$(OBJEXT)
ldipen.$(OBJEXT):            modules.$(OBJEXT)
ldmar1.$(OBJEXT):            modules.$(OBJEXT)
lsolv.$(OBJEXT):             modules.$(OBJEXT)
mtoijk.$(OBJEXT):            modules.$(OBJEXT)
nintrp.$(OBJEXT):            modules.$(OBJEXT)
openf.$(OBJEXT):             modules.$(OBJEXT) mpimod.$(OBJEXT)
phast.$(OBJEXT):             modules.$(OBJEXT) mpimod.$(OBJEXT)
phast_root.$(OBJEXT):        modules.$(OBJEXT) print_control_mod.$(OBJEXT)
phast_slave.$(OBJEXT):       modules.$(OBJEXT) mpimod.$(OBJEXT) print_control_mod.$(OBJEXT)
prchar.$(OBJEXT):            modules.$(OBJEXT)
prntar.$(OBJEXT):            modules.$(OBJEXT)
rbord.$(OBJEXT):             modules.$(OBJEXT)
read1.$(OBJEXT):             modules.$(OBJEXT)
read2.$(OBJEXT):             modules.$(OBJEXT) rewi_mod.$(OBJEXT) ifrd.inc
read3.$(OBJEXT):             modules.$(OBJEXT) print_control_mod.$(OBJEXT) rewi_mod.$(OBJEXT) ifrd.inc
reordr.$(OBJEXT):            modules.$(OBJEXT)
rewi_mod.$(OBJEXT):          modules.$(OBJEXT) interpolate_mod.$(OBJEXT)
rfact.$(OBJEXT):             modules.$(OBJEXT)
rfactm.$(OBJEXT):            modules.$(OBJEXT)
rhsn.$(OBJEXT):              modules.$(OBJEXT)
rhsn_ss_flow.$(OBJEXT):      modules.$(OBJEXT)
sbcflo.$(OBJEXT):            modules.$(OBJEXT)
scale_jds.$(OBJEXT):         modules.$(OBJEXT)
simulate_ss_flow.$(OBJEXT):  modules.$(OBJEXT)
sumcal1.$(OBJEXT):           modules.$(OBJEXT)
sumcal2.$(OBJEXT):           modules.$(OBJEXT)
sumcal_ss_flow.$(OBJEXT):    modules.$(OBJEXT)
terminate_phast.$(OBJEXT):   modules.$(OBJEXT) mpimod.$(OBJEXT)
tfrds.$(OBJEXT):             modules.$(OBJEXT)
timstp.$(OBJEXT):            modules.$(OBJEXT) print_control_mod.$(OBJEXT)
timstp_ss_flow.$(OBJEXT):    modules.$(OBJEXT) print_control_mod.$(OBJEXT)
update_print_flags.$(OBJEXT):modules.$(OBJEXT) print_control_mod.$(OBJEXT)
usolv.$(OBJEXT):             modules.$(OBJEXT)
viscos.$(OBJEXT):            modules.$(OBJEXT)
wbbal.$(OBJEXT):             modules.$(OBJEXT)
wbcflo.$(OBJEXT):            modules.$(OBJEXT)
wellsc.$(OBJEXT):            modules.$(OBJEXT)
wellsc_ss_flow.$(OBJEXT):    modules.$(OBJEXT)
wellsr.$(OBJEXT):            modules.$(OBJEXT)
wellsr_ss_flow.$(OBJEXT):    modules.$(OBJEXT)
welris.$(OBJEXT):            modules.$(OBJEXT)
wfdydz.$(OBJEXT):            modules.$(OBJEXT)
write1.$(OBJEXT):            modules.$(OBJEXT)
write2_1.$(OBJEXT):          modules.$(OBJEXT) ld_seg_mod.$(OBJEXT) ifwr.inc
write2_2.$(OBJEXT):          modules.$(OBJEXT) ifwr.inc
write3.$(OBJEXT):            modules.$(OBJEXT) ifwr.inc
write3_ss_flow.$(OBJEXT):    modules.$(OBJEXT) ifwr.inc
write4.$(OBJEXT):            modules.$(OBJEXT) print_control_mod.$(OBJEXT) ifwr.inc
write5.$(OBJEXT):            modules.$(OBJEXT) print_control_mod.$(OBJEXT) ifwr.inc
write5_ss_flow.$(OBJEXT):    modules.$(OBJEXT) print_control_mod.$(OBJEXT) ifwr.inc
write6.$(OBJEXT):            modules.$(OBJEXT) print_control_mod.$(OBJEXT) ifwr.inc
zone_flow.$(OBJEXT):         modules.$(OBJEXT)
zone_flow_ss.$(OBJEXT):      modules.$(OBJEXT)

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
