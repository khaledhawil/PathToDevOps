#!/bin/bash

# if [ $UID -eq 0 ]; then
#     echo "Welcome ya Rooot"
# else 
#     echo "Welcome ya $USER"
# # fi
#  _  ___           _          _   _   _                _ _ 
# | |/ / |__   __ _| | ___  __| | | | | | __ ___      _(_) |
# | ' /| '_ \ / _` | |/ _ \/ _` | | |_| |/ _` \ \ /\ / / | |
# | . \| | | | (_| | |  __/ (_| | |  _  | (_| |\ V  V /| | |
# |_|\_\_| |_|\__,_|_|\___|\__,_| |_| |_|\__,_| \_/\_/ |_|_|
                                                          



if test $UID -eq 0 ; then 
    echo "Welcome YA rooot"
else 
    echo "Welcome ya &USER"
fi 

