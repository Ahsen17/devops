#! /bin/bash
# shellcheck disable=SC2086,SC2034,SC2009

WORKPOTFLAG=services
ROOTPATH=/usr/local/${WORKPOTFLAG}
SERVPLACE=${ROOTPATH}/servplace
WORKPLACE=${ROOTPATH}/workplace

# 工作脚本
#curPath=$(pwd)
scriptName=$(echo $0 | awk -F/ '{print $NF}')

# 工作目录
[[ -d ${SERVPLACE}/${scriptName} ]] && demoPath=${SERVPLACE}/${scriptName} || demoPath=${WORKPLACE}/${scriptName}

version=$(cat ${demoPath}/VERSION)
workDir=${demoPath}/${version}/bin
workExec=${workDir}/${scriptName}

# 配置文件
confDir=/etc/${scriptName}
# confFile=${confDir}/${scriptName}.yml
confFile=${confDir}/config.toml
withNacos=false
nacosConfUrl="http://localhost:xxxx/"

# 日志
logDir=${ROOTPATH}/logs/${scriptName}
logFile=${logDir}/${scriptName}.log

# 数据
dataDir=/${ROOTPATH}/data/${scriptName}

echo " $(date) "

function init(){
  echo "exec init, version: ${version}"

  if [ ! -d ${workDir} ];then
    echo "workdir not found ${workDir}"
    return
  elif [ ! -d ${confDir} ];then
    # 部分程序无需配置文件，此步骤可忽略
    echo "confDir not found ${confDir}, maybe some doesn't need..."
  elif [ ! -d ${logDir} ];then
    mkdir -p ${logDir}
  elif [ ! -d ${dataDir} ];then
    mkdir -p ${dataDir}
  fi

  echo "done."
}

init

function start(){
  echo "exec ${scriptName} start"
  # 各程序启动命令不一致，请根据实际情况配置
  sudo nohup ${workExec} --configs ${confDir} &> ${logFile} &
}

function stop(){
  echo "exec ${scriptName} stop"
  ps -ef | grep ${scriptName} | grep -v grep | awk '{print $2}' | xargs kill -9
}

function restart(){
  echo "exec ${scriptName} restart"
  stop
  sleep 1
  start
}

function status(){
  echo "exec ${scriptName} status"
  ps aux | grep ${scriptName} | grep -v grep | grep -v status
}

function config(){
  echo "exec ${scriptName} config"
  cat ${confFile}
}

function log(){
  echo "exec ${scriptName} log"
  tail -f ${logFile}
}

function version(){
  echo "exec ${scriptName} version"
  echo ${version}
}

function update(){
    echo "exec ${scriptName} update"
    echo "stopping ${scriptName}..."
    stop
    
    echo "check latest version..."
    mkdir -p ${WORKPLACE}/nightingale
    cd ${WORKPLACE}/nightingale
    ROOT=$(pwd -P)
    GIT_COMMIT=$(git --work-tree ${ROOT}  rev-parse 'HEAD^{commit}')
    _GIT_VERSION=$(git --work-tree ${ROOT} describe --tags --abbrev=14 "${GIT_COMMIT}^{commit}" 2>/dev/null)
    version=$(echo $_GIT_VERSION | cut -d'-' -f1)

    if [ ! -d ${demoPath}/${version} ];then
      echo "update server version: ${version}"
      echo ${version} > ${demoPath}/VERSION
      mkdir ${demoPath}/${version}
      mkdir ${demoPath}/${version}/bin
    fi

    echo "prepare front..."
    cd ${demoPath}
    TAG=$(curl -sX GET https://api.github.com/repos/n9e/fe/releases/latest   | awk '/tag_name/{print $4;exit}' FS='[""]')
    if [ ! -f "n9e-fe-${TAG}.tar.gz" ];then
      wget "https://github.com/n9e/fe/releases/download/${TAG}/n9e-fe-${TAG}.tar.gz"
    fi
    if [ ! -d "${version}/pub" ];then
      cp n9e-fe-${TAG}.tar.gz ${version}/ && cd ${version}
      tar -xvf n9e-fe-${TAG}.tar.gz
      rm -rf n9e-fe-${TAG}.tar.gz
    fi

    echo "prepare backend..."
    cd ${WORKPLACEPATH}/nightingale
    git pull # update official codes
    make

    workDir=${demoPath}/${version}/bin
    workExec=${workDir}/${scriptName}
    cp ${scriptName} ${workExec}
    echo "update done."
}

function helpText(){
  echo "Usage: ${scriptName} {start|stop|restart|status|config|log|version|update}"
}

operate=$1
if [[ $operate == start ]];then
  start
elif [[ $operate == stop ]];then
  stop
elif [[ $operate == restart ]];then
  restart
elif [[ $operate == status ]];then
  status
elif [[ $operate == config ]];then
  config
elif [[ $operate == log ]];then
  log
elif [[ $operate == version ]];then
  version
elif [[ $operate == update ]];then
  update
else
  helpText
fi
