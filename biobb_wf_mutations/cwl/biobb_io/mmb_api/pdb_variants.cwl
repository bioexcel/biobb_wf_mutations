#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: pdb_variants
hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_io:0.1.3--py_0
inputs:
  output_mutations_list_txt:
    type: string
    inputBinding:
      position: 1
      prefix: --output_mutations_list_txt
    default: "mutations_list.txt"

  config:
    type: string?
    inputBinding:
      position: 2
      prefix: --config
    default: "{\"pdb_code\":\"2vgb\"}"

outputs:
  output_mutations_list_file:
    type: File
    format: edam:format_MUT_TXT
    outputBinding:
      glob: $(inputs.output_mutations_list_txt)

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.22_dev.owl
