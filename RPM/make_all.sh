#!/bin/sh
# Build phast rpms

# Linux version
./build_phast.sh  2>&1 | tee phast-rc3.spec.srv2rcolkr.log

# Sun version
TOPDIR=~charlton/phast/RPM
ssh sunarcolkr ". ~/.kshrc; cd $TOPDIR; ./build_phast.sh  2>&1 | tee phast-rc3.spec.sunarcolkr.log"
