# Phase 4: Infrastructure and Containers

## Overview

Modern applications run in containers, orchestrated by systems like Kubernetes, with infrastructure defined as code. This phase teaches you how to package applications, manage infrastructure programmatically, and deploy at scale.

## Learning Objectives

- Master Docker containerization
- Understand container orchestration with Kubernetes
- Learn Infrastructure as Code with Terraform
- Manage configuration with Ansible
- Deploy and scale applications
- Implement container security best practices
- Design infrastructure architecture

## Time Required

Estimated: 6 weeks with 5-6 hours daily practice

## Why Containers and IaC?

### Before Containers

**Manual Deployment:**
- Install dependencies on server
- Configure environment variables
- Deploy application files
- Configure web server
- Different behavior on different servers
- "Works on my machine" problem

**Issues:**
- Inconsistent environments
- Difficult to reproduce issues
- Long deployment times
- Hard to scale
- Manual configuration prone to errors

### With Containers

**Containerized Deployment:**
- Package application with all dependencies
- Same container runs everywhere
- Consistent environments
- Fast deployment
- Easy scaling
- Infrastructure defined as code

## Module Structure

### Docker
1. `01-docker-basics.md` - Introduction to containers
2. `02-dockerfile.md` - Building container images
3. `03-docker-compose.md` - Multi-container applications
4. `04-docker-networking.md` - Container networking
5. `05-docker-volumes.md` - Data persistence
6. `06-docker-security.md` - Container security

### Kubernetes
7. `07-kubernetes-basics.md` - K8s fundamentals
8. `08-k8s-pods-deployments.md` - Workload management
9. `09-k8s-services-networking.md` - Networking and services
10. `10-k8s-storage.md` - Persistent storage
11. `11-k8s-config-secrets.md` - Configuration management
12. `12-k8s-advanced.md` - Advanced concepts

### Infrastructure as Code
13. `13-terraform-basics.md` - Terraform fundamentals
14. `14-terraform-aws.md` - AWS infrastructure
15. `15-ansible-basics.md` - Configuration management
16. `16-labs.md` - Hands-on projects

## Key Technologies

### Docker - Containerization Platform

**What is a container?**
A lightweight, standalone package containing application and all dependencies.

**Container vs Virtual Machine:**

**Virtual Machine:**
```
Host OS → Hypervisor → Guest OS → Application
Size: GBs, Boot: Minutes
```

**Container:**
```
Host OS → Docker Engine → Container → Application
Size: MBs, Boot: Seconds
```

**Benefits:**
- Lightweight (share host OS kernel)
- Fast startup
- Portable
- Resource efficient
- Version control for infrastructure

**Example Dockerfile:**
```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "app.py"]
```

**What each line does:**
- Line 1: Start from Python 3.9 base image
- Line 3: Set working directory to /app
- Line 5: Copy requirements file
- Line 6: Install Python dependencies
- Line 8: Copy application code
- Line 10: Expose port 8000
- Line 12: Command to run application

### Kubernetes - Container Orchestration

**What is Kubernetes?**
System for automating deployment, scaling, and management of containerized applications.

**Why Kubernetes?**
Docker runs containers on one machine. Kubernetes manages containers across multiple machines.

**Key Concepts:**

**Pod:** Smallest deployable unit, one or more containers

**Deployment:** Manages multiple replicas of pods

**Service:** Exposes pods to network traffic

**Namespace:** Virtual cluster for resource isolation

**Example Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: myapp:1.0
        ports:
        - containerPort: 8000
```

**What this means:**
- Lines 1-2: API version and resource type
- Lines 3-4: Resource name
- Line 6: Run 3 copies (replicas)
- Lines 7-9: Select pods with label app=webapp
- Lines 10-20: Pod template
- Lines 16-20: Container specification

**How Kubernetes works:**
1. You declare desired state (3 replicas)
2. Kubernetes ensures actual state matches desired state
3. If pod crashes, Kubernetes restarts it automatically
4. If node fails, Kubernetes reschedules pods elsewhere

### Terraform - Infrastructure as Code

**What is Terraform?**
Tool for building, changing, and versioning infrastructure safely and efficiently.

**Why Terraform?**
Instead of manually creating cloud resources via web console, define infrastructure in code.

**Benefits:**
- Version control for infrastructure
- Reproducible environments
- Documentation (code is documentation)
- Plan before apply (see changes before executing)
- Multi-cloud support

**Example Terraform:**
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

**What this does:**
- Lines 1-3: Configure AWS provider
- Lines 5-12: Create EC2 instance
- Lines 14-16: Output instance IP address

**Terraform workflow:**
```bash
terraform init    # Initialize providers
terraform plan    # Preview changes
terraform apply   # Apply changes
terraform destroy # Delete infrastructure
```

### Ansible - Configuration Management

**What is Ansible?**
Automation tool for configuration management, application deployment, and task automation.

**Why Ansible?**
After Terraform creates servers, Ansible configures them.

**Benefits:**
- Agentless (uses SSH)
- Simple YAML syntax
- Idempotent operations
- Large module library

**Example Playbook:**
```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
    
    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Copy website files
      copy:
        src: /local/website/
        dest: /var/www/html/
```

**What this does:**
- Lines 2-4: Target webservers group with sudo
- Lines 7-10: Install Nginx package
- Lines 12-16: Start and enable Nginx service
- Lines 18-21: Copy website files to server

## How Everything Connects

### Complete DevOps Workflow

**Development:**
```
Developer writes code → Commits to Git → Pushes to GitHub
```

**CI/CD Pipeline:**
```
GitHub webhook → Jenkins/GitHub Actions triggered
→ Run tests
→ Build Docker image
→ Push to container registry
→ Update Kubernetes deployment
```

**Infrastructure:**
```
Terraform provisions AWS resources
→ Creates VPC, subnets, security groups
→ Launches EC2 instances or EKS cluster
→ Ansible configures instances
→ Installs Docker, Kubernetes agents
→ Configures monitoring agents
```

**Deployment:**
```
Kubernetes pulls container image
→ Creates pods across nodes
→ Service exposes pods via load balancer
→ Traffic routed to healthy pods
→ Prometheus monitors metrics
→ Grafana visualizes dashboards
```

**Monitoring:**
```
Applications send logs → Centralized logging (ELK stack)
Applications expose metrics → Prometheus scrapes metrics
→ Grafana displays dashboards
→ Alertmanager sends notifications
```

## Real-World Example: Deploying Microservices

### 1. Application Structure

```
myapp/
├── frontend/
│   ├── Dockerfile
│   └── src/
├── backend/
│   ├── Dockerfile
│   └── src/
├── database/
│   └── Dockerfile
└── docker-compose.yml
```

### 2. Docker Compose for Local Development

```yaml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend
  
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://db:5432/myapp
    depends_on:
      - database
  
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_PASSWORD: secret
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

**What this does:**
- Defines three services: frontend, backend, database
- Frontend depends on backend (starts after backend)
- Backend depends on database
- Database data persists in named volume
- All services can communicate via service names

**Usage:**
```bash
docker-compose up -d       # Start all services
docker-compose ps          # List running services
docker-compose logs -f     # View logs
docker-compose down        # Stop and remove containers
```

### 3. Kubernetes Deployment for Production

**frontend-deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: myregistry/frontend:1.0
        ports:
        - containerPort: 3000
        env:
        - name: BACKEND_URL
          value: "http://backend:8000"
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 3000
```

**What this creates:**
- Deployment with 3 frontend replicas
- Service exposing frontend via load balancer
- Environment variable pointing to backend service

### 4. Terraform Infrastructure

**main.tf:**
```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "myapp-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = true
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  cluster_name    = "myapp-cluster"
  cluster_version = "1.27"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  eks_managed_node_groups = {
    main = {
      desired_size = 3
      min_size     = 2
      max_size     = 5
      
      instance_types = ["t3.medium"]
    }
  }
}
```

**What this creates:**
- VPC with public and private subnets
- NAT gateway for private subnet internet access
- EKS (Kubernetes) cluster
- Node group with 3 worker nodes (can scale to 5)

## DevOps Best Practices

### 1. Container Best Practices

**Use specific image tags:**
```dockerfile
# Bad
FROM python:latest

# Good
FROM python:3.9.18-slim
```

**Run as non-root user:**
```dockerfile
RUN adduser --disabled-password --gecos '' appuser
USER appuser
```

**Multi-stage builds (smaller images):**
```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM node:18-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/server.js"]
```

### 2. Kubernetes Best Practices

**Set resource limits:**
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

**Use health checks:**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 5
```

**Store secrets securely:**
```yaml
env:
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

### 3. Infrastructure as Code Best Practices

**Use modules for reusability:**
```hcl
module "web_servers" {
  source = "./modules/web-server"
  
  count       = 3
  server_name = "web-${count.index}"
  vpc_id      = module.vpc.id
}
```

**State management:**
```hcl
terraform {
  backend "s3" {
    bucket = "myapp-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```

**Use variables:**
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

resource "aws_instance" "web" {
  tags = {
    Environment = var.environment
  }
}
```

## Learning Path

1. Master Docker fundamentals first
2. Build and run containers locally
3. Learn Kubernetes concepts
4. Deploy applications to Kubernetes
5. Learn Terraform basics
6. Provision cloud infrastructure
7. Combine all skills in complete projects

## Practice Projects

1. **Containerize existing application:** Take Python/Node.js app, create Dockerfile
2. **Multi-container application:** Build app with frontend, backend, database
3. **Kubernetes deployment:** Deploy microservices to K8s cluster
4. **Infrastructure provisioning:** Use Terraform to create AWS resources
5. **Complete CI/CD:** Git → Jenkins → Docker → Kubernetes
6. **Monitoring setup:** Deploy Prometheus and Grafana on Kubernetes
7. **Production-ready architecture:** Multi-region, auto-scaling, monitoring

## Success Criteria

You are ready for Phase 5 when you can:

- [ ] Write Dockerfiles and build images
- [ ] Run multi-container applications with Docker Compose
- [ ] Understand Kubernetes architecture
- [ ] Deploy applications to Kubernetes
- [ ] Write Terraform configurations
- [ ] Provision cloud infrastructure with Terraform
- [ ] Use Ansible for configuration management
- [ ] Debug container and Kubernetes issues
- [ ] Implement security best practices

## Next Steps

Begin with `01-docker-basics.md` to learn containerization fundamentals.

This is one of the most important phases. Containers and IaC are the foundation of modern DevOps. Invest time in understanding these concepts deeply.

Continue to Phase 5 to learn CI/CD and automation pipelines.
