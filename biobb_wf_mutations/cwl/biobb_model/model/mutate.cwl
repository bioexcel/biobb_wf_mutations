#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: mutate
hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_model:0.1.3--py_0
inputs:
  input_pdb_path:
    type: File
    format: edam:format_1476
    inputBinding:
      position: 1
      prefix: --input_pdb_path

  output_pdb_path:
    type: string
    inputBinding:
      position: 2
      prefix: --output_pdb_path
    default: "mutated.pdb"

  config:
    type: string?
    inputBinding:
      position: 3
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
