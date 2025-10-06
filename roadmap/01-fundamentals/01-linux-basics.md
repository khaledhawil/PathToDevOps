# Linux Basics

## What is Linux?

Linux is an operating system kernel created by Linus Torvalds in 1991. An operating system is software that manages hardware resources and provides services for computer programs.

### Why Linux for DevOps?

**Market Share:** 96.3% of the top one million web servers run Linux
**Cloud Dominance:** AWS, Google Cloud, Azure primarily use Linux
**Open Source:** Free to use, modify, and distribute
**Stability:** Servers run for years without rebooting
**Security:** Built with security in mind, permissions system
**Package Management:** Easy software installation and updates
**Automation:** Designed to be automated via scripts

### Linux vs Windows vs macOS

**Linux:**
- Open source and free
- Highly customizable
- Command-line focused
- Multi-user by design
- Stable and secure
- DevOps industry standard

**Windows:**
- Proprietary
- GUI-focused
- Primarily single-user
- Common in enterprise desktops
- Less common in server environments

**macOS:**
- Proprietary Unix-based
- Good for development
- Expensive hardware
- Popular among developers

## Linux Distributions

A distribution is Linux kernel plus software packages.

### Popular Distributions

**Ubuntu:**
- Most beginner-friendly
- Excellent documentation
- LTS versions (Long Term Support) for 5 years
- Default choice for learning and cloud
- Uses APT package manager

**Debian:**
- Ubuntu is based on Debian
- Very stable
- Strict free software principles
- Used in production environments

**Red Hat Enterprise Linux (RHEL):**
- Commercial distribution
- Enterprise support
- Very stable
- Common in large corporations
- Uses YUM/DNF package manager

**CentOS / Rocky Linux:**
- Free alternatives to RHEL
- Enterprise-grade stability
- Popular for servers

**Alpine Linux:**
- Extremely small (about 5MB)
- Used in Docker containers
- Security-focused
- Minimal resource usage

**For Learning: Ubuntu 22.04 LTS is recommended**

## Linux Filesystem Hierarchy

Linux organizes files in a tree structure starting from root directory.

### Directory Structure

```
/
├── bin/        Binary executables (essential commands)
├── boot/       Boot loader files (kernel, initrd)
├── dev/        Device files (hardware as files)
├── etc/        Configuration files
├── home/       User home directories
├── lib/        Shared libraries (like Windows DLLs)
├── media/      Mount points for removable media
├── mnt/        Temporary mount points
├── opt/        Optional software packages
├── proc/       Process information (virtual filesystem)
├── root/       Root user home directory
├── run/        Runtime data since last boot
├── sbin/       System binaries (admin commands)
├── srv/        Service data
├── sys/        System information (virtual filesystem)
├── tmp/        Temporary files (cleared on reboot)
├── usr/        User programs and data
└── var/        Variable data (logs, databases)
```

### Important Directories Explained

**/bin** - Essential Commands
Contains basic commands needed for system boot and repair:
- ls (list files)
- cp (copy)
- mv (move)
- rm (remove)
- cat (display file content)

These commands are available even in single-user mode.

**/etc** - Configuration Files
All system-wide configuration files live here:
- /etc/passwd - User account information
- /etc/shadow - Encrypted passwords
- /etc/hosts - Hostname to IP mapping
- /etc/ssh/sshd_config - SSH server configuration
- /etc/nginx/nginx.conf - Nginx configuration

**Important:** Configuration files are text files, editable with any text editor.

**/home** - User Directories
Each user has a directory here:
- /home/john - John's files
- /home/alice - Alice's files

Your home directory symbol is ~ (tilde).

**/var** - Variable Data
Data that changes during system operation:
- /var/log - Log files (system and application logs)
- /var/www - Web server files (default for Apache/Nginx)
- /var/lib - State information (databases)
- /var/tmp - Temporary files (preserved across reboots)

**DevOps Note:** You will spend significant time in /var/log analyzing application logs.

**/usr** - User Programs
Secondary hierarchy for user programs:
- /usr/bin - Non-essential commands
- /usr/local - Locally installed software
- /usr/share - Shared data (documentation, icons)

**/tmp** - Temporary Files
Temporary storage for programs:
- Cleared on reboot
- World-writable (any user can write)
- Use for temporary data that doesn't need persistence

## Essential Commands

### Navigation Commands

**pwd** - Print Working Directory
Shows your current location in filesystem.

```bash
pwd
```

Output: `/home/username`

**Explanation:** Tells you where you are. Essential when navigating complex directory structures.

**cd** - Change Directory
Move between directories.

```bash
cd /var/log        # Go to /var/log
cd ..              # Go up one level
cd ~               # Go to home directory
cd -               # Go to previous directory
cd                 # Go to home directory (shortcut)
```

**Explanation:**
- `cd /var/log` - Absolute path (starts with /)
- `cd ..` - Relative path (relative to current location)
- `cd ~` - ~ expands to /home/username
- `cd -` - Useful for switching between two directories

**ls** - List Files
Display directory contents.

```bash
ls                 # List files in current directory
ls -l              # Long format (detailed)
ls -a              # Show hidden files (start with .)
ls -lh             # Long format with human-readable sizes
ls -lt             # Sort by modification time
ls -R              # Recursive (show subdirectories)
```

**Explanation of ls -l output:**
```bash
drwxr-xr-x 2 user group 4096 Jan 15 10:30 directory_name
-rw-r--r-- 1 user group 1234 Jan 15 10:30 file_name
```

Breaking down each field:
- `d` - Directory (or `-` for file)
- `rwxr-xr-x` - Permissions
- `2` - Number of hard links
- `user` - Owner
- `group` - Group owner
- `4096` - Size in bytes
- `Jan 15 10:30` - Last modification time
- `directory_name` - Name

### File Operations

**touch** - Create Empty File
Creates a new file or updates timestamp.

```bash
touch newfile.txt
touch file1.txt file2.txt file3.txt    # Create multiple files
```

**Explanation:** If file exists, only the modification timestamp is updated. Often used in scripts to mark events.

**mkdir** - Make Directory
Create directories.

```bash
mkdir new_directory
mkdir -p parent/child/grandchild    # Create nested directories
```

**Explanation:** 
- Without `-p`, mkdir fails if parent doesn't exist
- With `-p`, creates all intermediate directories

**cp** - Copy Files
Copy files or directories.

```bash
cp source.txt destination.txt
cp file.txt /path/to/destination/
cp -r directory/ /path/to/destination/    # Copy directory recursively
cp -i file.txt dest.txt                   # Interactive (ask before overwrite)
```

**Explanation:**
- `-r` or `-R` - Recursive, required for directories
- `-i` - Interactive, prevents accidental overwrites
- `-p` - Preserve permissions and timestamps

**mv** - Move or Rename
Move files or rename them.

```bash
mv oldname.txt newname.txt              # Rename
mv file.txt /path/to/destination/       # Move
mv *.txt documents/                     # Move multiple files
```

**Explanation:** mv is atomic operation, either completes fully or not at all. Safe for renaming files even if system crashes.

**rm** - Remove Files
Delete files or directories.

```bash
rm file.txt
rm -r directory/              # Remove directory recursively
rm -f file.txt                # Force remove (no confirmation)
rm -rf directory/             # Force remove directory (DANGEROUS)
```

**WARNING:** Linux has no recycle bin. Deleted files are gone forever.

**Explanation:**
- `-r` - Recursive, required for directories
- `-f` - Force, don't ask for confirmation
- Never run `rm -rf /` (deletes everything)

**cat** - Concatenate and Display
Display file contents.

```bash
cat file.txt                  # Display file
cat file1.txt file2.txt       # Display multiple files
cat > newfile.txt             # Create file (Ctrl+D to save)
cat file1.txt file2.txt > combined.txt    # Combine files
```

**Explanation:** Reads file and outputs to terminal. Good for small files. For large files, use `less` or `more`.

**less** - View Files Page by Page
View large files with pagination.

```bash
less /var/log/syslog
```

**Controls inside less:**
- Space: Next page
- b: Previous page
- /pattern: Search forward
- ?pattern: Search backward
- q: Quit

**Explanation:** Doesn't load entire file into memory, efficient for large log files.

**head** - Display First Lines
Show beginning of file.

```bash
head file.txt              # First 10 lines
head -n 5 file.txt         # First 5 lines
head -n 20 /var/log/syslog # First 20 lines of log
```

**Explanation:** Useful for quickly checking file format or headers.

**tail** - Display Last Lines
Show end of file.

```bash
tail file.txt              # Last 10 lines
tail -n 20 file.txt        # Last 20 lines
tail -f /var/log/syslog    # Follow (real-time updates)
```

**Explanation:** 
- `tail -f` is essential for monitoring log files in real-time
- Press Ctrl+C to stop following

### File Content and Search

**grep** - Search Text
Search for patterns in files.

```bash
grep "error" logfile.txt
grep -i "error" logfile.txt        # Case-insensitive
grep -r "error" /var/log/           # Recursive in directory
grep -v "debug" logfile.txt         # Invert match (exclude)
grep -n "error" logfile.txt         # Show line numbers
```

**Explanation:**
- Most used command for log analysis
- Supports regular expressions
- Essential for troubleshooting

**find** - Find Files
Search for files and directories.

```bash
find /home -name "*.txt"            # Find all .txt files
find /var/log -name "*.log" -mtime -7    # Modified in last 7 days
find . -type f                      # Find only files
find . -type d                      # Find only directories
find . -size +100M                  # Files larger than 100MB
```

**Explanation:**
- Searches by name, type, size, time, permissions
- Can execute commands on found files
- Powerful but can be slow on large filesystems

**wc** - Word Count
Count lines, words, and characters.

```bash
wc file.txt                 # Lines, words, characters
wc -l file.txt              # Count lines only
wc -w file.txt              # Count words only
```

**Explanation:** Often used to count log entries or data rows.

### File Permissions and Ownership

**chmod** - Change Mode (Permissions)
Modify file permissions.

```bash
chmod 755 script.sh         # rwxr-xr-x
chmod +x script.sh          # Add execute permission
chmod -w file.txt           # Remove write permission
chmod u+x,g+x file.sh       # Add execute for user and group
```

**Permission Numbers:**
- 4 = read (r)
- 2 = write (w)
- 1 = execute (x)

**755 breakdown:**
- 7 (4+2+1) = rwx for owner
- 5 (4+1) = r-x for group
- 5 (4+1) = r-x for others

**Common Permissions:**
- 644 = rw-r--r-- (files)
- 755 = rwxr-xr-x (directories and scripts)
- 600 = rw------- (sensitive files)
- 777 = rwxrwxrwx (never use, security risk)

**chown** - Change Owner
Change file owner and group.

```bash
sudo chown user file.txt
sudo chown user:group file.txt
sudo chown -R user:group directory/    # Recursive
```

**Explanation:** Requires root/sudo privileges. Used when transferring files between users or fixing ownership issues.

### System Information

**whoami** - Current User
Display current username.

```bash
whoami
```

**Explanation:** Useful in scripts to check which user is running the script.

**hostname** - System Name
Display system hostname.

```bash
hostname
hostname -I                 # Show IP addresses
```

**Explanation:** Identifies the machine. Important in distributed systems.

**uname** - System Information
Display system information.

```bash
uname -a                    # All information
uname -r                    # Kernel version
uname -m                    # Hardware architecture
```

**Explanation:** Shows OS type, kernel version, architecture. Important for compatibility checks.

**df** - Disk Free
Display disk space usage.

```bash
df -h                       # Human-readable format
df -h /var                  # Specific filesystem
```

**Explanation:** Monitor disk space to prevent full disk issues. Full disk causes system failures.

**du** - Disk Usage
Show directory space usage.

```bash
du -h directory/            # Human-readable
du -sh directory/           # Summary only
du -h --max-depth=1         # One level deep
```

**Explanation:** Find which directories consume most space.

**free** - Memory Usage
Display memory statistics.

```bash
free -h                     # Human-readable format
```

**Explanation:** Shows total, used, free, and available memory. Critical for performance troubleshooting.

### Input/Output Redirection

Linux treats everything as a file, including input and output streams.

**Three Standard Streams:**
- stdin (0) - Standard input (keyboard)
- stdout (1) - Standard output (screen)
- stderr (2) - Standard error (screen)

**Output Redirection:**

```bash
command > file.txt          # Redirect output to file (overwrite)
command >> file.txt         # Append output to file
command 2> error.log        # Redirect errors to file
command > output.txt 2>&1   # Redirect both output and errors
```

**Example:**
```bash
ls /var/log > log_files.txt
echo "New line" >> log_files.txt
find / -name "test" 2> /dev/null    # Suppress errors
```

**Explanation:**
- `>` overwrites file
- `>>` appends to file
- `2>` redirects errors only
- `2>&1` redirects stderr to wherever stdout goes
- `/dev/null` is a black hole, discards data

**Input Redirection:**

```bash
command < input.txt         # Read from file instead of keyboard
```

**Example:**
```bash
wc -l < file.txt
```

**Pipes:**

Connect output of one command to input of another.

```bash
command1 | command2         # Output of command1 → input of command2
```

**Examples:**
```bash
ls -l | grep "txt"          # List files, filter .txt files
cat file.txt | wc -l        # Count lines in file
ps aux | grep nginx         # Find nginx processes
cat /var/log/syslog | grep error | wc -l    # Count error lines
```

**Explanation:** Pipes are fundamental to Unix philosophy: combine small tools to accomplish complex tasks.

## Practical Examples

### Example 1: Finding Large Files

```bash
find /home -type f -size +100M | xargs ls -lh | sort -k5 -h
```

**Breakdown:**
1. `find /home -type f -size +100M` - Find files larger than 100MB
2. `|` - Pipe results to next command
3. `xargs ls -lh` - List files with details
4. `|` - Pipe to next command
5. `sort -k5 -h` - Sort by 5th column (size) in human-readable format

### Example 2: Monitoring Log File

```bash
tail -f /var/log/syslog | grep --color=auto "error"
```

**Breakdown:**
1. `tail -f /var/log/syslog` - Follow log file in real-time
2. `|` - Pipe to grep
3. `grep --color=auto "error"` - Highlight error lines in color

### Example 3: Disk Space Alert

```bash
df -h | grep '^/dev' | awk '{print $5 " " $1}' | sort -rn
```

**Breakdown:**
1. `df -h` - Show disk usage
2. `grep '^/dev'` - Filter only device filesystems
3. `awk '{print $5 " " $1}'` - Print percentage and device
4. `sort -rn` - Sort numerically in reverse

## Best Practices

1. **Use Tab Completion:** Press Tab to autocomplete filenames and commands
2. **Check Before Deleting:** Use `ls` before `rm` to verify you are deleting correct files
3. **Backup Important Files:** Before making changes, create backups
4. **Read Man Pages:** `man command` provides official documentation
5. **Test in Safe Environment:** Try commands in test directory first
6. **Use History:** Press Up arrow to recall previous commands
7. **Use Absolute Paths in Scripts:** Avoid ambiguity

## Common Mistakes

1. **Running rm -rf without thinking:** Double-check paths
2. **Not checking current directory:** Use pwd before operations
3. **Ignoring file extensions:** Linux doesn't care about extensions
4. **Case sensitivity:** file.txt and File.txt are different files
5. **Spaces in filenames:** Use quotes or escape spaces

## Next Steps

Practice these commands extensively before moving to user and permission management. Create files, directories, search through them, and use pipes to combine commands.

Once comfortable with basic navigation and file operations, proceed to `02-user-permissions.md`.
