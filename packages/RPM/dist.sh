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
USAGE="USAGE: ./dist.sh -v VERSION -r REVISION -d RELEASE_DATE \
[-rs REVISION-SVN ] [-pr REPOS-PATH] \
[-alpha ALPHA_NUM|-beta BETA_NUM|-rc RC_NUM] \
[-win]
 EXAMPLES: ./dist.sh -v 1.1 -r 150 -d 2/7/05
           ./dist.sh -v 1.1 -r 150 -d 2/7/05 -pr trunk"


# Let's check and set all the arguments
ARG_PREV=""

for ARG in $@
do
  if [ "$ARG_PREV" ]; then

    case $ARG_PREV in
         -v)  VERSION="$ARG" ;;
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
      -v|-r|-rs|-pr|-beta|-rc|-alpha|-d)
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
  VER_NUMTAG=""
fi

case `uname` in
  CYGWIN*)  WIN=1;;
esac
  
if [ -n "$WIN" ] ; then
  EXTRA_EXPORT_OPTIONS="--native-eol CRLF"
fi

if [ -z "$VERSION" ] || [ -z "$REVISION" ] || [ -z "$RDATE" ]; then
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
 	${SVN:-svn} export -q $EXTRA_EXPORT_OPTIONS -r "$REVISION" \
	     "http://internalbrr/svn_GW/phast/$REPOS_PATH" \
	     "$DISTNAME")
	     
echo "Making examples clean"
(cd "$DISTPATH/examples" && [ -f Makefile ] && make TOPDIR=.. clean)

echo "Cleaning up examples directory"
rm -rf "$DISTPATH/examples/hosts"
rm -rf "$DISTPATH/examples/Makefile"
rm -rf "$DISTPATH/examples/run"
rm -rf "$DISTPATH/examples/schema"
find "$DISTPATH/examples" -type d -name '0' -print | xargs rm -rf
find "$DISTPATH/examples" -type f -name 'clean' -print | xargs rm -rf

echo "Cleaning up srcinput directory"
rm -rf "$DISTPATH/srcinput/test"

echo "Renaming phreeqc.dat to phast.dat"
mv "$DISTPATH/database/phreeqc.dat" "$DISTPATH/database/phast.dat"

echo "Rearranging source directories"
mkdir -p "$DISTPATH/src"
mv "$DISTPATH/srcinput" "$DISTPATH/src/phastinput"
mv "$DISTPATH/srcphast" "$DISTPATH/src/phast"
mv "$DISTPATH/phasthdf" "$DISTPATH/src/phasthdf"

ver_major=`echo $VERSION | cut -d '.' -f 1`
ver_minor=`echo $VERSION | cut -d '.' -f 2`
ver_patch=`echo $VERSION | cut -d '.' -f 3`

if [ -z "$ver_patch" ]; then
  ver_patch="0"
fi

VERSION_LONG="$ver_major.$ver_minor.$ver_patch.$REVISION_SVN"

SED_FILES="$DISTPATH/src/phast/phast_version.h
           $DISTPATH/src/phasthdf/win32/phasthdf_version.h\
           $DISTPATH/src/phastinput/win32/phastinput_version.h\
           $DISTPATH/doc/README \
           $DISTPATH/packages/win32-is/phast.ipr \
           $DISTPATH/packages/win32-is/String?Tables/0009-English/value.shl"

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
   -e "s/@VERSION_LONG@/$VERSION_LONG/g" \
   -e "s/@VER_UC@/${VER_UC}/g" \
    < "$vsn_file" > "$vsn_file.tmp"
  mv -f "$vsn_file.tmp" "$vsn_file"
  if [ -n "$WIN" ]; then
    unix2dos "$vsn_file"
  fi  
  cp "$vsn_file" "$vsn_file.dist"
done

echo "Rolling $DISTNAME.tar ..."
(cd "$DIST_SANDBOX" > /dev/null && tar c "$DISTNAME") > \
"$DISTNAME.tar"

echo "Compressing to $DISTNAME.tar.bz2 ..."
bzip2 -9fk "$DISTNAME.tar"

echo "Compressing to $DISTNAME.tar.gz ..."
gzip -9f "$DISTNAME.tar"
echo "Removing sandbox..."
rm -rf "$DIST_SANDBOX"

echo ""
echo "Done:"
ls -l "$DISTNAME.tar.gz" "$DISTNAME.tar.bz2"
echo ""
echo "md5sums:"
md5sum "$DISTNAME.tar.gz" "$DISTNAME.tar.bz2"
type sha1sum > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo ""
  echo "sha1sums:"
  sha1sum "$DISTNAME.tar.gz" "$DISTNAME.tar.bz2"
fi
