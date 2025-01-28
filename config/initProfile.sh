#! /bin/bash

# This script is used to initialize the custom profile.

if [ ! -d "${BASEDIR}" ]; then
    exit 1
fi

echo '#! /bin/bash

BASEDIR='${BASEDIR}'

DEVSENV='${DEVSENV}'
WORKPLACE='${WORKPLACE}'
SERVPLACE='${SERVPLACE}'

# golang env vars setting
GOHOME=${DEVSENV}/golang
GOVERSION=$(cat ${GOHOME}/VERSION | tail -n 1)

GOBINBASE=${GOHOME}/${GOVERSION}/bin
GODATABASE=${BASEDIR}/data/golang

if [ -n ${GOVERSION} ] && \
[[ $PATH != *${GOBINBASE}* ]];then
    PATH=$PATH:${GOBINBASE}
fi

export GOCACHE=${GODATABASE}/.cache/go-build
export GOENV=${BASEDIR}/.config/go/env
export GOPATH=${GODATABASE}/${GOVERSION}
export GOPROXY=https://goproxy.cn,direct
export GOROOT=${GOHOME}/${GOVERSION}

# python env vars setting
PYHOME=${DEVSENV}/python
PYVERSION=$(cat ${PYHOME}/VERSION)
PYACTIVATE=${PYHOME}/${PYVERSION}/venv/bin/activate

# custom alias
alias cls='\'clear\''
alias psg='\'ps aux \| grep\''
alias pyac='\'source \''${PYACTIVATE}

' > ${BASEDIR}/profile

mkdir -p ${BASEDIR}/profile.d

if [ -z $(cat ~/.bashrc | grep "_dir=${BASEDIR}") ]; then
  echo '
# set custom bash if it exists
_dir='${BASEDIR}'
if [ -d ${_dir} ]; then
  if [ -f ${_dir}/profile ]; then
    . ${_dir}/profile
  fi

  if [ -d ${_dir}/profile.d ]; then
    for i in ${_dir}/profile.d/*.sh; do
      if [ -r $i ]; then
        . $i
      fi
    done
    unset i
  fi
fi
' >> ~/.bashrc
fi