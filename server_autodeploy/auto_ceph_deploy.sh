#!/usr/bin/bash

source ./ceph_hosts.sh

# copy and install ceph packages to remote node
function install_ceph() {
  echo "============== install ceph ==============="

  vip_0=${lvs_vip[0]};
  vip_1=${lvs_vip[1]};
  sed -i "s/vip0/$vip_0/g" sense-ceph/keepalive/lvs_dr_rs.sh;
  sed -i "s/vip1/$vip_1/g" sense-ceph/keepalive/lvs_dr_rs.sh;

  if [ -d sense-ceph ]; then
    for node in ${ceph_nodes[@]}; do
      echo "=== copy sense-ceph to node: $node" ====
      scp -r -q sense-ceph root@$node:/root/
      if [ $? -eq 0 ]; then
	ssh root@$node "cd /root/sense-ceph && sh install.sh"
      else
	echo "copy sense-ceph to $node fail"
      fi
    done
  else
    echo "subdirectory sense-ceph doesn'g exist! exit."
    exit 1
  fi
}

# prepare disks
function make_partition() {
  echo "============== partition disk ============="
  for node in ${ceph_hdds[@]}; do
    echo "=== node: $node" ====
    ssh root@$node "cd /root/sense-ceph && sh make_partiton.sh"
  done
}

# generate hosts file
function generate_hosts() {
  echo "============= generate hosts file ========="
  echo > hosts
  for node in ${ceph_nodes[@]}; do
    echo "=== node: $node" ====
    name=`ssh $node "hostname"`
    line=$node"    "$name
    echo $line >> hosts
    echo "line: $line"
  done

  #for node in $@; do
  #  scp hosts $node:/etc/hosts
  #done
  cp hosts /etc/ -f
}

# close firewall
function change_firewall(){
  echo "============= close firewall ==========="
  for node in ${ceph_nodes[@]};
  do
    ssh $node "systemctl stop firewalld"
    ssh $node "systemctl disable firewalld"
  done
}


# create monitors
function create_mon() {
  echo "============= create mons ==========="
  mon_1=`cat ./hosts | grep ${ceph_mons[0]} | awk '{print $2}'`
  mon_2=`cat ./hosts | grep ${ceph_mons[1]} | awk '{print $2}'`
  mon_3=`cat ./hosts | grep ${ceph_mons[2]} | awk '{print $2}'`
  mons_initial_members=$mon_1","$mon_2","$mon_3
  mon_host="${ceph_mons[0]},${ceph_mons[1]},${ceph_mons[2]}"
  ipoib=`ifconfig | sed -n '/ib/,+1p' | grep inet | awk '{print $2}'`
  ipeth0=`ifconfig | sed -n '/eth0/,+1p' | grep inet | awk '{print $2}'`
  ipoib_prefix=`echo ${ipoib%.*}`
  ipeth0_prefix=`echo ${ipeth0%.*}`
  network=$ipoib_prefix".0/23"

  echo "mons: "$mon_1 $mon_2 $mon_3

  ceph-deploy new $mon_1 $mon_2 $mon_3

  sed -i "/^mon_host\ =/cmon_host\ =\ $mon_host" ceph.conf;
  cat ceph_common.conf >> ceph.conf
  sed -i "/^cluster_network\ =/ccluster_network\ =\ $network" ceph.conf;
  sed -i "/^public_network\ =/cpublic_network\ =\ $network" ceph.conf;
  sed -i "/^rados_network\ =/crados_network\ =\ $network" ceph.conf;
  sed -i "s/$ipeth0_prefix/$ipoib_prefix/g" ceph.conf;
  sed -i "/^mon_initial_members\ =/cmon_initial_members\ =\ $mons_initial_members" ceph.conf;

  ceph-deploy mon create-initial
  ceph-deploy mgr create $mon_1 $mon_2 $mon_3
  ceph-deploy admin $mon_1 $mon_2 $mon_3
  ceph-deploy admin `hostname`
}

# create hdd osds for a host
function create_hddosd() {
  nvmedisks=(
  "nvme0n1"
  "nvme1n1"
  "nvme2n1")

  host_ip=$1
  count=0
  round=7
  p=1

  host_name=`cat ./hosts | grep $host_ip | awk '{print $2}'`

  for hdd in {a..u}; do
    hdddisk=/dev/sd$hdd
    num=$((count/$round))
    wal=/dev/${nvmedisks[$num]}p$p
    db=/dev/${nvmedisks[$num]}p$(($p+1))
    echo $hdddisk"  "$wal"  "$db

    ceph-deploy --overwrite-conf osd create --data $hdddisk\1 --block-wal $wal --block-db $db --bluestore $host_name

    count=$(($count+1))
    p=$(($p+2))
    if [ $p -gt 14 ]; then
      p=1
    fi
  done
}

function create_hddosds() {
  for node in ${ceph_hdds[@]}; do
    create_hddosd $node;
  done
}

# create ssd osds for a host
function create_ssdosd() {
  host_ip=$1

  host_name=`cat ./hosts | grep $host_ip | awk '{print $2}'`

  for ssd in {c..z}; do
    ssddisk=/dev/sd$hdd
    echo "ceph osd create $host: $ssddisk"
    ceph-deploy --overwrite-conf osd create --data $ssddisk\1 --bluestore $host_name
  done
}

function create_ssdosds() {
  for node in ${ceph_ssds[@]}; do
    create_ssdosd $node;
  done
}

function create_rules() {
  echo "============== create ceph pool rules ==============="
  ssh root@${ceph_mons[0]} "cd /root/sense-ceph/create_pools/ && sh create_poolrules.sh"
}

function create_pool() {
  echo "============== create ceph rgws ==============="
  ssh root@${ceph_mons[0]} "cd /root/sense-ceph/create_pools/ && sh create_pool.sh"
}

function create_rgws() {
  for node in ${ceph_rgws[@]}; do
    host_name=`cat ./hosts | grep $node | awk '{print $2}'`
    ceph-deploy rgw create $host_name
  done
}

rpm -Uvh ceph-deploy-2.0.0-0.noarch.rpm

# rados

generate_hosts
install_ceph
change_firewall
create_mon
create_hddosds
create_ssdosds

create_rules

# rgw

create_pool
create_rgws

