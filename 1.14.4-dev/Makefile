NOFILE=100000

build:
	docker build -t ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current} .
build-native:
	docker build -t ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current} -f Dockerfile.native .
run-mainnet:
	docker run -it --ulimit "nofile=${NOFILE}:${NOFILE}" ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current}
run-testnet:
	docker run -it --ulimit "nofile=${NOFILE}:${NOFILE}" ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current} -testnet=1
run-mainnet-local:
	docker run -d --ulimit "nofile=${NOFILE}:${NOFILE}" -v ${PWD}/data:/home/dogecoin/.dogecoin -it ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current}
run-testnet-local:
	docker run -it -d --rm --ulimit "nofile=${NOFILE}:${NOFILE}" -v ${PWD}/data:/home/dogecoin/.dogecoin ${USER}/${shell basename -s .git `git config --get remote.origin.url`}:${shell git branch --show-current} -testnet=1