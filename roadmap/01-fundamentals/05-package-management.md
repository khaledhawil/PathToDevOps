# Package Management

## Why Package Management Matters

In DevOps, you constantly install, update, and manage software:
- Installing web servers (nginx, apache)
- Setting up databases (MySQL, PostgreSQL)
- Installing programming languages (Python, Node.js)
- Managing dependencies and libraries
- Applying security updates
- Automating software installation with Ansible, Terraform

Package managers handle dependencies, updates, and removals safely.

## APT - Advanced Package Tool (Debian/Ubuntu)

APT is the package manager for Debian-based systems.

### Basic APT Commands

**Update package list:**
```bash
sudo apt update
```

What this does:
- Downloads latest package information from repositories
- Updates local package index
- Does NOT install or upgrade any packages
- Run this before installing new software

**Upgrade packages:**
```bash
sudo apt upgrade
```

What this does:
- Upgrades installed packages to latest versions
- Does NOT remove packages
- Safe upgrade

**Full upgrade:**
```bash
sudo apt full-upgrade
```

What this does:
- Upgrades packages and removes obsolete packages
- Handles changing dependencies
- More aggressive than upgrade

**Install package:**
```bash
sudo apt install nginx
```

**Install specific version:**
```bash
sudo apt install nginx=1.18.0-0ubuntu1
```

**Install multiple packages:**
```bash
sudo apt install nginx mysql-server python3-pip
```

**Remove package:**
```bash
sudo apt remove nginx
```

Removes package but keeps configuration files.

**Purge package:**
```bash
sudo apt purge nginx
```

Removes package and all configuration files.

**Remove unused dependencies:**
```bash
sudo apt autoremove
```

**Search for package:**
```bash
apt search nginx
apt search "web server"
```

**Show package information:**
```bash
apt show nginx
```

Output shows:
- Package name
- Version
- Size
- Dependencies
- Description

**List installed packages:**
```bash
apt list --installed
apt list --installed | grep nginx
```

**Check if package installed:**
```bash
dpkg -l | grep nginx
```

### APT Configuration

**Repository configuration:**
```bash
cat /etc/apt/sources.list
```

Example:
```
deb http://archive.ubuntu.com/ubuntu/ jammy main restricted
deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted
deb http://security.ubuntu.com/ubuntu jammy-security main restricted
```

**Add repository:**
```bash
sudo add-apt-repository ppa:ondrej/php
sudo apt update
```

**Remove repository:**
```bash
sudo add-apt-repository --remove ppa:ondrej/php
```

### APT vs APT-GET

APT is newer and more user-friendly than apt-get.

**APT (recommended):**
- Better output formatting
- Progress bars
- Simpler commands

**APT-GET (older):**
- More stable for scripts
- More options
- Used in older documentation

Both work similarly:
```bash
apt install package        # APT
apt-get install package    # APT-GET
```

### Package Dependencies

When you install a package, APT automatically installs dependencies.

Example:
```bash
sudo apt install nginx
```

APT installs:
- nginx (main package)
- nginx-common (shared files)
- nginx-core (core files)
- libc6, libssl1.1 (libraries)

**View dependencies:**
```bash
apt depends nginx
```

**View reverse dependencies:**
```bash
apt rdepends nginx
```

Shows what packages depend on nginx.

## YUM/DNF (Red Hat/CentOS/Fedora)

YUM (Yellowdog Updater Modified) is used on RHEL-based systems.
DNF (Dandified YUM) is the newer version.

### Basic YUM/DNF Commands

Commands are similar to APT:

**Update package list:**
```bash
sudo yum update
sudo dnf update
```

**Install package:**
```bash
sudo yum install nginx
sudo dnf install nginx
```

**Remove package:**
```bash
sudo yum remove nginx
sudo dnf remove nginx
```

**Search package:**
```bash
yum search nginx
dnf search nginx
```

**Show package info:**
```bash
yum info nginx
dnf info nginx
```

**List installed packages:**
```bash
yum list installed
dnf list installed
```

**Clean cache:**
```bash
sudo yum clean all
sudo dnf clean all
```

### YUM Repository Configuration

**Repository files:**
```bash
ls /etc/yum.repos.d/
```

**Example repository:**
```bash
cat /etc/yum.repos.d/epel.repo
```

Content:
```
[epel]
name=Extra Packages for Enterprise Linux
baseurl=http://download.fedoraproject.org/pub/epel/7/x86_64
enabled=1
gpgcheck=1
```

**Add repository:**
```bash
sudo yum-config-manager --add-repo https://example.com/repo
```

## Snap Packages

Snap packages are self-contained applications that work across Linux distributions.

**Install snap:**
```bash
sudo apt install snapd
```

**Install snap package:**
```bash
sudo snap install docker
```

**List installed snaps:**
```bash
snap list
```

**Update snap:**
```bash
sudo snap refresh docker
```

**Remove snap:**
```bash
sudo snap remove docker
```

**Search snaps:**
```bash
snap find docker
```

**Snap advantages:**
- Works on any Linux distribution
- Always latest version
- Automatic updates
- Sandboxed applications

**Snap disadvantages:**
- Larger size
- Slower startup
- May have permission issues

## PIP - Python Package Manager

PIP installs Python libraries and tools.

**Install pip:**
```bash
sudo apt install python3-pip
```

**Install package:**
```bash
pip3 install flask
```

**Install specific version:**
```bash
pip3 install flask==2.0.1
```

**Install from requirements file:**
```bash
pip3 install -r requirements.txt
```

requirements.txt:
```
flask==2.0.1
requests==2.26.0
boto3==1.18.0
```

**List installed packages:**
```bash
pip3 list
```

**Show package info:**
```bash
pip3 show flask
```

**Upgrade package:**
```bash
pip3 install --upgrade flask
```

**Uninstall package:**
```bash
pip3 uninstall flask
```

**Generate requirements file:**
```bash
pip3 freeze > requirements.txt
```

**Install in user directory:**
```bash
pip3 install --user flask
```

Installs to ~/.local/bin (no sudo needed).

### Virtual Environments

Virtual environments isolate Python dependencies per project.

**Create virtual environment:**
```bash
python3 -m venv myenv
```

**Activate virtual environment:**
```bash
source myenv/bin/activate
```

Your prompt changes:
```
(myenv) user@hostname:~$
```

**Install packages in virtual environment:**
```bash
pip install flask requests
```

**Deactivate virtual environment:**
```bash
deactivate
```

**Why use virtual environments:**
- Different projects need different versions
- Avoid system-wide conflicts
- Easier dependency management
- Standard practice in Python development

## NPM - Node Package Manager

NPM manages JavaScript packages for Node.js.

**Install Node.js and npm:**
```bash
sudo apt install nodejs npm
```

**Initialize project:**
```bash
npm init
```

Creates package.json file.

**Install package:**
```bash
npm install express
```

**Install globally:**
```bash
sudo npm install -g pm2
```

Global packages available system-wide.

**Install development dependency:**
```bash
npm install --save-dev jest
```

**Install from package.json:**
```bash
npm install
```

**Update packages:**
```bash
npm update
```

**Uninstall package:**
```bash
npm uninstall express
```

**List installed packages:**
```bash
npm list
npm list -g --depth=0    # Global packages
```

**Check outdated packages:**
```bash
npm outdated
```

### package.json

Defines project dependencies:

```json
{
  "name": "myapp",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.17.1",
    "mongoose": "^6.0.0"
  },
  "devDependencies": {
    "jest": "^27.0.0",
    "eslint": "^7.32.0"
  }
}
```

Version format:
- ^4.17.1 - Compatible with 4.x.x (minor updates)
- ~4.17.1 - Compatible with 4.17.x (patch updates)
- 4.17.1 - Exact version

## Docker - Container Package Manager

Docker packages applications with dependencies into containers.

**Install Docker:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

**Pull image:**
```bash
docker pull nginx
```

**List images:**
```bash
docker images
```

**Remove image:**
```bash
docker rmi nginx
```

**Search Docker Hub:**
```bash
docker search nginx
```

**Why Docker matters:**
- Consistent environment across systems
- No dependency conflicts
- Easy to distribute applications
- Foundation for Kubernetes

## System Libraries

Some packages require system libraries.

**Install development tools:**
```bash
sudo apt install build-essential
```

Includes:
- gcc (C compiler)
- g++ (C++ compiler)
- make
- libc-dev

**Install common libraries:**
```bash
sudo apt install libssl-dev libffi-dev libxml2-dev
```

**Why needed:**
- Compile software from source
- Install Python packages with C extensions
- Build custom applications

## Package Management Best Practices

### 1. Always Update Before Installing

```bash
sudo apt update
sudo apt install nginx
```

Ensures you get latest version.

### 2. Use Package Manager, Not Manual Downloads

**Wrong:**
```bash
wget http://example.com/software.deb
sudo dpkg -i software.deb
```

**Right:**
```bash
sudo apt install software
```

Package manager handles updates and dependencies.

### 3. Clean Up Regularly

```bash
sudo apt autoremove
sudo apt autoclean
```

Removes unused packages and cleans cache.

### 4. Use Virtual Environments for Python

```bash
python3 -m venv venv
source venv/bin/activate
pip install flask
```

Avoids system-wide conflicts.

### 5. Document Dependencies

Create requirements.txt (Python):
```bash
pip freeze > requirements.txt
```

Create package.json (Node.js):
```bash
npm init
```

### 6. Pin Versions in Production

**Development:**
```
flask>=2.0.0
```

**Production:**
```
flask==2.0.1
```

Ensures consistent builds.

### 7. Audit Security

**Check Python packages:**
```bash
pip install safety
safety check
```

**Check Node packages:**
```bash
npm audit
npm audit fix
```

### 8. Use Official Repositories

Only add trusted PPAs or repositories.

## DevOps Package Management Scenarios

### Scenario 1: Setting Up Web Server

```bash
# Update system
sudo apt update

# Install Nginx
sudo apt install nginx -y

# Install Python
sudo apt install python3 python3-pip -y

# Install application dependencies
pip3 install flask gunicorn

# Install monitoring
sudo apt install prometheus-node-exporter -y
```

### Scenario 2: Ansible Automation

Ansible playbook to install packages:

```yaml
- name: Install web server
  hosts: webservers
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        
    - name: Install packages
      apt:
        name:
          - nginx
          - python3-pip
          - git
        state: present
        
    - name: Install Python packages
      pip:
        name:
          - flask
          - gunicorn
          - boto3
        executable: pip3
```

### Scenario 3: Docker Multi-stage Build

Dockerfile managing dependencies:

```dockerfile
# Build stage
FROM python:3.9 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Production stage
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

## Troubleshooting

### Problem: Package Not Found

**Error:**
```
E: Unable to locate package nginx
```

**Solution:**
```bash
sudo apt update
sudo apt install nginx
```

### Problem: Broken Dependencies

**Error:**
```
The following packages have unmet dependencies:
```

**Solution:**
```bash
sudo apt --fix-broken install
sudo apt autoremove
sudo apt clean
sudo apt update
```

### Problem: Package Held Back

**Solution:**
```bash
sudo apt full-upgrade
```

### Problem: PPA Issues

**Remove problematic PPA:**
```bash
sudo add-apt-repository --remove ppa:user/ppa-name
sudo apt update
```

### Problem: Disk Space Full

**Clean package cache:**
```bash
sudo apt clean
sudo apt autoremove
du -sh /var/cache/apt/archives
```

## Practice Exercises

1. Update system and install nginx
2. Create Python virtual environment and install flask
3. Write requirements.txt for Python project
4. Install Node.js and create package.json
5. Search for packages related to Docker
6. Remove package and verify removal
7. Add PPA repository and install package from it
8. Clean up unused packages and check disk space saved

## Next Steps

Understanding package management is essential for automating infrastructure setup and managing dependencies in DevOps pipelines.

You have completed Phase 1 - Fundamentals.

Continue to: `Phase 2 - Version Control` in `/roadmap/02-version-control/`
