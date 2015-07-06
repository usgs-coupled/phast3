#!/bin/sh
# $Id$

#
# USAGE: ./dist.sh -v VERSION -r REVISION -d RELEASE_DATE
#                  [-rs REVISION-SVN] [-pr REPOS-PATH]
#                  [-win] [-alpha ALPHA_NUM|-beta BETA_NUM|-rc RC_NUM]
#
#   Create a distribution tarball, labelling it with the given VERSION.
#   The REVISION or REVISION-SVN will be used in the version string.
#   The tarball will be constructed from the root located at REPOS-PATH.
#   If REPOS-PATH is not specified then the default is "branches/VERSION".
#   For example, the command line:
#
#      ./dist.sh -v 0.24.2 -r 6284 -d 2/7/05
#
#   from the top-level of a branches/0.24.2 working copy will create
#   the 0.24.2 release tarball.
#
#   When building a alpha, beta or rc tarballs pass the apppropriate flag
#   followed by the number for that release.  For example you'd do
#   the following for a Beta 1 release:
#      ./dist.sh -v 1.1.0 -r 10277 -pr branches/1.1.x -beta 1
# 
#   If neither an -alpha, -beta or -rc option with a number is
#   specified, it will build a release tarball.
#  
#   To build a Windows package pass -win.

# echo everything
# set -x

# A quick and dirty usage message
USAGE="USAGE: ./dist.sh -v VERSION -vp PHREEQC_VER -r REVISION -d RELEASE_DATE \
[-rs REVISION-SVN ] [-pr REPOS-PATH] \
[-alpha ALPHA_NUM|-beta BETA_NUM|-rc RC_NUM] \
[-win]
 EXAMPLES: ./dist.sh -v 1.1.1 -vp 2.17.0  -r 150 -d 2/7/05
           ./dist.sh -v 1.1.1 -vp 2.17.1  -r 150 -d 2/7/05 -pr trunk"


# Let's check and set all the arguments
ARG_PREV=""

for ARG in $@
do
  if [ "$ARG_PREV" ]; then

    case $ARG_PREV in
         -v)  VERSION="$ARG" ;;
        -vp)  PHREEQC_VER="$ARG" ;;
         -r)  REVISION="$ARG" ;;
        -rs)  REVISION_SVN="$ARG" ;;
        -pr)  REPOS_PATH="$ARG" ;;
        -rc)  RC="$ARG" ;;
      -beta)  BETA="$ARG" ;;
     -alpha)  ALPHA="$ARG" ;;
         -d)  RDATE="$ARG" ;;
          *)  ARG_PREV=$ARG ;;
    esac

    ARG_PREV=""

  else

    case $ARG in
      -v|-vp|-r|-rs|-pr|-beta|-rc|-alpha|-d)
        ARG_PREV=$ARG
        ;;
      -win)
        WIN=1
        ARG_PREV=""
	;;
      *)
        echo " $USAGE"
        exit 1
        ;;
    esac
  fi
done

if [ -z "$REVISION_SVN" ]; then
  REVISION_SVN=$REVISION
fi

if [ -n "$ALPHA" ] && [ -n "$BETA" ] ||
   [ -n "$ALPHA" ] && [ -n "$RC" ] ||
   [ -n "$BETA" ] && [ -n "$RC" ] ; then
  echo " $USAGE"
  exit 1
elif [ -n "$ALPHA" ] ; then
  VER_TAG="Alpha $ALPHA"
  VER_NUMTAG="-alpha$ALPHA" 
elif [ -n "$BETA" ] ; then
  VER_TAG="Beta $BETA"
  VER_NUMTAG="-beta$BETA"
elif [ -n "$RC" ] ; then
  VER_TAG="Release Candidate $RC"
  VER_NUMTAG="-rc$RC"
else
  VER_TAG="r$REVISION_SVN"
  VER_NUMTAG="-$REVISION"
fi

case `uname` in
  CYGWIN*)  WIN=1;;
esac
  
if [ -n "$WIN" ] ; then
  EXTRA_EXPORT_OPTIONS="--native-eol CRLF"
  MODELVIEWER_1_3="/cygdrive/c/Program Files/USGS/Model Viewer 1.3/"
  if [ ! -d "${MODELVIEWER_1_3}" ] ; then \
    echo "Error: ${MODELVIEWER_1_3} not found"; \
    echo "Error: ModelViewer must be installed"; \
    exit 1; \
  fi
fi

if [ -z "$VERSION" ] || [ -z "$PHREEQC_VER" ] || [ -z "$REVISION" ] || [ -z "$RDATE" ]; then
  echo " $USAGE"
  exit 1
fi

LOWER='abcdefghijklmnopqrstuvwxyz'
UPPER='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
VER_UC=`echo $VERSION | sed -e "y/$LOWER/$UPPER/"`

# format date string
RELEASE_DATE="`date -d $RDATE  "+%B %e, %G"`"

if [ -z "$REPOS_PATH" ]; then
  REPOS_PATH="branches/$VERSION"
else
  REPOS_PATH="`echo $REPOS_PATH | sed 's/^\/*//'`"
fi

DISTNAME="phast-${VERSION}${VER_NUMTAG}"
DIST_SANDBOX=.dist_sandbox
DISTPATH="$DIST_SANDBOX/$DISTNAME"

echo "Distribution will be named: $DISTNAME"
echo " release branch's revision: $REVISION"
echo "     executable's revision: $REVISION_SVN"
echo "     constructed from path: /$REPOS_PATH"
echo "              release date: $RELEASE_DATE"

rm -rf "$DIST_SANDBOX"
mkdir "$DIST_SANDBOX"
echo "Removed and recreated $DIST_SANDBOX"

echo "Exporting revision $REVISION of PHAST into sandbox..."
(cd "$DIST_SANDBOX" && \
        ${SVN:-svn} export -q $EXTRA_EXPORT_OPTIONS --ignore-externals -r "$REVISION" \
             "http://internalbrr.cr.usgs.gov/svn_GW/phast3/$REPOS_PATH" \
             "$DISTNAME")
if [ $? != 0 ] ; then
  exit $?;
fi

echo "Exporting revision $REVISION of external database into sandbox..."
(cd "$DIST_SANDBOX" && \
        ${SVN:-svn} export -q $EXTRA_EXPORT_OPTIONS --ignore-externals -r "$REVISION" \
             "http://internalbrr.cr.usgs.gov/svn_GW/phreeqc3/trunk/database" \
             "$DISTNAME/database")
if [ $? != 0 ] ; then
  exit $?;
fi

echo "Exporting revision $REVISION of external doc/phreeqc3-doc into sandbox..."
(cd "$DIST_SANDBOX" && \
        ${SVN:-svn} export -q $EXTRA_EXPORT_OPTIONS --ignore-externals -r "$REVISION" \
             "http://internalbrr.cr.usgs.gov/svn_GW/phreeqc3/trunk/doc" \
             "$DISTNAME/doc/phreeqc3-doc")
if [ $? != 0 ] ; then
  exit $?;
fi

echo "Exporting revision $REVISION of external src/phast/KDtree into sandbox..."
(cd "$DIST_SANDBOX" && \
        ${SVN:-svn} export -q $EXTRA_EXPORT_OPTIONS --ignore-externals -r "$REVISION" \
             "http://internalbrr.cr.usgs.gov/svn_GW/phast3/trunk/src/phastinput/KDtree" \
             "$DISTNAME/src/phast/KDtree")
if [ $? != 0 ] ; then
  exit $?;
fi

echo "Exporting revision $REVISION of external src/phast/PhreeqcRM into sandbox..."
(cd "$DIST_SANDBOX" && \
        ${SVN:-svn} export -q $EXTRA_EXPORT_OPTIONS --ignore-externals -r "$REVISION" \
             "http://internalbrr.cr.usgs.gov/svn_GW/PhreeqcRM/trunk" \
             "$DISTNAME/src/phast/PhreeqcRM")
if [ $? != 0 ] ; then
  exit $?;
fi

echo "Exporting revision $REVISION of external src/phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc into sandbox..."
(cd "$DIST_SANDBOX" && \
        ${SVN:-svn} export -q $EXTRA_EXPORT_OPTIONS --ignore-externals -r "$REVISION" \
             "http://internalbrr.cr.usgs.gov/svn_GW/IPhreeqc/trunk/src" \
             "$DISTNAME/src/phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc")
if [ $? != 0 ] ; then
  exit $?;
fi

echo "Exporting revision $REVISION of external src/phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp into sandbox..."
(cd "$DIST_SANDBOX" && \
        ${SVN:-svn} export -q $EXTRA_EXPORT_OPTIONS --ignore-externals -r "$REVISION" \
             "http://internalbrr.cr.usgs.gov/svn_GW/phreeqc3/trunk/src" \
             "$DISTNAME/src/phast/PhreeqcRM/src/IPhreeqcPhast/IPhreeqc/phreeqcpp")
if [ $? != 0 ] ; then
  exit $?;
fi

if [ -n "$WIN" ]; then
  echo "Exporting revision $REVISION of ModelViewer into sandbox..."
  (cd "$DIST_SANDBOX" && \
          ${SVN:-svn} export -q $EXTRA_EXPORT_OPTIONS --ignore-externals -r "$REVISION" \
                "http://internalbrr.cr.usgs.gov/svn_GW/ModelViewer/trunk" \
                "$DISTNAME/ModelViewer")
  if [ $? != 0 ] ; then
    exit $?;
  fi
fi  

echo "Making examples clean"
(cd "$DISTPATH/examples" && [ -f Makefile ] && make TOPDIR=.. clean > /dev/null)

echo "Cleaning up examples directory"
rm -rf "$DISTPATH/examples/hosts"
rm -rf "$DISTPATH/examples/Makefile"
rm -rf "$DISTPATH/examples/run"
rm -rf "$DISTPATH/examples/schema"
rm -rf "$DISTPATH/examples/zero.sed"
rm -rf "$DISTPATH/examples/zero1.sed"
rm -rf "$DISTPATH/examples/runmpich"
rm -rf "$DISTPATH/examples/ex4/ex4.restart"
rm -rf "$DISTPATH/examples/ex5/plume.heads.xyzt"
rm -rf "$DISTPATH/examples/ex5/runmpich"
rm -rf "$DISTPATH/examples/print_check_ss/print_check_ss.head.dat"
rm -rf "$DISTPATH/examples/print_check_ss/print_check_ss.dmp"
find "$DISTPATH/examples" -type f -name '*.restart' ! -wholename '*/ex4restart/ex4.restart' -print | xargs rm -rf
find "$DISTPATH/examples" -type d -name '0' -print | xargs rm -rf
find "$DISTPATH/examples" -type f -name 'clean' -print | xargs rm -rf
find "$DISTPATH/examples" -type f -name 'notes' -print | xargs rm -rf
find "$DISTPATH/examples" -type f -name '*.wphast' -print | xargs rm -rf
find "$DISTPATH/examples" -type f -name '*.mv' -print | xargs rm -rf

echo "Cleaning up misc files"
rm -rf "$DISTPATH/bootstrap"
find "$DISTPATH/src" -type f -name '*.user' -print | xargs rm -rf

echo "Deleting examples that aren't distributed"
mv "$DISTPATH/examples" "$DISTPATH/examples-delete"
mkdir "$DISTPATH/examples"
cp "$DISTPATH/examples-delete/Makefile.am" "$DISTPATH/examples"
EXAMPLES="decay \
          diffusion1d \
          diffusion2d \
          disp2d \
          ex1 \
          ex2 \
          ex3 \
          ex4 \
          ex4_ddl \
          ex4_noedl \
          ex4_start_time \
          ex4_transient \
          ex4restart \
          ex5 \
          ex6 \
          kindred4.4 \
          leaky \
          leakysurface \
          leakyx \
          leakyz \
          linear_bc \
          linear_ic \
          mass_balance \
          notch \
          phrqex11 \
          property \
          radial \
          river \
          shell \
          simple \
          unconf \
          well \
          zf"
for ex in $EXAMPLES
do
  mv "$DISTPATH/examples-delete/$ex" "$DISTPATH/examples/."
done
rm -rf "$DISTPATH/examples-delete"

echo "Cleaning up src/phastinput directory"
rm -rf "$DISTPATH/src/phastinput/test"

echo "Cleaning up src/phast directory"
rm -rf "$DISTPATH/src/phast/phreeqc/Sun"

echo "Renaming phreeqc.dat to phast.dat"
mv "$DISTPATH/database/phreeqc.dat" "$DISTPATH/database/phast.dat"

if [ -n "$WIN" ]; then
  echo "Copying Model Viewer Reqs"
  mkdir "$DISTPATH/ModelViewer/Redist"
  mkdir "$DISTPATH/ModelViewer/Redist/doc"
  mkdir "$DISTPATH/ModelViewer/Redist/bin"
  cp "`cygpath "${MODELVIEWER_1_3}"`/notice.txt"            "$DISTPATH/ModelViewer/Redist/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/readme.txt"            "$DISTPATH/ModelViewer/Redist/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/doc/ofr02-106.pdf"     "$DISTPATH/ModelViewer/Redist/doc/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/DFORRT.DLL"        "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/hdf5dll.dll"       "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/lf90.eer"          "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/lf90wiod.dll"      "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/modview.chm"       "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/szlibdll.dll"      "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/vtkCommon.dll"     "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/vtkFiltering.dll"  "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/vtkGraphics.dll"   "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/vtkImaging.dll"    "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/vtkRendering.dll"  "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/zlib1.dll"         "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/mf2k_r1.dll"       "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/mf96_r1.dll"       "$DISTPATH/ModelViewer/Redist/bin/."
  cp "`cygpath "${MODELVIEWER_1_3}"`/bin/mt_r1.dll"         "$DISTPATH/ModelViewer/Redist/bin/."
fi  

ver_major=`echo $VERSION | cut -d '.' -f 1`
ver_minor=`echo $VERSION | cut -d '.' -f 2`
ver_patch=`echo $VERSION | cut -d '.' -f 3`

if [ -z "$ver_patch" ]; then
  ver_patch="0"
fi

VERSION_LONG="$ver_major.$ver_minor.$ver_patch.$REVISION_SVN"

SED_FILES="$DISTPATH/src/phast/phast_version.h \
           $DISTPATH/src/phast/phast.F90 \
           $DISTPATH/src/phast/phreeqcpp/phreeqc/revisions \
           $DISTPATH/src/phasthdf/win32/phasthdf_version.h \
           $DISTPATH/src/phastinput/phastinput_version.h \
           $DISTPATH/README \
           $DISTPATH/RELEASE \
for vsn_file in $SED_FILES
do
  sed \
   -e "/#define *PHAST_VER_MAJOR/s/[0-9]\+/$ver_major/" \
   -e "/#define *PHAST_VER_MINOR/s/[0-9]\+/$ver_minor/" \
   -e "/#define *PHAST_VER_PATCH/s/[0-9]\+/$ver_patch/" \
   -e "/#define *PHAST_VER_TAG/s/\".*\"/\" ($VER_TAG)\"/" \
   -e "/#define *PHAST_VER_NUMTAG/s/\".*\"/\"$VER_NUMTAG\"/" \
   -e "/#define *PHAST_VER_REVISION/s/[0-9]\+/$REVISION_SVN/" \
   -e "s/@VERSION@/${VERSION}/g" \
   -e "s/@REVISION@/${REVISION}/g" \
   -e "s/@VER_DATE@/${RELEASE_DATE}/g" \
   -e "s/@RELEASE_DATE@/${RELEASE_DATE}/g" \
   -e "s/@VERSION_LONG@/$VERSION_LONG/g" \
   -e "s/@VER_UC@/${VER_UC}/g" \
   -e "s/@PHREEQC_VER@/${PHREEQC_VER}/g" \
   -e "s/@PHREEQC_DATE@/${RELEASE_DATE}/g" \
    < "$vsn_file" > "$vsn_file.tmp"
  mv -f "$vsn_file.tmp" "$vsn_file"
  if [ -n "$WIN" ]; then
    unix2dos "$vsn_file"
  fi
  cp "$vsn_file" "$vsn_file.dist"
done

echo "Copying src/phast/phreeqcpp/phreeqc/revisions to src/phast/phreeqc.revisions and doc/phreeqc.revisions"
cp "$DISTPATH/src/phast/phreeqcpp/phreeqc/revisions" "$DISTPATH/src/phast/phreeqc.revisions"
cp "$DISTPATH/src/phast/phreeqcpp/phreeqc/revisions" "$DISTPATH/doc/phreeqc.revisions"

echo "Rolling $DISTNAME.tar ..."
(cd "$DIST_SANDBOX" > /dev/null && tar c "$DISTNAME") > \
"$DISTNAME.tar"

echo "Compressing to $DISTNAME.tar.gz ..."
gzip -9f "$DISTNAME.tar"
echo "Removing sandbox..."
rm -rf "$DIST_SANDBOX"

echo ""
echo "Done:"
ls -l "$DISTNAME.tar.gz"
echo ""
echo "md5sums:"
md5sum "$DISTNAME.tar.gz"
type sha1sum > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo ""
  echo "sha1sums:"
  sha1sum "$DISTNAME.tar.gz"
fi
