# Build stage for Dogecoin Core
FROM ubuntu:focal as build

RUN apt-get update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y git bash bc binutils bison libbison-dev bzip2 build-essential ccache coreutils diffutils findutils gawk git libc6 grep gzip libarchive-dev lzip libzstd-dev m4 make perl rsync sed texinfo xz-utils zstd \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*