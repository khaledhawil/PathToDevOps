#!/bin/bash
# Prompt the user for the name of the new script

read -p "Enter The name of the new script file (without .sh): " script
 # Create the new scrip  file with .sh extension

script_file=${script}.sh

# Create the script file and add the shebang line 

echo "#!/bin/bash" > "$script_file"


chmod +x "$script_file"
echo "Script '$script_file' created and made executable."
