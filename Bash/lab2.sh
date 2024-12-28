#!/bin/bash
# 
read -p "What is Your age"  age 
    #       =~ we usng this with regular expressions 
    #            ^ this refer to the input must start with number 
    #             ^[0-9]   must start with number 
    #              ^[0-9]+$  $ sign to end the input 
 if [[ $age =~  ^[0-9]+$ ]]; then
    echo "Your age is $age"
else
    echo "Please Enter A Number"
fi 


