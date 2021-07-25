# Build stage for mussel toolchain
FROM ubuntu:focal as build

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y git bash bc binutils bison libbison-dev bzip2 build-essential ccache coreutils diffutils findutils gawk git grep gzip libarchive-dev libc6 lzip libzstd-dev m4 make perl rsync sed texinfo wget xz-utils zstd

RUN ln -s /lib/x86_64-linux-gnu/libc.so.6 /lib/libc.so.6

RUN git clone https://github.com/xanimo/mussel /mussel

WORKDIR /mussel

RUN ./check.sh

RUN ./mussel.sh x86_64 -k -l -o -p