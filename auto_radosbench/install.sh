
apt-get install python-dbg python3-dbg resource-agents python-flask python-openssl python-requests  python-itsdangerous libpython-dbg python-cryptography python-urllib3 python-chardet libpython3-dbg python3.5-dbg libnet1 libplumb2 cluster-glue liblrm2 libopenhpi2 libopenipmi0 libpils2 libplumbgpl2 libsnmp30 libstonith1 libpils2 libpython2.7-dbg libpython3.5-dbg python-cffi-backend-api-9729 python-enum34 python-idna python-ipaddress python-pyasn1 libpython3.5-dbg python2.7-dbg gdb libsnmp-base

if [ -d tack_pkgs ];then
    cd tack_pkgs
    dpkg -i *.deb
    cd ..
fi

if [ -d deb_ceph ];then
    cd deb_ceph
    dpkg -i *.deb
    cd ..
else
echo "no such directory"
fi
