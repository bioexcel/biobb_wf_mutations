#!/usr/bin/env python3

import os
import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_adapters.pycompss.biobb_io.mmb_api.pdb_pc import pdb_pc
from biobb_adapters.pycompss.biobb_model.model.fix_side_chain_pc import fix_side_chain_pc
from biobb_adapters.pycompss.biobb_model.model.mutate_pc import mutate_pc
from biobb_adapters.pycompss.biobb_md.gromacs.pdb2gmx_pc import pdb2gmx_pc
from biobb_adapters.pycompss.biobb_md.gromacs.editconf_pc import editconf_pc
from biobb_adapters.pycompss.biobb_md.gromacs.solvate_pc import solvate_pc
from biobb_adapters.pycompss.biobb_md.gromacs.grompp_pc import grompp_pc
from biobb_adapters.pycompss.biobb_md.gromacs.grompp_cpt_pc import grompp_cpt_pc
from biobb_adapters.pycompss.biobb_md.gromacs.genion_pc import genion_pc
from biobb_adapters.pycompss.biobb_md.gromacs.mdrun_cpt_pc import mdrun_cpt_pc
from biobb_adapters.pycompss.biobb_md.gromacs.mdrun_pc import mdrun_pc

def main(config, system=None):
    from pycompss.api.api import compss_barrier
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    initial_structure = conf.properties.get('initial_structure')
    if initial_structure:
        global_paths["step2_fixsidechain"]['input_pdb_path'] = initial_structure
    else:
        global_log.info("step1_mmbpdb: Dowload the initial Structure")
        pdb_pc(**global_paths["step1_mmbpdb"], properties=global_prop["step1_mmbpdb"])

    global_log.info("step2_fixsidechain: Modeling the missing heavy atoms in the structure side chains")
    fix_side_chain_pc(**global_paths["step2_fixsidechain"], properties=global_prop["step2_fixsidechain"])

    for mutation_number, mutation in enumerate(conf.properties['mutations']):
        global_log.info('')
        global_log.info("Mutation: %s  %d/%d" % (mutation, mutation_number+1, len(conf.properties['mutations'])))
        global_log.info('')
        prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
        paths = conf.get_paths_dic(prefix=mutation)

        global_log.info("step3_mutate Modeling mutation")
        prop['step3_mutate']['mutation_list'] = mutation
        paths['step3_mutate']['input_pdb_path'] = global_paths['step2_fixsidechain']['output_pdb_path']
        mutate_pc(**paths["step3_mutate"], properties=prop["step3_mutate"])

        global_log.info("step4_pdb2gmx: Generate the topology")
        pdb2gmx_pc(**paths["step4_pdb2gmx"], properties=prop["step4_pdb2gmx"])

        global_log.info("step5_editconf: Create the solvent box")
        editconf_pc(**paths["step5_editconf"], properties=prop["step5_editconf"])

        global_log.info("step6_solvate: Fill the solvent box with water molecules")
        solvate_pc(**paths["step6_solvate"], properties=prop["step6_solvate"])

        global_log.info("step7_grompp_genion: Preprocess ion generation")
        grompp_pc(**paths["step7_grompp_genion"], properties=prop["step7_grompp_genion"])

        global_log.info("step8_genion: Ion generation")
        genion_pc(**paths["step8_genion"], properties=prop["step8_genion"])

        global_log.info("step9_grompp_min: Preprocess energy minimization")
        grompp_pc(**paths["step9_grompp_min"], properties=prop["step9_grompp_min"])

        pa=paths["step10_mdrun_min"]
        global_log.info("step10_mdrun_min: Execute energy minimization")
        mdrun_pc(input_tpr_path=pa["input_tpr_path"], output_gro_path=pa["output_gro_path"], output_xtc_path=pa["output_xtc_path"], output_trr_path=pa["output_trr_path"], output_edr_path=pa["output_edr_path"], output_log_path=pa["output_log_path"])

        global_log.info("step11_grompp_nvt: Preprocess system temperature equilibration")
        grompp_pc(**paths["step11_grompp_nvt"], properties=prop["step11_grompp_nvt"])

        pa=paths["step12_mdrun_nvt"]
        global_log.info("step12_mdrun_nvt: Execute system temperature equilibration")
        mdrun_pc_cpt(input_tpr_path=pa["input_tpr_path"], output_gro_path=pa["output_gro_path"], output_cpt_path=pa["output_cpt_path"], output_xtc_path=pa["output_xtc_path"], output_trr_path=pa["output_trr_path"], output_edr_path=pa["output_edr_path"], output_log_path=pa["output_log_path"])

        global_log.info("step13_grompp_npt: Preprocess system pressure equilibration")
        grompp_cpt_pc(**paths["step13_grompp_npt"], properties=prop["step13_grompp_npt"])

        pa=paths["step14_mdrun_npt"]
        global_log.info("step14_mdrun_npt: Execute system pressure equilibration")
        mdrun_pc_cpt(input_tpr_path=pa["input_tpr_path"], output_gro_path=pa["output_gro_path"], output_cpt_path=pa["output_cpt_path"], output_xtc_path=pa["output_xtc_path"], output_trr_path=pa["output_trr_path"], output_edr_path=pa["output_edr_path"], output_log_path=pa["output_log_path"])

        global_log.info("step15_grompp_md: Preprocess free dynamics")
        grompp_cpt_pc(**paths["step15_grompp_md"], properties=prop["step15_grompp_md"])

        pa=paths["step16_mdrun_md"]
        global_log.info("step16_mdrun_md: Execute free molecular dynamics simulation")
        mdrun_pc_cpt(input_tpr_path=pa["input_tpr_path"], output_gro_path=pa["output_gro_path"], output_cpt_path=pa["output_cpt_path"], output_xtc_path=pa["output_xtc_path"], output_trr_path=pa["output_trr_path"], output_edr_path=pa["output_edr_path"], output_log_path=pa["output_log_path"])

    compss_barrier()
    elapsed_time = time.time() - start_time
    global_log.info('')
    global_log.info('')
    global_log.info('Execution sucessful: ')
    global_log.info('  Workflow_path: %s' % conf.get_working_dir_path())
    global_log.info('  Config File: %s' % config)
    if system:
        global_log.info('  System: %s' % system)
    global_log.info('')
    global_log.info('Elapsed time: %.1f minutes' % (elapsed_time/60))
    global_log.info('')

# computing_units = "48"
# computing_nodes = 2
#
# @constraint(ComputingUnits=computing_units)
# @mpi(runner="mpirun", binary="gmx_mpi", computingNodes=computing_nodes)
# @task(input_tpr_path=FILE_IN, output_gro_path=FILE_OUT, output_log_path=FILE_OUT)
# def mdrun_pc(mdrun="mdrun", s="-s",input_tpr_path="", c="-c",output_gro_path="", o="-o",output_trr_path="", x="-x",output_xtc_path="", e="-e", output_edr_path="", g="-g",output_log_path=""):
#     pass
#
# @constraint(ComputingUnits=computing_units)
# @mpi(runner="mpirun", binary="gmx_mpi", computingNodes=computing_nodes)
# @task(input_tpr_path=FILE_IN, output_gro_path=FILE_OUT, output_cpt_path=FILE_OUT, output_log_path=FILE_OUT)
# def mdrun_pc_cpt(mdrun="mdrun", s="-s",input_tpr_path="", c="-c",output_gro_path="", o="-o",output_trr_path="", x="-x",output_xtc_path="", e="-e", output_edr_path="", cpo="-cpo",output_cpt_path="", g="-g",output_log_path=""):
#     pass
#
#
# @constraint(ComputingUnits=computing_units)
# @mpi(runner="mpirun", binary="gmx_mpi", computingNodes=computing_nodes)
# @task(input_tpr_path=FILE_IN, output_gro_path=FILE_OUT, output_cpt_path=FILE_OUT, output_trr_path=FILE_OUT, output_xtc_path=FILE_OUT, output_edr_path=FILE_OUT, output_log_path=FILE_OUT)
# def mdrun_pc_all(mdrun="mdrun", s="-s",input_tpr_path="", c="-c",output_gro_path="", o="-o",output_trr_path="", x="-x",output_xtc_path="", e="-e", output_edr_path="", cpo="-cpo",output_cpt_path="", g="-g",output_log_path=""):
#     pass


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Based on the official Gromacs tutorial")
    parser.add_argument('--config', required=False)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
