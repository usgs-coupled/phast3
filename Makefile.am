ACLOCAL_AMFLAGS = -I m4
EXTRA_DIST = INSTALL NOTICE README RELEASE
SUBDIRS = src examples doc

NOTICE : $(top_srcdir)/doc/NOTICE.TXT
	cp $(top_srcdir)/doc/NOTICE.TXT $(top_srcdir)/NOTICE

README : $(top_srcdir)/doc/README
	cp $(top_srcdir)/doc/README $(top_srcdir)/README

RELEASE : $(top_srcdir)/src/phast/revisions
	cp $(top_srcdir)/src/phast/revisions $(top_srcdir)/RELEASE
