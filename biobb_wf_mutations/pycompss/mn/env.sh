module load ANACONDA/2018.12_py3
source activate biobb
export BIOBB_LOCATION=$PWD/../../../../
export PYTHONPATH=${BIOBB_LOCATION}/biobb_adapters/

#COMPSs environment
export COMPSS_PYTHON_VERSION=none 
#COMPSs version for testing
#module load TrunkJEA
#COMPSs release
module load COMPSs/2.5

#GROMAS environment
#GROMACS 2019
module load intel/2018.4 impi/2018.4 mkl/2018.4 gromacs/2019.1

#GROMACS default MN
#module load gromacs

#GROMACS with openmpi
#module unload impi
#module load openmpi gromacs/2016.4-openmpi
