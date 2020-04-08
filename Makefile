torque50:  # tested
	./create-and-test-cluster.sh 2>&1 torque 50 | tee log-files/torque-50-output.txt

slurm50:  # tested
	./create-and-test-cluster.sh 2>&1 slurm 50 | tee log-files/slurm-50-output.txt

sge50:  # tested
	./create-and-test-cluster.sh 2>&1 sge 50 | tee log-files/sge-50-output.txt

torque100:
	./create-and-test-cluster.sh 2>&1 torque 100 | tee log-files/torque-100-output.txt

slurm100:  # tested
	./create-and-test-cluster.sh 2>&1 slurm 100 | tee log-files/slurm-100-output.txt

sge100:
	./create-and-test-cluster.sh 2>&1 sge 100 | tee log-files/sge-100-output.txt

torque500:
	./create-and-test-cluster.sh 2>&1 torque 500 | tee log-files/torque-500-output.txt

slurm500:
	./create-and-test-cluster.sh 2>&1 slurm 500 | tee log-files/slurm-500-output.txt

sge500:
	./create-and-test-cluster.sh 2>&1 sge 500 | tee log-files/sge-500-output.txt

slurm1000:
	./create-and-test-cluster.sh 2>&1 slurm 1000 | tee log-files/slurm-1000-output.txt

slurm2000:
	./create-and-test-cluster.sh 2>&1 slurm 1000 | tee log-files/slurm-2000-output.txt
