rd /s /q _build_mpi_x64
ctest -S build-mpi-2012-64.cmake -C Release -VV -O build-mpi-2012-64.log
rd /s /q _build_mt_x64
ctest -S build-mt-2012-64.cmake -C Release -VV -O build-mt-2012-64.log
