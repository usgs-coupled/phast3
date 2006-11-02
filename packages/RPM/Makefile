##########################################################################
# Build an RPM from the current spec file and subversion directory tree. #
#                                                                        #
# Note: The RPM and Makefile are set up to GENERATE RPMS as a non-root   #
# user in the user's home directory.  Of course to INSTALL the resulting #
# binary RPM the user has to log in as root.                             #
##########################################################################

PHAST_TOP_DIR := $(shell pwd)/../..

SPECFILE := phast.spec

RPMDIR := rpms

NAME := $(shell grep '^Name:' < $(SPECFILE) | sed -e 's/^Name: //')

RELEASE := $(shell svn st -v $(SPECFILE) | cut -b 10- | ( read one two ; echo $$one ) )

TARBALL := $(NAME)-$(VERSION)-$(RELEASE).tar.gz

SOURCE_RPM_DIR := $(HOME)/$(RPMDIR)/sources/$(NAME)-$(VERSION)-$(RELEASE)

DIST_RPM := $(HOME)/$(RPMDIR)/rpms/i586/$(NAME)-$(VERSION)-$(RELEASE).i586.rpm

DIST_TARBALL := $(HOME)/$(RPMDIR)/rpms/i586/$(NAME)-$(VERSION)-$(RELEASE).`uname`.tar.gz

RPMDIRS := \
	$(HOME)/$(RPMDIR) \
	$(HOME)/$(RPMDIR)/build \
	$(HOME)/$(RPMDIR)/rpms \
	$(HOME)/$(RPMDIR)/rpms/i386 \
	$(HOME)/$(RPMDIR)/rpms/i486 \
	$(HOME)/$(RPMDIR)/rpms/i586 \
	$(HOME)/$(RPMDIR)/rpms/i686 \
	$(HOME)/$(RPMDIR)/rpms/noarch \
	$(HOME)/$(RPMDIR)/rpms/ppc \
	$(HOME)/$(RPMDIR)/rpms/sparc \
	$(HOME)/$(RPMDIR)/sources \
	$(HOME)/$(RPMDIR)/srpms \
	$(HOME)/$(RPMDIR)/tmp

all : rpm

phast rpm : check_release build_srpm_files build_rpm_files $(DIST_TARBALL)

check_release :
	@if [ "$(VERSION)"x = "x" ]; \
	  then \
		echo "Please specifiy VERSION with 'make VERSION=<number>'"; \
		exit 1; \
	    else \
		exit 0; \
	fi
	@if [ "$(RELEASE)"x = "x" ]; \
	   then \
		echo "Please specifiy RELEASE with 'make RELEASE=<number>'"; \
		exit 1; \
	    else \
		exit 0; \
	fi
	@if [ "$(DATE)"x = "x" ]; \
	   then \
		echo "Please specifiy DATE with 'make DATE=<number>'"; \
		exit 1; \
	    else \
		exit 0; \
	fi
	@echo "Making $(NAME)-$(VERSION)-$(RELEASE) (S)RPM ..."

$(DIST_TARBALL) : $(DIST_RPM)
	cd $(HOME)/$(RPMDIR)/rpms/i586; \
	rm -rf $(NAME)-$(VERSION); \
	mkdir -p $(NAME)-$(VERSION); \
	cd $(NAME)-$(VERSION); \
	rpm2cpio $(DIST_RPM) > $(NAME).cpio; \
	cpio -i -d < $(NAME).cpio; \
	rm -f $(NAME).cpio; \
	mv usr/* .; \
	rmdir usr; \
	mv share/doc/$(NAME)-$(VERSION)/* .; \
	rmdir share/doc/$(NAME)-$(VERSION); \
	rmdir share/doc; \
	rmdir share; \
	cd ..; \
	tar cvzf $(DIST_TARBALL) $(NAME)-$(VERSION); \
	rm -rf $(NAME)-$(VERSION)


build_rpm_files : build_srpm_files
	cd $(SOURCE_RPM_DIR); rpmbuild -ba $(SPECFILE)


build_srpm_files : $(HOME)/.rpmmacros $(HOME)/$(RPMDIR) $(SPECFILE) $(TARBALL)
	rm -rf $(SOURCE_RPM_DIR)
	mkdir -p $(SOURCE_RPM_DIR)
	cp $(TARBALL) Makefile dist.sh $(SOURCE_RPM_DIR)
	sed -e 's/@RELEASE@/$(RELEASE)/' \
		-e 's/@VERSION@/$(VERSION)/' \
		< $(SPECFILE) > $(SOURCE_RPM_DIR)/$(SPECFILE)

$(TARBALL) : dist.sh
	@echo "Creating $(TARBALL)"
	rm -f $(TARBALL)
	time ./dist.sh -v $(VERSION) -r $(RELEASE) -d $(DATE) -pr trunk 2>&1 | tee dist-$(RELEASE).log

$(HOME)/.rpmmacros : .rpmmacros
	@if [ ! -f $(HOME)/.rpmmacros ]; \
	   then \
	   echo "Creating $(HOME)/.rpmmacros"; \
	   sed -e 's;@RPMSDIR@;$(HOME)/$(RPMDIR);' < .rpmmacros > $(HOME)/.rpmmacros; \
	   fi

$(HOME)/$(RPMDIR) :
	@if [ ! -d $(HOME)/$(RPMDIR) ]; \
		then \
		for i in $(RPMDIRS); \
			do \
			echo "Making directory $$i"; \
			mkdir -p $$i; \
			done; \
	   fi
