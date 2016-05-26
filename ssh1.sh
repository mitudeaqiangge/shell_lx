#!/bin/bash
source ./config
export PATH=$third_part/bin:$PATH

echo "Begin to config ssh non-password ...";sleep 1
export PATH=$third_part/bin:$PATH
if [ -d /root/.ssh ] ; then
mv /root/.ssh /root/.ssh.$backup_name
fi
ssh-keygen -t rsa 
#cd ~/.ssh
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
#cp /etc/ssh/ssh_config /etc/ssh/ssh_config.$backup_name
#echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
cat nodelist | while read vnode ; do sshpass -p $root_passwd scp -r /root/.ssh $vnode: ; done
cat nodelist | while read vnode ; do    scp /etc/hosts $vnode:/etc ; done
cat nodelist | while read vnode ; do  scp /etc/ssh/ssh_config $vnode:/etc/ssh ; done

