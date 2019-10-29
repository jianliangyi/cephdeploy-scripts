
remove_pkgs="
ceph-mgr-petrel.1.1.4-0.el7.centos.x86_64
cephfs-java-petrel.1.1.4-0.el7.centos.x86_64
ceph-test-petrel.1.1.4-0.el7.centos.x86_64
libcephfs2-petrel.1.1.4-0.el7.centos.x86_64
ceph-base-petrel.1.1.4-0.el7.centos.x86_64
ceph-mds-petrel.1.1.4-0.el7.centos.x86_64
ceph-mon-petrel.1.1.4-0.el7.centos.x86_64
libcephfs_jni1-petrel.1.1.4-0.el7.centos.x86_64
ceph-petrel.1.1.4-0.el7.centos.x86_64
ceph-resource-agents-petrel.1.1.4-0.el7.centos.x86_64
ceph-tokenbucketserv-petrel.1.1.4-0.el7.centos.x86_64
python-cephfs-petrel.1.1.4-0.el7.centos.x86_64
ceph-common-petrel.1.1.4-0.el7.centos.x86_64
ceph-selinux-petrel.1.1.4-0.el7.centos.x86_64
ceph-osd-petrel.1.1.4-0.el7.centos.x86_64
ceph-radosgw-petrel.1.1.4-0.el7.centos.x86_64
python-ceph-compat-petrel.1.1.4-0.el7.centos.x86_64
ceph-fuse-petrel.1.1.4-0.el7.centos.x86_64
rbd-nbd-petrel.1.1.4-0.el7.centos.x86_64
python-rbd-petrel.1.1.4-0.el7.centos.x86_64
rbd-mirror-petrel.1.1.4-0.el7.centos.x86_64
rbd-fuse-petrel.1.1.4-0.el7.centos.x86_64
librbd1-petrel.1.1.4-0.el7.centos.x86_64
python-rgw-petrel.1.1.4-0.el7.centos.x86_64
librgw2-petrel.1.1.4-0.el7.centos.x86_64
python-rados-petrel.1.1.4-0.el7.centos.x86_64
ceph-radosgw-petrel.1.1.4-0.el7.centos.x86_64
librados2-petrel.1.1.4-0.el7.centos.x86_64
libradosstriper1-petrel.1.1.4-0.el7.centos.x86_64
ceph-radosgw-petrel.1.1.4-0.el7.centos.x86_64
"

yum remove $remove_pkgs -y -q

