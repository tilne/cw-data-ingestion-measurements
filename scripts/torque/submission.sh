#!/bin/bash
for i in `seq 1 ${NUM_JOBS}`
do
    qsub -t 1-8 /shared/job.sh
done
