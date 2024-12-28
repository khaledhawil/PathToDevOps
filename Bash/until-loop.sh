#!/bin/bash

read -p "Enter A Number: " cont 
until [ $cont -gt 5 ]; do
    echo $cont
    ((cont++))
done


read -p "Enter A Number: " cont 
while [ $cont -gt 5 ]; do
    echo $cont
    ((cont--))
done


