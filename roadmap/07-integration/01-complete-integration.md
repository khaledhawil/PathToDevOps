# Complete DevOps Tool Integration Guide

## Understanding the Big Picture

This guide shows how ALL DevOps tools work together in a real-world scenario. Each tool has a specific purpose, and they integrate to create an automated, scalable infrastructure.

## The Complete DevOps Toolchain

```
Developer Workflow:
1. Write Code (Linux, Bash, Python)
2. Version Control (Git, GitHub)
3. Automated Testing & Building (Jenkins, GitHub Actions)
4. Containerization (Docker)
5. Infrastructure Provisioning (Terraform)
6. Configuration Management (Ansible)
7. Orchestration (Kubernetes)
8. Monitoring (Prometheus, Grafana)
9. Cloud Platform (AWS)
```

## Real-World Scenario: E-commerce Web Application

Let's build and deploy an e-commerce application using ALL DevOps tools.

### The Application Architecture

```
Users (Internet)
    |
    v
Load Balancer (AWS ALB)
    |
    v
Web Servers (Kubernetes Pods)
    |
    v
Application Servers (Kubernetes Pods)
    |
    v
Database (AWS RDS)
    |
    v
Monitoring (Prometheus + Grafana)
```

## Step-by-Step Integration

### Phase 1: Local Development (Linux + Git + Python)

**Developer's machine (Ubuntu):**

**Step 1: Set up development environment**
```bash
# Linux provides the operating system
cd /home/developer/projects

# Create project directory
mkdir ecommerce-app
cd ecommerce-app

# Initialize Git repository
git init
```

**Why Linux here:**
- Provides file system for code
- Runs development tools (Python, Git, Docker)
- Same OS as production servers (consistency)

**Why Git here:**
- Tracks code changes
- Enables collaboration
- Creates history you can revert to

**Step 2: Write application code (Python)**

**app.py:**
```python
from flask import Flask, jsonify
import os

app = Flask(__name__)

# This connects to database (configured by Ansible later)
DATABASE_URL = os.getenv('DATABASE_URL', 'localhost')

@app.route('/')
def home():
    return jsonify({
        'message': 'Welcome to E-commerce API',
        'version': '1.0',
        'database': DATABASE_URL
    })

@app.route('/health')
def health():
    # Kubernetes uses this to check if app is healthy
    return jsonify({'status': 'healthy'})

@app.route('/products')
def products():
    # Later this will query real database
    return jsonify({
        'products': [
            {'id': 1, 'name': 'Laptop', 'price': 999},
            {'id': 2, 'name': 'Phone', 'price': 699}
        ]
    })

if __name__ == '__main__':
    # Docker will expose this port
    app.run(host='0.0.0.0', port=5000)
```

**Why Python here:**
- Web application framework (Flask)
- Easy to write and maintain
- Works well with Docker
- Good for DevOps automation scripts

**How it connects:**
- Python app will run in Docker container
- Docker container will run in Kubernetes pod
- Kubernetes will be deployed by Terraform
- Configuration managed by Ansible

**Step 3: Create tests**

**test_app.py:**
```python
import unittest
from app import app

class TestApp(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
    
    def test_home(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)
    
    def test_health(self):
        # Jenkins will run this test
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['status'], 'healthy')
    
    def test_products(self):
        response = self.app.get('/products')
        self.assertEqual(response.status_code, 200)

if __name__ == '__main__':
    unittest.main()
```

**Why tests here:**
- Jenkins will run these automatically
- Catch bugs before deployment
- Ensure code quality

**Step 4: Commit to Git**
```bash
git add .
git commit -m "Initial application code"
git remote add origin https://github.com/username/ecommerce-app.git
git push -u origin main
```

**What happens next:**
- GitHub receives the code
- GitHub webhook notifies Jenkins
- Jenkins starts CI/CD pipeline

### Phase 2: Containerization (Docker)

**Step 5: Create Dockerfile**

**Dockerfile:**
```dockerfile
# Base image (Linux inside container)
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Copy application code
COPY app.py .
COPY test_app.py .

# Expose port (Kubernetes will map this)
EXPOSE 5000

# Health check (Kubernetes uses this)
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/health || exit 1

# Run application
CMD ["python", "app.py"]
```

**Why Docker here:**
- Packages app with all dependencies
- Runs same way everywhere (dev, test, prod)
- Kubernetes needs containers to orchestrate
- Makes deployment consistent

**How Docker connects to other tools:**
- **From Python:** Docker wraps Python app
- **To Jenkins:** Jenkins builds Docker image
- **To Kubernetes:** Kubernetes runs Docker containers
- **To Docker Hub:** Jenkins pushes images here
- **From Terraform:** Creates EC2 instances with Docker

**Step 6: Build and test locally**
```bash
# Build Docker image
docker build -t ecommerce-app:latest .

# Run container
docker run -d -p 5000:5000 --name ecommerce ecommerce-app:latest

# Test
curl http://localhost:5000/health

# Stop container
docker stop ecommerce
docker rm ecommerce
```

**Step 7: Commit Docker files**
```bash
git add Dockerfile requirements.txt
git commit -m "Add Docker configuration"
git push
```

### Phase 3: CI/CD Automation (Jenkins)

**Step 8: Create Jenkinsfile**

**Jenkinsfile:**
```groovy
pipeline {
    agent any
    
    environment {
        // Docker Hub credentials stored in Jenkins
        DOCKER_HUB_REPO = 'username/ecommerce-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG = credentials('kubeconfig-file')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Stage 1: Pulling code from GitHub'
                // Git integration: Clone repository
                checkout scm
            }
        }
        
        stage('Test') {
            steps {
                echo 'Stage 2: Running Python tests'
                sh '''
                    # Create Python virtual environment
                    python3 -m venv venv
                    . venv/bin/activate
                    
                    # Install dependencies
                    pip install -r requirements.txt
                    
                    # Run tests
                    python -m pytest test_app.py -v
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Stage 3: Building Docker container'
                script {
                    // Docker integration: Build image
                    docker.build("${DOCKER_HUB_REPO}:${DOCKER_TAG}")
                    docker.build("${DOCKER_HUB_REPO}:latest")
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Stage 4: Pushing to Docker Hub'
                script {
                    // Docker Hub integration: Push image
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        docker.image("${DOCKER_HUB_REPO}:${DOCKER_TAG}").push()
                        docker.image("${DOCKER_HUB_REPO}:latest").push()
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Stage 5: Deploying to Kubernetes cluster'
                sh '''
                    # Kubernetes integration: Update deployment
                    kubectl set image deployment/ecommerce-app \
                        ecommerce-app=${DOCKER_HUB_REPO}:${DOCKER_TAG} \
                        --kubeconfig=${KUBECONFIG}
                    
                    # Wait for rollout
                    kubectl rollout status deployment/ecommerce-app \
                        --kubeconfig=${KUBECONFIG}
                '''
            }
        }
        
        stage('Run Ansible Playbook') {
            steps {
                echo 'Stage 6: Configuring servers with Ansible'
                sh '''
                    # Ansible integration: Configure monitoring
                    ansible-playbook -i inventory.ini configure-monitoring.yml
                '''
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Stage 7: Verifying deployment health'
                sh '''
                    # Health check
                    sleep 30
                    curl -f http://load-balancer-url/health || exit 1
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline succeeded!'
            // Prometheus will scrape metrics from this build
        }
        failure {
            echo 'Pipeline failed!'
            // Alert via Prometheus/Grafana
        }
    }
}
```

**Why Jenkins here:**
- Automates entire deployment process
- Triggers on Git push
- Runs tests automatically
- Builds Docker images
- Deploys to Kubernetes
- Runs Ansible playbooks

**How Jenkins connects:**
- **Git:** Pulls code when changes detected
- **Python:** Runs tests
- **Docker:** Builds and pushes images
- **Kubernetes:** Deploys containers
- **Ansible:** Runs configuration playbooks
- **Prometheus:** Reports metrics

### Phase 4: Infrastructure Provisioning (Terraform)

**Step 9: Create AWS infrastructure with Terraform**

**terraform/main.tf:**
```hcl
# Terraform provisions AWS infrastructure

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create VPC (Network)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "ecommerce-vpc"
    ManagedBy = "Terraform"
  }
}

# Create Subnets
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "ecommerce-public-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Create Security Group
resource "aws_security_group" "k8s_cluster" {
  name        = "k8s-cluster-sg"
  description = "Security group for Kubernetes cluster"
  vpc_id      = aws_vpc.main.id
  
  # Allow SSH (for Ansible)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTP (for application)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow Prometheus metrics
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances for Kubernetes cluster
resource "aws_instance" "k8s_master" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public.id
  
  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  
  # User data to install Docker (required by Kubernetes)
  user_data = <<-EOF
              #!/bin/bash
              # Install Docker
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh
              
              # Install kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              install kubectl /usr/local/bin/
              
              # Ansible will configure the rest
              EOF
  
  tags = {
    Name = "k8s-master"
    Role = "Kubernetes-Master"
  }
}

resource "aws_instance" "k8s_worker" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.small"
  subnet_id     = aws_subnet.public.id
  
  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  
  user_data = <<-EOF
              #!/bin/bash
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh
              EOF
  
  tags = {
    Name = "k8s-worker-${count.index + 1}"
    Role = "Kubernetes-Worker"
  }
}

# Create RDS database
resource "aws_db_instance" "ecommerce_db" {
  identifier = "ecommerce-db"
  engine     = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type      = "gp2"
  
  db_name  = "ecommerce"
  username = "admin"
  password = "changeme123"  # Use Terraform variables in real scenario
  
  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]
  
  skip_final_snapshot = true
  
  tags = {
    Name = "ecommerce-database"
  }
}

# Output values (used by Ansible and Kubernetes)
output "k8s_master_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "k8s_worker_ips" {
  value = aws_instance.k8s_worker[*].public_ip
}

output "database_endpoint" {
  value = aws_db_instance.ecommerce_db.endpoint
}
```

**Why Terraform here:**
- Creates AWS infrastructure as code
- Provisions VPC, subnets, security groups
- Creates EC2 instances for Kubernetes
- Creates RDS database
- Reproducible and version-controlled

**How Terraform connects:**
- **To AWS:** Provisions cloud resources
- **To Ansible:** Outputs server IPs for configuration
- **To Kubernetes:** Creates servers for K8s cluster
- **To Docker:** Installs Docker on EC2 instances
- **To Prometheus:** Opens metrics ports

**Step 10: Deploy infrastructure**
```bash
cd terraform

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Create infrastructure
terraform apply -auto-approve

# Get outputs
terraform output k8s_master_ip
terraform output k8s_worker_ips
```

**What Terraform created:**
- VPC with networking
- Security groups with firewall rules
- 3 EC2 instances (1 master, 2 workers)
- RDS PostgreSQL database
- All tagged and documented

### Phase 5: Configuration Management (Ansible)

**Step 11: Configure servers with Ansible**

**ansible/inventory.ini:**
```ini
# Inventory uses Terraform outputs

[k8s_master]
master ansible_host=TERRAFORM_OUTPUT_MASTER_IP ansible_user=ubuntu

[k8s_workers]
worker1 ansible_host=TERRAFORM_OUTPUT_WORKER1_IP ansible_user=ubuntu
worker2 ansible_host=TERRAFORM_OUTPUT_WORKER2_IP ansible_user=ubuntu

[k8s_cluster:children]
k8s_master
k8s_workers

[k8s_cluster:vars]
ansible_python_interpreter=/usr/bin/python3
```

**ansible/setup-kubernetes.yml:**
```yaml
---
# This playbook configures Kubernetes cluster

- name: Configure all nodes
  hosts: k8s_cluster
  become: true
  
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
    
    - name: Install required packages
      apt:
        name:
          - docker.io
          - curl
          - apt-transport-https
        state: present
    
    - name: Start Docker service
      service:
        name: docker
        state: started
        enabled: yes
    
    - name: Add Kubernetes repository
      shell: |
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
    
    - name: Install Kubernetes components
      apt:
        name:
          - kubelet
          - kubeadm
          - kubectl
        state: present
        update_cache: yes

- name: Initialize Kubernetes master
  hosts: k8s_master
  become: true
  
  tasks:
    - name: Initialize cluster
      shell: kubeadm init --pod-network-cidr=10.244.0.0/16
      register: kubeadm_output
    
    - name: Create .kube directory
      file:
        path: /home/ubuntu/.kube
        state: directory
        owner: ubuntu
    
    - name: Copy admin config
      copy:
        src: /etc/kubernetes/admin.conf
        dest: /home/ubuntu/.kube/config
        remote_src: yes
        owner: ubuntu
    
    - name: Install Flannel network
      shell: kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
      become_user: ubuntu
    
    - name: Get join command
      shell: kubeadm token create --print-join-command
      register: join_command

- name: Join worker nodes
  hosts: k8s_workers
  become: true
  
  tasks:
    - name: Join cluster
      shell: "{{ hostvars['master']['join_command'].stdout }}"

- name: Deploy application
  hosts: k8s_master
  become: true
  become_user: ubuntu
  
  tasks:
    - name: Create deployment YAML
      copy:
        dest: /home/ubuntu/deployment.yml
        content: |
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: ecommerce-app
          spec:
            replicas: 3
            selector:
              matchLabels:
                app: ecommerce
            template:
              metadata:
                labels:
                  app: ecommerce
              spec:
                containers:
                - name: ecommerce-app
                  image: username/ecommerce-app:latest
                  ports:
                  - containerPort: 5000
                  env:
                  - name: DATABASE_URL
                    value: "{{ database_endpoint }}"
    
    - name: Apply deployment
      shell: kubectl apply -f /home/ubuntu/deployment.yml
```

**Why Ansible here:**
- Configures all servers consistently
- Installs Kubernetes on EC2 instances
- Joins worker nodes to cluster
- Deploys application to Kubernetes
- Idempotent (safe to run multiple times)

**How Ansible connects:**
- **From Terraform:** Gets server IPs to configure
- **To Linux:** Uses SSH to configure Ubuntu servers
- **To Docker:** Ensures Docker is running
- **To Kubernetes:** Installs and configures K8s
- **From Jenkins:** Called in CI/CD pipeline

**Step 12: Run Ansible playbook**
```bash
cd ansible

# Run playbook
ansible-playbook -i inventory.ini setup-kubernetes.yml

# Verify
ansible k8s_cluster -i inventory.ini -m ping
```

**What Ansible configured:**
- Installed Kubernetes on all nodes
- Initialized master node
- Joined worker nodes
- Deployed application
- Configured networking

### Phase 6: Monitoring (Prometheus + Grafana)

**Step 13: Deploy monitoring stack**

**ansible/setup-monitoring.yml:**
```yaml
---
- name: Install Prometheus and Grafana
  hosts: k8s_master
  become: true
  
  tasks:
    - name: Create monitoring namespace
      shell: kubectl create namespace monitoring
      ignore_errors: yes
    
    - name: Deploy Prometheus
      shell: |
        kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml
      
    - name: Create ServiceMonitor for app
      copy:
        dest: /tmp/servicemonitor.yml
        content: |
          apiVersion: monitoring.coreos.com/v1
          kind: ServiceMonitor
          metadata:
            name: ecommerce-monitor
            namespace: monitoring
          spec:
            selector:
              matchLabels:
                app: ecommerce
            endpoints:
            - port: metrics
              interval: 30s
      
    - name: Apply ServiceMonitor
      shell: kubectl apply -f /tmp/servicemonitor.yml
    
    - name: Install Grafana
      shell: |
        kubectl apply -f https://raw.githubusercontent.com/grafana/grafana/main/deploy/kubernetes/grafana.yaml
```

**Why Prometheus + Grafana:**
- Monitors application health
- Collects metrics from Kubernetes
- Alerts on problems
- Visualizes system performance

**How monitoring connects:**
- **To Kubernetes:** Scrapes metrics from pods
- **To Docker:** Monitors container resource usage
- **From Jenkins:** Receives build metrics
- **To AWS:** Monitors EC2 instance health
- **To Python app:** Scrapes /metrics endpoint

### Complete Integration Flow

**The complete flow when developer pushes code:**

```
1. Developer writes Python code
   └─> Uses Linux for development
   └─> Uses Git for version control

2. Developer pushes to GitHub
   └─> Git tracks changes
   └─> GitHub stores code

3. GitHub webhook triggers Jenkins
   └─> Jenkins pulls code from Git
   └─> Jenkins runs Python tests
   
4. Jenkins builds Docker image
   └─> Docker packages Python app
   └─> Docker image pushed to Docker Hub

5. Jenkins deploys to Kubernetes
   └─> Kubernetes pulls Docker image
   └─> Kubernetes runs containers on AWS EC2
   └─> Infrastructure created by Terraform
   └─> Servers configured by Ansible

6. Application runs on AWS
   └─> Load balancer distributes traffic
   └─> Kubernetes manages pods
   └─> Connects to RDS database

7. Prometheus monitors everything
   └─> Collects metrics from Kubernetes
   └─> Collects metrics from application
   └─> Grafana visualizes metrics
   └─> Alerts if problems detected

8. Cycle repeats on next code push
```

## Tool Relationship Summary

### Linux
**Role:** Operating system foundation
**Connects to:** Everything runs on Linux
**Used by:** Docker containers, Kubernetes pods, EC2 instances, developer machine

### Git/GitHub
**Role:** Version control and code storage
**Connects to:** 
- Developers push code
- Jenkins pulls code
- Stores Infrastructure as Code (Terraform, Ansible)

### Python
**Role:** Application code
**Connects to:**
- Packaged by Docker
- Tested by Jenkins
- Runs in Kubernetes

### Docker
**Role:** Containerization
**Connects to:**
- Wraps Python application
- Built by Jenkins
- Runs on Kubernetes
- Uses Linux kernel features

### Terraform
**Role:** Infrastructure provisioning
**Connects to:**
- Creates AWS resources (VPC, EC2, RDS)
- Outputs used by Ansible
- Manages state in S3

### Ansible
**Role:** Configuration management
**Connects to:**
- Configures servers created by Terraform
- Installs Kubernetes
- Deploys applications
- Triggered by Jenkins

### Kubernetes
**Role:** Container orchestration
**Connects to:**
- Runs Docker containers
- Deployed on EC2 (from Terraform)
- Configured by Ansible
- Updated by Jenkins
- Monitored by Prometheus

### Jenkins
**Role:** CI/CD automation
**Connects to:**
- Pulls from Git
- Tests Python code
- Builds Docker images
- Deploys to Kubernetes
- Runs Ansible playbooks

### AWS
**Role:** Cloud infrastructure
**Connects to:**
- Hosts EC2 instances (Kubernetes nodes)
- Provides RDS database
- Created by Terraform
- Monitored by Prometheus

### Prometheus + Grafana
**Role:** Monitoring and alerting
**Connects to:**
- Monitors Kubernetes
- Monitors Docker containers
- Monitors EC2 instances
- Receives Jenkins metrics
- Visualizes everything

## Practical Exercise: Deploy Complete Stack

Follow these steps to deploy the complete integrated system:

**Day 1: Setup**
1. Install tools on local machine (Git, Docker, Terraform, Ansible)
2. Create AWS account and configure credentials
3. Fork the ecommerce-app repository

**Day 2: Infrastructure**
1. Run Terraform to create AWS infrastructure
2. Run Ansible to configure Kubernetes cluster
3. Verify cluster is operational

**Day 3: CI/CD**
1. Install Jenkins
2. Configure Jenkins credentials (GitHub, Docker Hub, AWS)
3. Create pipeline job

**Day 4: Deployment**
1. Make code change
2. Push to GitHub
3. Watch automated pipeline
4. Verify application is running

**Day 5: Monitoring**
1. Deploy Prometheus and Grafana
2. Configure dashboards
3. Set up alerts
4. Test end-to-end system

## Troubleshooting Integration Issues

**Issue: Jenkins can't connect to Git**
**Solution:** Check GitHub credentials in Jenkins, verify network connectivity

**Issue: Docker build fails in Jenkins**
**Solution:** Ensure Docker is installed and Jenkins user is in docker group

**Issue: Terraform fails to create resources**
**Solution:** Verify AWS credentials, check IAM permissions

**Issue: Ansible can't connect to servers**
**Solution:** Check SSH keys, verify security group allows SSH

**Issue: Kubernetes pods won't start**
**Solution:** Check Docker image exists, verify resource limits

**Issue: Prometheus not collecting metrics**
**Solution:** Ensure ServiceMonitor is configured, check network policies

## Next Steps

You now understand how all DevOps tools integrate. Practice each tool individually, then combine them progressively:

1. Master Linux and Git basics
2. Learn Docker containerization
3. Practice with Kubernetes
4. Automate with Jenkins
5. Provision with Terraform
6. Configure with Ansible
7. Monitor with Prometheus

Each tool makes the others more powerful!
