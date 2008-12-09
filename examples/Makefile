CFG1 :=`uname`
CFG :=$(shell echo $(CFG1) | sed "s/CYGWIN.*/CYGWIN/")

ifeq ($(CFG), Linux)
  TOPDIR=$(HOME)/programs/phastpp
  TEST=$(TOPDIR)/examples
  PHAST_INPUT=$(TOPDIR)/srcinput/phastinput
#  PHAST_INPUT=$(TOPDIR)/../phast_bc/srcinput-wedge/phastinput
#  PHAST=$(TOPDIR)/srcphast/serial_gfortran/phast
#  PHAST=$(TOPDIR)/srcphast/serial_g95/phast
  PHAST=$(TOPDIR)/srcphast/serial_lahey/phast
#  PHAST=$(TOPDIR)/../phast_bc/srcphast/serial_lahey/phast
  RUN=$(TEST)/run
endif

ifeq ($(CFG), CYGWIN)
  TOPDIR=/cygdrive/c/programs/phastpp
  TEST=$(TOPDIR)/examples
  PHAST_INPUT=/cygdrive/c/Programs/phastpp/srcinput/win32_2005/Debug/phastinput.exe
#  PHAST_INPUT=/cygdrive/c/Programs/phastpp/srcinput-wedge/win32_2005/Debug/phastinput.exe
  PHAST=/cygdrive/c/Programs/phastpp/srcphast/win32_2005/ser/phast.exe
  PHAST_MPICH=c:/Programs/phastpp/srcphast/win32_2005/merge_debug/phast.exe
  PHAST_MPICH=c:/Programs/phastpp/srcphast/win32_2005/merge/phast.exe
  RUN=$(TEST)/runmpich
endif

SERIAL = decay diffusion1d diffusion2d disp2d ex3 kindred4.4 leaky leakyx leakyz linear_bc linear_ic ex4 notch phrqex11 ex1 radial river unconf well ex2 free ex4restart print_check_ss print_check_transient ex4_start_time mass_balance simple ex4_noedl ex4_ddl ex4_transient leakysurface flux_patches patches_lf zf property

PARALLEL =  decay_parallel diffusion1d_parallel diffusion2d_parallel disp2d_parallel ex3_parallel kindred4.4_parallel leaky_parallel leakyx_parallel leakyz_parallel linear_bc_parallel linear_ic_parallel ex4_parallel notch_parallel phrqex11_parallel ex1_parallel radial_parallel river_parallel unconf_parallel well_parallel ex2_parallel free_parallel ex4restart_parallel print_check_ss_parallel print_check_transient_parallel  ex4_start_time_parallel mass_balance_parallel simple_parallel ex4_noedl_parallel ex4_ddl_parallel ex4_transient_parallel leakysurface_parallel flux_patches_parallel patches_lf_parallel zf_parallel property_parallel

CLEAN_SERIAL = decay_clean diffusion1d_clean diffusion2d_clean disp2d_clean ex3_clean \
	kindred4.4_clean leaky_clean leakyx_clean leakyz_clean \
	linear_bc_clean linear_ic_clean ex4_clean notch_clean phrqex11_clean ex1_clean \
	radial_clean river_clean unconf_clean well_clean ex2_clean free_clean \
	ex4restart_clean print_check_ss_clean print_check_transient_clean ex4_start_time_clean \
	mass_balance_clean simple_clean ex4_noedl_clean ex4_ddl_clean ex4_transient_clean leakysurface_clean \
	flux_patches_clean patches_lf_clean

CLEAN_PARALLEL = decay_clean_parallel diffusion1d_clean_parallel diffusion2d_clean_parallel \
	disp2d_clean_parallel ex3_clean_parallel kindred4.4_clean_parallel \
	leaky_clean_parallel leakyx_clean_parallel leakyz_clean_parallel \
	linear_bc_clean_parallel linear_ic_clean_parallel ex4_clean_parallel notch_clean_parallel \
	phrqex11_clean_parallel ex1_clean_parallel radial_clean_parallel \
	river_clean_parallel unconf_clean_parallel well_clean_parallel ex2_clean_parallel \
	free_clean_parallel \
	ex4restart_clean_parallel print_check_ss_clean_parallel print_check_transient_clean_parallel \
	ex4_start_time_clean_parallel mass_balance_clean_parallel simple_clean_parallel \
	ex4_noedl_clean_parallel ex4_ddl_clean_parallel ex4_transient_clean_parallel leakysurface_clean_parallel \
	flux_patches_clean_parallel patches_lf_clean_parallel

CLEAN_CMD =  rm -f *~ *.O.* *.log *.h5 *.h5~ abs* *.h5dump *.sel *.xyz* *backup* *.txt *.tsv Phast.tmp 

all: $(PARALLEL) $(SERIAL) 

serial: $(SERIAL)

parallel: $(PARALLEL)

#
# ex2
#
ex2: ex2_clean
	echo ; 
	echo ============= ex2
	echo ; 
	cd $(TEST)/ex2
	cd $(TEST)/ex2; $(PHAST_INPUT) ex2; time $(PHAST)
	echo ============= Done ex2

ex2_parallel: ex2_clean_parallel
	echo ; 
	echo ============= ex2 Parallel
	echo ; 
	$(RUN) ex2
	echo ============= Done ex2 Parallel

ex2_clean:
	cd $(TEST)/ex2; $(CLEAN_CMD)

ex2_clean_parallel:
	@if [ -d $(TEST)/ex2/0 ]; \
	  then \
	  find $(TEST)/ex2/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# free
#
free: free_clean
	echo ; 
	echo ============= free
	echo ; 
	cd $(TEST)/free
	cd $(TEST)/free; $(PHAST_INPUT) free; time $(PHAST)
	echo ============= Done free

free_parallel: free_clean_parallel
	echo ; 
	echo ============= free Parallel
	echo ; 
	$(RUN) free
	echo ============= Done free Parallel

free_clean:
	cd $(TEST)/free; $(CLEAN_CMD)

free_clean_parallel:
	@if [ -d $(TEST)/free/0 ]; \
	  then \
	  find $(TEST)/free/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# decay
#
decay: decay_clean
	echo ; 
	echo ============= decay
	echo ; 
	cd $(TEST)/decay;
	cd $(TEST)/decay; $(PHAST_INPUT) decay; time $(PHAST)
	echo ============= Done decay

decay_parallel: decay_clean_parallel
	echo ; 
	echo ============= decay Parallel
	echo ; 
	$(RUN) decay
	echo ============= Done decay Parallel

decay_clean:
	cd $(TEST)/decay; $(CLEAN_CMD)


decay_clean_parallel:
	@if [ -d $(TEST)/decay/0 ]; \
	  then \
	  find $(TEST)/decay/0 -maxdepth 1 -type f | xargs rm -f; \
	fi
#
# simple
#
simple: simple_clean
	echo ; 
	echo ============= simple
	echo ; 
	cd $(TEST)/simple;
	cd $(TEST)/simple; $(PHAST_INPUT) simple; time $(PHAST)
	echo ============= Done simple

simple_parallel: simple_clean_parallel
	echo ; 
	echo ============= simple Parallel
	echo ; 
	$(RUN) simple
	echo ============= Done simple Parallel

simple_clean:
	cd $(TEST)/simple; $(CLEAN_CMD)


simple_clean_parallel:
	@if [ -d $(TEST)/simple/0 ]; \
	  then \
	  find $(TEST)/simple/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# diffusion1d
#
diffusion1d: diffusion1d_clean
	echo ; 
	echo ============= diffusion1d
	echo ; 
	cd $(TEST)/diffusion1d;
	cd $(TEST)/diffusion1d; $(PHAST_INPUT) diffusion1d; time $(PHAST)
	echo ============= Done diffusion1d

diffusion1d_parallel: diffusion1d_clean_parallel
	echo ; 
	echo ============= diffusion1d Parallel
	echo ; 
	$(RUN) diffusion1d
	echo ============= Done diffusion1d Parallel

diffusion1d_clean:
	cd $(TEST)/diffusion1d; $(CLEAN_CMD)

diffusion1d_clean_parallel:
	@if [ -d $(TEST)/diffusion1d/0 ]; \
	  then \
	  find $(TEST)/diffusion1d/0 -maxdepth 1 -type f | xargs rm -f; \
	fi
#
# diffusion2d
#
diffusion2d: diffusion2d_clean
	echo ; 
	echo ============= diffusion2d
	echo ; 
	cd $(TEST)/diffusion2d;
	cd $(TEST)/diffusion2d; $(PHAST_INPUT) diffusion2d; time $(PHAST)
	echo ============= Done diffusion2d

diffusion2d_parallel: diffusion2d_clean_parallel
	echo ; 
	echo ============= diffusion2d Parallel
	echo ; 
	$(RUN) diffusion2d
	echo ============= Done diffusion2d Parallel

diffusion2d_clean:
	cd $(TEST)/diffusion2d; $(CLEAN_CMD)

diffusion2d_clean_parallel:
	@if [ -d $(TEST)/diffusion2d/0 ]; \
	  then \
	  find $(TEST)/diffusion2d/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# disp2d
#
disp2d: disp2d_clean
	echo ; 
	echo ============= disp2d
	echo ; 
	cd $(TEST)/disp2d;
	cd $(TEST)/disp2d; $(PHAST_INPUT) disp2d; time $(PHAST)
	echo ============= Done disp2d

disp2d_parallel: disp2d_clean_parallel
	echo ; 
	echo ============= disp2d Parallel
	echo ; 
	$(RUN) disp2d
	echo ============= Done disp2d Parallel

disp2d_clean:
	cd $(TEST)/disp2d; $(CLEAN_CMD)

disp2d_clean_parallel:
	@if [ -d $(TEST)/disp2d/0 ]; \
	  then \
	  find $(TEST)/disp2d/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# kindred4.1
#
ex3: ex3_clean
	echo ; 
	echo ============= ex3
	echo ; 
	cd $(TEST)/ex3;
	cd $(TEST)/ex3; $(PHAST_INPUT) ex3; time $(PHAST)
	echo ============= Done ex3

ex3_parallel: ex3_clean_parallel
	echo ; 
	echo ============= ex3 Parallel
	echo ; 
	$(RUN) ex3
	echo ============= Done ex3 Parallel

ex3_clean:
	cd $(TEST)/ex3; $(CLEAN_CMD)

ex3_clean_parallel:
	@if [ -d $(TEST)/ex3/0 ]; \
	  then \
	  find $(TEST)/ex3/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# kindred4.4
#
kindred4.4: kindred4.4_clean
	echo ; 
	echo ============= kindred4.4
	echo ; 
	cd $(TEST)/kindred4.4;
	cd $(TEST)/kindred4.4; $(PHAST_INPUT) kindred4.4; time $(PHAST)
	echo ============= Done kindred4.4

kindred4.4_parallel: kindred4.4_clean_parallel
	echo ; 
	echo ============= kindred4.4 Parallel
	echo ; 
	$(RUN) kindred4.4
	echo ============= Done kindred4.4 Parallel

kindred4.4_clean:
	cd $(TEST)/kindred4.4; $(CLEAN_CMD)

kindred4.4_clean_parallel:
	@if [ -d $(TEST)/kindred4.4/0 ]; \
	  then \
	  find $(TEST)/kindred4.4/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# leaky
#
leaky: leaky_clean
	echo ; 
	echo ============= leaky
	echo ; 
	cd $(TEST)/leaky;
	cd $(TEST)/leaky; $(PHAST_INPUT) leaky; time $(PHAST)
	echo ============= Done leaky

leaky_parallel: leaky_clean_parallel
	echo ; 
	echo ============= leaky Parallel
	echo ; 
	$(RUN) leaky
	echo ============= Done leaky Parallel

leaky_clean:
	cd $(TEST)/leaky; $(CLEAN_CMD)

leaky_clean_parallel:
	@if [ -d $(TEST)/leaky/0 ]; \
	  then \
	  find $(TEST)/leaky/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# leakyx
#
leakyx: leakyx_clean
	echo ; 
	echo ============= leakyx
	echo ; 
	cd $(TEST)/leakyx;
	cd $(TEST)/leakyx; $(PHAST_INPUT) leakyx; time $(PHAST)
	echo ============= Done leakyx

leakyx_parallel: leakyx_clean_parallel
	echo ; 
	echo ============= leakyx Parallel
	echo ; 
	$(RUN) leakyx
	echo ============= Done leakyx Parallel

leakyx_clean:
	cd $(TEST)/leakyx; $(CLEAN_CMD)

leakyx_clean_parallel:
	@if [ -d $(TEST)/leakyx/0 ]; \
	  then \
	  find $(TEST)/leakyx/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# leakyz
#
leakyz: leakyz_clean
	echo ; 
	echo ============= leakyz
	echo ; 
	cd $(TEST)/leakyz;
	cd $(TEST)/leakyz; $(PHAST_INPUT) leakyz; time $(PHAST)
	echo ============= Done leakyz

leakyz_parallel: leakyz_clean_parallel
	echo ; 
	echo ============= leakyz Parallel
	echo ; 
	$(RUN) leakyz
	echo ============= Done leakyz Parallel

leakyz_clean:
	cd $(TEST)/leakyz; $(CLEAN_CMD)

leakyz_clean_parallel:
	@if [ -d $(TEST)/leakyz/0 ]; \
	  then \
	  find $(TEST)/leakyz/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# leakysurface
#
leakysurface: leakysurface_clean
	echo ; 
	echo ============= leakysurface
	echo ; 
	cd $(TEST)/leakysurface;
	cd $(TEST)/leakysurface; $(PHAST_INPUT) leakysurface; time $(PHAST)
	echo ============= Done leakysurface

leakysurface_parallel: leakysurface_clean_parallel
	echo ; 
	echo ============= leakysurface Parallel
	echo ; 
	$(RUN) leakysurface
	echo ============= Done leakysurface Parallel

leakysurface_clean:
	cd $(TEST)/leakysurface; $(CLEAN_CMD)

leakysurface_clean_parallel:
	@if [ -d $(TEST)/leakysurface/0 ]; \
	  then \
	  find $(TEST)/leakysurface/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# patches_lf
#
patches_lf: patches_lf_clean
	echo ; 
	echo ============= patches_lf
	echo ; 
	cd $(TEST)/patches_lf;
	cd $(TEST)/patches_lf; $(PHAST_INPUT) patches_lf; time $(PHAST)
	echo ============= Done patches_lf

patches_lf_parallel: patches_lf_clean_parallel
	echo ; 
	echo ============= patches_lf Parallel
	echo ; 
	$(RUN) patches_lf
	echo ============= Done patches_lf Parallel

patches_lf_clean:
	cd $(TEST)/patches_lf; $(CLEAN_CMD)

patches_lf_clean_parallel:
	@if [ -d $(TEST)/patches_lf/0 ]; \
	  then \
	  find $(TEST)/patches_lf/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# flux_patches
#
flux_patches: flux_patches_clean
	echo ; 
	echo ============= flux_patches
	echo ; 
	cd $(TEST)/flux_patches;
	cd $(TEST)/flux_patches; $(PHAST_INPUT) flux_patches; time $(PHAST)
	echo ============= Done flux_patches

flux_patches_parallel: flux_patches_clean_parallel
	echo ; 
	echo ============= flux_patches Parallel
	echo ; 
	$(RUN) flux_patches
	echo ============= Done flux_patches Parallel

flux_patches_clean:
	cd $(TEST)/flux_patches; $(CLEAN_CMD)

flux_patches_clean_parallel:
	@if [ -d $(TEST)/flux_patches/0 ]; \
	  then \
	  find $(TEST)/flux_patches/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# linear_bc
#
linear_bc: linear_bc_clean
	echo ; 
	echo ============= linear_bc
	echo ; 
	cd $(TEST)/linear_bc;
	cd $(TEST)/linear_bc; $(PHAST_INPUT) linear_bc; time $(PHAST)
	echo ============= Done linear_bc

linear_bc_parallel: linear_bc_clean_parallel
	echo ; 
	echo ============= linear_bc Parallel
	echo ; 
	$(RUN) linear_bc
	echo ============= Done linear_bc Parallel

linear_bc_clean:
	cd $(TEST)/linear_bc; $(CLEAN_CMD)

linear_bc_clean_parallel:
	@if [ -d $(TEST)/linear_bc/0 ]; \
	  then \
	  find $(TEST)/linear_bc/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# linear_ic
#
linear_ic: linear_ic_clean
	echo ; 
	echo ============= linear_ic
	echo ; 
	cd $(TEST)/linear_ic;
	cd $(TEST)/linear_ic; $(PHAST_INPUT) linear_ic; time $(PHAST)
	echo ============= Done linear_ic

linear_ic_parallel: linear_ic_clean_parallel
	echo ; 
	echo ============= linear_ic Parallel
	echo ; 
	$(RUN) linear_ic
	echo ============= Done linear_ic Parallel

linear_ic_clean:
	cd $(TEST)/linear_ic; $(CLEAN_CMD)

linear_ic_clean_parallel:
	@if [ -d $(TEST)/linear_ic/0 ]; \
	  then \
	  find $(TEST)/linear_ic/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# ok
#
ex4: ex4_clean
	echo ; 
	echo ============= ex4
	echo ; 
	cd $(TEST)/ex4;
	cd $(TEST)/ex4; $(PHAST_INPUT) ex4; time $(PHAST)
	echo ============= Done ex4

ex4_parallel: ex4_clean_parallel
	echo ; 
	echo ============= ex4 Parallel
	echo ; 
	$(RUN) ex4
	echo ============= Done ex4 Parallel

ex4_clean:
	cd $(TEST)/ex4; $(CLEAN_CMD) ex4.head.dat

ex4_clean_parallel:
	@if [ -d $(TEST)/ex4/0 ]; \
	  then \
	  find $(TEST)/ex4/0 -maxdepth 1 -type f | xargs rm -f; \
	fi
#
# ex4_noedl
#
ex4_noedl: ex4_noedl_clean
	echo ; 
	echo ============= ex4_noedl
	echo ; 
	cd $(TEST)/ex4_noedl;
	cd $(TEST)/ex4_noedl; $(PHAST_INPUT) ex4_noedl; time $(PHAST)
	echo ============= Done ex4_noedl

ex4_noedl_parallel: ex4_noedl_clean_parallel
	echo ; 
	echo ============= ex4_noedl Parallel
	echo ; 
	$(RUN) ex4_noedl
	echo ============= Done ex4_noedl Parallel

ex4_noedl_clean:
	cd $(TEST)/ex4_noedl; $(CLEAN_CMD) ex4_noedl.head.dat

ex4_noedl_clean_parallel:
	@if [ -d $(TEST)/ex4_noedl/0 ]; \
	  then \
	  find $(TEST)/ex4_noedl/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# ex4_ddl
#
ex4_ddl: ex4_ddl_clean
	echo ; 
	echo ============= ex4_ddl
	echo ; 
	cd $(TEST)/ex4_ddl;
	cd $(TEST)/ex4_ddl; $(PHAST_INPUT) ex4_ddl; time $(PHAST)
	echo ============= Done ex4_ddl

ex4_ddl_parallel: ex4_ddl_clean_parallel
	echo ; 
	echo ============= ex4_ddl Parallel
	echo ; 
	$(RUN) ex4_ddl
	echo ============= Done ex4_ddl Parallel

ex4_ddl_clean:
	cd $(TEST)/ex4_ddl; $(CLEAN_CMD) ex4_ddl.head.dat

ex4_ddl_clean_parallel:
	@if [ -d $(TEST)/ex4_ddl/0 ]; \
	  then \
	  find $(TEST)/ex4_ddl/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# ex4_transient
#
ex4_transient: ex4_transient_clean
	echo ; 
	echo ============= ex4_transient
	echo ; 
	cd $(TEST)/ex4_transient;
	cd $(TEST)/ex4_transient; $(PHAST_INPUT) ex4_transient; time $(PHAST)
	echo ============= Done ex4_transient

ex4_transient_parallel: ex4_transient_clean_parallel
	echo ; 
	echo ============= ex4_transient Parallel
	echo ; 
	$(RUN) ex4_transient
	echo ============= Done ex4_transient Parallel

ex4_transient_clean:
	cd $(TEST)/ex4_transient; $(CLEAN_CMD) ex4_transient.head.dat

ex4_transient_clean_parallel:
	@if [ -d $(TEST)/ex4_transient/0 ]; \
	  then \
	  find $(TEST)/ex4_transient/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# ex4_start_time
#
ex4_start_time: ex4_start_time_clean
	echo ; 
	echo ============= ex4_start_time
	echo ; 
	cd $(TEST)/ex4_start_time;
	cd $(TEST)/ex4_start_time; $(PHAST_INPUT) ex4_start_time; time $(PHAST)
	echo ============= Done ex4_start_time

ex4_start_time_parallel: ex4_start_time_clean_parallel
	echo ; 
	echo ============= ex4_start_time Parallel
	echo ; 
	$(RUN) ex4_start_time
	echo ============= Done ex4_start_time Parallel

ex4_start_time_clean:
	cd $(TEST)/ex4_start_time; $(CLEAN_CMD) ex4_start_time.head.dat

ex4_start_time_clean_parallel:
	@if [ -d $(TEST)/ex4_start_time/0 ]; \
	  then \
	  find $(TEST)/ex4_start_time/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# ex4restart
#
ex4restart: ex4restart_clean
	echo ; 
	echo ============= ex4restart
	echo ; 
	cd $(TEST)/ex4restart;
	cd $(TEST)/ex4restart; $(PHAST_INPUT) ex4restart; time $(PHAST)
	echo ============= Done ex4restart

ex4restart_parallel: ex4restart_clean_parallel
	echo ; 
	echo ============= ex4restart Parallel
	echo ; 
	$(RUN) ex4restart
	echo ============= Done ex4restart Parallel

ex4restart_clean:
	cd $(TEST)/ex4restart; $(CLEAN_CMD) ex4restart.restart

ex4restart_clean_parallel:
	@if [ -d $(TEST)/ex4restart/0 ]; \
	  then \
	  find $(TEST)/ex4restart/0 -maxdepth 1 -type f | xargs rm -f; \
	fi
#
# Notch
#
notch: notch_clean
	echo ; 
	echo ============= notch
	echo ; 
	cd $(TEST)/notch;
	cd $(TEST)/notch; $(PHAST_INPUT) notch; time $(PHAST)
	echo ============= Done notch

notch_parallel: notch_clean_parallel
	echo ; 
	echo ============= notch Parallel
	echo ; 
	$(RUN) notch
	echo ============= Done notch Parallel

notch_clean:
	cd $(TEST)/notch; $(CLEAN_CMD) notch.head.dat

notch_clean_parallel:
	@if [ -d $(TEST)/notch/0 ]; \
	  then \
	  find $(TEST)/notch/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# mass_balance
#
mass_balance: mass_balance_clean
	echo ; 
	echo ============= mass_balance
	echo ; 
	cd $(TEST)/mass_balance;
	cd $(TEST)/mass_balance; $(PHAST_INPUT) mass_balance; time $(PHAST)
	echo ============= Done mass_balance

mass_balance_parallel: mass_balance_clean_parallel
	echo ; 
	echo ============= mass_balance Parallel
	echo ; 
	$(RUN) mass_balance
	echo ============= Done mass_balance Parallel

mass_balance_clean:
	cd $(TEST)/mass_balance; $(CLEAN_CMD) mass_balance.head.dat

mass_balance_clean_parallel:
	@if [ -d $(TEST)/mass_balance/0 ]; \
	  then \
	  find $(TEST)/mass_balance/0 -maxdepth 1 -type f | xargs rm -f; \
	fi
#
# print_check_ss
#
print_check_ss: print_check_ss_clean
	echo ; 
	echo ============= print_check_ss
	echo ; 
	cd $(TEST)/print_check_ss;
	cd $(TEST)/print_check_ss; $(PHAST_INPUT) print_check_ss; time $(PHAST)
	echo ============= Done print_check_ss

print_check_ss_parallel: print_check_ss_clean_parallel
	echo ; 
	echo ============= print_check_ss Parallel
	echo ; 
	$(RUN) print_check_ss
	echo ============= Done print_check_ss Parallel

print_check_ss_clean:
	cd $(TEST)/print_check_ss; $(CLEAN_CMD) print_check_ss.restart

print_check_ss_clean_parallel:
	@if [ -d $(TEST)/print_check_ss/0 ]; \
	  then \
	  find $(TEST)/print_check_ss/0 -maxdepth 1 -type f | xargs rm -f; \
	fi
#
# print_check_transient
#
print_check_transient: print_check_transient_clean
	echo ; 
	echo ============= print_check_transient
	echo ; 
	cd $(TEST)/print_check_transient;
	cd $(TEST)/print_check_transient; $(PHAST_INPUT) print_check_transient; time $(PHAST)
	echo ============= Done print_check_transient

print_check_transient_parallel: print_check_transient_clean_parallel
	echo ; 
	echo ============= print_check_transient Parallel
	echo ; 
	$(RUN) print_check_transient
	echo ============= Done print_check_transient Parallel

print_check_transient_clean:
	cd $(TEST)/print_check_transient; $(CLEAN_CMD) print_check_transient.restart

print_check_transient_clean_parallel:
	@if [ -d $(TEST)/print_check_transient/0 ]; \
	  then \
	  find $(TEST)/print_check_transient/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# phrqex11
#
phrqex11: phrqex11_clean
	echo ; 
	echo ============= phrqex11
	echo ; 
	cd $(TEST)/phrqex11;
	cd $(TEST)/phrqex11; $(PHAST_INPUT) phrqex11; time $(PHAST)
	echo ============= Done phrqex11

phrqex11_parallel: phrqex11_clean_parallel
	echo ; 
	echo ============= phrqex11 Parallel
	echo ; 
	$(RUN) phrqex11
	echo ============= Done phrqex11 Parallel

phrqex11_clean:
	cd $(TEST)/phrqex11; $(CLEAN_CMD)

phrqex11_clean_parallel:
	@if [ -d $(TEST)/phrqex11/0 ]; \
	  then \
	  find $(TEST)/phrqex11/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# ex1
#
ex1: ex1_clean
	echo ; 
	echo ============= ex1
	echo ; 
	cd $(TEST)/ex1;
	cd $(TEST)/ex1; $(PHAST_INPUT) ex1; time $(PHAST)
	echo ============= Done ex1

ex1_parallel: ex1_clean_parallel
	echo ; 
	echo ============= ex1 Parallel
	echo ; 
	$(RUN) ex1
	echo ============= Done ex1 Parallel

ex1_clean:
	cd $(TEST)/ex1; $(CLEAN_CMD)

ex1_clean_parallel:
	@if [ -d $(TEST)/ex1/0 ]; \
	  then \
	  find $(TEST)/ex1/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# radial
#
radial: radial_clean
	echo ; 
	echo ============= radial
	echo ; 
	cd $(TEST)/radial;
	cd $(TEST)/radial; $(PHAST_INPUT) radial; time $(PHAST)
	echo ============= Done radial

radial_parallel: radial_clean_parallel
	echo ; 
	echo ============= radial Parallel
	echo ; 
	$(RUN) radial
	echo ============= Done radial Parallel

radial_clean:
	cd $(TEST)/radial; $(CLEAN_CMD)

radial_clean_parallel:
	@if [ -d $(TEST)/radial/0 ]; \
	  then \
	  find $(TEST)/radial/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# river
#
river: river_clean
	echo ; 
	echo ============= river
	echo ; 
	cd $(TEST)/river;
	cd $(TEST)/river; $(PHAST_INPUT) river; time $(PHAST)
	echo ============= Done river

river_parallel: river_clean_parallel
	echo ; 
	echo ============= river Parallel
	echo ; 
	$(RUN) river
	echo ============= Done river Parallel

river_clean:
	cd $(TEST)/river; $(CLEAN_CMD)

river_clean_parallel:
	@if [ -d $(TEST)/river/0 ]; \
	  then \
	  find $(TEST)/river/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# unconf
#
unconf: unconf_clean
	echo ; 
	echo ============= unconf
	echo ; 
	cd $(TEST)/unconf;
	cd $(TEST)/unconf; $(PHAST_INPUT) unconf; time $(PHAST)
	echo ============= Done unconf

unconf_parallel: unconf_clean_parallel
	echo ; 
	echo ============= unconf Parallel
	echo ; 
	$(RUN) unconf
	echo ============= Done unconf Parallel

unconf_clean:
	cd $(TEST)/unconf; $(CLEAN_CMD)

unconf_clean_parallel:
	@if [ -d $(TEST)/unconf/0 ]; \
	  then \
	  find $(TEST)/unconf/0 -maxdepth 1 -type f | xargs rm -f; \
	fi

#
# well
#
well: well_clean
	echo ; 
	echo ============= well
	echo ; 
	cd $(TEST)/well;
	cd $(TEST)/well; $(PHAST_INPUT) well; time $(PHAST)
	echo ============= Done well

well_parallel: well_clean_parallel
	echo ; 
	echo ============= well Parallel
	echo ; 
	$(RUN) well
	echo ============= Done well Parallel

well_clean:
	cd $(TEST)/well; $(CLEAN_CMD)

well_clean_parallel:
	@if [ -d $(TEST)/well/0 ]; \
	  then \
	  find $(TEST)/well/0  -maxdepth 1 -type f  | xargs rm -f; \
	fi

#
# zone budget
#
zf: zf_clean
	echo ; 
	echo ============= zf
	echo ; 
	cd $(TEST)/zf;
	cd $(TEST)/zf; $(PHAST_INPUT) zf; time $(PHAST)
	echo ============= Done zf

zf_parallel: zf_clean_parallel
	echo ; 
	echo ============= zf Parallel
	echo ; 
	$(RUN) zf
	echo ============= Done zf Parallel

zf_clean:
	cd $(TEST)/zf; $(CLEAN_CMD)

zf_clean_parallel:
	@if [ -d $(TEST)/zf/0 ]; \
	  then \
	  find $(TEST)/zf/0  -maxdepth 1 -type f  | xargs rm -f; \
	fi

#
# Property definitions
#
property: property_clean
	echo ; 
	echo ============= property
	echo ; 
	cd $(TEST)/property;
	cd $(TEST)/property; $(PHAST_INPUT) property; time $(PHAST)
	echo ============= Done property

property_parallel: property_clean_parallel
	echo ; 
	echo ============= property Parallel
	echo ; 
	$(RUN) property
	echo ============= Done property Parallel

property_clean:
	cd $(TEST)/property; $(CLEAN_CMD)

property_clean_parallel:
	@if [ -d $(TEST)/property/0 ]; \
	  then \
	  find $(TEST)/property/0  -maxdepth 1 -type f  | xargs rm -f; \
	fi

clean: clean_serial clean_parallel
	rm -f all.out

clean_serial: $(CLEAN_SERIAL)
	rm -f make.out serial.out diff.out diff

clean_parallel: $(CLEAN_PARALLEL)
	rm -f make.out parallel.out diff.out diff

#ci: $(CI_PROBLEMS)

diff_parallel:
	#rcsdiff -bw ./*/0/*
	for DIR in $(SERIAL); \
		do diff -r $$DIR $$DIR/0; \
		done;

ci_parallel:
	for FILE in $(SERIAL); do \
		cd $$FILE/0; ci -l -m"latest" *.dat *.O.* *.xyz.* Phast.tmp; cd ../..; done

diff:
	svn diff --diff-cmd diff -x -bw	

zero:
	for DIR in $(SERIAL); \
		do echo $$DIR; cd $$DIR; \
			for FILE in *.txt *.tsv Phast.tmp; \
				do \
					if [ -f $$FILE ]; then \
						echo "   " $$FILE; \
						../zero.sed $$FILE; \
					fi; \
				done; \
			cd ..; \
		done;

zero_parallel:
	for DIR in $(SERIAL); \
		do echo $$DIR; cd $$DIR/0; \
			for FILE in *.txt *.tsv Phast.tmp; \
				do \
					if [ -f $$FILE ]; then \
						echo "   " $$FILE; \
						../../zero.sed $$FILE; \
					fi; \
				done; \
			cd ../..; \
		done;

zero1:
	for DIR in $(SERIAL); \
		do echo $$DIR; cd $$DIR; \
			for FILE in *.txt *.tsv; \
				do \
					if [ -f $$FILE ]; then \
						echo "   " $$FILE; \
						../zero1.sed $$FILE; \
					fi; \
				done; \
			cd ..; \
		done;

zero1_parallel:
	for DIR in $(SERIAL); \
		do echo $$DIR; cd $$DIR/0; \
			for FILE in *.txt *.tsv; \
				do \
					if [ -f $$FILE ]; then \
						echo "   " $$FILE; \
						../../zero1.sed $$FILE; \
					fi; \
				done; \
			cd ../..; \
		done;

mpich:
#	echo $(CFG)
#	echo $(TOPDIR)
#	echo $(PHAST)
#	echo $(PHAST_MPICH)
	for DIR in $(SERIAL); \
		do cd $$DIR; \
			mkdir -p 0; \
			cp -f *.trans.dat 0; \
			if [ -f $$DIR.chem.dat ]; then cp *.chem.dat phast.dat 0; fi;\
			if [ -f $$DIR.head.dat ]; then cp *.head.dat 0; fi;\
			if [ -f ex4.restart ]; then cp ex4.restart 0; fi;\
			cd 0; \
			$(PHAST_INPUT) $$DIR; \
			time mpirun -np 2 -localonly -dir $(TEST)/$$DIR/0 $(PHAST_MPICH); \
			cd $(TEST); \
		done;

tester:
	make -f Makefile clean
	make -f Makefile all >& all.out
	make -f Makefile zero zero1 zero_parallel zero1_parallel >> all.out
	make -f Makefile diff >& diff.out
	make -f Makefile diff_parallel >& diff_parallel.out
