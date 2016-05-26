#!/bin/bash
source ./config
export PATH=$third_part/bin:$PATH
nis_domain=`hostname`

echo "Begin to config nis ..."
nisdomainname $nis_domain
cp /etc/sysconfig/network /etc/sysconfig/network.$backup_name
if [ -z "`grep -i 'NISDOMAIN' /etc/sysconfig/network`" ] ; then
echo "NISDOMAIN="$nis_domain >> /etc/sysconfig/network
else echo 'NETWORKING=yes'  > /etc/sysconfig/network
echo 'HOSTNAME='`hostname` >> /etc/sysconfig/network
echo "NISDOMAIN="$nis_domain >> /etc/sysconfig/network
fi
echo '127.0.0.0/255.255.255.0 :* :* :none' >>/etc/ypserv.conf
echo '192.168.1.0/255.255.255.0 :* :* :none' >>/etc/ypserv.conf
echo '*:* :* : done' >>/etc/ypserv.conf
/etc/init.d/ypserv start
/etc/init.d/yppasswdd start
chkconfig --level 35 ypserv
chkconfig --level 35 yppasswdd
echo -e "" | /usr/lib64/yp/ypinit -m
/etc/init.d/ypserv restart
/etc/init.d/yppasswdd restart
echo "/etc/init.d/ypserv restart" >> /etc/rc.local

pdsh -R ssh -w `cat $auto_tmp/vnodes` nisdomainname $nis_domain ;
cat nodelist | while read vnode
do
cat > $auto_tmp/$vnode.network  << EOF
NETWORKING=yes
HOSTNAME=$vnode
NISDOMAIN=$nis_domain
EOF
scp $auto_tmp/$vnode.network $vnode:/etc/sysconfig/network
done
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i 's/passwd:\ \ \ \ \ files/passwd:\ \ \ \ \ files\ nis/g' /etc/nsswitch.conf
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i 's/shadow:\ \ \ \ \ files/shadow:\ \ \ \ \ files\ nis/g' /etc/nsswitch.conf
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i 's/group:\ \ \ \ \ \ files/group:\ \ \ \ \ \ files\ nis/g' /etc/nsswitch.conf
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i 's/hosts:\ \ \ \ \ \ files\ dns/hosts:\ \ \ \ \ \ files\ nis\ dns/g' /etc/nsswitch.conf
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i 's/nis\ nis/nis/g' /etc/nsswitch.conf
pdsh -R ssh -w `cat $auto_tmp/vnodes` "echo 'ypserver 192.168.1.10 >> /etc/yp.conf"
pdsh -R ssh -w `cat $auto_tmp/vnodes` "echo 'domain manager server 192.168.1.10' >> /etc/yp.conf"
pdsh -R ssh -w `cat $auto_tmp/vnodes` /etc/init.d/ypbind restart
pdsh -R ssh -w `cat $auto_tmp/vnodes` chkconfig --level 35 ypbind on
pdsh -R ssh -w `cat $auto_tmp/vnodes` "echo '/etc/init.d/ypbind restart' >> /etc/rc.local"

echo "Done."
