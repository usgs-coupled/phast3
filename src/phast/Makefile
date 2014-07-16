# Makefile for PHAST
#
# Generates object files and executables for 8 versions of PHAST
#	    Gfortran/Intel
#           Serial/MPI version
#           Optimize/Debug
#
# Makefile sets CFG variable, cd's to appropriate directory, runs Makefile recursively
# Recursive make sets appropriate compiler, objects, options, libraries, and compiles PHAST
#

PROGRAM = phast

all: gfortran 

SERIAL_GFORTRAN_DIR           = serial_gfortran
SERIAL_GFORTRAN_DEBUG_DIR     = serial_gfortran_debug
OPENMPI_GFORTRAN_DIR          = openmpi_gfortran
OPENMPI_GFORTRAN_DEBUG_DIR    = openmpi_gfortran_debug

SERIAL_GFORTRAN_64_DIR        = serial_gfortran_64
SERIAL_GFORTRAN_64_DEBUG_DIR  = serial_gfortran_64_debug
OPENMPI_GFORTRAN_64_DIR       = openmpi_gfortran_64
OPENMPI_GFORTRAN_64_DEBUG_DIR = openmpi_gfortran_64_debug

SERIAL_INTEL_DIR              = serial_intel
SERIAL_INTEL_DEBUG_DIR        = serial_intel_debug
OPENMPI_INTEL_DIR             = openmpi_intel
OPENMPI_INTEL_DEBUG_DIR       = openmpi_intel_debug

SERIAL_INTEL_64_DIR           = serial_intel_64
SERIAL_INTEL_64_DEBUG_DIR     = serial_intel_64_debug
OPENMPI_INTEL_64_DIR          = openmpi_intel_64
OPENMPI_INTEL_64_DEBUG_DIR    = openmpi_intel_64_debug

MPICH_GFORTRAN_DIR            = mpich_gfortran

mpich: mpich_gfortran

gfortran:    serial_gfortran    serial_gfortran_debug    openmpi_gfortran    openmpi_gfotran_debug
gfortran_64: serial_gfortran_64 serial_gfortran_64_debug openmpi_gfortran_64 openmpi_gfotran_64_debug
intel:       serial_intel       serial_intel_debug       openmpi_intel       openmpi_intel_debug
intel_64:    serial_intel_64    serial_intel_64_debug    openmpi_intel_64    openmpi_intel_64_debug


MAKEFILE                = Makefile

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

.PHONY : openmpi_gfortran
openmpi_gfortran:
	mkdir -p $(OPENMPI_GFORTRAN_DIR);
	cd $(OPENMPI_GFORTRAN_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN $(PROGRAM)
#	ssh $(OPENMPI_COMPUTER) "cd programs/phastpp/srcphast; cd $(OPENMPI_GFORTRAN_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN $(PROGRAM)"

.PHONY : openmpi_gfortran_debug
openmpi_gfortran_debug:
	mkdir -p $(OPENMPI_GFORTRAN_DEBUG_DIR);
	cd $(OPENMPI_GFORTRAN_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN_DEBUG $(PROGRAM)
#	ssh $(OPENMPI_COMPUTER) "cd programs/phastpp/srcphast; cd $(OPENMPI_GFORTRAN_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN_DEBUG $(PROGRAM)"

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

.PHONY : openmpi_gfortran_64
openmpi_gfortran_64:
	mkdir -p $(OPENMPI_GFORTRAN_64_DIR);
	cd $(OPENMPI_GFORTRAN_64_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN_64 $(PROGRAM)

.PHONY : openmpi_gfortran_64_debug
openmpi_gfortran_64_debug:
	mkdir -p $(OPENMPI_GFORTRAN_64_DEBUG_DIR);
	cd $(OPENMPI_GFORTRAN_64_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_GFORTRAN_64_DEBUG $(PROGRAM)

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

.PHONY : openmpi_intel
openmpi_intel:
	mkdir -p $(OPENMPI_INTEL_DIR) 
	cd $(OPENMPI_INTEL_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_INTEL $(PROGRAM)

.PHONY : openmpi_intel_debug
openmpi_intel_debug:
	mkdir -p $(OPENMPI_INTEL_DEBUG_DIR) 
	cd $(OPENMPI_INTEL_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_INTEL_DEBUG $(PROGRAM)

#########################
####    intel_64     ####
#########################

.PHONY : serial_intel_64
serial_intel_64:
	mkdir -p $(SERIAL_INTEL_64_DIR)
	cd $(SERIAL_INTEL_64_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_INTEL_64 $(PROGRAM)

.PHONY : serial_intel_64_debug
serial_intel_64_debug:
	mkdir -p $(SERIAL_INTEL_64_DEBUG_DIR);
	cd $(SERIAL_INTEL_64_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=SERIAL_INTEL_64_DEBUG $(PROGRAM)

.PHONY : openmpi_intel_64
openmpi_intel_64:
	mkdir -p $(OPENMPI_INTEL_64_DIR) 
	cd $(OPENMPI_INTEL_64_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_INTEL_64 $(PROGRAM)

.PHONY : openmpi_intel_64_debug
openmpi_intel_64_debug:
	mkdir -p $(OPENMPI_INTEL_64_DEBUG_DIR) 
	cd $(OPENMPI_INTEL_64_DEBUG_DIR); $(MAKE) -r -f ../$(MAKEFILE) CFG=OPENMPI_INTEL_64_DEBUG $(PROGRAM)

# Recursive make begins here
#
# =============================================================================
# Significant suffixes [assuming Fortran 90 (.f90)  source code]:
# Significant suffixes [assuming Fortran 90 (.F90)  source code, needs to be preprocessed ]:
# =============================================================================

SRC              = ../IPHreeqcPhast/IPhreeqc/phreeqcpp/phreeqc
PHREEQC_INCLUDES = -I.. -I../PhreeqcRM -I../IPhreeqcPhast -I../IPhreeqcPhast/IPhreeqc -I../IPhreeqcPhast/IPhreeqc/phreeqcpp 
PHREEQC_VPATH    = ..:../PhastFortran:../PhreeqcRM:../IPhreeqcPhast:../IPhreeqcPhast/IPhreeqc:../IPhreeqcPhast/IPhreeqc/phreeqcpp:../KDtree

.SUFFIXES : .o .f .F90 .f90 .c .cxx .cpp

# The following apply to GFortran versions
FGFORTRAN=     gfortran
LIBGFORTRAN=   -lgfortranbegin -Xlinker -Bstatic -lgfortran -Xlinker -Bdynamic
LIBGFORTRAN_64=-L/usr/lib64 -lgfortranbegin -Xlinker -Bstatic -lgfortran -Xlinker -Bdynamic

# The following apply to INTEL versions
FINTEL=ifort
IF_HOME=/opt/intel/Compiler/11.0/083/lib
IFORT_LIB=-Xlinker -Bstatic -L$(IF_HOME)/ia32/ -lifport -lifcore -limf -lsvml -lm -lipgo -lirc -lirc_s -Xlinker -Bdynamic -lpthread -ldl
IFORT_LIB_64=-Xlinker -Bstatic -L$(IF_HOME)/intel64/ -lifport -lifcore -limf -lsvml -lm -lipgo -lirc -lirc_s -Xlinker -Bdynamic -lpthread -ldl 

# The following apply to OpenMPI versions
OPENMPI_GFORTRAN_32=/usr/lib/openmpi
OPENMPI_IFORT_32=/raid/home/charlton/openmpi-1.5.4/lobo07-ifort-static
OPENMPI_GFORTRAN_64=/usr/lib64/openmpi
OPENMPI_IFORT_64=/raid/home/charlton/openmpi-1.5.4/lobo02-ifort-x64-static

# -----------------------------------------------------------------------------
.f.o :
	${FC} -c ${FFLAGS} $<
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
#hdf options
ifeq ($(HOSTNAME), arc1.cr.usgs.gov)
  HDF5_LIBS_64=${HDF5_ROOT}/lib64/openmpi/lib/libhdf5.a -Xlinker -lz -lpthread 
endif

# -----------------------------------------------------------------------------
DEFINE_HDF=-DHDF5_CREATE -DH5Dcreate_vers=1 -DH5Gcreate_vers=1 -DH5Eset_auto_vers=1
DEFINE_MPI=-DUSE_MPI

# -----------------------------------------------------------------------------
#efence for debugging
EFENCE_LIB=-L$(HOME)/packages/efence

# -----------------------------------------------------------------------------
# fixes shared object lookup error(SIGFPE floating point exception)
HASH_STYLE=$(call ld-option, -Wl$(comma)--hash-style=sysv)

# -----------------------------------------------------------------------------
# Versions
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DHAVE_ISFINITE -DUSE_OPENMP -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(FGFORTRAN)
  FFLAGS       = -p -O3 -frecursive -fopenmp -fno-underscoring -fopenmp $(DEFINES) 
  CC           = g++
  CFLAGS       = -Wall -fopenmp -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) -lgomp -lm ${HDF5_LIBS} ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC -DUSE_OPENMP -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(FGFORTRAN)
  FFLAGS       = -g -frecursive -fopenmp -fno-underscoring $(DEFINES) 
  CC           = g++
  CFLAGS       = -Wall -g -fopenmp $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS)  $(HDF_OBJS) 
  LD_FLAGS     = $(LIBGFORTRAN) -lgomp -lm ${HDF5_LIBS} ${HASH_STYLE}
  LINKER       = $(CXX) 
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN_64)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DHAVE_ISFINITE -DUSE_OPENMP -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(FGFORTRAN)
  FFLAGS       = -g -O3 -frecursive -fopenmp -fno-underscoring -cpp $(DEFINES) 
  CC           = g++
  CFLAGS       = -Wall -fopenmp -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(HDF_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) -lgomp -lm ${HASH_STYLE} ${HDF5_LIBS_64}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_GFORTRAN_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC -DUSE_OPENMP -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(FGFORTRAN)
  FFLAGS       = -g -frecursive -fopenmp -fno-underscoring -cpp $(DEFINES) $(PHREEQC_INCLUDES)
  CC           = g++
  CFLAGS       = -Wall -fopenmp -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES)
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS)  $(HDF_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) -fopenmp -lm ${HDF5_LIBS_64} ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) -DNDEBUG -DHAVE_ISFINITE  -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(OPENMPI_GFORTRAN_32)/bin/mpif90
  FFLAGS       = -O3 -fno-underscoring $(DEFINES)
  CXX          = $(OPENMPI_GFORTRAN_32)/bin/mpiCC
  CC           = $(OPENMPI_GFORTRAN_32)/bin/mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) 
  LD_FLAGS     = $(LIBGFORTRAN) ${HDF5_LIBS} -lmpi_f77 -ldl ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_GFORTRAN_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(OPENMPI_GFORTRAN_32)/bin/mpif90
  FFLAGS       = -g  -fno-underscoring $(DEFINES)
  CXX          = $(OPENMPI_GFORTRAN_32)/bin/mpiCC
  CC           = $(OPENMPI_GFORTRAN_32)/bin/mpiCC
  CFLAGS       = -Wall -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN) ${HDF5_LIBS} -lmpi_f77 -ldl ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), OPENMPI_GFORTRAN_64)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) -DNDEBUG -DHAVE_ISFINITE -DNO_UNDERSCORES -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(OPENMPI_GFORTRAN_64)/bin/mpif90
  FFLAGS       = -O3 -fno-underscoring -cpp $(DEFINES) 
  CXX          = $(OPENMPI_GFORTRAN_64)/bin/mpiCC
  CC           = $(OPENMPI_GFORTRAN_64)/bin/mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS)
  LD_FLAGS     = $(LIBGFORTRAN_64) ${HDF5_LIBS_64} -lmpi_f77 -ldl ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), OPENMPI_GFORTRAN_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC -DNO_UNDERSCORES -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(OPENMPI_GFORTRAN_64)/bin/mpif90
  FFLAGS       = -g -fno-underscoring $(DEFINES) 
  CXX          = $(OPENMPI_GFORTRAN_64)/bin/mpiCC
  CC           = $(OPENMPI_GFORTRAN_64)/bin/mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) 
  LD_FLAGS     = $(LIBGFORTRAN_64) ${HDF5_LIBS_64} -lmpi_f77 -ldl ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), SERIAL_INTEL)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DHAVE_ISFINITE -DUSE_OPENMP -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(FINTEL)
  FFLAGS       = -O3 -nus -openmp -recursive -reentrancy threaded $(DEFINES)
  CXX          = g++
  CFLAGS       = -Wall  -O3 -fopenmp $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS)
  LD_FLAGS     = ${IFORT_LIB}  -lgomp ${HDF5_LIBS} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_INTEL_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC -DUSE_OPENMP -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(FINTEL)
  FFLAGS       = -g -nus -openmp -recursive -reentrancy threaded $(DEFINES)
  CXX          = g++
  CFLAGS       = -Wall -g  -fopenmp $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES)  $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS)
  LD_FLAGS     = ${IFORT_LIB} -lgomp ${HDF5_LIBS} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_INTEL_64)
  DEFINES      = $(DEFINE_HDF) -DNDEBUG -DHAVE_ISFINITE -DUSE_OPENMP -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(FINTEL)
  FFLAGS       = -O3 -nus -openmp -recursive -reentrancy threaded -openmp-threadprivate compat $(DEFINES)
  CXX          = g++
  CFLAGS       = -Wall -O3 -fopenmp $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS) 
  LD_FLAGS     = ${IFORT_LIB_64} -lgomp -threads ${HDF5_LIBS_64} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), SERIAL_INTEL_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC -DUSE_OPENMP -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(FINTEL)
  FFLAGS       = -check bounds -check pointer -check arg_temp_created -g -nus -openmp -openmp-threadprivate compat -auto -recursive -reentrancy threaded $(DEFINES) #
  CXX          = g++
  CFLAGS       = -Wall -g -fopenmp $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS)  $(COMMON_CXXOBJS) $(HDF_OBJS)
  LD_FLAGS     = -g ${IFORT_LIB_64} -threads /z/loboraid/raid3/intel/Compiler/11.0/083/lib/intel64/libiomp5.a ${HDF5_LIBS_64} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_INTEL)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) -DNDEBUG -DHAVE_ISFINITE  -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(OPENMPI_IFORT_32)/bin/mpif90
  FFLAGS       = -g -nus $(DEFINES) -I$(OPENMPI_IFORT_32)/lib 
  CXX          = $(OPENMPI_IFORT_32)/bin/mpiCC
  CC           = $(OPENMPI_IFORT_32)/bin/mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS)
  LD_FLAGS     = ${IFORT_LIB} ${HDF5_LIBS} -lmpi_f77 ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_INTEL_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(OPENMPI_IFORT_32)/bin/mpif90
  FFLAGS       = -g -nus $(DEFINES) 
  CXX          = $(OPENMPI_IFORT_32)/bin/mpiCC
  CC           = $(OPENMPI_IFORT_32)/bin/mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS)
  LD_FLAGS     = ${IFORT_LIB} ${HDF5_LIBS} -lmpi_f77 ${HASH_STYLE}
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_INTEL_64)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) -DNDEBUG -DHAVE_ISFINITE  -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(OPENMPI_IFORT_64)/bin/mpif90
  FFLAGS       = -mcmodel=large -O3 -nus $(DEFINES)
  CXX          = $(OPENMPI_IFORT_64)/bin/mpiCC
  CC           = $(OPENMPI_IFORT_64)/bin/mpiCC
  CFLAGS       = -Wall  -O3 $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS)
  LD_FLAGS     = ${IFORT_LIB_64} ${HDF5_LIBS_64} -lmpi_f77 ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
ifeq ($(CFG), OPENMPI_INTEL_64_DEBUG)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) -DHAVE_ISFINITE -DUSE_PHRQ_ALLOC -I$(PHREEQC_INCLUDES)
  FC_FUNC      = -DFC_FUNC\(name,NAME\)=name -DFC_FUNC_\(name,NAME\)=name
  VPATH        = $(PHREEQC_VPATH)
  FC           = $(OPENMPI_IFORT_64)/bin/mpif90
  FFLAGS       = -mcmodel=large -g -nus $(DEFINES)
  CXX          = $(OPENMPI_IFORT_64)/bin/mpiCC
  CC           = $(OPENMPI_IFORT_64)/bin/mpiCC
  CFLAGS       = -Wall  -g $(DEFINES) $(FC_FUNC) $(HDF5_INCLUDES) $(PHREEQC_INCLUDES) 
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS)
  LD_FLAGS     = ${IFORT_LIB_64} ${HDF5_LIBS_64} -lmpi_f77 ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------

ifeq ($(CFG), MPICH_GFORTRAN)
  DEFINES      = $(DEFINE_HDF) $(DEFINE_MPI) -DNDEBUG -DHAVE_ISFINITE  -I$(PHREEQC_INCLUDES)
  VPATH        = $(PHREEQC_VPATH)
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
  OBJECT_FILES = $(COMMON_FOBJS) $(COMMON_COBJS) $(COMMON_CXXOBJS) $(MPI_OBJS) $(HDF_OBJS) 
  LD_FLAGS     = $(LIBGFORTRAN) ${HDF5_LIBS}  -ldl ${MPICH_LIB} ${HASH_STYLE} 
  LINKER       = $(CXX)
endif

# -----------------------------------------------------------------------------
# (d) Create expected object file list, with .o extension:     [TARGETS OF PRE-
#     REQUISITE (.f90,.f) SOURCE FILES]
#

COMMON_FOBJS =	\
	IPhreeqcF.o \
	aplbce_flow.o \
	aplbci_flow.o \
	asembl_flow.o \
	asmslp_flow.o \
	calcc.o \
	calc_velocity.o \
	clog.o \
	closef.o \
	coeff_flow.o \
	coeff_trans.o \
	create_mapping.o \
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
	rhsn_flow.o \
	rhsn_manager.o \
	rhsn_ss_flow.o \
	sbcflo.o \
	scale_jds_mod.o \
	set_component_map.o \
	simulate_ss_flow.o \
	solver_direct_mod.o \
	solver_iter_mod.o \
	stonb.o \
	sumcal0_manager.o \
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
PhreeqcRM.o \
RM_interface_F.o \
RM_interface_C.o \
hdf.o \
TM_interface.o \
FileHandler.o \
\
fwrap2Phast.o \
fwrap3Phast.o \
fwrap4Phast.o \
fwrap5Phast.o \
fwrap6Phast.o \
fwrap7Phast.o \
fwrap8Phast.o \
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
CSelectedOutput.o \
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
SelectedOutput.o \
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
UserPunch.o \
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

#MPI_OBJS     =	xfer_indices.o


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

module_dummy.o: ../PhastFortran/module_dummy.f90 mach_mod.o modules_g.o \
	modules_manager.o print_control_mod.o ld_seg_mod.o \
	interpolate_mod.o reorder_mod.o rewi_mod.o XP_module.o scale_jds_mod.o \
	solver_direct_mod.o solver_iter_mod.o
interpolate_mod.o: ../PhastFortran/interpolate_mod.f90 mach_mod.o modules_g.o
	${FC} -c ${FFLAGS} $<
ld_seg_mod.o:      ../PhastFortran/ld_seg_mod.f90 modules_g.o modules_manager.o
	${FC} -c ${FFLAGS} $<
mach_mod.o: ../PhastFortran/mach_mod.f90
	${FC} -c ${FFLAGS} $<
modules_g.o: ../PhastFortran/modules_g.f90 mach_mod.o modules_manager.o
	${FC} -c ${FFLAGS} $<
modules_manager.o: ../PhastFortran/modules_manager.f90 mach_mod.o
	${FC} -c ${FFLAGS} $<
print_control_mod.o: ../PhastFortran/print_control_mod.f90 mach_mod.o modules_g.o modules_manager.o
	${FC} -c ${FFLAGS} $<
mpi_mod.o: ../PhastFortran/mpi_mod.F90 modules_g.o
	${FC} -c ${FFLAGS} $<
reorder_mod.o: ../PhastFortran/reorder_mod.f90 modules_g.o
	${FC} -c ${FFLAGS} $<
rewi_mod.o: ../PhastFortran/rewi_mod.f90 mach_mod.o modules_g.o modules_manager.o interpolate_mod.o
	${FC} -c ${FFLAGS} $<
scale_jds_mod.o: ../PhastFortran/scale_jds_mod.f90 mach_mod.o 
	${FC} -c ${FFLAGS} $<
solver_direct_mod.o: ../PhastFortran/solver_direct_mod.f90 mach_mod.o modules_g.o XP_module.o
	${FC} -c ${FFLAGS} $<
solver_iter_mod.o: ../PhastFortran/solver_iter_mod.f90 mach_mod.o modules_g.o modules_manager.o XP_module.o
	${FC} -c ${FFLAGS} $<
XP_module.o: ../PhastFortran/XP_module.F90 mach_mod.o modules_g.o
	${FC} -c ${FFLAGS} $<

# -----------------------------------------------------------------------------
# Module dependency list
# -----------------------------------------------------------------------------
IPhreeqcF.o: ../IPhreeqcPhast/IPhreeqc/IPhreeqcF.f module_dummy.o
aplbce_flow.o: ../PhastFortran/aplbce_flow.f90 module_dummy.o
aplbci_flow.o: ../PhastFortran/aplbci_flow.F90 module_dummy.o
asembl_flow.o: ../PhastFortran/asembl_flow.f90 module_dummy.o
asmslp.o: ../PhastFortran/asmslp.F90 module_dummy.o
asmslp_flow.o: ../PhastFortran/asmslp_flow.F90 module_dummy.o
calcc.o: ../PhastFortran/calcc.f90 module_dummy.o
calc_velocity.o: ../PhastFortran/calc_velocity.f90 module_dummy.o
clog.o: ../PhastFortran/clog.f90 module_dummy.o
closef.o: ../PhastFortran/closef.F90 module_dummy.o
coeff_flow.o: ../PhastFortran/coeff_flow.F90 module_dummy.o
coeff_trans.o: ../PhastFortran/coeff_trans.F90 module_dummy.o
create_mapping.o: ../PhastFortran/create_mapping.f90 module_dummy.o
dealloc_arr.o: ../PhastFortran/dealloc_arr.F90 module_dummy.o
dealloc_arr_worker.o: ../PhastFortran/dealloc_arr_worker.F90 module_dummy.o
dump.o: ../PhastFortran/dump.f90 module_dummy.o
error1.o: ../PhastFortran/error1.f90 module_dummy.o
error2.o: ../PhastFortran/error2.f90 module_dummy.o
error3.o: ../PhastFortran/error3.f90 module_dummy.o
error4.o: ../PhastFortran/error4.f90 module_dummy.o
errprt.o: ../PhastFortran/errprt.f90 module_dummy.o
etom1.o: ../PhastFortran/etom1.f90 module_dummy.o
etom2.o: ../PhastFortran/etom2.f90 module_dummy.o
hdf_f.o: ../PhastFortran/hdf_f.F90 module_dummy.o
incidx.o: ../PhastFortran/incidx.f90 module_dummy.o
indx_rewi_bc.o: ../PhastFortran/indx_rewi_bc.f90 module_dummy.o
indx_rewi.o: ../PhastFortran/indx_rewi.f90 module_dummy.o
init1.o: ../PhastFortran/init1.F90 module_dummy.o
init2_1.o: ../PhastFortran/init2_1.F90 module_dummy.o
init2_1_xfer.o: ../PhastFortran/init2_1_xfer.F90 module_dummy.o
init2_2.o: ../PhastFortran/init2_2.f90 module_dummy.o
init2_3.o: ../PhastFortran/init2_3.f90 module_dummy.o
init2_post_ss.o: ../PhastFortran/init2_post_ss.F90 module_dummy.o
init3.o: ../PhastFortran/init3.F90 module_dummy.o
init3_xfer.o: ../PhastFortran/init3_xfer.F90 module_dummy.o
ldchar_bc.o: ../PhastFortran/ldchar_bc.f90 module_dummy.o
ldchar.o: ../PhastFortran/ldchar.f90 module_dummy.o
mtoijk.o: ../PhastFortran/mtoijk.f90 module_dummy.o
nintrp.o: ../PhastFortran/nintrp.f90 module_dummy.o
openf.o: ../PhastFortran/openf.F90 module_dummy.o
phast_manager.o: ../PhastFortran/phast_manager.F90 module_dummy.o
phast_spmd.o: ../PhastFortran/phast_spmd.F90 module_dummy.o
phast_worker.o: ../PhastFortran/phast_worker.F90 module_dummy.o
prchar.o: ../PhastFortran/prchar.f90 module_dummy.o
printar.o: ../PhastFortran/printar.f90 module_dummy.o
read1.o: ../PhastFortran/read1.F90 module_dummy.o
read1_xfer.o: ../PhastFortran/read1_xfer.F90 module_dummy.o
read2.o: ../PhastFortran/read2.F90 module_dummy.o
read2_xfer.o: ../PhastFortran/read2_xfer.F90 module_dummy.o
read3.o: ../PhastFortran/read3.F90 module_dummy.o
read3_xfer.o: ../PhastFortran/read3_xfer.F90 module_dummy.o
rhsn.o: ../PhastFortran/rhsn.f90 module_dummy.o
rhsn_flow.o: ../PhastFortran/rhsn_flow.f90 module_dummy.o
rhsn_manager.o: ../PhastFortran/rhsn_manager.F90 module_dummy.o
rhsn_ss_flow.o: ../PhastFortran/rhsn_ss_flow.f90 module_dummy.o
sbcflo.o: ../PhastFortran/sbcflo.f90 module_dummy.o
set_component_map.o: ../PhastFortran/set_component_map.F90 module_dummy.o
simulate_ss_flow.o: ../PhastFortran/simulate_ss_flow.f90 module_dummy.o
stonb.o: ../PhastFortran/stonb.f90 module_dummy.o
sumcal0_manager.o: ../PhastFortran/sumcal0_manager.F90 module_dummy.o
sumcal1.o: ../PhastFortran/sumcal1.F90 module_dummy.o
sumcal1_manager.o: ../PhastFortran/sumcal1_manager.F90 module_dummy.o
sumcal2.o: ../PhastFortran/sumcal2.f90 module_dummy.o
sumcal_ss_flow.o: ../PhastFortran/sumcal_ss_flow.f90 module_dummy.o
terminate_phast.o: ../PhastFortran/terminate_phast.F90 module_dummy.o
terminate_phast_worker.o: ../PhastFortran/terminate_phast_worker.F90 module_dummy.o
timestep.o: ../PhastFortran/timestep.F90 module_dummy.o
time_step_save.o: ../PhastFortran/time_step_save.F90 module_dummy.o
timestep_ss_flow.o: ../PhastFortran/timestep_ss_flow.f90 module_dummy.o
timestep_worker.o: ../PhastFortran/timestep_worker.F90 module_dummy.o
update_print_flags.o: ../PhastFortran/update_print_flags.f90 module_dummy.o
uppercase.o: ../PhastFortran/uppercase.f90 module_dummy.o
wbbal.o: ../PhastFortran/wbbal.f90 module_dummy.o
wbcflo.o: ../PhastFortran/wbcflo.f90 module_dummy.o
wellsc.o: ../PhastFortran/wellsc.f90 module_dummy.o
wellsc_ss_flow.o: ../PhastFortran/wellsc_ss_flow.f90 module_dummy.o
wellsr.o: ../PhastFortran/wellsr.f90 module_dummy.o
wellsr_ss_flow.o: ../PhastFortran/wellsr_ss_flow.f90 module_dummy.o
welris.o: ../PhastFortran/welris.f90 module_dummy.o
wfdydz.o: ../PhastFortran/wfdydz.f90 module_dummy.o
write1.o: ../PhastFortran/write1.f90 module_dummy.o
write2_1.o: ../PhastFortran/write2_1.f90 module_dummy.o
write2_2.o: ../PhastFortran/write2_2.f90 module_dummy.o
write3.o: ../PhastFortran/write3.f90 module_dummy.o
write3_ss_flow.o: ../PhastFortran/write3_ss_flow.f90 module_dummy.o
write4.o: ../PhastFortran/write4.f90 module_dummy.o
write5.o: ../PhastFortran/write5.f90 module_dummy.o
write5_ss_flow.o: ../PhastFortran/write5_ss_flow.f90 module_dummy.o
write6.o: ../PhastFortran/write6.f90 module_dummy.o
xfer_to_manager.o: ../PhastFortran/xfer_to_manager.F90 module_dummy.o
xfer_to_workers.o: ../PhastFortran/xfer_to_workers.F90 module_dummy.o
XP_aplbce.o: ../PhastFortran/XP_aplbce.f90 module_dummy.o
XP_aplbci.o: ../PhastFortran/XP_aplbci.F90 module_dummy.o
XP_asembl.o: ../PhastFortran/XP_asembl.f90 module_dummy.o
XP_asmslc.o: ../PhastFortran/XP_asmslc.F90 module_dummy.o
XP_crsdsp.o: ../PhastFortran/XP_crsdsp.f90 module_dummy.o
XP_etom2.o: ../PhastFortran/XP_etom2.f90 module_dummy.o
XP_rhsn.o: ../PhastFortran/XP_rhsn.f90 module_dummy.o
XP_sumcal1.o: ../PhastFortran/XP_sumcal1.f90 module_dummy.o
XP_wbcflo.o: ../PhastFortran/XP_wbcflo.f90 module_dummy.o
XP_wellsc.o: ../PhastFortran/XP_wellsc.f90 module_dummy.o
XP_wellsr.o: ../PhastFortran/XP_wellsr.f90 module_dummy.o
zone_flow.o: ../PhastFortran/zone_flow.f90 module_dummy.o
zone_flow_ss.o: ../PhastFortran/zone_flow_ss.f90 module_dummy.o
#
#  PHAST Fortran files
#

#
#  Dependencies
#
-include ../dependencies

clean:
	rm -rf serial_gfortran serial_gfortran_debug openmpi_gfortran openmpi_gfortran_debug serial_gfortran_64 serial_gfortran_64_debug openmpi_gfortran_64 openmpi_gfortran_64_debug serial_intel serial_intel_debug serial_intel_64 serial_intel_64_debug openmpi_intel openmpi_intel_debug openmpi_intel_64 openmpi_intel_64_debug 

depends:
	mkdir -p temp_dependency_dir
	cd temp_dependency_dir; gcc -MM $(DEFINE_HDF) -I.. -I../IPhreeqcPhast -I../PhreeqcRM \
	-I../IPhreeqcPhast/IPhreeqc -I../IPhreeqcPhast/IPhreeqc/phreeqcpp \
	-I../KDtree \
	../*.cxx ../*.cpp \
	../IPhreeqcPhast/*.cpp 	../IPhreeqcPhast/*.cxx \
	../PhreeqcRM/*.cpp \
	../IPhreeqcPhast/IPhreeqc/*.cpp ../IPhreeqcPhast/IPhreeqc/*.c \
	../IPhreeqcPhast/IPhreeqc/phreeqcpp/*.cxx ../IPhreeqcPhast/IPhreeqc/phreeqcpp/*.cpp \
	../KDtree/*.cpp $(PHASTINPUT_FILES) > ../dependencies
#	cd temp_dependency_dir; gfortran -MM $(DEFINE_HDF) -I.. -I../IPhreeqcPhast \
#	../PhastFortran/*.f90 ../PhastFortran/*.F90 \
#	$(PHASTINPUT_FILES) > ../dependencies_fort
	rm -rf temp_dependency_dir

depends_parallel:
	mkdir -p temp_dependency_dir
	cd temp_dependency_dir; gcc -MM $(DEFINE_HDF) $(DEFINE_MPI) -I../phreeqcpp -I../phreeqcpp/phreeqc -I../KDtree ../*.cxx ../*.c ../phreeqcpp/*.cxx ../phreeqcpp/phreeqc/*.c $(PHASTINPUT_FILES) > ../dependencies_parallel
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
