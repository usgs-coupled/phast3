EXTRA_DIST = CMakeLists.txt

# Docs
#
docdir = $(datadir)/doc/$(PACKAGE_TARNAME)-$(VERSION)

dist_doc_DATA = $(DOCS)

DOCS= \
    phast2-TM6-A35.pdf \
    phreeqc.pdf \
    wrir02-4172.pdf \
    phreeqc.revisions

$(srcdir)/phreeqc.revisions:
	cd $(srcdir) && $(LN_S) phreeqc3-doc/RELEASE.TXT phreeqc.revisions
