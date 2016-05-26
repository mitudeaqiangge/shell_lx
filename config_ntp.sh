#!/bin/bash
source ./config
export PATH=$third_part/bin:$PATH

echo "Begin to config ntp ..."
admin=`hostname`
ippool=`grep $admin /etc/hosts | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`

echo "Set local time zone as $time_zone"
cp /etc/sysconfig/clock /etc/sysconfig/clock.$backup_name
cp /etc/localtime /etc/localtime.$backup_name
cp /etc/ntp.conf /etc/ntp.conf.$backup_name
cp /etc/ntp/step-tickers /etc/ntp/step-tickers.$backup_name
cp /etc/sysconfig/ntpd /etc/sysconfig/ntpd.$backup_name
echo ZONE=\"$time_zone\" > /etc/sysconfig/clock
ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime
sed -i "/#restrict/arestrict $ippool.0 mask 255.255.255.0 nomodify notrap" /etc/ntp.conf
#sed -i "/#server\t127.127.1.0/aserver\t127.127.1.0\t# local clock" /etc/ntp.conf
#sed -i "/#fudge\t127.127.1.0/afudge\t127.127.1.0\tstratum 10" /etc/ntp.conf
echo "server 127.127.1.0 # local clock" >>/etc/ntp.conf
echo "fudge 127.127.1.0 stratum 10"  >>/etc/ntp.conf
echo "SYNC_HWCLOCK=yes" >> /etc/sysconfig/ntpd
chkconfig ntpdate off
/etc/init.d/ntpdate stop
chkconfig ntpd on
/etc/init.d/ntpd restart

pdsh -R ssh -w `cat $auto_tmp/vnodes` echo "ZONE=\"$time_zone\" > /etc/sysconfig/clock"
pdsh -R ssh -w `cat $auto_tmp/vnodes` "ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime"
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i "/www.pool.ntp.org/aserver\ $admin\ prefer" /etc/ntp.conf
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i "/server\ 0./d" /etc/ntp.conf
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i "/server\ 1./d" /etc/ntp.conf
pdsh -R ssh -w `cat $auto_tmp/vnodes` sed -i "/server\ 2./d" /etc/ntp.conf
pdsh -R ssh -w `cat $auto_tmp/vnodes` "echo $admin >> /etc/ntp/step-tickers"
pdsh -R ssh -w `cat $auto_tmp/vnodes` "echo "SYNC_HWCLOCK=yes" >> /etc/sysconfig/ntpd"
pdsh -R ssh -w `cat $auto_tmp/vnodes` chkconfig ntpdate off
pdsh -R ssh -w `cat $auto_tmp/vnodes` /etc/init.d/ntpdate stop
pdsh -R ssh -w `cat $auto_tmp/vnodes` chkconfig ntpd on
pdsh -R ssh -w `cat $auto_tmp/vnodes` /etc/init.d/ntpd restart

echo "Done."
