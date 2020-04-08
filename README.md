#### Running one of the test cases:

There should be a target in the Makefile for any of the remaining test cases. Running the test case should be just

```
make $SCHEDULER-$SIZE
```

#### Things you'll need to change:

* the key_name parameter in configs/config.j2
* the custom\_node\_package URL in the extra_json parameter in the template at configs/config.j2
  * the node package i was using was the current development version
* the VPC section of the template at configs/config.j2


#### Things I don't think you'll need to change, but I'm not sure:

* The custom AMI ID (if I shared it with your account I don't think you can use the same ID)
