
#!/usr/bin/bash

source ./ceph_hosts.sh

function configure_lvs_rs() {
  for node in ${ceph_rgws[@]}; do
    ssh root@$node "cd /root/sense-ceph/keepalive/ && sh lvs_dr_rs.sh";
  done
}

function configure_keepalive() {
  # keep the keepalive configuration file clean
  echo > keepalived.conf.master;
  echo > keepalived.conf.slave;
  cp keepalived.conf.head keepalived.conf.master;

  ssh ${load_balance[0]} "yum install keepalived -y"
  ssh ${load_balance[1]} "yum install keepalived -y"

  sed -i "s/vip0/${lvs_vip[0]}/g" keepalived.conf.master;
  sed -i "s/vip1/${lvs_vip[1]}/g" keepalived.conf.master;

  # configure ethernet network cfg part
  sed "s/vip/${lvs_vip[0]}/g" keepalived.conf.vip-head >> keepalived.conf.master;

  for node in ${ceph_rgws[@]}; do
    sed "s/rs_ip/$node/g" keepalived.conf.common >> keepalived.conf.master;
    #cat keepalived.conf.common >> keepalived.conf.master;
  done
  echo "}" >> keepalived.conf.master;

  # configure infiniband network cfg part
  sed "s/vip/${lvs_vip[1]}/g" keepalived.conf.vip-head >> keepalived.conf.master;

  for node in ${ceph_rgws[@]}; do
    ipoib=`ifconfig | sed -n '/ib/,+1p' | grep inet | awk '{print $2}'`
    ipoib_prefix=`echo ${ipoib%.*}`
    ib_rgw=$ipoib_prefix"."${node##*.}
    sed "s/rs_ip/$ib_rgw/g" keepalived.conf.common >> keepalived.conf.master;
    #cat keepalived.conf.common >> keepalived.conf.master;
  done
  echo "}" >> keepalived.conf.master;

  scp keepalived.conf.master root@${load_balance[0]}:/etc/keepalived/keepalived.conf;
  ssh root@${load_balance[0]} "systemctl start keepalived && systemctl status keepalived"

  cp keepalived.conf.master keepalived.conf.slave;

  sed -i "s/master_host/backup_host/g" keepalived.conf.slave;
  sed -i "s/MASTER/BACKUP/g" keepalived.conf.slave;
  sed -i "s/priority\ 100/priority\ 90/g" keepalived.conf.slave;

  scp keepalived.conf.slave root@${load_balance[0]}:/etc/keepalived/keepalived.conf;
  ssh root@${load_balance[1]} "systemctl start keepalived && systemctl status keepalived"
}


configure_lvs_rs
configure_keepalive


