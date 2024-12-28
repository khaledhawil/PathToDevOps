#!/bin/bash



file="/etc/passwd"
cont=1
while IFS=: read -r f1 f2 f3 f4 f5 f6 f7
do
    printf "%d:UserName: %s ----- Home Dir: %s \n" "$cont" "$f1" "$f6"
    (( cont++ ))
done < "$file"


incidents