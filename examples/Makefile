TOPDIR=$(HOME)/programs/phast
TEST=$(TOPDIR)/examples
PHAST_INPUT=$(TOPDIR)/srcinput/phastinput
PHAST=$(TOPDIR)/srcphast/serial_absoft/phast

SERIAL = decay disp2d ex3 kindred4.4 leaky leakyx leakyz linear_bc linear_ic ex4 phrqex11 ex1 radial river unconf well ex2 free

PARALLEL =  decay_parallel disp2d_parallel ex3_parallel kindred4.4_parallel leaky_parallel leakyx_parallel leakyz_parallel linear_bc_parallel linear_ic_parallel ex4_parallel phrqex11_parallel ex1_parallel radial_parallel river_parallel unconf_parallel well_parallel ex2_parallel free_parallel

SERIAL_COMPARE = decay_compare disp2d_compare ex3_compare kindred4.4_compare leaky_compare leakyx_compare leakyz_compare linear_bc_compare linear_ic_compare ex4_compare phrqex11_compare ex1_compare radial_compare river_compare unconf_compare well_compare ex2_compare free_compare

PARALLEL_COMPARE = decay_compare_parallel disp2d_compare_parallel ex3_compare_parallel kindred4.4_compare_parallel leaky_compare_parallel leakyx_compare_parallel leakyz_compare_parallel linear_bc_compare_parallel linear_ic_compare_parallel ex4_compare_parallel phrqex11_compare_parallel ex1_compare_parallel radial_compare_parallel river_compare_parallel unconf_compare_parallel well_compare_parallel ex2_compare_parallel free_compare_parallel

CLEAN_PROBLEMS = decay_clean disp2d_clean ex3_clean kindred4.4_clean leaky_clean leakyx_clean leakyz_clean \
	linear_bc_clean linear_ic_clean ex4_clean phrqex11_clean ex1_clean \
	radial_clean river_clean unconf_clean well_clean ex2_clean free_clean \
	decay_clean_parallel disp2d_clean_parallel ex3_clean_parallel kindred4.4_clean_parallel \
	leaky_clean_parallel leakyx_clean_parallel leakyz_clean_parallel \
	linear_bc_clean_parallel linear_ic_clean_parallel ex4_clean_parallel \
	phrqex11_clean_parallel ex1_clean_parallel radial_clean_parallel \
	river_clean_parallel unconf_clean_parallel well_clean_parallel ex2_clean_parallel \
	free_clean_parallel

CI_PROBLEMS = ci_decay ci_disp2d ci_ex3 ci_kindred4.4 ci_leaky ci_leakyx ci_leakyz ci_linear_bc ci_linear_ic ci_ex4 ci_phrqex11 ci_ex1 ci_radial ci_river ci_unconf ci_well ci_ex2 ci_free

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
	cd $(TEST)/ex2; ./clean
	cd $(TEST)/ex2; $(PHAST_INPUT) ex2; time $(PHAST)
	echo ============= Done ex2

ex2_parallel: ex2_clean_parallel
	echo ; 
	echo ============= ex2 Parallel
	echo ; 
	./run ex2
	echo ============= Done ex2 Parallel

ex2_clean:
	cd $(TEST)/ex2; ./clean

ex2_clean_parallel:
	cd $(TEST)/ex2; rm -rf [0-4]/*

#
# free
#
free: free_clean
	echo ; 
	echo ============= free
	echo ; 
	cd $(TEST)/free; ./clean
	cd $(TEST)/free; $(PHAST_INPUT) free; time $(PHAST)
	echo ============= Done free

free_parallel: free_clean_parallel
	echo ; 
	echo ============= free Parallel
	echo ; 
	./run free
	echo ============= Done free Parallel

free_clean:
	cd $(TEST)/free; ./clean

free_clean_parallel:
	cd $(TEST)/free; rm -rf [0-4]/*

#
# decay
#
decay: decay_clean
	echo ; 
	echo ============= decay
	echo ; 
	cd $(TEST)/decay; ./clean
	cd $(TEST)/decay; $(PHAST_INPUT) decay; time $(PHAST)
	echo ============= Done decay

decay_parallel: decay_clean_parallel
	echo ; 
	echo ============= decay Parallel
	echo ; 
	./run decay
	echo ============= Done decay Parallel

decay_clean:
	cd $(TEST)/decay; ./clean

decay_clean_parallel:
	cd $(TEST)/decay; rm -rf [0-4]/*

#
# disp2d
#
disp2d: disp2d_clean
	echo ; 
	echo ============= disp2d
	echo ; 
	cd $(TEST)/disp2d; ./clean
	cd $(TEST)/disp2d; $(PHAST_INPUT) disp2d; time $(PHAST)
	echo ============= Done disp2d

disp2d_parallel: disp2d_clean_parallel
	echo ; 
	echo ============= disp2d Parallel
	echo ; 
	./run disp2d
	echo ============= Done disp2d Parallel

disp2d_clean:
	cd $(TEST)/disp2d; ./clean

disp2d_clean_parallel:
	cd $(TEST)/disp2d; rm -rf [0-4]/*

#
# kindred4.1
#
ex3: ex3_clean
	echo ; 
	echo ============= ex3
	echo ; 
	cd $(TEST)/ex3; ./clean
	cd $(TEST)/ex3; $(PHAST_INPUT) ex3; time $(PHAST)
	echo ============= Done ex3

ex3_parallel: ex3_clean_parallel
	echo ; 
	echo ============= ex3 Parallel
	echo ; 
	./run ex3
	echo ============= Done ex3 Parallel

ex3_clean:
	cd $(TEST)/ex3; ./clean

ex3_clean_parallel:
	cd $(TEST)/ex3; rm -rf [0-4]/*

#
# kindred4.4
#
kindred4.4: kindred4.4_clean
	echo ; 
	echo ============= kindred4.4
	echo ; 
	cd $(TEST)/kindred4.4; ./clean
	cd $(TEST)/kindred4.4; $(PHAST_INPUT) kindred4.4; time $(PHAST)
	echo ============= Done kindred4.4

kindred4.4_parallel: kindred4.4_clean_parallel
	echo ; 
	echo ============= kindred4.4 Parallel
	echo ; 
	./run kindred4.4
	echo ============= Done kindred4.4 Parallel

kindred4.4_clean:
	cd $(TEST)/kindred4.4; ./clean

kindred4.4_clean_parallel:
	cd $(TEST)/kindred4.4; rm -rf [0-4]/*

#
# leaky
#
leaky: leaky_clean
	echo ; 
	echo ============= leaky
	echo ; 
	cd $(TEST)/leaky; ./clean
	cd $(TEST)/leaky; $(PHAST_INPUT) leaky; time $(PHAST)
	echo ============= Done leaky

leaky_parallel: leaky_clean_parallel
	echo ; 
	echo ============= leaky Parallel
	echo ; 
	./run leaky
	echo ============= Done leaky Parallel

leaky_clean:
	cd $(TEST)/leaky; ./clean

leaky_clean_parallel:
	cd $(TEST)/leaky; rm -rf [0-4]/*

#
# leakyx
#
leakyx: leakyx_clean
	echo ; 
	echo ============= leakyx
	echo ; 
	cd $(TEST)/leakyx; ./clean
	cd $(TEST)/leakyx; $(PHAST_INPUT) leakyx; time $(PHAST)
	echo ============= Done leakyx

leakyx_parallel: leakyx_clean_parallel
	echo ; 
	echo ============= leakyx Parallel
	echo ; 
	./run leakyx
	echo ============= Done leakyx Parallel

leakyx_clean:
	cd $(TEST)/leakyx; ./clean

leakyx_clean_parallel:
	cd $(TEST)/leakyx; rm -rf [0-4]/*


#
# leakyz
#
leakyz: leakyz_clean
	echo ; 
	echo ============= leakyz
	echo ; 
	cd $(TEST)/leakyz; ./clean
	cd $(TEST)/leakyz; $(PHAST_INPUT) leakyz; time $(PHAST)
	echo ============= Done leakyz

leakyz_parallel: leakyz_clean_parallel
	echo ; 
	echo ============= leakyz Parallel
	echo ; 
	./run leakyz
	echo ============= Done leakyz Parallel

leakyz_clean:
	cd $(TEST)/leakyz; ./clean

leakyz_clean_parallel:
	cd $(TEST)/leakyz; rm -rf [0-4]/*

#
# linear_bc
#
linear_bc: linear_bc_clean
	echo ; 
	echo ============= linear_bc
	echo ; 
	cd $(TEST)/linear_bc; ./clean
	cd $(TEST)/linear_bc; $(PHAST_INPUT) linear_bc; time $(PHAST)
	echo ============= Done linear_bc

linear_bc_parallel: linear_bc_clean_parallel
	echo ; 
	echo ============= linear_bc Parallel
	echo ; 
	./run linear_bc
	echo ============= Done linear_bc Parallel

linear_bc_clean:
	cd $(TEST)/linear_bc; ./clean

linear_bc_clean_parallel:
	cd $(TEST)/linear_bc; rm -rf [0-4]/*

#
# linear_ic
#
linear_ic: linear_ic_clean
	echo ; 
	echo ============= linear_ic
	echo ; 
	cd $(TEST)/linear_ic; ./clean
	cd $(TEST)/linear_ic; $(PHAST_INPUT) linear_ic; time $(PHAST)
	echo ============= Done linear_ic

linear_ic_parallel: linear_ic_clean_parallel
	echo ; 
	echo ============= linear_ic Parallel
	echo ; 
	./run linear_ic
	echo ============= Done linear_ic Parallel

linear_ic_clean:
	cd $(TEST)/linear_ic; ./clean

linear_ic_clean_parallel:
	cd $(TEST)/linear_ic; rm -rf [0-4]/*

#
# ok
#
ex4: ex4_clean
	echo ; 
	echo ============= ex4
	echo ; 
	cd $(TEST)/ex4; ./clean
	cd $(TEST)/ex4; $(PHAST_INPUT) ex4; time $(PHAST)
	echo ============= Done ex4

ex4_parallel: ex4_clean_parallel
	echo ; 
	echo ============= ex4 Parallel
	echo ; 
	./run ex4
	echo ============= Done ex4 Parallel

ex4_clean:
	cd $(TEST)/ex4; ./clean

ex4_clean_parallel:
	cd $(TEST)/ex4; rm -rf [0-4]/*

#
# phrqex11
#
phrqex11: phrqex11_clean
	echo ; 
	echo ============= phrqex11
	echo ; 
	cd $(TEST)/phrqex11; ./clean
	cd $(TEST)/phrqex11; $(PHAST_INPUT) phrqex11; time $(PHAST)
	echo ============= Done phrqex11

phrqex11_parallel: phrqex11_clean_parallel
	echo ; 
	echo ============= phrqex11 Parallel
	echo ; 
	./run phrqex11
	echo ============= Done phrqex11 Parallel

phrqex11_clean:
	cd $(TEST)/phrqex11; ./clean

phrqex11_clean_parallel:
	cd $(TEST)/phrqex11; rm -rf [0-4]/*

#
# ex1
#
ex1: ex1_clean
	echo ; 
	echo ============= ex1
	echo ; 
	cd $(TEST)/ex1; ./clean
	cd $(TEST)/ex1; $(PHAST_INPUT) ex1; time $(PHAST)
	echo ============= Done ex1

ex1_parallel: ex1_clean_parallel
	echo ; 
	echo ============= ex1 Parallel
	echo ; 
	./run ex1
	echo ============= Done ex1 Parallel

ex1_clean:
	cd $(TEST)/ex1; ./clean

ex1_clean_parallel:
	cd $(TEST)/ex1; rm -rf [0-4]/*

#
# radial
#
radial: radial_clean
	echo ; 
	echo ============= radial
	echo ; 
	cd $(TEST)/radial; ./clean
	cd $(TEST)/radial; $(PHAST_INPUT) radial; time $(PHAST)
	echo ============= Done radial

radial_parallel: radial_clean_parallel
	echo ; 
	echo ============= radial Parallel
	echo ; 
	./run radial
	echo ============= Done radial Parallel

radial_clean:
	cd $(TEST)/radial; ./clean

radial_clean_parallel:
	cd $(TEST)/radial; rm -rf [0-4]/*

#
# river
#
river: river_clean
	echo ; 
	echo ============= river
	echo ; 
	cd $(TEST)/river; ./clean
	cd $(TEST)/river; $(PHAST_INPUT) river; time $(PHAST)
	echo ============= Done river

river_parallel: river_clean_parallel
	echo ; 
	echo ============= river Parallel
	echo ; 
	./run river
	echo ============= Done river Parallel

river_clean:
	cd $(TEST)/river; ./clean

river_clean_parallel:
	cd $(TEST)/river; rm -rf [0-4]/*

#
# unconf
#
unconf: unconf_clean
	echo ; 
	echo ============= unconf
	echo ; 
	cd $(TEST)/unconf; ./clean
	cd $(TEST)/unconf; $(PHAST_INPUT) unconf; time $(PHAST)
	echo ============= Done unconf

unconf_parallel: unconf_clean_parallel
	echo ; 
	echo ============= unconf Parallel
	echo ; 
	./run unconf
	echo ============= Done unconf Parallel

unconf_clean:
	cd $(TEST)/unconf; ./clean

unconf_clean_parallel:
	cd $(TEST)/unconf; rm -rf [0-4]/*

#
# well
#
well: well_clean
	echo ; 
	echo ============= well
	echo ; 
	cd $(TEST)/well; ./clean
	cd $(TEST)/well; $(PHAST_INPUT) well; time $(PHAST)
	echo ============= Done well

well_parallel: well_clean_parallel
	echo ; 
	echo ============= well Parallel
	echo ; 
	./run well
	echo ============= Done well Parallel

well_clean:
	cd $(TEST)/well; ./clean

well_clean_parallel:
	cd $(TEST)/well; rm -rf [0-4]/*

clean: $(CLEAN_PROBLEMS)
	rm -f make.out

#ci: $(CI_PROBLEMS)
