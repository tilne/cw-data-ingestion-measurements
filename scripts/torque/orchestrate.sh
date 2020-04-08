#!/bin/bash

LOG=/shared/cluster-timeline-log.txt
_log() {
    echo >> $LOG $@
}

# MAX_QUEUE_LENGTH must be set
if [ -z "${MAX_QUEUE_LENGTH}" ]; then
    echo 'MAX_QUEUE_LENGTH must be set'
    exit 1
fi


##########
#
#  SCALE UP
#
##########

# Note the time at which scale up is starting
_log "SCALE UP TIME IS STARTING AT $(date)"

# Poll on the job queue until there's no pending jobs
export NUM_JOBS=$MAX_QUEUE_LENGTH
/shared/submission.sh
NUM_PENDING_JOBS=$(qstat | grep ' Q batch' | wc -l)
while [ "$NUM_PENDING_JOBS" -gt "0" ]; do
    _log "NUM_PENDING_JOBS: $NUM_PENDING_JOBS"
    sleep 90
    NUM_PENDING_JOBS=$(qstat | grep ' Q batch' | wc -l)
done

# Note the time at which scale up is finished
_log "SCALE UP TIME IS FINISHED AT $(date)"

##########
#
#  COMPUTE PLATEAU
#
##########

# Note the time at which plateau is starting
_log "COMPUTE PLATEAU TIME IS STARTING AT $(date)"

# Sleep for 20 minutes
sleep $(( 60 * 20 ))

# Note the time at which plateau is finished
_log "COMPUTE PLATEAU TIME IS FINISHED AT $(date)"

##########
#
#  SCALE DOWN
#
##########

# Note the time at which scale down is starting
_log "SCALE DOWN TIME IS STARTING AT $(date)"

# Cancel all of the jobs
qdel $(qstat | grep ' R batch' | cut -d '.' -f1)

# Wait for the queue to be empty
NUM_NODES=$(pbsnodes | egrep '^ip-' | grep -v $(hostname) | wc -l)
while [ "$NUM_NODES" -gt "0" ]; do
    _log "NUM_NODES: $NUM_NODES"
    sleep 90
    NUM_NODES=$(pbsnodes | egrep '^ip-' | grep -v $(hostname) | wc -l)
done

# Note the time at which scale down is finished
_log "SCALE DOWN TIME IS FINISHED AT $(date)"

