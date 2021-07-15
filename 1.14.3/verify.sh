#!/bin/sh

helpFunction()
{
   echo ""
   echo "Usage: $0 -f parameterF"
   echo -e "\t-a File that needs to be verified."
   exit 1 # exit script after printing help
}

while getopts "f:" opt
do
   case "$opt" in
      f ) parameterF="$OPTARG" ;;
      ? ) helpFunction ;; # print helpFunction in case parameter is non-existent
   esac
done

# print helpFunction in case parameters are empty
if [ -z "$parameterF" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# begin script in case all parameters are correct
echo "$parameterF"

getKeyId() {
    if [ -z $1 ]
    # checks if any params.
    then
        echo "No parameters passed to function."
        return 0
    else
        # fetch keyid
        gpg --list-packets < $1 | awk '$1=="keyid:"{print$2; exit}'
    fi
}

getUserId() {
    if [ -z $1 ]
    # checks if any params
    then
        echo "No parameters passed to function."
        return 0
    else
        # fetch user id between double quotes
        gpg --list-packets < $1 | awk -F'"' '$0=$2'
    fi
}

fileHash() {
    if [ -z $1 ]
    # checks if any params
    then
        echo "No parameters passed to function."
        return 0
    else
        # fetch sha256sum from file
        echo `sha256sum $1` | awk '{print $1;}'
    fi
}

# env vars
EXT=pgp
GITIAN_DESCRIPTOR_URL=https://raw.githubusercontent.com/dogecoin/dogecoin/master/contrib/gitian-descriptors/gitian-linux.yml

# fetch and strip contrib/gitian-keys dir
wget -O - https://github.com/dogecoin/dogecoin/archive/master.tar.gz | tar xz --strip=2 "dogecoin-master/contrib/gitian-keys"

# fetch and strip gitian.sigs/1.14.3-linux for verifying precompiled dogecoind binaries
wget -O - https://github.com/dogecoin/gitian.sigs/archive/master.tar.gz | tar xz --strip=0 "gitian.sigs-master/1.14.3-linux"
# cd gitian-keys && gpg --dry-run --keyid-format long --import <*.pgp && gpg --refresh-keys

cd gitian-keys
# delete previous keyid/userid write to keys.txt
rm ./keys.txt

# iterate through gitian-keys and extract keyid/userid from each .pgp pubkey to ./keys.txt
for i in *; do
    if [ "${i}" != "${i%.${EXT}}" ];then
        echo $(getKeyId $i) $(getUserId $i) >> ./keys.txt
    fi
done

# iterate through keys.txt we just updated and verify from keyserver.ubuntu.com
bash -xc 'pushd `pwd` ;
while read fingerprint keyholder_name; 
do gpg --keyserver keyserver.ubuntu.com --recv-keys ${fingerprint}; done < ./keys.txt ;
popd ;'

# iterate through gitian.sigs-master and verify signers via gpg
for i in *; do
    if [ "$(find . -type f -name '*.assert')" ];then
        gpg --verify "$i/dogecoin-linux-1.14-build.assert.sig"
    fi
done

# cd base (1.14.3)
cd ../

# rm and dl gitian-linux.yml for gverify
rm gitian-linux.yml
wget ${GITIAN_DESCRIPTOR_URL}

# verify signers additional time via gitian-builder gverify script
./gverify --destination ./gitian.sigs-master/ --release 1.14.3-linux ./gitian-linux.yml

# pass -f argument to filehash function and set env var 
FILEHASH=$(fileHash "$parameterF")
# echo ${FILEHASH}
# echo `pwd`

# count number of verified signers to assert against build.assert
count=`grep -r "${FILEHASH}" gitian.sigs-master/1.14.3-linux/ | wc -l`

# if at least 4 verified signers contain precompiled dogecoin binaries
# filehash in build.assert complete verification by cleaning up directory
if [ "$count" -ge 4 ]; then
    echo "OK";
    rm gitian-linux.yml
    rm -rf ./gitian-keys ./gitian.sigs-master
  else
    echo "$parameterF: NOT VALID!"
    exit 1;
fi