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
workDir=${demoPath}/${version}
workExec=${workDir}/${scriptName}

# 配置文件
# confDir=/etc/${scriptName}
confDir=${workDir}/conf
confFile=${confDir}/config.yaml
withNacos=false
nacosConfUrl="http://localhost:xxxx/"

# 日志
logDir=${ROOTPATH}/logs/${scriptName}
# logFile=${logDir}/${scriptName}.log
logFile=${workDir}/logs/clash.log

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
  bash ${workDir}/start.sh
  
  export http_proxy=http://127.0.0.1:7890
  export https_proxy=http://127.0.0.1:7890
  export no_proxy=127.0.0.1,localhost
  export HTTP_PROXY=http://127.0.0.1:7890
  export HTTPS_PROXY=http://127.0.0.1:7890
  export NO_PROXY=127.0.0.1,localhost
  echo -e "\033[32m[√] proxy online\033[0m"
}

function stop(){
  echo "exec ${scriptName} stop"
  bash ${workDir}/shutdown.sh
  
  unset http_proxy
  unset https_proxy
  unset no_proxy
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset NO_PROXY
  echo -e "\033[31m[×] proxy offline\033[0m"
}

function restart(){
  echo "exec ${scriptName} restart"
  # bash ${workDir}/restart.sh
  stop
  sleep 1
  start
}

function status(){
  echo "exec ${scriptName} status"
  env | grep -E 'http_proxy|https_proxy'
  echo ""
  netstat -tln | grep -E '9090|789.'
}

function update() {
  echo "exec ${scriptName} update"
  # 请根据实际情况配置
  cd ${workDir}
  git pull
}

function config(){
  echo "exec ${scriptName} config"
  cat ${confFile}
}

function settoken() {
  echo "exec ${scriptName} settoken"
  read -p "input: " token
  sed -i 's|export CLASH_URL=.*|export CLASH_URL='\'${token}\''|' ${workDir}/.env
  
  echo "" >> ${workDir}/.env
  echo "# ${token}" >> ${workDir}/.env

  restart
}

function log(){
  echo "exec ${scriptName} log"
  tail -f ${logFile}
}

function version(){
  echo "exec ${scriptName} version"
  echo ${version}
}

function helpText(){
  echo "Usage: ${scriptName} {start|stop|restart|status|config|log|version|update|settoken}"
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
elif [[ $operate == update ]];then
  update
elif [[ $operate == config ]];then
  config
elif [[ $operate == settoken ]];then
  settoken
elif [[ $operate == log ]];then
  log
elif [[ $operate == version ]];then
  version
else
  helpText
fi
