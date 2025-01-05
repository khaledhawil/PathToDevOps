🚀 Linux Commands Cheat Sheet for DevOps Engineers 🚀

As DevOps engineers, we spend a lot of time working with Linux. Whether it’s automating tasks, managing servers, or troubleshooting, knowing the right commands can save us tons of time. Here’s a quick cheat sheet of some essential Linux commands that I use almost every day:

File & Directory Operations:
 • ls – List the files in a directory
 • cd <directory> – Move to a different directory
 • pwd – Show your current directory
 • mkdir <dir> – Create a new directory
 • rm <file> – Delete a file
 • rm -r <dir> – Remove a directory and its contents
 • cp <source> <destination> – Copy files or directories
 • mv <source> <destination> – Move or rename files

File Permissions:
 • chmod <permissions> <file> – Change file permissions
 • chown <user>:<group> <file> – Change file ownership
 • ls -l – View files with detailed information (including permissions)

Search & Find:
 • find <path> -name <filename> – Search for files by name
 • grep <pattern> <file> – Find specific content within a file
 • ps aux – View running processes
 • top – Check real-time system resource usage

Process Management:
 • kill <PID> – Terminate a process
 • killall <process_name> – Kill all instances of a process
 • bg – Resume a paused process in the background
 • fg – Bring a background process back to the foreground

Disk Usage:
 • df -h – Check disk space usage
 • du -sh <directory> – See how much space a directory is using
 • lsblk – List information about your storage devices

Networking:
 • ifconfig – Display your network interfaces
 • ping <hostname> – Test connectivity to a server or device
 • netstat -tuln – See your active network connections
 • curl <url> – Make a web request (useful for testing APIs)
 • scp <file> <user>@<host>:<destination> – Copy files securely over SSH

System Information:
 • uptime – View how long your system has been running
 • free -h – Check your system’s memory usage
 • hostname – Show your system’s hostname
 • dmesg – See boot and system messages

Package Management (Ubuntu/Debian):
 • apt update – Refresh your package list
 • apt upgrade – Upgrade installed packages
 • apt install <package> – Install a new package
 • apt remove <package> – Uninstall a package

Version Control (Git):
 • git clone <repo> – Clone a repository
 • git status – Check the status of your working directory
 • git pull – Pull the latest changes from the remote repo
 • git push – Push your local changes to the remote repo.

🔧 Pro Tip: The real magic happens when you start combining these commands in shell scripts! It can really streamline your workflow, especially when you’re dealing with automation or managing infrastructure at scale.
