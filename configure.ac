#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.64])
AC_INIT([phast], [2.0.0], [dlpark@usgs.gov])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([-Wall -Werror foreign subdir-objects])
AC_CONFIG_SRCDIR([src/phastinput/accumulate.c])

# phastinput defines
AC_DEFINE(ANSI_DECLARATORS)
AC_DEFINE(TRILIBRARY)

# phast defines
# DEFINE_HDF=-DHDF5_CREATE -DH5Dcreate_vers=1 -DH5Gcreate_vers=1 -DH5Eset_auto_vers=1
AC_DEFINE(PHREEQC_CPP)
AC_DEFINE(HDF5_CREATE)
AC_DEFINE(H5Dcreate_vers)
AC_DEFINE(H5Gcreate_vers)
AC_DEFINE(H5Eset_auto_vers)

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
AX_LIB_HDF5()

# Build mpi version
AM_CONDITIONAL([BUILD_MPI], [test "X$TODO" = "Xyes"])

# src/phast/Makefile
AC_CONFIG_FILES([
  Makefile
  src/Makefile
  src/phast/Makefile
  src/phastinput/Makefile
])
AC_OUTPUT
