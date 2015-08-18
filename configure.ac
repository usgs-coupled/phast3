<#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.61])
AC_INIT([phast], [3.0.0-9238], [dlpark@usgs.gov])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([-Wall -Werror foreign no-define subdir-objects tar-ustar])
AC_CONFIG_SRCDIR([src/phastinput/accumulate.cpp])

# enable silent rules when available (automake 1.11 or later).
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_CANONICAL_HOST

# phastinput defines
AC_DEFINE([ANSI_DECLARATORS], , [Must be set for phastinput])
AC_DEFINE([TRILIBRARY], , [Must be set for phastinput])
AC_DEFINE([PHRQ_IO_INPUT], , [Must be set for phastinput])

# phast defines
AC_DEFINE([SWIG_SHARED_OBJ], , [Must be set for phast])
AC_DEFINE([USE_PHRQ_ALLOC], , [Must be set for phast])
AC_DEFINE([H5Dcreate_vers], [1] , [Must be set to 1 for phast])
AC_DEFINE([H5Gcreate_vers], [1] , [Must be set to 1 for phast])
AC_DEFINE([H5Eset_auto_vers], [1] , [Must be set to 1 for phast])

# check for --with-mpi
# If --with-mpi=auto is used, try to find MPI, but use standard C compiler if it is not found.
# If --with-mpi=yes is used, try to find MPI and fail if it isn't found.
# If --with-mpi=no is used, use a standard C compiler instead.
AC_ARG_WITH(mpi, [AS_HELP_STRING([--with-mpi],
    [compile with MPI (parallelization) support. If none is found,
    MPI is not used. Default: no])
],,[with_mpi=no])


# Checks for programs.
##AC_PROG_CXX
AX_PROG_CXX_MPI([test x"$with_mpi" != xno],[use_mpi=yes],[
  use_mpi=no
  if test x"$with_mpi" = xyes; then
    AC_MSG_ERROR([MPI compiler requested, but couldn't use MPI.])
  fi
])
AC_PROG_AWK
AC_PROG_LN_S
##AC_PROG_CC
AC_PROG_CPP
AC_PROG_F77
##AC_PROG_FC
AX_PROG_FC_MPI([test x"$with_mpi" != xno],[use_mpi=yes],[
  use_mpi=no
  if test x"$with_mpi" = xyes; then
    AC_MSG_ERROR([MPI compiler requested, but couldn't use MPI.])
  fi
])
AC_FC_LIBRARY_LDFLAGS
AC_FC_WRAPPERS
AC_FC_MAIN
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET

# ant (used to build phasthdf)
AC_ARG_VAR(ANT, [Ant Java build tool command])
AC_PATH_PROG([ANT], [ant])

# determine f90 module suffix
AX_F90_MODULE_EXTENSION
F90_MODEXT=mod
if test x$ax_cv_f90_modext != xunknown ; then
  F90_MODEXT=$ax_cv_f90_modext  
fi
AC_SUBST(F90_MODEXT)

# Checks for libraries.
if test x"$with_mpi" = xyes; then
  enable_openmp=no
fi

if test x"$enable_openmp" != xno; then
  AC_LANG_PUSH(C++)
  AC_OPENMP
  AC_LANG_POP(C++)
  AC_SUBST(AM_CXXFLAGS, $OPENMP_CXXFLAGS)
fi

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

case $host_os in
     solaris*)
	CXXFLAGS="$CXXFLAGS -library=stlport4"
	LDFLAGS="$LDFLAGS -library=stlport4"
	;;
esac


# boost
AX_BOOST_BASE([1.33], , AC_ERROR([Boost is required to build phast]))
if test "X$want_boost" = "Xno"; then
  AC_MSG_ERROR([Boost is required to build phast])
fi

# isfinite
AC_LANG_PUSH(C++)
AC_CACHE_CHECK([for isfinite], ac_cv_isfinite,
 [AC_TRY_LINK([#include <math.h>],
 [double x; int y; y = isfinite(x);],
 ac_cv_isfinite=yes,
 ac_cv_isfinite=no
)])
if test x"$ac_cv_isfinite" = x"yes"; then
  AC_DEFINE(HAVE_ISFINITE, [], [Has isfinite])
fi
AC_LANG_POP(C++)

# finite
AC_LANG_PUSH(C++)
AC_CACHE_CHECK([for finite], ac_cv_finite,
 [AC_TRY_LINK([#include <math.h>],
 [double x; int y; y = finite(x);],
 ac_cv_finite=yes,
 ac_cv_finite=no
)])
if test x"$ac_cv_finite" = x"yes"; then
  AC_DEFINE(HAVE_FINITE, [], [Has finite])
fi
AC_LANG_POP(C++)

# isnan
AC_CHECK_FUNCS([isnan],    , AC_CHECK_LIB(m, isnan))


#  --with-xxx from HDF configure
#  ----------------------------------------------------------------------
#  Fake --with-xxx option to allow us to create a help message for the
#  following --with-xxx options which can take either a =DIR or =INC,LIB
#  specifier.
#
AC_ARG_WITH([fnord],
  [
 For the following --with-xxx options, you can specify where the header
 files and libraries are in two different ways:

    --with-xxx=INC,LIB - Specify individually the include directory and
                         library directory separated by a comma
    --with-xxx=DIR     - Specify only the directory which contains the
                         include/ and lib/ subdirectories
  ])


# zlib (Note: test for zlib before hdf5 since hdf5 normally depends on zlib)
#  ----------------------------------------------------------------------
#  Is the zlib present? It has a header file `zlib.h' and a library
#  `-lz' and their locations might be specified with the `--with-zlib'
#  command-line switch. The value is an include path and/or a library path.
#  If the library path is specified then it must be preceded by a comma.
#
AC_ARG_WITH([zlib],
            [AC_HELP_STRING([--with-zlib=DIR],
                            [Use the zlib library [default=auto]])],,withval=yes)

case $withval in
  yes)
    HAVE_ZLIB="yes"
    AC_CHECK_HEADERS(zlib.h, , AC_MSG_ERROR([zlib.h not found]))
    AC_CHECK_LIB(z, gzwrite, , AC_MSG_ERROR([couldn't find zlib library]))
    ;;
  *)
    HAVE_ZLIB="yes"
    case "$withval" in
      *,*)
        zlib_inc="`echo $withval |cut -f1 -d,`"
        zlib_lib="`echo $withval |cut -f2 -d, -s`"
        ;;
      *)
        if test -n "$withval"; then
          zlib_inc="$withval/include"
          zlib_lib="$withval/lib"
        fi
        ;;
    esac

    saved_CPPFLAGS="$CPPFLAGS"
    saved_LDFLAGS="$LDFLAGS"

    if test -n "$zlib_inc"; then
      CPPFLAGS="$CPPFLAGS -I$zlib_inc"
    fi

    AC_CHECK_HEADERS(zlib.h,, AC_MSG_ERROR([zlib.h not found]))

    if test -n "$zlib_lib"; then
      LDFLAGS="$LDFLAGS -L$zlib_lib"
    fi

    AC_CHECK_LIB(z, gzwrite,, LDFLAGS="$saved_LDFLAGS"; unset HAVE_ZLIB)

    if test -z "$HAVE_ZLIB"; then
      AC_MSG_ERROR(couldn't find zlib library)
    fi
    ;;
esac

# HDF5
#  ----------------------------------------------------------------------
#  Is the hdf5 present? It has a header file `hdf5.h' and a library
#  `-lhdf5' and their locations might be specified with the `--with-hdf5'
#  command-line switch. The value is an include path and/or a library path.
#  If the library path is specified then it must be preceded by a comma.
#
##set -x -v
AC_LANG_PUSH(C++)
AC_ARG_WITH([hdf5],
            [AC_HELP_STRING([--with-hdf5=DIR],
                            [Use the HDF5 library [default=auto]])],,withval=yes)

case $withval in
  yes)
    HAVE_HDF5="yes"
    AC_CHECK_HEADERS(hdf5.h, , AC_MSG_ERROR([hdf5.h not found]))
    AC_CHECK_LIB(hdf5, H5Fopen, , AC_MSG_ERROR([couldn't find hdf5 library]))
    ;;
  *)
    HAVE_HDF5="yes"
    case "$withval" in
      *,*)
        hdf5_inc="`echo $withval |cut -f1 -d,`"
        hdf5_lib="`echo $withval |cut -f2 -d, -s`"
        ;;
      *)
        if test -n "$withval"; then
          hdf5_inc="$withval/include"
          hdf5_lib="$withval/lib"
        fi
        ;;
    esac

    saved_CPPFLAGS="$CPPFLAGS"
    saved_LDFLAGS="$LDFLAGS"

    if test -n "$hdf5_inc"; then
      CPPFLAGS="$CPPFLAGS -I$hdf5_inc"
    fi

    AC_CHECK_HEADERS(hdf5.h,, AC_MSG_ERROR([hdf5.h not found]))

    if test -n "$hdf5_lib"; then
      LDFLAGS="$LDFLAGS -L$hdf5_lib"
    fi

    AC_CHECK_LIB(hdf5, H5Fopen,, LDFLAGS="$saved_LDFLAGS"; unset HAVE_HDF5)

    if test -z "$HAVE_HDF5"; then
      AC_MSG_ERROR(couldn't find hdf5 library)
    fi
    ;;
esac
AC_LANG_POP(C++)


dnl # Build mpi version
dnl # Check if building mpi version
dnl AC_MSG_CHECKING([if building MPI version])
dnl AC_ARG_ENABLE([mpi],
dnl      [AC_HELP_STRING([--enable-mpi],
dnl                      [build the MPI version @<:@default=no@:>@])],
dnl      [PHAST_MPI=yes],[PHAST_MPI=no])

dnl if test "X$PHAST_MPI" = "Xyes"; then
dnl   AC_MSG_RESULT(yes)
dnl   AC_LANG_PUSH(C++)
dnl   AX_MPI(, AC_ERROR([MPI not found]))
dnl   AC_LANG_POP(C++)

dnl   # extra MPI defines
dnl   AC_DEFINE([USE_MPI], , [Set to use MPI])
dnl   AC_DEFINE([MERGE_FILES], , [Set to use MPI])

dnl   AC_LANG_PUSH(Fortran)
dnl   AX_MPI(, AC_ERROR([MPI not found]))
dnl   AC_LANG_POP(Fortran)

dnl   # set compilers
dnl   CXX="$MPICXX"
dnl   PHAST_SUFFIX=mpi
dnl   #{{
dnl   AC_LANG_PUSH(Fortran)
dnl   AC_MSG_RESULT("$MPIFC")
dnl   FC="$MPIFC"
dnl   AC_FC_LIBRARY_LDFLAGS
dnl   AC_FC_WRAPPERS
dnl   AC_FC_MAIN
dnl   AC_LANG_POP(Fortran)
dnl   #}}
dnl   # disable openmp
dnl   enable_openmp=no
dnl else
dnl   AC_MSG_RESULT(no)
dnl   if test "$enable_openmp" != no; then
dnl      AC_SUBST(AM_CXXFLAGS, $OPENMP_CXXFLAGS)
dnl      AC_DEFINE(USE_OPENMP)
dnl   fi
dnl   PHAST_SUFFIX=openmp
dnl fi

AM_CONDITIONAL([BUILD_OPENMP], [test "X$enable_openmp" != "Xno"])
###AM_CONDITIONAL([BUILD_MPI], [test "X$PHAST_MPI" = "Xyes"])
AM_CONDITIONAL([BUILD_MPI], [test "X$with_mpi" = "Xyes"])
AM_CONDITIONAL([BUILD_PHASTHDF], [test -n "$ANT"])

# set phast suffix
if test "X$with_mpi" != "Xno"; then
  AC_DEFINE([USE_MPI], [] , [Set to use MPI])
  PHAST_SUFFIX=mpi
  MPIEXEC=mpiexec
  MPIEXEC_NUMPROC_FLAG=-np
else
  if test "X$enable_openmp" != "Xno"; then
    AC_DEFINE([USE_OPENMP], [], [Set to to use OpenMP])
    PHAST_SUFFIX=openmp
  else
    PHAST_SUFFIX=ser
  fi
fi
AC_SUBST(PHAST_SUFFIX)
AC_SUBST(MPIEXEC)
AC_SUBST(MPIEXEC_NUMPROC_FLAG)

AC_CONFIG_FILES([
  Makefile
  doc/Makefile
  examples/Makefile
  src/Makefile
  src/phast/Makefile
  src/phast/phast
  src/phasthdf/Makefile
  src/phasthdf/build.xml
  src/phastinput/Makefile
])

AC_OUTPUT
echo "*************************************"
echo "Summary:"
echo "C++ Compiler                 = $CXX"
echo "CPPFLAGS                     = $CPPFLAGS"
echo "CXXFLAGS                     = $CXXFLAGS"
echo "Fortran Compiler             = $FC"
echo "Fortran Libs                 = $FCLIBS"
echo "LDFLAGS                      = $LDFLAGS"
if test "X$enable_openmp" != "Xno"; then
  echo "Enable OpenMP                = yes"
else
  echo "Enable OpenMP                = no"
fi
echo "Enable MPI                   = $with_mpi"
if test -z "$ANT"; then
  echo "Build phasthdf (reqs ant)    = no"
else
  echo "Build phasthdf (reqs ant)    = yes"
  echo "Ant                          = $ANT"
fi
echo "*************************************"
