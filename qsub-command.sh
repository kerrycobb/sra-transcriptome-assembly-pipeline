#!/bin/bash

snakemake \
--configfile $1
--workdir $2
--cores 20 \
--latency 60 \
--rerun-incomplete \
--cluster \
"ssh kac0070@hopper.auburn.edu \
'/cm/shared/apps/torque/5.1.0/bin/qsub \
-l nodes=1:ppn={threads},mem={params.mem},walltime={params.time} \
-N {rule}.{wildcards.sample} \
-m n \
-j oe \
-d {workingdir} \
-o {log} \
' "
