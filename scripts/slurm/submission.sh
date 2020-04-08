#!/bin/bash
for i in `seq 1 ${NUM_JOBS}`
do
    sbatch -N 1 -n 1 -a 1-8 /shared/job.sh
done
