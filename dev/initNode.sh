#! /bin/bash

ROOTPATH=$(cd `dirname $0`; pwd)

NODEVERSION=$(cat ${ROOTPATH}/DEV_VERSIONS | grep node | cut -d" " -f2)

# check
INSTALLEDV=$(cat ${DEVSENV}/node/VERSION)
if [[ ${INSTALLEDV} = ${NODEVERSION} ]];then
    echo "node ${NODEVERSION} already installed"
    return
fi

echo "node version: ${NODEVERSION}"

NODEPACK=${ROOTPATH}/package/node-v${NODEVERSION}-linux-x64.tar.xz
NODEURL="https://nodejs.org/dist/v${NODEVERSION}/node-v${NODEVERSION}-linux-x64.tar.xz"

NODEROOT=${DEVSENV}/node
if [ ! -d ${NODEROOT} ];then
    mkdir -p ${NODEROOT}
fi

if [ ! -f ${NODEPACK} ];then    
    wget -O ${NODEPACK} ${NODEURL}
fi
tar -xvf ${NODEPACK} -C ${NODEROOT}
res=$(mv ${NODEROOT}/node-v${NODEVERSION}-linux-x64 ${NODEROOT}/${NODEVERSION})
if [ -z "$res" ];then
    echo ${NODEVERSION} > ${NODEROOT}/VERSION
fi
echo "install node step finished"