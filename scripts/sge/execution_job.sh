#!/bin/bash

count=0
while true; do
    ((count++))
    if !((count%30000)); then
        dd if=/dev/zero of=/tmp/filei1M_$$.txt count=1 bs=1048576
    fi
    echo "$(date)"
    sleep 0.01
done

