#!/bin/bash
# Take inputs from users 

read -p "Enter Your UserNem: "  user
read -p "Enter Your Full-Name: " name

INFO=$user,$name

read -p "Please, Confirm that you have entered the correct information. Is everything correct ? [y/n] " input 

case  $input in 
    N | n ) 
        exit
        ;;
    Y | y ) 
        echo $INFO  >> employee.csv
        ;;
    *)
        echo "Invalid choose"
        exit 
        ;;
esac

echo "Your date has been stored successfully. at --> ./employee.csv "


