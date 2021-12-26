REPO=xanimo/$(shell basename -s .git `git config --get remote.origin.url`):$(shell git branch --show-current)
CACHE=`xanimo/cache:$(shell git branch --show-current)-$(shell basename -s .git `git config --get remote.origin.url`)`

cache:
	echo ${REPO}

deps:
	../../init-multi-arch.sh

build:
	docker build \
	-t ${REPO} .

buildx:
	docker buildx build  \
	-t ${REPO} \
	--progress plain . --load

buildx-log:
	docker buildx build  \
	-t ${REPO} \
	--progress plain . --load 2> ${PWD}/build-log.txt

build-multiarch:
	docker buildx build --platform linux/386,linux/amd64,linux/arm64,linux/arm \
	-t ${REPO} \
	--progress plain . --load 2> ${PWD}/build-log.txt

build-toolchain:
	docker build \
	-f Dockerfile.toolchain \
	-t xanimo/musl-toolchain .

build-source:
	docker build \
	-f Dockerfile.source \
	-t xanimo/dogecoin-core:source .

run:
	docker run -v ${PWD}:${PWD} \
	-it --rm ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current}

run-sh:
	docker run -v ${PWD}:${PWD} \
	-it --rm ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current} /bin/sh

test:
	docker run -v ${PWD}:${PWD} \
	-it --rm ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current} \
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