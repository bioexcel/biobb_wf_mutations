#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: cluster
hints:
  DockerRequirement:
    dockerPull: mmbirb/biobb_analysis:0.1.3
inputs:
  input_gro_path:
    type: File
    format: edam:format_GROMACS_GRO
    inputBinding:
      position: 1
      prefix: --input_gro_path

  input_traj_path:
    type: File
    format: edam:format_3866
    inputBinding:
      position: 2
      prefix: --input_traj_path

  output_pdb_path:
    type: string
    inputBinding:
      position: 3
      prefix: --output_pdb_path
    default: "structure_cluster.pdb"

  config:
    type: string?
    inputBinding:
      position: 4
      prefix: --config

outputs:
  output_pdb_file:
    type: File
    format: edam:format_1476
    outputBinding:
      glob: $(inputs.output_pdb_path)

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.22_dev.owl
