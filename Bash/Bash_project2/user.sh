#!/bin/bash


CSV_FILE="employee.csv"

# Check if you'r using root user or not 

if [ "$UID" -ne 0 ]; then 
    echo "This script must run as root user"
    exit 1
fi 


# Check if Csv file is exist or not .

if [ ! -f "$CSV_FILE" ]; then 
    echo "CSV file not exist: $CSV_FILE"
    exit 1 
fi 


while IFS=, read -r username full_name
do
    if  id  "$username" &>/dev/null ; then
         echo "Username Exists."
    else
        password=$(openssl rand -base64 12)
        useradd -m -c "$full_name" -s /bin/bash "$username"
        echo "$username:$password"  | chpasswd
        chage -d 0 "$username"
        echo "User Created: $username"
        echo "Full Name: $full_name"
        echo "Random Password: $password"
        echo "--------------------------"
        echo "$username,$password >> out.txt"
    fi
done < $CSV_FILE        

echo "User creation completed"