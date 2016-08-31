#!/bin/bash
#This script is used to add system users
user_add()
{
while true
do
	read -p "Please enter a new user name:" user
	if id -u $user >/dev/null 2>&1; then
		echo "User name already exists. Please re-enter."
		continue
	else
		useradd  -d /home/$user $user && echo "New user $user add success"
		break
	fi
done
}
check_group()
{
while true
do
	read -p "Please enter a user group:" group
	if groups $group >/dev/null 2>&1;then
		gpasswd -a $user $group
                if [ $? == 0 ];then
                        echo "$user join group $group Success" && break
                fi
	else
		echo "Input group does not exist, the new group $group"
		groupadd $group
		gpasswd -a $user $group
		if [ $? == 0 ];then
			echo "$user join group $group Success" && break
		fi
	fi
echo end
done
}
pw()
{
	read -p "Please enter a user passwd:" pwd
	echo $pwd | passwd --stdin $user 



}
echo 'This script is used to add system users. '
echo '.................start.......................'
while true; do
    read -p "Do you wish to continue ... yes|no [yes]" yn
    case $yn in
        y|Y|YES )user_add;check_group;pw ;;
        n|N|NO ) exit ;;
        '' ) break ;;
        * ) echo "Please answer y or n." ;;
    esac
done
