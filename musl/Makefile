build:
	docker buildx build -t ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current} --progress plain . 2> ${PWD}/build-log.txt

buildx:
	docker buildx create --use --name ${shell basename -s .git `git config --get remote.origin.url`} --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=50000000