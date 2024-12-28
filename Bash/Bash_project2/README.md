# Automated User Management Scripts
    - This project provides a set of Bash scripts to manage user creation and data storage in a Linux environment. 
    - The scripts ensure secure and efficient user management with randomly generated passwords and initial password reset policies.

## Project Features
- Data Collection and Storage
    - Collects user information interactively.
    - Stores user data (username and full name) in a CSV file for later processing.
- Automated User Creation

    - Reads the stored CSV file and creates Linux system users.
    - Assigns secure, randomly generated passwords to each user.
    - Forces users to change their password upon first login.
- User Management

    - Users can be deleted using standard Linux commands for efficient system cleanup.
## Prerequisites
- A Linux system with Bash installed.
- The openssl package for generating secure random passwords:
```bash
sudo apt update && sudo apt install openssl  
```
## Scripts Overview
### Script 1: Data Collection (data.sh)
    - This script collects user information interactively and saves it to a CSV file.

- Usage:
Run the script:

```bash
bash data.sh 
``` 
- Input:

    Username.
    Full Name.
    Confirm data entry (y/n).
- Example:
```bash
Enter your username: user123  
Enter your full-name: John Doe  
Please confirm that you have entered the correct information. Is everything correct? [y/n] y  
Your data has been stored successfully.  
```
## Script 2: User Creation (user.sh)
- This script reads the CSV file and creates users with secure, randomly generated passwords.

    Usage:
    Run the script with sudo:
 ```bash
    sudo bash user.sh  
```
### Key Features:
    Checks if the script is executed with root privileges.
    Reads user data from employee.csv.
    Assigns a random password to each user.
    Forces users to reset their password upon the first login.
    Stores generated passwords in out.txt for reference.
- Output:
    Example output for a created user:
```bash
        User created: user123  
        Full Name: John Doe  
        Random Password: T7k2V3pQ1s!  
        -------------------  
```
### File Structure
- plaintext
```bash ├── data.sh          # Script to collect user data  
├── user.sh          # Script to create system users  
├── employee.csv     # Stores collected user data  
├── out.txt          # Stores generated usernames and passwords  
```
### Additional User Management Commands
- Delete a User
- To delete a user and remove their home directory:

```bash
sudo deluser --remove-home <username>  
```
- Example:

```bash
sudo deluser --remove-home aws  
```
## Security Considerations
- Secure Password Generation: The script uses openssl rand to generate strong random passwords.
- Initial Password Reset: New users are forced to change their password upon first login for better security.
- Controlled User Deletion: The deluser command is used to safely remove users when needed.
## Future Improvements
- Add logging functionality for user creation and deletion.
- Implement additional validation for user data input.
- Extend support for bulk user deletion.
# Author
* Created by Khaled Hawil.