@PEST_BIN_DIR@/phastinput @PHAST_ROOT_NAME@
/usr/lib64/openmpi/bin/mpiexec -n @PHAST_NODES@ @PEST_BIN_DIR@/phast3-mpi
@PEST_BIN_DIR@/Interpolate4d
