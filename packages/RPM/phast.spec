# $Id: phast.spec,v 1.5 2004/12/22 09:10:12 charlton Exp $
#

Summary: A 3D Reaction-Transport Model based on PHREEQC and HST3D
Name: phast
Version: @VERSION@
Release: @RELEASE@
Vendor: USGS
License: None
Group: Applications/Modeling
Source0: %{name}-%{version}-%{release}.tar.gz
URL: http://wwwbrr.cr.usgs.gov/projects/GWC_coupled
BuildRoot: %{_tmppath}/phast-%{version}-root
Prefix: %{_usr}

%description
PHAST -- A Program for Simulating Ground-Water Flow,
Solute Transport, and Multicomponent Geochemical
Reactions

# Don't build debug packages
%define _enable_debug_packages 0
%define debug_package %{nil}

# Fix for rpmbuild 4.4.8
%define _docdir_fmt %{NAME}-%{VERSION}

# Solaris /bin/id doesn't have id -u option
%ifarch usparc
%define __id   /usr/xpg4/bin/id
%endif

%prep
%setup -n %{name}-%{version}-%{release}

# 
# Rearrange files
#
rm -f doc/README.dist
mv src/phast/phreeqc.revisions  ./doc/.
%build

#
# build phastinput
#
cd src/phastinput
make
cd ../..

#
# build phasthdf
#
cd src/phasthdf
cp build.xml.in build.xml
ant dist-Linux
cd ../..

#
# build phast-ser phast-lam and phast-openmpi
#
ssh grundvand "cd $RPM_BUILD_DIR/$RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION-$RPM_PACKAGE_RELEASE/src/phast && make serial_intel"
ssh grundvand "cd $RPM_BUILD_DIR/$RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION-$RPM_PACKAGE_RELEASE/src/phast && make openmpi_intel"
ssh stoch     "cd $RPM_BUILD_DIR/$RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION-$RPM_PACKAGE_RELEASE/src/phast && make lam_intel"

%install
rm -rf $RPM_BUILD_ROOT

#
# Linux /usr/bin
# SunOS /usr/local/bin
#
mkdir -p  $RPM_BUILD_ROOT/%{_bindir}

#
# Linux /usr/lib/phast-%{version}/Linux
# SunOS /usr/local/lib/phast-%{version}/SunOS
#
mkdir -p  $RPM_BUILD_ROOT/%{_libdir}/phast-%{version}/`uname`

#
# prep to run examples for archive
#
mkdir -p test
cp -alr examples/* test/.

#
# prep to dist source files
#
tar xvzf $RPM_SOURCE_DIR/%{name}-%{version}-%{release}.tar.gz %{name}-%{version}-%{release}/src
find %{name}-%{version}-%{release}/src -type d -name win32 -print | xargs rm -rf
find %{name}-%{version}-%{release}/src -type d -name win32_2005 -print | xargs rm -rf
find %{name}-%{version}-%{release}/src -type d -name Sun -print | xargs rm -rf
find %{name}-%{version}-%{release}/src/phasthdf/. -type f -name ".nbattrs" -print | xargs rm -rf
rm -f %{name}-%{version}-%{release}/src/Makefile.am
rm -f %{name}-%{version}-%{release}/src/phast/Makefile.am
rm -f %{name}-%{version}-%{release}/src/phasthdf/Makefile.am
rm -f %{name}-%{version}-%{release}/src/phasthdf/phasthdf.in
mv %{name}-%{version}-%{release}/src/phasthdf/build.xml.in %{name}-%{version}-%{release}/src/phasthdf/build.xml
rm -rf %{name}-%{version}-%{release}/src/phasthdf/hdf-java
rm -rf %{name}-%{version}-%{release}/src/phasthdf/test
rm -f %{name}-%{version}-%{release}/src/phastinput/Makefile.am
rm -f %{name}-%{version}-%{release}/src/phast/phreeqc/distribution.checklist
rm -f %{name}-%{version}-%{release}/src/phast/phreeqc/distribution.mk
rm -f %{name}-%{version}-%{release}/src/phast/phreeqc/Makefile
rm -f %{name}-%{version}-%{release}/doc/Makefile.am
rm -f %{name}-%{version}-%{release}/doc/phast.pdf
rm -rf %{name}-%{version}-%{release}/database/EPRI
rm -rf %{name}-%{version}-%{release}/database/isotopes
rm -rf %{name}-%{version}-%{release}/database/SIT
rm -rf %{name}-%{version}-%{release}/database/redox


#
# Linux /usr/bin/phast-ser
# SunOS /usr/local/bin/phast-ser
#
# Linux /usr/bin/phast-lam
# SunOS None
#
cp src/phast/serial_intel/phast $RPM_BUILD_ROOT/%{_bindir}/phast-ser
cp src/phast/lam_intel/phast $RPM_BUILD_ROOT/%{_bindir}/phast-lam
cp src/phast/openmpi_intel/phast $RPM_BUILD_ROOT/%{_bindir}/phast-openmpi

#
# Linux /usr/bin/phastinput
# SunOS /usr/local/bin/phastinput
#
cp src/phastinput/phastinput $RPM_BUILD_ROOT/%{_bindir}/phastinput

#
# Phast/hdf jar's
#
# Linux /usr/lib/phast-%{version}/*.jar
# SunOS /usr/local/lib/phast-%{version}/*.jar
#
cp src/phasthdf/dist/*.jar $RPM_BUILD_ROOT/%{_libdir}/phast-%{version}/.

#
# Phast/hdf so's
#
# Linux /usr/lib/phast-%{version}Linux/*.so
# SunOS /usr/local/lib/phast-%{version}/SunOS/*.so
#
cp src/phasthdf/dist/`uname`/* $RPM_BUILD_ROOT/%{_libdir}/phast-%{version}/`uname`/.

#
# Create script to run phast
#
cat > $RPM_BUILD_ROOT/%{_bindir}/phast <<EOF
#!/bin/sh

#
# Script used to run phast.
# This script assumes that the two phast binaries
# (phastinput and phast-ser) are located
# in the same directory as this script.
#

# resolve symlinks (to determine BIN_DIR)
prg=\$0
while [ -h "\$prg" ] ; do
    ls=\`ls -ld "\$prg"\`
    link=\`expr "\$ls" : '.*-> \(.*\)$'\`
    if expr "\$link" : '[^/].*' > /dev/null; then
        prg="\`dirname \$prg\`/\$link"
    else
        prg="\$link"
    fi
done

# directory where executables are located
BIN_DIR=\`dirname \$prg\`

# run
\$BIN_DIR/phastinput \$* && \$BIN_DIR/phast-ser
EOF
chmod 755 $RPM_BUILD_ROOT/%{_bindir}/phast


#
# Create script to run phasthdf
#
cat > $RPM_BUILD_ROOT/%{_bindir}/phasthdf <<EOF
#!/bin/sh

#
# Script used to run phasthdf.
#

# resolve symlinks (to determine BIN_DIR)
prg=\$0
while [ -h "\$prg" ] ; do
    ls=\`ls -ld "\$prg"\`
    link=\`expr "\$ls" : '.*-> \(.*\)$'\`
    if expr "\$link" : '[^/].*' > /dev/null; then
        prg="\`dirname \$prg\`/\$link"
    else
        prg="\$link"
    fi
done

# directory where jars located
JARS=\`dirname \$prg\`
JARS=\$JARS/../lib/phast-%{version}

# define native shared objects
if [ -z "\$LD_LIBRARY_PATH" ]; then
    LD_LIBRARY_PATH=\$JARS/\`uname\`
else
    LD_LIBRARY_PATH=\$JARS/\`uname\`:\$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

# start java vm (version >= 1.2)
java -jar \$JARS/phast.jar \$* &
EOF
chmod 755 $RPM_BUILD_ROOT/%{_bindir}/phasthdf

####
#### run and store examples
####
###for arg in `find test -mindepth 1 -maxdepth 1 -type d`; do
###  cd $arg
###  $RPM_BUILD_ROOT/%{_bindir}/phast `basename $arg`
###  cd ../..
###done
###tar cvzf $RPM_SOURCE_DIR/%{name}-%{version}-%{release}-`uname`-test.tar.gz test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc README RELEASE NOTICE examples database doc %{name}-%{version}-%{release}/src
%{_bindir}/*
%{_libdir}/*

%changelog
