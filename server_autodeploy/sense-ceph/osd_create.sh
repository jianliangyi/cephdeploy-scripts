#!/bin/bash

disk_labels="
sdb
sdc
sdd
sde
sdf
sdg
sdh
sdi
sdj
sdk
sdl
sdm
sdn
sdo
sdp
sdq
sdr
sds
sdt
sdu
sdv
"

nvme_disks="
nvme0n1
nvme1n1
nvme2n1
"

# create osds
nvmedisks=(
"nvme0n1"
"nvme1n1"
"nvme2n1")

host=$1
count=0
round=7
p=1
for hdd in $disk_labels; do
  hdd_disk=/dev/sd$hdd\1
  num=$((count/$round))
  wal=/dev/${nvmedisks[$num]}p$p
  db=/dev/${nvmedisks[$num]}p$(($p+1))
  echo $hdd_disk"  "$wal"  "$db

  ceph-deploy --overwrite-conf osd create --data $hdd_disk --block-wal $wal --block-db $db --bluestore $host

count=$(($count+1))
p=$(($p+2))
if [ $p -gt 14 ]; then
p=1
fi
done

