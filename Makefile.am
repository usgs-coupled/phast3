ACLOCAL_AMFLAGS = -I m4
EXTRA_DIST = CMakeLists.txt INSTALL NOTICE README RELEASE database/CMakeLists.txt
SUBDIRS = doc examples src

# Docs
#
databasedir=$(datadir)/doc/$(PACKAGE_TARNAME)-$(VERSION)/database

dist_database_DATA=$(DATABASE)

DATABASE=\
	database/Amm.dat\
	database/frezchem.dat\
	database/iso.dat\
	database/llnl.dat\
	database/minteq.dat\
	database/minteq.v4.dat\
	database/phast.dat\
	database/pitzer.dat\
	database/sit.dat\
	database/wateq4f.dat
