#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
inputs:
  step1_mmbpdb_config: string
  step3_mutate_config: string
  step7_grompp_genion_config: string
  step8_genion_config: string
  step9_grompp_min_config: string
  step11_grompp_nvt_config: string
  step13_grompp_npt_config: string
  step15_grompp_md_config: string

outputs:
  trr:
    type: File
    outputSource: step16_mdrun_md/output_trr_file
  gro:
    type: File
    outputSource: step16_mdrun_md/output_gro_file
  edr:
    type: File
    outputSource: step16_mdrun_md/output_edr_file
  log:
    type: File
    outputSource: step16_mdrun_md/output_log_file
  cpt:
    type: File
    outputSource: step16_mdrun_md/output_cpt_file


steps:
  step1_mmbpdb:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_io/mmb_api/pdb.cwl
    in:
      config: step1_mmbpdb_config
    out: [output_pdb_file]

  step2_fixsidechain:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_model/model/fix_side_chain.cwl
    in:
      input_pdb_path: step1_mmbpdb/output_pdb_file
    out: [output_pdb_file]

  step3_mutate:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_model/model/mutate.cwl
    in:
      config: step3_mutate_config
      input_pdb_path: step2_fixsidechain/output_pdb_file
    out: [output_pdb_file]

  step4_pdb2gmx:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/pdb2gmx.cwl
    in:
      input_pdb_path: step3_mutate/output_pdb_file
    out: [output_gro_file, output_top_zip_file]

  step5_editconf:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/editconf.cwl
    in:
      input_gro_path: step4_pdb2gmx/output_gro_file
    out: [output_gro_file]

  step6_solvate:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/solvate.cwl
    in:
      input_solute_gro_path: step5_editconf/output_gro_file
      input_top_zip_path: step4_pdb2gmx/output_top_zip_file
    out: [output_gro_file, output_top_zip_file]

  step7_grompp_genion:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/grompp.cwl
    in:
      config: step7_grompp_genion_config
      input_gro_path: step6_solvate/output_gro_file
      input_top_zip_path: step6_solvate/output_top_zip_file
    out: [output_tpr_file]

  step8_genion:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/genion.cwl
    in:
      config: step8_genion_config
      input_tpr_path: step7_grompp_genion/output_tpr_file
      input_top_zip_path: step6_solvate/output_top_zip_file
    out: [output_gro_file, output_top_zip_file]

  step9_grompp_min:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/grompp.cwl
    in:
      config: step9_grompp_min_config
      input_gro_path: step8_genion/output_gro_file
      input_top_zip_path: step8_genion/output_top_zip_file
    out: [output_tpr_file]

  step10_mdrun_min:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/mdrun.cwl
    in:
      input_tpr_path: step9_grompp_min/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file]

  step11_grompp_nvt:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/grompp.cwl
    in:
      config: step11_grompp_nvt_config
      input_gro_path: step10_mdrun_min/output_gro_file
      input_top_zip_path: step8_genion/output_top_zip_file
    out: [output_tpr_file]

  step12_mdrun_nvt:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/mdrun.cwl
    in:
      input_tpr_path: step11_grompp_nvt/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file, output_cpt_file]

  step13_grompp_npt:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/grompp.cwl
    in:
      config: step13_grompp_npt_config
      input_gro_path: step12_mdrun_nvt/output_gro_file
      input_top_zip_path: step8_genion/output_top_zip_file
      input_cpt_path:  step12_mdrun_nvt/output_cpt_file
    out: [output_tpr_file]

  step14_mdrun_npt:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/mdrun.cwl
    in:
      input_tpr_path: step13_grompp_npt/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file, output_cpt_file]

  step15_grompp_md:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/grompp.cwl
    in:
      config: step15_grompp_md_config
      input_gro_path: step14_mdrun_npt/output_gro_file
      input_top_zip_path: step8_genion/output_top_zip_file
      input_cpt_path:  step14_mdrun_npt/output_cpt_file
    out: [output_tpr_file]

  step16_mdrun_md:
    run: ../../../biobb_adapters/biobb_adapters/cwl/biobb_md/gromacs/mdrun.cwl
    in:
      input_tpr_path: step15_grompp_md/output_tpr_file
    out: [output_trr_file, output_gro_file, output_edr_file, output_log_file, output_cpt_file]
