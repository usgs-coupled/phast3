# $Id: phast.spec,v 1.5 2004/12/22 09:10:12 charlton Exp $
#

Summary: A 3D Reaction-Transport Model based on PHREEQC and HST3D
Name: phast
Version: @VERSION@
Release: @RELEASE@
Vendor: USGS
License: None
Group: Applications/Modeling
#####Source0: %{name}-%{version}-%{release}.tar.gz
Source0: %{name}-%{version}.tar.gz
#####Patch0: %{name}-%{version}-%{release}-Makefile.David.patch
URL: http://wwwbrr.cr.usgs.gov/projects/GWC_coupled
BuildRoot: %{_tmppath}/phast-%{version}-root
Prefix: %{_usr}

%description
PHAST -- A Program for Simulating Ground-Water Flow,
Solute Transport, and Multicomponent Geochemical
Reactions

# Solaris /bin/id doesn't have id -u option
%ifarch usparc
%define __id   /usr/xpg4/bin/id
%endif

%prep
%setup -q

###%ifarch usparc
###echo "Patch #0:"
###patch -p1 srcphast/Makefile.David < $RPM_SOURCE_DIR/%{name}-%{version}-%{release}-Makefile.David.patch
###%else
###%patch0 -p1
###%endif

# 
# Rearrange files
#
mv doc/README .
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
ant dist-Linux
cd ../..

#
# build phast-ser and phast-lam
#
cd src/phast
make serial_absoft
make mpi_absoft
cd ../..

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
# src/phast src/phastinput src/phasthdf test
# for
#   Linux /usr/share/doc/phast-1.0/src
#   SunOS /usr/local/doc/phast-1.0/src
#
####mkdir src
####cd src
####tar xvzf $RPM_SOURCE_DIR/%{name}-%{version}-%{release}.tar.gz
####mv %{name}-%{version}/srcphast ./phast
####rm -f phast/revisions phast/phast.rev
####mv %{name}-%{version}/srcinput ./phastinput
####rm -f phastinput/rivtest.c phastinput/d4ordr.c
####mv %{name}-%{version}/export ./phastexport
####mv %{name}-%{version}/examples ../test
####rm -rf %{name}-%{version}
####find . -name '.cvsignore' -exec echo rm {} \;
####cd ..
mkdir -p test
cp -alr examples/* test/.

#
# Linux /usr/bin/phast-ser
# SunOS /usr/local/bin/phast-ser
#
# Linux /usr/bin/phast-lam
# SunOS None
#
cp src/phast/serial_absoft/phast $RPM_BUILD_ROOT/%{_bindir}/phast-ser
cp src/phast/mpi_absoft/phast $RPM_BUILD_ROOT/%{_bindir}/phast-lam

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

#
# run and store examples
#
for arg in test/*; do
  cd $arg
  echo $RPM_BUILD_ROOT/%{_bindir}/phast `basename $arg`
  cd ../..
done
tar cvzf $RPM_SOURCE_DIR/%{name}-%{version}-%{release}-`uname`-test.tar.gz test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc README examples database doc src
%{_bindir}/*
%{_libdir}/*

%changelog
