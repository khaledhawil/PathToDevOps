# Ansible - Configuration Management and Automation

## What is Ansible and Why Do We Need It?

Imagine you have 50 servers and need to:
- Install nginx on all of them
- Update configuration files
- Restart services
- Ensure security settings are correct

**Without Ansible:**
- SSH to each server manually (50 times!)
- Run commands one by one
- Takes hours
- Prone to mistakes
- Hard to track what was done

**With Ansible:**
- Write one playbook
- Run once: `ansible-playbook install-nginx.yml`
- Done in minutes
- Same result on all servers
- Repeatable and documented

**Ansible is:**
- Configuration management tool
- Automation engine
- Agentless (no software needed on managed servers)
- Uses SSH for communication
- Written in Python
- Uses YAML for configuration (easy to read)

## How Ansible Works

**The Ansible workflow:**
```
1. You write playbook (YAML file)
2. You specify which servers to manage (inventory)
3. Ansible connects via SSH
4. Ansible executes tasks on servers
5. Ansible reports results
```

**Key concepts:**
- **Control Node:** Your machine running Ansible
- **Managed Nodes:** Servers you want to configure
- **Inventory:** List of managed nodes
- **Playbook:** YAML file with tasks
- **Module:** Unit of work (install package, copy file, etc.)
- **Task:** Single action using a module
- **Role:** Organized collection of tasks

**Why Ansible vs other tools:**
- **No agent required** (Puppet/Chef need agent installed)
- **Simple YAML syntax** (not a programming language)
- **Push-based** (you control when changes happen)
- **Idempotent** (safe to run multiple times)

## Installing Ansible

**On Ubuntu/Debian:**
```bash
# Update packages
sudo apt update

# Install Ansible
sudo apt install ansible -y

# Verify installation
ansible --version
```

Output:
```
ansible [core 2.15.0]
  config file = /etc/ansible/ansible.cfg
  python version = 3.10.6
```

**On Red Hat/CentOS:**
```bash
sudo yum install epel-release -y
sudo yum install ansible -y
```

**Via pip (any system):**
```bash
pip3 install ansible
```

## Setting Up SSH Keys

Ansible uses SSH, so we need passwordless authentication.

**Generate SSH key (if you don't have one):**
```bash
ssh-keygen -t rsa -b 4096
```

Press Enter for all prompts (uses defaults).

**Copy SSH key to managed server:**
```bash
ssh-copy-id user@192.168.1.100
```

Replace:
- `user` - Username on remote server
- `192.168.1.100` - IP of managed server

**Test SSH connection:**
```bash
ssh user@192.168.1.100
```

Should login without password.

**For AWS EC2:**
```bash
ssh-add your-key.pem
ssh -i your-key.pem ubuntu@ec2-ip-address
```

## Ansible Inventory

Inventory lists your servers.

**Create inventory file:**
```bash
mkdir ansible-demo
cd ansible-demo
nano inventory.ini
```

**Simple inventory (INI format):**
```ini
# Single server
web1 ansible_host=192.168.1.100 ansible_user=ubuntu

# Multiple servers
web2 ansible_host=192.168.1.101 ansible_user=ubuntu
web3 ansible_host=192.168.1.102 ansible_user=ubuntu
```

**Explanation:**
- `web1` - Nickname for server (can be anything)
- `ansible_host` - IP address or hostname
- `ansible_user` - SSH username

**Grouped inventory:**
```ini
# Web servers group
[webservers]
web1 ansible_host=192.168.1.100
web2 ansible_host=192.168.1.101

# Database servers group
[databases]
db1 ansible_host=192.168.1.200
db2 ansible_host=192.168.1.201

# All production servers
[production:children]
webservers
databases

# Variables for all webservers
[webservers:vars]
ansible_user=ubuntu
ansible_port=22
```

**Explanation:**
- `[webservers]` - Group name
- `[production:children]` - Group of groups
- `[webservers:vars]` - Variables for group

**YAML inventory (modern format):**
```yaml
all:
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.100
          ansible_user: ubuntu
        web2:
          ansible_host: 192.168.1.101
          ansible_user: ubuntu
    databases:
      hosts:
        db1:
          ansible_host: 192.168.1.200
          ansible_user: ubuntu
```

## Testing Connectivity

**Ping all hosts:**
```bash
ansible all -i inventory.ini -m ping
```

Breakdown:
- `ansible` - Command
- `all` - Target all hosts (can use group name)
- `-i inventory.ini` - Use this inventory file
- `-m ping` - Use ping module

**Success output:**
```json
web1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

**Ping specific group:**
```bash
ansible webservers -i inventory.ini -m ping
```

**Ping single host:**
```bash
ansible web1 -i inventory.ini -m ping
```

## Ad-Hoc Commands

Run single commands without playbook.

**Check disk space:**
```bash
ansible all -i inventory.ini -m shell -a "df -h"
```

Breakdown:
- `-m shell` - Use shell module
- `-a "df -h"` - Arguments to shell module (command to run)

**Check uptime:**
```bash
ansible all -i inventory.ini -m shell -a "uptime"
```

**Check memory:**
```bash
ansible all -i inventory.ini -m shell -a "free -h"
```

**Install package (needs sudo):**
```bash
ansible webservers -i inventory.ini -m apt -a "name=nginx state=present" --become
```

Breakdown:
- `-m apt` - Use apt module (for Ubuntu/Debian)
- `name=nginx` - Package name
- `state=present` - Ensure it's installed
- `--become` - Use sudo

**Start service:**
```bash
ansible webservers -i inventory.ini -m service -a "name=nginx state=started" --become
```

**Copy file:**
```bash
ansible all -i inventory.ini -m copy -a "src=/local/file.txt dest=/remote/path/file.txt"
```

**Create directory:**
```bash
ansible all -i inventory.ini -m file -a "path=/opt/myapp state=directory mode=0755" --become
```

**Gather facts:**
```bash
ansible web1 -i inventory.ini -m setup
```

Shows all information about the system (OS, IP, CPU, memory, etc.)

## Your First Playbook

Playbooks are YAML files describing desired state.

**Create playbook:**
```bash
nano install-nginx.yml
```

**Content:**
```yaml
---
# This playbook installs nginx on webservers
# --- indicates start of YAML file

- name: Install and configure nginx
  hosts: webservers
  become: true
  
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
    
    - name: Install nginx
      apt:
        name: nginx
        state: present
    
    - name: Start nginx service
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Create custom index.html
      copy:
        content: "<h1>Hello from Ansible!</h1>"
        dest: /var/www/html/index.html
```

**Explanation line by line:**
- `---` - YAML file start
- `- name: Install and configure nginx` - Playbook description
- `hosts: webservers` - Run on webservers group
- `become: true` - Use sudo for all tasks
- `tasks:` - List of tasks to execute
- `- name: Update apt cache` - Task description
- `apt:` - Module to use
- `update_cache: yes` - Module parameter
- Indentation matters in YAML! (use 2 spaces)

**Run playbook:**
```bash
ansible-playbook -i inventory.ini install-nginx.yml
```

**Output shows:**
```
PLAY [Install and configure nginx] *****

TASK [Update apt cache] *****
changed: [web1]

TASK [Install nginx] *****
changed: [web1]

TASK [Start nginx service] *****
ok: [web1]

TASK [Create custom index.html] *****
changed: [web1]

PLAY RECAP *****
web1 : ok=4 changed=3 unreachable=0 failed=0
```

**Status meanings:**
- `ok` - Task succeeded, no changes needed
- `changed` - Task made changes
- `failed` - Task failed
- `skipped` - Task was skipped

**Test result:**
```bash
curl http://192.168.1.100
```

Output: `<h1>Hello from Ansible!</h1>`

**Run playbook again:**
```bash
ansible-playbook -i inventory.ini install-nginx.yml
```

Second run shows mostly `ok` (not `changed`) because system is already in desired state. This is **idempotency** - safe to run multiple times.

## Playbook Structure

**Complete playbook structure:**
```yaml
---
- name: Playbook name
  hosts: target_hosts
  become: yes/no
  gather_facts: yes/no
  vars:
    variable_name: value
  
  tasks:
    - name: Task description
      module_name:
        parameter: value
      when: condition
      notify: handler_name
  
  handlers:
    - name: Handler name
      module_name:
        parameter: value
```

## Variables

Variables make playbooks reusable.

**Define in playbook:**
```yaml
---
- name: Install package
  hosts: webservers
  become: true
  
  vars:
    package_name: nginx
    package_state: present
  
  tasks:
    - name: Install {{ package_name }}
      apt:
        name: "{{ package_name }}"
        state: "{{ package_state }}"
```

**Use double curly braces:** `{{ variable_name }}`

**Variables file (recommended):**

Create `vars.yml`:
```yaml
---
package_name: nginx
package_state: present
web_port: 80
document_root: /var/www/html
```

Use in playbook:
```yaml
---
- name: Install package
  hosts: webservers
  become: true
  vars_files:
    - vars.yml
  
  tasks:
    - name: Install {{ package_name }}
      apt:
        name: "{{ package_name }}"
        state: "{{ package_state }}"
```

**Pass variable on command line:**
```bash
ansible-playbook -i inventory.ini playbook.yml -e "package_name=apache2"
```

**Host variables:**

Create `host_vars/web1.yml`:
```yaml
---
server_purpose: frontend
max_clients: 100
```

These variables only apply to web1.

**Group variables:**

Create `group_vars/webservers.yml`:
```yaml
---
web_package: nginx
web_port: 80
```

These variables apply to all hosts in webservers group.

## Conditionals

Run tasks based on conditions.

```yaml
---
- name: Install web server
  hosts: all
  become: true
  
  tasks:
    - name: Install nginx on Ubuntu
      apt:
        name: nginx
        state: present
      when: ansible_os_family == "Debian"
    
    - name: Install nginx on CentOS
      yum:
        name: nginx
        state: present
      when: ansible_os_family == "RedHat"
    
    - name: Start nginx only if port 80 is not in use
      service:
        name: nginx
        state: started
      when: ansible_port_80 is not defined
```

**Common conditions:**
```yaml
when: ansible_os_family == "Debian"
when: ansible_distribution == "Ubuntu"
when: ansible_distribution_version == "22.04"
when: ansible_hostname == "web1"
when: variable_name is defined
when: variable_name is not defined
when: ansible_memory_mb.real.total > 4096
```

**Multiple conditions (AND):**
```yaml
when:
  - ansible_os_family == "Debian"
  - ansible_distribution_version >= "20.04"
```

**Multiple conditions (OR):**
```yaml
when: ansible_os_family == "Debian" or ansible_os_family == "RedHat"
```

## Loops

Repeat tasks with different values.

**Simple loop:**
```yaml
---
- name: Install multiple packages
  hosts: webservers
  become: true
  
  tasks:
    - name: Install packages
      apt:
        name: "{{ item }}"
        state: present
      loop:
        - nginx
        - git
        - vim
        - curl
        - wget
```

**Loop with dictionary:**
```yaml
---
- name: Create users
  hosts: all
  become: true
  
  tasks:
    - name: Create users
      user:
        name: "{{ item.name }}"
        groups: "{{ item.groups }}"
        state: present
      loop:
        - { name: 'john', groups: 'sudo' }
        - { name: 'jane', groups: 'www-data' }
        - { name: 'bob', groups: 'developers' }
```

**Loop over file contents:**
```yaml
---
- name: Add SSH keys
  hosts: all
  become: true
  
  tasks:
    - name: Add authorized keys
      authorized_key:
        user: ubuntu
        key: "{{ item }}"
      with_file:
        - keys/john.pub
        - keys/jane.pub
```

## Handlers

Handlers run only when notified and only once (even if notified multiple times).

```yaml
---
- name: Configure nginx
  hosts: webservers
  become: true
  
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
    
    - name: Copy nginx config
      copy:
        src: nginx.conf
        dest: /etc/nginx/nginx.conf
      notify: Restart nginx
    
    - name: Copy site config
      copy:
        src: site.conf
        dest: /etc/nginx/sites-available/default
      notify: Restart nginx
  
  handlers:
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
```

**Explanation:**
- Both copy tasks notify "Restart nginx"
- Nginx restarts only ONCE at the end
- Nginx restarts only if files changed
- Handlers run after all tasks complete

## Templates

Templates are files with variables (Jinja2 format).

**Create template file (nginx.conf.j2):**
```nginx
user {{ nginx_user }};
worker_processes {{ nginx_workers }};

events {
    worker_connections {{ worker_connections }};
}

http {
    server {
        listen {{ web_port }};
        server_name {{ server_name }};
        
        root {{ document_root }};
        
        location / {
            try_files $uri $uri/ =404;
        }
    }
}
```

**Use in playbook:**
```yaml
---
- name: Configure nginx with template
  hosts: webservers
  become: true
  
  vars:
    nginx_user: www-data
    nginx_workers: 4
    worker_connections: 1024
    web_port: 80
    server_name: example.com
    document_root: /var/www/html
  
  tasks:
    - name: Deploy nginx config from template
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: Restart nginx
  
  handlers:
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
```

**Template with logic:**
```jinja2
# File: index.html.j2
<h1>Welcome to {{ server_name }}</h1>
<p>Server IP: {{ ansible_default_ipv4.address }}</p>
<p>Environment: {{ environment }}</p>

{% if environment == "production" %}
<p>Running in production mode</p>
{% else %}
<p>Running in development mode</p>
{% endif %}

<h2>Installed packages:</h2>
<ul>
{% for package in packages %}
    <li>{{ package }}</li>
{% endfor %}
</ul>
```

## Roles

Roles organize playbooks into reusable components.

**Role structure:**
```
roles/
  webserver/
    tasks/
      main.yml
    handlers/
      main.yml
    templates/
      nginx.conf.j2
    files/
      index.html
    vars/
      main.yml
    defaults/
      main.yml
```

**Create role:**
```bash
ansible-galaxy init webserver
```

This creates the directory structure above.

**roles/webserver/tasks/main.yml:**
```yaml
---
- name: Install nginx
  apt:
    name: nginx
    state: present

- name: Copy nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Restart nginx

- name: Start nginx
  service:
    name: nginx
    state: started
    enabled: yes
```

**roles/webserver/handlers/main.yml:**
```yaml
---
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

**roles/webserver/defaults/main.yml:**
```yaml
---
nginx_port: 80
nginx_user: www-data
```

**Use role in playbook:**
```yaml
---
- name: Setup webservers
  hosts: webservers
  become: true
  
  roles:
    - webserver
```

**Multiple roles:**
```yaml
---
- name: Setup servers
  hosts: all
  become: true
  
  roles:
    - common
    - security
    - monitoring
    - webserver
```

Roles execute in order listed.

## Complete Real-World Example

Let's deploy a complete web application.

**Project structure:**
```
ansible-project/
  ├── inventory.ini
  ├── playbook.yml
  ├── group_vars/
  │   └── all.yml
  ├── roles/
  │   ├── common/
  │   ├── security/
  │   ├── webserver/
  │   └── database/
  └── files/
      └── app.conf
```

**inventory.ini:**
```ini
[webservers]
web1 ansible_host=192.168.1.100
web2 ansible_host=192.168.1.101

[databases]
db1 ansible_host=192.168.1.200

[all:vars]
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
```

**group_vars/all.yml:**
```yaml
---
# Application settings
app_name: myapp
app_port: 5000
environment: production

# Database settings
db_name: myapp_db
db_user: appuser
db_password: "{{ vault_db_password }}"

# Nginx settings
nginx_port: 80
nginx_workers: 2
```

**playbook.yml:**
```yaml
---
- name: Configure all servers
  hosts: all
  become: true
  
  roles:
    - common

- name: Setup webservers
  hosts: webservers
  become: true
  
  roles:
    - security
    - webserver

- name: Setup database
  hosts: databases
  become: true
  
  roles:
    - security
    - database
```

**roles/common/tasks/main.yml:**
```yaml
---
- name: Update apt cache
  apt:
    update_cache: yes
    cache_valid_time: 3600

- name: Install common packages
  apt:
    name:
      - vim
      - git
      - curl
      - wget
      - htop
    state: present

- name: Set timezone
  timezone:
    name: America/New_York

- name: Configure hostname
  hostname:
    name: "{{ inventory_hostname }}"
```

**roles/security/tasks/main.yml:**
```yaml
---
- name: Install fail2ban
  apt:
    name: fail2ban
    state: present

- name: Start fail2ban
  service:
    name: fail2ban
    state: started
    enabled: yes

- name: Configure firewall
  ufw:
    rule: "{{ item.rule }}"
    port: "{{ item.port }}"
    proto: "{{ item.proto }}"
  loop:
    - { rule: 'allow', port: '22', proto: 'tcp' }
    - { rule: 'allow', port: '80', proto: 'tcp' }
    - { rule: 'allow', port: '443', proto: 'tcp' }

- name: Enable firewall
  ufw:
    state: enabled
```

**roles/webserver/tasks/main.yml:**
```yaml
---
- name: Install nginx
  apt:
    name: nginx
    state: present

- name: Install Python dependencies
  apt:
    name:
      - python3-pip
      - python3-venv
    state: present

- name: Create app directory
  file:
    path: /opt/{{ app_name }}
    state: directory
    owner: www-data
    group: www-data

- name: Deploy nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/sites-available/{{ app_name }}
  notify: Restart nginx

- name: Enable site
  file:
    src: /etc/nginx/sites-available/{{ app_name }}
    dest: /etc/nginx/sites-enabled/{{ app_name }}
    state: link
  notify: Restart nginx

- name: Start nginx
  service:
    name: nginx
    state: started
    enabled: yes
```

**Run playbook:**
```bash
ansible-playbook -i inventory.ini playbook.yml
```

## Ansible Vault (Secrets Management)

Store sensitive data encrypted.

**Create encrypted file:**
```bash
ansible-vault create secrets.yml
```

Enter password, then add content:
```yaml
---
vault_db_password: secretpassword123
vault_api_key: abc123xyz789
```

**Edit encrypted file:**
```bash
ansible-vault edit secrets.yml
```

**View encrypted file:**
```bash
ansible-vault view secrets.yml
```

**Encrypt existing file:**
```bash
ansible-vault encrypt vars.yml
```

**Decrypt file:**
```bash
ansible-vault decrypt vars.yml
```

**Use in playbook:**
```yaml
---
- name: Deploy with secrets
  hosts: all
  become: true
  vars_files:
    - secrets.yml
  
  tasks:
    - name: Create database user
      mysql_user:
        name: appuser
        password: "{{ vault_db_password }}"
        state: present
```

**Run with vault:**
```bash
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
```

Or use password file:
```bash
echo "mypassword" > .vault_pass
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass
```

## Ansible Galaxy

Ansible Galaxy hosts community roles.

**Install role from Galaxy:**
```bash
ansible-galaxy install geerlingguy.nginx
```

**Install to specific directory:**
```bash
ansible-galaxy install geerlingguy.nginx -p ./roles
```

**Install from requirements:**

Create `requirements.yml`:
```yaml
---
- src: geerlingguy.nginx
  version: 3.1.4

- src: geerlingguy.mysql
  version: 4.3.3

- src: https://github.com/user/role.git
  name: custom-role
```

Install all:
```bash
ansible-galaxy install -r requirements.yml
```

**Use installed role:**
```yaml
---
- name: Setup webserver
  hosts: webservers
  become: true
  
  roles:
    - geerlingguy.nginx
```

## Useful Ansible Commands

**Check syntax:**
```bash
ansible-playbook playbook.yml --syntax-check
```

**Dry run (check mode):**
```bash
ansible-playbook -i inventory.ini playbook.yml --check
```

**Show differences:**
```bash
ansible-playbook -i inventory.ini playbook.yml --check --diff
```

**Run specific tasks:**
```bash
ansible-playbook -i inventory.ini playbook.yml --tags "install,configure"
```

**Skip specific tasks:**
```bash
ansible-playbook -i inventory.ini playbook.yml --skip-tags "backup"
```

**Limit to specific hosts:**
```bash
ansible-playbook -i inventory.ini playbook.yml --limit web1,web2
```

**List hosts:**
```bash
ansible all -i inventory.ini --list-hosts
```

**List tasks:**
```bash
ansible-playbook playbook.yml --list-tasks
```

**Verbose output:**
```bash
ansible-playbook -i inventory.ini playbook.yml -v
ansible-playbook -i inventory.ini playbook.yml -vvv
```

## Best Practices

1. **Use version control** for all Ansible code
2. **Use roles** for organization
3. **Use Ansible Vault** for secrets
4. **Use inventory groups** logically
5. **Name all tasks** descriptively
6. **Use handlers** for service restarts
7. **Test with --check** before applying
8. **Use tags** for selective execution
9. **Keep playbooks idempotent**
10. **Document with comments**

## Common Modules Reference

**Package management:**
```yaml
apt:        # Debian/Ubuntu
yum:        # RedHat/CentOS
dnf:        # Fedora
package:    # Generic (auto-detects)
pip:        # Python packages
npm:        # Node packages
```

**Service management:**
```yaml
service:    # Manage services
systemd:    # Systemd-specific
```

**File operations:**
```yaml
copy:       # Copy file
template:   # Template file
file:       # Manage files/directories
lineinfile: # Edit line in file
blockinfile: # Edit block in file
```

**Command execution:**
```yaml
command:    # Run command
shell:      # Run shell command
script:     # Run script
```

**User management:**
```yaml
user:       # Manage users
group:      # Manage groups
authorized_key: # SSH keys
```

**Cloud modules:**
```yaml
ec2:        # AWS EC2
azure_rm_*: # Azure
gcp_*:      # Google Cloud
```

## Troubleshooting

**Connection refused:**
```bash
# Test SSH manually
ssh user@host

# Check SSH key
ssh -i key.pem user@host

# Test with verbose
ansible all -i inventory.ini -m ping -vvv
```

**Permission denied:**
```bash
# Add --become flag
ansible-playbook playbook.yml --become

# Specify sudo password
ansible-playbook playbook.yml --ask-become-pass
```

**Module not found:**
```bash
# Check Python is installed on managed host
ansible all -m raw -a "which python3"

# Specify Python interpreter
ansible all -e ansible_python_interpreter=/usr/bin/python3
```

## Practice Exercises

1. Create inventory with multiple groups
2. Write playbook to install LAMP stack
3. Use variables and templates for configuration
4. Create role for application deployment
5. Implement handlers for service management
6. Use Ansible Vault for database passwords
7. Deploy multi-tier application (web + db)
8. Automate user creation across servers

## Next Steps

Ansible is powerful for configuration management and application deployment. Practice with simple tasks before automating complex infrastructure.

Continue to: `Phase 5 - CI/CD` in `/roadmap/05-cicd/`
