
#!/bin/bash
source ./config
source scripts/auto_functions
export PATH=$third_part/bin:$PATH

check_dir $auto_tmp
rm -rf $auto_tmp/*
check_dir logs
#cat ./nodelist | while read vnode ; do grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' ; done
cp ./nodelist $auto_tmp/all_nodes
ipreg='\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b'
echo `hostname` >> $auto_tmp/all_nodes
cat $auto_tmp/all_nodes | while read vnode ; do grep $vnode /etc/hosts | awk '{print $1}' >> $auto_tmp/all_ips ; done
sed -ri ':1;N;s/^(\S+)((\n.*)*)\n\1$/\1\2/M;$!b1' $auto_tmp/all_ips
rnips=`cat $auto_tmp/all_nodes | wc -l`
nips=`egrep $ipreg $auto_tmp/all_ips | wc -l`
if [ $rnips != $nips ] ; then
	echo "Please check nodelist and /etc/hosts, then make them correct !"
	exit 1
fi
cat ./nodelist | xargs | sed 's/ /,/g' > $auto_tmp/vnodes

echo 'Checking nodes ...'
for i in `cat nodelist`; do nc -w 1 $i 22 && echo $i is OK ... || echo $i >> $auto_tmp/failed_nodes ; done
if [ -f $auto_tmp/failed_nodes ] ; then
        echo 'Warning : The cluster has unreachable nodes :';
        cat $auto_tmp/failed_nodes
while true; do
    read -p "Do you wish to continue ... yes|no [yes]" yn
    case $yn in
        y|Y|YES ) break ;;
        n|N|NO ) exit ;;
        '' ) break ;;
        * ) echo "Please answer yes or no." ;;
    esac
done
fi

echo "Done."
