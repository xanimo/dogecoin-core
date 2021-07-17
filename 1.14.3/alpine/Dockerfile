FROM alpine:latest

ENV LANG=C.UTF-8

LABEL maintainer.0="xanimo (@xanimo)"

ENV DOGECOIN_VERSION=1.14.3
ENV DOGECOIN_DATA=/home/dogecoin/.dogecoin
ENV DOGECOIN_PREFIX=/opt/dogecoin-${DOGECOIN_VERSION}
ENV PATH=${DOGECOIN_PREFIX}/bin:$PATH
ENV GLIBC_PACKAGE_VERSION="2.33-r0"
ENV GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download"
ENV GLIBC_BASE_PACKAGE="glibc-$GLIBC_PACKAGE_VERSION.apk"
ENV GLIBC_BIN_PACKAGE="glibc-bin-$GLIBC_PACKAGE_VERSION.apk"
ENV GLIBC_I18N_PACKAGE="glibc-i18n-$GLIBC_PACKAGE_VERSION.apk"
ENV GLIBC_BASE_PACKAGE_URL="$GLIBC_BASE_URL/$GLIBC_PACKAGE_VERSION/$GLIBC_BASE_PACKAGE" 
ENV GLIBC_BIN_PACKAGE_URL="$GLIBC_BASE_URL/$GLIBC_PACKAGE_VERSION/$GLIBC_BIN_PACKAGE" 
ENV GLIBC_I18N_PACKAGE_URL="$GLIBC_BASE_URL/$GLIBC_PACKAGE_VERSION/$GLIBC_I18N_PACKAGE"

ARG TARGETPLATFORM

RUN set -x \
    && apk add --no-cache --virtual=.build-dependencies wget ca-certificates \
    && echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" \
    && wget ${GLIBC_BASE_PACKAGE_URL} ${GLIBC_BIN_PACKAGE_URL} ${GLIBC_I18N_PACKAGE_URL} \
    && apk add --no-cache ${GLIBC_BASE_PACKAGE} ${GLIBC_BIN_PACKAGE} ${GLIBC_I18N_PACKAGE} \
    && rm "/etc/apk/keys/sgerrand.rsa.pub" \
    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 $LANG || true \
    && echo "export LANG=${LANG}" > /etc/profile.d/locale.sh \
    && apk del glibc-i18n \
    && rm "/root/.wget-hsts" \
    && apk del .build-dependencies \
    && rm ${GLIBC_BASE_PACKAGE} ${GLIBC_BIN_PACKAGE} ${GLIBC_I18N_PACKAGE}

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN adduser -S dogecoin
RUN set -x \
    && apk add --no-cache wget gnupg su-exec \
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

EXPOSE 22555 22556 44555 44556 18444

ENTRYPOINT ["/entrypoint.sh"]

RUN dogecoind -version | grep "Dogecoin Core Daemon version v${DOGECOIN_VERSION}"

CMD ["dogecoind"]