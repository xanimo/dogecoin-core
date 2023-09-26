build:
	docker buildx build -t xanimo/${shell basename -s .git `git config --get remote.origin.url`}:alpine --progress plain --load .

buildx:
	docker buildx create --use --node ${shell basename -s .git `git config --get remote.origin.url`} --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=50000000

run:
	docker run -v ${PWD}:${PWD} \
	-it --rm xanimo/${shell basename -s .git `git config --get remote.origin.url`}:alpine

run-sh:
	docker run -v ${PWD}:${PWD} \
	-it --rm xanimo/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current} /bin/sh

test:
	docker run -v ${PWD}:${PWD} \
	-it --rm xanimo/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current} \
	test_dogecoin \
	--build_info=1 \
	--auto_start_dbg=1 \
	--show_progress=1 \
	--catch_system_errors=1 \
	--color_output=1 \
	--detect_fp_exceptions=1 \
	--detect_memory_leaks=1000 \
	--log_format=CLF \
	--log_level=success \
	--log_sink=${PWD}/test-log.txt \
	--report_memory_leaks_to=${PWD}/memleaks-log.txt