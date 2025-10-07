# Bash Scripting

## Why Bash Scripting in DevOps

Bash scripts automate repetitive tasks:
- System administration
- Deployment automation
- Log analysis and monitoring
- Backup and restore operations
- Environment setup
- CI/CD pipeline tasks
- Server configuration
- Batch file processing

Every DevOps engineer needs Bash scripting for daily automation.

## Your First Bash Script

**Create script:**
```bash
nano hello.sh
```

**Content:**
```bash
#!/bin/bash
# This is a comment

echo "Hello, DevOps!"
```

**Explanation:**
- `#!/bin/bash` - Shebang, tells system to use bash interpreter
- `#` - Comment, ignored by bash
- `echo` - Prints text to terminal

**Make executable:**
```bash
chmod +x hello.sh
```

**Run script:**
```bash
./hello.sh
```

Output:
```
Hello, DevOps!
```

## Variables

**Define variable:**
```bash
name="John"
age=25
```

**No spaces around = sign!**

**Use variable:**
```bash
echo "My name is $name"
echo "I am $age years old"
```

**Curly braces for clarity:**
```bash
echo "My name is ${name}"
```

**Read user input:**
```bash
echo "Enter your name:"
read name
echo "Hello, $name"
```

**Read with prompt:**
```bash
read -p "Enter your age: " age
echo "You are $age years old"
```

**Command substitution:**
```bash
current_date=$(date)
echo "Today is $current_date"

files_count=$(ls | wc -l)
echo "Files in directory: $files_count"
```

**Environment variables:**
```bash
echo $HOME
echo $USER
echo $PATH
```

## Data Types

**Strings:**
```bash
first_name="John"
last_name="Doe"
full_name="$first_name $last_name"
echo $full_name
```

**Numbers (integers only in basic bash):**
```bash
num1=10
num2=20
sum=$((num1 + num2))
echo "Sum: $sum"
```

**Arrays:**
```bash
# Define array
fruits=("apple" "banana" "orange")

# Access elements
echo ${fruits[0]}      # apple
echo ${fruits[1]}      # banana

# All elements
echo ${fruits[@]}

# Array length
echo ${#fruits[@]}

# Add element
fruits+=("grape")

# Loop through array
for fruit in "${fruits[@]}"; do
    echo $fruit
done
```

## Operators

**Arithmetic operators:**
```bash
num1=10
num2=3

# Addition
result=$((num1 + num2))
echo $result    # 13

# Subtraction
result=$((num1 - num2))
echo $result    # 7

# Multiplication
result=$((num1 * num2))
echo $result    # 30

# Division
result=$((num1 / num2))
echo $result    # 3

# Modulus
result=$((num1 % num2))
echo $result    # 1
```

**Using bc for floating point:**
```bash
result=$(echo "scale=2; 10 / 3" | bc)
echo $result    # 3.33
```

**Comparison operators:**
```bash
num1=10
num2=20

# Numeric comparison
[ $num1 -eq $num2 ]    # Equal
[ $num1 -ne $num2 ]    # Not equal
[ $num1 -gt $num2 ]    # Greater than
[ $num1 -lt $num2 ]    # Less than
[ $num1 -ge $num2 ]    # Greater or equal
[ $num1 -le $num2 ]    # Less or equal
```

**String comparison:**
```bash
str1="hello"
str2="world"

[ "$str1" = "$str2" ]     # Equal
[ "$str1" != "$str2" ]    # Not equal
[ -z "$str1" ]            # String is empty
[ -n "$str1" ]            # String is not empty
```

**File operators:**
```bash
[ -e file.txt ]    # File exists
[ -f file.txt ]    # Is regular file
[ -d directory ]   # Is directory
[ -r file.txt ]    # File is readable
[ -w file.txt ]    # File is writable
[ -x script.sh ]   # File is executable
```

## Conditional Statements

**If statement:**
```bash
#!/bin/bash

age=18

if [ $age -ge 18 ]; then
    echo "You are an adult"
fi
```

**If-else:**
```bash
#!/bin/bash

read -p "Enter your age: " age

if [ $age -ge 18 ]; then
    echo "You are an adult"
else
    echo "You are a minor"
fi
```

**If-elif-else:**
```bash
#!/bin/bash

read -p "Enter your score: " score

if [ $score -ge 90 ]; then
    echo "Grade: A"
elif [ $score -ge 80 ]; then
    echo "Grade: B"
elif [ $score -ge 70 ]; then
    echo "Grade: C"
else
    echo "Grade: F"
fi
```

**Multiple conditions (AND):**
```bash
if [ $age -ge 18 ] && [ $age -le 65 ]; then
    echo "Working age"
fi

# Alternative syntax
if [[ $age -ge 18 && $age -le 65 ]]; then
    echo "Working age"
fi
```

**Multiple conditions (OR):**
```bash
if [ $day = "Saturday" ] || [ $day = "Sunday" ]; then
    echo "Weekend"
fi

# Alternative syntax
if [[ $day = "Saturday" || $day = "Sunday" ]]; then
    echo "Weekend"
fi
```

**Case statement:**
```bash
#!/bin/bash

read -p "Enter fruit name: " fruit

case $fruit in
    apple)
        echo "Red or green fruit"
        ;;
    banana)
        echo "Yellow fruit"
        ;;
    orange)
        echo "Orange fruit"
        ;;
    *)
        echo "Unknown fruit"
        ;;
esac
```

## Loops

**For loop:**
```bash
#!/bin/bash

# Loop through numbers
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

# Loop through range
for i in {1..5}; do
    echo "Number: $i"
done

# C-style for loop
for ((i=1; i<=5; i++)); do
    echo "Number: $i"
done

# Loop through files
for file in *.txt; do
    echo "Processing $file"
done

# Loop through command output
for user in $(cat /etc/passwd | cut -d: -f1); do
    echo "User: $user"
done
```

**While loop:**
```bash
#!/bin/bash

counter=1

while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done
```

**Read file line by line:**
```bash
#!/bin/bash

while IFS= read -r line; do
    echo "Line: $line"
done < file.txt
```

**Until loop:**
```bash
#!/bin/bash

counter=1

until [ $counter -gt 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done
```

**Break and continue:**
```bash
#!/bin/bash

# Break - exit loop
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        break
    fi
    echo $i
done

# Continue - skip iteration
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        continue
    fi
    echo $i
done
```

## Functions

**Define function:**
```bash
#!/bin/bash

greet() {
    echo "Hello, World!"
}

# Call function
greet
```

**Function with parameters:**
```bash
#!/bin/bash

greet() {
    echo "Hello, $1!"
}

greet "John"
greet "Alice"
```

**Multiple parameters:**
```bash
#!/bin/bash

add() {
    result=$(($1 + $2))
    echo $result
}

sum=$(add 10 20)
echo "Sum: $sum"
```

**Return value:**
```bash
#!/bin/bash

is_even() {
    if [ $(($1 % 2)) -eq 0 ]; then
        return 0  # Success (true)
    else
        return 1  # Failure (false)
    fi
}

if is_even 4; then
    echo "Number is even"
else
    echo "Number is odd"
fi
```

**Local variables:**
```bash
#!/bin/bash

my_function() {
    local local_var="I am local"
    global_var="I am global"
}

my_function
echo $global_var    # Works
echo $local_var     # Empty
```

## Command Line Arguments

**Access arguments:**
```bash
#!/bin/bash

echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"
```

**Run script:**
```bash
./script.sh arg1 arg2 arg3
```

Output:
```
Script name: ./script.sh
First argument: arg1
Second argument: arg2
All arguments: arg1 arg2 arg3
Number of arguments: 3
```

**Check if arguments provided:**
```bash
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename=$1
echo "Processing $filename"
```

**Shift arguments:**
```bash
#!/bin/bash

while [ $# -gt 0 ]; do
    echo "Argument: $1"
    shift
done
```

## Input/Output Redirection

**Output redirection:**
```bash
# Overwrite file
echo "Hello" > file.txt

# Append to file
echo "World" >> file.txt

# Redirect stderr
command 2> error.log

# Redirect both stdout and stderr
command > output.log 2>&1

# Modern syntax
command &> output.log
```

**Input redirection:**
```bash
# Read from file
while read line; do
    echo $line
done < file.txt

# Here document
cat << EOF
Line 1
Line 2
Line 3
EOF
```

**Pipe:**
```bash
# Connect stdout to stdin
ls -l | grep "txt"
cat file.txt | wc -l
ps aux | grep nginx
```

## Error Handling

**Exit codes:**
```bash
#!/bin/bash

command

if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi
```

**Exit on error:**
```bash
#!/bin/bash
set -e  # Exit on any error

command1
command2
command3
```

**Custom exit codes:**
```bash
#!/bin/bash

if [ ! -f file.txt ]; then
    echo "Error: File not found"
    exit 1
fi

echo "File exists"
exit 0
```

**Trap errors:**
```bash
#!/bin/bash

cleanup() {
    echo "Cleaning up..."
    rm -f temp_file
}

trap cleanup EXIT

# Script continues
touch temp_file
```

## Real DevOps Scripts

### System Health Check

```bash
#!/bin/bash

echo "=== System Health Check ==="
echo

# CPU usage
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}'
echo

# Memory usage
echo "Memory Usage:"
free -h | awk '/^Mem:/ {print $3 "/" $2}'
echo

# Disk usage
echo "Disk Usage:"
df -h | grep -v "tmpfs" | grep -v "loop"
echo

# Check critical services
services=("nginx" "mysql" "redis")

echo "Service Status:"
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "$service: Running"
    else
        echo "$service: Stopped"
    fi
done
```

### Backup Script

```bash
#!/bin/bash

# Configuration
SOURCE_DIR="/var/www/html"
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="website_${DATE}.tar.gz"

# Create backup
echo "Starting backup..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" "$SOURCE_DIR"

if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_NAME"
else
    echo "Backup failed!"
    exit 1
fi

# Remove backups older than 7 days
find "$BACKUP_DIR" -name "website_*.tar.gz" -mtime +7 -delete

echo "Old backups cleaned up"
```

### Log Analysis

```bash
#!/bin/bash

LOG_FILE="/var/log/nginx/access.log"

echo "=== Nginx Log Analysis ==="
echo

# Top 10 IPs
echo "Top 10 IP Addresses:"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
echo

# Top 10 URLs
echo "Top 10 URLs:"
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
echo

# HTTP status codes
echo "HTTP Status Codes:"
awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -rn
echo

# Requests per hour
echo "Requests per Hour:"
awk '{print $4}' "$LOG_FILE" | cut -d: -f2 | sort | uniq -c
```

### Deployment Script

```bash
#!/bin/bash

set -e

APP_NAME="myapp"
APP_DIR="/var/www/$APP_NAME"
GIT_REPO="git@github.com:user/$APP_NAME.git"
BRANCH="main"

echo "=== Deploying $APP_NAME ==="

# Backup current version
if [ -d "$APP_DIR" ]; then
    echo "Creating backup..."
    cp -r "$APP_DIR" "${APP_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
fi

# Pull latest code
echo "Pulling latest code..."
cd "$APP_DIR"
git fetch origin
git reset --hard origin/$BRANCH

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Run database migrations
echo "Running migrations..."
python manage.py migrate

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Restart application
echo "Restarting application..."
sudo systemctl restart $APP_NAME

# Health check
sleep 5
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "Deployment successful!"
else
    echo "Health check failed! Rolling back..."
    # Restore backup
    exit 1
fi
```

### User Management

```bash
#!/bin/bash

create_user() {
    username=$1
    
    if id "$username" &>/dev/null; then
        echo "User $username already exists"
        return 1
    fi
    
    sudo useradd -m -s /bin/bash "$username"
    echo "User $username created"
    
    # Set SSH key
    sudo mkdir -p /home/$username/.ssh
    sudo touch /home/$username/.ssh/authorized_keys
    sudo chown -R $username:$username /home/$username/.ssh
    sudo chmod 700 /home/$username/.ssh
    sudo chmod 600 /home/$username/.ssh/authorized_keys
}

delete_user() {
    username=$1
    
    if ! id "$username" &>/dev/null; then
        echo "User $username does not exist"
        return 1
    fi
    
    sudo userdel -r "$username"
    echo "User $username deleted"
}

# Main menu
echo "User Management Script"
echo "1. Create user"
echo "2. Delete user"
read -p "Choose option: " option

case $option in
    1)
        read -p "Enter username: " username
        create_user "$username"
        ;;
    2)
        read -p "Enter username: " username
        delete_user "$username"
        ;;
    *)
        echo "Invalid option"
        ;;
esac
```

## Best Practices

1. **Always add shebang** (`#!/bin/bash`)
2. **Use set -e** to exit on errors
3. **Quote variables** (`"$var"` not `$var`)
4. **Check if file exists** before operations
5. **Validate user input**
6. **Use functions** for reusable code
7. **Add comments** for clarity
8. **Use meaningful variable names**
9. **Handle errors gracefully**
10. **Test scripts thoroughly**

## Common Mistakes

**Mistake 1: No quotes**
```bash
# Wrong
if [ $name = "John" ]; then

# Right
if [ "$name" = "John" ]; then
```

**Mistake 2: Spaces in assignment**
```bash
# Wrong
var = "value"

# Right
var="value"
```

**Mistake 3: Not checking exit codes**
```bash
# Wrong
command

# Right
command
if [ $? -ne 0 ]; then
    echo "Command failed"
    exit 1
fi
```

## Practice Exercises

1. Write script to check if service is running
2. Create backup script with date-based naming
3. Parse log file for errors
4. Automate user creation with SSH key setup
5. Monitor disk space and alert if > 80%
6. Write deployment script with rollback
7. Create menu-driven system administration tool
8. Build automated testing script

## Next Steps

Bash scripting is essential for system automation. Practice regularly with real-world scenarios.

Continue to: `02-python-automation.md`
