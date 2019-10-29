yum install epel-release cryptsetup lttng-ust lz4 tcmalloc python-requests babeltrace-ctf babeltrace python-prettytable junit python-cherrypy pyOpenSSL python-jinja2 python-pecan python-notario python-werkzeug python-flask gdisk mailcap resource-agents jq socat xmlstarlet gperftools-libs python34 python-setuptools xmlstarlet python-pecan fuse libibverbs.x86_64 libbabeltrace.x86_64 lttng-ust.x86_64 leveldb.x86_64 ntp fuse fuse-devel fuse-libs -y -q

if [ -d tack_pkgs ];then
    cd tack_pkgs
    rpm -Uvh *.rpm --force --quiet
    cd ..
fi

if [ -d rpms ];then
    cd rpms 
    rpm -Uvh *.rpm --force --quiet
    cd ..
else
echo "no such directory"
fi
