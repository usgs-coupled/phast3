#!/bin/sh
##SBATCH -p normal
#SBATCH -p UV
##SBATCH -p exper
#SBATCH -A nrp
#SBATCH -n 11
#SBATCH -c 8
##SBATCH --ntasks-per-node=1
#SBATCH --ntasks-per-socket=1
#SBATCH --output=full3d.UV.out
#SBATCH --mem-per-cpu=500M
#SBATCH -t24:00:00
##SBATCH --ntasks-per-node=1
##SBATCH --threads-per-core=1
##SBATCH --hint compute_bound
##SBATCH --hint nomultithread
##SBATCH --exclusive

#module load openmpi/1.8.8-gcc
#module load mpi/openmpi-1.8.8-intel
#module load tools/pest-13.5-gnu

PHAST_ROOT_NAME=full3d
NODES=11
PROCESSES=${NODES}
PHAST_NODES=8
PST=phast.pst

LOCAL_HOME=`pwd`
INPUT_DIR=${LOCAL_HOME}/Input
PEST_FILES_DIR=${LOCAL_HOME}/Pest_files
PROJECT_DIR=${LOCAL_HOME}/pest_run_dir
PEST_BIN_DIR=${LOCAL_HOME}/bin
BIN_DIR=${PEST_BIN_DIR}
OBSERVATIONS_DIR=${LOCAL_HOME}/Data
TEMP_DIR=psttemp

# setup working directory PROJECT_DIR=pest_run_dir
rm -rf ${PROJECT_DIR}
mkdir ${PROJECT_DIR}

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
cp ${PEST_FILES_DIR}/*.rmf                             ${PROJECT_DIR}
cp ${INPUT_DIR}/phast.dat                              ${PROJECT_DIR}
cp ${OBSERVATIONS_DIR}/*.obs                           ${PROJECT_DIR}
cp ${OBSERVATIONS_DIR}/*.tsv                           ${PROJECT_DIR}

MYHOST=`hostname`
echo myhost is ...........  ${MYHOST}

# Make temp directories
i=1
while [ "$i" -le "${PROCESSES}" ]; do
    cd ${PROJECT_DIR}
    rm -rf ${TEMP_DIR}$i
    mkdir ${TEMP_DIR}$i
    cd ${TEMP_DIR}$i
    cp ${PEST_FILES_DIR}/${PHAST_ROOT_NAME}.chem.dat.tpl   .
    cp ${PEST_FILES_DIR}/${PHAST_ROOT_NAME}.trans.dat.tpl  .
    cp ${PEST_FILES_DIR}/*.ins                             .
    cp ${PEST_FILES_DIR}/*.rmf                             .
    cp ${INPUT_DIR}/phast.dat                              .
    cp ${PROJECT_DIR}/phast.sh                             .
    cp ${PROJECT_DIR}/interpolator.control                 .
    cp ${OBSERVATIONS_DIR}/*.obs                           .
    cp ${OBSERVATIONS_DIR}/*.tsv                           .
    ${BIN_DIR}/ppest ${PROJECT_DIR}/${PST} /H ${MYHOST}:4004 & # cd ${PROJECT_DIR}
    echo Starting ppest $i
    i=$(($i+1))
done

time ${BIN_DIR}/ppest ${PROJECT_DIR}/${PST} /H /L :4004

#time mpirun -np ${PROCESSES} --bind-to core ppest ${PROJECT_DIR}/${PST} /M /L ${PROJECT_DIR}/psttemp
# time mpirun -np ${PROCESSES} ${BIN_DIR}/ppest ${PROJECT_DIR}/${PST} /M /L ${PROJECT_DIR}/psttemp
#MPITYPE=openmpi
#time srun --mpi=${MPITYPE} -n ${PROCESSES} ${BIN_DIR}/ppest ${PROJECT_DIR}/${PST} /M /L ${PROJECT_DIR}/psttemp

# Tidy up
rm -rf ${LOCAL_HOME}/pest_results
mkdir ${LOCAL_HOME}/pest_results
cp psttemp1/${PHAST_ROOT_NAME}*          ${LOCAL_HOME}/pest_results
rm -rf                          ${LOCAL_HOME}/pest_results/*intermediate*
rm -rf                          ${LOCAL_HOME}/pest_results/*h5*
cp interpolator.control		${LOCAL_HOME}/pest_results
cp psttemp1/*.calc		${LOCAL_HOME}/pest_results
cp *.ins			${LOCAL_HOME}/pest_results
cp *.obs			${LOCAL_HOME}/pest_results
cp phast*			${LOCAL_HOME}/pest_results
rm -rf				${LOCAL_HOME}/pest_results/Phast.tmp
cp ${LOCAL_HOME}/phast.slurm	${LOCAL_HOME}/pest_results
cp ${LOCAL_HOME}/full3d.UV.out	${LOCAL_HOME}/pest_results

REM pest_files
cd ${LOCAL_HOME}/pest_results
mkdir ${LOCAL_HOME}/pest_results/Pest_files
cp ${LOCAL_HOME}/Pest_files/*.tpl		${LOCAL_HOME}/pest_results/Pest_files
cp ${LOCAL_HOME}/Pest_files/*.rmf		${LOCAL_HOME}/pest_results/Pest_files


cd ${LOCAL_HOME}

#time /home/dlpark/programs/phast3-trunk/src/phastinput/phastinput MoMaS

#time mpirun -n 1 /home/dlpark/programs/phast3-trunk/src/phast/mpi_gfortran_64/phast 


