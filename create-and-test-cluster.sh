#!/bin/bash
set -e

SCHEDULER=$1
MAX_QUEUE_LENGTH=$2
if [ -n "$3" ]; then
    SUFFIX="-$3"
fi

if [ -z "$SCHEDULER" ]; then
    echo "Must pass scheduler as first arg"
    exit 1
elif [ "$SCHEDULER" != "slurm" ] && [ "$SCHEDULER" != "sge" ] && [ "$SCHEDULER" != "torque" ]; then
    echo "Scheduler must be one of slurm, sge, or torque"
    exit
fi

if [ -z "$MAX_QUEUE_LENGTH" ]; then
    echo "Must pass max queue size for cluster config as second arg"
    exit 1
elif [ "$MAX_QUEUE_LENGTH" != "50" ] && [ "$MAX_QUEUE_LENGTH" != "100" ] && [ "$MAX_QUEUE_LENGTH" != "500" ] && [ "$MAX_QUEUE_LENGTH" != "1000" ] && [ "$MAX_QUEUE_LENGTH" != "2000" ]; then
    echo "Scheduler must be one of 50, 100, 500, 1000, 2000"
    exit 1
fi

# Create the cluster config file
cluster_config=$(python scripts/make-pcluster-config.py --scheduler $SCHEDULER --max_queue_size $MAX_QUEUE_LENGTH)
cluster_name="${SCHEDULER}-${MAX_QUEUE_LENGTH}${SUFFIX}"


# Create the cluster
pcluster create -c $cluster_config $cluster_name

# Sleep for 60 seconds to make sure cluster is ready to go
sleep 60

# Get the cluster's status. Ensure it was created successfully. Extract
# the public IP address of its master node.
cluster_status_output="$(pcluster status ${cluster_name})"
if ! echo $cluster_status_output| grep 'Status:' | grep &> /dev/null 'CREATE_COMPLETE' ; then
    echo 'Cluster creation failed'
    exit 1
fi
master_ip=$(echo "$cluster_status_output"| grep 'MasterPublicIP' | egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

# We're only using centos7 clusters
cluster_user=centos


# Set MAX_QUEUE_LENGTH, which is required by the script that orchestrates
# jobs used to scale and load the cluster
echo "Setting MAX_QUEUE_LENGTH in master's .bashrc"
set -x
command="echo >> .bashrc 'export MAX_QUEUE_LENGTH=${MAX_QUEUE_LENGTH}'"
disable_host_check="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
echo $command
ssh ${disable_host_check} $cluster_user@$master_ip "$command"

# Copy over the scripts for the given scheduler
echo "Copying over scripts"
scp ${disable_host_check} scripts/${SCHEDULER}/*.sh $cluster_user@$master_ip:/shared/

# Call the orchestration script
echo "Calling orchestration script"
ssh ${disable_host_check} $cluster_user@$master_ip /shared/orchestrate.sh

# Copy the log file back over
echo "Copying log file back over"
scp ${disable_host_check} $cluster_user@$master_ip:/shared/cluster-timeline-log.txt log-files/${cluster_name}-timeline-log.txt

echo "Getting the number of bytes ingested by the ${cluster_name}'s log group during the various phases of testing"
python scripts/get-ingested-data-for-phases.py --timeline-log log-files/${cluster_name}-timeline-log.txt

# Delete the cluster (making sure to keep the log group)
echo "Deleting cluster"
pcluster delete --keep-logs $cluster_name
