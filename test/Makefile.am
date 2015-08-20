# Tests
#

TESTS = phrqex11

EXTRA_DIST = $(TESTS)

TESTS_ENVIRONMENT = top_srcdir=$(top_srcdir) \
                    PATH=.$(PATH_SEPARATOR)../src/phastinput$(PATH_SEPARATOR)../src/phast$(PATH_SEPARATOR)$$PATH \
                    PHAST=`echo phast-@PHAST_SUFFIX@|sed '$(transform)'` \
                    PHASTINPUT=`echo phastinput|sed '$(transform)'` \
                    DATADIR=$(top_builddir)/examples \
                    DBDIR=$(top_srcdir)/database

PHRQEX11=\
	$(top_builddir)/examples/phrqex11/phrqex11.bal.txt \
	$(top_builddir)/examples/phrqex11/phrqex11.chem.txt \
	$(top_builddir)/examples/phrqex11/phrqex11_1.chem.xyz.tsv \
	$(top_builddir)/examples/phrqex11/phrqex11.head.txt \
	$(top_builddir)/examples/phrqex11/phrqex11_1.h5 \
	$(top_builddir)/examples/phrqex11/phrqex11.log.txt \
	$(top_builddir)/examples/phrqex11/phrqex11.probdef.txt \
	$(top_builddir)/examples/phrqex11/phrqex11.wt.xyz.tsv \
	$(top_builddir)/examples/phrqex11/phrqex11.vel.xyz.tsv \
	$(top_builddir)/examples/phrqex11/phrqex11.head.xyz.tsv \
	$(top_builddir)/examples/phrqex11/phrqex11_1.intermediate.h5 \
	$(top_builddir)/test/Phast.tmp

CLEANFILES=$(PHRQEX11)
