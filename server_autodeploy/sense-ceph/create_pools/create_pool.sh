#!/usr/bin/bash
#exit 0
power2() {
  if [ $1 -lt 1 ]; then echo 2; return; fi
  echo "x=l($1)/l(2); scale=0; 2^((x+0.5)/1)" | bc -l
}

function pgcalc(){
  num_pgs=$1
  pct=$2
  target_num=$(echo "($num_pgs*$pct)/1" | bc)
  power2 $target_num
}

function pool_enable(){
  app="petreloss"
  for p in `ceph osd pool ls | grep -e $prefix -e root`
  do
    ceph osd pool application enable $p $app
  done
}

function zone_init(){
radosgw-admin realm create --rgw-realm=petrel --default
radosgw-admin zonegroup create --rgw-zonegroup=petreloss --rgw-realm=petrel  --master --default
radosgw-admin zone create --rgw-zone=default --rgw-zonegroup=petreloss  --master --default 
radosgw-admin zone set --rgw-zone=default  --master --default --infile zone.json
radosgw-admin period update --commit
}

function rgw_pool(){
num_pgs=$(power2 $1)
echo "total num of rgw pgs :"$num_pgs
other_num=$(pgcalc $num_pgs 0.05)
data_num=$(pgcalc $num_pgs 0.85)
index_num=$(pgcalc $num_pgs 0.1)

echo $data_num $index_num $other_num

prefix="petreloss"
#ruleset="replicated_rule"
ruleset="ssdpoolrule"
ceph osd pool create $prefix.index $index_num $index_num    replicated $ruleset
ceph osd pool create $prefix.data $data_num $data_num  replicated $ruleset
ceph osd pool create .rgw.root $other_num $other_num replicated $ruleset
ceph osd pool create $prefix.control $other_num $other_num replicated $ruleset
ceph osd pool create $prefix.meta $other_num $other_num replicated $ruleset
ceph osd pool create $prefix.log $other_num $other_num replicated $ruleset
ceph osd pool create $prefix.non-ec $other_num $other_num replicated $ruleset
pool_enable
sleep 1m
zone_init
}

function lustre_pool(){
name=$1
rule=$2
num_pgs=$(power2 $3)
echo "creating lustre pool $name $rule $num_pgs"
ceph osd pool create $name  $num_pgs $num_pgs replicated $rule
ceph osd pool set $name size 3
}

function agent_pool(){
name=$1
rule=$2
num_pgs=$(power2 $3)
echo "creating agent pool $name $rule $num_pgs"
ceph osd pool create $name $num_pgs $num_pgs replicated $rule
}

function vm_pool(){
rule=$1
num_pgs=$(power2 $2)
echo "creating vm pool  $rule $num_pgs"
pools="
images
vms
volumes
backups
"

for p in $pools
do
  ceph osd pool create  $p $num_pgs $num_pgs replicated $rule
  ceph osd pool set $p size 3
done

}

pg_per_osd=120
NUM_SSD_OSD=$(ceph osd tree | grep ssd 2> /dev/null | wc -l)
NUM_HDD_OSD=$(ceph osd tree | grep hdd 2> /dev/null | wc -l)
echo "ssd osd : "$NUM_SSD_OSD
echo "hdd osd : "$NUM_HDD_OSD
SSD_SIZE=2
HDD_SIZE=3
total_ssd_pg=$(($NUM_SSD_OSD*$pg_per_osd/$SSD_SIZE))
total_hdd_pg=$(($NUM_HDD_OSD*$pg_per_osd/$HDD_SIZE))
total_ssd_pg=$(power2 $total_ssd_pg)
total_hdd_pg=$(power2 $total_hdd_pg)
echo "total ssd pgs of cluster : "$total_ssd_pg"  "
echo "total hdd pgs of cluster : "$total_hdd_pg"  "

rgw_total=$(echo "($total_ssd_pg*0.6)/1" | bc)
echo "total num of rgw pgs :"$rgw_total

lustre_hdd__total=$(echo "($total_hdd_pg*1)/1" | bc)
lustre_ssd__total=$(echo "($total_ssd_pg*0.1)/1" | bc)
echo "total num of lustre ssd pg :"$lustre_ssd__total
echo "total num of lustre hdd pg :"$lustre_hdd__total
agent_ssd_total=$(echo "($total_ssd_pg*0.3)/1" | bc)
echo "total num of agent ssd :"$agent_ssd_total
vm_pgs=$(echo "($total_hdd_pg*0.1)/1" | bc)
echo "total num of vm pgs  :"$vm_pgs

rgw_pool $rgw_total
mdt="lustre_ssdpool_mdt.data"
ost="lustre_hddpool_ost.data"
lustre_pool $mdt "ssdpoolrule" $lustre_ssd__total
lustre_pool $ost "hddpoolrule" $lustre_hdd__total
#agent="SenseAgentPool"
#agent_pool $agent "ssdpoolrule"  $agent_ssd_total
#vm_pool "hddpoolrule"  $vm_pgs
