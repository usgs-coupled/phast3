#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.61])
AC_INIT([phast], [2.0.0-4665], [dlpark@usgs.gov])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([-Wall -Werror foreign no-define subdir-objects])
AC_CONFIG_SRCDIR([src/phastinput/accumulate.c])

AC_CANONICAL_HOST

# phastinput defines
AC_DEFINE([ANSI_DECLARATORS], , [Must be set for phastinput])
AC_DEFINE([TRILIBRARY], , [Must be set for phastinput])

# phast defines
AC_DEFINE([PHREEQC_CPP], , [Must be set for phast])
AC_DEFINE([HDF5_CREATE], , [Must be set for phast])
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

# ant (used to build phasthdf)
AC_ARG_VAR(ANT, [Ant Java build tool command])
AC_PATH_PROG([ANT], [ant])


# determine f90 module suffix
AX_F90_MODULE_EXTENSION
F90_MODEXT=mod
if test x$ax_f90_modext = xunknown ; then
  F90_MODEXT=$ax_f90_modext  
fi
AC_SUBST(F90_MODEXT)

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

##AC_CHECK_DECL([__SUNPRO_CC], [SUNCC=yes], [SUNCC=no])
##if test x$SUNCC = xyes; then
##   CXXFLAGS="CXXFLAGS -library=stlport4"
##   LDFLAGS="$LDFLAGS -library=stlport4"
##fi
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

#   Trying to include -I/usr/include and -L/usr/lib is redundant and
#   can mess some compilers up.
##    if test "X$zlib_inc" = "X/usr/include"; then
##      zlib_inc=""
##    fi
##    if test "X$zlib_lib" = "X/usr/lib"; then
##      zlib_lib=""
##    fi

#   Trying to include -I/usr/local/include and -L/usr/local/lib is redundant and
#   can mess some compilers up.
##    if test "X$zlib_inc" = "X/usr/local/include"; then
##      zlib_inc=""
##    fi
##    if test "X$zlib_lib" = "X/usr/local/lib"; then
##      zlib_lib=""
##    fi

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

#   Trying to include -I/usr/include and -L/usr/lib is redundant and
#   can mess some compilers up.
##    if test "X$hdf5_inc" = "X/usr/include"; then
##      hdf5_inc=""
##    fi
##    if test "X$hdf5_lib" = "X/usr/lib"; then
##      hdf5_lib=""
##    fi

#   Trying to include -I/usr/local/include and -L/usr/local/lib is redundant and
#   can mess some compilers up.
##    if test "X$hdf5_inc" = "X/usr/local/include"; then
##      hdf5_inc=""
##    fi
##    if test "X$hdf5_lib" = "X/usr/local/lib"; then
##      hdf5_lib=""
##    fi

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
##set +x +v

# Build mpi version
# Check if building mpi version
AC_MSG_CHECKING([if building MPI version])
AC_ARG_ENABLE([mpi],
     [AC_HELP_STRING([--enable-mpi],
                     [build the MPI version @<:@default=no@:>@])],
     [PHAST_MPI=yes],[PHAST_MPI=no])

if test "X$PHAST_MPI" = "Xyes"; then
  AC_MSG_RESULT(yes)
  AC_LANG(C++)
  AX_MPI(, AC_ERROR([MPI not found]))
  # extra MPI defines
  AC_DEFINE([USE_MPI], , [Set to use MPI])
  AC_DEFINE([MERGE_FILES], , [Set to use MPI])
  # set compilers
  CXX="$MPICXX"
  PHAST_SUFFIX=mpi
else
  AC_MSG_RESULT(no)
  PHAST_SUFFIX=ser
fi

AM_CONDITIONAL([BUILD_MPI], [test "X$PHAST_MPI" = "Xyes"])
AM_CONDITIONAL([BUILD_PHASTHDF], [test -n "$ANT"])
AC_SUBST(PHAST_SUFFIX)

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
echo "Fortran Compiler             = $FC"
echo "Fortran Libs                 = $FCLIBS"
echo "LDFLAGS                      = $LDFLAGS"
echo "Enable MPI                   = $PHAST_MPI"
if test "X$PHAST_MPI" = "Xyes"; then
echo "MPI C++ compiler command     = $MPICXX"
fi
if test -z "$ANT"; then
echo "Build phasthdf (reqs ant)    = no"
else
echo "Build phasthdf               = yes"
echo "Ant                          = $ANT"
fi
echo "*************************************"
