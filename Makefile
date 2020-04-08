scheduler = $(word 1,$(subst -, ,$@))
size = $(word 2,$(subst -, ,$@))
suffix = $(word 3,$(subst -, ,$@))

%:
	@echo testing scheduler $(scheduler) with size $(size) and suffix $(suffix)
	./create-and-test-cluster.sh 2>&1 $(scheduler) $(size) $(suffix) | tee log-files/$(scheduler)-$(size)-$(suffix)-output.txt