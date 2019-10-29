#!/bin/bash

disk_labels="
sda
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
"

nvme_disks="
nvme0n1
nvme1n1
nvme2n1
"

for HDD in $disk_labels; do
  parted -s -a optimal /dev/$HDD mklabel gpt Yes
  parted -s -a optimal /dev/$HDD mkpart $HDD\1 0% 100% 
done

for nvme in $nvme_disks; do
  disk="/dev/"$nvme
  parted $disk mklabel gpt Yes

  n=7
  part=$((100/$n))
  for ((i=0; i < $n; i++)); do
    wal_s=$(($i*$part))
    wal_e=$(($wal_s+1))"%"
    wal_s=$wal_s"%"
    e=$(($(($i+1))*$part))"%"

    if [ $i -eq $(($n-1)) ]; then
        e="100%"
    fi
    echo $wal_s"  "$wal_e"  "$e
    parted -a optimal $disk  mkpart primary $wal_s $wal_e
    parted -a optimal $disk  mkpart primary $wal_e $e
  done
done

