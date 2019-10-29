#!/bin/bash

disk_labels="
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
sdw
sdx
sdy
sdz
"

for SSD in $disk_labels; do
  parted -s -a optimal /dev/$SSD mklabel gpt Yes
  parted -s -a optimal /dev/$SSD mkpart $SSD\1 0% 100% 
done

