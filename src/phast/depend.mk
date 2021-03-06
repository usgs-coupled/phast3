FORTRAN_SOURCES:=$(shell find -name "*.f90" -o -name "*.F90" -o -name "*.f" | egrep -v "/Tests/" | egrep -v "module_dummy" | sed 's^\./^^g')

depend .depend:
	@makedepf90 $(FORTRAN_SOURCES) | sed 's/\.o/\.\$$\(OBJEXT\)/g' | sort > .depend
