
ifconfig lo:0 down
ifconfig lo:0 vip0 broadcast vip0 netmask 255.255.255.255 up
route add -host vip0 lo:0

ifconfig lo:1 down
ifconfig lo:1 vip1 broadcast vip1 netmask 255.255.255.255 up
route add -host vip1 lo:1

echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce



