#! /bin/bash

ROOTPATH=$(cd `dirname $0`; pwd)

# check
if [ -d ${PROXY_PATH} ]; then
    echo "proxy has been installed."
    return
fi

# install
PROXY_URL="https://github.com/wnlen/clash-for-linux.git"
git clone ${PROXY_URL} ${PROXY_PATH}

# config
proxy_config='# proxy config
export CLASH_URL='${PROXY_TOKEN}'
export CLASH_SECRET='ahsen'
'

cat > ${PROXY_PATH}/.env <<EOF
${proxy_config}
EOF

echo "install proxy finished"