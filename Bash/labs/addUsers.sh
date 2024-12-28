#!/bin/bash
# Function to add users 
add_user(){
    read -p "Entre username to add: " username
    sudo useradd "$username"
    if [ $? -eq 0 ]; then
        echo  " User '$username' added successfully."
    else 
        echo "Failed to add user '$username' . "
    fi
}   


list_users()
{
    echo "List of Users "
    tail -n 5 /etc/passwd | cut -d: -f1
}

delete_user(){
    read -p "Enter the userName to delete " user
    sudo userdel "$user" 
    if [ $? -eq 0 ]; then
        echo "The '$user' has been deleted "
    else
        echo "Failed to delete this User"
    fi
}


# while true; do 
#     echo "User Management Menu: "
#     echo "1. Add User"
#     echo "2. List Of Users"
#     echo "3. Delete User"
#     echo "4. Exit"
#     read -p "Select an option: " option
#     case $option in
#         1 | add | Add) add_user ;;
#         2 | list | List | ls) list_users ;;
#         3 | delete | Delete | del  ) delete_user ;;
#         4 | ex | exit | q) echo "Exiting."; exit 0 ;;
#         *) echo "Invalid option. Please try again." ;;
#     esac
# done




while true; do 
    echo "Users Management Menu: "
    echo "1. List users "
    echo "2. Add user "
    echo "3. Delete user "
    echo "4. Exit. "
    read -p "Select an option: " option
    case $option in
        1 | list | ls ) list_users;;
        2 | add | Add ) add_user ;;
        3 | delete | Delete) delete_user ;;
        4 | q | exit ) echo "Exiting."; exit 0 ;;
        *) echo "Invalid Option try select an option " ;;
    esac
done