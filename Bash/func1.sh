#!/bin/bash


source ./function.sh

# greet_user "Alice"
read -p "Enter the First numberer : " n1 
 read -p "Enter the second numberer : " n2 

echo "the result is : $(sum $n1 $n2)"
echo "the result is : $(mul $n1 $n2)"
