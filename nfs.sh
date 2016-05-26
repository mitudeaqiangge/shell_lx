#!/bin/bash
source ./config
source scripts/auto_functions
export PATH=$third_part/bin:$PATH
/etc/init.d/rpcbind start
/etc/init.d/nfs start
cat nfs_share_d |while read share_d ;do  check_dir $share_d ;done
cat nfs_share_d |while read share_d ;do echo $share_d ;done
touch /etc/exports
cat nfs_share_d |while read share_d;do echo "$share_d  *(rw,sync,no_root_squash)" >>/etc/exports ; done
/etc/init.d/rpcbind restart
/etc/init.d/nfs restart
chkconfig rpcbind on
chkconfig nfs on
num1=`showmount -e |wc -l`
num=`expr $num1 - 1`
num2=`cat nfs_share_d |wc -l`
#echo $num1 $num $num2
if [ $num == $num2 ] ;then
	echo 'share successful'
else
	echo "share failure"
fi
#######################################
for dir in `cat nfs_share_d` ;do
	pdsh -R ssh -w `cat $auto_tmp/vnodes` mkdir -p $dir
	pdsh -R ssh -w `cat $auto_tmp/vnodes`  mount -t nfs 192.168.1.10:$dir $dir
	pdsh -R ssh -w `cat $auto_tmp/vnodes` "echo 'mount -t nfs 192.168.1.10:$dir $dir' >> /etc/rc.local"
done
#pdsh -R ssh -w `cat $auto_tmp/vnodes  df |tail -$num`
for i in `cat nodelist` ;do ssh $i "hostname ; df |tail -$num";done
