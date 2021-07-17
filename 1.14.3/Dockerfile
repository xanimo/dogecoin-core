FROM amd64/debian:bullseye-20210621-slim

LABEL maintainer.0="xanimo (@xanimo)"

RUN useradd -r dogecoin \
  && apt-get update -y \
  && apt-get install -y wget gnupg gosu \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG TARGETPLATFORM

ENV DOGECOIN_VERSION=1.14.3
ENV DOGECOIN_PREFIX=/opt/dogecoin-${DOGECOIN_VERSION}
ENV DOGECOIN_DATA=/home/dogecoin/.dogecoin
ENV PATH=/opt/dogecoin-${DOGECOIN_VERSION}/bin:$PATH

RUN set -ex \
  && if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then export TARGETPLATFORM=x86_64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then export TARGETPLATFORM=aarch64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then export TARGETPLATFORM=arm-linux-gnueabihf; fi \
  && for key in \
  E9E1D8252D569306 \
  ; do \
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" || \
  gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
  gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" ; \
  done \
  && wget https://github.com/dogecoin/dogecoin/releases/download/v${DOGECOIN_VERSION}/dogecoin-${DOGECOIN_VERSION}-${TARGETPLATFORM}.tar.gz \
  && wget https://raw.githubusercontent.com/xanimo/dogecoin-sha256sum/main/${DOGECOIN_VERSION}/SHA256SUMS.asc \
  && gpg --verify SHA256SUMS.asc \
  && grep " dogecoin-${DOGECOIN_VERSION}-${TARGETPLATFORM}.tar.gz" SHA256SUMS.asc | sha256sum -c - \
  && tar -xzf *.tar.gz -C /opt \
  && rm *.tar.gz *.asc \
  && rm -rf /opt/dogecoin-${DOGECOIN_VERSION}/bin/dogecoin-qt

COPY docker-entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

VOLUME ["/home/dogecoin/.dogecoin"]

EXPOSE 22555 22556 44555 44556 18443 18444 38555 38556


ENTRYPOINT ["/entrypoint.sh"]

RUN dogecoind -version | grep "Dogecoin Core Daemon version v${DOGECOIN_VERSION}"

CMD ["dogecoind"]
