####MAKE = /usr/bin/make

all: mpi_lahey mpi_lahey_debug mpi_absoft mpi_absoft_debug serial_lahey serial_lahey_debug serial_absoft serial_absoft_debug

#########################
##### MPI Versions ######
#########################
MPI_LAHEY_DIR        = mpi_lahey
MPI_LAHEY_DEBUG_DIR  = mpi_lahey_debug
MPI_ABSOFT_DIR       = mpi_absoft
MPI_ABSOFT_DEBUG_DIR = mpi_absoft_debug

.PHONY : mpi_lahey
mpi_lahey:
	mkdir -p $(MPI_LAHEY_DIR) && cd $(MPI_LAHEY_DIR) &&\
	$(MAKE) -r -f ../Makefile.David CFG=MPI_LAHEY

.PHONY : mpi_lahey_debug
mpi_lahey_debug:
	mkdir -p $(MPI_LAHEY_DEBUG_DIR) && cd $(MPI_LAHEY_DEBUG_DIR) &&\
	$(MAKE) -r -f ../Makefile.David CFG=MPI_LAHEY_DEBUG

.PHONY : mpi_absoft
mpi_absoft:
	mkdir -p $(MPI_ABSOFT_DIR) && cd $(MPI_ABSOFT_DIR) &&\
	$(MAKE) -r -f ../Makefile.David CFG=MPI_ABSOFT

.PHONY : mpi_absoft_debug
mpi_absoft_debug:
	mkdir -p $(MPI_ABSOFT_DEBUG_DIR) && cd $(MPI_ABSOFT_DEBUG_DIR) &&\
	$(MAKE) -r -f ../Makefile.David CFG=MPI_ABSOFT_DEBUG

#########################
#### Serial Versions ####
#########################
SERIAL_ABSOFT_DIR    = serial_absoft
SERIAL_ABSOFT_DEBUG_DIR    = serial_absoft_debug
SERIAL_LAHEY_DIR     = serial_lahey
SERIAL_LAHEY_DEBUG_DIR  = serial_lahey_debug
SERIAL_SUN_DIR       = serial_sun
SERIAL_SUN_DEBUG_DIR  = serial_sun_debug

.PHONY : serial_absoft
serial_absoft:
	mkdir -p $(SERIAL_ABSOFT_DIR) && cd $(SERIAL_ABSOFT_DIR) &&\
	$(MAKE) -r -f ../Makefile.David CFG=SERIAL_ABSOFT

.PHONY : serial_absoft_debug
serial_absoft_debug:
	mkdir -p $(SERIAL_ABSOFT_DEBUG_DIR) && cd $(SERIAL_ABSOFT_DEBUG_DIR) &&\
	$(MAKE) -r -f ../Makefile.David CFG=SERIAL_ABSOFT_DEBUG

.PHONY : serial_lahey
serial_lahey:
	mkdir -p $(SERIAL_LAHEY_DIR) && cd $(SERIAL_LAHEY_DIR) &&\
	$(MAKE) -r -f ../Makefile.David CFG=SERIAL_LAHEY

.PHONY : serial_lahey_debug
serial_lahey_debug:
	mkdir -p $(SERIAL_LAHEY_DEBUG_DIR) && cd $(SERIAL_LAHEY_DEBUG_DIR) &&\
	$(MAKE) -r -f ../Makefile.David CFG=SERIAL_LAHEY_DEBUG

.PHONY : serial_sun
serial_sun:
	mkdir -p $(SERIAL_SUN_DIR) && cd $(SERIAL_SUN_DIR) &&\
	$(MAKE) -r -j 2 -f ../Makefile.David CFG=SERIAL_SUN

#	rsh u450rcolkr "cd ~dlpark/parkplace/phast/srcphast/$(SERIAL_SUN_DIR); $(MAKE) -r -j 2 -f ../Makefile.David CFG=SERIAL_SUN"

.PHONY : serial_sun_debug
serial_sun_debug:
	mkdir -p $(SERIAL_SUN_DEBUG_DIR) && cd $(SERIAL_SUN_DEBUG_DIR) &&\
	rsh sunarcolkr "cd ~dlpark/parkplace/phast/srcphast/$(SERIAL_SUN_DEBUG_DIR); $(MAKE) -r -j 2 -f ../Makefile.David CFG=SERIAL_SUN_DEBUG"

PHREEQC_FILES = advection.c basic.c basicsubs.c cl1.c cvdense.c cvdense.h cvode.c cvode.h dense.c dense.h global.h input.c input.h integrate.c inverse.c isotopes.c kinetics.c kinetics.h mainsubs.c model.c nvector.c nvector.h nvector_serial.c nvector_serial.h output.c output.h p2c.h p2clib.c parse.c phqalloc.c phqalloc.h phrqproto.h phrqtype.h prep.c print.c read.c readtr.c smalldense.c smalldense.h spread.c step.c structures.c sundialsmath.c sundialsmath.h sundialstypes.h tally.c tidy.c transport.c utilities.c

GLUE_FILES = hdf.c hst.c hst.h hstsubs.c merge.c mix.c phast_files.c phast_files.h phastproto.h clog.f90 hdf_f.f90

HST_FILES = abmult.f90 aplbce.f90 aplbce_ss_flow.f90 aplbci.f90 armult.f90 asembl.f90 asmslc.f90 asmslp.f90 asmslp_ss_flow.f90 bsode.f90 calcc.f90 calc_velocity.f90 closef.F90 coeff.f90 coeff_ss_flow.f90 crsdsp.f90 d4ord.f90 d4zord.f90 dbmult.f90 dump.f90 efact.f90 ehoftp.f90 el1slv.f90 elslv.f90 error1.f90 error2.f90 error3.f90 error4.f90 errprt.f90 etom1.f90 etom2.f90 euslv.f90 formr.f90 gcgris.f90 hunt.f90 incidx.f90 indx_rewi_bc.f90 indx_rewi.f90 init1.f90 init2_1.f90 init2_2.f90 init2_3.f90 init2_post_ss.f90 init3.f90 interp.f90 irewi.f90 ldchar.f90 ldci.f90 ldcir.f90 ldind.f90 ldipen.f90 ldmar1.f90 load_indx_bc.f90 lsolv.f90 modules.f90 mpimod.F90 mtoijk.f90 nintrp.f90 openf.F90 phast.F90 prchar.f90 print_control_mod.f90 prntar.f90 rbord.f90 read1.f90 read2.f90 read3.f90 reordr.f90 rewi3.f90 rewi.f90 rfact.f90 rfactm.f90 rhsn.f90 rhsn_ss_flow.f90 sbcflo.f90 simulate_ss_flow.f90 stonb.f90 sumcal1.f90 sumcal2.f90 sumcal_ss_flow.f90 terminate_phast.F90 tfrds.f90 timstp.f90 timstp_ss_flow.f90 update_print_flags.f90 usolv.f90 viscos.f90 vpsv.f90 wbbal.f90 wbcflo.f90 wellsc.f90 wellsc_ss_flow.f90 wellsr.f90 wellsr_ss_flow.f90 welris.f90 wfdydz.f90 write1.f90 write2_1.f90 write2_2.f90 write3.f90 write3_ss_flow.f90 write4.f90 write5.f90 write5_ss_flow.f90 write6.f90
