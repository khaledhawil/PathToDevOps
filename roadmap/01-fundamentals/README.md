# Phase 1: Fundamentals

## Overview

This phase builds the foundation for everything in DevOps. Without mastering these fundamentals, advanced topics will be extremely difficult. Linux is the operating system that runs 96% of production servers, and understanding it deeply is non-negotiable for DevOps engineers.

## Learning Objectives

By the end of this phase, you will:

- Navigate Linux filesystem with confidence
- Manage users, groups, and permissions
- Understand networking fundamentals
- Work with processes and services
- Master essential command-line tools
- Troubleshoot common Linux issues
- Write basic shell scripts
- Understand how computers communicate over networks

## Time Required

Estimated: 4-6 weeks with 4-6 hours daily practice

## Why Linux and Networking First?

### Linux Dominance

Every DevOps tool you will learn runs on or interacts with Linux:
- Docker containers are Linux processes
- Kubernetes orchestrates Linux containers
- CI/CD agents run on Linux servers
- Cloud VMs are predominantly Linux
- Ansible manages Linux servers
- Monitoring tools collect data from Linux systems

### Networking is Everywhere

You cannot:
- Deploy applications without understanding ports and protocols
- Configure load balancers without knowing networking
- Troubleshoot connectivity issues without network knowledge
- Secure systems without understanding firewalls and network security
- Work with Kubernetes without understanding networking concepts

## Module Structure

### 1. Linux Basics
- What Linux is and why it matters
- Linux distributions
- Filesystem hierarchy
- Essential commands
- File operations

### 2. User and Permission Management
- User accounts and groups
- File permissions (chmod, chown)
- sudo and root access
- Security best practices

### 3. Process Management
- What processes are
- Viewing and managing processes
- Background and foreground jobs
- Process signals
- Systemd and service management

### 4. Networking Fundamentals
- OSI model and TCP/IP
- IP addresses and subnets
- Ports and protocols
- DNS and name resolution
- Network troubleshooting tools

### 5. Package Management
- Package managers (apt, yum, dnf)
- Installing and updating software
- Managing dependencies
- Repository configuration

### 6. Text Processing
- Working with text files
- grep, sed, awk
- Regular expressions
- Log file analysis

### 7. System Monitoring
- Resource usage (CPU, memory, disk)
- Monitoring tools
- Log files and journald
- Performance troubleshooting

## Learning Path

Work through modules in order:

1. `01-linux-basics.md` - Start here
2. `02-user-permissions.md` - User and permission management
3. `03-process-management.md` - Processes and services
4. `04-networking.md` - Networking fundamentals
5. `05-package-management.md` - Software installation
6. `06-text-processing.md` - Working with text and logs
7. `07-system-monitoring.md` - Monitoring and troubleshooting
8. `08-labs.md` - Hands-on practice exercises

## Prerequisites

- Computer with Linux installed (Ubuntu 22.04 recommended)
- OR Virtual machine with Linux
- OR WSL2 on Windows
- Terminal access
- Internet connection for package installation

## Study Approach

### Daily Routine

**Day 1-7: Linux Basics**
- Read module documentation
- Practice every command shown
- Complete exercises
- Create a cheat sheet of commands

**Day 8-14: Users and Permissions**
- Create multiple users
- Practice permission scenarios
- Understand security implications
- Lab: Set up a multi-user system

**Day 15-21: Processes and Services**
- Explore running processes
- Start and stop services
- Create custom services
- Lab: Deploy a simple web service

**Day 22-28: Networking**
- Understand network concepts
- Practice network commands
- Configure network interfaces
- Lab: Set up network between VMs

**Day 29-35: Package Management**
- Install various software
- Manage repositories
- Handle dependencies
- Lab: Set up a complete LAMP stack

**Day 36-42: Text Processing and Monitoring**
- Parse log files
- Use grep, sed, awk effectively
- Monitor system resources
- Lab: Create monitoring scripts

### Practice Methodology

**Do not just read - practice everything**

For each command:
1. Type it yourself (no copy-paste)
2. Read the man page: `man command`
3. Try different options and flags
4. Intentionally make errors to see what happens
5. Fix the errors yourself

## How This Connects to DevOps

### Real-World Scenario

Imagine deploying a web application. You need to:

1. **Linux knowledge:** SSH into server, navigate directories
2. **User management:** Create service accounts for applications
3. **Permissions:** Set correct file permissions for security
4. **Process management:** Start web server as a service
5. **Networking:** Configure firewall, open correct ports
6. **Package management:** Install dependencies (Node.js, Python, etc.)
7. **Text processing:** Analyze application logs for errors
8. **Monitoring:** Check if application is consuming too much memory

Without these fundamentals, you cannot complete even this basic deployment.

### DevOps Tools Connection

Every tool you will learn later builds on these fundamentals:

**Docker:**
- Uses Linux namespaces and cgroups (processes)
- Requires understanding of filesystem (volumes)
- Networking concepts (container networking)
- Users and permissions (security)

**Kubernetes:**
- Manages multiple Linux servers
- Complex networking between pods
- Process management at scale
- Log aggregation requires text processing skills

**Ansible:**
- Automates Linux system administration tasks
- Manages users, packages, services
- Requires SSH (networking)
- Uses YAML files (text files)

**Terraform:**
- Provisions Linux VMs in cloud
- Configures networking (VPC, subnets)
- Sets up security groups (firewalls)
- Installs software (package management)

## Success Criteria

You are ready for Phase 2 when you can:

- [ ] Navigate the filesystem without looking up commands
- [ ] Create users and set permissions correctly
- [ ] Start, stop, and troubleshoot services
- [ ] Configure basic networking
- [ ] Install software and manage dependencies
- [ ] Parse log files and find specific information
- [ ] Monitor system resources and identify issues
- [ ] Complete all labs independently
- [ ] Explain concepts to someone else

## Common Pitfalls

### 1. Skipping Man Pages
**Problem:** Not reading documentation
**Solution:** Always run `man command` to understand what it does

### 2. Using Root Account Constantly
**Problem:** Working as root user for everything
**Solution:** Use regular user with sudo when needed

### 3. Not Understanding File Paths
**Problem:** Confusion between relative and absolute paths
**Solution:** Practice cd, pwd, and path navigation extensively

### 4. Memorizing Without Understanding
**Problem:** Memorizing commands without knowing what they do
**Solution:** Understand the purpose and options of each command

### 5. Ignoring Error Messages
**Problem:** Giving up when commands fail
**Solution:** Read errors carefully, they tell you what is wrong

## Resources

### Essential Man Pages to Read

```bash
man ls      # List files
man cd      # Change directory
man chmod   # Change permissions
man ps      # Process status
man grep    # Search text
man systemctl  # Service management
man ip      # Network configuration
man apt     # Package management (Debian/Ubuntu)
```

### Online Resources

- Linux Journey: linuxjourney.com (beginner-friendly)
- OverTheWire Bandit: Practice security-focused Linux (wargames)
- Linux Command Line Book: free PDF available
- Ubuntu Documentation: help.ubuntu.com
- Arch Wiki: wiki.archlinux.org (excellent technical reference)

### Practice Platforms

- VirtualBox with Ubuntu VM (local)
- DigitalOcean droplet (5 USD per month)
- AWS EC2 free tier (12 months free)
- Google Cloud Compute Engine free tier

## Getting Help

### When Stuck

1. Read the error message completely
2. Check man page: `man command`
3. Search: "command error message linux"
4. Check Stack Overflow
5. Ask in Linux forums or communities

### Good Questions to Ask

- What is this command doing?
- Why did I get this error?
- How does this relate to DevOps?
- When would I use this in real scenarios?

## Next Steps

Start with `01-linux-basics.md` and work through each module systematically.

Remember: These are the most important weeks of your DevOps journey. A strong foundation here makes everything else easier. A weak foundation makes everything difficult.

Invest the time now, practice extensively, and you will thank yourself later.
