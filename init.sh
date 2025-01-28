#! /bin/bash

export BASEDIR=/usr/local/services
if [ ! -d ${BASEDIR} ];then
    echo "${BASEDIR} not exist, start init"
    mkdir -p ${BASEDIR}
fi

export DEVSENV=${BASEDIR}/devsenv
export WORKPLACE=${BASEDIR}/workplace
export SERVPLACE=${BASEDIR}/servplace

export PROXY_TOKEN=$(cat token/proxy.token)
export PROXY_PATH=${SERVPLACE}/proxy

export DATADIR=${BASEDIR}/data

# init and load dev env
for d in $(ls); do
  if [ -d $(pwd)/$d ]; then
    for i in $(pwd)/$d/init*.sh; do
      if [ -r $i ]; then
        . $i
      fi
    done
    unset i
  fi
done
unset d

# shell script soft links
_script=${BASEDIR}/script
mkdir -p ${_script}
for i in $(pwd)/script/*.sh; do
  if [ -r $i ]; then
    _name=$(echo $i | tail -n 1 | awk -F '.' '{print $1}' | awk -F'/' '{print $NF}')
    ln -s $i ${_script}/${_name}
  fi
done
unset i

# add custom script path to PATH
if [ -z $(cat ~/.bashrc | grep ${_script}) ]; then
  echo '
# custom script path
_script='${_script}'
if [[ $PATH != *${_script}* ]]; then
  PATH=$PATH:${_script}
fi' >> ~/.bashrc
fi

. ~/.bashrc
