FROM debian:bullseye-slim

SHELL ["/bin/bash", "-c"] 

LABEL maintainer.0="xanimo (@xanimo)"

RUN apt-get update -y \
  && apt-get install -y wget gnupg gosu ruby \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG TARGETPLATFORM

ENV DOGECOIN_VERSION=1.14.5
ENV DOGECOIN_PREFIX=/opt/dogecoin-${DOGECOIN_VERSION}
ENV DOGECOIN_DATA=/home/dogecoin/.dogecoin
ENV PATH=/opt/dogecoin-${DOGECOIN_VERSION}/bin:$PATH

COPY /gverify /gverify
COPY /verify.sh /verify.sh

RUN set -ex && TARGETPLATFORM=$(dpkg --print-architecture) \
  && if [ "${TARGETPLATFORM}" = "amd64" ]; then export TARGETPLATFORM=x86_64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "arm64" ]; then export TARGETPLATFORM=aarch64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "arm/v7" ]; then export TARGETPLATFORM=arm-linux-gnueabihf; fi \
  && for key in \
    E9E1D8252D569306 \
  ; do \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" || \
      gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" ; \
    done \
  && wget https://github.com/dogecoin/dogecoin/releases/download/v${DOGECOIN_VERSION}/dogecoin-${DOGECOIN_VERSION}-${TARGETPLATFORM}.tar.gz \
  && if [[ "$(./verify.sh -f "dogecoin-${DOGECOIN_VERSION}-${TARGETPLATFORM}.tar.gz" | tail -n 1)" == *"OK"* ]]; then \
      tar -xzf *.tar.gz -C /opt \
      && rm *.tar.gz \
      && rm -rf /opt/dogecoin-${DOGECOIN_VERSION}/bin/dogecoin-qt; \
    else \
      exit 1; \
    fi

COPY docker-entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

VOLUME ["/home/dogecoin/.dogecoin"]

EXPOSE 22555 22556 44555 44556 18443 18444 38555 38556


ENTRYPOINT ["/entrypoint.sh"]

RUN dogecoind -version | grep "Dogecoin Core Daemon version v${DOGECOIN_VERSION}"

CMD ["dogecoind", "-printtoconsole"]
