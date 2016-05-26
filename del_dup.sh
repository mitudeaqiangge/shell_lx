#!/bin/bash
source ./config
export PATH=$third_part/bin:$PATH

cat > $auto_tmp/local_files  << EOF
/etc/sysconfig/network
/etc/rc.local
/etc/ntp.conf
/etc/sysconfig/clock
/etc/sysconfig/ntpd
/etc/ssh/ssh_config
/etc/ssh/sshd_config
/etc/ssh/ssh_hosts
/etc/ssh/shosts.equiv
EOF
cat > $auto_tmp/remote_files  << EOF
/etc/sysconfig/network
/etc/rc.local
/etc/nsswitch.conf
/etc/yp.conf
/etc/ntp.conf
/etc/ntp/step-tickers
/etc/sysconfig/clock
/etc/sysconfig/ntpd
/etc/ssh/ssh_config
/etc/ssh/sshd_config
/etc/ssh/shosts.equiv
EOF
#cat $auto_tmp/local_files | while read vfile ; do sed -ri ':1;N;s/^(\S+)((\n.*)*)\n\1$/\1\2/M;$!b1' $vfile ; done
cat $auto_tmp/local_files | while read vfile ; do awk '! a[$0]++' $vfile > $vfile.auto ; done
cat $auto_tmp/local_files | while read vfile ; do mv $vfile.auto $vfile ; done
cat ./nodelist | while read vnode ; do scp $auto_tmp/remote_files $vnode:/tmp/remote_files ; done
pdsh -R ssh -w `cat $auto_tmp/vnodes` "cat /tmp/remote_files | while read vfile ; do awk '! a[\$0]++'  \$vfile > \$vfile.auto ; done"
pdsh -R ssh -w `cat $auto_tmp/vnodes` "cat /tmp/remote_files | while read vfile ; do mv \$vfile.auto \$vfile ; done"

#rm -rf $auto_tmp
