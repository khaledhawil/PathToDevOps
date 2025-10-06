# Process Management

## What is a Process?

A process is a running instance of a program. When you execute a command or application, Linux creates a process.

### Process vs Program

**Program:** Executable file stored on disk (e.g., /usr/bin/python3)
**Process:** Program loaded into memory and executing

**Example:**
You can run multiple Firefox windows. Each is a separate process of the same program.

## Why Process Management Matters in DevOps

**Service Management:** Web servers, databases, applications run as processes
**Resource Monitoring:** Track CPU, memory usage per process
**Troubleshooting:** Identify which process is causing issues
**Automation:** Start, stop, restart services automatically
**Scaling:** Manage multiple instances of applications
**Security:** Kill compromised or misbehaving processes

## Process Hierarchy

### Parent and Child Processes

Every process (except init) has a parent process.

**Process Tree Example:**
```
systemd (PID 1)
├── sshd (PID 1234)
│   └── bash (PID 5678)
│       └── python app.py (PID 9012)
└── nginx (PID 2345)
    ├── nginx worker (PID 3456)
    └── nginx worker (PID 3457)
```

**Key Concepts:**
- **PID (Process ID):** Unique number identifying each process
- **PPID (Parent Process ID):** PID of parent process
- **init/systemd:** First process (PID 1), parent of all processes
- **Orphan Process:** Parent dies, adopted by init
- **Zombie Process:** Finished but parent hasn't collected exit status

## Viewing Processes

### ps - Process Status

**Basic usage:**
```bash
ps                        # Processes in current shell
ps aux                    # All processes, detailed
ps -ef                    # All processes, full format
```

**ps aux output explained:**
```
USER  PID  %CPU %MEM    VSZ   RSS TTY   STAT START   TIME COMMAND
john  1234  0.5  2.3  12345  6789 pts/0 S    10:30   0:05 python app.py
```

**Columns:**
- **USER:** Process owner
- **PID:** Process ID
- **%CPU:** CPU usage percentage
- **%MEM:** Memory usage percentage
- **VSZ:** Virtual memory size (KB)
- **RSS:** Resident set size - actual RAM used (KB)
- **TTY:** Terminal (pts/0 = pseudo-terminal, ? = no terminal)
- **STAT:** Process state (explained below)
- **START:** When process started
- **TIME:** CPU time consumed
- **COMMAND:** Command that started the process

**Process States (STAT):**
- **R:** Running or runnable
- **S:** Sleeping (waiting for event)
- **D:** Uninterruptible sleep (usually I/O)
- **T:** Stopped (suspended)
- **Z:** Zombie (finished but not reaped)
- **<:** High priority
- **N:** Low priority
- **s:** Session leader
- **+:** Foreground process group

**Useful ps commands:**
```bash
ps aux | grep nginx       # Find nginx processes
ps aux | grep -v grep     # Exclude grep itself
ps aux --sort=-%mem       # Sort by memory usage
ps aux --sort=-%cpu       # Sort by CPU usage
ps -u john                # Processes owned by john
ps -p 1234                # Specific process by PID
```

### top - Dynamic Process View

Real-time process monitoring.

```bash
top
```

**Top screen sections:**

**Header:**
```
top - 14:30:25 up 5 days,  3:20,  2 users,  load average: 0.15, 0.10, 0.08
Tasks: 245 total,   1 running, 244 sleeping,   0 stopped,   0 zombie
%Cpu(s):  5.2 us,  1.8 sy,  0.0 ni, 92.7 id,  0.3 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   7976.0 total,   2134.5 free,   3421.2 used,   2420.3 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   4123.4 avail Mem
```

**Explanation:**
- **Load average:** Average number of processes waiting for CPU (1, 5, 15 minute averages)
- **Tasks:** Total processes and their states
- **CPU usage:** us (user), sy (system), id (idle), wa (I/O wait)
- **Memory:** Total, free, used, buffer/cache

**Interactive commands in top:**
- **h:** Help
- **k:** Kill process (prompts for PID)
- **r:** Renice process (change priority)
- **M:** Sort by memory usage
- **P:** Sort by CPU usage
- **q:** Quit
- **1:** Show individual CPU cores
- **u:** Filter by user

**Better alternative - htop:**
```bash
sudo apt install htop
htop
```

More user-friendly, colored output, mouse support.

### pstree - Process Tree View

Visual representation of process hierarchy.

```bash
pstree                    # Show process tree
pstree -p                 # Show PIDs
pstree -u                 # Show users
pstree -a                 # Show command line arguments
pstree 1234               # Tree for specific PID
```

**Example output:**
```
systemd─┬─sshd───sshd───bash───python
        ├─nginx─┬─nginx
        │       └─nginx
        └─docker─┬─containerd
                 └─containerd-shim───app
```

## Controlling Processes

### Foreground vs Background

**Foreground:** Process attached to terminal, receives input
**Background:** Process runs independently, terminal free

**Running in background:**
```bash
command &                 # Start in background
python app.py &
```

**Moving to background:**
```bash
command                   # Start normally
# Press Ctrl+Z to suspend
bg                        # Resume in background
```

**Bringing to foreground:**
```bash
fg                        # Bring last background job to foreground
fg %1                     # Bring job 1 to foreground
```

**List background jobs:**
```bash
jobs                      # List jobs in current shell
jobs -l                   # Show PIDs
```

### nohup - Run After Logout

Normally, processes die when you logout. nohup prevents this.

```bash
nohup command &
nohup python app.py &
```

**What it does:**
- Ignores HUP (hangup) signal
- Output redirected to nohup.out
- Process survives logout

**Better for DevOps:** Use systemd services instead of nohup.

### Process Signals

Signals are software interrupts sent to processes.

**Common signals:**
- **SIGTERM (15):** Graceful termination (default)
- **SIGKILL (9):** Force kill (cannot be caught)
- **SIGHUP (1):** Hangup (often reloads config)
- **SIGINT (2):** Interrupt (Ctrl+C)
- **SIGSTOP (19):** Stop process (cannot be caught)
- **SIGCONT (18):** Continue if stopped
- **SIGUSR1/SIGUSR2:** User-defined signals

### kill - Send Signals to Processes

```bash
kill PID                  # Send SIGTERM (graceful)
kill -9 PID               # Send SIGKILL (force)
kill -15 PID              # Send SIGTERM (explicit)
kill -HUP PID             # Send SIGHUP (reload config)
kill -l                   # List all signals
```

**Example:**
```bash
# Find process
ps aux | grep nginx

# Kill gracefully (application can cleanup)
kill 1234

# If not responding, force kill
kill -9 1234
```

**Difference between SIGTERM and SIGKILL:**
- **SIGTERM:** Process can catch signal, cleanup, save state, then exit
- **SIGKILL:** Immediate termination, no cleanup, data may be lost

**Best practice:** Always try SIGTERM first, use SIGKILL only if necessary.

### killall - Kill by Name

```bash
killall nginx             # Kill all nginx processes
killall -9 python         # Force kill all python processes
killall -u john           # Kill all processes owned by john
```

**Warning:** Be careful, kills ALL processes matching name.

### pkill - Kill by Pattern

More flexible than killall.

```bash
pkill nginx               # Kill processes containing "nginx"
pkill -u john python      # Kill john's python processes
pkill -f "python app.py"  # Kill by full command line
```

**Difference:**
- **killall:** Exact name match
- **pkill:** Pattern matching

### pgrep - Find Process IDs by Pattern

```bash
pgrep nginx               # Find nginx PIDs
pgrep -u john             # Find john's process PIDs
pgrep -f "python app.py"  # Find by full command line
pgrep -l nginx            # Show PID and name
```

**Useful in scripts:**
```bash
if pgrep nginx > /dev/null; then
    echo "Nginx is running"
else
    echo "Nginx is not running"
fi
```

## Process Priority and Nice Values

### Understanding Priority

Linux uses priority to decide which process gets CPU time.

**Nice values:** -20 (highest priority) to +19 (lowest priority)
**Default:** 0 (normal priority)

**Only root can:**
- Set negative nice values (higher priority)
- Increase priority of existing processes

### nice - Start Process with Priority

```bash
nice command              # Default nice value (10)
nice -n 10 command        # Nice value 10
nice -n -5 command        # Nice value -5 (requires root)
sudo nice -n -10 command  # High priority
```

**Example:**
```bash
nice -n 19 ./backup.sh    # Low priority backup (doesn't slow system)
sudo nice -n -10 ./critical-app.sh  # High priority
```

### renice - Change Running Process Priority

```bash
renice 10 -p PID          # Set nice value for PID
renice -n 5 -p PID        # Alternative syntax
renice 10 -u john         # All john's processes
```

**Example:**
```bash
# Find process using too much CPU
top

# Lower its priority
sudo renice 15 -p 1234
```

## Systemd - Service Management

Systemd is the init system and service manager for modern Linux distributions.

### Why Systemd?

**Old way (init scripts):**
- Complex shell scripts in /etc/init.d/
- Hard to manage dependencies
- No automatic restart
- Slow boot times

**Systemd advantages:**
- Parallel service startup (faster boot)
- Automatic restart on failure
- Dependency management
- Logging with journald
- Socket and timer activation

### systemctl - Control Systemd

**Service operations:**
```bash
sudo systemctl start nginx          # Start service
sudo systemctl stop nginx           # Stop service
sudo systemctl restart nginx        # Stop then start
sudo systemctl reload nginx         # Reload config without restart
sudo systemctl status nginx         # Show service status
sudo systemctl enable nginx         # Start on boot
sudo systemctl disable nginx        # Don't start on boot
sudo systemctl is-active nginx      # Check if running
sudo systemctl is-enabled nginx     # Check if enabled
```

**System operations:**
```bash
systemctl list-units                # List loaded units
systemctl list-units --type=service # List only services
systemctl list-unit-files           # List all unit files
systemctl daemon-reload             # Reload systemd config
```

**Example status output:**
```bash
sudo systemctl status nginx
```

```
● nginx.service - A high performance web server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-01-15 10:30:45 UTC; 2h 15min ago
   Main PID: 1234 (nginx)
      Tasks: 3 (limit: 4915)
     Memory: 15.2M
        CPU: 1.234s
     CGroup: /system.slice/nginx.service
             ├─1234 nginx: master process /usr/sbin/nginx
             ├─1235 nginx: worker process
             └─1236 nginx: worker process
```

**Explanation:**
- **Loaded:** Service file location and whether enabled on boot
- **Active:** Current state (running, stopped, failed)
- **Main PID:** Primary process ID
- **Tasks:** Number of processes/threads
- **Memory/CPU:** Resource usage
- **CGroup:** Process control group (containment)

### Creating a Custom Service

**Service file location:** /etc/systemd/system/myapp.service

**Example service file:**
```ini
[Unit]
Description=My Python Web Application
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/python3 /opt/myapp/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Section explanations:**

**[Unit]:**
- **Description:** Human-readable description
- **After:** Start after network is ready
- **Requires:** Hard dependency
- **Wants:** Soft dependency

**[Service]:**
- **Type:** Service type (simple, forking, oneshot, notify, dbus)
- **User:** Run as this user (not root)
- **WorkingDirectory:** Directory to run from
- **ExecStart:** Command to start service
- **ExecStop:** Command to stop (optional)
- **ExecReload:** Command to reload (optional)
- **Restart:** When to restart (always, on-failure, on-abnormal)
- **RestartSec:** Delay before restart
- **Environment:** Set environment variables

**[Install]:**
- **WantedBy:** Target to attach to (multi-user.target = normal boot)

**Service types explained:**
- **simple:** Process doesn't fork (most common)
- **forking:** Process forks and parent exits (traditional daemons)
- **oneshot:** Runs once then exits (initialization tasks)
- **notify:** Service notifies systemd when ready

**Enable and start:**
```bash
sudo systemctl daemon-reload        # Load new service file
sudo systemctl enable myapp         # Enable on boot
sudo systemctl start myapp          # Start now
sudo systemctl status myapp         # Check status
```

### Timer Units (Cron Alternative)

Systemd timers replace cron for scheduled tasks.

**Timer file:** /etc/systemd/system/backup.timer
```ini
[Unit]
Description=Run backup daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

**Service file:** /etc/systemd/system/backup.service
```ini
[Unit]
Description=Backup job

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

**Enable timer:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
systemctl list-timers              # List all timers
```

**OnCalendar examples:**
- **daily:** Once per day at 00:00
- **weekly:** Once per week
- **Mon,Fri 10:00:** Mondays and Fridays at 10 AM
- ***-*-* 02:00:00:** Every day at 2 AM
- **hourly:** Every hour

## Monitoring Resource Usage

### Finding Resource-Heavy Processes

**Top CPU consumers:**
```bash
ps aux --sort=-%cpu | head -10
```

**Top memory consumers:**
```bash
ps aux --sort=-%mem | head -10
```

**All resource info for specific process:**
```bash
top -p PID                # Monitor specific PID
```

### /proc Filesystem

Virtual filesystem containing process information.

**/proc/[PID]/ directories:**
```bash
/proc/1234/cmdline        # Command line
/proc/1234/environ        # Environment variables
/proc/1234/fd/            # Open file descriptors
/proc/1234/status         # Process status
/proc/1234/limits         # Resource limits
```

**Example:**
```bash
cat /proc/1234/cmdline    # See exact command
cat /proc/1234/status     # Detailed status
ls -l /proc/1234/fd/      # See open files
```

**System-wide info:**
```bash
cat /proc/cpuinfo         # CPU information
cat /proc/meminfo         # Memory information
cat /proc/version         # Linux version
cat /proc/uptime          # System uptime
```

## Troubleshooting Process Issues

### Process Won't Stop

**Try escalating signals:**
```bash
kill PID                  # SIGTERM (graceful)
sleep 5
kill PID                  # Try again
sleep 5
kill -9 PID               # SIGKILL (force)
```

**Check if process is in uninterruptible sleep:**
```bash
ps aux | grep "D"
```

Processes in D state cannot be killed, usually waiting for I/O. Wait or reboot.

### Too Many Processes

**Find which user has most processes:**
```bash
ps aux | awk '{print $1}' | sort | uniq -c | sort -rn
```

**Limit user processes:** Edit /etc/security/limits.conf
```
username hard nproc 100
```

### Process Using Too Much Memory

**Identify:**
```bash
ps aux --sort=-%mem | head
```

**Check for memory leaks:**
```bash
top -p PID                # Monitor over time
```

**Temporary fix:**
```bash
kill -9 PID               # Kill and restart
```

**Permanent fix:** Debug application code.

### Zombie Processes

Zombies don't consume resources except PID.

**Find parent:**
```bash
ps -o ppid= -p ZOMBIE_PID
```

**Kill parent:**
```bash
kill PPID                 # Parent should reap zombie
```

If many zombies, indicates parent process bug.

## DevOps Best Practices

### 1. Use Systemd Services

Instead of manual process management, create systemd services:
- Automatic restart on failure
- Dependency management
- Logging integration
- Resource limits

### 2. Set Resource Limits

**In systemd service:**
```ini
[Service]
LimitNOFILE=4096          # Max open files
LimitNPROC=512            # Max processes
MemoryMax=2G              # Max memory
CPUQuota=50%              # Max 50% CPU
```

### 3. Monitor Processes

Set up monitoring:
- Prometheus + node_exporter
- Grafana dashboards
- Alerting on high resource usage

### 4. Graceful Shutdowns

Always handle signals properly in applications:
```python
import signal
import sys

def signal_handler(sig, frame):
    print('Graceful shutdown...')
    # Cleanup code here
    sys.exit(0)

signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)
```

### 5. Logging

Configure systemd services to log properly:
```ini
[Service]
StandardOutput=journal
StandardError=journal
```

View logs:
```bash
journalctl -u myapp.service -f    # Follow logs
```

## Practice Exercises

1. Find the top 5 processes consuming CPU
2. Create a systemd service for a simple script
3. Set up automatic restart on failure
4. Use kill commands to terminate processes
5. Monitor a service in real-time with top
6. Find all zombie processes
7. Change priority of a running process
8. Create a timer unit for scheduled task

## Next Steps

Understanding process management is crucial for running applications and troubleshooting issues. Next, learn networking to understand how processes communicate.

Continue to: `04-networking.md`
