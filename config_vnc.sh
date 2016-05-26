#!/bin/bash
source ./config
export PATH=$third_part/bin:$PATH

echo "Begin to config nvc for `hostname` as root ..."
if [ -d /root/.vnc ] ; then
mv /root/.vnc /tmp/root.vnc.$backup_name
fi
cat > $auto_tmp/vncpasswd.expect << EOF
set vnc__passwdd $vnc_passwd
spawn vncpasswd
expect "Password:"
send "\$vnc__passwdd\r"
expect "Verify:"
send "\$vnc__passwdd\r"
expect eof
EOF
/usr/bin/expect -f $auto_tmp/vncpasswd.expect

vncserver
sed -i "s/twm/#twm/g" /root/.vnc/xstartup
echo "gnome-session &" >> /root/.vnc/xstartup
pkill -9 Xvnc
chkconfig vncserver on
cp /etc/sysconfig/vncservers /etc/sysconfig/vncservers.$backup_name
sed -i '/VNCSERVERS/d' /etc/sysconfig/vncservers
echo VNCSERVERS=\"1:root\" >> /etc/sysconfig/vncservers
sed -i '/VNCSERVERARGS/d' /etc/sysconfig/vncservers
echo VNCSERVERARGS[1]=\"-geometry $vnc_size\" >> /etc/sysconfig/vncservers
rm -rf /tmp/.X*
/etc/init.d/vncserver restart
echo 'Web port        : 5801'
echo 'Vnc Client port : 5901'

echo "Done."
