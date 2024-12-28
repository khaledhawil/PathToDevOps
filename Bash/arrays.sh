


my_array=(value1 value2 value3)


# Accessing elements
echo "${my_array[0]}"  # Outputs: value1
echo "${my_array[1]}"  # Outputs: value2

echo "${my_array[@]}"  # Outputs: all values
echo "${#my_array[@]}"  # Outputs: all values

echo "${#my_array}"  # Outputs: all values

my_array+=(value4)

echo "${my_array[@]}"

 echo "${my_array[3]}"  # Outputs: value2
unset $my_array[2]
echo "${my_array[@]:1:3}"
#-------------------------------------------------------
for value in "${my_array[@]}"; do
    echo "$value"
done
echo "--------------------------------_"
echo $my_array