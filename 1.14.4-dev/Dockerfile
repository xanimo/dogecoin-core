# Build stage for Dogecoin Core
FROM ubuntu:focal as build

RUN apt-get update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y git curl libtool libtool-bin pkg-config bsdmainutils autotools-dev automake build-essential python3

ENV DOGECOIN_VERSION=1.14.4-dev
ENV DOGECOIN_PREFIX=/app

RUN git clone https://github.com/xanimo/dogecoin.git /dogecoin-${DOGECOIN_VERSION}

WORKDIR /dogecoin-${DOGECOIN_VERSION}

RUN git fetch && git checkout 9ba6538b2af01b08cfe5bb2719a556ec3e93ffa0

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
  # on the fence as to benefit of static nss...
  # --enable-static-nss \
  LD_LIBRARY_PATH="/usr/lib/ld-musl-x86_64.so.1" \
  CC="musl-gcc -g -specs=/usr/lib/x86_64-linux-musl/musl-gcc.specs" \
  CXX=musl-g++ \  
  CROSS_COMPILE=x86_64-linux-musl- \
  CHOST=x86_64-linux-musl \
  CFLAGS="-g0 -Os -static --static -fPIC" \
  CXXFLAGS="-g0 -Os -static --static -fPIC -fvisibility=hidden" \
  LIBDIR=/usr/lib/x86_64-linux-musl/ \
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

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN adduser -S dogecoin
RUN apk update && apk upgrade && apk --no-cache add \
  su-exec \
  && echo "${LANG} UTF-8" > /etc/profile.d/locale.sh

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

EXPOSE 22555 22556 44555 44556

ENTRYPOINT ["/entrypoint.sh"]

RUN chmod -R 755 /app/*

CMD ["dogecoind"]