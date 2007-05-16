# Makefile for PHAST
#
# Generates object files and executables for 8 versions of PHAST
#	    Gfortran/Lahey compiler
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

all: gfortran lahey g95 # absoft

# serial_lahey serial_lahey_debug mpi_lahey mpi_lahey_debug 

SERIAL_ABSOFT_DIR       = serial_absoft
SERIAL_ABSOFT_DEBUG_DIR = serial_absoft_debug
MPI_ABSOFT_DIR          = mpi_absoft
MPI_ABSOFT_DEBUG_DIR    = mpi_absoft_debug
absoft: serial_absoft serial_absoft_debug mpi_absoft mpi_absoft_debug

SERIAL_LAHEY_DIR        = serial_lahey
SERIAL_LAHEY_DEBUG_DIR  = serial_lahey_debug
MPI_LAHEY_DIR           = mpi_lahey
MPI_LAHEY_DEBUG_DIR     = mpi_lahey_debug
lahey: serial_lahey serial_lahey_debug mpi_lahey mpi_lahey_debug

SERIAL_G95_DIR          = serial_g95
SERIAL_G95_DEBUG_DIR    = serial_g95_debug
MPI_G95_DIR             = mpi_g95
MPI_G95_DEBUG_DIR       = mpi_g95_debug
g95: serial_g95 serial_g95_debug mpi_g95 mpi_g95_debug

SERIAL_GFORTRAN_DIR          = serial_gfortran
SERIAL_GFORTRAN_DEBUG_DIR    = serial_gfortran_debug
MPI_GFORTRAN_DIR             = mpi_gfortran
MPI_GFORTRAN_DEBUG_DIR       = mpi_gfortran_debug
OPENMPI_GFORTRAN_DIR         = openmpi_gfortran
OPENMPI_GFORTRAN_DEBUG_DIR   = openmpi_gfortran_debug
gfortran: serial_gfortran serial_gfortran_debug mpi_gfortran mpi_gfortran_debug 
open_mpi: openmpi_gfortran openmpi_gfortran_debug

SERIAL_GFORTRAN_64_DIR       = serial_gfortran_64
SERIAL_GFORTRAN_64_DEBUG_DIR = serial_gfortran_debug_64
OPENMPI_GFORTRAN_64_DIR      = openmpi_gfortran_64
OPENMPI_GFORTRAN_64_DEBUG_DIR= openmpi_gfortran_64_debug
gfortran_64: serial_gfortran_64 serial_gfortran_64_debug openmpi_gfortran_64 openmpi_gfortran_64_debug

MAKEFILE                = Makefile

#########################
####    Absoft       ####
#########################

.PHONY : serial_absoft
serial_absoft:
	mkdir -p $(SERIAL_ABSOFT_DIR) 
	cd $(SERIAL_ABSOFT_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_ABSOFT $(PROGRAM)

.PHONY : serial_absoft_debug
serial_absoft_debug:
	mkdir -p $(SERIAL_ABSOFT_DEBUG_DIR) 
	cd $(SERIAL_ABSOFT_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_ABSOFT_DEBUG $(PROGRAM)
.PHONY : mpi_absoft
mpi_absoft:
	mkdir -p $(MPI_ABSOFT_DIR)
	cd $(MPI_ABSOFT_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_ABSOFT $(PROGRAM)

.PHONY : mpi_absoft_debug
mpi_absoft_debug:
	mkdir -p $(MPI_ABSOFT_DEBUG_DIR);
	cd $(MPI_ABSOFT_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_ABSOFT_DEBUG $(PROGRAM)

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

.PHONY : mpi_lahey
mpi_lahey:
	mkdir -p $(MPI_LAHEY_DIR) 
	cd $(MPI_LAHEY_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_LAHEY $(PROGRAM)

.PHONY : mpi_lahey_debug
mpi_lahey_debug:
	mkdir -p $(MPI_LAHEY_DEBUG_DIR) 
	cd $(MPI_LAHEY_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_LAHEY_DEBUG $(PROGRAM)

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

.PHONY : mpi_g95
mpi_g95:
	mkdir -p $(MPI_G95_DIR)
	cd $(MPI_G95_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_G95 $(PROGRAM)

.PHONY : mpi_g95_debug
mpi_g95_debug:
	mkdir -p $(MPI_G95_DEBUG_DIR);
	cd $(MPI_G95_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_G95_DEBUG $(PROGRAM)

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

.PHONY : mpi_gfortran
mpi_gfortran:
	mkdir -p $(MPI_GFORTRAN_DIR)
	cd $(MPI_GFORTRAN_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_GFORTRAN $(PROGRAM)

.PHONY : mpi_gfortran_debug
mpi_gfortran_debug:
	mkdir -p $(MPI_GFORTRAN_DEBUG_DIR);
	cd $(MPI_GFORTRAN_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=MPI_GFORTRAN_DEBUG $(PROGRAM)

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
# Recursive make begins here
#
# =============================================================================
# Significant suffixes [assuming Fortran 90 (.f90)  source code]:
# Significant suffixes [assuming Fortran 90 (.F90)  source code, needs to be preprocessed ]:
# =============================================================================

SRC              = ../phreeqcpp/phreeqc
PHREEQC_INCLUDES = -I../phreeqcpp -I../phreeqcpp/phreeqc
LAM_INCLUDES     =  
LAM_LIB          =  -L/usr/lib/ -llam

.SUFFIXES : .o .f .F90 .f90 .c .cxx 

# compilers
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

LIBGFORTRAN_64=-L/usr/lib64 -lgfortranbegin -lgfortran
FGFORTRAN=gfortran
LIBGFORTRAN= -lgfortranbegin -lgfortran
# for static linking of gfortran library
#LIBGFORTRAN= -lgfortranbegin /usr/lib/gcc/i586-mandriva-linux-gnu/4.1.2/libgfortran.a

OPENMPI_COMPUTER=grundvand

# -----------------------------------------------------------------------------
.f90.o :
	${FC} -c ${FFLAGS} $<
.F90.o :
	${FC} -c ${FFLAGS} $< -o $@
.c.o :
	${CXX} ${CFLAGS} -c -o $@ $<
.cxx.o :
	${CXX} ${CFLAGS} -c -o $@ $<

# -----------------------------------------------------------------------------
#hdf options
HDF5_ROOT=/usr
HDF5_INCLUDES=-I$(HDF5_ROOT)/include 
HDF5_LIBS=${HDF5_ROOT}/lib/libhdf5.a  -lz -lpthread
HDF5_LIBS_64=${HDF5_ROOT}/lib64/libhdf5.a -lpthread -lz

# -----------------------------------------------------------------------------
DEFINE_HDF=-DHDF5_CREATE
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
# Versions
# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_ABSOFT)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FABSOFT)
  NLSPATH      = $(NLSABSOFT)
  FDEBUG       = -O -en  # -C
  FMISC        = -YEXT_NAMES=LCS -s -YCFRL=1 -trap=DIVBYZERO,OVERFLOW
  FFLAGS       = $(FDEBUG) $(FMISC) $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  CFLAGS_MODEL = -Wall -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm ${CL1MP_LIB} ${HDF5_LIBS} $(LIBABSOFT)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_ABSOFT_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FABSOFT)
  NLSPATH      = $(NLSABSOFT)
  FDEBUG       = -g -en # -Rb -Rc -Rp -Rs # range checking
  FMISC        = -YEXT_NAMES=LCS -s -YCFRL=1 -trap=DIVBYZERO,OVERFLOW
  FFLAGS       = $(FDEBUG) $(FMISC) $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall -g $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  CFLAGS_MODEL = -Wall -g $(DEFINES) $(HDF5_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm ${CL1MP_LIB} ${HDF5_LIBS} $(LIBABSOFT) # ${EFENCE_LIB} -lefence
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_ABSOFT)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG  -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  LAMHF77      = $(FABSOFT)
  export LAMHF77
  NLSPATH      = $(NLSABSOFT)
  FC           = mpif77
  FDEBUG       = -O -en  # -C
  FMISC        = -YEXT_NAMES=LCS -s -YCFRL=1 -trap=DIVBYZERO,OVERFLOW
  FFLAGS       = $(FDEBUG) $(FMISC) $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  CFLAGS_MODEL = -Wall -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm -lc ${CL1MP_LIB} ${HDF5_LIBS} $(LIBABSOFT) -ldl
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_ABSOFT_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  LAMHF77      = $(FABSOFT)
  export LAMHF77
#  LAMHCC      = g++
#  export LAMHCC
  NLSPATH      = $(NLSABSOFT)
  FC           = mpif77
  FDEBUG       = -g -en # -Rb -Rc -Rp -Rs # range checking
  FMISC        = -YEXT_NAMES=LCS -s -YCFRL=1 -trap=DIVBYZERO,OVERFLOW
  FFLAGS       = $(FDEBUG) $(FMISC) $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -ansi -g $(DEFINES) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) $(LAM_INCLUDES)# -Wconversion 
  CFLAGS_MODEL = -Wall  -ansi -g $(DEFINES) $(HDF5_INCLUDES)# -Wconversion 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = -lm -lc ${CL1MP_LIB} ${HDF5_LIBS} $(LIBABSOFT) -ldl # ${EFENCE_LIB} -lefence
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_LAHEY)
  DEFINES      = $(DEFINE_HDF) -DLAHEY_F95 -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FLAHEY)
  FFLAGS       = -O $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  CFLAGS_MODEL = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS) $(LAHEY_RUNTIME)
  LD_FLAGS     = -lm  ${CL1MP_LIB} ${HDF5_LIBS} $(LIBLAHEY)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_LAHEY_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DLAHEY_F95 -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FLAHEY)
  FFLAGS       = -g --f95 --chkglobal --warn --info $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall  -g $(DEFINES)  $(PHREEQC_INCLUDES) 
  CFLAGS_MODEL = -Wall  -g $(DEFINES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS) $(LAHEY_RUNTIME)
  LD_FLAGS     = -lm -lgcc_s ${CL1MP_LIB} ${HDF5_LIBS} $(LIBLAHEY)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_LAHEY)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DLAHEY_F95 -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  LAMHF77      = $(FLAHEY)
  export LAMHF77
  FC           = mpif77
  FFLAGS       = -O $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES) 
  CFLAGS_MODEL = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS) $(LAHEY_RUNTIME)
  LD_FLAGS     = -lm -lgcc_s ${CL1MP_LIB} ${HDF5_LIBS} $(LIBLAHEY) -ldl
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_LAHEY_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DLAHEY_F95 -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  LAMHF77      = $(FLAHEY)
  export LAMHF77
  FC           = mpif77
  FFLAGS       = -g --chkglobal --warn --info $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES) 
  CFLAGS_MODEL = -Wall  -g $(DEFINES) $(HDF5_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS) $(LAHEY_RUNTIME)
  LD_FLAGS     = -lm -lgcc_s ${CL1MP_LIB} ${HDF5_LIBS} $(LIBLAHEY) -ldl
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_G95)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FG95)
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CC           = g++
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  CFLAGS_MODEL = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBG95) -lm ${CL1MP_LIB} ${HDF5_LIBS} 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_G95_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FG95)
  FFLAGS       = -g -fno-underscoring $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall  -g $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  CFLAGS_MODEL = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS)  $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBG95) -lm ${CL1MP_LIB} ${HDF5_LIBS} 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_G95)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  LAMHF77      = $(FG95)
  export LAMHF77
  FC           = mpif77
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  CFLAGS_MODEL = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBG95) -lm ${CL1MP_LIB} ${HDF5_LIBS} -ldl
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_G95_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  LAMHF77      = $(FG95)
  export LAMHF77
  FC           = mpif77
  FFLAGS       = -g  -fno-underscoring $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  CFLAGS_MODEL = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBG95) -lm ${CL1MP_LIB} ${HDF5_LIBS}  -ldl
endif
# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FGFORTRAN)
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CC           = g++
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  CFLAGS_MODEL = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) -lm ${CL1MP_LIB} ${HDF5_LIBS} 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FGFORTRAN)
  FFLAGS       = -g -fno-underscoring $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall  -g $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  CFLAGS_MODEL = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS)  $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) -lm ${CL1MP_LIB} ${HDF5_LIBS} 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN_64)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FGFORTRAN)
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CC           = g++
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  CFLAGS_MODEL = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) -lm ${CL1MP_LIB} ${HDF5_LIBS_64} 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  FC           = $(FGFORTRAN)
  FFLAGS       = -g -fno-underscoring $(DEFINES)
  CC           = g++
  CFLAGS       = -Wall  -g $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  CFLAGS_MODEL = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS)  $(HDF_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) -lm ${CL1MP_LIB} ${HDF5_LIBS_64} 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  LAMHF77      = $(FGFORTRAN)
  export LAMHF77
  FC           = mpif77
  FFLAGS       = -O3 $(DEFINES) -fno-underscoring
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  CFLAGS_MODEL = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) -lm ${CL1MP_LIB} ${HDF5_LIBS} -ldl
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), MPI_GFORTRAN_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  LAMHF77      = $(FGFORTRAN)
  export LAMHF77
  FC           = mpif77
  FFLAGS       = -g  -fno-underscoring $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) $(LAM_INCLUDES)
  CFLAGS_MODEL = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) -lm ${CL1MP_LIB} ${HDF5_LIBS}  -ldl
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  DINVERSE_CL1MP=
  FC           = mpif90
  FFLAGS       = -O3 -fno-underscoring -I.. -I. $(DEFINES)
  CXX          = mpicxx
  CC           = mpicxx
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  CFLAGS_MODEL = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) # $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) ${HDF5_LIBS}  -ldl # -lm ${CL1MP_LIB}
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_GFORTRAN_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  DINVERSE_CL1MP=
  FC           = mpif90
  FFLAGS       = -g  -fno-underscoring $(DEFINES)
  CXX          = mpicxx
  CC           = mpicxx
  CFLAGS       = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  CFLAGS_MODEL = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) # $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) ${HDF5_LIBS}  -ldl # -lm ${CL1MP_LIB}
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), OPENMPI_GFORTRAN_64)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DNDEBUG -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  HDF5_ROOT=/usr
  HDF5_INCLUDES=-I$(HDF5_ROOT)/include 
  DINVERSE_CL1MP=
  FC           = mpif90
  FFLAGS       = -O3 -fno-underscoring $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  CFLAGS_MODEL = -Wall  -O3 $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) # $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) ${HDF5_LIBS_64}  -ldl # -lm ${CL1MP_LIB}
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), OPENMPI_GFORTRAN_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) $(DEFINE_MERGE) -DPHREEQC_CPP
  VPATH        = ..:../phreeqcpp:../phreeqcpp/phreeqc
  HDF5_ROOT    =/usr
  HDF5_INCLUDES=-I$(HDF5_ROOT)/include 
  DINVERSE_CL1MP=
  FC           = mpif90
  FFLAGS       = -g  -fno-underscoring $(DEFINES)
  CXX          = mpiCC
  CC           = mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  CFLAGS_MODEL = -Wall  -g $(DEFINES) $(HDF5_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) $(MERGE_OBJS) # $(CL1MP_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) ${HDF5_LIBS_64}  -ldl 
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
		pitzer.o pitzer_structures.o dw.o \
		hst.o cxxHstSubs.o hstsubs.o mix.o phast_files.o 

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

COMMON_CXXOBJS = \
	       Dictionary.o \
	       Exchange.o \
	       ExchComp.o \
	       GasPhase.o \
	       ISolution.o \
	       ISolutionComp.o \
	       KineticsComp.o \
	       cxxKinetics.o \
	       cxxMix.o \
	       NameDouble.o \
	       NumKeyword.o \
	       Parser.o \
	       PPassemblageComp.o \
	       PPassemblage.o \
	       Reaction.o \
	       ReadClass.o \
	       Solution.o \
	       SolutionIsotope.o \
	       SolutionIsotopeList.o \
	       SSassemblage.o \
	       SSassemblageSS.o \
               StorageBin.o \
	       Surface.o \
	       SurfaceCharge.o \
	       SurfaceComp.o \
	       Temperature.o \
	       Utils.o 

HDF_OBJS     =  hdf.o hdf_f.o

MERGE_OBJS   =	merge.o

MPI_OBJS     =	mpimod.o phast_slave.o slavesubs.o

# -----------------------------------------------------------------------------
#  Assign dependents to target on dependency line & link options on command 
#  line. Command line is initiated with a tab. ($@ is an internal macro for 
#  the current target.) 

${PROGRAM} : ${OBJECT_FILES}
#	${FC} -o $@ ${OBJECT_FILES} ${LD_LIB1} ${LD_FLAGS} 
	${CXX} -o $@ ${OBJECT_FILES} ${LD_LIB1} ${LD_FLAGS} 
	@echo; echo Done making for phast
# -----------------------------------------------------------------------------
#  SPECIAL TARGET for compiling files containing modules so that
#  module_name.mod and module_name.o files are created or
#  updated before all other source code object files. 

modules.o : modules.f90 
	${FC} -c ${FFLAGS} $<
print_control_mod.o : ../print_control_mod.f90 modules.o
	${FC} -c ${FFLAGS} $<

# -----------------------------------------------------------------------------
# Module dependency list
# -----------------------------------------------------------------------------
#
#  PHAST Fortran files
#
phast.o:	  	../phast.F90	modules.o  mpimod.o
abmult.o:		../abmult.f90	modules.o
aplbce.o:		../aplbce.f90	modules.o
aplbce_ss_flow.o:	../aplbce_ss_flow.f90  modules.o
aplbci.o:		../aplbci.f90	modules.o
armult.o:		../armult.f90	modules.o
asembl.o:		../asembl.f90	modules.o
asmslc.o:		../asmslc.f90	modules.o
asmslp.o:		../asmslp.f90	modules.o
asmslp_ss_flow.o:	../asmslp_ss_flow.f90  modules.o
bsode.o:		../bsode.f90	modules.o
calcc.o:		../calcc.f90	modules.o
calc_velocity.o:	../calc_velocity.f90  modules.o
clog.o:			../clog.f90		modules.o
closef.o:		../closef.F90	modules.o	mpimod.o
coeff.o:		../coeff.f90	modules.o
coeff_ss_flow.o:	../coeff_ss_flow.f90  modules.o
crsdsp.o:		../crsdsp.f90	modules.o
d4ord.o:		../d4ord.f90	modules.o
d4zord.o:		../d4zord.f90	modules.o
dbmult.o:		../dbmult.f90	modules.o
dump.o:			../dump.f90		modules.o
efact.o:		../efact.f90	modules.o
ehoftp.o:		../ehoftp.f90	modules.o
el1slv.o:		../el1slv.f90	modules.o
elslv.o:		../elslv.f90	modules.o
error1.o:		../error1.f90	modules.o
error2.o:		../error2.f90	modules.o
error3.o:		../error3.f90	modules.o    print_control_mod.o
error4.o:		../error4.f90	modules.o	ifwr.inc
errprt.o:		../errprt.f90	modules.o
etom1.o:		../etom1.f90	modules.o
etom2.o:		../etom2.f90	modules.o
euslv.o:		../euslv.f90	modules.o
formr.o:		../formr.f90	modules.o
gcgris.o:		../gcgris.f90	modules.o	print_control_mod.o
hdf_f.o:		../hdf_f.f90	modules.o	print_control_mod.o
hunt.o:			../hunt.f90		modules.o
incidx.o:		../incidx.f90	modules.o
indx_rewi.o:		../indx_rewi.f90	modules.o
indx_rewi_bc.o:		../indx_rewi_bc.f90	modules.o
init1.o:		../init1.f90	modules.o
init2_1.o:		../init2_1.f90	modules.o
init2_2.o:		../init2_2.f90	modules.o
init2_3.o:		../init2_3.f90	modules.o
init2_post_ss.o:	../init2_post_ss.f90  modules.o
init3.o:		../init3.f90	modules.o    print_control_mod.o
interp.o:		../interp.f90	modules.o
irewi.o:		../irewi.f90	modules.o
ldchar.o:		../ldchar.f90	modules.o
ldci.o:			../ldci.f90		modules.o
ldcir.o:		../ldcir.f90	modules.o
ldind.o:		../ldind.f90	modules.o
ldipen.o:		../ldipen.f90	modules.o
ldmar1.o:		../ldmar1.f90	modules.o
load_indx_bc.o:		../load_indx_bc.f90   modules.o
lsolv.o:		../lsolv.f90	modules.o
nintrp.o:		../nintrp.f90	modules.o
openf.o:		../openf.F90	modules.o    mpimod.o
phast_root.o:		../phast_root.F90	modules.o    mpimod.o    print_control_mod.o
phast_slave.o:		../phast_slave.F90	modules.o    mpimod.o    print_control_mod.o
prchar.o:		../prchar.f90	modules.o
prntar.o:		../prntar.f90	modules.o
rbord.o:		../rbord.f90	modules.o
read1.o:		../read1.f90	modules.o
read2.o:		../read2.f90	modules.o    ifrd.inc
read3.o:		../read3.f90	modules.o    print_control_mod.o
reordr.o:		../reordr.f90	modules.o
rewi.o:			../rewi.f90		modules.o
rewi3.o:		../rewi3.f90	modules.o
rfact.o:		../rfact.f90	modules.o
rfactm.o:		../rfactm.f90	modules.o
rhsn.o:			../rhsn.f90		modules.o
rhsn_ss_flow.o:		../rhsn_ss_flow.f90	modules.o
sbcflo.o:		../sbcflo.f90	modules.o
scale_jds.o:		../scale_jds.f90	modules.o
simulate_ss_flow.o:	../simulate_ss_flow.f90  modules.o
sumcal1.o:		../sumcal1.f90	modules.o
sumcal2.o:		../sumcal2.f90	modules.o
sumcal_ss_flow.o:	../sumcal_ss_flow.f90  modules.o
terminate_phast.o:	../terminate_phast.F90  modules.o	mpimod.o
tfrds.o:		../tfrds.f90	modules.o
timstp.o:		../timstp.f90	modules.o	print_control_mod.o
timstp_ss_flow.o:	../timstp_ss_flow.f90  modules.o	print_control_mod.o
update_print_flags.o:	../update_print_flags.f90  modules.o    print_control_mod.o
usolv.o:		../usolv.f90	modules.o
viscos.o:		../viscos.f90	modules.o
wbbal.o:		../wbbal.f90	modules.o
wbcflo.o:		../wbcflo.f90	modules.o
wellsc.o:		../wellsc.f90	modules.o
wellsc_ss_flow.o:	../wellsc_ss_flow.f90  modules.o
wellsr.o:		../wellsr.f90	modules.o
wellsr_ss_flow.o:	../wellsr_ss_flow.f90  modules.o
welris.o:		../welris.f90	modules.o
wfdydz.o:		../wfdydz.f90	modules.o
write1.o:		../write1.f90	modules.o
write2_1.o:		../write2_1.f90	modules.o	ifwr.inc
write2_2.o:		../write2_2.f90	modules.o	ifwr.inc
write3.o:		../write3.f90	modules.o	ifwr.inc
write3_ss_flow.o:	../write3_ss_flow.f90  modules.o	ifwr.inc
write4.o:		../write4.f90	modules.o	ifwr.inc	print_control_mod.o
write5.o:		../write5.f90	modules.o	ifwr.inc	print_control_mod.o
write5_ss_flow.o:	../write5_ss_flow.f90  modules.o	ifwr.inc	print_control_mod.o
write6.o:		../write6.f90	modules.o	ifwr.inc	print_control_mod.o
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
	${CC} $(SRC)/model.c ${CFLAGS_MODEL} -c -o model.o
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
merge.o: merge.c global.h phqalloc.h hst.h output.h phastproto.h
mix.o: mix.c global.h hst.h phqalloc.h output.h phastproto.h
phast_files.o: phast_files.c global.h phqalloc.h output.h phrqproto.h input.h
slavesubs.o: slavesubs.c global.h hst.h phqalloc.h output.h phastproto.h
hst.o: ../hst.cxx ../phreeqcpp/StorageBin.h ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Solution.h ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/SolutionIsotopeList.h ../phreeqcpp/SolutionIsotope.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/cxxMix.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Exchange.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/ExchComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/GasPhase.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/cxxKinetics.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/KineticsComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/PPassemblage.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/PPassemblageComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SSassemblage.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SSassemblageSS.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Surface.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SurfaceComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SurfaceCharge.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/cxxMix.h ../phreeqcpp/Reaction.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Temperature.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/output.h ../hst.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h ../phreeqcpp/phreeqc/input.h \
  ../phast_files.h ../phastproto.h ../phreeqcpp/Dictionary.h \
  ../phreeqcpp/Solution.h ../phreeqcpp/NameDouble.h
cxxHstSubs.o: ../cxxHstSubs.cxx ../phreeqcpp/StorageBin.h \
  ../phreeqcpp/Utils.h ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Solution.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/SolutionIsotopeList.h ../phreeqcpp/SolutionIsotope.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/cxxMix.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Exchange.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/ExchComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/GasPhase.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/cxxKinetics.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/KineticsComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/PPassemblage.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/PPassemblageComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SSassemblage.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SSassemblageSS.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Surface.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SurfaceComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SurfaceCharge.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/cxxMix.h ../phreeqcpp/Reaction.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Temperature.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Solution.h \
  ../phreeqcpp/phreeqc/output.h ../hst.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h ../phastproto.h
cxxKinetics.o: ../phreeqcpp/cxxKinetics.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/cxxKinetics.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/KineticsComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/KineticsComp.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h
cxxMix.o: ../phreeqcpp/cxxMix.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/cxxMix.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h
Dictionary.o: ../phreeqcpp/Dictionary.cxx ../phreeqcpp/Dictionary.h \
  ../phreeqcpp/Solution.h ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SolutionIsotopeList.h \
  ../phreeqcpp/SolutionIsotope.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/phreeqc/global.h ../phreeqcpp/phreeqc/phrqtype.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/cxxMix.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h ../phreeqcpp/phreeqc/output.h
Exchange.o: ../phreeqcpp/Exchange.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Exchange.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/ExchComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/ExchComp.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h
ExchComp.o: ../phreeqcpp/ExchComp.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/ExchComp.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h \
  ../phreeqcpp/phreeqc/output.h
GasPhase.o: ../phreeqcpp/GasPhase.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/GasPhase.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/phreeqc/global.h ../phreeqcpp/phreeqc/phrqtype.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h
ISolutionComp.o: ../phreeqcpp/ISolutionComp.cxx \
  ../phreeqcpp/ISolutionComp.h ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/ISolution.h ../phreeqcpp/ISolutionComp.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Solution.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/SolutionIsotopeList.h \
  ../phreeqcpp/SolutionIsotope.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/phreeqc/global.h ../phreeqcpp/phreeqc/phrqtype.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/cxxMix.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h ../phreeqcpp/Utils.h \
  ../phreeqcpp/phreeqc/phrqproto.h ../phreeqcpp/phreeqc/phqalloc.h
ISolution.o: ../phreeqcpp/ISolution.cxx ../phreeqcpp/ISolution.h \
  ../phreeqcpp/ISolutionComp.h ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Solution.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/SolutionIsotopeList.h \
  ../phreeqcpp/SolutionIsotope.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/phreeqc/global.h ../phreeqcpp/phreeqc/phrqtype.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/cxxMix.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h
KineticsComp.o: ../phreeqcpp/KineticsComp.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/KineticsComp.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h
NameDouble.o: ../phreeqcpp/NameDouble.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/phreeqc/global.h ../phreeqcpp/phreeqc/phrqtype.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/output.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h
NumKeyword.o: ../phreeqcpp/NumKeyword.cxx ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h
Parser.o: ../phreeqcpp/Parser.cxx ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Utils.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/char_star.h
PPassemblageComp.o: ../phreeqcpp/PPassemblageComp.cxx \
  ../phreeqcpp/Utils.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/PPassemblageComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/phreeqc/global.h ../phreeqcpp/phreeqc/phrqtype.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h
PPassemblage.o: ../phreeqcpp/PPassemblage.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/PPassemblage.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/PPassemblageComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/PPassemblageComp.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h
Reaction.o: ../phreeqcpp/Reaction.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Reaction.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/phreeqc/global.h ../phreeqcpp/phreeqc/phrqtype.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h
ReadClass.o: ../phreeqcpp/ReadClass.cxx ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Solution.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/SolutionIsotopeList.h ../phreeqcpp/SolutionIsotope.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/cxxMix.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Exchange.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/ExchComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Surface.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SurfaceComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SurfaceCharge.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/PPassemblage.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/PPassemblageComp.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/cxxKinetics.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/KineticsComp.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SSassemblage.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SSassemblageSS.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/GasPhase.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Reaction.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/cxxMix.h ../phreeqcpp/Temperature.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/output.h \
  ../phreeqcpp/phreeqc/phrqproto.h
Solution.o: ../phreeqcpp/Solution.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Solution.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SolutionIsotopeList.h \
  ../phreeqcpp/SolutionIsotope.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/phreeqc/global.h ../phreeqcpp/phreeqc/phrqtype.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/cxxMix.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h \
  ../phreeqcpp/phreeqc/output.h ../phreeqcpp/ISolution.h \
  ../phreeqcpp/ISolutionComp.h ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/Solution.h ../phreeqcpp/Exchange.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/ExchComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Surface.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SurfaceComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SurfaceCharge.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/PPassemblage.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/PPassemblageComp.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/cxxKinetics.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/KineticsComp.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SSassemblage.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SSassemblageSS.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/GasPhase.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Reaction.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Temperature.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/StorageBin.h ../phreeqcpp/Utils.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/Solution.h ../phreeqcpp/Exchange.h \
  ../phreeqcpp/GasPhase.h ../phreeqcpp/cxxKinetics.h \
  ../phreeqcpp/PPassemblage.h ../phreeqcpp/SSassemblage.h \
  ../phreeqcpp/Surface.h ../phreeqcpp/cxxMix.h ../phreeqcpp/Reaction.h \
  ../phreeqcpp/Temperature.h ../phreeqcpp/NumKeyword.h
SolutionIsotope.o: ../phreeqcpp/SolutionIsotope.cxx \
  ../phreeqcpp/SolutionIsotope.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Utils.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h
SolutionIsotopeList.o: ../phreeqcpp/SolutionIsotopeList.cxx \
  ../phreeqcpp/Utils.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SolutionIsotopeList.h ../phreeqcpp/SolutionIsotope.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/global.h ../phreeqcpp/phreeqc/phrqtype.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h
SSassemblage.o: ../phreeqcpp/SSassemblage.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SSassemblage.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SSassemblageSS.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SSassemblageSS.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h
SSassemblageSS.o: ../phreeqcpp/SSassemblageSS.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SSassemblageSS.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h
StorageBin.o: ../phreeqcpp/StorageBin.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/StorageBin.h ../phreeqcpp/Utils.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h ../phreeqcpp/Solution.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/SolutionIsotopeList.h ../phreeqcpp/SolutionIsotope.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/cxxMix.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Exchange.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/ExchComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/GasPhase.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/cxxKinetics.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/KineticsComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/PPassemblage.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/PPassemblageComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SSassemblage.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SSassemblageSS.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Surface.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SurfaceComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SurfaceCharge.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/cxxMix.h ../phreeqcpp/Reaction.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Temperature.h ../phreeqcpp/NumKeyword.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Solution.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h \
  ../phreeqcpp/phreeqc/output.h
SurfaceCharge.o: ../phreeqcpp/SurfaceCharge.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SurfaceCharge.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/output.h ../phreeqcpp/phreeqc/phqalloc.h \
  ../phreeqcpp/phreeqc/phrqproto.h
SurfaceComp.o: ../phreeqcpp/SurfaceComp.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SurfaceComp.h \
  ../phreeqcpp/NameDouble.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h \
  ../phreeqcpp/phreeqc/output.h
Surface.o: ../phreeqcpp/Surface.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Surface.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SurfaceComp.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/SurfaceCharge.h ../phreeqcpp/NameDouble.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/SurfaceComp.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h
Temperature.o: ../phreeqcpp/Temperature.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Temperature.h \
  ../phreeqcpp/NumKeyword.h ../phreeqcpp/Parser.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/phreeqc/global.h \
  ../phreeqcpp/phreeqc/phrqtype.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/phqalloc.h ../phreeqcpp/phreeqc/phrqproto.h
Utils.o: ../phreeqcpp/Utils.cxx ../phreeqcpp/Utils.h \
  ../phreeqcpp/char_star.h ../phreeqcpp/Parser.h ../phreeqcpp/char_star.h \
  ../phreeqcpp/phreeqc/output.h
# -----------------------------------------------------------------------------

clean:
	rm -rf serial_absoft serial_absoft_debug mpi_absoft mpi_absoft_debug serial_lahey serial_lahey_debug mpi_lahey mpi_lahey_debug serial_g95 serial_g95_debug mpi_g95 mpi_g95_debug serial_gfortran serial_gfortran_debug mpi_gfortran mpi_gfortran_debug openmpi_gfortran openmpi_gfortran_debug serial_gfortran_64 serial_gfortran_64_debug openmpi_gfortran_64 openmpi_gfortran_64_debug

dependencies:
	mkdir -p $(SERIAL_ABSOFT_DIR) 
	cd $(SERIAL_ABSOFT_DIR); gcc -MM -I../phreeqcpp -I../phreeqcpp/phreeqc ../*.cxx ../phreeqcpp/*.cxx

# =============================================================================
# End of makefile.
# =============================================================================
