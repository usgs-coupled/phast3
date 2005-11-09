# Makefile for PHAST
#
# Generates object files and executables for 8 versions of PHAST
#	    Absoft/Lahey compiler
#           Serial/MPI version
#           Optimize/Debug
#
# Serial verisons:   serial_absoft serial_absoft_debug serial_lahey serial_lahey_debug 
# Parallel versions: mpi_absoft mpi_absoft_debug mpi_lahey mpi_lahey_debug 
#
# Makefile sets CFG variable, cd's to appropriate directory, runs Makefile recursively
# Recursive make sets appropriate compiler, objects, options, libraries, and compiles PHAST
#

PROGRAM = phast

all: serial_absoft serial_absoft_debug mpi_absoft mpi_absoft_debug serial_lahey serial_lahey_debug mpi_lahey mpi_lahey_debug 

SERIAL_ABSOFT_DIR       = serial_absoft
SERIAL_ABSOFT_DEBUG_DIR = serial_absoft_debug
SERIAL_LAHEY_DIR        = serial_lahey
SERIAL_LAHEY_DEBUG_DIR  = serial_lahey_debug
MPI_LAHEY_DIR           = mpi_lahey
MPI_LAHEY_DEBUG_DIR     = mpi_lahey_debug
MPI_ABSOFT_DIR          = mpi_absoft
MPI_ABSOFT_DEBUG_DIR    = mpi_absoft_debug
MAKEFILE                = Makefile

#########################
#### Serial Versions ####
#########################
.PHONY : serial_absoft
serial_absoft:
	mkdir -p $(SERIAL_ABSOFT_DIR) 
	cd $(SERIAL_ABSOFT_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_ABSOFT $(PROGRAM)

.PHONY : serial_absoft_debug
serial_absoft_debug:
	mkdir -p $(SERIAL_ABSOFT_DEBUG_DIR) 
	cd $(SERIAL_ABSOFT_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_ABSOFT_DEBUG $(PROGRAM)

.PHONY : serial_lahey
serial_lahey:
	mkdir -p $(SERIAL_LAHEY_DIR)
	cd $(SERIAL_LAHEY_DIR);	$(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_LAHEY $(PROGRAM)

.PHONY : serial_lahey_debug
serial_lahey_debug:
	mkdir -p $(SERIAL_LAHEY_DEBUG_DIR);
	cd $(SERIAL_LAHEY_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_LAHEY_DEBUG $(PROGRAM)

#########################
##### MPI Versions ######
#########################

.PHONY : mpi_lahey
mpi_lahey:
	mkdir -p $(MPI_LAHEY_DIR) 
	cd $(MPI_LAHEY_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_LAHEY $(PROGRAM)

.PHONY : mpi_lahey_debug
mpi_lahey_debug:
	mkdir -p $(MPI_LAHEY_DEBUG_DIR) 
	cd $(MPI_LAHEY_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_LAHEY_DEBUG $(PROGRAM)

.PHONY : mpi_absoft
mpi_absoft:
	mkdir -p $(MPI_ABSOFT_DIR)
	cd $(MPI_ABSOFT_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_ABSOFT $(PROGRAM)

.PHONY : mpi_absoft_debug
mpi_absoft_debug:
	mkdir -p $(MPI_ABSOFT_DEBUG_DIR);
	cd $(MPI_ABSOFT_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_ABSOFT_DEBUG $(PROGRAM)

# Recursive make begins here
#
# =============================================================================
# Significant suffixes [assuming Fortran 90 (.f90)  source code]:
# Significant suffixes [assuming Fortran 90 (.F90)  source code, needs to be preprocessed ]:
# =============================================================================

SRC     = ../phreeqc
.SUFFIXES : .o .f .F90 .f90 .c 

# compilers
FLAHEY=/usr/local/lf9562/bin/lf95
LIBLAHEY=-L/usr/lib 
#FLAHEY=/z/niwot/usr/local/lf9562/bin/lf95
#LIBLAHEY=-L/z/niwot/usr/lib -L/z/niwot/usr/local/lf9562/lib 

FABSOFT=/z/parkplace/usr/absoft/bin/f90
NLSABSOFT=/z/parkplace/usr/absoft/lib/nls/cf90
LIBABSOFT=-L/z/parkplace/usr/absoft/lib 

# -----------------------------------------------------------------------------
.f90.o :
	${FC} -c ${FFLAGS} $<
.F90.o :
	${FC} -c ${FFLAGS} $< -o $@
.c.o :
	${CC} ${CFLAGS} -c -o $@ $<

# -----------------------------------------------------------------------------
#hdf options
#HDF5_ROOT=$(HOME)/../../usr
#HDF5_ROOT=/z/lobo/usr
#HDF5_ROOT=/z/parkplace/home/dlparkpackages/hdf5-1.4.5-post2
HDF5_ROOT=/z/parkplace/home/dlpark
HDF5_INCLUDES=-I$(HDF5_ROOT)/include
#HDF5_INCLUDES=-I$(HDF5_ROOT)/src
HDF5_LIBS=${HDF5_ROOT}/lib/libhdf5.a -lz -lpthread  

# -----------------------------------------------------------------------------
# #define compile options
DEFINE_HDF=-DHDF5_CREATE
DEFINE_MPI=-DUSE_MPI
DEFINE_MERGE=-DMERGE_FILES

# -----------------------------------------------------------------------------
# #define gmp for inverse modeling
# comment the following lines to remove multiprecision option
DINVERSE_CL1MP=TRUE
CL1MP_LIB=/z/parkplace/usr/lib/libgmp.a 
CL1MP_OBJS=cl1mp.o

# -----------------------------------------------------------------------------
#efence for debugging
EFENCE_LIB=-L$(HOME)/packages/efence

# -----------------------------------------------------------------------------
# 8 Versions
# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_ABSOFT)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG 
  VPATH        = ..:../phreeqc
  FC           = $(FABSOFT)
  NLSPATH      = $(NLSABSOFT)
  FDEBUG       = -O -en  # -C
  FMISC        = -YEXT_NAMES=LCS -s -B108 -YCFRL=1 -trap=DIVBYZERO,OVERFLOW
  FFLAGS       = $(FDEBUG) $(FMISC) $(DEFINES)
  CC           = gcc
  CFLAGS       = -Wall -pedantic -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm ${CL1MP_LIB} ${HDF5_LIBS} $(LIBABSOFT)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_ABSOFT_DEBUG)
  DEFINES      = $(DEFINE_HDF)
  VPATH        = ..:../phreeqc
  FC           = $(FABSOFT)
  NLSPATH      = $(NLSABSOFT)
  FDEBUG       = -g -en # -Rb -Rc -Rp -Rs # range checking
  FMISC        = -YEXT_NAMES=LCS -s -B108 -YCFRL=1 -trap=DIVBYZERO,OVERFLOW
  FFLAGS       = $(FDEBUG) $(FMISC) $(DEFINES)
  CC           = gcc
  CFLAGS       = -Wall -g $(DEFINES) $(HDF5_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm ${CL1MP_LIB} ${HDF5_LIBS} $(LIBABSOFT) # ${EFENCE_LIB} -lefence
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_ABSOFT)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG  
  VPATH        = ..:../phreeqc
  LAMHF77      = $(FABSOFT)
  export LAMHF77
  NLSPATH      = $(NLSABSOFT)
  FC           = mpif77
  FDEBUG       = -O -en  # -C
  FMISC        = -YEXT_NAMES=LCS -s -B108 -YCFRL=1 -trap=DIVBYZERO,OVERFLOW
  FFLAGS       = $(FDEBUG) $(FMISC) $(DEFINES)
  CC           = mpicc
  CFLAGS       = -Wall -pedantic -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm ${CL1MP_LIB} ${HDF5_LIBS} $(LIBABSOFT)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_ABSOFT_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE)
  VPATH        = ..:../phreeqc
  LAMHF77      = $(FABSOFT)
  export LAMHF77
  NLSPATH      = $(NLSABSOFT)
  FC           = mpif77
  FDEBUG       = -g -en # -Rb -Rc -Rp -Rs # range checking
  FMISC        = -YEXT_NAMES=LCS -s -B108 -YCFRL=1 -trap=DIVBYZERO,OVERFLOW
  FFLAGS       = $(FDEBUG) $(FMISC) $(DEFINES)
  CC           = mpicc
  CFLAGS       = -Wall -pedantic -ansi -g $(DEFINES) $(HDF5_INCLUDES)# -Wconversion 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm ${CL1MP_LIB} ${HDF5_LIBS} $(LIBABSOFT) # ${EFENCE_LIB} -lefence
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_LAHEY)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG
  VPATH        = ..:../phreeqc
  LAMHF77      = $(FLAHEY)
  export LAMHF77
  FC           = mpif77
  FFLAGS       = -O $(DEFINES)
  CC           = mpicc
  CFLAGS       = -Wall -pedantic -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
#  LD_FLAGS     = -static-flib  -lm ${HDF5_LIBS} 
  LD_FLAGS     = $(LIBLAHEY) -lm ${CL1MP_LIB} ${HDF5_LIBS} 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_LAHEY_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE)
  VPATH        = ..:../phreeqc
  LAMHF77      = $(FLAHEY)
  export LAMHF77
  FC           = mpif77
  FFLAGS       = -g --chkglobal --warn --info $(DEFINES)
  CC           = mpicc
  CFLAGS       = -Wall -pedantic -g $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
#  LD_FLAGS     = -static-flib -lm ${HDF5_LIBS} 
  LD_FLAGS     = -static $(LIBLAHEY) -lm ${CL1MP_LIB} ${HDF5_LIBS} 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_LAHEY)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG
  VPATH        = ..:../phreeqc
  FC           = $(FLAHEY)
  FFLAGS       = -O $(DEFINES)
  CC           = gcc
  CFLAGS       = -Wall -pedantic $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(HDF_OBJS) $(CL1MP_OBJS)
#  LD_FLAGS     = -static-flib -lm ${HDF5_LIBS} 
  LD_FLAGS     = -static $(LIBLAHEY) -lm ${CL1MP_LIB} ${HDF5_LIBS} 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_LAHEY_DEBUG)
  DEFINES      = $(DEFINE_HDF) 
  VPATH        = ..:../phreeqc
  FC           = $(FLAHEY)
  FFLAGS       = -g --f95 --chkglobal --warn --info $(DEFINES)
  CC           = gcc
  CFLAGS       = -Wall -pedantic -g $(DEFINES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(HDF_OBJS) $(CL1MP_OBJS)
#  LD_FLAGS     = -static-flib -lm ${HDF5_LIBS} 
  LD_FLAGS     = -static $(LIBLAHEY) -lm ${CL1MP_LIB} ${HDF5_LIBS} 
endif

# -----------------------------------------------------------------------------
# (d) Create expected object file list, with .o extension:     [TARGETS OF PRE-
#     REQUISITE (.f90,.f) SOURCE FILES]
#

COMMON_COBJS =  advection.o basic.o basicsubs.o cl1.o input.o integrate.o inverse.o \
	        isotopes.o kinetics.o mainsubs.o output.o model.o p2clib.o parse.o \
		phqalloc.o prep.o print.o read.o readtr.o spread.o step.o structures.o \
		tally.o tidy.o transport.o utilities.o \
		cvdense.o cvode.o dense.o nvector.o nvector_serial.o smalldense.o sundialsmath.o \
		hst.o hstsubs.o mix.o phast_files.o pitzer.o pitzer_structures.o dw.o

COMMON_FOBJS =	abmult.o aplbce.o aplbce_ss_flow.o aplbci.o armult.o asembl.o\
		asmslc.o asmslp.o asmslp_ss_flow.o bsode.o calcc.o calc_velocity.o clog.o closef.o\
		coeff.o coeff_ss_flow.o crsdsp.o d4ord.o d4zord.o dbmult.o dump.o\
		efact.o ehoftp.o el1slv.o elslv.o error1.o error2.o error3.o error4.o\
		errprt.o etom1.o etom2.o euslv.o formr.o gcgris.o hunt.o incidx.o\
		indx_rewi_bc.o indx_rewi.o init1.o init2_1.o init2_2.o init2_3.o\
		init2_post_ss.o init3.o interp.o irewi.o ldchar.o ldci.o ldcir.o\
		ldind.o ldipen.o ldmar1.o load_indx_bc.o lsolv.o modules.o mtoijk.o\
		nintrp.o openf.o phast.o phast_root.o \
		prchar.o print_control_mod.o prntar.o rbord.o\
		read1.o read2.o read3.o reordr.o rewi3.o rewi.o rfact.o rfactm.o\
		rhsn.o rhsn_ss_flow.o sbcflo.o scale_jds.o simulate_ss_flow.o stonb.o sumcal1.o sumcal2.o \
		sumcal_ss_flow.o terminate_phast.o tfrds.o timstp.o timstp_ss_flow.o\
		update_print_flags.o\
		usolv.o viscos.o vpsv.o wbbal.o wbcflo.o wellsc.o wellsc_ss_flow.o\
		wellsr.o wellsr_ss_flow.o welris.o wfdydz.o write1.o write2_1.o write2_2.o write3.o\
		write3_ss_flow.o write4.o write5.o write5_ss_flow.o write6.o 

HDF_OBJS     =  hdf.o hdf_f.o

MERGE_OBJS   =	merge.o

MPI_OBJS     =	mpimod.o phast_slave.o slavesubs.o

# -----------------------------------------------------------------------------
#  Assign dependents to target on dependency line & link options on command 
#  line. Command line is initiated with a tab. ($@ is an internal macro for 
#  the current target.) 

${PROGRAM} : ${OBJECT_FILES}
	${FC} -o $@ ${OBJECT_FILES} ${LD_LIB1} ${LD_FLAGS} 
	@echo; echo Done making for phast
# -----------------------------------------------------------------------------
#  SPECIAL TARGET for compiling files containing modules so that
#  module_name.mod and module_name.o files are created or
#  updated before all other source code object files. 

modules.o : modules.f90 
	${FC} -c ${FFLAGS} $<
print_control_mod.o : print_control_mod.f90
	${FC} -c ${FFLAGS} $<

# -----------------------------------------------------------------------------
# Module dependency list
# -----------------------------------------------------------------------------
#
#  PHAST Fortran files
#
phast.o:	           modules.o	mpimod.o
abmult.o:		   modules.o
aplbce.o:		   modules.o
aplbce_ss_flow.o:	   modules.o
aplbci.o:		   modules.o
armult.o:		   modules.o
asembl.o:		   modules.o
asmslc.o:		   modules.o
asmslp.o:		   modules.o
asmslp_ss_flow.o:	   modules.o
bsode.o:		   modules.o
calcc.o:	   	   modules.o
calc_velocity.o:	   modules.o
clog.o:			   modules.o
closef.o:		   modules.o	mpimod.o
coeff.o:		   modules.o
coeff_ss_flow.o:	   modules.o
crsdsp.o:		   modules.o
d4ord.o:		   modules.o
d4zord.o:		   modules.o
dbmult.o:		   modules.o
dump.o:			   modules.o
efact.o:		   modules.o
ehoftp.o:		   modules.o
el1slv.o:		   modules.o
elslv.o:		   modules.o
error1.o:		   modules.o
error2.o:		   modules.o
error3.o:		   modules.o
error4.o:		   modules.o	ifwr.inc
errprt.o:		   modules.o
etom1.o:		   modules.o
etom2.o:		   modules.o
euslv.o:		   modules.o
formr.o:		   modules.o
gcgris.o:		   modules.o	print_control_mod.o
hdf_f.o:		   modules.o	print_control_mod.o
hunt.o:			   modules.o
incidx.o:		   modules.o
indx_rewi.o:		   modules.o
indx_rewi_bc.o:		   modules.o
init1.o:		   modules.o
init2_1.o:		   modules.o
init2_2.o:		   modules.o
init2_3.o:		   modules.o
init2_post_ss.o:	   modules.o
init3.o:		   modules.o
interp.o:		   modules.o
irewi.o:		   modules.o
ldchar.o:		   modules.o
ldci.o:			   modules.o
ldcir.o:		   modules.o
ldind.o:		   modules.o
ldipen.o:		   modules.o
ldmar1.o:		   modules.o
load_indx_bc.o:		   modules.o
lsolv.o:		   modules.o
nintrp.o:		   modules.o
openf.o:		   modules.o	mpimod.o
phast_root.o:	           modules.o    mpimod.o
phast_slave.o:		   modules.o    mpimod.o
prchar.o:		   modules.o
prntar.o:		   modules.o
rbord.o:		   modules.o
read1.o:		   modules.o
read2.o:		   modules.o 	ifrd.inc
read3.o:		   modules.o
reordr.o:		   modules.o
rewi.o:			   modules.o
rewi3.o:		   modules.o
rfact.o:		   modules.o
rfactm.o:		   modules.o
rhsn.o:			   modules.o
rhsn_ss_flow.o:		   modules.o
sbcflo.o:		   modules.o
scale_jds.o:     	   modules.o
simulate_ss_flow.o:	   modules.o
sumcal1.o:		   modules.o
sumcal2.o:		   modules.o
sumcal_ss_flow.o:	   modules.o
terminate_phast.o:	   modules.o	mpimod.o
tfrds.o:		   modules.o
timstp.o:		   modules.o	print_control_mod.o
timstp_ss_flow.o:	   modules.o	print_control_mod.o
update_print_flags.o:	   modules.o	
usolv.o:		   modules.o
viscos.o:		   modules.o
wbbal.o:		   modules.o
wbcflo.o:		   modules.o
wellsc.o:		   modules.o
wellsc_ss_flow.o:	   modules.o
wellsr.o:		   modules.o
wellsr_ss_flow.o:	   modules.o
welris.o:		   modules.o
wfdydz.o:		   modules.o
write1.o:		   modules.o
write2_1.o:		   modules.o	ifwr.inc
write2_2.o:		   modules.o	ifwr.inc
write3.o:		   modules.o	ifwr.inc
write3_ss_flow.o:	   modules.o	ifwr.inc
write4.o:		   modules.o	ifwr.inc	print_control_mod.o
write5.o:		   modules.o	ifwr.inc	print_control_mod.o
write5_ss_flow.o:	   modules.o	ifwr.inc	print_control_mod.o
write6.o:		   modules.o	ifwr.inc	print_control_mod.o
#
#  PHREEQC files
#
advection.o: $(SRC)/advection.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
basic.o: $(SRC)/basic.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h $(SRC)/p2c.h
basicsubs.o: $(SRC)/basicsubs.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
cl1.o: $(SRC)/cl1.c $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqtype.h
cvdense.o: $(SRC)/cvdense.c $(SRC)/cvdense.h $(SRC)/cvode.h $(SRC)/sundialstypes.h $(SRC)/phrqtype.h $(SRC)/nvector.h $(SRC)/dense.h $(SRC)/smalldense.h $(SRC)/sundialsmath.h $(SRC)/output.h $(SRC)/phqalloc.h
cvode.o: $(SRC)/cvode.c $(SRC)/cvode.h $(SRC)/sundialstypes.h $(SRC)/phrqtype.h $(SRC)/nvector.h $(SRC)/sundialsmath.h $(SRC)/output.h $(SRC)/kinetics.h $(SRC)/phqalloc.h
dense.o: $(SRC)/dense.c $(SRC)/sundialstypes.h $(SRC)/phrqtype.h $(SRC)/sundialsmath.h $(SRC)/dense.h $(SRC)/smalldense.h $(SRC)/output.h $(SRC)/phqalloc.h
dw.o: $(SRC)/dw.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/input.h $(SRC)/output.h $(SRC)/phrqproto.h $(SRC)/phqalloc.h pitzer.h
input.o: $(SRC)/input.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/input.h $(SRC)/output.h $(SRC)/phrqproto.h $(SRC)/phqalloc.h
integrate.o: $(SRC)/integrate.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
inverse.o: $(SRC)/inverse.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
isotopes.o: $(SRC)/isotopes.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
kinetics.o: $(SRC)/kinetics.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h $(SRC)/sundialstypes.h $(SRC)/cvode.h $(SRC)/nvector.h $(SRC)/cvdense.h $(SRC)/dense.h $(SRC)/smalldense.h $(SRC)/nvector_serial.h $(SRC)/kinetics.h
mainsubs.o: $(SRC)/mainsubs.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h $(SRC)/input.h
model.o: $(SRC)/model.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
nvector.o: $(SRC)/nvector.c $(SRC)/nvector.h $(SRC)/sundialstypes.h $(SRC)/phrqtype.h $(SRC)/output.h
nvector_serial.o: $(SRC)/nvector_serial.c $(SRC)/nvector_serial.h $(SRC)/nvector.h $(SRC)/sundialstypes.h $(SRC)/phrqtype.h $(SRC)/sundialsmath.h $(SRC)/output.h $(SRC)/phqalloc.h
output.o: $(SRC)/output.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/output.h $(SRC)/phrqproto.h $(SRC)/phqalloc.h
p2clib.o: $(SRC)/p2clib.c $(SRC)/p2c.h $(SRC)/output.h
parse.o: $(SRC)/parse.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
pitzer.o: $(SRC)/pitzer.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h $(SRC)/pitzer.h
pitzer_structures.o: $(SRC)/pitzer_structures.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h $(SRC)/pitzer.h
phqalloc.o: $(SRC)/phqalloc.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/output.h
prep.o: $(SRC)/prep.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
print.o: $(SRC)/print.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
read.o: $(SRC)/read.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
readtr.o: $(SRC)/readtr.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
smalldense.o: $(SRC)/smalldense.c $(SRC)/smalldense.h $(SRC)/sundialstypes.h $(SRC)/phrqtype.h $(SRC)/sundialsmath.h $(SRC)/output.h $(SRC)/phqalloc.h
spread.o: $(SRC)/spread.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
step.o: $(SRC)/step.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
structures.o: $(SRC)/structures.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
sundialsmath.o: $(SRC)/sundialsmath.c $(SRC)/sundialsmath.h $(SRC)/sundialstypes.h $(SRC)/phrqtype.h $(SRC)/output.h
tally.o: $(SRC)/tally.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
tidy.o: $(SRC)/tidy.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
transport.o: $(SRC)/transport.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
utilities.o: $(SRC)/utilities.c $(SRC)/global.h $(SRC)/phrqtype.h $(SRC)/phqalloc.h $(SRC)/output.h $(SRC)/phrqproto.h
#
#  Glue files
#
hdf.o:hdf.c  global.h hst.h phqalloc.h output.h phastproto.h
hst.o: hst.c  global.h hst.h phqalloc.h output.h phastproto.h
hstsubs.o: hstsubs.c  global.h hst.h phqalloc.h output.h phastproto.h
merge.o: merge.c global.h phqalloc.h hst.h output.h phastproto.h
mix.o: mix.c global.h hst.h phqalloc.h output.h phastproto.h
phast_files.o: phast_files.c global.h phqalloc.h output.h phrqproto.h input.h
slavesubs.o: slavesubs.c global.h hst.h phqalloc.h output.h phastproto.h

# -----------------------------------------------------------------------------

clean:
	rm -rf serial_absoft serial_absoft_debug mpi_absoft mpi_absoft_debug serial_lahey serial_lahey_debug mpi_lahey mpi_lahey_debug 	

# =============================================================================
# End of makefile.
# =============================================================================
