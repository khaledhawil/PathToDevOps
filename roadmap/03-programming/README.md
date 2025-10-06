# Phase 3: Programming and Scripting

## Overview

Automation is the core of DevOps. Without programming skills, you cannot automate tasks, write infrastructure code, or understand application behavior. This phase focuses on Bash scripting for system automation and Python for more complex DevOps tasks.

## Learning Objectives

- Master Bash scripting for system automation
- Learn Python fundamentals for DevOps
- Understand programming concepts (variables, loops, functions, conditionals)
- Write automation scripts for common DevOps tasks
- Parse and process data (JSON, YAML, logs)
- Interact with APIs
- Handle errors and exceptions
- Write maintainable, readable code

## Time Required

Estimated: 4 weeks with 4-5 hours daily practice

## Why Two Languages?

### Bash - System Automation

**Use Bash for:**
- System administration tasks
- File operations and text processing
- Gluing command-line tools together
- Quick automation scripts
- Shell environment manipulation
- CI/CD pipeline scripts

**Strengths:**
- Native to Linux, no installation needed
- Direct access to all system commands
- Fast for simple tasks
- Process and file manipulation

**Weaknesses:**
- Complex logic becomes messy
- Limited data structures
- Poor error handling
- Hard to maintain large scripts

### Python - Complex Automation

**Use Python for:**
- API interactions
- Data processing and analysis
- Complex automation logic
- Testing frameworks
- Cloud SDK interactions (boto3 for AWS)
- Infrastructure as Code tools
- Monitoring and alerting scripts

**Strengths:**
- Clean, readable syntax
- Rich standard library
- Excellent third-party packages
- Powerful data structures
- Good error handling
- Cross-platform

**Weaknesses:**
- Requires installation
- Slower than compiled languages
- Indentation-sensitive

## When to Use Which Language?

**Bash:**
```bash
# Simple file backup
tar -czf backup-$(date +%Y%m%d).tar.gz /var/www
```

**Python:**
```python
# Complex backup with S3 upload, notifications, rotation
import boto3
import datetime
import smtplib
# Complex logic here...
```

**Rule of thumb:**
- Script under 50 lines with mostly system commands: Bash
- Script over 50 lines or complex logic: Python
- API interactions: Python
- File processing: Either (choose what team uses)
- System administration: Bash
- Data analysis: Python

## How Programming Connects to DevOps

### Infrastructure as Code

```python
# Terraform uses HCL, but Python can generate it
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
```

### CI/CD Pipelines

```bash
# Jenkins/GitLab CI pipeline script
#!/bin/bash
echo "Building application..."
npm install
npm run build
npm test
docker build -t myapp:${BUILD_NUMBER} .
docker push myapp:${BUILD_NUMBER}
```

### Configuration Management

```python
# Ansible can execute Python scripts
# Custom modules written in Python
```

### Monitoring and Alerting

```python
# Prometheus custom exporter
from prometheus_client import start_http_server, Gauge
import time

disk_usage = Gauge('disk_usage_bytes', 'Disk usage in bytes')

while True:
    disk_usage.set(get_disk_usage())
    time.sleep(60)
```

### Cloud Automation

```python
# AWS automation with boto3
import boto3

ec2 = boto3.resource('ec2')
instances = ec2.create_instances(
    ImageId='ami-12345678',
    MinCount=1,
    MaxCount=1,
    InstanceType='t2.micro'
)
```

## Module Structure

### Bash Scripting
1. `01-bash-basics.md` - Fundamentals
2. `02-bash-scripting.md` - Variables, loops, conditionals
3. `03-bash-advanced.md` - Functions, arrays, error handling
4. `04-bash-devops.md` - DevOps automation scripts

### Python Programming
5. `05-python-basics.md` - Syntax and fundamentals
6. `06-python-intermediate.md` - Data structures, functions, modules
7. `07-python-advanced.md` - OOP, exceptions, file handling
8. `08-python-devops.md` - DevOps libraries and tools

### Integration
9. `09-apis-and-data.md` - Working with APIs and data formats
10. `10-labs.md` - Hands-on projects

## Prerequisites

- Completed Phase 1 (Linux fundamentals)
- Completed Phase 2 (Git)
- Comfortable with command line
- Text editor proficiency

## Key Concepts

### Variables
Store data for later use.

**Bash:**
```bash
NAME="DevOps"
echo "Hello $NAME"
```

**Python:**
```python
name = "DevOps"
print(f"Hello {name}")
```

### Loops
Repeat actions multiple times.

**Bash:**
```bash
for server in web1 web2 web3; do
    ssh $server "systemctl restart nginx"
done
```

**Python:**
```python
servers = ['web1', 'web2', 'web3']
for server in servers:
    restart_service(server, 'nginx')
```

### Conditionals
Make decisions based on conditions.

**Bash:**
```bash
if [ -f "/var/log/app.log" ]; then
    echo "Log file exists"
else
    echo "Log file missing"
fi
```

**Python:**
```python
import os

if os.path.exists('/var/log/app.log'):
    print("Log file exists")
else:
    print("Log file missing")
```

### Functions
Reusable blocks of code.

**Bash:**
```bash
backup_database() {
    local db_name=$1
    mysqldump $db_name > backup_$db_name.sql
}

backup_database "myapp"
```

**Python:**
```python
def backup_database(db_name):
    import subprocess
    subprocess.run(['mysqldump', db_name], 
                   stdout=open(f'backup_{db_name}.sql', 'w'))

backup_database('myapp')
```

## Real-World DevOps Scripts

### Example 1: Server Health Check

```bash
#!/bin/bash
# check_server_health.sh

echo "=== Server Health Check ==="
echo "Timestamp: $(date)"

# CPU usage
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}'

# Memory usage
echo "Memory Usage:"
free -h | awk 'NR==2{printf "Used: %s/%s (%.2f%%)\n", $3,$2,$3*100/$2 }'

# Disk usage
echo "Disk Usage:"
df -h | grep '^/dev' | awk '$5+0 > 80 {print "WARNING: "$0}'

# Check if critical services are running
services=("nginx" "mysql" "redis")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "$service: Running"
    else
        echo "$service: NOT Running - ALERT!"
    fi
done
```

**What this script does:**
- Line 1: Shebang tells system to use bash
- Line 4: Shows current date and time
- Lines 7-8: Gets CPU usage from top command
- Lines 11-12: Calculates memory usage percentage
- Lines 15-16: Warns if disk usage over 80 percent
- Lines 19-25: Checks if critical services are running

### Example 2: Automated Deployment

```python
#!/usr/bin/env python3
# deploy_app.py

import subprocess
import sys
import os

def run_command(command):
    """Execute shell command and handle errors"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            capture_output=True,
            text=True
        )
        print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr}")
        return False

def backup_current_version():
    """Backup current application version"""
    print("Creating backup...")
    return run_command("tar -czf /backup/app-$(date +%Y%m%d).tar.gz /var/www/app")

def pull_latest_code():
    """Pull latest code from Git"""
    print("Pulling latest code...")
    os.chdir('/var/www/app')
    return run_command("git pull origin main")

def install_dependencies():
    """Install application dependencies"""
    print("Installing dependencies...")
    return run_command("npm install")

def run_tests():
    """Run application tests"""
    print("Running tests...")
    return run_command("npm test")

def restart_service():
    """Restart application service"""
    print("Restarting service...")
    return run_command("sudo systemctl restart myapp")

def deploy():
    """Main deployment function"""
    steps = [
        ("Backup", backup_current_version),
        ("Pull Code", pull_latest_code),
        ("Install Dependencies", install_dependencies),
        ("Run Tests", run_tests),
        ("Restart Service", restart_service)
    ]
    
    for step_name, step_function in steps:
        print(f"\n=== {step_name} ===")
        if not step_function():
            print(f"Deployment failed at: {step_name}")
            sys.exit(1)
    
    print("\n=== Deployment Successful ===")

if __name__ == "__main__":
    deploy()
```

**What this script does:**
- Lines 8-22: Function to run shell commands safely
- Lines 24-26: Creates backup before deployment
- Lines 28-31: Pulls latest code from Git repository
- Lines 33-35: Installs dependencies (npm in this case)
- Lines 37-39: Runs automated tests
- Lines 41-43: Restarts application service
- Lines 45-65: Main deployment orchestrator
- Exits with error code if any step fails

## DevOps Script Best Practices

### 1. Always Handle Errors

**Bad:**
```bash
git pull
npm install
npm start
```

**Good:**
```bash
#!/bin/bash
set -e  # Exit on any error
set -u  # Exit on undefined variable

git pull || { echo "Git pull failed"; exit 1; }
npm install || { echo "Install failed"; exit 1; }
npm start
```

### 2. Make Scripts Idempotent

Script can run multiple times with same result.

**Bad:**
```bash
mkdir /app  # Fails if exists
```

**Good:**
```bash
mkdir -p /app  # Creates only if not exists
```

### 3. Log Everything

```bash
#!/bin/bash
LOG_FILE="/var/log/deployment.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log "Starting deployment"
log "Pulling code"
git pull
log "Deployment complete"
```

### 4. Use Configuration Files

**Bad:**
```python
API_KEY = "abc123xyz"  # Hardcoded
DATABASE_URL = "mysql://localhost/db"
```

**Good:**
```python
import os
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.getenv('API_KEY')
DATABASE_URL = os.getenv('DATABASE_URL')
```

### 5. Validate Input

```bash
#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Example: $0 production"
    exit 1
fi

ENVIRONMENT=$1

if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo "Error: Environment must be development, staging, or production"
    exit 1
fi

echo "Deploying to $ENVIRONMENT"
```

### 6. Document Your Scripts

```bash
#!/bin/bash

################################################################################
# Script: deploy.sh
# Description: Deploys application to specified environment
# Author: DevOps Team
# Date: 2024-01-15
# 
# Usage: ./deploy.sh <environment>
# Example: ./deploy.sh production
#
# Prerequisites:
#   - Git installed
#   - SSH access to servers
#   - sudo privileges
################################################################################
```

## Learning Path

1. Start with Bash basics (modules 1-3)
2. Build simple automation scripts
3. Learn Python fundamentals (modules 5-7)
4. Rewrite Bash scripts in Python
5. Explore DevOps-specific libraries
6. Build complete automation projects

## Common Mistakes to Avoid

1. **Not testing scripts:** Always test in safe environment first
2. **Hardcoding values:** Use variables and config files
3. **Poor error handling:** Scripts should fail gracefully
4. **No logging:** Cannot troubleshoot without logs
5. **Not making backups:** Always backup before making changes
6. **Ignoring security:** Never commit secrets, use environment variables
7. **Over-engineering:** Start simple, add complexity when needed

## Essential Tools and Libraries

### Bash Tools
- sed: Stream editor for text processing
- awk: Pattern scanning and processing
- jq: JSON processor
- curl: API interactions
- grep: Search text

### Python Libraries
- requests: HTTP library for API calls
- boto3: AWS SDK
- paramiko: SSH connections
- pyyaml: YAML parsing
- click: CLI tool creation
- fabric: Remote execution
- ansible: Automation (uses Python)

## Practice Projects

1. **System backup script:** Backup specified directories to S3
2. **Log analyzer:** Parse logs and extract errors
3. **Server provisioning:** Automate server setup
4. **Monitoring script:** Check services and send alerts
5. **Deployment automation:** Complete deployment pipeline
6. **Configuration management:** Template-based config generation
7. **API integration:** Interact with cloud provider APIs

## Success Criteria

You are ready for Phase 4 when you can:

- [ ] Write Bash scripts with loops, conditionals, functions
- [ ] Write Python programs with proper structure
- [ ] Parse and process JSON and YAML
- [ ] Interact with APIs using Python
- [ ] Handle errors appropriately
- [ ] Create reusable functions
- [ ] Read and modify existing scripts
- [ ] Debug script issues
- [ ] Write clear documentation

## Next Steps

Begin with `01-bash-basics.md` for Bash fundamentals.

Remember: Programming is learned by solving problems, not memorizing syntax. Practice daily, build real automation, and your skills will grow naturally.

Continue to Phase 4 to learn containerization and infrastructure as code.
