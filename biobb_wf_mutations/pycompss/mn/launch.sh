enqueue_compss -d -m --qos=debug \
	--worker_working_dir=$PWD \
	--num_nodes=5 --exec_time=20 \
        --network=ethernet \
	--jvm_workers_opts="-Dcompss.worker.removeWD=false" \
	 ../mutations.py --conf ~/Bioexcel/github/biobb_wf_mutations/biobb_wf_mutations/conf/mutations.yml 
