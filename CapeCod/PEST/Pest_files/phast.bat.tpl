REM @DEL@ webmod.params
REM @DEL@ webmod.pqi
REM @DEL@ webmod.statvar
REM @PEST_BIN_DIR@/phastinput.exe @PHAST_ROOT_NAME@
REM mpiexec -n @PHAST_NODES% @PEST_BIN_DIR@phast3-mpi.exe 
@PEST_BIN_DIR@/bspline.exe
