#!/bin/bash
source ./config
source scripts/auto_functions
export PATH=$third_part/bin:$PATH
main_path=`pwd`

echo "Begin to install pdsh to $third_part ..."
check_file src/pdsh-2.26.tar.bz2
tar xjf src/pdsh-2.26.tar.bz2 -C $auto_tmp
cd  $auto_tmp/pdsh-2.26
#./configure --prefix=$third_part --with-ssh >& $main_path/logs/install_pdsh.log &&  make >$main_path/logs/install_pdsh.log 2>&1  &&make install >$main_path/logs/install_pdsh.log
./configure  --with-ssh >& $main_path/logs/install_pdsh.log &&  make >$main_path/logs/install_pdsh.log 2>&1  &&make install >$main_path/logs/install_pdsh.log
#./configure  --with-ssh &&  make &&make install
if [ $? != 0 ];then
echo "Error: fail to install pdsh!!"
else
echo "Install pdsh successfully!!"
fi
cd -

echo "Begin to install sshpass to $third_part ..."
check_file src/sshpass-1.05.tar.gz
tar xzf src/sshpass-1.05.tar.gz -C $auto_tmp
cd  $auto_tmp/sshpass-1.05
#./configure --prefix=$third_part >& $main_path/logs/install_sshpass.log &&  make >>$main_path/logs/install_sshpass.log 2>&1  &&make install >>$main_path/logs/install_sshpass.log
./configure  >& $main_path/logs/install_sshpass.log &&  make >>$main_path/logs/install_sshpass.log 2>&1  &&make install >>$main_path/logs/install_sshpass.log
#./configure  && make &&make install
if [ $? != 0 ];then
echo "Error: fail to install sshpass!!"
else
echo "Install sshpass successfully!!"
fi
cd -

echo "Done."
