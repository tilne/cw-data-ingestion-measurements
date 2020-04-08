#!/bin/bash
for i in `seq 1 ${NUM_JOBS}`
do
    qsub -pe mpi 1 -t 1-8 /shared/job.sh
done
