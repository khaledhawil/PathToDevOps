#!/usr/bin/bash
#this script helps to manage user / create /delete, add/remove user to specifi group
choice="c"
while [ $choice != "q" ]
do
echo
"=======================================================================
============================"
echo "Enter [1] create Use
Enter [2] Get Information About User"
echo "Enter [3] Delete and Delete its Data User
User"Enter [4] Delete And Keep its Data
echo "Enter [5] Lock User AccountEnter [6] Unlock User Account"
echo "Enter [7] Disable User AccountEnter [8] Create Group"
echo "Enter [9] Delete Group
echo "Enter [11] Remove User From Group
Enter [10] Add User To Group"
Enter [q] To Quite"
echo
"=======================================================================
============================"
echo "Enter The Number Of Operation"
read input
choice=$input
case "$input"
in
1)echo "you entered (1) create user"
echo "Please Enter Name of User"
read username
cat /etc/passwd | grep ${username} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
echo "User ALREADY Exists"
else
useradd $username
passwd $username
echo "User created sucessfully"
fi
;;
2)
echo "you entered (2) get information about user "
echo "please enter name of user"
read username
id $username
;;
3)
echo "you entered (3) delete user and its data "
read username
cat /etc/passwd | grep ${username} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
userdel -r $usernameecho user has been deleted
else
echo "User dosen't exist "
fi
;;
4)
echo "you entered (4) delete user and keep its data "
read username
cat /etc/passwd | grep ${username} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
userdel $username
echo user has been deleted
else
echo "User dosen't exist "
fi
;;
5)
echo "you entered (5)lock user account "
echo "please enter the username you want to lock "
read username
cat /etc/passwd | grep ${username} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
usermod -L $username
echo user has been lockedelse
echo "User dosen't exist "
fi
;;
6)
echo "you entered (6) unlock user account "
echo "please enter the username you want to unlock "
read username
cat /etc/passwd | grep ${username} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
usermod -U $username
echo user has been unlocked
else
echo "User dosen't exist "
fi
;;
7)
echo "you entered (7) disable user account "
read username
cat /etc/passwd | grep ${username} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
chage -E0 $username
echo "user has been disabled"else
echo "User dosen't exist "
fi
;;
8)
echo "you entered (8) create group"
echo "enter name of group you want to create"
read grpname
cat /etc/group | grep ${grpname} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
echo "group ALREADY exist"
else
groupadd $grpname
echo "group has been added"
fi
;;
9)
echo "you entered (9)delete group"
echo "please enter name of group you want to delete"
read grpname
cat /etc/group | grep ${grpname} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
groupdel $grpname
echo "group has been deletes"else
echo "group Does not exist "
fi
;;
10)
echo "you entered (10)add user to group "
echo "enter name of the group"
read grpname
cat /etc/group | grep ${grpname} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
echo "enter the username"
read username
cat /etc/passwd | grep ${username} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
usermod -G $grpname $username
echo $username has been added to ${grpname}
else
echo "user Does not exist "
fi
else
echo "group Does not exist "
fi;;
11)
echo "you entered (11) remove user from group"
echo "enter name of the group"
read grpname
cat /etc/group | grep ${grpname} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
echo "enter the username"
read username
cat /etc/passwd | grep ${username} >/dev/null 2>&1
if [ $? -eq 0 ] ; then
gpasswd -d $username $grpname
echo $username has been deleted from ${grpname}
else
echo "user Does not exist "
fi
else
echo "group Does not exist "
fi
;;
esac
done