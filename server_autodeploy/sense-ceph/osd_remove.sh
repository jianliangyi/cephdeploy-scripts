

for i in `sudo lvdisplay | grep -i "LV Path" | grep -i "ceph" | awk '{print $3}'`; 
do 
  sudo lvremove -f $i; 
done

for i in `sudo vgs | grep ceph | awk '{print $1}'`; 
do 
  sudo vgremove $i; 
done

for i in `sudo pvscan | grep PV | grep -v centos | awk '{print $2}'`; 
do 
  sudo pvremove $i; 
done

