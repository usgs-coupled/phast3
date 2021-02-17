EXTRA_DIST = CMakeLists.txt

# Docs
#
docdir = $(datadir)/doc/$(PACKAGE_TARNAME)-$(VERSION)

dist_doc_DATA = $(DOCS)

DOCS= \
    phast2-TM6-A35.pdf \
    phreeqc2.pdf \
    phreeqc3.pdf \
    wrir02-4172.pdf \
    phreeqc.RELEASE.txt \
    RELEASE.txt

$(srcdir)/phreeqc.RELEASE.txt:
	cd $(srcdir) && $(LN_S) phreeqc3-doc/RELEASE.TXT phreeqc.RELEASE.txt

$(srcdir)/RELEASE.txt:
	cd $(srcdir) && $(LN_S) ../RELEASE RELEASE.txt
