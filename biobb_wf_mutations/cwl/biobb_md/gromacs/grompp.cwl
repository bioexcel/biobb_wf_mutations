#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: grompp
hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_md:0.1.5--py_0
inputs:
  input_gro_path:
    type: File
    format: edam:format_GROMACS_GRO
    inputBinding:
      position: 1
      prefix: --input_gro_path

  input_top_zip_path:
    type: File
    format: edam:format_TOP_ITP_ZIP
    inputBinding:
      position: 2
      prefix: --input_top_zip_path

  output_tpr_path:
    type: string
    inputBinding:
      position: 3
      prefix: --output_tpr_path
    default: "system.tpr"

  input_cpt_path:
    type: File?
    format: edam:format_GROMACS_CPT
    inputBinding:
      prefix: --input_cpt_path

  config:
    type: string?
    inputBinding:
      prefix: --config

outputs:
  output_tpr_file:
    type: File
    format: edam:format_GROMACS_TPR
    outputBinding:
      glob: $(inputs.output_tpr_path)

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.22_dev.owl
