#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: rms
hints:
  DockerRequirement:
    dockerPull: mmbirb/biobb_analysis:0.1.3
inputs:
  input_structure_path:
    type: File
    format: edam:format_GROMACS_GRO
    inputBinding:
      position: 1
      prefix: --input_structure_path

  input_traj_path:
    type: File
    format: edam:format_3866
    inputBinding:
      position: 2
      prefix: --input_traj_path

  output_xvg_path:
    type: string
    inputBinding:
      position: 3
      prefix: --output_xvg_path
    default: "rms.xvg"

  config:
    type: string?
    inputBinding:
      position: 4
      prefix: --config

outputs:
  output_xvg_file:
    type: File
    format: edam:format_XVG
    outputBinding:
      glob: $(inputs.output_xvg_path)

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.22_dev.owl
