MYNAME	= patchi
OBJECTS= patchi.o subs.o
F77		= f77
F77_LD		= $(F77)
FFLAGS=   -g -c -C 
LD_FFLAGS	= -lc -lm

.SUFFIXES:	.f
.f.o:
	f77 $(FFLAGS)  $<
patchi: $(OBJECTS)
	$(F77_LD)  -o $(MYNAME) $(LD_LIB1) $(OBJECTS) $(LD_FFLAGS)
	mv patchi ..
