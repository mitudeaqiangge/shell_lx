read#!/bin/bash
source ./config
export PATH=$third_part/bin:$PATH

echo "Begin to config ssh non-password ...";sleep 1
export PATH=$third_part/bin:$PATH
if [ -d /root/.ssh ] ; then
mv /root/.ssh /root/.ssh.$backup_name
fi
ssh-keygen -t rsa -f /root/.ssh/id_rsa -P ''
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
cp /etc/ssh/ssh_config /etc/ssh/ssh_config.$backup_name
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
cat nodelist | while read vnode ; do sshpass -p $root_passwd scp -r /root/.ssh $vnode: ; done &&ssh-add
cat nodelist | while read vnode ; do sshpass -p $root_passwd   scp /etc/hosts $vnode:/etc ; done
cat nodelist | while read vnode ; do sshpass -p $root_passwd  scp /etc/ssh/ssh_config $vnode:/etc/ssh ; done

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$bakup_name
echo "HostbasedAuthentication yes" >> /etc/ssh/sshd_config
echo "HostbasedAuthentication yes" >> /etc/ssh/ssh_config
echo "EnableSSHKeysign yes" >> /etc/ssh/ssh_config
cat ./nodelist | while read vnode ; do grep $vnode /etc/hosts ; done | awk '{print $2,$1}' | sed 's/ /,/g' >> /etc/ssh/ssh_hosts
grep `hostname` /etc/hosts | awk '{print $2,$1}' | sed 's/ /,/g' >> /etc/ssh/ssh_hosts
ssh-keyscan -t rsa -f /etc/ssh/ssh_hosts > /etc/ssh/ssh_known_hosts2
cat nodelist >>  /etc/ssh/shosts.equiv
echo `hostname` >> /etc/ssh/shosts.equiv
pdsh -R ssh -w `cat $auto_tmp/vnodes` scp `hostname`:/etc/ssh/ssh_config /etc/ssh/
pdsh -R ssh -w `cat $auto_tmp/vnodes` scp `hostname`:/etc/ssh/sshd_config /etc/ssh/
pdsh -R ssh -w `cat $auto_tmp/vnodes` scp `hostname`:/etc/ssh/ssh_known_hosts2 /etc/ssh/
pdsh -R ssh -w `cat $auto_tmp/vnodes` scp `hostname`:/etc/ssh/shosts.equiv /etc/ssh/
/etc/init.d/sshd restart
pdsh -R ssh -w `cat $auto_tmp/vnodes` /etc/init.d/sshd restart
echo "Done."
