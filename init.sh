#! /bin/bash

export BASEDIR=/usr/local/services
if [ ! -d ${BASEDIR} ];then
    echo "${BASEDIR} not exist, start init"
    mkdir -p ${BASEDIR}
fi

# init base env
cp .env ${BASEDIR}/.env
env=$(cat ~/.bashrc | grep ${BASEDIR}/.env)
if [ -z "$env" ];then
    echo ". ${BASEDIR}/.env" >> ~/.bashrc
fi


export PROXY_TOKEN=$(cat token/proxy.token)
export PROXY_PATH=${BASEDIR}/proxy
export DEVSENV=${BASEDIR}/devsenv

. script/init/initProxy.sh
. script/init/initGo.sh
. script/init/initPy.sh