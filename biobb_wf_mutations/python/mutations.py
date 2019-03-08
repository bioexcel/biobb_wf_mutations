#!/usr/bin/env python3

import os
import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_io.api.pdb import Pdb
from biobb_model.model.fix_side_chain import FixSideChain
from biobb_model.model.mutate import Mutate
from biobb_md.gromacs.pdb2gmx import Pdb2gmx
from biobb_md.gromacs.editconf import Editconf
from biobb_md.gromacs.solvate import Solvate
from biobb_md.gromacs.grompp import Grompp
from biobb_md.gromacs.genion import Genion
from biobb_md.gromacs.mdrun import Mdrun

def main(config, system=None):
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
        Pdb(**global_paths["step1_mmbpdb"], properties=global_prop["step1_mmbpdb"]).launch()

    global_log.info("step2_fixsidechain: Modeling the missing heavy atoms in the structure side chains")
    FixSideChain(**global_paths["step2_fixsidechain"], properties=global_prop["step2_fixsidechain"]).launch()

    for mutation_number, mutation in enumerate(conf.properties['mutations']):
        global_log.info('')
        global_log.info("Mutation: %s  %d/%d" % (mutation, mutation_number+1, len(conf.properties['mutations'])))
        global_log.info('')
        prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
        paths = conf.get_paths_dic(prefix=mutation)

        global_log.info("step3_mutate Modeling mutation")
        prop['step3_mutate']['mutation_list'] = mutation
        paths['step3_mutate']['input_pdb_path'] = global_paths['step2_fixsidechain']['output_pdb_path']
        Mutate(**paths["step3_mutate"], properties=prop["step3_mutate"]).launch()

        global_log.info("step4_pdb2gmx: Generate the topology")
        Pdb2gmx(**paths["step4_pdb2gmx"], properties=prop["step4_pdb2gmx"]).launch()

        global_log.info("step5_editconf: Create the solvent box")
        Editconf(**paths["step5_editconf"], properties=prop["step5_editconf"]).launch()

        global_log.info("step6_solvate: Fill the solvent box with water molecules")
        Solvate(**paths["step6_solvate"], properties=prop["step6_solvate"]).launch()

        global_log.info("step7_grompp_genion: Preprocess ion generation")
        Grompp(**paths["step7_grompp_genion"], properties=prop["step7_grompp_genion"]).launch()

        global_log.info("step8_genion: Ion generation")
        Genion(**paths["step8_genion"], properties=prop["step8_genion"]).launch()

        global_log.info("step9_grompp_min: Preprocess energy minimization")
        Grompp(**paths["step9_grompp_min"], properties=prop["step9_grompp_min"]).launch()

        global_log.info("step10_mdrun_min: Execute energy minimization")
        Mdrun(**paths["step10_mdrun_min"], properties=prop["step10_mdrun_min"]).launch()

        global_log.info("step11_grompp_nvt: Preprocess system temperature equilibration")
        Grompp(**paths["step11_grompp_nvt"], properties=prop["step11_grompp_nvt"]).launch()

        global_log.info("step12_mdrun_nvt: Execute system temperature equilibration")
        Mdrun(**paths["step12_mdrun_nvt"], properties=prop["step12_mdrun_nvt"]).launch()

        global_log.info("step13_grompp_npt: Preprocess system pressure equilibration")
        Grompp(**paths["step13_grompp_npt"], properties=prop["step13_grompp_npt"]).launch()

        global_log.info("step14_mdrun_npt: Execute system pressure equilibration")
        Mdrun(**paths["step14_mdrun_npt"], properties=prop["step14_mdrun_npt"]).launch()

        global_log.info("step15_grompp_md: Preprocess free dynamics")
        Grompp(**paths["step15_grompp_md"], properties=prop["step15_grompp_md"]).launch()

        global_log.info("step16_mdrun_md: Execute free molecular dynamics simulation")
        Mdrun(**paths["step16_mdrun_md"], properties=prop["step16_mdrun_md"]).launch()


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

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Based on the official Gromacs tutorial")
    parser.add_argument('--config', required=False)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
