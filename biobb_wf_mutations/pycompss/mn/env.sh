module load ANACONDA/2018.12_py3
source activate biobb
export BIOBB_LOCATION=$PWD/../../../../
export PYTHONPATH=${BIOBB_LOCATION}/biobb_adapters/
export COMPSS_PYTHON_VERSION=none 
#export COMPSS_PYTHON_VERSION=anaconda3
module load COMPSs/2.4.rc1904
module load intel/2018.4 impi/2018.4 mkl/2018.4

