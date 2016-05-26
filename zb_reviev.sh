#!/bin/bash
#Filename:zb_review
#Usage:./zb_review
#作用：查看周报运维管理建议模块信息，并统计列出。
#使用：在导出周报邮件目录下执行，导出邮件后缀格式为.txt
display(){
cat <<END
    *--------------------------------------------------*
    *    ***请根据查看内容输入相关数字***              *
    *                                                  *
    *    1  查看存在僵尸进程集群                       *
    *    2  查看存在超长时间进程集群                   *
    *    3  查看即存在僵尸进程又存在超长时间进程集群   *
    *    4  查看存在磁盘警告信息集群                   *
    *    5  退出（exit） "                             *
    *--------------------------------------------------*
END
}
display
for i in $(find ./ -name  "*[PPSN*]*" | awk -F '[][]' '{print $2}') ;
do
    find ./ -name "*$i*" -exec mv "{}" $i.txt \;
done
Cluster_num=$(ls *txt |wc -l)
while true
do
echo -e '\033[0;32;1m please input number(1/2/3/4/5):\033[0m'
read num
case "$num" in
1) i=0
for file in  `ls *.txt`
do
    grep -E '建议及时处理僵尸进程，以免|建议及时处理僵尸进程和超长时间进程'  $file  >/dev/null
    if [ $? -eq 0 ]
        then
            sed -n '1p' $file |awk '{print $2 $3 $4 $5 $6}'  && echo -e '\033[0;34;1m该集群存在僵尸进程\033[0m'
	    let i=i+1
    fi
done
num_1=$(awk -v va=$i -v vb=$Cluster_num 'BEGIN{printf "%2.2f%%",va*100/vb}')
echo "存在僵尸进程的集群总数为："$i
echo "集群总数为：$Cluster_num    只存在僵尸进程集群占：$num_1 "
;;
2) i=0
for file in  `ls *.txt`
do
    grep -E '建议及时处理超长时间进程|建议及时处理僵尸进程和超长时间进程' $file >/dev/null
    if [ $? -eq 0 ]
        then
            sed -n '1p' $file |awk '{print $2 $3 $4 $5 $6}' && echo -e  '\033[0;34;1m该集群存在超长时间进程\033[0m'
	    let i=i+1
    fi
done
num_1=$(awk -v va=$i -v vb=$Cluster_num 'BEGIN{printf "%2.2f%%",va*100/vb}')
echo "存在超长时间进程的集群总数为："$i
echo "集群总数为： $Cluster_num       只存在超长时间进程集群占： $num_1"
;;
3) i=0
for file in  `ls *.txt`
do
    cat $file |grep  建议及时处理僵尸进程和超长时间进程 >/dev/null
    if [ $? -eq 0 ]
        then
            sed -n '1p' $file |awk '{print $2 $3 $4 $5 $6}'  && echo -e '\033[0;34;1m该集群存在超长时间进程和僵尸进程\033[0m'
            let  i=i+1
    fi
done
num_1=$(awk -v va=$i -v vb=$Cluster_num 'BEGIN{printf "%2.2f%%",va*100/vb}')
echo  "即存在超长时间进程又存在僵尸进程的集群总数为："$i
echo "集群总数为： $Cluster_num    僵尸进程和超长时间进程并存集群占： $num_1"
;;
4) i=0
for file in  `ls *.txt`
do
#    cat $file |grep  建议及时处理僵尸进程和超长时间进程 >/dev/null
    grep -E '使用率超过|有大量公用存储剩余空间不足'  $file >/dev/null
    if [ $? -eq 0 ]
        then
            sed -n '1p' $file |awk '{print $2 $3 $4 $5 $6}'  && echo  -e  '\033[0;33;1m集群存在磁盘警告信息，清查看\033[0m'
            let  i=i+1
    fi
done
num_1=$(awk -v va=$i -v vb=$Cluster_num 'BEGIN{printf "%2.2f%%",va*100/vb}')
echo  "部分磁盘使用率过高或公用磁盘剩余不足集群数为："$i
echo "集群总数为： $Cluster_num    存在磁盘警告信息集群占： $num_1"
;;

5) break ;;
* ) echo -e  '\033[0;31;1mInput Error!\033[0m'	 ;;
esac
done

