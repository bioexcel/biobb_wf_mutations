#!/usr/bin/env bash

#Download and install miniconda in the path
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOME/miniconda.sh
bash $HOME/miniconda.sh -b -p $HOME/miniconda
CONDA="$HOME/miniconda/bin/conda"
export PATH="$HOME/miniconda/bin:$PATH"

$CONDA config --add channels defaults
$CONDA config --add channels bioconda
$CONDA config --add channels conda-forge

$CONDA install -y jupyter
$CONDA install -y nglview -c conda-forge
jupyter-nbextension enable nglview --py --sys-prefix
$CONDA install -y biobb_wf_mutations
mkdir -p $HOME/biobb_wf_mutations
wget https://raw.githubusercontent.com/bioexcel/biobb_wf_mutations/master/biobb_wf_mutations/notebooks/mutations.ipynb -O $HOME/biobb_wf_mutations/mutations.ipynb
jupyter-notebook $HOME/biobb_wf_mutations/mutations.ipynb
