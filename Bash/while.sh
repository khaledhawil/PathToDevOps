#!/bin/bash

# read -p "Enter The Number: " num 
# while  [ $num -gt 15 ]
# do 
#     echo "The number is $num:"
#     (( num-- ))
# done discarded
read -p "Enter The Number: " num 
while  : 
do 
    echo $num
    if [ $num -eq 20 ]; then
        echo "This nubmer end of the loop"
        break
        fi
    (( num++ ))
done