#!/usr/bin/env bash

#Download and install miniconda in the path
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOME/miniconda.sh
bash $HOME/miniconda.sh -b -p $HOME/miniconda
CONDA="$HOME/miniconda/bion/conda"
export PATH="$HOME/miniconda/bin:$PATH"

$CONDA config --add channels defaults
$CONDA config --add channels bioconda
$CONDA config --add channels conda-forge

$CONDA install -y biobb_wf_mutations

$CONDA install -y nglview -c conda-forge
jupyter-nbextension enable nglview --py --sys-prefix

jupyter-notebook $HOME/mutations/mutations.ipynb