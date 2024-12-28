#!/bin/bash

string1="hello"
string2="world"
num1=15
num2=10
file=/home/luka/Desktop/devOpsPath/bash/Notes.txt
dir=/home/luka/Desktop/devOpsPath/bash/
# String comparison  
if [ "$string1" != "$string2" ]; then
    echo "Strings are not equal"
else 
    echo Strings are equal
fi

# Integer comparison
if [ "$num1" -lt "$num2" ]; then
    echo "$num1 is less than $num2"

else
    echo "Is greater then"
fi

# File comparison
if [ -e "$file" ]; then
    echo "$file exists"
else
    echo "$file does not exist"
fi
# directory comparison 
if [ -d  "$dir" ]; then
    echo "$dir exists"
else
    echo "$dir does not exist"
fi