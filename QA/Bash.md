# Bash Scripting Interview Questions and Answers for DevOps Engineers & System Administrators

## Table of Contents
1. [Bash Basics](#bash-basics)
2. [Variables and Data Types](#variables-and-data-types)
3. [Control Structures](#control-structures)
4. [Functions](#functions)
5. [File Operations](#file-operations)
6. [Text Processing](#text-processing)
7. [Process Management](#process-management)
8. [Error Handling](#error-handling)
9. [Advanced Scripting](#advanced-scripting)
10. [System Administration](#system-administration)
11. [DevOps Automation](#devops-automation)
12. [Performance and Optimization](#performance-and-optimization)
13. [Security](#security)
14. [Debugging and Troubleshooting](#debugging-and-troubleshooting)

---

## Bash Basics

### 1. What is Bash and how does it differ from other shells?

**Short Answer:** Bash (Bourne Again Shell) is a command processor and scripting language that extends the Bourne shell with additional features like command history, job control, and advanced scripting capabilities.

**Detailed Explanation:**

**Bash Features:**
- **Command History**: Navigate and reuse previous commands
- **Tab Completion**: Auto-complete files, commands, and variables
- **Job Control**: Background/foreground process management
- **Aliases**: Create shortcuts for frequently used commands
- **Functions**: Define reusable code blocks
- **Arrays**: Support for indexed and associative arrays
- **Regular Expressions**: Pattern matching capabilities

**Comparison with Other Shells:**

| Feature | Bash | Zsh | Fish | Dash |
|---------|------|-----|------|------|
| POSIX Compliance | Yes | Yes | No | Yes |
| Auto-completion | Basic | Advanced | Smart | Minimal |
| Syntax Highlighting | No | Yes | Yes | No |
| Performance | Good | Good | Good | Excellent |
| Scripting | Excellent | Excellent | Good | Basic |
| Plugins | Limited | Extensive | Moderate | None |

**Basic Bash Script Structure:**
```bash
#!/bin/bash
# Script: example.sh
# Description: Basic Bash script template
# Author: Your Name
# Date: $(date +%Y-%m-%d)

# Exit on any error
set -e
# Exit on undefined variables
set -u
# Exit on pipe failures
set -o pipefail

# Global variables
SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(dirname "$0")
LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"

# Function to log messages
log_message() {
    local level="$1"
    shift
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $*" | tee -a "$LOG_FILE"
}

# Function to handle errors
error_exit() {
    log_message "ERROR" "$1"
    exit 1
}

# Main function
main() {
    log_message "INFO" "Script started"
    
    # Your script logic here
    
    log_message "INFO" "Script completed successfully"
}

# Call main function with all arguments
main "$@"
```

### 2. Explain Bash variable types and scope.

**Short Answer:** Bash supports string variables, arrays, and special variables with global and local scope, plus environment variables for inter-process communication.

**Detailed Explanation:**

**Variable Types:**

1. **String Variables:**
```bash
# Variable assignment (no spaces around =)
name="John Doe"
age=30
empty_var=""
readonly_var="constant"
readonly readonly_var

# Variable expansion
echo "Hello, $name"
echo "Hello, ${name}"
echo "Age: ${age} years old"

# Default values
echo "User: ${USER:-unknown}"           # Use USER or 'unknown' if unset
echo "Home: ${HOME:=/tmp}"              # Use HOME or set to '/tmp' if unset
echo "Shell: ${SHELL:?Shell not set}"   # Error if SHELL is unset
```

2. **Arrays:**
```bash
# Indexed arrays
fruits=("apple" "banana" "orange")
fruits[3]="grape"

# Access array elements
echo "First fruit: ${fruits[0]}"
echo "All fruits: ${fruits[@]}"
echo "Array length: ${#fruits[@]}"
echo "Indices: ${!fruits[@]}"

# Associative arrays (Bash 4+)
declare -A config
config["host"]="localhost"
config["port"]="8080"
config["ssl"]="true"

# Access associative array
echo "Host: ${config[host]}"
echo "All keys: ${!config[@]}"
echo "All values: ${config[@]}"

# Array operations
fruits+=("kiwi")                    # Append element
unset fruits[1]                     # Remove element
fruits=("${fruits[@]/orange/mango}") # Replace element
```

3. **Special Variables:**
```bash
# Script arguments
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "All arguments as string: $*"
echo "Number of arguments: $#"

# Process information
echo "Process ID: $$"
echo "Parent PID: $PPID"
echo "Last background PID: $!"
echo "Exit status of last command: $?"

# Example usage
#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: $0 <source> <destination>"
    exit 1
fi

source="$1"
destination="$2"
shift 2  # Remove first two arguments
options="$@"  # Remaining arguments

echo "Copying $source to $destination with options: $options"
```

**Variable Scope:**
```bash
#!/bin/bash

# Global variables
global_var="I'm global"

function test_scope() {
    # Local variables
    local local_var="I'm local"
    local global_var="I'm local override"
    
    echo "Inside function:"
    echo "  Local: $local_var"
    echo "  Global (overridden): $global_var"
    
    # Modify global variable
    global_modified="Modified from function"
}

echo "Before function:"
echo "  Global: $global_var"

test_scope

echo "After function:"
echo "  Global: $global_var"
echo "  Global modified: $global_modified"
# echo "  Local: $local_var"  # This would be empty/undefined
```

**Environment Variables:**
```bash
# Export variables to environment
export PATH="/usr/local/bin:$PATH"
export DATABASE_URL="postgresql://localhost:5432/mydb"

# Read environment variables
echo "Current PATH: $PATH"
echo "Home directory: $HOME"
echo "Current user: $USER"

# Set temporary environment variables
DATABASE_HOST=localhost DATABASE_PORT=5432 ./my_script.sh

# Check if variable is set
if [ -n "${DATABASE_URL:-}" ]; then
    echo "Database URL is set"
else
    echo "Database URL is not set"
fi
```

---

## Control Structures

### 3. Explain Bash conditional statements and operators.

**Short Answer:** Bash provides if/then/else statements, case statements, and various test operators for numeric, string, and file comparisons.

**Detailed Explanation:**

**If Statements:**
```bash
#!/bin/bash

# Basic if statement
if [ "$USER" = "root" ]; then
    echo "Running as root"
else
    echo "Running as regular user"
fi

# Multiple conditions
if [ "$#" -eq 0 ]; then
    echo "No arguments provided"
elif [ "$#" -eq 1 ]; then
    echo "One argument provided: $1"
else
    echo "Multiple arguments provided: $#"
fi

# Nested conditions
if [ -f "/etc/os-release" ]; then
    if grep -q "Ubuntu" /etc/os-release; then
        echo "Running on Ubuntu"
    elif grep -q "CentOS" /etc/os-release; then
        echo "Running on CentOS"
    else
        echo "Running on other Linux distribution"
    fi
else
    echo "Cannot determine OS"
fi
```

**Test Operators:**
```bash
# Numeric comparisons
num1=10
num2=20

if [ "$num1" -eq "$num2" ]; then echo "Equal"; fi
if [ "$num1" -ne "$num2" ]; then echo "Not equal"; fi
if [ "$num1" -lt "$num2" ]; then echo "$num1 is less than $num2"; fi
if [ "$num1" -le "$num2" ]; then echo "$num1 is less than or equal to $num2"; fi
if [ "$num1" -gt "$num2" ]; then echo "$num1 is greater than $num2"; fi
if [ "$num1" -ge "$num2" ]; then echo "$num1 is greater than or equal to $num2"; fi

# String comparisons
str1="hello"
str2="world"

if [ "$str1" = "$str2" ]; then echo "Strings are equal"; fi
if [ "$str1" != "$str2" ]; then echo "Strings are not equal"; fi
if [ -z "$str1" ]; then echo "String is empty"; fi
if [ -n "$str1" ]; then echo "String is not empty"; fi

# Pattern matching
if [[ "$str1" == h* ]]; then echo "String starts with 'h'"; fi
if [[ "$str1" =~ ^[a-z]+$ ]]; then echo "String contains only lowercase letters"; fi

# File tests
file="/etc/passwd"
if [ -e "$file" ]; then echo "File exists"; fi
if [ -f "$file" ]; then echo "Is a regular file"; fi
if [ -d "$file" ]; then echo "Is a directory"; fi
if [ -r "$file" ]; then echo "File is readable"; fi
if [ -w "$file" ]; then echo "File is writable"; fi
if [ -x "$file" ]; then echo "File is executable"; fi
if [ -s "$file" ]; then echo "File is not empty"; fi

# File comparisons
file1="/etc/passwd"
file2="/etc/group"
if [ "$file1" -nt "$file2" ]; then echo "$file1 is newer than $file2"; fi
if [ "$file1" -ot "$file2" ]; then echo "$file1 is older than $file2"; fi
if [ "$file1" -ef "$file2" ]; then echo "Files are the same"; fi
```

**Logical Operators:**
```bash
# AND operator
if [ -f "/etc/passwd" ] && [ -r "/etc/passwd" ]; then
    echo "File exists and is readable"
fi

# OR operator
if [ "$USER" = "root" ] || [ "$USER" = "admin" ]; then
    echo "User has administrative privileges"
fi

# NOT operator
if ! [ -f "/etc/config" ]; then
    echo "Config file does not exist"
fi

# Complex conditions
if [[ ( "$USER" = "root" || "$USER" = "admin" ) && -f "/etc/config" ]]; then
    echo "Admin user with config file"
fi
```

**Case Statements:**
```bash
#!/bin/bash

# Basic case statement
case "$1" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    status)
        echo "Checking service status..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

# Pattern matching in case
check_file_type() {
    local file="$1"
    
    case "$file" in
        *.txt)
            echo "Text file"
            ;;
        *.jpg|*.jpeg|*.png|*.gif)
            echo "Image file"
            ;;
        *.tar.gz|*.tgz)
            echo "Compressed archive"
            ;;
        *.[Cc]|*.[Cc][Pp][Pp])
            echo "C/C++ source file"
            ;;
        [0-9]*.log)
            echo "Numbered log file"
            ;;
        *)
            echo "Unknown file type"
            ;;
    esac
}

# Case with multiple actions
process_option() {
    case "$1" in
        -v|--verbose)
            VERBOSE=true
            echo "Verbose mode enabled"
            ;;
        -q|--quiet)
            QUIET=true
            exec > /dev/null 2>&1
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            # Regular argument
            ARGS+=("$1")
            ;;
    esac
}
```

### 4. How do you implement loops in Bash?

**Short Answer:** Bash supports for loops (C-style and range), while loops, until loops, and break/continue statements for iteration control.

**Detailed Explanation:**

**For Loops:**
```bash
#!/bin/bash

# Traditional for loop with list
echo "=== Processing files ==="
for file in *.txt *.log; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        # Process file here
    fi
done

# For loop with array
servers=("web1" "web2" "db1" "cache1")
for server in "${servers[@]}"; do
    echo "Checking server: $server"
    ping -c 1 "$server" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "  ✓ $server is online"
    else
        echo "  ✗ $server is offline"
    fi
done

# C-style for loop
echo "=== Countdown ==="
for ((i=10; i>=1; i--)); do
    echo "Countdown: $i"
    sleep 1
done
echo "Blast off!"

# For loop with sequence
echo "=== Creating directories ==="
for i in $(seq 1 5); do
    mkdir -p "dir_$i"
    echo "Created directory: dir_$i"
done

# For loop with brace expansion
for month in {01..12}; do
    echo "Processing month: $month"
    # Process monthly data
done

# For loop with step
for i in {0..100..5}; do
    echo "Progress: $i%"
done
```

**While Loops:**
```bash
#!/bin/bash

# Basic while loop
counter=1
while [ $counter -le 5 ]; do
    echo "Iteration: $counter"
    ((counter++))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Processing line: $line"
    # Process each line
done < "/etc/passwd"

# While loop with condition check
log_file="/var/log/application.log"
while [ ! -f "$log_file" ]; do
    echo "Waiting for log file to appear..."
    sleep 5
done
echo "Log file found!"

# Infinite loop with break condition
while true; do
    echo "Monitoring system..."
    
    # Check system load
    load=$(uptime | awk '{print $10}' | sed 's/,//')
    if (( $(echo "$load > 5.0" | bc -l) )); then
        echo "High load detected: $load"
        break
    fi
    
    sleep 60
done

# Process monitoring loop
service_name="nginx"
while ! systemctl is-active --quiet "$service_name"; do
    echo "Service $service_name is not running, attempting to start..."
    systemctl start "$service_name"
    sleep 10
done
echo "Service $service_name is running"
```

**Until Loops:**
```bash
#!/bin/bash

# Basic until loop
counter=1
until [ $counter -gt 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done

# Wait until file exists
until [ -f "/tmp/process_complete" ]; do
    echo "Waiting for process to complete..."
    sleep 5
done
echo "Process completed!"

# Wait until service is ready
until curl -f http://localhost:8080/health > /dev/null 2>&1; do
    echo "Waiting for service to be ready..."
    sleep 10
done
echo "Service is ready!"

# Network connectivity check
host="google.com"
until ping -c 1 "$host" > /dev/null 2>&1; do
    echo "No internet connection, retrying..."
    sleep 30
done
echo "Internet connection established"
```

**Loop Control:**
```bash
#!/bin/bash

# Break and continue example
echo "=== Processing numbers 1-10 ==="
for i in {1..10}; do
    # Skip even numbers
    if [ $((i % 2)) -eq 0 ]; then
        echo "Skipping even number: $i"
        continue
    fi
    
    # Stop at 7
    if [ $i -eq 7 ]; then
        echo "Stopping at: $i"
        break
    fi
    
    echo "Processing odd number: $i"
done

# Nested loops with labeled break
#!/bin/bash
echo "=== Processing matrix ==="
for ((row=1; row<=3; row++)); do
    for ((col=1; col<=3; col++)); do
        if [ $row -eq 2 ] && [ $col -eq 2 ]; then
            echo "Found center element at ($row,$col), stopping all loops"
            break 2  # Break out of both loops
        fi
        echo "Element at ($row,$col)"
    done
done

# Error handling in loops
process_files() {
    local error_count=0
    local max_errors=3
    
    for file in *.data; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        echo "Processing: $file"
        
        # Simulate processing that might fail
        if ! process_file "$file"; then
            echo "Error processing $file"
            ((error_count++))
            
            if [ $error_count -ge $max_errors ]; then
                echo "Too many errors, stopping processing"
                return 1
            fi
            
            continue
        fi
        
        echo "Successfully processed: $file"
    done
    
    if [ $error_count -gt 0 ]; then
        echo "Completed with $error_count errors"
        return 1
    fi
    
    echo "All files processed successfully"
    return 0
}
```

---

## Functions

### 5. How do you create and use functions in Bash?

**Short Answer:** Bash functions are reusable code blocks defined with function keyword or function_name() syntax, supporting parameters, return values, and local variables.

**Detailed Explanation:**

**Function Definition Syntax:**
```bash
#!/bin/bash

# Method 1: function keyword
function greet() {
    echo "Hello, $1!"
}

# Method 2: function name with parentheses
say_goodbye() {
    echo "Goodbye, $1!"
}

# Method 3: POSIX compatible
hello_world() {
    echo "Hello, World!"
}

# Calling functions
greet "Alice"
say_goodbye "Bob"
hello_world
```

**Function Parameters and Return Values:**
```bash
#!/bin/bash

# Function with multiple parameters
calculate_sum() {
    local num1="$1"
    local num2="$2"
    
    if [ $# -ne 2 ]; then
        echo "Usage: calculate_sum <num1> <num2>" >&2
        return 1
    fi
    
    if ! [[ "$num1" =~ ^-?[0-9]+$ ]] || ! [[ "$num2" =~ ^-?[0-9]+$ ]]; then
        echo "Error: Arguments must be integers" >&2
        return 1
    fi
    
    local result=$((num1 + num2))
    echo "$result"
    return 0
}

# Function that returns status and outputs result
validate_email() {
    local email="$1"
    local email_regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    
    if [[ "$email" =~ $email_regex ]]; then
        echo "Valid email: $email"
        return 0
    else
        echo "Invalid email: $email" >&2
        return 1
    fi
}

# Using functions with return values
echo "=== Calculator Example ==="
result=$(calculate_sum 10 20)
if [ $? -eq 0 ]; then
    echo "Sum: $result"
else
    echo "Calculation failed"
fi

echo "=== Email Validation Example ==="
if validate_email "user@example.com"; then
    echo "Email validation passed"
else
    echo "Email validation failed"
fi
```

**Advanced Function Features:**
```bash
#!/bin/bash

# Function with variable arguments
log_message() {
    local level="$1"
    shift  # Remove first argument
    local message="$*"  # All remaining arguments as string
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        ERROR)
            echo "[$timestamp] [ERROR] $message" >&2
            ;;
        WARN)
            echo "[$timestamp] [WARN] $message" >&2
            ;;
        INFO)
            echo "[$timestamp] [INFO] $message"
            ;;
        DEBUG)
            if [ "${DEBUG:-false}" = "true" ]; then
                echo "[$timestamp] [DEBUG] $message"
            fi
            ;;
        *)
            echo "[$timestamp] [$level] $message"
            ;;
    esac
}

# Function with default parameters
create_backup() {
    local source="${1:?Source directory required}"
    local destination="${2:-/backup}"
    local compression="${3:-gzip}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="backup_${timestamp}"
    
    log_message "INFO" "Creating backup of $source"
    log_message "INFO" "Destination: $destination"
    log_message "INFO" "Compression: $compression"
    
    mkdir -p "$destination"
    
    case "$compression" in
        gzip)
            tar -czf "$destination/${backup_name}.tar.gz" -C "$(dirname "$source")" "$(basename "$source")"
            ;;
        bzip2)
            tar -cjf "$destination/${backup_name}.tar.bz2" -C "$(dirname "$source")" "$(basename "$source")"
            ;;
        xz)
            tar -cJf "$destination/${backup_name}.tar.xz" -C "$(dirname "$source")" "$(basename "$source")"
            ;;
        none)
            tar -cf "$destination/${backup_name}.tar" -C "$(dirname "$source")" "$(basename "$source")"
            ;;
        *)
            log_message "ERROR" "Unsupported compression: $compression"
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log_message "INFO" "Backup created successfully: $destination/${backup_name}"
        echo "$destination/${backup_name}"
        return 0
    else
        log_message "ERROR" "Backup failed"
        return 1
    fi
}

# Function with arrays and associative arrays
process_server_list() {
    local -a servers=("$@")  # Accept array as argument
    local -A results         # Associative array for results
    
    log_message "INFO" "Processing ${#servers[@]} servers"
    
    for server in "${servers[@]}"; do
        log_message "INFO" "Checking server: $server"
        
        if ping -c 1 -W 5 "$server" > /dev/null 2>&1; then
            results["$server"]="online"
            log_message "INFO" "Server $server is online"
        else
            results["$server"]="offline"
            log_message "WARN" "Server $server is offline"
        fi
    done
    
    # Print results
    echo "Server Status Report:"
    for server in "${!results[@]}"; do
        printf "  %-20s: %s\n" "$server" "${results[$server]}"
    done
}

# Recursive function example
calculate_factorial() {
    local n="$1"
    
    if [ "$n" -le 1 ]; then
        echo 1
    else
        local prev_factorial=$(calculate_factorial $((n - 1)))
        echo $((n * prev_factorial))
    fi
}

# Function with error handling and cleanup
process_with_cleanup() {
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Cleanup function
    cleanup() {
        log_message "INFO" "Cleaning up temporary directory: $temp_dir"
        rm -rf "$temp_dir"
    }
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    log_message "INFO" "Working in temporary directory: $temp_dir"
    
    # Simulate work that might fail
    cd "$temp_dir" || {
        log_message "ERROR" "Cannot change to temp directory"
        return 1
    }
    
    # Do some work
    echo "Temporary file" > temp_file.txt
    
    if [ ! -f "temp_file.txt" ]; then
        log_message "ERROR" "Failed to create temporary file"
        return 1
    fi
    
    log_message "INFO" "Work completed successfully"
    return 0
}

# Usage examples
echo "=== Function Examples ==="

# Using log function
DEBUG=true
log_message "INFO" "Application started"
log_message "DEBUG" "Debug information"
log_message "WARN" "This is a warning"
log_message "ERROR" "This is an error"

# Using backup function
echo ""
echo "=== Backup Example ==="
backup_location=$(create_backup "/etc/hosts" "/tmp/backups" "gzip")
if [ $? -eq 0 ]; then
    echo "Backup created at: $backup_location"
fi

# Using server list function
echo ""
echo "=== Server Check Example ==="
server_list=("localhost" "google.com" "nonexistent.server.com")
process_server_list "${server_list[@]}"

# Using factorial function
echo ""
echo "=== Factorial Example ==="
for i in {1..5}; do
    result=$(calculate_factorial $i)
    echo "Factorial of $i: $result"
done

# Using cleanup function
echo ""
echo "=== Cleanup Example ==="
process_with_cleanup
```

**Function Libraries and Sourcing:**
```bash
# File: lib/common_functions.sh
#!/bin/bash

# Common utility functions library

# Check if running as root
is_root() {
    [ "$(id -u)" -eq 0 ]
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install package based on distribution
install_package() {
    local package="$1"
    
    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install -y "$package"
    elif command_exists yum; then
        sudo yum install -y "$package"
    elif command_exists dnf; then
        sudo dnf install -y "$package"
    elif command_exists pacman; then
        sudo pacman -S --noconfirm "$package"
    else
        echo "No supported package manager found" >&2
        return 1
    fi
}

# Get system information
get_system_info() {
    echo "System Information:"
    echo "  OS: $(uname -s)"
    echo "  Kernel: $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo "  Hostname: $(hostname)"
    echo "  Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo "  Load: $(uptime | awk -F'load average:' '{print $2}')"
}

# Main script using the library
#!/bin/bash
# File: main_script.sh

# Source the function library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common_functions.sh"

main() {
    echo "=== System Setup Script ==="
    
    # Check if running as root
    if ! is_root; then
        echo "This script must be run as root" >&2
        exit 1
    fi
    
    # Display system information
    get_system_info
    
    # Install required packages
    packages=("curl" "wget" "git" "htop")
    for package in "${packages[@]}"; do
        if ! command_exists "$package"; then
            echo "Installing $package..."
            install_package "$package"
        else
            echo "$package is already installed"
        fi
    done
    
    echo "Setup completed successfully"
}

main "$@"
```

---

## Text Processing

### 6. How do you process text and files in Bash?

**Short Answer:** Bash provides powerful text processing tools like grep, sed, awk, cut, sort, and various string manipulation techniques for file processing and data extraction.

**Detailed Explanation:**

**String Manipulation:**
```bash
#!/bin/bash

# String length and substrings
text="Hello, World! This is a test string."
echo "Original: $text"
echo "Length: ${#text}"
echo "Substring (7-12): ${text:7:5}"
echo "From position 7: ${text:7}"
echo "Last 10 characters: ${text: -10}"

# String replacement
echo "Replace 'World' with 'Universe': ${text/World/Universe}"
echo "Replace all spaces with underscores: ${text// /_}"
echo "Remove 'Hello, ': ${text/Hello, /}"

# Case conversion (Bash 4+)
echo "Uppercase: ${text^^}"
echo "Lowercase: ${text,,}"
echo "Capitalize first: ${text^}"
echo "Capitalize words: ${text^^?( )}"

# String trimming
text_with_spaces="   Hello World   "
echo "Original: '$text_with_spaces'"
echo "Left trim: '${text_with_spaces#"${text_with_spaces%%[![:space:]]*}"}'"
echo "Right trim: '${text_with_spaces%"${text_with_spaces##*[![:space:]]}"}'"

# Pattern matching and extraction
email="user@example.com"
if [[ "$email" =~ ^([^@]+)@([^.]+)\.(.+)$ ]]; then
    echo "Username: ${BASH_REMATCH[1]}"
    echo "Domain: ${BASH_REMATCH[2]}"
    echo "TLD: ${BASH_REMATCH[3]}"
fi
```

**File Reading and Processing:**
```bash
#!/bin/bash

# Read file line by line
process_log_file() {
    local logfile="$1"
    local error_count=0
    local warning_count=0
    local line_number=0
    
    echo "Processing log file: $logfile"
    
    while IFS= read -r line; do
        ((line_number++))
        
        case "$line" in
            *ERROR*)
                ((error_count++))
                echo "Line $line_number: ERROR found - $line"
                ;;
            *WARNING*|*WARN*)
                ((warning_count++))
                echo "Line $line_number: WARNING found - $line"
                ;;
        esac
    done < "$logfile"
    
    echo "Summary:"
    echo "  Total lines: $line_number"
    echo "  Errors: $error_count"
    echo "  Warnings: $warning_count"
}

# Process CSV file
process_csv() {
    local csvfile="$1"
    local delimiter="${2:-,}"
    
    echo "Processing CSV file: $csvfile"
    
    # Read header
    IFS="$delimiter" read -r -a headers < "$csvfile"
    echo "Headers: ${headers[*]}"
    
    # Process data rows
    local row_number=0
    while IFS="$delimiter" read -r -a fields; do
        ((row_number++))
        
        echo "Row $row_number:"
        for i in "${!headers[@]}"; do
            printf "  %s: %s\n" "${headers[$i]}" "${fields[$i]}"
        done
        echo
    done < <(tail -n +2 "$csvfile")  # Skip header
}

# Configuration file parser
parse_config() {
    local config_file="$1"
    declare -A config
    
    echo "Parsing configuration file: $config_file"
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Clean up key and value
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        config["$key"]="$value"
    done < "$config_file"
    
    # Display configuration
    echo "Configuration:"
    for key in "${!config[@]}"; do
        printf "  %s = %s\n" "$key" "${config[$key]}"
    done
}
```

**Using grep for Pattern Matching:**
```bash
#!/bin/bash

# Advanced grep examples
search_logs() {
    local log_dir="/var/log"
    
    echo "=== Searching logs ==="
    
    # Find all error messages in the last hour
    echo "Recent errors:"
    find "$log_dir" -name "*.log" -mmin -60 -exec grep -l "ERROR" {} \; 2>/dev/null
    
    # Search for specific patterns
    echo ""
    echo "Failed login attempts:"
    grep -n "Failed password" /var/log/auth.log 2>/dev/null | head -5
    
    # Search with context
    echo ""
    echo "Connection errors with context:"
    grep -B 2 -A 2 "connection.*failed" /var/log/*.log 2>/dev/null | head -10
    
    # Case-insensitive search with line numbers
    echo ""
    echo "Memory issues:"
    grep -in "out of memory\|oom\|memory allocation" /var/log/*.log 2>/dev/null | head -5
    
    # Regular expression search
    echo ""
    echo "IP addresses:"
    grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" /var/log/*.log 2>/dev/null | head -5
    
    # Recursive search
    echo ""
    echo "Configuration files with database settings:"
    grep -r "database\|db_host\|mysql\|postgresql" /etc/ 2>/dev/null | head -5
}

# Complex pattern matching
analyze_web_logs() {
    local access_log="$1"
    
    echo "Analyzing web access log: $access_log"
    
    # Extract unique IP addresses
    echo "Unique IP addresses:"
    grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" "$access_log" | sort | uniq -c | sort -nr | head -10
    
    # Find 404 errors
    echo ""
    echo "404 errors:"
    grep " 404 " "$access_log" | head -5
    
    # Find requests by user agent
    echo ""
    echo "Bot requests:"
    grep -i "bot\|crawler\|spider" "$access_log" | head -5
    
    # Extract request methods
    echo ""
    echo "HTTP methods:"
    grep -oE '"[A-Z]+ ' "$access_log" | sort | uniq -c | sort -nr
    
    # Find large requests
    echo ""
    echo "Large responses (>1MB):"
    awk '$10 > 1048576 {print $1, $7, $10}' "$access_log" | head -5
}
```

**Using sed for Text Transformation:**
```bash
#!/bin/bash

# sed examples for text processing
process_text_with_sed() {
    local input_file="$1"
    local output_file="$2"
    
    echo "Processing text with sed: $input_file -> $output_file"
    
    # Multiple sed operations
    sed '
        # Remove blank lines
        /^[[:space:]]*$/d
        
        # Remove comments (lines starting with #)
        /^[[:space:]]*#/d
        
        # Convert to lowercase
        s/.*/\L&/
        
        # Replace multiple spaces with single space
        s/[[:space:]]\+/ /g
        
        # Trim leading and trailing spaces
        s/^[[:space:]]*//
        s/[[:space:]]*$//
        
        # Add line numbers
        =' "$input_file" | sed 'N;s/\n/: /' > "$output_file"
}

# Configuration file transformation
transform_config() {
    local config_file="$1"
    
    echo "Transforming configuration file: $config_file"
    
    # Convert INI format to environment variables
    sed -n '
        # Skip empty lines and comments
        /^[[:space:]]*$/d
        /^[[:space:]]*[#;]/d
        
        # Process sections [section_name]
        /^\[.*\]$/ {
            s/^\[\(.*\)\]$/SECTION_\1/
            s/.*/\U&/
            h
            d
        }
        
        # Process key=value pairs
        /=/ {
            s/^[[:space:]]*//
            s/[[:space:]]*=[[:space:]]*/=/
            s/^/export /
            p
        }
    ' "$config_file"
}

# Log file sanitization
sanitize_logs() {
    local log_file="$1"
    local sanitized_file="$2"
    
    echo "Sanitizing log file: $log_file -> $sanitized_file"
    
    sed '
        # Remove IP addresses
        s/\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/XXX.XXX.XXX.XXX/g
        
        # Remove email addresses
        s/[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}/user@domain.com/g
        
        # Remove credit card numbers (simple pattern)
        s/\b[0-9]\{4\}[[:space:]-]*[0-9]\{4\}[[:space:]-]*[0-9]\{4\}[[:space:]-]*[0-9]\{4\}\b/XXXX-XXXX-XXXX-XXXX/g
        
        # Remove phone numbers
        s/\b[0-9]\{3\}-[0-9]\{3\}-[0-9]\{4\}\b/XXX-XXX-XXXX/g
    ' "$log_file" > "$sanitized_file"
}
```

**Using awk for Data Processing:**
```bash
#!/bin/bash

# Advanced awk examples
analyze_system_resources() {
    echo "=== System Resource Analysis ==="
    
    # Process /proc/meminfo
    echo "Memory analysis:"
    awk '
    /MemTotal/ { total = $2 }
    /MemFree/ { free = $2 }
    /MemAvailable/ { available = $2 }
    /Buffers/ { buffers = $2 }
    /Cached/ { cached = $2 }
    END {
        used = total - free
        printf "Total Memory: %.2f GB\n", total/1024/1024
        printf "Used Memory: %.2f GB (%.1f%%)\n", used/1024/1024, used*100/total
        printf "Free Memory: %.2f GB (%.1f%%)\n", free/1024/1024, free*100/total
        if (available > 0)
            printf "Available Memory: %.2f GB (%.1f%%)\n", available/1024/1024, available*100/total
    }' /proc/meminfo
    
    echo ""
    echo "Disk usage analysis:"
    df -h | awk '
    NR==1 { printf "%-20s %10s %10s %10s %6s %s\n", $1, $2, $3, $4, $5, $6 }
    NR>1 && $5 != "Use%" {
        gsub(/%/, "", $5)
        if ($5 > 80) color = "\033[31m"  # Red for >80%
        else if ($5 > 60) color = "\033[33m"  # Yellow for >60%
        else color = "\033[32m"  # Green for <60%
        printf "%s%-20s %10s %10s %10s %5s%% %s\033[0m\n", color, $1, $2, $3, $4, $5, $6
    }'
    
    echo ""
    echo "Process analysis:"
    ps aux | awk '
    NR==1 { next }  # Skip header
    {
        cpu_total += $3
        mem_total += $4
        if ($3 > max_cpu) {
            max_cpu = $3
            max_cpu_proc = $11
        }
        if ($4 > max_mem) {
            max_mem = $4
            max_mem_proc = $11
        }
        proc_count++
    }
    END {
        printf "Total processes: %d\n", proc_count
        printf "Total CPU usage: %.1f%%\n", cpu_total
        printf "Total Memory usage: %.1f%%\n", mem_total
        printf "Highest CPU process: %s (%.1f%%)\n", max_cpu_proc, max_cpu
        printf "Highest Memory process: %s (%.1f%%)\n", max_mem_proc, max_mem
    }'
}

# Log analysis with awk
analyze_apache_logs() {
    local log_file="$1"
    
    echo "Analyzing Apache access log: $log_file"
    
    awk '
    BEGIN {
        print "Apache Log Analysis"
        print "==================="
    }
    {
        # Parse common log format: IP - - [timestamp] "request" status size
        ip = $1
        timestamp = substr($4, 2)  # Remove leading [
        request = $6 " " $7
        status = $9
        size = ($10 == "-") ? 0 : $10
        
        # Count by IP
        ip_count[ip]++
        
        # Count by status code
        status_count[status]++
        
        # Count by hour
        hour = substr(timestamp, 13, 2)
        hour_count[hour]++
        
        # Track total bytes
        total_bytes += size
        
        # Track requests
        total_requests++
        
        # Track 404s
        if (status == "404") {
            not_found[ip]++
            not_found_total++
        }
    }
    END {
        printf "\nSummary:\n"
        printf "Total requests: %d\n", total_requests
        printf "Total bytes served: %.2f MB\n", total_bytes/1024/1024
        printf "Average request size: %.2f KB\n", total_bytes/total_requests/1024
        
        printf "\nTop 10 IP addresses:\n"
        PROCINFO["sorted_in"] = "@val_num_desc"
        count = 0
        for (ip in ip_count) {
            printf "%15s: %6d requests\n", ip, ip_count[ip]
            if (++count >= 10) break
        }
        
        printf "\nStatus code distribution:\n"
        PROCINFO["sorted_in"] = "@ind_str_asc"
        for (status in status_count) {
            printf "%3s: %6d (%.1f%%)\n", status, status_count[status], status_count[status]*100/total_requests
        }
        
        printf "\nTraffic by hour:\n"
        PROCINFO["sorted_in"] = "@ind_str_asc"
        for (hour in hour_count) {
            printf "%02s:00: %6d requests\n", hour, hour_count[hour]
        }
        
        if (not_found_total > 0) {
            printf "\nTop 404 errors by IP:\n"
            PROCINFO["sorted_in"] = "@val_num_desc"
            count = 0
            for (ip in not_found) {
                printf "%15s: %6d 404s\n", ip, not_found[ip]
                if (++count >= 5) break
            }
        }
    }' "$log_file"
}

# CSV processing with awk
process_sales_data() {
    local csv_file="$1"
    
    echo "Processing sales data: $csv_file"
    
    awk -F',' '
    NR==1 {
        # Process header
        for (i=1; i<=NF; i++) {
            header[i] = $i
        }
        next
    }
    {
        # Assuming CSV format: Date,Product,Category,Sales,Quantity
        date = $1
        product = $2
        category = $3
        sales = $4
        quantity = $5
        
        # Extract month from date (assuming YYYY-MM-DD format)
        split(date, date_parts, "-")
        month = date_parts[1] "-" date_parts[2]
        
        # Aggregate data
        monthly_sales[month] += sales
        category_sales[category] += sales
        product_sales[product] += sales
        total_sales += sales
        total_quantity += quantity
        
        # Track best selling product
        if (sales > best_sale_amount) {
            best_sale_amount = sales
            best_sale_product = product
            best_sale_date = date
        }
    }
    END {
        printf "\nSales Summary:\n"
        printf "=============\n"
        printf "Total Sales: $%.2f\n", total_sales
        printf "Total Quantity: %d\n", total_quantity
        printf "Average Sale: $%.2f\n", total_sales/NR-1
        printf "Best Single Sale: $%.2f (%s on %s)\n", best_sale_amount, best_sale_product, best_sale_date
        
        printf "\nSales by Month:\n"
        PROCINFO["sorted_in"] = "@ind_str_asc"
        for (month in monthly_sales) {
            printf "%7s: $%8.2f\n", month, monthly_sales[month]
        }
        
        printf "\nSales by Category:\n"
        PROCINFO["sorted_in"] = "@val_num_desc"
        for (category in category_sales) {
            printf "%15s: $%8.2f (%.1f%%)\n", category, category_sales[category], category_sales[category]*100/total_sales
        }
        
        printf "\nTop 5 Products:\n"
        PROCINFO["sorted_in"] = "@val_num_desc"
        count = 0
        for (product in product_sales) {
            printf "%20s: $%8.2f\n", product, product_sales[product]
            if (++count >= 5) break
        }
    }' "$csv_file"
}

# Usage examples
echo "=== Text Processing Examples ==="

# Create sample files for testing
cat > sample.log << 'EOF'
2023-08-24 10:30:15 [INFO] Application started
2023-08-24 10:30:16 [ERROR] Database connection failed
2023-08-24 10:30:17 [WARNING] Retrying database connection
2023-08-24 10:30:18 [INFO] Database connected successfully
2023-08-24 10:30:20 [ERROR] User authentication failed for user@example.com
EOF

cat > sample.csv << 'EOF'
Date,Product,Category,Sales,Quantity
2023-08-01,Laptop,Electronics,1200.00,1
2023-08-01,Mouse,Electronics,25.50,3
2023-08-02,Desk,Furniture,300.00,1
2023-08-02,Chair,Furniture,150.00,2
2023-08-03,Laptop,Electronics,1200.00,1
EOF

# Run examples
process_log_file "sample.log"
echo ""
process_csv "sample.csv"
echo ""
analyze_system_resources
echo ""
process_sales_data "sample.csv"

# Cleanup
rm -f sample.log sample.csv
```

This comprehensive Bash scripting guide covers essential topics for DevOps engineers and system administrators, providing practical examples and real-world scenarios for effective automation and system management.