#!/bin/sh
# set -x
if [ $# -eq 0 ]; then
    echo "Usage: `basename $0` phast_ver"
    echo "(ie `basename $0` 1.0-1)"
    exit
fi

VER=`echo $1 | sed -e 's/^version-//' -e 's/\-[^\-]*$//'`
REL=`echo $1 | sed -e 's/^version-//' -e 's/[^\-]*\-//'`

if [ "${REL}" != "1" ] ; then
  CVSTAG=version-`echo ${VER}-${REL} | sed -e 's/\./_/'`
else
  CVSTAG=version-`echo ${VER} | sed -e 's/\./_/'`
fi

cd SOURCES

if cvs -d :ext:charlton@mackey:/usr/local/cvsroot export -r${CVSTAG} -d phast-${VER} phast; then
    rm -rf phast-${VER}/bin
    rm -rf phast-${VER}/phastexport
    rm -rf phast-${VER}/setup
    rm -rf phast-${VER}/RPM
    rm -rf phast-${VER}/srcphast/win32
    rm -rf phast-${VER}/srcinput/win32
    rm -f phast-${VER}/srcinput/driver.cpp
    rm -f phast-${VER}/srcinput/main.cpp
    rm -f phast-${VER}/srcinput/Parser.cpp
    rm -f phast-${VER}/srcinput/Parser.h
    rm -f phast-${VER}/srcinput/patch.sh
    rm -f phast-${VER}/srcinput/*.patch
    rm -f phast-${VER}/srcinput/test.sh
    rm -f phast-${VER}/srcinput/driver.cpp
    find phast-${VER}/. -name '.cvsignore' -exec rm -f {} \;
    find phast-${VER}/. -type f | xargs chmod 644
else
    echo "PHAST TAGS:"
    cvs -d :ext:charlton@mackey:/usr/local/cvsroot history -T -n phast/srcphast | sed -e 's/.*\[\(.*\):.*/     \1/g'
    exit
fi

if tar cvzf phast-${VER}-${REL}.tar.gz phast-${VER}/; then
    rm -rf phast-${VER}
fi
