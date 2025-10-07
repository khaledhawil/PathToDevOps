# Python for DevOps Automation

## Why Python in DevOps

Python is the most popular language for DevOps automation:
- Clean and readable syntax
- Extensive library ecosystem
- Better for complex logic than Bash
- Cloud SDK support (AWS boto3, Azure SDK, GCP client libraries)
- Infrastructure automation (Ansible written in Python)
- API interactions and web scraping
- Data processing and analysis
- Cross-platform compatibility

**When to use Python over Bash:**
- Complex data structures needed
- API interactions
- Multi-platform scripts
- Advanced error handling
- Object-oriented approach
- Unit testing required

## Python Basics for DevOps

### Installation and Setup

**Install Python:**
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

**Check version:**
```bash
python3 --version
```

**Create virtual environment:**
```bash
python3 -m venv venv
source venv/bin/activate
```

**Install packages:**
```bash
pip install requests boto3 paramiko
```

### Your First Python Script

**Create script:**
```bash
nano hello.py
```

**Content:**
```python
#!/usr/bin/env python3

# This is a comment

print("Hello, DevOps!")
```

**Run script:**
```bash
python3 hello.py
chmod +x hello.py
./hello.py
```

### Variables and Data Types

**Variables:**
```python
name = "John"
age = 25
height = 5.9
is_devops = True

print(f"Name: {name}")
print(f"Age: {age}")
print(f"Height: {height}")
print(f"Is DevOps: {is_devops}")
```

**Type checking:**
```python
print(type(name))      # <class 'str'>
print(type(age))       # <class 'int'>
print(type(height))    # <class 'float'>
print(type(is_devops)) # <class 'bool'>
```

### Lists (Arrays)

```python
# Create list
servers = ["web1", "web2", "db1", "cache1"]

# Access elements
print(servers[0])        # web1
print(servers[-1])       # cache1 (last element)

# Add element
servers.append("web3")

# Remove element
servers.remove("db1")

# Length
print(len(servers))

# Loop through list
for server in servers:
    print(f"Server: {server}")

# List comprehension
uppercase_servers = [s.upper() for s in servers]

# Check if exists
if "web1" in servers:
    print("web1 exists")
```

### Dictionaries (Key-Value)

```python
# Create dictionary
server = {
    "hostname": "web1",
    "ip": "192.168.1.100",
    "port": 80,
    "status": "running"
}

# Access values
print(server["hostname"])
print(server.get("ip"))

# Add/update
server["region"] = "us-east-1"
server["port"] = 8080

# Remove
del server["status"]

# Loop through dictionary
for key, value in server.items():
    print(f"{key}: {value}")

# Check if key exists
if "hostname" in server:
    print("Hostname exists")
```

### Tuples (Immutable Lists)

```python
# Create tuple
coordinates = (10.5, 20.3)
server_config = ("web1", "192.168.1.100", 80)

# Access elements
print(coordinates[0])

# Cannot modify tuple
# coordinates[0] = 15  # This will error
```

### Sets (Unique Items)

```python
# Create set
ports = {80, 443, 8080, 80}  # Duplicate 80 removed
print(ports)  # {80, 443, 8080}

# Add element
ports.add(3000)

# Remove element
ports.remove(80)

# Set operations
active_servers = {"web1", "web2", "db1"}
all_servers = {"web1", "web2", "web3", "db1", "db2"}

# Difference
inactive = all_servers - active_servers
print(inactive)  # {'web3', 'db2'}
```

## Control Flow

### Conditional Statements

```python
age = 18

if age >= 18:
    print("Adult")
elif age >= 13:
    print("Teenager")
else:
    print("Child")
```

**Comparison operators:**
```python
==  # Equal
!=  # Not equal
>   # Greater than
<   # Less than
>=  # Greater or equal
<=  # Less or equal
```

**Logical operators:**
```python
and  # Both conditions true
or   # At least one condition true
not  # Negate condition

if age >= 18 and age <= 65:
    print("Working age")
```

### Loops

**For loop:**
```python
# Loop through list
servers = ["web1", "web2", "db1"]
for server in servers:
    print(f"Processing {server}")

# Loop through range
for i in range(5):
    print(i)  # 0, 1, 2, 3, 4

# Loop through range with start and step
for i in range(1, 10, 2):
    print(i)  # 1, 3, 5, 7, 9

# Loop with index
for index, server in enumerate(servers):
    print(f"{index}: {server}")
```

**While loop:**
```python
counter = 0
while counter < 5:
    print(f"Counter: {counter}")
    counter += 1
```

**Break and continue:**
```python
for i in range(10):
    if i == 5:
        break  # Exit loop
    if i == 3:
        continue  # Skip this iteration
    print(i)
```

## Functions

```python
def greet(name):
    """Greet a person by name."""
    print(f"Hello, {name}!")

greet("John")
```

**Return value:**
```python
def add(a, b):
    """Add two numbers."""
    return a + b

result = add(10, 20)
print(result)  # 30
```

**Multiple return values:**
```python
def get_server_info():
    """Get server information."""
    hostname = "web1"
    ip = "192.168.1.100"
    port = 80
    return hostname, ip, port

hostname, ip, port = get_server_info()
```

**Default arguments:**
```python
def deploy(app_name, environment="production"):
    """Deploy application."""
    print(f"Deploying {app_name} to {environment}")

deploy("myapp")                      # Uses default
deploy("myapp", "staging")           # Overrides default
```

**Keyword arguments:**
```python
def create_server(name, cpu, memory, disk):
    """Create server with specifications."""
    print(f"Creating {name}: {cpu} CPU, {memory}GB RAM, {disk}GB disk")

create_server(name="web1", cpu=2, memory=4, disk=50)
create_server(disk=100, name="db1", cpu=4, memory=8)
```

**Variable arguments:**
```python
def deploy_to_servers(*servers):
    """Deploy to multiple servers."""
    for server in servers:
        print(f"Deploying to {server}")

deploy_to_servers("web1", "web2", "web3")
```

## File Operations

**Read file:**
```python
# Method 1: Manual close
file = open("config.txt", "r")
content = file.read()
file.close()

# Method 2: Automatic close (recommended)
with open("config.txt", "r") as file:
    content = file.read()
    print(content)
```

**Read lines:**
```python
with open("servers.txt", "r") as file:
    for line in file:
        print(line.strip())
```

**Write file:**
```python
with open("output.txt", "w") as file:
    file.write("Hello, World!\n")
    file.write("DevOps automation\n")
```

**Append to file:**
```python
with open("log.txt", "a") as file:
    file.write("New log entry\n")
```

**Check if file exists:**
```python
import os

if os.path.exists("config.txt"):
    print("File exists")
```

## Error Handling

```python
try:
    # Code that might raise exception
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")
except Exception as e:
    print(f"Error: {e}")
else:
    print("No errors occurred")
finally:
    print("This always executes")
```

**Specific exceptions:**
```python
try:
    with open("nonexistent.txt", "r") as file:
        content = file.read()
except FileNotFoundError:
    print("File not found")
except PermissionError:
    print("Permission denied")
```

**Raise exceptions:**
```python
def divide(a, b):
    if b == 0:
        raise ValueError("Divisor cannot be zero")
    return a / b

try:
    result = divide(10, 0)
except ValueError as e:
    print(e)
```

## Working with System

### Execute Shell Commands

```python
import subprocess

# Simple command
result = subprocess.run(["ls", "-l"], capture_output=True, text=True)
print(result.stdout)

# With shell
result = subprocess.run("df -h | grep /dev", shell=True, capture_output=True, text=True)
print(result.stdout)

# Check exit code
result = subprocess.run(["systemctl", "is-active", "nginx"])
if result.returncode == 0:
    print("Nginx is running")
else:
    print("Nginx is not running")
```

### Environment Variables

```python
import os

# Get environment variable
home = os.getenv("HOME")
print(home)

# Get with default
api_key = os.getenv("API_KEY", "default_key")

# Set environment variable
os.environ["MY_VAR"] = "my_value"

# All environment variables
for key, value in os.environ.items():
    print(f"{key}: {value}")
```

### File System Operations

```python
import os
import shutil

# Current directory
print(os.getcwd())

# Change directory
os.chdir("/tmp")

# List directory
files = os.listdir(".")
print(files)

# Create directory
os.makedirs("path/to/directory", exist_ok=True)

# Remove directory
shutil.rmtree("path/to/directory")

# Copy file
shutil.copy("source.txt", "dest.txt")

# Move file
shutil.move("source.txt", "destination.txt")

# Remove file
os.remove("file.txt")

# File information
stat = os.stat("file.txt")
print(f"Size: {stat.st_size} bytes")
print(f"Modified: {stat.st_mtime}")
```

## Working with APIs

### Requests Library

```bash
pip install requests
```

**GET request:**
```python
import requests

response = requests.get("https://api.github.com/users/octocat")

if response.status_code == 200:
    data = response.json()
    print(data["login"])
    print(data["name"])
else:
    print(f"Error: {response.status_code}")
```

**POST request:**
```python
import requests

payload = {
    "username": "john",
    "email": "john@example.com"
}

response = requests.post("https://api.example.com/users", json=payload)
print(response.json())
```

**With headers:**
```python
headers = {
    "Authorization": "Bearer YOUR_TOKEN",
    "Content-Type": "application/json"
}

response = requests.get("https://api.example.com/data", headers=headers)
```

**Error handling:**
```python
try:
    response = requests.get("https://api.example.com/data", timeout=5)
    response.raise_for_status()  # Raise exception for 4xx/5xx
    data = response.json()
except requests.exceptions.Timeout:
    print("Request timed out")
except requests.exceptions.HTTPError as e:
    print(f"HTTP error: {e}")
except requests.exceptions.RequestException as e:
    print(f"Error: {e}")
```

## Real DevOps Scripts

### System Health Monitoring

```python
#!/usr/bin/env python3

import psutil
import subprocess

def get_cpu_usage():
    """Get CPU usage percentage."""
    return psutil.cpu_percent(interval=1)

def get_memory_usage():
    """Get memory usage."""
    memory = psutil.virtual_memory()
    return {
        "total": round(memory.total / (1024**3), 2),
        "used": round(memory.used / (1024**3), 2),
        "percent": memory.percent
    }

def get_disk_usage():
    """Get disk usage."""
    disk = psutil.disk_usage('/')
    return {
        "total": round(disk.total / (1024**3), 2),
        "used": round(disk.used / (1024**3), 2),
        "percent": disk.percent
    }

def check_service(service_name):
    """Check if service is running."""
    result = subprocess.run(
        ["systemctl", "is-active", service_name],
        capture_output=True,
        text=True
    )
    return result.returncode == 0

def main():
    print("=== System Health Check ===\n")
    
    # CPU
    cpu = get_cpu_usage()
    print(f"CPU Usage: {cpu}%")
    
    # Memory
    memory = get_memory_usage()
    print(f"Memory: {memory['used']}GB / {memory['total']}GB ({memory['percent']}%)")
    
    # Disk
    disk = get_disk_usage()
    print(f"Disk: {disk['used']}GB / {disk['total']}GB ({disk['percent']}%)")
    
    # Services
    services = ["nginx", "mysql", "redis"]
    print("\nServices:")
    for service in services:
        status = "Running" if check_service(service) else "Stopped"
        print(f"  {service}: {status}")

if __name__ == "__main__":
    main()
```

### AWS EC2 Management

```bash
pip install boto3
```

```python
#!/usr/bin/env python3

import boto3

def list_instances():
    """List all EC2 instances."""
    ec2 = boto3.client('ec2', region_name='us-east-1')
    response = ec2.describe_instances()
    
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            state = instance['State']['Name']
            instance_type = instance['InstanceType']
            
            # Get Name tag
            name = "N/A"
            if 'Tags' in instance:
                for tag in instance['Tags']:
                    if tag['Key'] == 'Name':
                        name = tag['Value']
            
            print(f"{name} ({instance_id}): {state} - {instance_type}")

def start_instance(instance_id):
    """Start EC2 instance."""
    ec2 = boto3.client('ec2', region_name='us-east-1')
    ec2.start_instances(InstanceIds=[instance_id])
    print(f"Starting instance {instance_id}")

def stop_instance(instance_id):
    """Stop EC2 instance."""
    ec2 = boto3.client('ec2', region_name='us-east-1')
    ec2.stop_instances(InstanceIds=[instance_id])
    print(f"Stopping instance {instance_id}")

if __name__ == "__main__":
    list_instances()
```

### Log Parser

```python
#!/usr/bin/env python3

import re
from collections import Counter

def parse_nginx_log(log_file):
    """Parse Nginx access log."""
    ip_addresses = []
    status_codes = []
    urls = []
    
    # Nginx log pattern
    pattern = r'(\d+\.\d+\.\d+\.\d+).*\[.*\] "(?:GET|POST|PUT|DELETE) ([^ ]+) .*" (\d+)'
    
    with open(log_file, 'r') as file:
        for line in file:
            match = re.search(pattern, line)
            if match:
                ip_addresses.append(match.group(1))
                urls.append(match.group(2))
                status_codes.append(match.group(3))
    
    return ip_addresses, urls, status_codes

def main():
    log_file = "/var/log/nginx/access.log"
    
    ips, urls, status_codes = parse_nginx_log(log_file)
    
    print("=== Nginx Log Analysis ===\n")
    
    # Top 10 IPs
    print("Top 10 IP Addresses:")
    for ip, count in Counter(ips).most_common(10):
        print(f"  {ip}: {count}")
    
    print("\nTop 10 URLs:")
    for url, count in Counter(urls).most_common(10):
        print(f"  {url}: {count}")
    
    print("\nHTTP Status Codes:")
    for code, count in Counter(status_codes).most_common():
        print(f"  {code}: {count}")

if __name__ == "__main__":
    main()
```

### Automated Deployment

```python
#!/usr/bin/env python3

import subprocess
import sys
from datetime import datetime

class Deployer:
    def __init__(self, app_name, app_dir, branch="main"):
        self.app_name = app_name
        self.app_dir = app_dir
        self.branch = branch
    
    def run_command(self, command):
        """Execute shell command."""
        print(f"Running: {command}")
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error: {result.stderr}")
            sys.exit(1)
        return result.stdout
    
    def backup(self):
        """Create backup of current version."""
        backup_name = f"{self.app_dir}_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        print(f"Creating backup: {backup_name}")
        self.run_command(f"cp -r {self.app_dir} {backup_name}")
    
    def pull_code(self):
        """Pull latest code from Git."""
        print(f"Pulling latest code from {self.branch}")
        self.run_command(f"cd {self.app_dir} && git fetch origin")
        self.run_command(f"cd {self.app_dir} && git reset --hard origin/{self.branch}")
    
    def install_dependencies(self):
        """Install application dependencies."""
        print("Installing dependencies")
        self.run_command(f"cd {self.app_dir} && pip install -r requirements.txt")
    
    def run_migrations(self):
        """Run database migrations."""
        print("Running migrations")
        self.run_command(f"cd {self.app_dir} && python manage.py migrate")
    
    def restart_service(self):
        """Restart application service."""
        print(f"Restarting {self.app_name}")
        self.run_command(f"sudo systemctl restart {self.app_name}")
    
    def health_check(self):
        """Perform health check."""
        print("Performing health check")
        result = subprocess.run(
            ["curl", "-f", "http://localhost:8000/health"],
            capture_output=True,
            timeout=10
        )
        return result.returncode == 0
    
    def deploy(self):
        """Execute deployment."""
        print(f"=== Deploying {self.app_name} ===\n")
        
        try:
            self.backup()
            self.pull_code()
            self.install_dependencies()
            self.run_migrations()
            self.restart_service()
            
            if self.health_check():
                print("\nDeployment successful!")
            else:
                print("\nHealth check failed!")
                sys.exit(1)
        except Exception as e:
            print(f"\nDeployment failed: {e}")
            sys.exit(1)

if __name__ == "__main__":
    deployer = Deployer(
        app_name="myapp",
        app_dir="/var/www/myapp",
        branch="main"
    )
    deployer.deploy()
```

## Best Practices

1. **Use virtual environments**
2. **Follow PEP 8 style guide**
3. **Write docstrings for functions**
4. **Handle exceptions properly**
5. **Use context managers (with statement)**
6. **Avoid global variables**
7. **Use meaningful variable names**
8. **Add type hints (Python 3.5+)**
9. **Write unit tests**
10. **Use logging instead of print**

## Practice Exercises

1. Write script to monitor server resources
2. Create AWS EC2 instance manager
3. Build log parser for specific format
4. Automate backup with rotation
5. Create API client for REST service
6. Build configuration file generator
7. Write deployment automation script
8. Create system inventory collector

## Next Steps

Python enables sophisticated automation beyond Bash capabilities. Practice with AWS SDK and API integrations.

Continue to: `Phase 4 - Infrastructure` in `/roadmap/04-infrastructure/`
