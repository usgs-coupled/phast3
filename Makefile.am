ACLOCAL_AMFLAGS=-I m4
EXTRA_DIST=\
	cmake/FindMPI.cmake\
	cmake/FindPackageHandleStandardArgs.cmake\
	cmake/FindPackageMessage.cmake\
	CMakeLists.txt\
	database/CMakeLists.txt\
	environment.yml\
	INSTALL\
	NOTICE\
	README\
	RELEASE
SUBDIRS=doc examples src test

# Docs
#
databasedir=$(datadir)/doc/$(PACKAGE_TARNAME)-$(VERSION)/database

dist_database_DATA=$(DATABASE)

DATABASE=\
	database/Amm.dat\
	database/ColdChem.dat\
	database/Concrete_PHR.dat\
	database/Concrete_PZ.dat\
	database/core10.dat\
	database/frezchem.dat\
	database/iso.dat\
	database/Kinec_v3.dat\
	database/Kinec.v2.dat\
	database/llnl.dat\
	database/minteq.dat\
	database/minteq.v4.dat\
	database/phast.dat\
	database/phreeqc_rates.dat\
	database/PHREEQC_ThermoddemV1.10_15Dec2020.dat\
	database/pitzer.dat\
	database/sit.dat\
	database/stimela.dat\
	database/Tipping_Hurley.dat\
	database/wateq4f.dat
