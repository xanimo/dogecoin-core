# Build stage for BerkeleyDB
FROM alpine as berkeleydb

ENV BERKELEYDB_VERSION=5.1.29.NC
ENV BERKELEYDB_SHA256SUM=08238e59736d1aacdd47cfb8e68684c695516c37f4fbe1b8267dde58dc3a576c

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add build-base
RUN apk del libressl && apk add --no-cache openssl && apk fix

ADD http://download.oracle.com/berkeley-db/db-${BERKELEYDB_VERSION}.tar.gz ./
RUN \
  echo "${BERKELEYDB_SHA256SUM}  db-${BERKELEYDB_VERSION}.tar.gz" | sha256sum -c - && \
  tar xf db-${BERKELEYDB_VERSION}.tar.gz

WORKDIR /db-${BERKELEYDB_VERSION}/build_unix

RUN \
sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ../src/dbinc/atomic.h

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/usr/local/bdb
RUN make -j4
RUN make install
RUN rm -rf ${BERKELEYDB_PREFIX}/docs

# Build stage for Dogecoin Core
FROM alpine as dogecoin-core

ENV DOGECOIN_VERSION=1.14.3
ENV DOGECOIN_PREFIX=/opt/dogecoin-${DOGECOIN_VERSION}
ENV DOGECOIN_DOWNLOAD_SHA256 01039ad91adf7d2815ab07b45f751426e1c8e230f868dc878d4f5ff8aefeee47
ENV DOGECOIN_GITIAN_URL_BASE=https://github.com/dogecoin/gitian.sigs/tree/master/

COPY --from=berkeleydb /usr/local/bdb /usr/local/bdb

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add pkgconfig
RUN apk --no-cache add boost-dev
RUN apk --no-cache add build-base
RUN apk --no-cache add chrpath
RUN apk --no-cache add file
RUN apk --no-cache add gnupg
RUN apk --no-cache add libevent-dev
RUN apk --no-cache add openssl-dev
RUN apk --no-cache add libtool
RUN apk --no-cache add linux-headers
RUN apk --no-cache add zeromq-dev
RUN apk --no-cache add python3
RUN set -ex \
  && for key in \
    E9E1D8252D569306 \
  ; do \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" || \
      gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" ; \
  done

RUN wget https://github.com/dogecoin/dogecoin/archive/refs/tags/v${DOGECOIN_VERSION}.tar.gz
RUN echo "$DOGECOIN_DOWNLOAD_SHA256  v${DOGECOIN_VERSION}.tar.gz" | sha256sum -c -
RUN tar -xzf *.tar.gz && rm *.tar.gz

WORKDIR /dogecoin-${DOGECOIN_VERSION}

RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h
RUN ./autogen.sh
RUN ./configure \
    --prefix=${DOGECOIN_PREFIX} \
    --mandir=/usr/share/man \
    --disable-tests \
    --disable-bench \
    --disable-ccache \
    --without-gui \
    --without-miniupnpc \
    --disable-maintainer-mode \
    --disable-dependency-tracking \
    --with-libs \
    --with-daemon \
    --with-utils \
      CFLAGS="-O2 -g" \
      CXXFLAGS="-Wno-cpp -O2 -g" \
      LDFLAGS='-L/usr/local/bdb/lib/ -static-libstdc++' \
      CPPFLAGS='-I/usr/local/bdb/include/'
RUN make -j4
RUN make check -j4
RUN make install
RUN strip ${DOGECOIN_PREFIX}/bin/dogecoin-cli
RUN strip ${DOGECOIN_PREFIX}/bin/dogecoin-tx
RUN strip ${DOGECOIN_PREFIX}/bin/dogecoind
RUN strip ${DOGECOIN_PREFIX}/lib/libdogecoinconsensus.a
RUN strip ${DOGECOIN_PREFIX}/lib/libdogecoinconsensus.so.0.0.0

# Build stage for compiled artifacts
FROM alpine

LABEL maintainer.0="xanimo (@xanimo)"

RUN adduser -S dogecoin
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add \
  boost-filesystem \
  boost-system \
  boost-thread \
  boost-dev \
  libevent-dev \
  libzmq \
  su-exec 

ENV DOGECOIN_DATA=/home/dogecoin/.dogecoin
ENV DOGECOIN_VERSION=1.14.3
ENV DOGECOIN_PREFIX=/opt/dogecoin-${DOGECOIN_VERSION}
ENV PATH=${DOGECOIN_PREFIX}/bin:$PATH

COPY --from=dogecoin-core /opt /opt
COPY docker-entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

VOLUME ["/home/dogecoin/.dogecoin"]

EXPOSE 22555 22556 44555 44556 18444

ENTRYPOINT ["/entrypoint.sh"]

RUN dogecoind -version | grep "Dogecoin Core Daemon version v${DOGECOIN_VERSION}"

CMD ["dogecoind"]
