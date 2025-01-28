#! /bin/bash

ROOTPATH=$(cd `dirname $0`; pwd)

PYVERSION=$(python3 -V | cut -d" " -f2)
PYVENV=${DEVSENV}/python/${PYVERSION}/venv

# check
if [ -d ${PYVENV} ];then
    echo "python3 ${PYVERSION} already initialized"
    return
fi

echo "python3 version: ${PYVERSION}"
mkdir -p ${DEVSENV}/python
echo ${PYVERSION} > ${DEVSENV}/python/VERSION

sudo apt-get install python3.10-pip python3.10-dev python3.10-venv -y
python3 -m venv ${PYVENV}

. ${PYVENV}/bin/activate
pip install --upgrade pip
deactivate

echo "install python3 step finished"
