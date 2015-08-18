# Tests
#

testdir = $(docdir)/test

TESTS = phrqex11

EXTRA_DIST = $(TESTS)

TESTS_ENVIRONMENT = top_srcdir=$(top_srcdir) \
                    PATH=.$(PATH_SEPARATOR)../src/phastinput$(PATH_SEPARATOR)../src/phast$(PATH_SEPARATOR)$$PATH \
                    PHAST=`echo phast-openmp|sed '$(transform)'` \
                    PHASTINPUT=`echo phastinput|sed '$(transform)'` \
                    DATADIR=$(top_srcdir)/examples \
                    DBDIR=$(top_srcdir)/database


PHRQEX11=


CLEANFILES=$(PHRQEX11)
