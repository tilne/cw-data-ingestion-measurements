#### Running one of the test cases:

There should be a target in the Makefile for any of the remaining test cases. Running the test case should be just

```
make $SCHEDULER-$SIZE
```

That will produce a file at `logs/$SCHEDULER-$SIZE-output.txt`. That log file will contain the information describing how much log data was ingested during a certain phase of the test. For example, from logs/slurm-500-output.txt:

```
slurm-500's log group ingested 165229477 during SCALE UP
slurm-500's log group ingested 647716 during COMPUTE PLATEAU
slurm-500's log group ingested 458009 during SCALE DOWN
```

The units are bytes. The COMPUTE PLATEAU phase lasts 20 minutes, so multiply that value by 3 to extrapolate to the ingestion that would have been seen over an hour.

#### Things you'll need to change:

* the key_name parameter in configs/config.j2
* the custom\_node\_package URL in the extra_json parameter in the template at configs/config.j2
  * the node package i was using was the current development version
* the VPC section of the template at configs/config.j2


#### Things I don't think you'll need to change, but I'm not sure:

* The custom AMI ID (if I shared it with your account I don't think you can use the same ID)
  * it's being used because it contains the changes that were merged into the develop branch of the cookbook repo yesterday to drop two of the cfn logs.
* The use of us-east-1 is assumed by the cluster config template and also the call in scripts/get-ingested-data.sh.
