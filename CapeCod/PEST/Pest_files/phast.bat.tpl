@DEL@ webmod.params
@DEL@ webmod.pqi
@DEL@ webmod.statvar
@PEST_BIN_DIR@phastinput.exe @PHAST_ROOT_NAME@
mpiexec -n @PHAST_NODES% @PEST_BIN_DIR@phast3-mpi.exe 
