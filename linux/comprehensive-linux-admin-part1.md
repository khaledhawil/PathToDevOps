# Comprehensive Linux Administration Guide - Part 1

## Table of Contents
1. [Introduction to Linux System Administration](#introduction-to-linux-system-administration)
2. [File System and Directory Structure](#file-system-and-directory-structure)
3. [File and Directory Operations](#file-and-directory-operations)
4. [File Permissions and Ownership](#file-permissions-and-ownership)
5. [Text Processing and File Manipulation](#text-processing-and-file-manipulation)
6. [Process Management](#process-management)
7. [System Information and Monitoring](#system-information-and-monitoring)
8. [Package Management](#package-management)
9. [Archive and Compression](#archive-and-compression)
10. [Environment Variables and Shell Configuration](#environment-variables-and-shell-configuration)

## Introduction to Linux System Administration

Linux system administration involves managing and maintaining Linux systems, including user accounts, file systems, processes, services, and system resources. This guide covers essential commands and concepts needed for effective Linux administration.

### Basic Principles
- Everything in Linux is a file
- Configuration files are typically stored in `/etc`
- User data is stored in `/home`
- System binaries are in `/bin`, `/sbin`, `/usr/bin`, `/usr/sbin`
- Temporary files are in `/tmp`
- Variable data is in `/var`

## File System and Directory Structure

### Linux Directory Hierarchy

```
/                   # Root directory
├── bin/           # Essential user binaries
├── boot/          # Boot loader files
├── dev/           # Device files
├── etc/           # Configuration files
├── home/          # User home directories
├── lib/           # Essential shared libraries
├── media/         # Removable media mount points
├── mnt/           # Temporary mount points
├── opt/           # Optional software packages
├── proc/          # Process and kernel information
├── root/          # Root user home directory
├── run/           # Runtime data
├── sbin/          # System binaries
├── srv/           # Service data
├── sys/           # System information
├── tmp/           # Temporary files
├── usr/           # User programs and data
│   ├── bin/       # User binaries
│   ├── lib/       # Libraries
│   ├── local/     # Locally installed software
│   └── share/     # Shared data
└── var/           # Variable data
    ├── log/       # Log files
    ├── mail/      # Mail spool
    └── www/       # Web server files
```

### Directory Information Commands

```bash
# List directory contents
ls                    # Basic listing
ls -l                 # Long format (permissions, owner, size, date)
ls -la                # Include hidden files
ls -lh                # Human-readable sizes
ls -lt                # Sort by modification time
ls -lS                # Sort by file size
ls -lR                # Recursive listing

# Show current directory
pwd                   # Print working directory

# Show directory tree structure
tree                  # Display directory tree
tree -L 2             # Limit depth to 2 levels
tree -a               # Include hidden files
tree -d               # Directories only

# Display directory size
du                    # Disk usage of current directory
du -h                 # Human-readable sizes
du -sh                # Summary of total size
du -sh *              # Size of each item in current directory
du -ah                # All files with sizes
du -h --max-depth=1   # Limit subdirectory depth

# Display file system usage
df                    # Disk free space
df -h                 # Human-readable format
df -T                 # Show file system types
df -i                 # Show inode usage
```

## File and Directory Operations

### Navigation Commands

```bash
# Change directory
cd /path/to/directory  # Change to specific directory
cd                     # Change to home directory
cd ~                   # Change to home directory
cd -                   # Change to previous directory
cd ..                  # Go up one directory
cd ../..               # Go up two directories
cd /                   # Go to root directory

# Create directories
mkdir directory_name              # Create single directory
mkdir -p path/to/nested/dirs     # Create nested directories
mkdir dir1 dir2 dir3             # Create multiple directories
mkdir -m 755 directory           # Create with specific permissions

# Remove directories
rmdir directory_name             # Remove empty directory
rmdir -p path/to/empty/dirs     # Remove nested empty directories
rm -rf directory_name           # Remove directory and contents (dangerous!)
```

### File Operations

```bash
# Create files
touch filename               # Create empty file or update timestamp
touch file1 file2 file3     # Create multiple files
touch -t 202512251200.00 file  # Set specific timestamp

# Copy files and directories
cp source destination        # Copy file
cp -r source_dir dest_dir   # Copy directory recursively
cp -p source dest           # Preserve permissions and timestamps
cp -a source dest           # Archive mode (preserve all attributes)
cp -u source dest           # Copy only if source is newer
cp *.txt backup/            # Copy all .txt files to backup directory

# Move and rename files
mv old_name new_name        # Rename file or directory
mv file /path/to/dest       # Move file to different location
mv *.log /var/log/          # Move all .log files

# Remove files
rm filename                 # Remove file
rm file1 file2 file3       # Remove multiple files
rm -i filename             # Interactive removal (prompt before delete)
rm -f filename             # Force removal (no prompts)
rm *.tmp                   # Remove all .tmp files

# Create symbolic and hard links
ln target_file link_name         # Create hard link
ln -s target_file symlink_name   # Create symbolic link
ln -sf new_target existing_link  # Force update symbolic link

# Find files and directories
find /path -name "filename"      # Find by name
find /path -type f               # Find files only
find /path -type d               # Find directories only
find /path -size +100M           # Find files larger than 100MB
find /path -mtime -7             # Find files modified in last 7 days
find /path -user username        # Find files owned by user
find /path -perm 755             # Find files with specific permissions
find /path -name "*.log" -delete # Find and delete .log files

# Locate files (using database)
locate filename              # Find files quickly using database
updatedb                     # Update locate database (run as root)

# Which command shows path to executable
which command_name           # Show path to command
whereis command_name         # Show binary, source, and manual locations
```

## File Permissions and Ownership

### Understanding Permissions

File permissions in Linux are represented by a 10-character string:
```
-rwxrwxrwx
│└┬┘└┬┘└┬┘
│ │  │  └── Others permissions
│ │  └───── Group permissions  
│ └──────── Owner permissions
└────────── File type
```

File types:
- `-` Regular file
- `d` Directory
- `l` Symbolic link
- `c` Character device
- `b` Block device
- `p` Named pipe
- `s` Socket

Permission characters:
- `r` Read (4)
- `w` Write (2)
- `x` Execute (1)

### Permission Commands

```bash
# Change file permissions
chmod 755 filename           # rwxr-xr-x
chmod 644 filename           # rw-r--r--
chmod u+x filename          # Add execute for owner
chmod g-w filename          # Remove write for group
chmod o=r filename          # Set others to read only
chmod a+r filename          # Add read for all
chmod -R 755 directory      # Recursive permission change

# Common permission combinations
chmod 777 file              # rwxrwxrwx (all permissions for all)
chmod 755 file              # rwxr-xr-x (common for directories)
chmod 644 file              # rw-r--r-- (common for files)
chmod 600 file              # rw------- (owner only)
chmod 400 file              # r-------- (read-only for owner)

# Change file ownership
chown user filename              # Change owner
chown user:group filename       # Change owner and group
chown :group filename           # Change group only
chown -R user:group directory   # Recursive ownership change

# Change group ownership
chgrp group filename            # Change group
chgrp -R group directory        # Recursive group change

# View file attributes
lsattr filename                 # Show file attributes
chattr +i filename              # Make file immutable
chattr -i filename              # Remove immutable attribute
chattr +a filename              # Append-only attribute
```

### Access Control Lists (ACL)

```bash
# View ACL
getfacl filename                # Show ACL for file

# Set ACL
setfacl -m u:username:rwx file  # Give user specific permissions
setfacl -m g:groupname:rx file  # Give group specific permissions
setfacl -m o:r file             # Set others permissions
setfacl -x u:username file      # Remove user from ACL
setfacl -b file                 # Remove all ACL entries

# Default ACL for directories
setfacl -d -m u:username:rwx dir # Set default ACL for new files
```

## Text Processing and File Manipulation

### Viewing File Contents

```bash
# Display file contents
cat filename                    # Display entire file
cat -n filename                # Display with line numbers
cat -b filename                # Number non-blank lines only
cat file1 file2                # Concatenate multiple files

# Display file contents page by page
less filename                   # Navigate with arrows, q to quit
more filename                   # Similar to less, space for next page

# Display beginning of file
head filename                   # First 10 lines
head -n 20 filename            # First 20 lines
head -c 100 filename           # First 100 characters

# Display end of file
tail filename                   # Last 10 lines
tail -n 20 filename            # Last 20 lines
tail -f filename               # Follow file changes (useful for logs)
tail -F filename               # Follow file even if recreated

# Display specific lines
sed -n '10,20p' filename       # Lines 10 to 20
sed -n '10p' filename          # Line 10 only
```

### Text Search and Pattern Matching

```bash
# Search for patterns in files
grep pattern filename              # Search for pattern in file
grep -i pattern filename          # Case-insensitive search
grep -r pattern directory         # Recursive search in directory
grep -n pattern filename          # Show line numbers
grep -v pattern filename          # Invert match (lines without pattern)
grep -c pattern filename          # Count matching lines
grep -l pattern *.txt             # List files containing pattern
grep -w word filename             # Match whole words only
grep -A 3 pattern filename        # Show 3 lines after match
grep -B 3 pattern filename        # Show 3 lines before match
grep -C 3 pattern filename        # Show 3 lines before and after

# Advanced grep with regex
grep '^pattern' filename          # Lines starting with pattern
grep 'pattern$' filename          # Lines ending with pattern
grep '[0-9]' filename             # Lines containing digits
grep '[a-zA-Z]' filename          # Lines containing letters

# Extended grep
egrep 'pattern1|pattern2' file    # Multiple patterns
grep -E 'pattern1|pattern2' file  # Same as above
```

### Text Processing Tools

```bash
# Cut command (extract columns)
cut -d: -f1 /etc/passwd           # Extract first field (username)
cut -d: -f1,3 /etc/passwd         # Extract fields 1 and 3
cut -c1-10 filename               # Extract characters 1-10
cut -d' ' -f2- filename           # Extract from field 2 to end

# AWK - pattern scanning and processing
awk '{print $1}' filename         # Print first field
awk -F: '{print $1}' /etc/passwd  # Use : as field separator
awk '{print NF}' filename         # Print number of fields
awk '{print NR, $0}' filename     # Print line number and line
awk '/pattern/ {print}' filename  # Print lines matching pattern
awk '{sum += $1} END {print sum}' # Sum first column

# SED - stream editor
sed 's/old/new/' filename         # Replace first occurrence per line
sed 's/old/new/g' filename        # Replace all occurrences
sed 's/old/new/gi' filename       # Case-insensitive replacement
sed '10d' filename                # Delete line 10
sed '10,20d' filename             # Delete lines 10-20
sed '/pattern/d' filename         # Delete lines containing pattern
sed -i 's/old/new/g' filename     # Edit file in place

# Sort and unique
sort filename                     # Sort lines alphabetically
sort -n filename                  # Sort numerically
sort -r filename                  # Sort in reverse order
sort -k2 filename                 # Sort by second field
sort -u filename                  # Sort and remove duplicates
uniq filename                     # Remove consecutive duplicates
uniq -c filename                  # Count occurrences

# Word, line, and character count
wc filename                       # Lines, words, characters
wc -l filename                    # Line count only
wc -w filename                    # Word count only
wc -c filename                    # Character count only

# Translation and deletion
tr 'a-z' 'A-Z' < file            # Convert lowercase to uppercase
tr -d '0-9' < file               # Delete all digits
tr -s ' ' < file                 # Squeeze multiple spaces to one
```

### File Comparison

```bash
# Compare files
diff file1 file2                  # Show differences between files
diff -u file1 file2               # Unified diff format
diff -y file1 file2               # Side-by-side comparison
cmp file1 file2                   # Compare files byte by byte
comm file1 file2                  # Compare sorted files line by line
```

## Process Management

### Viewing Processes

```bash
# Process status
ps                               # Show processes for current terminal
ps aux                           # Show all processes with details
ps -ef                           # Full format listing
ps -u username                   # Show processes for specific user
ps -C command_name               # Show processes by command name

# Real-time process monitoring
top                              # Interactive process viewer
htop                             # Enhanced version of top (if installed)
atop                             # Advanced system monitor

# Process tree
pstree                           # Show process tree
pstree -p                        # Include process IDs
pstree username                  # Show tree for specific user
```

### Process Control

```bash
# Start processes
command &                        # Start process in background
nohup command &                  # Start process immune to hangups
screen command                   # Start in screen session
tmux new-session -d command      # Start in tmux session

# Job control
jobs                             # List active jobs
fg %1                           # Bring job 1 to foreground
bg %1                           # Send job 1 to background
disown %1                       # Remove job from shell's job table

# Kill processes
kill PID                         # Terminate process by PID
kill -9 PID                      # Force kill process
kill -TERM PID                   # Send termination signal
killall command_name             # Kill all processes by name
pkill pattern                    # Kill processes matching pattern
pgrep pattern                    # Find process IDs matching pattern

# Process priorities
nice -n 10 command              # Start with lower priority
renice 10 PID                   # Change priority of running process
```

### System Resources and Performance

```bash
# Memory usage
free                            # Show memory usage
free -h                         # Human-readable format
free -m                         # Show in megabytes
cat /proc/meminfo               # Detailed memory information

# CPU information
lscpu                           # CPU architecture information
cat /proc/cpuinfo               # Detailed CPU information
nproc                           # Number of processing units

# System load
uptime                          # System uptime and load average
w                               # Who is logged on and what they're doing
who                             # Show logged-in users
last                            # Show login history

# I/O statistics
iostat                          # I/O statistics
iostat -x 1 5                   # Extended stats, 1-second intervals, 5 times
iotop                           # Real-time I/O monitoring

# Network monitoring
netstat -tuln                   # Show listening ports
ss -tuln                        # Modern replacement for netstat
lsof -i                         # Show network connections
```

## System Information and Monitoring

### Hardware Information

```bash
# System information
uname -a                        # All system information
uname -r                        # Kernel version
uname -m                        # Machine architecture
hostname                        # System hostname
hostnamectl                     # Detailed hostname information

# Hardware details
lshw                           # List hardware
lshw -short                    # Short format
lspci                          # PCI devices
lsusb                          # USB devices
lsblk                          # Block devices
fdisk -l                       # Disk partitions

# DMI/SMBIOS information
dmidecode                      # Hardware information from BIOS
dmidecode -t system            # System information
dmidecode -t memory            # Memory information
dmidecode -t processor         # Processor information
```

### Log Files and System Monitoring

```bash
# System logs
journalctl                      # View systemd logs
journalctl -f                   # Follow logs in real-time
journalctl -u service_name      # Logs for specific service
journalctl --since "1 hour ago" # Recent logs
journalctl -p err               # Error messages only

# Traditional log files
tail -f /var/log/syslog         # Follow system log
tail -f /var/log/auth.log       # Authentication log
tail -f /var/log/kern.log       # Kernel log
less /var/log/messages          # General system messages

# Log rotation
logrotate -f /etc/logrotate.conf # Force log rotation
```

## Package Management

### Debian/Ubuntu (APT)

```bash
# Update package database
apt update                      # Update package lists
apt upgrade                     # Upgrade installed packages
apt full-upgrade               # Upgrade with dependency resolution

# Install packages
apt install package_name        # Install package
apt install package1 package2  # Install multiple packages
apt install -y package_name     # Install without confirmation

# Remove packages
apt remove package_name         # Remove package (keep config)
apt purge package_name          # Remove package and config files
apt autoremove                  # Remove orphaned packages

# Search and information
apt search keyword              # Search for packages
apt show package_name           # Show package information
apt list --installed           # List installed packages
apt list --upgradable          # List upgradable packages

# Package files
dpkg -l                        # List all installed packages
dpkg -L package_name           # List files installed by package
dpkg -S filename               # Find package that owns file
```

### Red Hat/CentOS/Fedora (YUM/DNF)

```bash
# YUM (older systems)
yum update                     # Update all packages
yum install package_name       # Install package
yum remove package_name        # Remove package
yum search keyword             # Search packages
yum info package_name          # Package information
yum list installed            # List installed packages

# DNF (newer systems)
dnf update                     # Update all packages
dnf install package_name       # Install package
dnf remove package_name        # Remove package
dnf search keyword             # Search packages
dnf info package_name          # Package information
dnf list installed            # List installed packages

# RPM commands
rpm -qa                        # List all installed packages
rpm -ql package_name           # List files in package
rpm -qf filename               # Find package owning file
rpm -ivh package.rpm           # Install RPM package
```

## Archive and Compression

### TAR Archives

```bash
# Create archives
tar -cf archive.tar files       # Create tar archive
tar -czf archive.tar.gz files   # Create compressed tar.gz
tar -cjf archive.tar.bz2 files  # Create tar.bz2 archive
tar -cJf archive.tar.xz files   # Create tar.xz archive

# Extract archives
tar -xf archive.tar             # Extract tar archive
tar -xzf archive.tar.gz         # Extract tar.gz
tar -xjf archive.tar.bz2        # Extract tar.bz2
tar -xJf archive.tar.xz         # Extract tar.xz

# List archive contents
tar -tf archive.tar             # List files in archive
tar -tzf archive.tar.gz         # List files in compressed archive

# Extract specific files
tar -xf archive.tar filename    # Extract specific file
tar -xf archive.tar --wildcards "*.txt" # Extract files matching pattern

# Archive with additional options
tar -czf backup.tar.gz --exclude="*.log" /home/user # Exclude patterns
tar -czf backup.tar.gz -T filelist.txt              # Archive files from list
```

### Compression Tools

```bash
# GZIP
gzip filename                   # Compress file (replaces original)
gzip -d filename.gz             # Decompress file
gunzip filename.gz              # Same as gzip -d
gzip -l filename.gz             # List compressed file info

# BZIP2
bzip2 filename                  # Compress file
bzip2 -d filename.bz2           # Decompress file
bunzip2 filename.bz2            # Same as bzip2 -d

# XZ
xz filename                     # Compress file
xz -d filename.xz               # Decompress file
unxz filename.xz                # Same as xz -d

# ZIP
zip archive.zip files           # Create zip archive
zip -r archive.zip directory    # Recursively zip directory
unzip archive.zip               # Extract zip archive
unzip -l archive.zip            # List contents of zip file
```

## Environment Variables and Shell Configuration

### Environment Variables

```bash
# View environment variables
env                             # Show all environment variables
printenv                        # Same as env
echo $VARIABLE_NAME             # Show specific variable
echo $PATH                      # Show PATH variable
echo $HOME                      # Show home directory
echo $USER                      # Show current user

# Set environment variables
export VARIABLE_NAME=value      # Set for current session
VARIABLE_NAME=value command     # Set for single command
unset VARIABLE_NAME             # Remove variable

# Common environment variables
PATH                            # Executable search path
HOME                            # User home directory
USER                            # Current username
SHELL                           # Current shell
LANG                            # System language
TERM                            # Terminal type
```

### Shell Configuration Files

```bash
# Bash configuration files
~/.bashrc                       # User-specific bash configuration
~/.bash_profile                 # User login configuration
~/.bash_aliases                 # User aliases
/etc/bash.bashrc               # System-wide bash configuration
/etc/profile                   # System-wide login configuration

# Reload configuration
source ~/.bashrc                # Reload .bashrc
. ~/.bashrc                     # Same as source
exec bash                       # Restart bash shell
```

### Aliases and Functions

```bash
# Create aliases
alias ll='ls -la'               # Create alias
alias la='ls -la'
alias ..='cd ..'
alias grep='grep --color=auto'

# View aliases
alias                           # List all aliases
alias ll                        # Show specific alias

# Remove aliases
unalias ll                      # Remove alias

# Create functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Add to .bashrc for persistence
echo "alias ll='ls -la'" >> ~/.bashrc
```

This completes Part 1 of the Linux Administration Guide, covering fundamental file operations, permissions, text processing, process management, system monitoring, package management, and shell configuration.
