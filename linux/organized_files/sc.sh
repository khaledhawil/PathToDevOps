#!/bin/bash


username=$1
group=$2
password=$3



# Check If arguments are provided 

if [ -z "$username" ] || [ -z "$group" ] || [ -z "$password" ] ; then
	echo "Usage: $0 <username> <group> <password> "
	exit 1
fi

# Create user y useradd 

sudo useradd  -m -g "$group"  -p "$password"  "$useradd" 
echo "User '$useradd' Created successfully"
