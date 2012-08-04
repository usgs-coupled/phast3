# Makefile for PHAST
#
# Generates object files and executables for 8 versions of PHAST
#	    Gfortran/Lahey compiler
#           Serial/MPI version
#           Optimize/Debug
#
# Makefile sets CFG variable, cd's to appropriate directory, runs Makefile recursively
# Recursive make sets appropriate compiler, objects, options, libraries, and compiles PHAST
#

PROGRAM = phast

all: gfortran lahey # g95 

# serial_lahey serial_lahey_debug lam_lahey lam_lahey_debug 

SERIAL_ABSOFT_DIR       = serial_absoft
absoft: serial_absoft 

SERIAL_LAHEY_DIR        = serial_lahey
SERIAL_LAHEY_DEBUG_DIR  = serial_lahey_debug
LAM_LAHEY_DIR           = lam_lahey
LAM_LAHEY_DEBUG_DIR     = lam_lahey_debug

SERIAL_G95_DIR          = serial_g95
SERIAL_G95_DEBUG_DIR    = serial_g95_debug
LAM_G95_DIR             = lam_g95
LAM_G95_DEBUG_DIR       = lam_g95_debug
g95: serial_g95 serial_g95_debug lam_g95 lam_g95_debug

SERIAL_GFORTRAN_DIR          = serial_gfortran
SERIAL_GFORTRAN_DEBUG_DIR    = serial_gfortran_debug
LAM_GFORTRAN_DIR             = lam_gfortran
LAM_GFORTRAN_DEBUG_DIR       = lam_gfortran_debug
OPENMPI_GFORTRAN_DIR         = openmpi_gfortran
OPENMPI_GFORTRAN_DEBUG_DIR   = openmpi_gfortran_debug

SERIAL_GFORTRAN_64_DIR        = serial_gfortran_64
SERIAL_GFORTRAN_64_DEBUG_DIR  = serial_gfortran_64_debug
OPENMPI_GFORTRAN_64_DIR       = openmpi_gfortran_64
OPENMPI_GFORTRAN_64_DEBUG_DIR = openmpi_gfortran_64_debug
OPENMPI_1_4_2_GFORTRAN_64_DIR = openmpi_1_4_2_gfortran_64
OPENMPI_1_4_2_INTEL_64_STATIC_DIR = openmpi_1_4_2_intel_64_static

SERIAL_INTEL_DIR        = serial_intel
SERIAL_INTEL_DEBUG_DIR  = serial_intel_debug
SERIAL_INTEL_64_DIR     = serial_intel_64
SERIAL_INTEL_64_DEBUG_DIR   = serial_intel_64_debug
OPENMPI_INTEL_DIR           = openmpi_intel
OPENMPI_INTEL_DEBUG_DIR     = openmpi_intel_debug
OPENMPI_INTEL_64_DIR           = openmpi_intel_64
OPENMPI_INTEL_64_DEBUG_DIR     = openmpi_intel_64_debug
LAM_INTEL_DIR                  = lam_intel
LAM_INTEL_DEBUG_DIR            = lam_intel_debug

MPICH_GFORTRAN_DIR           = mpich_gfortran
mpich: mpich_gfortran

parkplace: gfortran lahey
gfortran: serial_gfortran serial_gfortran_debug lam_gfortran lam_gfortran_debug 
lahey: serial_lahey serial_lahey_debug lam_lahey lam_lahey_debug

#grundvand: intel openmpi
intel: serial_intel serial_intel_debug openmpi_intel openmpi_intel_debug
openmpi: openmpi_gfortran openmpi_gfortran_debug

stoch: intel openmpi lam_intel lam_intel_debug


robocomp: gfortran_64 intel_64
gfortran_64: serial_gfortran_64 serial_gfortran_64_debug openmpi_gfortran_64 openmpi_gfortran_64_debug
intel_64: serial_intel_64 serial_intel_64_debug openmpi_intel_64 openmpi_intel_64_debug

MAKEFILE                = Makefile

#########################
####    Absoft       ####
#########################

.PHONY : serial_absoft
serial_absoft:
	mkdir -p $(SERIAL_ABSOFT_DIR) 
	cd $(SERIAL_ABSOFT_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_ABSOFT $(PROGRAM)

#########################
####    Lahey        ####
#########################

.PHONY : serial_lahey
serial_lahey:
	mkdir -p $(SERIAL_LAHEY_DIR)
	cd $(SERIAL_LAHEY_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_LAHEY $(PROGRAM)

.PHONY : serial_lahey_debug
serial_lahey_debug:
	mkdir -p $(SERIAL_LAHEY_DEBUG_DIR);
	cd $(SERIAL_LAHEY_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_LAHEY_DEBUG $(PROGRAM)

.PHONY : lam_lahey
lam_lahey:
	mkdir -p $(LAM_LAHEY_DIR) 
	cd $(LAM_LAHEY_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=LAM_LAHEY $(PROGRAM)

.PHONY : lam_lahey_debug
lam_lahey_debug:
	mkdir -p $(LAM_LAHEY_DEBUG_DIR) 
	cd $(LAM_LAHEY_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=LAM_LAHEY_DEBUG $(PROGRAM)

#########################
####    g95          ####
#########################

.PHONY : serial_g95
serial_g95:
	mkdir -p $(SERIAL_G95_DIR)
	cd $(SERIAL_G95_DIR);	$(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_G95 $(PROGRAM)

.PHONY : serial_g95_debug
serial_g95_debug:
	mkdir -p $(SERIAL_G95_DEBUG_DIR);
	cd $(SERIAL_G95_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_G95_DEBUG $(PROGRAM)

.PHONY : lam_g95
lam_g95:
	mkdir -p $(LAM_G95_DIR)
	cd $(LAM_G95_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=LAM_G95 $(PROGRAM)

.PHONY : lam_g95_debug
lam_g95_debug:
	mkdir -p $(LAM_G95_DEBUG_DIR);
	cd $(LAM_G95_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=LAM_G95_DEBUG $(PROGRAM)

#########################
####    gfortran     ####
#########################

.PHONY : serial_gfortran
serial_gfortran:
	mkdir -p $(SERIAL_GFORTRAN_DIR)
	cd $(SERIAL_GFORTRAN_DIR);	$(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_GFORTRAN $(PROGRAM)

.PHONY : serial_gfortran_debug
serial_gfortran_debug:
	mkdir -p $(SERIAL_GFORTRAN_DEBUG_DIR);
	cd $(SERIAL_GFORTRAN_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_GFORTRAN_DEBUG $(PROGRAM)

.PHONY : lam_gfortran
lam_gfortran:
	mkdir -p $(LAM_GFORTRAN_DIR)
	cd $(LAM_GFORTRAN_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=LAM_GFORTRAN $(PROGRAM)

.PHONY : lam_gfortran_debug
lam_gfortran_debug:
	mkdir -p $(LAM_GFORTRAN_DEBUG_DIR);
	cd $(LAM_GFORTRAN_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=LAM_GFORTRAN_DEBUG $(PROGRAM)

.PHONY : openmpi_gfortran_debug
openmpi_gfortran_debug:
	mkdir -p $(OPENMPI_GFORTRAN_DEBUG_DIR);
	cd $(OPENMPI_GFORTRAN_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN_DEBUG $(PROGRAM)
#	ssh $(OPENMPI_COMPUTER) "cd programs/phastpp/srcphast; cd $(OPENMPI_GFORTRAN_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN_DEBUG $(PROGRAM)"

.PHONY : openmpi_gfortran
openmpi_gfortran:
	mkdir -p $(OPENMPI_GFORTRAN_DIR);
	cd $(OPENMPI_GFORTRAN_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN $(PROGRAM)
#	ssh $(OPENMPI_COMPUTER) "cd programs/phastpp/srcphast; cd $(OPENMPI_GFORTRAN_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN $(PROGRAM)"

#########################
####    gfortran_64  ####
#########################

.PHONY : serial_gfortran_64
serial_gfortran_64:
	mkdir -p $(SERIAL_GFORTRAN_64_DIR)
	cd $(SERIAL_GFORTRAN_64_DIR);	$(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_GFORTRAN_64 $(PROGRAM)

.PHONY : serial_gfortran_64_debug
serial_gfortran_64_debug:
	mkdir -p $(SERIAL_GFORTRAN_64_DEBUG_DIR);
	cd $(SERIAL_GFORTRAN_64_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_GFORTRAN_64_DEBUG $(PROGRAM)

.PHONY : openmpi_gfortran_64_debug
openmpi_gfortran_64_debug:
	mkdir -p $(OPENMPI_GFORTRAN_64_DEBUG_DIR);
	cd $(OPENMPI_GFORTRAN_64_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN_64_DEBUG $(PROGRAM)

.PHONY : openmpi_gfortran_64
openmpi_gfortran_64:
	mkdir -p $(OPENMPI_GFORTRAN_64_DIR);
	cd $(OPENMPI_GFORTRAN_64_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN_64 $(PROGRAM)

.PHONY : openmpi_1_4_2_gfortran_64
openmpi_1_4_2_gfortran_64:
	mkdir -p $(OPENMPI_1_4_2_GFORTRAN_64_DIR);
	cd $(OPENMPI_1_4_2_GFORTRAN_64_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_1_4_2_GFORTRAN_64 $(PROGRAM)

.PHONY : openmpi_1_4_2_intel_64_static
openmpi_1_4_2_intel_64_static:
	mkdir -p $(OPENMPI_1_4_2_INTEL_64_STATIC_DIR);
	cd $(OPENMPI_1_4_2_INTEL_64_STATIC_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_1_4_2_INTEL_64_STATIC $(PROGRAM)

.PHONY : mpich_gfortran
mpich_gfortran:
	mkdir -p $(MPICH_GFORTRAN_DIR);
	cd $(MPICH_GFORTRAN_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPICH_GFORTRAN $(PROGRAM)

#########################
####    Intel        ####
#########################

.PHONY : serial_intel
serial_intel:
	mkdir -p $(SERIAL_INTEL_DIR)
	cd $(SERIAL_INTEL_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_INTEL $(PROGRAM)

.PHONY : serial_intel_debug
serial_intel_debug:
	mkdir -p $(SERIAL_INTEL_DEBUG_DIR);
	cd $(SERIAL_INTEL_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_INTEL_DEBUG $(PROGRAM)

.PHONY : serial_intel_64
serial_intel_64:
	mkdir -p $(SERIAL_INTEL_64_DIR)
	cd $(SERIAL_INTEL_64_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_INTEL_64 $(PROGRAM)

.PHONY : serial_intel_64_debug
serial_intel_64_debug:
	mkdir -p $(SERIAL_INTEL_64_DEBUG_DIR);
	cd $(SERIAL_INTEL_64_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_INTEL_64_DEBUG $(PROGRAM)

.PHONY : openmpi_intel
openmpi_intel:
	mkdir -p $(OPENMPI_INTEL_DIR) 
	cd $(OPENMPI_INTEL_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_INTEL $(PROGRAM)

.PHONY : openmpi_intel_debug
openmpi_intel_debug:
	mkdir -p $(OPENMPI_INTEL_DEBUG_DIR) 
	cd $(OPENMPI_INTEL_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_INTEL_DEBUG $(PROGRAM)

.PHONY : openmpi_intel_64
openmpi_intel_64:
	mkdir -p $(OPENMPI_INTEL_64_DIR) 
	cd $(OPENMPI_INTEL_64_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_INTEL_64 $(PROGRAM)

.PHONY : openmpi_intel_64_debug
openmpi_intel_64_debug:
	mkdir -p $(OPENMPI_INTEL_64_DEBUG_DIR) 
	cd $(OPENMPI_INTEL_64_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_INTEL_64_DEBUG $(PROGRAM)

.PHONY : lam_intel
lam_intel:
	mkdir -p $(LAM_INTEL_DIR) 
	cd $(LAM_INTEL_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=LAM_INTEL $(PROGRAM)

.PHONY : lam_intel_debug
lam_intel_debug:
	mkdir -p $(LAM_INTEL_DEBUG_DIR) 
	cd $(LAM_INTEL_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=LAM_INTEL_DEBUG $(PROGRAM)

# Recursive make begins here
#
# =============================================================================
# Significant suffixes [assuming Fortran 90 (.f90)  source code]:
# Significant suffixes [assuming Fortran 90 (.F90)  source code, needs to be preprocessed ]:
# =============================================================================

SRC              = ../IPHreeqcPhast/IPhreeqc/phreeqcpp/phreeqc
PHREEQC_INCLUDES = -I.. -I../IPhreeqcPhast -I../IPhreeqcPhast/IPhreeqc -I../IPhreeqcPhast/IPhreeqc/phreeqcpp -I../IPhreeqcPhast/IPhreeqc/phreeqcpp/phreeqc
LAM_INCLUDES     =  -I/usr/include/
LAM_LIB          =  -L/usr/lib/ -llam

.SUFFIXES : .o .f .F90 .f90 .c .cxx .cpp

# The following apply to Lahey versions
FLAHEY=/z/niwot/usr/local/lf95/bin/lf95
# include lam library first to avoid lahey mpi library
LIBLAHEY=$(LAM_LIB) -L/z/niwot/usr/local/lf95/lib -Xlinker -Bstatic -Xlinker -lfj9i6 -Xlinker -lfj9f6 -Xlinker -lfj9e6 -Xlinker -lfccx86_6a -Xlinker -Bdynamic 
LAHEY_MACHINE=
LAHEY_RUNTIME=/z/niwot/usr/local/lf95/lib/fj90rt0.o 

FABSOFT=/usr/absoft/bin/f90
NLSABSOFT=/usr/absoft/lib/nls/cf90
LIBABSOFT=-L/usr/absoft/lib  -lfio -lU77 -lf77math -lf90math 

FG95=/usr/local/bin/g95
LIBG95=-L/usr/local/g95/lib/gcc-lib/i686-pc-linux-gnu/4.0.1/ -lf95

# The following apply to GFortran versions
FGFORTRAN=gfortran
LIBGFORTRAN= -lgfortranbegin -Xlinker -Bstatic -lgfortran -Xlinker -Bdynamic
LIBGFORTRAN_64=-L/usr/lib64 -lgfortranbegin -Xlinker -Bstatic -lgfortran -Xlinker -Bdynamic

# The following apply to INTEL versions
FINTEL=ifort
#IF_HOME=/z/robocomp/usr/opt/intel/Compiler/11.0/083/lib
IF_HOME=/z/loboraid/raid3/intel/Compiler/11.0/083/lib
IFORT_LIB=-Xlinker -Bstatic -L$(IF_HOME)/ia32/ -lifport -lifcore -limf -lsvml -lm -lipgo -lirc -lirc_s -Xlinker -Bdynamic -lpthread -ldl
IFORT_LIB_64=-Xlinker -Bstatic -L$(IF_HOME)/intel64/ -lifport -lifcore -limf -lsvml -lm -lipgo -lirc -lirc_s -libverbs -ltorque -Xlinker -Bdynamic -lpthread -ldl 

# The following apply to OpenMPI versions
OPENMPI_GFORTRAN_32=/z/parkplace/home/charlton/openmpi-1.4.2/grundvand-gfortran
OPENMPI_IFORT_32=/z/parkplace/home/charlton/openmpi-1.4.2/grundvand-ifort
OPENMPI_GFORTRAN_64=/z/parkplace/home/charlton/openmpi-1.4.2/lobo-gfortran-x64
OPENMPI_IFORT_64=/z/parkplace/home/charlton/openmpi-1.4.2/robocomp-ifort-x64-NO_NUMA

# -----------------------------------------------------------------------------
.f90.o :
	${FC} -c ${FFLAGS} $<
.F90.o :
	${FC} -c ${FFLAGS} $< -o $@
.c.o :
	${CXX} ${CFLAGS} -c -o $@ $<
.cxx.o :
	${CXX} ${CFLAGS} -c -o $@ $<
.cpp.o :
	${CXX} ${CFLAGS} -c -o $@ $<

# -----------------------------------------------------------------------------
#hdf options
HDF5_ROOT=/usr
HDF5_INCLUDES=-I$(HDF5_ROOT)/include 
HDF5_LIBS=${HDF5_ROOT}/lib/libhdf5.a  -Xlinker -Bstatic -lz -Xlinker -Bdynamic -lpthread 
HDF5_LIBS_64=${HDF5_ROOT}/lib64/libhdf5.a -Xlinker -Bstatic -lz -Xlinker -Bdynamic -lpthread 

# -----------------------------------------------------------------------------
DEFINE_HDF=-DHDF5_CREATE -DH5Dcreate_vers=1 -DH5Gcreate_vers=1 -DH5Eset_auto_vers=1
DEFINE_MPI=-DUSE_MPI
DEFINE_MERGE=-DMERGE_FILES

# -----------------------------------------------------------------------------
# #define gmp for inverse modeling
# comment the following lines to remove multiprecision option
#DINVERSE_CL1MP=TRUE
##CL1MP_LIB=/z/parkplace/usr/lib/libgmp.a 
#CL1MP_LIB=/usr/lib/libgmp.a 
#CL1MP_OBJS=cl1mp.o

# -----------------------------------------------------------------------------
#efence for debugging
EFENCE_LIB=-L$(HOME)/packages/efence

# -----------------------------------------------------------------------------
# fixes shared object lookup error(SIGFPE floating point exception)
HASH_STYLE=$(call ld-option, -Wl$(comma)--hash-style=sysv)

# -----------------------------------------------------------------------------
# Versions
# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_ABSOFT)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FABSOFT)
  NLSPATH      = $(NLSABSOFT)
  FDEBUG       = -O -en  # -C
  FMISC        = -YEXT_NAMES=LCS -s -YCFRL=1 -trap=DIVBYZERO,OVERFLOW
  FFLAGS       = $(FDEBUG) $(FMISC) $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm ${CL1MP_LIB} ${HDF5_LIBS} $(LIBABSOFT) ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_LAHEY)
  DEFINES      = $(DEFINE_HDF) -DLAHEY_F95 -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name\ \#\#\ _ -DFC_FUNC_\(name,NAME\)=name\ \#\#\ _
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FLAHEY)
  FFLAGS       = -O $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm  ${CL1MP_LIB} ${HDF5_LIBS} $(LIBLAHEY) ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_LAHEY_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DLAHEY_F95 -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name\ \#\#\ _ -DFC_FUNC_\(name,NAME\)=name\ \#\#\ _
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FLAHEY)
  FFLAGS       = -g --f95 --chkglobal --warn --info $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm -lgcc_s ${CL1MP_LIB} ${HDF5_LIBS} $(LIBLAHEY) ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), LAM_LAHEY)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DLAHEY_F95 -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name\ \#\#\ _ -DFC_FUNC_\(name,NAME\)=name\ \#\#\ _
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FLAHEY)
  FFLAGS       = -O $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm -lgcc_s ${CL1MP_LIB} ${HDF5_LIBS} $(LIBLAHEY) -ldl ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), LAM_LAHEY_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DLAHEY_F95 -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name\ \#\#\ _ -DFC_FUNC_\(name,NAME\)=name\ \#\#\ _
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FLAHEY)
  FFLAGS       = -g --chkglobal --warn --info $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm -lgcc_s ${CL1MP_LIB} ${HDF5_LIBS} $(LIBLAHEY) -ldl ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_G95)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FG95)
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CC           = g++
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBG95) -lm ${CL1MP_LIB} ${HDF5_LIBS} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_G95_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FG95)
  FFLAGS       = -g -fno-underscoring $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall  -g $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS)  $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBG95) -lm ${CL1MP_LIB} ${HDF5_LIBS} ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), LAM_G95)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FG95)
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBG95) -lm ${CL1MP_LIB} ${HDF5_LIBS} -ldl ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), LAM_G95_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FG95)
  FFLAGS       = -g  -fno-underscoring $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBG95) -lm ${CL1MP_LIB} ${HDF5_LIBS}  -ldl ${HASH_STYLE}
  LINKER       = $(CXX)
endif
# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FGFORTRAN)
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CC           = g++
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) -lm ${CL1MP_LIB} ${HDF5_LIBS} ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../PhastFortran:../IPhreeqcPhast:../IPhreeqcPhast/IPhreeqc:../IPhreeqcPhast/IPhreeqc/phreeqcpp:../IPhreeqcPhast/IPhreeqc/phreeqcpp/phreeqc:../KDtree
  FC           = $(FGFORTRAN)
  FFLAGS       = -g -fno-underscoring $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS)  $(HDF_OBJS) # $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) -lm ${HDF5_LIBS} ${HASH_STYLE} # ${CL1MP_LIB} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN_64)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FGFORTRAN)
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CC           = g++
  CFLAGS       = -Wall -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) -lm ${CL1MP_LIB} ${HDF5_LIBS_64} ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FGFORTRAN)
  FFLAGS       = -g -fno-underscoring $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS)  $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) -lm ${CL1MP_LIB} ${HDF5_LIBS_64} ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), LAM_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FGFORTRAN)
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) -lm ${CL1MP_LIB} ${HDF5_LIBS} -ldl ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), LAM_GFORTRAN_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FGFORTRAN)
  FFLAGS       = -g  -fno-underscoring $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) -lm ${CL1MP_LIB} ${HDF5_LIBS}  -ldl ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE 
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  DINVERSE_CL1MP=
#  FC           = $(OPENMPI_GFORTRAN_32)/bin/mpif90
  FC           = $(FGFORTRAN)
  FFLAGS       = -O3 -fno-underscoring -I/usr/include $(DEFINES)
  CXX          = $(OPENMPI_GFORTRAN_32)/bin/mpicxx
  CC           = $(OPENMPI_GFORTRAN_32)/bin/mpicxx
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) # $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) ${HDF5_LIBS} -lmpi_f77 -ldl ${HASH_STYLE} # -lm ${CL1MP_LIB}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_GFORTRAN_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  DINVERSE_CL1MP=
#  FC           = $(OPENMPI_GFORTRAN_32)/bin/mpif90
  FC           = $(FGFORTRAN)
  FFLAGS       = -g  -fno-underscoring -I/usr/include $(DEFINES)
  CXX          = $(OPENMPI_GFORTRAN_32)/bin/mpicxx
  CC           = $(OPENMPI_GFORTRAN_32)/bin/mpicxx
  CFLAGS       = -Wall -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) # $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) ${HDF5_LIBS} -lmpi_f77 -ldl ${HASH_STYLE} # -lm ${CL1MP_LIB}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), OPENMPI_GFORTRAN_64)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE -DNO_UNDERSCORES
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  HDF5_INCLUDES=-I$(HDF5_ROOT)/include 
  DINVERSE_CL1MP=
#  FC           = $(OPENMPI_GFORTRAN_64)/bin/mpif90
  FC           = $(FGFORTRAN)
  FFLAGS       = -O3 -fno-underscoring -I/usr/include $(DEFINES)
  CXX          = $(OPENMPI_GFORTRAN_64)/bin/mpiCC
  CC           = $(OPENMPI_GFORTRAN_64)/bin/mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) # $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) ${HDF5_LIBS_64} -L$(OPENMPI_GFORTRAN_64)/lib -Xlinker -Bstatic -lmpi_f77 -Xlinker -Bdynamic -ldl ${HASH_STYLE} # -lm ${CL1MP_LIB}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), OPENMPI_GFORTRAN_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC -DNO_UNDERSCORES
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  HDF5_INCLUDES=-I$(HDF5_ROOT)/include 
  DINVERSE_CL1MP=
#  FC           = $(OPENMPI_GFORTRAN_64)/bin/mpif90
  FC           = $(FGFORTRAN)
  FFLAGS       = -g  -fno-underscoring -I/usr/include $(DEFINES)
  CXX          = $(OPENMPI_GFORTRAN_64)/bin/mpiCC
  CC           = $(OPENMPI_GFORTRAN_64)/bin/mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) 
  LD_FLAGS     = $(LIBGFORTRAN_64) ${HDF5_LIBS_64} -lmpi_f77 -ldl ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), SERIAL_INTEL)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FINTEL)
  FFLAGS       = -O3 -nus $(DEFINES) 
  CXX          = g++
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS) 
  LD_FLAGS     = ${IFORT_LIB} ${HDF5_LIBS} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_INTEL_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FINTEL)
  FFLAGS       = -g -nus $(DEFINES)
  CXX          = g++
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS) 
  LD_FLAGS     = ${IFORT_LIB} ${HDF5_LIBS} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_INTEL_64)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FINTEL)
  FFLAGS       = -O3 -nus $(DEFINES)
  CXX          = g++
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS) 
  LD_FLAGS     = ${IFORT_LIB_64} ${HDF5_LIBS_64} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_INTEL_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FINTEL)
  FFLAGS       = -g -nus $(DEFINES)
  CXX          = g++
  CFLAGS       = -Wall -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS) 
  LD_FLAGS     = ${IFORT_LIB_64} ${HDF5_LIBS_64} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_INTEL)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE 
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FINTEL)
  FFLAGS       = -O3 -nus $(DEFINES)
  CXX          = $(OPENMPI_IFORT_32)/bin/mpiCC
  CC           = $(OPENMPI_IFORT_32)/bin/mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS) 
  LD_FLAGS     = ${IFORT_LIB} ${HDF5_LIBS} -lmpi_cxx  ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_INTEL_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
#  FC           = $(OPENMPI_IFORT_32)/bin/mpif90
  FC           = $(FINTEL)
  FFLAGS       = -g -nus $(DEFINES)
  CXX          = $(OPENMPI_IFORT_32)/bin/mpiCC
  CC           = $(OPENMPI_IFORT_32)/bin/mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS) 
  LD_FLAGS     = ${IFORT_LIB} ${HDF5_LIBS} ${HASH_STYLE} -lmpi_cxx
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_INTEL_64)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
#  FC           = $(OPENMPI_IFORT_64)/bin/mpif90
  FC           = $(FINTEL)
  FFLAGS       = -O3 -nus $(DEFINES)
  CXX          = $(OPENMPI_IFORT_64)/bin/mpiCC
  CC           = $(OPENMPI_IFORT_64)/bin/mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS) 
  LD_FLAGS     = ${IFORT_LIB_64} ${HDF5_LIBS_64} -lmpi_cxx  ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_INTEL_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
#  FC           = $(OPENMPI_IFORT_64)/bin/mpif90
  FC           = $(FINTEL)
  FFLAGS       = -g -nus $(DEFINES)
  CXX          = $(OPENMPI_IFORT_64)/bin/mpiCC
  CC           = $(OPENMPI_IFORT_64)/bin/mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS) 
  LD_FLAGS     = ${IFORT_LIB_64} ${HDF5_LIBS_64} ${HASH_STYLE} -lmpi_cxx
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), LAM_INTEL)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE
  HDF5_ROOT    = /z/parkplace/usr
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FINTEL)
  FFLAGS       = -O3 -nus $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = ${IFORT_LIB} ${HDF5_LIBS}  ${HASH_STYLE}  
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), LAM_INTEL_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC
  HDF5_ROOT    = /z/parkplace/usr
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  FC           = $(FINTEL)
  FFLAGS       = -g -nus $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = ${IFORT_LIB} ${HDF5_LIBS} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), MPICH_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP -DHAVE_ISFINITE 
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc:../KDtree
  DINVERSE_CL1MP=
  SZIP_ROOT=/home/dlpark/packages/szip2.0-linux-gcc3.2.3-enc
  SZIP_LIB=${SZIP_ROOT}/lib/libsz.a
  ZLIB_ROOT=/home/dlpark/packages/zlib121-linux2.4
  ZLIB_LIB=${ZLIB_ROOT}/lib/libz.a
  HDF5_ROOT    =/z/parkplace/home/dlpark/packages/5-1.6.6-linux
  HDF5_INCLUDES=-I$(HDF5_ROOT)/include 
  HDF5_LIBS=${HDF5_ROOT}/lib/libhdf5.a -lpthread $(SZIP_LIB) $(ZLIB_LIB)
  MPICH_ROOT=/z/parkplace/home/dlpark/packages/mpich2-1.0.5p4
  MPICH_BIN=$(MPICH_ROOT)/bin
  MPICH_INCLUDES=-I$(MPICH_ROOT)/src/include
#  MPICH_LIB=-L$(MPICH_ROOT)/lib -lfmpich -lmpich -lmpichcxx -lmpichf90
#  FC           = $(MPICH_BIN)/mpif90
  FC           = $(FGFORTRAN)
  FFLAGS       = -O3 -fno-underscoring $(MPICH_INCLUDES) $(DEFINES) 
  CXX          = $(MPICH_BIN)/mpicxx
  CC           = $(MPICH_BIN)/mpicxx
  CFLAGS       = -Wall  -O3 $(DEFINES) $(MPICH_INCLUDES) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) # $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) ${HDF5_LIBS}  -ldl ${MPICH_LIB} ${HASH_STYLE} # -lm ${CL1MP_LIB}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
# (d) Create expected object file list, with .o extension:     [TARGETS OF PRE-
#     REQUISITE (.f90,.f) SOURCE FILES]
#

COMMON_FOBJS =	\
	aplbce_flow.o \
	aplbci_flow.o \
	asembl_flow.o \
	asmslp.o \
	calcc.o \
	calc_velocity.o \
	clog.o \
	closef.o \
	coeff_flow.o \
	coeff_trans.o \
	dealloc_arr.o \
	dealloc_arr_worker.o \
	dump.o \
	error1.o \
	error2.o \
	error3.o \
	error4.o \
	errprt.o \
	etom1.o \
	etom2.o \
	hdf_f.o \
	incidx.o \
	indx_rewi_bc.o \
	indx_rewi.o \
	init1.o \
	init2_1.o \
	init2_1_xfer.o \
	init2_2.o \
	init2_3.o \
	init2_post_ss.o \
	init3.o \
	init3_xfer.o \
	interpolate_mod.o \
	ldchar_bc.o \
	ldchar.o \
	ld_seg_mod.o \
	mach_mod.o \
	modules_g.o \
	modules_manager.o \
	mpi_array_mod.o \
	mpi_mod.o \
	mtoijk.o \
	nintrp.o \
	openf.o \
	phast_manager.o \
	phast_spmd.o \
	phast_worker.o \
	prchar.o \
	printar.o \
	print_control_mod.o \
	read1.o \
	read1_xfer.o \
	read2.o \
	read2_xfer.o \
	read3.o \
	read3_xfer.o \
	reorder_mod.o \
	rewi_mod.o \
	rhsn.o \
	rhsn_manager.o \
	rhsn_ss_flow.o \
	sbcflo.o \
	scale_jds_mod.o \
	set_component_map.o \
	simulate_ss_flow.o \
	solver_direct_mod.o \
	solver_iter_mod.o \
	stonb.o \
	sumcal1.o \
	sumcal1_manager.o \
	sumcal2.o \
	sumcal_ss_flow.o \
	terminate_phast.o \
	terminate_phast_worker.o \
	timestep.o \
	time_step_save.o \
	timestep_ss_flow.o \
	timestep_worker.o \
	update_print_flags.o \
	uppercase.o \
	wbbal.o \
	wbcflo.o \
	wellsc.o \
	wellsc_ss_flow.o \
	wellsr.o \
	wellsr_ss_flow.o \
	welris.o \
	wfdydz.o \
	write1.o \
	write2_1.o \
	write2_2.o \
	write3.o \
	write3_ss_flow.o \
	write4.o \
	write5.o \
	write5_ss_flow.o \
	write6.o \
	xfer_to_manager.o \
	xfer_to_workers.o \
	XP_aplbce.o \
	XP_aplbci.o \
	XP_asembl.o \
	XP_asmslc.o \
	XP_crsdsp.o \
	XP_etom2.o \
	XP_module.o \
	XP_rhsn.o \
	XP_sumcal1.o \
	XP_wbcflo.o \
	XP_wellsc.o \
	XP_wellsr.o \
	zone_flow.o \
	zone_flow_ss.o 

COMMON_CXXOBJS = \
gzstream.o \
phast_main.o  \
Reaction_module.o \
RM_interface.o \
\
fwrap2Phast.o \
fwrap3Phast.o \
fwrap4Phast.o \
fwrap5Phast.o \
fwrap6Phast.o \
fwrap7Phast.o \
fwrap8.Phast.o \
fwrapPhast.o \
IPhreeqcPhast.o \
IPhreeqcPhastLib.o \
\
fwrap2.o \
fwrap3.o \
fwrap4.o \
fwrap5.o \
fwrap6.o \
fwrap7.o \
fwrap8.o \
fwrap.o \
IPhreeqc.o \
IPhreeqcLib.o \
pp_sys.o \
SelectedOutput.o \
Var.o \
\
ChartHandler.o \
ChartObject.o \
CurveObject.o \
cxxKinetics.o \
cxxMix.o \
dumper.o \
Exchange.o \
ExchComp.o \
GasComp.o \
GasPhase.o \
ISolutionComp.o \
ISolution.o \
Keywords.o \
KineticsComp.o \
NameDouble.o \
NumKeyword.o \
Parser.o \
PBasic.o \
Phreeqc.o \
PHRQ_base.o \
PHRQ_io.o \
PPassemblageComp.o \
PPassemblage.o \
Pressure.o \
Reaction.o \
ReadClass.o \
runner.o \
Solution.o \
SolutionIsotope.o \
SSassemblage.o \
SScomp.o \
SS.o \
StorageBin.o \
StorageBinList.o \
SurfaceCharge.o \
SurfaceComp.o \
Surface.o \
System.o \
Temperature.o \
Use.o \
Utils.o \
\
advection.o \
basicsubs.o \
cl1.o \
cvdense.o \
cvode.o \
dense.o \
dw.o \
gases.o \
input.o \
integrate.o \
inverse.o \
isotopes.o \
kinetics.o \
mainsubs.o \
model.o \
nvector.o \
nvector_serial.o \
parse.o \
phqalloc.o \
PHRQ_io_output.o \
pitzer.o \
pitzer_structures.o \
prep.o \
print.o \
read.o \
readtr.o \
sit.o \
smalldense.o \
spread.o \
step.o \
structures.o \
sundialsmath.o \
tally.o \
tidy.o \
transport.o \
utilities.o \
\
kdtree2.o \
KDtree.o \
Point.o

HDF_OBJS     =  #hdf.o hdf_f.o

MERGE_OBJS   =	#merge.o

MPI_OBJS     =	#mpimod.o phast_slave.o slavesubs.o


PHASTINPUT_FILES = ../KDtree/KDtree.cpp \
	../KDtree/kdtree2.cpp \
	../KDtree/Point.cpp

# -----------------------------------------------------------------------------
#  Assign dependents to target on dependency line & link options on command 
#  line. Command line is initiated with a tab. ($@ is an internal macro for 
#  the current target.) 

${PROGRAM} : ${OBJECT_FILES}
#	${FC} -o $@ ${OBJECT_FILES} ${LD_LIB1} ${LD_FLAGS} 
#	${CXX} -o $@ ${OBJECT_FILES} ${LD_LIB1} ${LD_FLAGS} 
	${LINKER} -o $@ ${OBJECT_FILES} ${LD_LIB1} ${LD_FLAGS} 
	@echo; echo Done making for phast
# -----------------------------------------------------------------------------
#  SPECIAL TARGET for compiling files containing modules so that
#  module_name.mod and module_name.o files are created or
#  updated before all other source code object files. 

mach_mod.o: ../PhastFortran/mach_mod.f90
	${FC} -c ${FFLAGS} $<
modules_g.o: ../PhastFortran/modules_g.f90 mach_mod.o modules_manager.o
	${FC} -c ${FFLAGS} $<
modules_manager.o: ../PhastFortran/modules_manager.f90 mach_mod.o
	${FC} -c ${FFLAGS} $<
print_control_mod.o: ../PhastFortran/print_control_mod.f90 modules_g.o
	${FC} -c ${FFLAGS} $<
ld_seg_mod.o:      ../PhastFortran/ld_seg_mod.f90  modules_g.o modules_manager.o
	${FC} -c ${FFLAGS} $<
interpolate_mod.O: ../PhastFortran/interpolate_mod.f90
	${FC} -c ${FFLAGS} $<
#mpi_array_mod.F90
#mpi_mod.F90
reorder_mod.o: ../PhastFortran/reorder_mod.f90
	${FC} -c ${FFLAGS} $<
rewi_mod.o: ../PhastFortran/rewi_mod.f90
	${FC} -c ${FFLAGS} $<
scale_jds_mod.o: ../PhastFortran/scale_jds_mod.f90
	${FC} -c ${FFLAGS} $<
solver_direct_mod.o: ../PhastFortran/solver_direct_mod.f90
	${FC} -c ${FFLAGS} $<
solver_iter_mod.o: ../PhastFortran/solver_iter_mod.f90
	${FC} -c ${FFLAGS} $<
XP_module.o: ../PhastFortran/XP_module.f90
	${FC} -c ${FFLAGS} $<

# -----------------------------------------------------------------------------
# Module dependency list
# -----------------------------------------------------------------------------
aplbce_flow.o: ../PhastFortran/aplbce_flow.f90
aplbci_flow.o: ../PhastFortran/aplbci_flow.F90
asembl_flow.o: ../PhastFortran/asembl_flow.f90
asmslp.o: ../PhastFortran/asmslp.F90
calcc.o: ../PhastFortran/calcc.f90
calc_velocity.o: ../PhastFortran/calc_velocity.f90
clog.o: ../PhastFortran/clog.f90
closef.o: ../PhastFortran/closef.F90
coeff_flow.o: ../PhastFortran/coeff_flow.F90
coeff_trans.o: ../PhastFortran/coeff_trans.F90
dealloc_arr.o: ../PhastFortran/dealloc_arr.F90
dealloc_arr_worker.o: ../PhastFortran/dealloc_arr_worker.F90
dump.o: ../PhastFortran/dump.f90
error1.o: ../PhastFortran/error1.f90
error2.o: ../PhastFortran/error2.f90
error3.o: ../PhastFortran/error3.f90
error4.o: ../PhastFortran/error4.f90
errprt.o: ../PhastFortran/errprt.f90
etom1.o: ../PhastFortran/etom1.f90
etom2.o: ../PhastFortran/etom2.f90
hdf_f.o: ../PhastFortran/hdf_f.F90
incidx.o: ../PhastFortran/incidx.f90
indx_rewi_bc.o: ../PhastFortran/indx_rewi_bc.f90
indx_rewi.o: ../PhastFortran/indx_rewi.f90
init1.o: ../PhastFortran/init1.F90
init2_1.o: ../PhastFortran/init2_1.F90
init2_1_xfer.o: ../PhastFortran/init2_1_xfer.F90
init2_2.o: ../PhastFortran/init2_2.f90
init2_3.o: ../PhastFortran/init2_3.f90
init2_post_ss.o: ../PhastFortran/init2_post_ss.F90
init3.o: ../PhastFortran/init3.F90
init3_xfer.o: ../PhastFortran/init3_xfer.F90
ldchar_bc.o: ../PhastFortran/ldchar_bc.f90
ldchar.o: ../PhastFortran/ldchar.f90
mtoijk.o: ../PhastFortran/mtoijk.f90
nintrp.o: ../PhastFortran/nintrp.f90
openf.o: ../PhastFortran/openf.F90
phast_manager.o: ../PhastFortran/phast_manager.F90
phast_spmd.o: ../PhastFortran/phast_spmd.F90
phast_worker.o: ../PhastFortran/phast_worker.F90
prchar.o: ../PhastFortran/prchar.f90
printar.o: ../PhastFortran/printar.f90
read1.o: ../PhastFortran/read1.F90
read1_xfer.o: ../PhastFortran/read1_xfer.F90
read2.o: ../PhastFortran/read2.F90
read2_xfer.o: ../PhastFortran/read2_xfer.F90
read3.o: ../PhastFortran/read3.F90
read3_xfer.o: ../PhastFortran/read3_xfer.F90
rhsn.o: ../PhastFortran/rhsn.f90
rhsn_manager.o: ../PhastFortran/rhsn_manager.F90
rhsn_ss_flow.o: ../PhastFortran/rhsn_ss_flow.f90
sbcflo.o: ../PhastFortran/sbcflo.f90
set_component_map.o: ../PhastFortran/set_component_map.F90
simulate_ss_flow.o: ../PhastFortran/simulate_ss_flow.f90
stonb.o: ../PhastFortran/stonb.f90
sumcal1.o: ../PhastFortran/sumcal1.F90
sumcal1_manager.o: ../PhastFortran/sumcal1_manager.F90
sumcal2.o: ../PhastFortran/sumcal2.f90
sumcal_ss_flow.o: ../PhastFortran/sumcal_ss_flow.f90
terminate_phast.o: ../PhastFortran/terminate_phast.F90
terminate_phast_worker.o: ../PhastFortran/terminate_phast_worker.F90
timestep.o: ../PhastFortran/timestep.F90
time_step_save.o: ../PhastFortran/time_step_save.F90
timestep_ss_flow.o: ../PhastFortran/timestep_ss_flow.f90
timestep_worker.o: ../PhastFortran/timestep_worker.F90
update_print_flags.o: ../PhastFortran/update_print_flags.f90
uppercase.o: ../PhastFortran/uppercase.f90
wbbal.o: ../PhastFortran/wbbal.f90
wbcflo.o: ../PhastFortran/wbcflo.f90
wellsc.o: ../PhastFortran/wellsc.f90
wellsc_ss_flow.o: ../PhastFortran/wellsc_ss_flow.f90
wellsr.o: ../PhastFortran/wellsr.f90
wellsr_ss_flow.o: ../PhastFortran/wellsr_ss_flow.f90
welris.o: ../PhastFortran/welris.f90
wfdydz.o: ../PhastFortran/wfdydz.f90
write1.o: ../PhastFortran/write1.f90
write2_1.o: ../PhastFortran/write2_1.f90
write2_2.o: ../PhastFortran/write2_2.f90
write3.o: ../PhastFortran/write3.f90
write3_ss_flow.o: ../PhastFortran/write3_ss_flow.f90
write4.o: ../PhastFortran/write4.f90
write5.o: ../PhastFortran/write5.f90
write5_ss_flow.o: ../PhastFortran/write5_ss_flow.f90
write6.o: ../PhastFortran/write6.f90
xfer_to_manager.o: ../PhastFortran/xfer_to_manager.F90
xfer_to_workers.o: ../PhastFortran/xfer_to_workers.F90
XP_aplbce.o: ../PhastFortran/XP_aplbce.f90
XP_aplbci.o: ../PhastFortran/XP_aplbci.F90
XP_asembl.o: ../PhastFortran/XP_asembl.f90
XP_asmslc.o: ../PhastFortran/XP_asmslc.F90
XP_crsdsp.o: ../PhastFortran/XP_crsdsp.f90
XP_etom2.o: ../PhastFortran/XP_etom2.f90
XP_rhsn.o: ../PhastFortran/XP_rhsn.f90
XP_sumcal1.o: ../PhastFortran/XP_sumcal1.f90
XP_wbcflo.o: ../PhastFortran/XP_wbcflo.f90
XP_wellsc.o: ../PhastFortran/XP_wellsc.f90
XP_wellsr.o: ../PhastFortran/XP_wellsr.f90
zone_flow.o: ../PhastFortran/zone_flow.f90
zone_flow_ss.o: ../PhastFortran/zone_flow_ss.f90
#
#  PHAST Fortran files
#

#
#  Dependencies
#
-include ../dependencies

clean:
	rm -rf serial_absoft serial_lahey serial_lahey_debug lam_lahey lam_lahey_debug serial_g95 serial_g95_debug lam_g95 lam_g95_debug serial_gfortran serial_gfortran_debug lam_gfortran lam_gfortran_debug openmpi_gfortran openmpi_gfortran_debug serial_gfortran_64 serial_gfortran_64_debug openmpi_gfortran_64 openmpi_gfortran_64_debug serial_intel serial_intel_debug serial_intel_64 serial_intel_64_debug openmpi_intel openmpi_intel_debug openmpi_intel_64 openmpi_intel_64_debug lam_intel lam_intel_debug

depends:
	mkdir -p temp_dependency_dir
	cd temp_dependency_dir; gcc -MM $(DEFINE_HDF) -I.. -I../IPhreeqcPhast \
	-I../IPhreeqcPhast/IPhreeqc -I../IPhreeqcPhast/IPhreeqc/phreeqcpp \
	-I../IPhreeqcPhast/IPhreeqc/phreeqcpp/phreeqc -I../KDtree \
	../*.cxx ../*.cpp \
	../IPhreeqcPhast/*.cpp 	../IPhreeqcPhast/*.cxx \
	../IPhreeqcPhast/IPhreeqc/*.cpp \
	../IPhreeqcPhast/IPhreeqc/phreeqcpp/*.cxx ../IPhreeqcPhast/IPhreeqc/phreeqcpp/*.cpp \
	../IPhreeqcPhast/IPhreeqc/phreeqcpp/phreeqc/*.cpp \
	../KDtree/*.cpp $(PHASTINPUT_FILES) > ../dependencies
#	cd temp_dependency_dir; gfortran -MM $(DEFINE_HDF) -I.. -I../IPhreeqcPhast \
#	../PhastFortran/*.f90 ../PhastFortran/*.F90 \
#	$(PHASTINPUT_FILES) > ../dependencies_fort
	rm -rf temp_dependency_dir

depends_parallel:
	mkdir -p temp_dependency_dir
	cd temp_dependency_dir; gcc -MM $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -I../phreeqcpp -I../phreeqcpp/phreeqc -I../KDtree ../*.cxx ../*.c ../phreeqcpp/*.cxx ../phreeqcpp/phreeqc/*.c $(PHASTINPUT_FILES) > ../dependencies_parallel
	rm -rf temp_dependency_dir

touch_fc_func:
	touch hst.cxx phast_main.cpp phastproto.h slavesubs.c

#ld-option
# Usage: ldflags += $(call ld-option, -Wl$(comma)--hash-style=sysv)
comma=,
ld-option = $(shell if $(CC) $(1) \
              -nostdlib -o /dev/null -xc /dev/null \
              > /dev/null 2>&1 ; then echo "$(1)" ; else echo "$(2)"; fi)


# =============================================================================
# End of makefile.
# =============================================================================
