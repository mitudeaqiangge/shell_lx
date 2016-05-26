#!/bin/bash
source ./config
export PATH=$third_part/bin:$PATH

echo "Turn off iptables ip6tables sendmail service ...";sleep 1
/etc/init.d/NetworkManager  stop
chkconfig --level 35 NetworkManager off
pdsh -R ssh -w `cat $auto_tmp/vnodes` /etc/init.d/NetworkManager stop
pdsh -R ssh -w `cat $auto_tmp/vnodes` chkconfig NetworkManager off
/etc/init.d/sendmail stop
chkconfig --level 35 sendmail off
pdsh -R ssh -w `cat $auto_tmp/vnodes` /etc/init.d/sendmail stop
pdsh -R ssh -w `cat $auto_tmp/vnodes` chkconfig sendmail off
/etc/init.d/iptables stop
chkconfig --level 35 iptables off
pdsh -R ssh -w `cat $auto_tmp/vnodes` /etc/init.d/iptables stop
pdsh -R ssh -w `cat $auto_tmp/vnodes` chkconfig iptables off
/etc/init.d/ip6tables stop
chkconfig --level 35 ip6tables off
pdsh -R ssh -w `cat $auto_tmp/vnodes` /etc/init.d/ip6tables stop
pdsh -R ssh -w `cat $auto_tmp/vnodes` chkconfig ip6tables off
echo "Disable selinux ...";sleep 1
sed -i s/=enable/=disable/g /etc/selinux/config
sed -i s/=enforcing/=disable/g /etc/selinux/config
setenforce 0 > /dev/null 2>&1
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i s/=enable/=disable/g /etc/selinux/config
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i s/=enforcing/=disable/g /etc/selinux/config
pdsh -R ssh -w `cat $auto_tmp/vnodes` setenforce 0 > /dev/null 2>&1

echo "Done."
