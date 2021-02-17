##########################################################################
# Build the tar.gz for building with configure/make.                     #
##########################################################################

NAME ?= phast

UPDATE := $(shell svn up ../..)

REL := $(shell svn st -v ../../configure.ac | cut -b 10- | ( read one two ; echo $$one ) )

EXPORT := $(NAME)-export-$(VER)-$(REL).tar.gz

TARBALL := $(NAME)-$(VER)-$(REL).tar.gz

REPOS_PATH ?= trunk

all : $(TARBALL)
	@echo "DATE=$(DATE)"               >> history
	@echo "VER=$(VER)"                 >> history
	@echo "PHREEQC_VER=$(PHREEQC_VER)" >> history
	@echo "REL=$(REL)"                 >> history
	@echo "==================="        >> history

$(TARBALL) : $(EXPORT)
	rm -rf $(NAME)-$(VER)-$(REL)
	tar xvzf $(NAME)-export-$(VER)-$(REL).tar.gz
	cd $(NAME)-$(VER)-$(REL) && sed -e "s/AC_INIT(.*)/AC_INIT([phast], [$(VER)-$(REL)], [dlpark@usgs.gov])/" < configure.ac > configure.ac.tmp
	cd $(NAME)-$(VER)-$(REL) && mv -f configure.ac.tmp configure.ac
	cd $(NAME)-$(VER)-$(REL) && autoreconf -fvi
	cd $(NAME)-$(VER)-$(REL) && mkdir _build
	cd $(NAME)-$(VER)-$(REL) && cd _build && ../configure
	cd $(NAME)-$(VER)-$(REL) && cd _build && $(MAKE) distcheck
	cd $(NAME)-$(VER)-$(REL) && cd _build && cp $(NAME)-$(VER)-$(REL).tar.gz ../..
	rm -rf $(NAME)-$(VER)-$(REL)

$(EXPORT) : ../RPM/dist.sh
ifeq ($(DATE),)
	$(error usage: make DATE=<m/d/yyyy> VER=<x.y.z> PHREEQC_VER=<x.y.z> [REL=x])
endif
ifeq ($(VER),)
	$(error usage: make DATE=<m/d/yyyy> VER=<x.y.z> PHREEQC_VER=<x.y.z> [REL=x])
endif
ifeq ($(PHREEQC_VER),)
	$(error usage: make DATE=<m/d/yyyy> VER=<x.y.z> PHREEQC_VER=<x.y.z> [REL=x])
endif
	@echo "Creating $(NAME)-export-$(VER)-$(REL).tar.gz"
	rm -f $(NAME)-export-$(VER)-$(REL).tar.gz
	time ../RPM/dist.sh -v $(VER) -vp $(PHREEQC_VER) -r $(REL) -d $(DATE) -pr $(REPOS_PATH) 2>&1 | tee export-$(REL).log
	mv $(TARBALL) $(NAME)-export-$(VER)-$(REL).tar.gz

usage:
	@echo ""
	@echo "usage: make DATE=<m/d/yyyy> VER=<x.y.z> PHREEQC_VER=<x.y.z>  [REL=x]"
	@echo "    ie make DATE=8/9/2010 VER=2.0.0 PHREEQC_VER=2.17.4"
	@echo "    ie make DATE=8/9/2010 VER=2.0.0 PHREEQC_VER=2.17.4 REL=4000"
	@echo ""
