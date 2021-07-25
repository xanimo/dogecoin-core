# Build stage for mussel toolchain
FROM ubuntu:focal as build

RUN apt-get update -y \
  && apt-get install -y git bash bc binutils bison libbison-dev bzip2 build-essential ccache coreutils diffutils findutils gawk git grep gzip libarchive-dev lzip libzstd-dev m4 make perl rsync sed texinfo wget xz-utils zstd

# RUN ln -s /lib/x86_64-linux-gnu/libc.so.6 /lib/libc.so.6

RUN git clone https://github.com/xanimo/mussel /mussel

WORKDIR /mussel

RUN ./check.sh

RUN ./mussel.sh x86_64 -p