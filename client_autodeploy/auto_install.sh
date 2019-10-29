#!/usr/bin/bash

source ./client_hosts.sh

# install python api
function api_install() {
  echo "============== python api ============="
  for node in ${client_nodes[@]}; do
    echo "=== node: $node" ====
    scp -r client_pythonapi root@$node:/root
    ssh root@$node "cd /root/client_pythonapi/petrel-oss-python-sdk && sh INSTALL"
  done
}

# install awscli api
function awscli_install() {
  echo "============== awscli tool ============="
  for node in ${client_nodes[@]}; do
    echo "=== node: $node" ====
    scp -r client_tools root@$node:/root
    ssh root@$node "cd /root/client_tools/awscli && sh build.sh"
    ssh root@$node "cd /root/client_tools/s3cmd && python setup.py install"
  done
}

api_install

awscli_install

