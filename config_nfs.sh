#!/bin/bash
source ./config
source scripts/auto_functions
export PATH=$third_part/bin:$PATH
cat ./nodelist | while read vnode ; do scp scripts/auto_functions $vnode:/tmp/auto_functions ; done

SERVER=`cat $auto_tmp/nfs | grep -v '^#' | grep NFSCFG | awk '{print $2}'`
echo $SERVER
SERVER_PATH=`cat $auto_tmp/nfs | grep -v '^#' | grep NFSCFG | awk '{print $3}'`
echo $SERVER_PATH
SERVER_OPT=`cat $auto_tmp/nfs | grep -v '^#' | grep NFSCFG | awk '{print $4}'`
echo $SERVER_OPT
MOUNT_PATH=`cat $auto_tmp/nfs | grep -v '^#' | grep NFSCFG | awk '{print $5}'`
echo $MOUNT_PATH
MOUNT_OPT=`cat $auto_tmp/nfs | grep -v '^#' | grep NFSCFG | awk -F "'" '{print $2}'`
echo $MOUNT_OPT
#check server
nc -w 1 $SERVER 22 && echo $SERVER is OK ...
#check dir
check_dir $SERVER_PATH
pdsh -R ssh -w `cat $auto_tmp/vnodes` "source /tmp/auto_functions ; check_dir $MOUNT_PATH"
#set server
echo "$SERVER_PATH $SERVER_OPT" >> /etc/exports
awk '! a[$0]++' /etc/exports > $auto_tmp/exports
cat $auto_tmp/exports > /etc/exports
/etc/init.d/rpcbind restart
/etc/init.d/nfslock restart
/etc/init.d/nfs restart
#set client
pdsh -R ssh -w `cat $auto_tmp/vnodes` "echo 'mount -t nfs $MOUNT_OPT $SERVER:$SERVER_PATH $MOUNT_PATH' >> /etc/rc.local"
pdsh -R ssh -w `cat $auto_tmp/vnodes` "mount -t nfs $MOUNT_OPT $SERVER:$SERVER_PATH $MOUNT_PATH"

BINDHOME=`cat ./nfs.cfg | grep -v '^#' | grep BINDHOME | awk '{print $2}'`
check_dir $BINDHOME
echo "mount --bind $BINDHOME /home" >> /etc/rc.local
mount --bind $BINDHOME /home
pdsh -R ssh -w `cat $auto_tmp/vnodes` "echo 'mount --bind $BINDHOME /home' >> /etc/rc.local"
pdsh -R ssh -w `cat $auto_tmp/vnodes` "mount --bind $BINDHOME /home"


echo "Done."
