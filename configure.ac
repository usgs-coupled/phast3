#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.64])
AC_INIT([phast], [2.0.0], [dlpark@usgs.gov])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([-Wall -Werror foreign subdir-objects])
AC_CONFIG_SRCDIR([src/phastinput/accumulate.c])

# phastinput defines
AC_DEFINE([ANSI_DECLARATORS], , [Must be set for phastinput])
AC_DEFINE([TRILIBRARY], , [Must be set for phastinput])

# phast defines
AC_DEFINE([PHREEQC_CPP], , [Must be set for phastinput])
AC_DEFINE([HDF5_CREATE], , [Must be set for phastinput])
AC_DEFINE([H5Dcreate_vers], [1] , [Must be set to 1 for phast])
AC_DEFINE([H5Gcreate_vers], [1] , [Must be set to 1 for phast])
AC_DEFINE([H5Eset_auto_vers], [1] , [Must be set to 1 for phast])

# Checks for programs.
AC_PROG_CXX
AC_PROG_AWK
AC_PROG_CC
AC_PROG_CPP
AC_PROG_FC
AC_FC_LIBRARY_LDFLAGS
AC_FC_WRAPPERS 
AC_FC_MAIN
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET

AC_PROG_LIBTOOL

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([float.h limits.h memory.h stddef.h stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T

# Checks for library functions.
AC_FUNC_MALLOC
AC_FUNC_REALLOC
AC_FUNC_STRTOD

# libc functions
AC_CHECK_FUNCS([memmove], , AC_ERROR([memmove not found in libc]))
AC_CHECK_FUNCS([memset],  , AC_ERROR([memset not found in libc]))
AC_CHECK_FUNCS([strchr],  , AC_ERROR([strchr not found in libc]))
AC_CHECK_FUNCS([strcspn], , AC_ERROR([strcspn not found in libc]))
AC_CHECK_FUNCS([strtol],  , AC_ERROR([strtol not found in libc]))

# libm functions
AC_CHECK_FUNCS([floor],   , AC_CHECK_LIB(m, floor, , AC_ERROR([cannot find floor])) )
AC_CHECK_FUNCS([pow],     , AC_CHECK_LIB(m, pow,   , AC_ERROR([cannot find pow])) )
AC_CHECK_FUNCS([sqrt],    , AC_CHECK_LIB(m, sqrt,  , AC_ERROR([cannot find sqrt])) )

# boost
AX_BOOST_BASE([1.36])

# HDF5
##set -x -v
AX_LIB_HDF5()
##set +x +v

# Build mpi version
# Check if building mpi version
AC_MSG_CHECKING([if building MPI version])
AC_ARG_ENABLE([mpi],
     [AC_HELP_STRING([--enable-mpi],
                     [build the MPI version @<:@default=no@:>@])],
     [PHAST_MPI=yes],)

if test "X$PHAST_MPI" = "Xyes"; then
  AC_MSG_RESULT(yes)
  AC_LANG(C++)
  AX_MPI()
  AC_LANG(Fortran)
  AX_MPI()
  # extra MPI defines
  AC_DEFINE([USE_MPI], , [Set to use MPI])
  AC_DEFINE([MERGE_FILES], , [Set to use MPI])
  # set compilers
  CXX="$MPICXX"
  FC="$MPIFC"
else
  AC_MSG_RESULT(no)
fi
AM_CONDITIONAL([BUILD_MPI], [test "X$PHAST_MPI" = "Xyes"])

###AC_CONFIG_HEADERS([config.h])

AC_CONFIG_FILES([
  Makefile
  src/Makefile
  src/phast/Makefile
  src/phastinput/Makefile
])
AC_OUTPUT
