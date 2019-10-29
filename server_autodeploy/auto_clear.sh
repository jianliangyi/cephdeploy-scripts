#!/usr/bin/bash

source ./ceph_hosts.sh

for node in ${ceph_nodes[@]}; do
  ceph-deploy purge $node
  ceph-deploy purgedata $node
  ssh root@$node "sh /root/sense-ceph/pkg_remove.sh"
done

for node in ${ceph_hdds[@]}; do
  ssh root@$node "sh /root/sense-ceph/osd_remove.sh"
done

for node in ${ceph_ssds[@]}; do
  ssh root@$node "sh /root/sense-ceph/osd_remove.sh"
done

ceph-deploy forgetkeys

