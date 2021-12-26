
# Build stage for compiled artifacts
FROM alpine:latest

LABEL maintainer.0="xanimo (@xanimo)"

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ARG USER=dogecoin
ENV USER=${USER}
ENV UID=10001

ENV DOGECOIN_DATA=/home/${USER}/.dogecoin
ENV DOGECOIN_VERSION=1.14.6-dev

RUN addgroup ${USER} \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

RUN apk --no-cache add \
  su-exec \
  && echo "${LANG} UTF-8" > /etc/profile.d/locale.sh

ENV PATH=/usr/local/bin:$PATH

COPY --from=xanimo/dogecoin-core:source \
  /dogecoin-${DOGECOIN_VERSION}/src/dogecoind \
  /dogecoin-${DOGECOIN_VERSION}/src/dogecoin-cli \
  /dogecoin-${DOGECOIN_VERSION}/src/dogecoin-tx \
  /dogecoin-${DOGECOIN_VERSION}/entrypoint.sh /usr/local/bin/

COPY dogecoin.conf dogecoind.pid ${DOGECOIN_DATA}/

VOLUME ["${DOGECOIN_DATA}"]

EXPOSE 22555 22556 44555 44556 18332 18444

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

RUN chmod +x /usr/local/bin/*
RUN sed -i "s/root:x:0:0:root:\/root:\/bin\/ash/root:x:0:0:root:\/root:\/sbin\/nologin/g" /etc/passwd
RUN dogecoind -version | grep "Dogecoin Core Daemon version v${DOGECOIN_VERSION:0:4}"
CMD ["dogecoind", "-printtoconsole"]