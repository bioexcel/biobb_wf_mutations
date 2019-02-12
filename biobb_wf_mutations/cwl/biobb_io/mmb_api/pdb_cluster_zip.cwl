#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
baseCommand: pdb_cluster_zip
hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biobb_io:0.1.3--py_0
inputs:
  output_pdb_zip_path:
    type: string
    inputBinding:
      position: 1
      prefix: --output_pdb_zip_path
    default: "pdb_cluster.zip"

  config:
    type: string?
    inputBinding:
      position: 2
      prefix: --config
    default: "{\"pdb_code\":\"2vgb\"}"

outputs:
  output_pdb_zip_file:
    type: File
    format: edam:format_PDB_ZIP
    outputBinding:
      glob: $(inputs.output_pdb_zip_path)

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.22_dev.owl
