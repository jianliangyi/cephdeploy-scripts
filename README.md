# cephdeploy-scripts
A tool program used to deploy a ceph cluster dynamically


Ceph部署文档

目录

前期准备	
1、 配置ssh免密登录
2、 Clone部署脚本	
3、 服务器规划

Server部署	
3、 编辑ceph_hosts.sh文件	
4、 硬盘分区初始化	
5、 部署	
6、 清理集群	

Keepalive+lvs dr部署	
1、 ceph_hosts.sh文件加以下内容	
2、 部署	

客户端部署	
1、编辑ceph_hosts.sh文件	
2、部署	

前期准备
1、配置ssh免密登录
确保ceph-deploy节点可免密登录所有ceph相关节点

2、Clone部署脚本
$ git clone https://github.com/jianliangyi/cephdeploy-scripts.git
目录结构

$ cd cephdeploy-scripts/server_autodeploy


3、服务器规划

设备名	数量	ip地址	ib地址			硬盘规划
OSDs(RGWs)设备	1	10.198.8.200		IP: 10.198.108.200	硬盘2：6TB HDD*21 硬盘3：1.6T NVME SSD*3
MONs(MGRs)设备	3	10.198.8.212-214	10.198.108.212-214	硬盘2：480G SATA3.0 SSD*1
Keepalive+lvs	2	10.198.8.215-216	10.198.108.215-216	硬盘2： 480G SATA3.0 SSD*1
Lvs virtual ip	2	10.198.8.234		10.198.108.234	

Server部署
1、编辑ceph_hosts.sh文件
$ vim ceph_hosts.sh

注意ceph_nodes项记录所有需要安装ceph rpm包的节点

2、硬盘分区初始化
$ sh auto_partition.sh
这步仅需要执行一次，后续运行auto_clear.sh后重新部署不需要重复。

3、部署
$ vim auto_ceph_deploy.sh
文档尾部有这几个配置项，可根据需要注释掉，即可不执行相应步骤

rpm -Uvh ceph-deploy-2.0.0-0.noarch.rpm

# rados

generate_hosts     # 生产hosts文件

install_ceph        # 安装ceph 软件，初始化配置项

change_firewall     # 关闭防火墙

create_mon        # 创建monitor服务

create_hddosds     # 创建hdd+nvme 类型osd服务

create_ssdosds      # 创建ssd 类型osd服务

create_rules        # 创建ssdpoolrule和hddpoolrule规则

# rgw

create_pool        # 创建rbd pool 和 rgw pool，配置rgw

create_rgws        # 创建rgw


运行一下脚本开启部署
$ sh auto_ceph_deploy.sh

4、清理集群
$ sh auto_clear.sh
卸载rpm相关环境，rpm包、生成的keyring。
注意该脚本并不会清理磁盘分区

keepalive+lvs dr部署
1、ceph_hosts.sh文件加以下内容

load_balance为负载均衡节点，lvs_vip为虚拟ip地址。
$ vim ceph_hosts.sh
load_balance=(
10.198.8.215
10.198.8.216
)

lvs_vip=(
10.198.8.234
10.198.108.234
)

2、部署
$ sh auto_keepalive_deploy.sh

客户端部署
安装awscli、s3cmd工具，安装python api

$ cd cephdeploy-scripts/client_autodeploy

1、编辑ceph_hosts.sh文件
$ vim client_hosts.sh

2、部署
$ sh client_hosts.sh

Cosbench测试

可参考测试文档《对象存储cosbench测试文档》

