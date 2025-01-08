#! /bin/bash

ROOTPATH=$(cd `dirname $0`; pwd)

GOVERSION=$(cat ${ROOTPATH}/DEV_VERSIONS | grep golang | cut -d" " -f2)

# check
INSTALLEDV=$(cat ${DEVSENV}/golang/VERSION)
if [[ ${INSTALLEDV} = ${GOVERSION} ]];then
    echo "golang ${GOVERSION} already installed"
    return
fi

echo "go version: ${GOVERSION}"

GOPACK=${ROOTPATH}/package/go${GOVERSION}.linux-amd64.tar.gz
GOURL="https://go.dev/dl/go${GOVERSION}.linux-amd64.tar.gz"

GOROOT=${DEVSENV}/golang
if [ ! -d ${GOROOT} ];then
    mkdir -p ${GOROOT}
fi

if [ ! -f ${GOPACK} ];then
    wget -O ${GOPACK} ${GOURL}
fi
tar -xvf ${GOPACK} -C ${GOROOT}
res=$(mv ${GOROOT}/go ${GOROOT}/${GOVERSION})
if [ -z "$res" ];then
    echo ${GOVERSION} > ${GOROOT}/VERSION
fi
echo "install go step finished"
