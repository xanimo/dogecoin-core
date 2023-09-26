# Build stage for Dogecoin Core
FROM xanimo/musl-toolchain AS build

ENV PKG_CONFIG_PATH=$MSYSROOT/usr/lib/pkgconfig:$MSYSROOT/usr/share/pkgconfig
ENV PKG_CONFIG_LIBDIR=$MSYSROOT/usr/lib/pkgconfig:$MSYSROOT/usr/share/pkgconfig
ENV PKG_CONFIG_SYSROOT_DIR=$MSYSROOT

ENV PKG_CONFIG_SYSTEM_INCLUDE_PATH=$MSYSROOT/usr/include
ENV PKG_CONFIG_SYSTEM_LIBRARY_PATH=$MSYSROOT/usr/lib

RUN apt-get update && apt-get -y install git
ENV DOGECOIN_VERSION=v1.14.6
ENV DOGECOIN_PREFIX=/app

RUN git clone https://github.com/dogecoin/dogecoin.git /dogecoin-${DOGECOIN_VERSION}

WORKDIR /dogecoin-${DOGECOIN_VERSION}
RUN git checkout ${DOGECOIN_VERSION}
RUN mkdir -p mussel/
COPY --from=xanimo/musl-toolchain mussel/ mussel/
RUN PATH=/mussel/toolchain/bin:/usr/bin:/bin
RUN apt-get update && apt-get install -y \
    curl \
    binutils \
    libbsd-dev \
    libunwind-dev \
    libtool-bin \
    gettext \
    lcov \
    autotools-dev \
    libtool \
    libtool-bin \
    pkg-config \
    bsdmainutils \
    automake \
    build-essential \
    python3 \
    python3-zmq
RUN make \
  HOST=x86_64-linux-musl \
  NO_QT=1 \
  NO_UPNP=1 \
  -s -j$(nproc) \
  -C depends
RUN libtool --finish $PWD/depends/x86_64-linux-musl/lib
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
  --enable-static-nss \
  --with-sysroot="/mussel/sysroot/" \
  LD_LIBRARY_PATH="/mussel/toolchain/lib/" \
  CC="x86_64-linux-musl-gcc" \
  CXX="x86_64-linux-musl-g++" \
  CROSS_COMPILE="x86_64-linux-musl-" \
  CHOST="x86_64-linux-musl" \
  CPPFLAGS="-I/mussel/toolchain/include/" \
  CFLAGS="-g0 -Os -static --static -fPIC" \
  CXXFLAGS="-DDEBUG_LOCKORDER -g -g0 -Os -s -static --static -fPIC -fvisibility=hidden" \
  LIBDIR="/mussel/toolchain/lib/" \
  LDFLAGS="-L/mussel/toolchain/lib/ -s -static-libgcc -static-libstdc++ -Wl,-rpath -Wl,LIBDIR,-O2"
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

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN adduser -S dogecoin

RUN apk update && apk upgrade && apk --no-cache add \
  su-exec \
  && echo "${LANG} UTF-8" > /etc/profile.d/locale.sh

ENV DOGECOIN_DATA=/home/dogecoin/.dogecoin
ENV DOGECOIN_VERSION=v1.14.6

RUN mkdir -p /app \
  && chown -R nobody:nogroup /app

ENV PATH=/app/bin:$PATH

WORKDIR /app
COPY --from=build \
    /dogecoin-${DOGECOIN_VERSION}/src/dogecoind \
    /dogecoin-${DOGECOIN_VERSION}/src/dogecoin-cli \
    /dogecoin-${DOGECOIN_VERSION}/src/dogecoin-tx /app/bin/

COPY dogecoin.conf /app/dogecoin.conf
COPY dogecoind.pid /app/dogecoin.pid

COPY docker-entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]

VOLUME ["/home/dogecoin/.dogecoin"]
VOLUME ["/sys/fs/cgroup"]

EXPOSE 22555 22556 44555 44556

ENTRYPOINT ["/entrypoint.sh"]

RUN chmod -R 755 /app/*

CMD ["dogecoind", "-datadir=/app"]
