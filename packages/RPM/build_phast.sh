#!/bin/sh
# Build phast rpm
# Note rpm --macros option doesn't seem to work

case `uname` in
    "Linux")
	RPMRC=/usr/lib/rpm/rpmrc:`pwd`/rpmrc
	time rpm --rcfile=$RPMRC -ba SPECS/phast.spec
	;;	
    "SunOS")
	RPMRC=/usr/local/lib/rpm/rpmrc:`pwd`/rpmrc
	time rpm --rcfile $RPMRC -ba SPECS/phast.spec
	;;
esac
