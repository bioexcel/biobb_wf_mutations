# Execution instructions for Marenostrum

To execute in MareNostrum IV follow next steps

1.- Clone biobb_adapters and bio_bb_wf_mutations in a folder

´´´
$localhost> git clone https://github.com/bioexcel/biobb_adapters.git

$localhost> git clone https://github.com/bioexcel/biobb_wf_mutations.git

´´´

2.- Check out the multi_node_testing branch in both repositories. This won't be needed when merged in the master branch

´´´ 
$localhost> cd biobb_adapters; git co multi_node_testing; cd ..

$localhost> cd biobb_wf_mutations; git co multi_node_testing; cd ..

´´´
3.- Copy to MareNostrum

´´´
$localhost> scp -r * <mn_user>@mn1.bsc.es:<biobb_folder>
´´´ 

4.- To run the workflow, enter to MN and run the following commands.

´´´
$mn4> cd bio_bb_wf_mutations/bio_bb_wf_mutations/pycompss/mn

$mn4> source env.sh

$mn4> ./launch.sh
´´´

