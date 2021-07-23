# # Build stage for BerkeleyDB
# FROM ubuntu:focal as berkeleydb

# ENV BERKELEYDB_VERSION=5.1.29.NC
# ENV BERKELEYDB_SHA256SUM=08238e59736d1aacdd47cfb8e68684c695516c37f4fbe1b8267dde58dc3a576c

# RUN apt-get update -y \
#   && apt-get install -y autotools-dev automake build-essential musl musl-dev \
#   && apt-get clean \
#   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ADD http://download.oracle.com/berkeley-db/db-${BERKELEYDB_VERSION}.tar.gz ./
# RUN \
#   echo "${BERKELEYDB_SHA256SUM}  db-${BERKELEYDB_VERSION}.tar.gz" | sha256sum -c - && \
#   tar xf db-${BERKELEYDB_VERSION}.tar.gz

# WORKDIR /db-${BERKELEYDB_VERSION}/build_unix

# RUN \
# sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ../src/dbinc/atomic.h

# RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/usr/local/bdb
# RUN make -s -j$(nproc)
# RUN make install
# RUN rm -rf ${BERKELEYDB_PREFIX}/docs

# Build stage for Dogecoin Core
FROM ubuntu:focal as build

# COPY --from=berkeleydb /usr/local/bdb /usr/local/bdb

RUN apt-get update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y git curl libtool libtool-bin pkg-config libevent-dev bsdmainutils autotools-dev automake build-essential libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libssl-dev python3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV DOGECOIN_VERSION=1.14.4-dev
ENV DOGECOIN_PREFIX=/app

RUN git clone https://github.com/xanimo/dogecoin.git /dogecoin-${DOGECOIN_VERSION}

WORKDIR /dogecoin-${DOGECOIN_VERSION}

RUN git checkout f4f7759649941820117d8c22f3d0a5b93cd8a200

RUN make HOST=x86_64-linux-musl NO_QT=1 NO_UPNP=1 -C depends
RUN libtool --finish $PWD/depends/x86_64-linux-musl/lib
RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h
RUN ./autogen.sh
RUN CONFIG_SITE="${PWD}/depends/x86_64-linux-musl/share/config.site" ./configure \
  --host=x86_64-linux-musl \
  --build=x86_64-linux-gnu \
  --mandir=/usr/share/man \
  --prefix=${DOGECOIN_PREFIX} \
  --without-gui \
  --disable-gui-tests \
  --without-upnpc \
  --disable-bench \
  --disable-ccache \
  --disable-maintainer-mode \
  LD_LIBRARY_PATH="/usr/lib/ld-musl-x86_64.so.1" \
  CC="musl-gcc -g -specs=/usr/lib/x86_64-linux-musl/musl-gcc.specs" \
  CXX=musl-g++ \
  CROSS_COMPILE=x86_64-linux-musl- \
  CHOST=x86_64-linux-musl \
  CFLAGS="-g0 -Os -static --static -fPIC" \
  # CPPFLAGS="-I/usr/local/bdb/include/" \
  CXXFLAGS="-g0 -Os -static --static -fPIC -fvisibility=hidden" \
  LIBDIR=/usr/lib/x86_64-linux-musl/ \
  # LDFLAGS="-L/usr/local/bdb/lib/ -s -static-libgcc -static-libstdc++ -Wl,-rpath -Wl,LIBDIR,-O2"
  LDFLAGS="-s -static-libgcc -static-libstdc++ -Wl,-rpath -Wl,LIBDIR,-O2"
RUN make -s -j$(nproc)
RUN make check -j$(nproc)
RUN make install
RUN strip ${DOGECOIN_PREFIX}/bin/dogecoin-cli
RUN strip ${DOGECOIN_PREFIX}/bin/dogecoin-tx
RUN strip ${DOGECOIN_PREFIX}/bin/dogecoind
RUN strip ${DOGECOIN_PREFIX}/lib/libdogecoinconsensus.a

# Build stage for compiled artifacts
FROM alpine:latest

LABEL maintainer.0="xanimo (@xanimo)"

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN adduser -S dogecoin
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk update && apk upgrade && apk --no-cache add \
  boost-filesystem \
  boost-system \
  boost-thread \
  dhclient \
  libevent \
  libzmq \
  su-exec \
  linux-headers \
  iputils \
  drill \
  openrc \
  util-linux \
  rsync \
  && echo "en_US.UTF-8 UTF-8" > /etc/profile.d/locale.sh

COPY dhclient.conf /etc/dhcp/dhclient.conf
COPY interfaces /etc/network/interfaces
COPY resolv.conf /etc/resolv.conf

ENV DOGECOIN_DATA=/home/dogecoin/.dogecoin
ENV DOGECOIN_VERSION=1.14.4-dev

RUN mkdir -p /app \
  && chown -R nobody:nogroup /app

ENV PATH=/app/bin:$PATH

WORKDIR /app

COPY --from=build /app /app
COPY dogecoin.conf /home/dogecoin/.dogecoin/dogecoin.conf
COPY dogecoind.pid /home/dogecoin/.dogecoin/dogecoin.pid

COPY docker-entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]

VOLUME ["/home/dogecoin/.dogecoin"]
VOLUME ["/sys/fs/cgroup"]

EXPOSE 22555 22556 44555 44556 18444 9050 9051

ENTRYPOINT ["/entrypoint.sh"]

# Set permissions for everything added to /app
RUN chmod -R 755 /app/*

CMD ["dogecoind"]