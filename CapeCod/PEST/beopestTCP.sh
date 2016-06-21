#!/bin/sh


PHAST_ROOT_NAME=full3d
NODES=2
PROCESSES=${NODES}
PHAST_NODES=11
PST=phast.pst
LOCAL_HOME=`pwd`
INPUT_DIR=${LOCAL_HOME}/Input
PEST_FILES_DIR=${LOCAL_HOME}/Pest_files
PROJECT_DIR=${LOCAL_HOME}/pest_run_dir
PEST_BIN_DIR=${LOCAL_HOME}/bin
BIN_DIR=${PEST_BIN_DIR}/../bin
OBSERVATIONS_DIR=${LOCAL_HOME}/Data
TEMP_DIR=psttemp

# setup working directory PROJECT_DIR=pest_run_dir
rm -rf ${PROJECT_DIR}
mkdir ${PROJECT_DIR}

## check files
#errors=0
#for %%i in ( 
#    %INPUT_DIR%\phast.dat
#    %PEST_FILES_DIR%\%PHAST_ROOT_NAME%.chem.dat.tpl
#    %PEST_FILES_DIR%\%PHAST_ROOT_NAME%.trans.dat.tpl
#    %PEST_FILES_DIR%\phast.pst.tpl
#    %PEST_FILES_DIR%\phast.bat.tpl
#    %OBSERVATIONS_DIR%\P_uM_1993.obs
#    %PEST_BIN_DIR%/beopest64.exe
#    %PEST_BIN_DIR%/phastinput.exe
#    %PEST_BIN_DIR%/phast3-mpi.exe
#    ) do (
#    if NOT exist %%i (
#        echo Did not find file %%i
#        set errors=2
#    )
#)

# Sed to make phast.pst
sed    "s#@PROJECT_DIR@#${PROJECT_DIR}#g"          ${PEST_FILES_DIR}/phast.pst.tpl > ${PROJECT_DIR}/phast.pst
sed -i "s#@PHAST_ROOT_NAME@#${PHAST_ROOT_NAME}#g"  ${PROJECT_DIR}/phast.pst 
sed -i "s#phast.bat#phast.sh#g"                    ${PROJECT_DIR}/phast.pst 
sed -i 's#\\#/#g'                                  ${PROJECT_DIR}/phast.pst 

# Sed to make phast.sh
sed    "s#@PEST_BIN_DIR@#${PEST_BIN_DIR}#g"        ${PEST_FILES_DIR}/phast.sh.tpl > ${PROJECT_DIR}/phast.sh
sed -i "s#@PHAST_NODES@#${PHAST_NODES}#g"          ${PROJECT_DIR}/phast.sh
sed -i "s#@PHAST_ROOT_NAME@#${PHAST_ROOT_NAME}#g"  ${PROJECT_DIR}/phast.sh
chmod 744 ${PROJECT_DIR}/phast.sh

# Sed to make interpolator.control
sed    "s#@PHAST_ROOT_NAME@#${PHAST_ROOT_NAME}#g"  ${PEST_FILES_DIR}/interpolator.control > ${PROJECT_DIR}/interpolator.control

# Copy other files
cp ${PEST_FILES_DIR}/${PHAST_ROOT_NAME}.chem.dat.tpl   ${PROJECT_DIR}
cp ${PEST_FILES_DIR}/${PHAST_ROOT_NAME}.trans.dat.tpl  ${PROJECT_DIR}
cp ${PEST_FILES_DIR}/*.ins                             ${PROJECT_DIR}
cp ${INPUT_DIR}/phast.dat                              ${PROJECT_DIR}
cp ${OBSERVATIONS_DIR}/*.obs                           ${PROJECT_DIR}


PORT=4004 
MASTER=${HOSTNAME}

# Make temp directories
i=1
while [ "$i" -le "${PROCESSES}" ]; do
#for i in {1.."${PROCESSES}"}
#do
    cd ${PROJECT_DIR}
    rm -rf ${TEMP_DIR}$i
    mkdir ${TEMP_DIR}$i
    cd ${TEMP_DIR}$i
    cp ${PEST_FILES_DIR}/${PHAST_ROOT_NAME}.chem.dat.tpl   .
    cp ${PEST_FILES_DIR}/${PHAST_ROOT_NAME}.trans.dat.tpl  .
    cp ${PEST_FILES_DIR}/*.ins                             .
    cp ${INPUT_DIR}/phast.dat                              .
    cp ${PROJECT_DIR}/phast.sh                            .
    cp ${PROJECT_DIR}/interpolator.control                 .
    cp ${OBSERVATIONS_DIR}/*.obs                           .
    ${PEST_BIN_DIR}/beopest ${PROJECT_DIR}/${PST} /H ${MASTER}:${PORT} & cd ${PROJECT_DIR}/..
    i=$(($i+1))
done

# /L requires a run in PROJECT_DIR
cd ${PROJECT_DIR}

#time mpirun -np ${PROCESSES} --bind-to-core ppest ${PROJECT_DIR}/webmod.pst /M /L ${PROJECT_DIR}/psttemp
#time /usr/lib64/openmpi/bin/mpiexec -np ${PROCESSES} /raid/home/dlpark/programs/pest13.5/beopest ${PROJECT_DIR}/${PST} /M /L ${PROJECT_DIR}/psttemp
${PEST_BIN_DIR}/beopest ${PROJECT_DIR}/${PST} /H /L :${PORT}

#time /usr/lib64/openmpi/bin/mpirun -np ${PROCESSES} /raid/home/dlpark/programs/pest13/beopest '/raid/home/dlpark/programs/webmod-trunk/projects/andcrk/webmod.pst /M /raid/home/dlpark/programs/webmod-trunk/projects/andcrk/psttemp'
#time /usr/lib64/openmpi/bin/mpirun -np ${PROCESSES} /raid/home/dlpark/programs/pest13/beopest xxx \/M

# Tidy up
#rm -rf ${PROJECT_DIR}/../pest_results
#mkdir ${PROJECT_DIR}/../pest_results


cd ${PROJECT_DIR}/..

