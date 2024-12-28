#!/bin/bash


file="file.txt"

sed '/^$/ d' $file > new-txt.txt
echo "Blank lines removed" 
