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

# init development env
export DEVSENV=${BASEDIR}/devsenv
. script/init/initGo.sh
. script/init/initPy.sh
