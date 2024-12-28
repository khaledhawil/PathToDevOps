#!/bin/bash
# بينقص قيمه مغ كل عمليه


# echo "This first patterns $1 $2 $3 $4"

# shift
# echo "After one shift $1 $2 $3 $4"

# shift 1

# echo "After one shift $1 $2 $3 $4"

while [ $# -gt 0 ]; do
    echo "$*"
    shift
    # echo "number of arguments "
done