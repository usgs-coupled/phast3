#!/bin/sh
#
# Requirements:
#
# o Visual Studio 2005
# o Intel(R) Fortran Compiler >= 9.1
# o Visual Studio 6 w/ (SP >= SP5)
# o Visual Fortran 6.1.A
# o ModelViewer 1.3
# o jdk >= 1.4.1
# o hdf5 >= 1.6.5
# o htmlhelp
# o cygwin
# o   sh/bash
# o   tar
# o   bzip
# o   gzip
# o   tar
# o   patch
# o   ant
# o   locate
# o   diff
# o   unix2dos
#
#
# build using:
# time ./phast-1.0-1.sh all 2>&1 | tee phast-1.0-1.sh.build.log
#
##################################################################

# echo everything
set -x

# find out where the build script is located
tdir=`echo "$0" | sed 's%[\\/][^\\/][^\\/]*$%%'`
test "x$tdir" = "x$0" && tdir=.
scriptdir=`cd $tdir; pwd`
# find src directory.  
# If scriptdir ends in SPECS, then topdir is $scriptdir/.. 
# If scriptdir ends in CYGWIN-PATCHES, then topdir is $scriptdir/../..
# Otherwise, we assume that topdir = scriptdir
topdir1=`echo ${scriptdir} | sed 's%/SPECS$%%'`
topdir2=`echo ${scriptdir} | sed 's%/CYGWIN-PATCHES$%%'`
if [ "x$topdir1" != "x$scriptdir" ] ; then # SPECS
  topdir=`cd ${scriptdir}/..; pwd`
else
  if [ "x$topdir2" != "x$scriptdir" ] ; then # CYGWIN-PATCHES
    topdir=`cd ${scriptdir}/../..; pwd`
  else
    topdir=`cd ${scriptdir}; pwd`
  fi
fi

tscriptname=`basename $0 .sh`
export PKG=`echo $tscriptname | sed -e 's/\-[^\-]*\-[^\-]*$//'`
export VER=`echo $tscriptname | sed -e "s/${PKG}\-//" -e 's/\-[^\-]*$//'`
export REL=`echo $tscriptname | sed -e "s/${PKG}\-${VER}\-//"`
export MAJOR=`echo $VER | sed -e 's/\.[^.]*//g'`
export MINOR=`echo $VER | sed -e 's/[^\.]*\.//' -e 's/\.[^\.]*//'`
export PATCH=`echo $VER | sed -e 's/[^\.]*\.//' -e 's/\.[^\.]*//' -e 's/[^\.]*\.//'`
export BASEPKG=${PKG}-${VER}-${REL}
export FULLPKG=${BASEPKG}
LOWER='abcdefghijklmnopqrstuvwxyz'
UPPER='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
export VER_UC=`echo $VER | sed -e "y/$LOWER/$UPPER/"`
export DIFF_IGNORE="-x *.aps -x *.ncb -x *.opt"

export src_orig_pkg_name=${FULLPKG}.tar.gz
export src_pkg_name=${FULLPKG}-src.tar.bz2
export src_patch_name=${FULLPKG}.patch
export bin_pkg_name=${FULLPKG}.tar.bz2
export src_orig_pkg=${topdir}/${src_orig_pkg_name}
export src_pkg=${topdir}/${src_pkg_name}
export src_patch=${topdir}/${src_patch_name}
export bin_pkg=${topdir}/${bin_pkg_name}
export srcdir=${topdir}/${BASEPKG}
export objdir=${srcdir}/.build
export instdir=${srcdir}/.inst
export srcinstdir=${srcdir}/.sinst
export checkfile=${topdir}/${FULLPKG}.check
export cvstag=version-`echo "${VER}" | sed -e 's/\./_/g'`
# run on
host=i686-pc-cygwin
# if this package creates binaries, they run on
target=i686-pc-cygwin
prefix=/${PKG}-${VER}
sysconfdir=/etc
MY_CFLAGS="-O2 -g"
MY_LDFLAGS=


# use Visual C++ 6.0 for Model Viewer
MSDEV="msdev.exe"

# use Ant to compile PHASTHDF export
ANT="ant"

# use Visual Studio 2005 to compile
DEVENV="devenv.exe"
PHAST_SLN=`cygpath -w ./src/phast/win32_2005/phastpp.sln`
PHASTINPUT_SLN=`cygpath -w ./src/phastinput/vc80/phastinput.sln`
PHASTHDF_SLN=`cygpath -w ./src/phasthdf/win32/phastexport.sln`
MSI_SLN=`cygpath -w ./msi/msi.sln`
BOOT_SLN=`cygpath -w ./PhastBootstrapper/PhastBootstrapper.sln`

# Modelviewer 
export MODELVIEWER_1_3="/cygdrive/c/Program Files/USGS/Model Viewer 1.3/"

# Examples
EXAMPLES="
 diffusion1d \
 diffusion2d \
 disp2d \
 ex1 \
 ex2 \
 ex3 \
 ex4 \
 ex4_ddl \
 ex4_noedl \
 ex4restart \
 ex4_start_time \
 ex4_transient \
 kindred4.4 \
 leaky \
 leakysurface \
 leakyx \
 leakyz \
 linear_bc \
 linear_ic \
 phrqex11 \
 property \
 radial \
 river \
 shell \
 simple \
 unconf \
 well \
 zf"

mkdirs() {
  (cd ${topdir} && \
  mkdir -p ${objdir} && \
  mkdir -p ${instdir} && \
  mkdir -p ${srcinstdir} )
}

precheck() {
  (
  if [ ! -s "`which ${DEVENV}`" ] ; then \
    echo "Error: Can't find Microsoft Visual Studio 8 (2005): ${DEVENV}"; \
    exit 1; \
  fi && \
  if [ ! -s "`which ${MSDEV}`" ] ; then \
    echo "Error: Can't find Microsoft Visual C++ 6.0: ${MSDEV}"; \
    exit 1; \
  fi && \
  if [ ! -s "`which ${ANT}`" ] ; then \
    echo "Error: Can't find ANT: ${ANT}"; \
    exit 1; \
  fi && \
#
# PHASTPP PreReqs
#
  if [ "x$BOOSTROOT" = "x" ] ; then \
    echo "Error: BOOSTROOT must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_GMP_LIB_MT" = "x" ] ; then \
    echo "Error: DEV_GMP_LIB_MT must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_HDF5_INC" = "x" ] ; then \
    echo "Error: DEV_HDF5_INC must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_HDF5_LIBDLL" = "x" ] ; then \
    echo "Error: DEV_HDF5_LIBDLL must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_MPICH2_INC" = "x" ] ; then \
    echo "Error: DEV_MPICH2_INC must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_MPICH2_LIB" = "x" ] ; then \
    echo "Error: DEV_MPICH2_LIB must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_ZLIB122_INC" = "x" ] ; then \
    echo "Error: DEV_ZLIB122_INC must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_ZLIB122_LIB" = "x" ] ; then \
    echo "Error: DEV_ZLIB122_LIB must be set"; \
    exit 1; \
  fi && \
#
# phasthdf PreReqs
#
  if [ "x$JAVA_HOME" = "x" ] ; then \
    echo "Error: JAVA_HOME must be set for ant"; \
    exit 1; \
  fi && \
#
# Model Viewer PreReqs
#
  if [ "x$DEV_VTK_40_INC" = "x" ] ; then \
    echo "Error: DEV_VTK_40_INC must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_VTK_40_LIB" = "x" ] ; then \
    echo "Error: DEV_VTK_40_LIB must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_HTMLHELP_INC" = "x" ] ; then \
    echo "Error: DEV_HTMLHELP_INC must be set"; \
    exit 1; \
  fi && \
  if [ "x$DEV_HTMLHELP_LIB" = "x" ] ; then \
    echo "Error: DEV_HTMLHELP_LIB must be set"; \
    exit 1; \
  fi && \
  if [ ! -d "${MODELVIEWER_1_3}" ] ; then \
    echo "Error: ${MODELVIEWER_1_3} not found"; \
    echo "Error: ModelViewer must be installed"; \
    exit 1; \
  fi )
}

prep() {
  (cd ${topdir} && \
  tar xvzf ${src_orig_pkg} && \
  cd ${topdir}/${FULLPKG} && \
  cd ${topdir} && \
  if [ -f ${src_patch} ] ; then \
    patch -p0 --binary < ${src_patch} ;\
  fi && \
  mkdirs )
}

conf() {
  (cd ${objdir} && \
  rm -rf * && \
# copy links to ${objdir} for building
  find ${srcdir} -mindepth 1 -maxdepth 1 ! -name .build ! -name .inst ! -name .sinst -exec cp -al {} . \; )
}

build() {
  (cd ${objdir} && \
### build phasthdf.exe
##  "${DEVENV}" "${PHASTHDF_SLN}"   /out phasthdf.log         /build "Release|Win32" && \
# build phasthdf.exe x64
  "${DEVENV}" "${PHASTHDF_SLN}"   /out phasthdf-x64.log     /build "Release|x64" && \
### build phastinput.exe
##  "${DEVENV}" "${PHASTINPUT_SLN}" /out phastinput.log       /build "Release|Win32" && \
### build phastinput.exe x64
##  "${DEVENV}" "${PHASTINPUT_SLN}" /out phastinput-x64.log   /build "Release|x64" && \
# build phast.jar
  cp -f ./src/phasthdf/build.xml.in ./src/phasthdf/build.xml
  "${ANT}" -buildfile ./src/phasthdf/build.xml dist-Win32 && \
  "${ANT}" -buildfile ./src/phasthdf/build.xml dist-Win64 && \
### build merge/phast.exe
##  "${DEVENV}" "${PHAST_SLN}"      /out phast-merge.log      /build "merge|Win32" && \
### build merge/phast.exe x64
##  "${DEVENV}" "${PHAST_SLN}"      /out phast-merge-x64.log  /build "merge|x64" && \
### build ser/phast.exe
##  "${DEVENV}" "${PHAST_SLN}"      /out phast-ser.log        /build "ser|Win32" && \
### build ser/phast.exe x64
##  "${DEVENV}" "${PHAST_SLN}"      /out phast-ser-x64.log    /build "ser|x64" && \
### build model viewer
##  "${MSDEV}" `cygpath -w ./ModelViewer/MvProject.dsw` /MAKE "ModelViewer - Win32 Release" /REBUILD && \
### build phast.msi
##  MSBuild.exe "${MSI_SLN}" /t:msi /p:Configuration=Release /p:Platform=x86 /p:TargetName=${FULLPKG}     /p:Major=${MAJOR} /p:Minor=${MINOR} /p:Build=${REL} && \
# build phast.msi x64
  MsBuild.exe "${MSI_SLN}" /t:msi /p:Configuration=Release /p:Platform=x64 /p:TargetName=${FULLPKG}-x64 /p:Major=${MAJOR} /p:Minor=${MINOR} /p:Patch=${PATCH} /p:Build=${REL}  && \
# build phast.msi x64
  MsBuild.exe "${BOOT_SLN}" /t:PhastBootstrapper /p:Configuration=Release /p:Platform=x64 /p:TargetName=${FULLPKG}-x64 /p:Major=${MAJOR} /p:Minor=${MINOR} /p:Patch=${PATCH} /p:Build=${REL} )
}


check() {
  (cd ${objdir} && \
# TODO (ie make test | tee ${checkfile} 2>&1)
  echo Check complete. )
}

clean() {
  (cd ${objdir} && \
# clean phasthdf.exe
  "${DEVENV}" "${PHASTHDF_SLN}" /Clean Release && \
# clean phastinput.exe
  "${DEVENV}" "${PHASTINPUT_SLN}" /Clean Release && \
# clean phast.jar
  "${ANT}" -buildfile ./src/phasthdf/build.xml clean && \
# clean merge/phast.exe
  "${DEVENV}" "${PHAST_SLN}" /Clean merge && \
# clean ser/phast.exe
  "${DEVENV}" "${PHAST_SLN}" /Clean ser && \
# clean model viewer
  "${MSDEV}" `cygpath -w ./ModelViewer/MvProject.dsw` /MAKE "ModelViewer - Win32 Release" /CLEAN && \
# clean phast.msi
  MSBuild.exe "${MSI_SLN}" /t:Clean /p:Configuration=Release /p:TargetName=${FULLPKG} /p:Major=${MAJOR} /p:Minor=${MINOR} /p:Build=${REL} && \
  rm -rf msi/bin && \
  rm -rf msi/obj )
}

install() {
  (rm -rf ${instdir}/* && \
# logs
  /usr/bin/install -m 755 ${objdir}/phasthdf.log \
    ${instdir}/. && \
  /usr/bin/install -m 755 ${objdir}/phasthdf-x64.log \
    ${instdir}/. && \
  /usr/bin/install -m 644 ${objdir}/phastinput.log \
    ${instdir}/. && \
  /usr/bin/install -m 644 ${objdir}/phastinput-x64.log \
    ${instdir}/. && \
  /usr/bin/install -m 644 ${objdir}/phast-ser.log \
    ${instdir}/. && \
  /usr/bin/install -m 644 ${objdir}/phast-ser-x64.log \
    ${instdir}/. && \
  /usr/bin/install -m 644 ${objdir}/phast-merge.log \
    ${instdir}/. && \
  /usr/bin/install -m 644 ${objdir}/phast-merge-x64.log \
    ${instdir}/. && \
  /usr/bin/install -m 644 ${objdir}/ModelViewer/mv/mv.plg \
    ${instdir}/. && \
# the MSI
  /usr/bin/install -m 755 "${objdir}/msi/bin/Release/${FULLPKG}.msi" \
    ${instdir}/. && \
# the x64 MSI
  /usr/bin/install -m 755 "${objdir}/msi/bin/x64/Release/${FULLPKG}-x64.msi" \
    ${instdir}/. && \
# md5sums    
  if [ -x /usr/bin/md5sum ]; then \
    cd ${instdir} && \
    find . -type f ! -name md5sum | sed 's/^/\"/' | sed 's/$/\"/' | xargs md5sum > md5sum ; \
  fi )    
}

run_examples() {
  (EXAMPLES="${instdir}${prefix}/examples/ex1 \
  ${instdir}${prefix}/examples/ex4"
  for arg in $EXAMPLES; do
    cd ${arg}
    export TD="`cygpath -w -s "${instdir}${prefix}"`" && \
    ${instdir}${prefix}/bin/${PKG}.bat `basename ${arg}`;
    if [ $? != 0 ] ; then
      exit $?;
    fi
  done )
}

strip() {
  (cd ${instdir} && \
  echo No need to strip )
}

pkg() {
  (cd ${instdir} && \
  tar cvjf ${bin_pkg} * )
}

mkpatch() {
  (cd ${srcdir} && \
  tar xvzf ${src_orig_pkg} && \
  cd ${srcdir}/${BASEPKG} && \
  cd ${srcdir} && \
  mv ${BASEPKG} ../${BASEPKG}-orig && \
  cd ${topdir} && \
  diff -urN -x '.build' -x '.inst' -x '.sinst' \
    ${DIFF_IGNORE} \
    ${BASEPKG}-orig ${BASEPKG} > \
    ${srcinstdir}/${src_patch_name} ; \
  rm -rf ${BASEPKG}-orig )
}

spkg() {
  (mkpatch && \
  cp -al ${src_orig_pkg} ${srcinstdir}/${src_orig_pkg_name} && \
  cp -al $0 ${srcinstdir}/`basename $0` && \
  cp Makefile ${srcinstdir}/. && \
  cd ${srcinstdir} && \
  tar cvjf ${src_pkg} * )
}

finish() {
  rm -rf ${srcdir} 
}

case $1 in
  precheck)     precheck ; STATUS=$? ;;
  checkout)     checkout ; STATUS=$? ;;
  dbuild)       dbuild   ; STATUS=$? ;;
  dmkpatch)     dmkpatch ; STATUS=$? ;;
  prep)	        prep     ; STATUS=$? ;;
  conf)	        conf     ; STATUS=$? ;;
  build)        build    ; STATUS=$? ;;
  check)        check    ; STATUS=$? ;;
  clean)        clean    ; STATUS=$? ;;
  install)      install  ; STATUS=$? ;;
  strip)        strip    ; STATUS=$? ;;
  package)      pkg      ; STATUS=$? ;;
  pkg)          pkg      ; STATUS=$? ;;
  mkpatch)      mkpatch  ; STATUS=$? ;;
  src-package)  spkg     ; STATUS=$? ;;
  spkg)         spkg     ; STATUS=$? ;;
  finish)       finish   ; STATUS=$? ;;
  cvsexport)    cvsexport; STATUS=$? ;;
  svnexport)    svnexport; STATUS=$? ;;
  run)          run_examples;  STATUS=$? ;;
  upto-conf)    precheck && prep && conf; STATUS=$? ;;
  upto-build)   precheck && prep && conf && build; STATUS=$? ;;
  upto-install) precheck && prep && conf && build && install; STATUS=$? ;;
  upto-pkg)     precheck && prep && conf && build && install && \
			strip && pkg ; \
			STATUS=$? ;;
  upto-spkg)    precheck && prep && conf && build && install && \
			strip && pkg && spkg ; \
			STATUS=$? ;;
  all) precheck && prep && conf && build && install && \
       strip && pkg && spkg && finish ; \
       STATUS=$? ;;
  sofar)  precheck && prep && conf && build && install && \
       STATUS=$? ;;
  *) echo "Error: bad arguments" ; exit 1 ;;
esac
exit ${STATUS}
