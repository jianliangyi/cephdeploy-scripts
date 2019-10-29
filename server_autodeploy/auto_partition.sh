#!/usr/bin/bash

source ./ceph_hosts.sh

# prepare disks
function make_hdd_partition() {
  echo "============== partition disk ============="
  for node in ${ceph_hdds[@]}; do
    echo "=== node: $node" ====
    ssh root@$node "cd /root/sense-ceph && sh hdd_partiton.sh"
  done
}

# prepare ssds
function make_ssd_partition() {
  echo "============== partition ssd ============="
  for node in ${ceph_ssds[@]}; do
    echo "=== node: $node" ====
    ssh root@$node "cd /root/sense-ceph && sh ssd_partiton.sh"
  done
}


make_hdd_partition

make_ssd_partition

