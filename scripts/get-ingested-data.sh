#!/bin/bash

CLUSTER_NAME=$1
START_TIME=$2
END_TIME=$3


aws cloudwatch get-metric-statistics \
    --metric-name IncomingBytes \
    --start-time ${START_TIME} \
    --end-time ${END_TIME} \
    --period 60 \
    --namespace AWS/Logs \
    --statistics Sum \
    --region us-east-1 \
    --dimensions Name=LogGroupName,Value=/aws/parallelcluster/${CLUSTER_NAME} | jq '.Datapoints[0].Sum'
