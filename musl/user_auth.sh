#!/bin/bash

apt update
apt -y upgrade
apt install -y python3-pip
$(echo -e $(bash ./share/rpcuser/rpcuser.py dogecoin) > log.txt)
cat <<EOT >> dogecoin.conf
# [network]
# Accept incoming connections from peers.   
server=1
listen=1   
bantime=15
rpcallowip=0.0.0.0/0
rpcthreads=16
rpcworkqueue=1000
bind=0.0.0.0:22556
bind=[::]:22556
rpcbind=127.0.0.1:22555

wallet=1

harddustlimit=0.02
EOT
rpcauth=$(echo -e $(grep rpcauth log.txt | cut -d '=' -f 2 ))
rpcuser=$(echo $rpcauth | awk '{print $1}' | cut -d ':' -f 1)
rpcpassword=$(echo $rpcauth | awk '{print $1}' | cut -d ':' -f 2)
$(echo -e rpcuser=$(echo $rpcuser) >> dogecoin.conf)
$(echo -e rpcpassword=$(echo $rpcpassword) >> dogecoin.conf)
$(echo -e '# PLEASE REMOVE THIS PASSWORD AT YOUR EARLIEST CONVENIENCE' >> dogecoin.conf)
$(echo -e pw=$(cat log.txt | awk '{print $10}') >> dogecoin.conf)
rm log.txt
