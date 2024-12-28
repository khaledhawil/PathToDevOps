#!/bin/bash

file="txt"
sed -e 's/Linux/Bash-Scripting/g' -e 's/K8s/Kubernetes/g' $file > txt1
echo "file Edited complete "
