FROM debian:bullseye-slim AS build

WORKDIR /build

ARG TARGETPLATFORM
ARG BUILDPLATFORM
# Specify release variables
ARG RLS_VERSION=1.14.6-dev
ARG RLS_OS=linux
ARG RLS_LIB=gnu
ARG RLS_ARCH=x86_64

# determine architecture, download release binary
# and verify against random OK signer and pinned shasums
RUN set -ex && ARCHITECTURE=$(dpkg --print-architecture) \
    && if [ "${ARCHITECTURE}" = "amd64" ]; then RLS_ARCH=x86_64 ; fi \
    && if [ "${ARCHITECTURE}" = "arm64" ]; then RLS_ARCH=aarch64; fi \
    && if [ "${ARCHITECTURE}" = "armhf" ]; then RLS_ARCH=arm && RLS_LIB=gnueabihf; fi \
    && if [ "${ARCHITECTURE}" = "i386" ]; then RLS_ARCH=i686-pc; fi \
    && if [ "${RLS_ARCH}" = "" ]; then echo "Could not determine architecture" >&2; exit 1; fi

ENV HOST_TRIPLET=${RLS_ARCH}-${RLS_OS}-${RLS_LIB}

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
git \
curl \
build-essential \
libtool-bin \
autotools-dev \
automake \
pkg-config \
libssl-dev \
libevent-dev \
bsdmainutils \
python3-dev \
&& rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/xanimo/dogecoin.git /dogecoin \
  && bash -xc "pushd /dogecoin; git checkout ${RLS_VERSION}; popd;"

WORKDIR /dogecoin

RUN make \
  HOST=${HOST_TRIPLET} \
  NO_QT=1 \
  -C depends
RUN libtool --finish $PWD/depends/${HOST_TRIPLET}/lib
RUN ./autogen.sh
RUN CONFIG_SITE="${PWD}/depends/${HOST_TRIPLET}/share/config.site" ./configure \
  --without-gui \
  --disable-gui-tests \
  --without-upnpc \
  --disable-bench \
  --disable-ccache \
  --disable-maintainer-mode \
  --enable-static-nss \
  --enable-hardcoded-path-in-tests \
  --enable-bind-now \
  --disable-shared \
  --enable-static-pie \
  --enable-stack-protector=all \
  CFLAGS="-g0 -Os -static --static -fPIC" \
  CXXFLAGS="-DDEBUG_LOCKORDER -g -g0 -Os -s -static --static -fPIC -fvisibility=hidden" \
  LDFLAGS="-s -static-libgcc -static-libstdc++ -Wl,-O2"
RUN make -j$(nproc)
RUN make check -j$(nproc)
# RUN strip ${DOGECOIN_PREFIX}/src/dogecoin-cli
# RUN strip ${DOGECOIN_PREFIX}/src/dogecoin-tx
# RUN strip ${DOGECOIN_PREFIX}/src/dogecoind
# RUN strip ${DOGECOIN_PREFIX}/.libs/libdogecoinconsensus.a

FROM debian:bullseye-slim AS test

ENV DOGECOIN_DATA=/home/dogecoin/.dogecoin
ENV PATH=/dogecoin/src:$PATH
ENV PATH=/dogecoin/src/test:$PATH

RUN apt-get update && apt-get install -y \
  curl \
  gcc \
  git \
  gosu \
  nano \
  python3-zmq \
  python3-dev

RUN git clone \
  --depth 1  \
  --filter=blob:none  \
  --sparse \
  https://github.com/xanimo/dogecoin.git

WORKDIR /dogecoin

RUN git sparse-checkout set qa

COPY --from=build /dogecoin/src/dogecoind /dogecoin/src/dogecoind
COPY --from=build /dogecoin/src/dogecoin-cli /dogecoin/src/dogecoin-cli
COPY --from=build /dogecoin/src/dogecoin-tx /dogecoin/src/dogecoin-tx
COPY --from=build /dogecoin/src/test/test_dogecoin /dogecoin/src/test/test_dogecoin
COPY --from=build /dogecoin/src/.libs /dogecoin/src/.libs

COPY dogecoin.conf /home/dogecoin/.dogecoin/dogecoin.conf
COPY dogecoind.pid /home/dogecoin/.dogecoin/dogecoin.pid

WORKDIR /dogecoin/qa/pull-tester

RUN ./install-deps.sh

WORKDIR /dogecoin

COPY entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]

VOLUME ["/home/dogecoin/.dogecoin"]
VOLUME ["/sys/fs/cgroup"]

EXPOSE 22555 22556 44555 44556

ENTRYPOINT ["/entrypoint.sh"]

RUN chmod -R 755 /dogecoin/*

CMD ["dogecoind"]