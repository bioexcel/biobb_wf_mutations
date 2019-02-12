#!/usr/bin/env bash

RUNNER=cwltool

BIOBB_ANALYSIS=$HOME/projects/biobb_adapters/biobb_adapters/cwl/biobb_analysis
$RUNNER $BIOBB_ANALYSIS/gromacs/rms.cwl $BIOBB_ANALYSIS/test/gromacs/rms.yml
$RUNNER $BIOBB_ANALYSIS/gromacs/cluster.cwl $BIOBB_ANALYSIS/test/gromacs/cluster.yml
$RUNNER $BIOBB_ANALYSIS/ambertools/cpptraj.cwl $BIOBB_ANALYSIS/test/ambertools/cpptraj.yml
