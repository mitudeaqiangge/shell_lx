#!/bin/bash
for i in `seq 1 3`
do
#   pw=`echo $[$RANDOM]|md5sum|cut -c 1-5`
  pw="redhat"
  sudo useradd -d /home/user$i  user$i
#  sudo echo "user$i $pw" >> /root/pw.txt
#  sudo echo "$pw" |passwd --stdin user$i
  passwd user$i < pwdoc
done
