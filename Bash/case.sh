#!/bin/bash

# Case Statement in BaSH


#ex1 

# read -p "Enter a number from (1-3)" num


# case $num in 
#     1)
#         echo "You entered one" 
#         ;;
#     2)
#         echo "You entered Two"
#         ;;
#     2)
#         echo "You Entered three"
#         ;;
#     *)
#         echo "Invalid input! Please enter a number between 1 and 3."
#         ;;
# esac




# read -p "Do You Know Bash Scripting: " bash 
# case $bash in 
#     Yes|yes|y|Y)
#         echo "That's  very good"
#         ;;
#     NO|no|n|N)
#         echo "You should Learn it"
#         ;;
#     *)
#         echo "Invalid input, Please Enter Yes Or No"
#         ;;
# esac



# read -p "Enter Your Score= " score

# case $score in 
#     8[0-9] | 9[0-9] | 10)
#         echo "Your grade is A "
#         ;;
#     7[5-9]| 8[0-4])
#         echo "Your Grade is B"
#         ;;
#     6[5-9] | 7[0-4])
#         echo "Your grade is C"
#         ;;
#     6[0-4])
#         echo "YOur grade is D"
#         ;;
#     *)
#         echo "Your Grade is F"
#         ;;
# esac
    
# #!/bin/bash

# # Get the user's input for the desired action
# read -p "Choose an action: [install, configure, deploy, test] " action

# # Use a case statement to handle different actions
# case "$action" in
#   install)
#     echo "Installing necessary packages..."
#     # Add your installation commands here (e.g., using apt-get, yum, etc.)
#     ;;
#   configure)
#     echo "Configuring the application..."
#     # Add your configuration commands here (e.g., editing config files)
#     ;;
#   deploy)
#     echo "Deploying the application..."
#     # Add your deployment commands here (e.g., using tools like Ansible, Puppet)
#     ;;
#   test)
#     echo "Running tests..."
#     # Add your testing commands here (e.g., unit tests, integration tests)
#     ;;
#   *)
#     echo "Invalid action. Please choose from: install, configure, deploy, test"
#     ;;
# esac



#!/bin/bash

# Function to check the operating system
check_os() {
  case "$(uname -s)" in
    "Linux")
      echo "Operating system: Linux"
      # Install packages using apt-get (for Debian/Ubuntu)
      sudo apt-get update
      sudo apt-get install -y git
      ;;
    "Darwin")
      echo "Operating system: macOS"
      # Install packages using brew (for macOS)
      brew install git
      ;;
    "Windows_NT")
      echo "Operating system: Windows"
      # Install packages using chocolatey (for Windows)
      choco install git
      ;;
    *)
      echo "Unsupported operating system"
      exit 1
      ;;
  esac
}

# Example usage: Install a specific package
check_os






