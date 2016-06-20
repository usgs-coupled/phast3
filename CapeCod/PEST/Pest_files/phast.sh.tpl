REM @DEL@ webmod.params
REM @DEL@ webmod.pqi
REM @DEL@ webmod.statvar

@PEST_BIN_DIR@/phastinput.exe @PHAST_ROOT_NAME@
#/usr/lib64/openmpi/bin/mpiexec -n @PHAST_NODES@ @PEST_BIN_DIR@/phast3-mpi
@PEST_BIN_DIR@/Interpolate4d
