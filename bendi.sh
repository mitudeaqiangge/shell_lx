#!/bin/bash
check_dir()
{
   if [ ! -d $1 ]; then
      echo "没有那个目录，开始创建目录"
      mkdir -p $1 >& /dev/null 
   fi
}
bendiback()
{
echo -n  "请输入备份文件/目录地址："
read  b_source
#echo $b_source
if [ -d "$b_source" ];then
  source_d=`echo "$b_source" |awk -F '/' '{print $NF}'`
  echo "备份源为目录：$source_d"
  back_name=bak-`date +%Y%m%d-%H%M%S`$source_d.tar.gz
  echo "开始压缩打包:$back_name 请稍等... .... "
  tar -zcf   $back_name  $b_source  >& /dev/null
  echo "打包完成，To start backup..."
  echo -n  "输入存放备份文件地址："
  read  b_destination
  check_dir $b_destination
  cp $back_name  $b_destination
  if [ $? == 0 ];then
     rm -rf $back_name
     echo "The backup successful"
  else
     echo "backup erro ...."
  fi
##############
else
#   echo "################## "$b_source
   test -e $b_source
   if [ $? == 0 ];then
     source_d=`echo "$b_source" |awk -F '/' '{print $NF}'`
     echo "备份源为文件：$source_d"
     read -p "输入存放备份文件地址：" b_destination
     check_dir $b_destination
     echo "To start backup...."
     cp $b_source  $b_destination
     if [ $? == 0 ];then
       echo "The backup successful"
     fi
   else
      echo "没有那个文件或目录"
    fi
fi
}
while true; do
	read -p "开始备份...yes|no  [yes]" yn
	case $yn in
		y|Y|yes|YES)bendiback ;;
		n|N|no)exit;;
		*)echo "Please answer y or n"
	esac
done


