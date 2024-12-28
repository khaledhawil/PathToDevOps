#!/bin/bash


# # Create a Function  

# func1 (){
#     echo "Hello From Function: $1" 

# }


# func1 one
# func1 two

# # Define a function to greet a user
# greet_user() {
#     echo "Hello, $1!"  # $1 refers to the first argument passed to the function
# }

# # Call the function with an argument
# greet_user "Alice"
# greet_user "Bob"




# add_numbers() {
#     local sum=$(( $1 + $2 ))  # Calculate the sum of the two arguments
#     echo $sum  # Output the sum
# }

# # Call the function and capture the output
# result=$(add_numbers 5 10)

# # Print the result
# echo "The sum is: $result"




sum (){
    let result=$1+$2
    echo $result
}

mul (){
    let result=$1*$2
    echo $result
}

sum
mul 