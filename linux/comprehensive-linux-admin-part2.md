# Comprehensive Linux Administration Guide - Part 2

## Table of Contents
1. [User and Group Management](#user-and-group-management)
2. [Network Configuration and Management](#network-configuration-and-management)
3. [System Services and Systemd](#system-services-and-systemd)
4. [Storage Management](#storage-management)
5. [Security and Firewall](#security-and-firewall)
6. [System Backup and Recovery](#system-backup-and-recovery)
7. [Cron Jobs and Task Scheduling](#cron-jobs-and-task-scheduling)
8. [System Performance Tuning](#system-performance-tuning)
9. [Kernel and Module Management](#kernel-and-module-management)
10. [Troubleshooting and Diagnostics](#troubleshooting-and-diagnostics)

## User and Group Management

### User Account Management

```bash
# Create users
useradd username                    # Create user with defaults
useradd -m username                 # Create user with home directory
useradd -m -s /bin/bash username    # Specify shell
useradd -m -g groupname username    # Specify primary group
useradd -m -G group1,group2 username # Add to additional groups
useradd -m -c "Full Name" username  # Add comment (full name)
useradd -m -e 2025-12-31 username   # Set expiration date

# Modify users
usermod -aG groupname username      # Add user to group
usermod -s /bin/zsh username        # Change shell
usermod -d /new/home username       # Change home directory
usermod -l newname oldname          # Rename user
usermod -L username                 # Lock account
usermod -U username                 # Unlock account
usermod -e 2025-12-31 username      # Set expiration date

# Delete users
userdel username                    # Delete user (keep home directory)
userdel -r username                 # Delete user and home directory
userdel -f username                 # Force deletion

# Password management
passwd username                     # Set/change password
passwd -l username                  # Lock password
passwd -u username                  # Unlock password
passwd -d username                  # Delete password
passwd -e username                  # Force password change on next login
echo "newpassword" | passwd --stdin username  # Set password non-interactively

# User information
id username                         # Show user and group IDs
whoami                             # Show current username
who                                # Show logged-in users
w                                  # Show who is logged on and what they're doing
last                               # Show login history
lastlog                            # Show last login for all users
finger username                    # Show user information (if available)

# Switch users
su username                        # Switch to user (requires password)
su - username                      # Switch with environment
sudo -u username command           # Run command as user
sudo -i                           # Switch to root with environment
sudo -s                           # Switch to root shell
```

### Group Management

```bash
# Create groups
groupadd groupname                 # Create group
groupadd -g 1001 groupname         # Create group with specific GID

# Modify groups
groupmod -n newname oldname        # Rename group
groupmod -g 1002 groupname         # Change GID

# Delete groups
groupdel groupname                 # Delete group

# Group membership
groups username                    # Show user's groups
newgrp groupname                   # Switch to group
gpasswd -a username groupname      # Add user to group
gpasswd -d username groupname      # Remove user from group
gpasswd -A username groupname      # Make user group administrator

# View group information
getent group                       # List all groups
getent group groupname             # Show specific group
cat /etc/group                     # View group file directly
```

### User and Group Files

```bash
# Important files
/etc/passwd                        # User account information
/etc/shadow                        # Encrypted passwords
/etc/group                         # Group information
/etc/gshadow                       # Group passwords
/etc/skel/                         # Default user files

# File formats
# /etc/passwd: username:x:UID:GID:comment:home:shell
# /etc/shadow: username:password:lastchange:min:max:warn:inactive:expire:flag
# /etc/group: groupname:x:GID:members

# Check file integrity
pwck                               # Check /etc/passwd integrity
grpck                              # Check /etc/group integrity
```

### Sudo Configuration

```bash
# Edit sudoers file
visudo                             # Safely edit /etc/sudoers

# Sudoers file syntax examples
# User privilege specification
username ALL=(ALL:ALL) ALL         # Full sudo access
username ALL=(ALL) NOPASSWD: ALL   # No password required

# Group privileges
%sudo ALL=(ALL:ALL) ALL            # Sudo group full access
%wheel ALL=(ALL) ALL               # Wheel group access

# Command aliases
Cmnd_Alias NETWORKING = /sbin/route, /sbin/ifconfig, /bin/ping
username ALL = NETWORKING          # Allow specific commands

# Host aliases
Host_Alias FILESERVERS = fs1, fs2, fs3
username FILESERVERS = /usr/bin/cp # Commands on specific hosts

# User-specific sudoers files
/etc/sudoers.d/username            # Individual user sudo rules

# Check sudo configuration
sudo -l                            # List sudo privileges for current user
sudo -l -U username                # List privileges for specific user
```

## Network Configuration and Management

### Network Interface Configuration

```bash
# View network interfaces
ip addr show                       # Show all interfaces (modern)
ip a                              # Short form
ifconfig                          # Show interfaces (traditional)
ifconfig -a                       # Show all interfaces including down

# Configure interfaces with ip command
ip addr add 192.168.1.100/24 dev eth0    # Add IP address
ip addr del 192.168.1.100/24 dev eth0    # Remove IP address
ip link set eth0 up                       # Bring interface up
ip link set eth0 down                     # Bring interface down
ip link set eth0 mtu 1500                 # Set MTU

# Configure with ifconfig (traditional)
ifconfig eth0 192.168.1.100 netmask 255.255.255.0  # Set IP and netmask
ifconfig eth0 up                          # Bring interface up
ifconfig eth0 down                        # Bring interface down

# Network configuration files
# Ubuntu/Debian - Netplan (newer)
/etc/netplan/*.yaml

# Example netplan configuration
cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.1.100/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

# Apply netplan configuration
netplan try                        # Test configuration
netplan apply                      # Apply configuration

# Ubuntu/Debian - Traditional interfaces file
/etc/network/interfaces

# Example interfaces configuration
auto eth0
iface eth0 inet static
address 192.168.1.100
netmask 255.255.255.0
gateway 192.168.1.1
dns-nameservers 8.8.8.8 8.8.4.4

# CentOS/RHEL network configuration
/etc/sysconfig/network-scripts/ifcfg-eth0

# Example ifcfg-eth0
TYPE=Ethernet
BOOTPROTO=static
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
ONBOOT=yes
```

### Routing Configuration

```bash
# View routing table
ip route show                      # Show routing table (modern)
ip r                              # Short form
route -n                          # Show routing table (traditional)
netstat -rn                       # Show routing table

# Add/remove routes
ip route add 192.168.2.0/24 via 192.168.1.1    # Add route
ip route del 192.168.2.0/24                     # Delete route
ip route add default via 192.168.1.1            # Add default gateway
route add -net 192.168.2.0/24 gw 192.168.1.1   # Traditional syntax

# Persistent routes
# Ubuntu/Debian - in netplan or interfaces file
# CentOS/RHEL - create route files
echo "192.168.2.0/24 via 192.168.1.1" > /etc/sysconfig/network-scripts/route-eth0
```

### DNS Configuration

```bash
# DNS configuration file
/etc/resolv.conf

# Example resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com
domain example.com

# DNS testing
nslookup hostname                  # Query DNS
dig hostname                      # DNS lookup utility
host hostname                     # DNS lookup

# Local DNS resolution
/etc/hosts                        # Local hostname resolution

# Example hosts file entries
127.0.0.1 localhost
192.168.1.100 server1.example.com server1
```

### Network Diagnostic Tools

```bash
# Connectivity testing
ping hostname                     # Test connectivity
ping -c 4 hostname               # Send 4 packets
ping6 hostname                   # IPv6 ping
traceroute hostname              # Trace route to destination
tracepath hostname               # Similar to traceroute
mtr hostname                     # Combined ping and traceroute

# Port scanning and testing
nmap hostname                    # Port scan
nmap -p 22,80,443 hostname      # Scan specific ports
telnet hostname port            # Test port connectivity
nc -zv hostname port            # Test port with netcat

# Network statistics
netstat -tuln                   # Show listening ports
netstat -an                     # Show all connections
ss -tuln                        # Modern replacement for netstat
ss -an                          # Show all sockets
lsof -i                         # Show network connections
lsof -i :80                     # Show connections on port 80

# Bandwidth monitoring
iftop                           # Interface bandwidth usage
nethogs                         # Process network usage
vnstat                          # Network statistics
tcpdump -i eth0                 # Packet capture
wireshark                       # GUI packet analyzer
```

### Wireless Configuration

```bash
# Wireless tools
iwconfig                        # Configure wireless interface
iwlist scan                     # Scan for wireless networks
iw dev                          # Show wireless devices
iw dev wlan0 scan              # Scan with specific interface

# WPA supplicant configuration
/etc/wpa_supplicant/wpa_supplicant.conf

# Example WPA configuration
network={
    ssid="NetworkName"
    psk="password"
}

# Connect to wireless network
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
dhclient wlan0                  # Get IP address
```

## System Services and Systemd

### Systemd Service Management

```bash
# Service control
systemctl start service_name     # Start service
systemctl stop service_name      # Stop service
systemctl restart service_name   # Restart service
systemctl reload service_name    # Reload configuration
systemctl enable service_name    # Enable at boot
systemctl disable service_name   # Disable at boot
systemctl mask service_name      # Prevent service from starting
systemctl unmask service_name    # Remove mask

# Service status
systemctl status service_name    # Show service status
systemctl is-active service_name # Check if service is running
systemctl is-enabled service_name # Check if service is enabled
systemctl is-failed service_name # Check if service failed

# List services
systemctl list-units            # List all units
systemctl list-units --type=service # List services only
systemctl list-units --state=failed # List failed units
systemctl list-unit-files       # List unit files
systemctl list-dependencies service_name # Show dependencies
```

### Creating Custom Services

```bash
# Service file location
/etc/systemd/system/myservice.service

# Example service file
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/start.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target

# Service file types
Type=simple         # Default, process doesn't fork
Type=forking       # Process forks and parent exits
Type=oneshot       # Process exits after completion
Type=notify        # Service sends notification when ready
Type=dbus          # Service acquires D-Bus name

# Reload systemd after changes
systemctl daemon-reload

# Enable and start custom service
systemctl enable myservice
systemctl start myservice
```

### System Targets (Runlevels)

```bash
# View current target
systemctl get-default           # Show default target
systemctl list-units --type=target # List available targets

# Change targets
systemctl isolate multi-user.target    # Switch to multi-user
systemctl isolate graphical.target     # Switch to graphical
systemctl isolate rescue.target        # Switch to rescue mode

# Set default target
systemctl set-default multi-user.target
systemctl set-default graphical.target

# Common targets
poweroff.target        # Shutdown
rescue.target          # Single-user mode
multi-user.target      # Multi-user, no GUI
graphical.target       # Multi-user with GUI
reboot.target          # Restart system
```

### System Logs with Journald

```bash
# View logs
journalctl                      # View all logs
journalctl -f                   # Follow logs (tail -f)
journalctl -n 50                # Show last 50 entries
journalctl --since "1 hour ago" # Recent logs
journalctl --since "2023-01-01" # Logs since date
journalctl --until "2023-12-31" # Logs until date

# Service-specific logs
journalctl -u service_name      # Logs for specific service
journalctl -u service_name -f   # Follow service logs
journalctl -u service_name --since today # Today's logs

# Log levels
journalctl -p err               # Error messages only
journalctl -p warning           # Warning and above
journalctl -p info              # Info and above

# Boot logs
journalctl -b                   # Current boot
journalctl -b -1                # Previous boot
journalctl --list-boots         # List all boots

# Log maintenance
journalctl --disk-usage         # Show disk usage
journalctl --vacuum-time=2weeks # Keep last 2 weeks
journalctl --vacuum-size=100M   # Keep last 100MB
```

### Timer Units (Systemd Cron Alternative)

```bash
# Timer unit file
/etc/systemd/system/mytimer.timer

# Example timer
[Unit]
Description=Run my script every hour

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target

# Corresponding service file
/etc/systemd/system/mytimer.service

[Unit]
Description=My hourly script

[Service]
Type=oneshot
ExecStart=/usr/local/bin/myscript.sh

# Enable and start timer
systemctl enable mytimer.timer
systemctl start mytimer.timer

# Timer management
systemctl list-timers           # List active timers
systemctl status mytimer.timer  # Timer status
```

## Storage Management

### Disk and Partition Management

```bash
# List block devices
lsblk                           # Tree view of block devices
lsblk -f                        # Include filesystem information
blkid                           # Show UUIDs and filesystem types
fdisk -l                        # List all partitions

# Partition management with fdisk
fdisk /dev/sda                  # Open disk for partitioning
# Commands within fdisk:
# p - print partition table
# n - new partition
# d - delete partition
# t - change partition type
# w - write changes
# q - quit without saving

# Partition management with parted
parted /dev/sda                 # Open with parted
parted /dev/sda print           # Print partition table
parted /dev/sda mklabel gpt     # Create GPT partition table
parted /dev/sda mkpart primary ext4 0% 100% # Create partition

# Advanced partitioning with gdisk (GPT)
gdisk /dev/sda                  # GPT partitioning tool
```

### Filesystem Management

```bash
# Create filesystems
mkfs.ext4 /dev/sda1             # Create ext4 filesystem
mkfs.xfs /dev/sda1              # Create XFS filesystem
mkfs.btrfs /dev/sda1            # Create Btrfs filesystem
mkfs.ntfs /dev/sda1             # Create NTFS filesystem

# Filesystem with options
mkfs.ext4 -L "MyLabel" /dev/sda1 # Create with label
mkfs.ext4 -b 4096 /dev/sda1     # Specify block size
mkfs.ext4 -m 1 /dev/sda1        # Reserve 1% for root

# Check and repair filesystems
fsck /dev/sda1                  # Check filesystem
fsck.ext4 /dev/sda1             # Check ext4 filesystem
fsck -f /dev/sda1               # Force check
e2fsck /dev/sda1                # Check ext2/3/4 filesystem
xfs_repair /dev/sda1            # Repair XFS filesystem

# Filesystem information
tune2fs -l /dev/sda1            # Show ext2/3/4 information
xfs_info /dev/sda1              # Show XFS information
dumpe2fs /dev/sda1              # Detailed ext2/3/4 info
```

### Mount Operations

```bash
# Mount filesystems
mount /dev/sda1 /mnt            # Mount to /mnt
mount -t ext4 /dev/sda1 /mnt    # Specify filesystem type
mount -o ro /dev/sda1 /mnt      # Mount read-only
mount -o rw,noexec /dev/sda1 /mnt # Mount with options

# Common mount options
rw / ro                         # Read-write / read-only
noexec                          # Prevent execution
nosuid                          # Ignore SUID bits
nodev                           # No device files
sync / async                    # Synchronous / asynchronous I/O
atime / noatime                 # Update / don't update access times

# Unmount filesystems
umount /mnt                     # Unmount by mount point
umount /dev/sda1                # Unmount by device
umount -l /mnt                  # Lazy unmount
umount -f /mnt                  # Force unmount

# Show mounted filesystems
mount                           # Show all mounted filesystems
mount | grep ext4               # Show ext4 filesystems only
df                              # Show mounted filesystems with usage
findmnt                         # Tree view of mounted filesystems
```

### Persistent Mounts (fstab)

```bash
# Edit fstab
/etc/fstab

# fstab format
# device mount_point filesystem options dump pass
/dev/sda1 /home ext4 defaults 0 2
UUID=xxx-xxx /var ext4 defaults,noatime 0 2
/dev/sda2 none swap sw 0 0
tmpfs /tmp tmpfs defaults,nodev,nosuid 0 0

# Common options
defaults                        # rw,suid,dev,exec,auto,nouser,async
auto / noauto                   # Mount / don't mount at boot
user / nouser                   # Allow / disallow user mounts
exec / noexec                   # Allow / prevent execution
suid / nosuid                   # Allow / ignore SUID

# Test fstab entries
mount -a                        # Mount all entries in fstab
mount /home                     # Mount specific entry from fstab
```

### LVM (Logical Volume Management)

```bash
# Physical Volume management
pvcreate /dev/sda1              # Create physical volume
pvdisplay                       # Show physical volumes
pvs                             # Brief PV information
pvremove /dev/sda1              # Remove physical volume

# Volume Group management
vgcreate vg01 /dev/sda1         # Create volume group
vgextend vg01 /dev/sdb1         # Add PV to VG
vgdisplay                       # Show volume groups
vgs                             # Brief VG information
vgremove vg01                   # Remove volume group

# Logical Volume management
lvcreate -L 10G -n lv01 vg01    # Create 10GB logical volume
lvcreate -l 100%FREE -n lv02 vg01 # Use all available space
lvextend -L +5G /dev/vg01/lv01  # Extend logical volume
lvreduce -L -2G /dev/vg01/lv01  # Reduce logical volume
lvdisplay                       # Show logical volumes
lvs                             # Brief LV information
lvremove /dev/vg01/lv01         # Remove logical volume

# Resize filesystem after LV changes
resize2fs /dev/vg01/lv01        # Resize ext2/3/4 filesystem
xfs_growfs /mount/point         # Grow XFS filesystem
```

### RAID Configuration

```bash
# Software RAID with mdadm
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sda1 /dev/sdb1
mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sda1 /dev/sdb1 /dev/sdc1

# RAID information
cat /proc/mdstat                # Show RAID status
mdadm --detail /dev/md0         # Detailed RAID information
mdadm --query /dev/md0          # Query RAID array

# RAID management
mdadm --manage /dev/md0 --add /dev/sdd1    # Add device to array
mdadm --manage /dev/md0 --fail /dev/sdb1   # Mark device as failed
mdadm --manage /dev/md0 --remove /dev/sdb1 # Remove device from array

# Save RAID configuration
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
```

### Swap Management

```bash
# Create swap file
dd if=/dev/zero of=/swapfile bs=1M count=1024  # Create 1GB file
chmod 600 /swapfile             # Set proper permissions
mkswap /swapfile                # Format as swap
swapon /swapfile                # Enable swap

# Create swap partition
mkswap /dev/sda2                # Format partition as swap
swapon /dev/sda2                # Enable swap partition

# Swap information
swapon --show                   # Show swap usage
free -h                         # Show memory and swap usage
cat /proc/swaps                 # Show swap devices

# Disable swap
swapoff /swapfile               # Disable specific swap
swapoff -a                      # Disable all swap

# Persistent swap in fstab
/swapfile none swap sw 0 0
```

## Security and Firewall

### UFW (Uncomplicated Firewall) - Ubuntu/Debian

```bash
# Enable/disable UFW
ufw enable                      # Enable firewall
ufw disable                     # Disable firewall
ufw status                      # Show firewall status
ufw status verbose              # Detailed status
ufw status numbered             # Show rule numbers

# Basic rules
ufw allow 22                    # Allow SSH
ufw allow ssh                   # Allow SSH by name
ufw allow 80/tcp                # Allow HTTP
ufw allow 443/tcp               # Allow HTTPS
ufw deny 23                     # Deny telnet

# Advanced rules
ufw allow from 192.168.1.0/24   # Allow from subnet
ufw allow from 192.168.1.100 to any port 22  # Specific source
ufw allow out 53                # Allow outgoing DNS
ufw limit ssh                   # Rate limit SSH

# Delete rules
ufw delete allow 80             # Delete rule
ufw delete 1                    # Delete by rule number
ufw reset                       # Reset to defaults
```

### Firewalld - CentOS/RHEL/Fedora

```bash
# Firewalld service
systemctl start firewalld       # Start firewalld
systemctl enable firewalld      # Enable at boot
firewall-cmd --state            # Check firewall state

# Zones
firewall-cmd --get-zones        # List available zones
firewall-cmd --get-default-zone # Show default zone
firewall-cmd --set-default-zone=public # Set default zone
firewall-cmd --get-active-zones # Show active zones

# Services and ports
firewall-cmd --list-all         # Show current configuration
firewall-cmd --list-services    # List allowed services
firewall-cmd --add-service=http # Allow HTTP
firewall-cmd --add-port=8080/tcp # Allow port 8080
firewall-cmd --remove-service=http # Remove HTTP
firewall-cmd --remove-port=8080/tcp # Remove port

# Permanent rules
firewall-cmd --permanent --add-service=https # Permanent rule
firewall-cmd --reload           # Reload configuration

# Rich rules
firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" accept'
firewall-cmd --add-rich-rule='rule service name="ssh" accept'
```

### IPTables (Advanced Firewall)

```bash
# View rules
iptables -L                     # List rules
iptables -L -n                  # List with numbers
iptables -L -v                  # Verbose output
iptables -t nat -L              # List NAT table

# Basic rules
iptables -A INPUT -p tcp --dport 22 -j ACCEPT    # Allow SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT    # Allow HTTP
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT # Allow established connections
iptables -A INPUT -j DROP       # Drop everything else

# Delete rules
iptables -D INPUT 1             # Delete rule 1
iptables -F                     # Flush all rules
iptables -F INPUT               # Flush INPUT chain

# Save/restore rules
iptables-save > /etc/iptables/rules.v4
iptables-restore < /etc/iptables/rules.v4

# Complex rules
iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT  # Source-based
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT  # Rate limiting
```

### SSH Security

```bash
# SSH configuration
/etc/ssh/sshd_config

# Important SSH settings
Port 2222                       # Change default port
PermitRootLogin no             # Disable root login
PasswordAuthentication no      # Disable password auth
PubkeyAuthentication yes       # Enable key-based auth
AllowUsers user1 user2         # Allow specific users
DenyUsers baduser              # Deny specific users
ClientAliveInterval 300        # Keep connections alive
MaxAuthTries 3                 # Limit auth attempts

# SSH key management
ssh-keygen -t rsa -b 4096      # Generate RSA key pair
ssh-keygen -t ed25519          # Generate Ed25519 key pair
ssh-copy-id user@host          # Copy public key to remote host
ssh-add ~/.ssh/id_rsa          # Add key to SSH agent

# SSH client configuration
~/.ssh/config

# Example SSH client config
Host server1
    HostName 192.168.1.100
    User admin
    IdentityFile ~/.ssh/server1_key
    Port 2222
    StrictHostKeyChecking no

# Restart SSH service
systemctl restart sshd         # Systemd
service ssh restart            # SysV init
```

### File and Directory Security

```bash
# File attributes
chattr +i file                 # Make file immutable
chattr -i file                 # Remove immutable attribute
chattr +a file                 # Append-only file
lsattr file                    # List file attributes

# Find security issues
find / -perm -4000 -type f     # Find SUID files
find / -perm -2000 -type f     # Find SGID files
find / -perm -001 -type f      # Find world-writable files
find / -nouser -o -nogroup     # Find files without owner

# File integrity monitoring
aide --init                    # Initialize AIDE database
aide --check                   # Check for changes
tripwire --init               # Initialize Tripwire
```

### SELinux (Security-Enhanced Linux)

```bash
# SELinux status
getenforce                     # Show current mode
sestatus                       # Detailed SELinux status

# SELinux modes
setenforce 0                   # Set to permissive
setenforce 1                   # Set to enforcing

# Permanent mode change
/etc/selinux/config
SELINUX=enforcing              # enforcing, permissive, disabled

# SELinux contexts
ls -Z file                     # Show SELinux context
ps -Z                          # Show process contexts
id -Z                          # Show user context

# Change contexts
chcon -t httpd_exec_t /usr/bin/httpd  # Change file context
restorecon /var/www/html       # Restore default context
setsebool httpd_can_network_connect on  # Set boolean

# SELinux policies
getsebool -a                   # List all booleans
semanage fcontext -l           # List file contexts
semanage port -l               # List port contexts

# Troubleshooting
sealert -a /var/log/audit/audit.log  # Analyze denials
audit2allow -a                 # Generate policy rules
```

This completes Part 2 of the Linux Administration Guide, covering user management, networking, services, storage, and security configurations.
