#!/bin/bash
# select courses in  Linux bash docker k8s aws 
# do
#     echo "Choose a course to learn $courses"
#     break
# done 




echo "Select your operation: "
 
select operator in add subtract multiply  divide quit
do
    case $operator in 
        add)
            read -p "Enter first number: " n1
            read -p "Enter second number: " n2
            echo  "$n1 + $n2 = $(( $n1 + $n2 ))"
            ;;
        subtract)
            read -p "Enter first number: " n1
            read -p "Enter second number: " n2
            echo  "$n1 - $n2 = $(( $n1 - $n2 ))"
            ;;
        multiply)
            read -p "Enter first number: " n1
            read -p "Enter second number: " n2
            echo  "$n1 * $n2 = $(( $n1 * $n2 ))"
            ;;
        divide)
            read -p "Enter first number: " n1
            read -p "Enter second number: " n2
            echo  "$n1 / $n2 = $(( $n1 / $n2 ))"
            ;;
        quit)
            exit 0 
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
