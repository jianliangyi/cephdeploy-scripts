#!/bin/bash

ceph osd crush rule create-replicated hddpoolrule default host hdd
ceph osd crush rule create-replicated ssdpoolrule default host ssd
