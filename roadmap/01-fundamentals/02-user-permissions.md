# User and Permission Management

## Understanding Linux User System

Linux is a multi-user operating system designed from the ground up to allow multiple users to work simultaneously on the same system safely and securely.

### Why User Management Matters in DevOps

**Security:** Applications run as specific users with limited permissions
**Isolation:** Different services run as different users to contain breaches
**Auditing:** Track who made changes to the system
**Access Control:** Grant appropriate permissions to team members
**Service Accounts:** Applications and services need their own users

## User Types

### 1. Root User (Superuser)

The root user has complete control over the system.

**Characteristics:**
- User ID (UID) is always 0
- Can access any file
- Can execute any command
- Can modify system configuration
- No permission restrictions

**Example:**
```bash
whoami
# Output: root
```

**Why root is dangerous:**
- Typos can destroy the system
- No undo for destructive operations
- Malware gets full system access
- No safety checks or warnings

**Best Practice:** Never login as root. Use sudo instead.

### 2. Regular Users

Normal user accounts for people.

**Characteristics:**
- UID typically starts from 1000
- Limited to their own files
- Cannot modify system files
- Cannot install system-wide software
- Home directory: /home/username

**Example:**
```bash
whoami
# Output: john
```

### 3. System Users

Special accounts for running services.

**Characteristics:**
- UID typically between 1-999
- No login shell (cannot login)
- No home directory (or minimal one)
- Run specific services or daemons

**Examples:**
- www-data: Web server (Apache/Nginx)
- mysql: MySQL database
- redis: Redis cache
- docker: Docker daemon

**Why system users exist:**
If web server is compromised, attacker only gets www-data permissions, not root.

## User Management Commands

### Creating Users

**useradd** - Add New User

```bash
sudo useradd john
```

This creates a basic user account but:
- No password set
- No home directory created
- No default shell set

**Better approach:**
```bash
sudo useradd -m -s /bin/bash john
```

**Explanation:**
- `-m` creates home directory (/home/john)
- `-s /bin/bash` sets default shell to bash
- `john` is the username

**Even better - use adduser (interactive):**
```bash
sudo adduser john
```

This script prompts for:
- Password
- Full name
- Phone number
- Room number
- Other information

**adduser vs useradd:**
- useradd: Low-level utility, requires all options
- adduser: High-level script, interactive and user-friendly
- Use adduser for manual user creation
- Use useradd in automation scripts

### Setting Passwords

**passwd** - Change Password

```bash
sudo passwd john
```

Prompts for new password twice.

**Explanation:**
- Passwords are hashed and stored in /etc/shadow
- Only root can change other users' passwords
- Users can change their own password with just `passwd`

**Password policies:**
```bash
sudo passwd -l john    # Lock account (disable login)
sudo passwd -u john    # Unlock account
sudo passwd -e john    # Expire password (force change on next login)
```

### Modifying Users

**usermod** - Modify User Account

```bash
sudo usermod -aG sudo john           # Add user to sudo group
sudo usermod -aG docker john         # Add user to docker group
sudo usermod -s /bin/zsh john        # Change shell
sudo usermod -L john                 # Lock account
sudo usermod -U john                 # Unlock account
```

**Explanation of flags:**
- `-a` append (use with -G to avoid removing from other groups)
- `-G` specify supplementary groups
- `-s` change login shell
- `-L` lock account
- `-U` unlock account

**Warning:** Without `-a` flag, `-G` replaces all groups.

**Wrong:**
```bash
sudo usermod -G docker john    # Removes john from all other groups
```

**Correct:**
```bash
sudo usermod -aG docker john   # Adds john to docker group, keeps other groups
```

### Deleting Users

**userdel** - Delete User

```bash
sudo userdel john              # Delete user, keep home directory
sudo userdel -r john           # Delete user and home directory
```

**Explanation:**
- Without `-r`: Home directory remains, can be backed up
- With `-r`: Complete removal including all files

**Best practice:** Backup user data before deletion.

### Viewing User Information

**id** - Display User and Group IDs

```bash
id                    # Current user
id john               # Specific user
```

**Output example:**
```
uid=1000(john) gid=1000(john) groups=1000(john),27(sudo),999(docker)
```

**Explanation:**
- uid: User ID
- gid: Primary group ID
- groups: All groups user belongs to

**who** - Show Logged-in Users

```bash
who                   # Currently logged-in users
whoami                # Current username
```

**w** - Show Who is Logged In and What They Are Doing

```bash
w
```

Shows: username, terminal, remote host, login time, idle time, current process.

**last** - Show Login History

```bash
last                  # Recent logins
last john             # Login history for john
last -n 10            # Last 10 logins
```

## Groups

Groups organize users and manage permissions collectively.

### Why Groups Matter

Instead of giving permissions to each user individually:
```bash
sudo chown john file1.txt
sudo chown alice file1.txt
sudo chown bob file1.txt
```

Use groups:
```bash
sudo chown :developers file1.txt
# All users in developers group can access
```

### Group Types

**Primary Group:**
- Every user has one primary group
- Files created by user belong to this group
- Usually same name as username

**Secondary Groups:**
- User can belong to multiple secondary groups
- Grants additional permissions
- Examples: sudo, docker, www-data

### Group Management Commands

**groupadd** - Create Group

```bash
sudo groupadd developers
sudo groupadd -g 1500 admins    # Create with specific GID
```

**groupdel** - Delete Group

```bash
sudo groupdel developers
```

**Adding Users to Groups:**

```bash
sudo usermod -aG developers john
sudo gpasswd -a john developers    # Alternative method
```

**Removing Users from Groups:**

```bash
sudo gpasswd -d john developers
sudo deluser john developers       # Alternative
```

**Viewing Groups:**

```bash
groups                   # Current user's groups
groups john              # John's groups
getent group developers  # List all members of developers group
```

### Important System Groups

**sudo:**
- Members can execute commands with root privileges
- Must use sudo before commands
- Password required

**docker:**
- Members can run Docker commands without sudo
- Essentially root-level access (security consideration)

**www-data:**
- Web server group
- Web files should be readable by this group

**adm:**
- Members can read log files in /var/log

## File Permissions

Linux permissions control who can read, write, or execute files.

### Permission Types

**Read (r):**
- Files: View contents
- Directories: List contents

**Write (w):**
- Files: Modify contents
- Directories: Create, delete, rename files

**Execute (x):**
- Files: Run as program
- Directories: Enter directory (cd)

### Permission Categories

Permissions are set for three categories:

**Owner (u):** The user who owns the file
**Group (g):** Users in the file's group
**Others (o):** Everyone else

### Understanding Permission Notation

**Symbolic notation:**
```
-rwxr-xr--
```

Breaking it down:
```
- rwx r-x r--
│ │   │   │
│ │   │   └─ Others: read only
│ │   └───── Group: read and execute
│ └───────── Owner: read, write, execute
└─────────── File type (- = file, d = directory, l = link)
```

**Numeric notation:**
```
754
```

Breaking it down:
- 7 (owner) = 4+2+1 = rwx
- 5 (group) = 4+1 = r-x
- 4 (others) = 4 = r--

**Permission values:**
- 4 = read (r)
- 2 = write (w)
- 1 = execute (x)
- 0 = no permission (-)

**Common permission combinations:**
- 7 = rwx (4+2+1)
- 6 = rw- (4+2)
- 5 = r-x (4+1)
- 4 = r-- (4)
- 0 = --- (0)

### chmod - Change File Permissions

**Numeric method:**
```bash
chmod 644 file.txt        # rw-r--r--
chmod 755 script.sh       # rwxr-xr-x
chmod 600 secret.txt      # rw-------
chmod 777 file.txt        # rwxrwxrwx (BAD - never use)
```

**Symbolic method:**
```bash
chmod u+x script.sh       # Add execute for owner
chmod g-w file.txt        # Remove write for group
chmod o+r file.txt        # Add read for others
chmod a+x script.sh       # Add execute for all (a=all)
chmod u=rw,g=r,o= file.txt  # Set exact permissions
```

**Explanation:**
- u = user (owner)
- g = group
- o = others
- a = all
- + = add permission
- - = remove permission
- = = set exact permission

**Recursive:**
```bash
chmod -R 755 directory/   # Apply to directory and all contents
```

### chown - Change File Owner

```bash
sudo chown john file.txt           # Change owner
sudo chown john:developers file.txt  # Change owner and group
sudo chown :developers file.txt    # Change group only
sudo chown -R john:developers dir/  # Recursive
```

**Explanation:**
- Format: `chown user:group file`
- Only root can change ownership
- Regular users can change group if they belong to it

### chgrp - Change Group Owner

```bash
sudo chgrp developers file.txt
sudo chgrp -R developers directory/
```

## Common Permission Patterns

### Web Application Files

```bash
# Application files
sudo chown -R appuser:www-data /var/www/myapp
sudo chmod -R 755 /var/www/myapp
sudo chmod -R 644 /var/www/myapp/*.txt

# Writable directories (uploads, cache)
sudo chmod -R 775 /var/www/myapp/storage
```

**Explanation:**
- Application owned by appuser
- www-data group can read (web server runs as www-data)
- Storage directory writable by both user and group

### Scripts

```bash
chmod 755 script.sh       # Owner can edit, everyone can execute
chmod 700 script.sh       # Only owner can read, write, execute
```

### Configuration Files

```bash
chmod 600 ~/.ssh/id_rsa   # SSH private key: owner only
chmod 644 /etc/nginx/nginx.conf  # Readable by all, writable by owner
```

### Log Files

```bash
chmod 640 /var/log/app.log      # Owner read/write, group read
sudo chown appuser:adm /var/log/app.log  # adm group can read logs
```

## Special Permissions

### SUID (Set User ID)

When set on executable, it runs with owner's permissions.

```bash
chmod u+s /usr/bin/program
chmod 4755 /usr/bin/program    # 4 = SUID bit
```

**Example:** passwd command
```bash
ls -l /usr/bin/passwd
# -rwsr-xr-x root root /usr/bin/passwd
```

passwd needs to modify /etc/shadow (root-only file), so it has SUID bit. When you run it, it executes as root even though you are not root.

**Security risk:** Be very careful with SUID programs.

### SGID (Set Group ID)

When set on directory, new files inherit directory's group.

```bash
chmod g+s /shared/directory
chmod 2775 /shared/directory   # 2 = SGID bit
```

**Use case:** Shared project directory where all files should belong to project group.

### Sticky Bit

Prevents users from deleting files they don't own.

```bash
chmod +t /tmp
chmod 1777 /tmp               # 1 = sticky bit
```

**Example:** /tmp directory
```bash
ls -ld /tmp
# drwxrwxrwt root root /tmp
```

Everyone can create files in /tmp, but users can only delete their own files.

## Sudo - Execute Commands as Root

sudo (superuser do) allows permitted users to execute commands as root.

### Configuration

sudo is configured in /etc/sudoers file.

**NEVER edit directly:** Use visudo
```bash
sudo visudo
```

visudo checks syntax before saving, preventing lockout from sudo access.

### Common sudo Patterns

```bash
sudo command              # Execute command as root
sudo -u john command      # Execute as user john
sudo -i                   # Interactive root shell
sudo su -                 # Switch to root user
sudo !!                   # Run previous command with sudo
```

### Passwordless sudo (Use Carefully)

Edit with `sudo visudo`:
```
john ALL=(ALL) NOPASSWD: ALL
```

**Use case:** Automation scripts, CI/CD pipelines

**Security risk:** User can do anything without password

**Better approach:** Allow specific commands only
```
john ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
```

### Viewing sudo Permissions

```bash
sudo -l                   # List allowed commands for current user
```

## DevOps Real-World Scenarios

### Scenario 1: Setting Up Application User

```bash
# Create application user (no login)
sudo useradd -r -s /bin/false appuser

# Create application directory
sudo mkdir -p /opt/myapp

# Set ownership
sudo chown -R appuser:appuser /opt/myapp

# Set permissions
sudo chmod -R 755 /opt/myapp
```

**Explanation:**
- `-r` creates system user
- `-s /bin/false` prevents login
- Application runs as appuser, not root (security)

### Scenario 2: Shared Development Environment

```bash
# Create developers group
sudo groupadd developers

# Add users to group
sudo usermod -aG developers alice
sudo usermod -aG developers bob

# Create shared directory
sudo mkdir /shared/project

# Set ownership
sudo chown root:developers /shared/project

# Set permissions with SGID
sudo chmod 2775 /shared/project
```

**Result:**
- All developers can read, write, execute
- New files automatically belong to developers group
- Collaboration without permission issues

### Scenario 3: CI/CD User

```bash
# Create CI user
sudo useradd -m -s /bin/bash ciuser

# Add to docker group (run containers)
sudo usermod -aG docker ciuser

# Allow specific sudo commands without password
sudo visudo
# Add line:
# ciuser ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart myapp
```

**Use case:** Jenkins or GitLab Runner needs to deploy applications.

## Security Best Practices

### 1. Principle of Least Privilege

Give users only the permissions they need.

**Bad:**
```bash
chmod 777 file.txt        # Everyone can do everything
```

**Good:**
```bash
chmod 644 file.txt        # Owner can write, others read only
```

### 2. Never Run Services as Root

Always create dedicated service users.

**Bad:**
```bash
sudo ./webapp.sh          # Running as root
```

**Good:**
```bash
sudo -u appuser ./webapp.sh   # Running as appuser
```

### 3. Regularly Audit Permissions

```bash
# Find world-writable files (security risk)
find / -type f -perm -002 2>/dev/null

# Find files with SUID bit
find / -type f -perm -4000 2>/dev/null
```

### 4. Remove Unused Accounts

```bash
# List all users
cat /etc/passwd

# Remove unused accounts
sudo userdel -r olduser
```

### 5. Strong Passwords

```bash
# Install password quality checking
sudo apt install libpam-pwquality

# Configure in /etc/security/pwquality.conf
```

## Troubleshooting Permission Issues

### "Permission Denied" Errors

**Check file permissions:**
```bash
ls -l file.txt
```

**Check your user and groups:**
```bash
id
```

**Check if you need to be in a specific group:**
```bash
groups
```

**Solution examples:**
```bash
# Add yourself to group
sudo usermod -aG groupname $USER
# Logout and login for changes to take effect

# Or fix file permissions
sudo chmod 644 file.txt
sudo chown $USER:$USER file.txt
```

### Cannot Write to Directory

```bash
# Check directory permissions
ls -ld /path/to/directory

# Make directory writable
sudo chmod 775 /path/to/directory
```

### Script Not Executing

```bash
# Check execute permission
ls -l script.sh

# Add execute permission
chmod +x script.sh
```

## Practice Exercises

1. Create three users: developer1, developer2, tester1
2. Create group "dev-team" and add developer1, developer2
3. Create directory /shared/devproject
4. Set permissions so dev-team can collaborate
5. tester1 should only read, not write
6. Create a script that only root can execute
7. Find all files owned by a specific user
8. Change ownership of directory recursively

## Next Steps

Master these concepts before moving forward. Permission management is fundamental to system security and proper DevOps practices.

Next: `03-process-management.md` to learn how to manage running programs.
