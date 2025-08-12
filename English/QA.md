# Comprehensive DevOps, Linux, and Cloud Q&A Guide

## Table of Contents
1. [Linux Administration Questions](#linux-administration-questions)
2. [DevOps Fundamentals](#devops-fundamentals)
3. [Cloud Computing (AWS/Azure/GCP)](#cloud-computing)
4. [Docker and Containers](#docker-and-containers)
5. [Kubernetes Questions](#kubernetes-questions)
6. [CI/CD Pipeline Questions](#cicd-pipeline-questions)
7. [Infrastructure as Code (IaC)](#infrastructure-as-code)
8. [Monitoring and Logging](#monitoring-and-logging)
9. [Security and Compliance](#security-and-compliance)
10. [Networking Questions](#networking-questions)
11. [Database and Storage](#database-and-storage)
12. [Troubleshooting Scenarios](#troubleshooting-scenarios)

---

## Linux Administration Questions

### Q1: What is the difference between hard links and soft links in Linux?

**Answer:**
- **Hard Link**: Points directly to the inode of a file. Multiple hard links share the same inode number and data blocks.
  - Cannot cross file systems
  - Cannot link to directories
  - File persists as long as at least one hard link exists
  
- **Soft Link (Symbolic Link)**: Points to the pathname of another file
  - Can cross file systems
  - Can link to directories
  - If original file is deleted, soft link becomes broken

**Commands:**
```bash
# Create hard link
ln original_file hard_link

# Create soft link
ln -s original_file soft_link

# Check inode numbers
ls -li file*
```

### Q2: How do you find and kill processes in Linux?

**Answer:**
```bash
# Find processes by name
ps aux | grep process_name
pgrep process_name
pidof process_name

# Find processes by port
netstat -tulpn | grep :8080
lsof -i :8080

# Kill processes
kill PID
kill -9 PID  # Force kill
killall process_name
pkill process_name

# Kill all processes of a user
pkill -u username
```

### Q3: Explain Linux file permissions and how to change them.

**Answer:**
Linux uses a 3-digit octal system (rwx):
- **r (read)**: 4
- **w (write)**: 2  
- **x (execute)**: 1

**Permission structure**: owner|group|others

```bash
# Numeric method
chmod 755 file  # rwxr-xr-x
chmod 644 file  # rw-r--r--

# Symbolic method
chmod u+x file      # Add execute for owner
chmod g-w file      # Remove write for group
chmod o=r file      # Set only read for others
chmod a+r file      # Add read for all

# Change ownership
chown user:group file
chgrp group file

# Recursive permissions
chmod -R 755 directory/
```

### Q4: What are systemd services and how do you manage them?

**Answer:**
Systemd is the init system for modern Linux distributions.

```bash
# Service management
systemctl start service_name
systemctl stop service_name
systemctl restart service_name
systemctl reload service_name
systemctl status service_name

# Enable/disable services
systemctl enable service_name   # Start at boot
systemctl disable service_name  # Don't start at boot

# List services
systemctl list-units --type=service
systemctl list-unit-files --type=service

# View logs
journalctl -u service_name
journalctl -f -u service_name  # Follow logs

# Create custom service
sudo vim /etc/systemd/system/myapp.service
sudo systemctl daemon-reload
```

### Q5: How do you monitor system performance in Linux?

**Answer:**
```bash
# CPU and memory usage
top
htop
vmstat 1
iostat 1

# Memory information
free -h
cat /proc/meminfo

# Disk usage
df -h
du -sh /path/*
lsblk

# Network monitoring
netstat -i
ss -tuln
iftop
nload

# Process monitoring
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head

# System load
uptime
w
cat /proc/loadavg
```

### Q6: Explain cron jobs and how to schedule tasks.

**Answer:**
Cron is used for scheduling recurring tasks.

**Cron format**: `minute hour day_of_month month day_of_week command`

```bash
# Edit crontab
crontab -e

# List cron jobs
crontab -l

# Examples:
# Run every minute
* * * * * /path/to/script.sh

# Run at 2:30 AM daily
30 2 * * * /backup/script.sh

# Run every Monday at 9 AM
0 9 * * 1 /weekly/report.sh

# Run every 15 minutes
*/15 * * * * /monitor/check.sh

# System-wide crons
ls /etc/cron.d/
ls /etc/cron.daily/
ls /etc/cron.weekly/
```

### Q7: How do you manage disk space and filesystems?

**Answer:**
```bash
# Check disk usage
df -h
du -sh /*
ncdu /  # Interactive disk usage

# Find large files
find / -type f -size +100M 2>/dev/null
find /var/log -type f -size +50M

# Clean up
# Log files
sudo journalctl --vacuum-time=7d
sudo find /var/log -name "*.log" -mtime +30 -delete

# Package cache
sudo apt autoremove
sudo apt autoclean

# Filesystem operations
# Create filesystem
sudo mkfs.ext4 /dev/sdb1

# Mount filesystem
sudo mount /dev/sdb1 /mnt/data
sudo umount /mnt/data

# Permanent mounts
sudo vim /etc/fstab
/dev/sdb1 /mnt/data ext4 defaults 0 2

# Check filesystem
sudo fsck /dev/sdb1
```

---

## DevOps Fundamentals

### Q8: What is DevOps and what are its core principles?

**Answer:**
DevOps is a cultural and technical movement that emphasizes collaboration between Development and Operations teams.

**Core Principles:**
1. **Collaboration**: Breaking down silos between teams
2. **Automation**: Automate repetitive tasks and processes
3. **Continuous Integration**: Frequent code integration
4. **Continuous Delivery**: Automated deployment pipeline
5. **Monitoring**: Continuous monitoring and feedback
6. **Infrastructure as Code**: Manage infrastructure through code

**Benefits:**
- Faster deployment cycles
- Improved collaboration
- Higher quality software
- Better system reliability
- Faster recovery from failures

### Q9: Explain the CI/CD pipeline and its stages.

**Answer:**
**CI/CD Pipeline stages:**

1. **Source Control**: Code committed to version control (Git)
2. **Build**: Compile and package the application
3. **Test**: Run automated tests (unit, integration, security)
4. **Deploy to Staging**: Deploy to staging environment
5. **Integration Testing**: Run tests in staging
6. **Deploy to Production**: Deploy to production environment
7. **Monitor**: Monitor application performance and health

**Example Jenkins Pipeline:**
```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/user/repo.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker build -t myapp .'
                sh 'docker run -d -p 8080:8080 myapp'
            }
        }
    }
}
```

### Q10: What is Infrastructure as Code (IaC) and its benefits?

**Answer:**
Infrastructure as Code is the practice of managing infrastructure through machine-readable definition files.

**Tools:**
- **Terraform**: Multi-cloud infrastructure provisioning
- **Ansible**: Configuration management and automation
- **CloudFormation**: AWS-specific infrastructure
- **ARM Templates**: Azure-specific infrastructure

**Benefits:**
- Version control for infrastructure
- Consistent environments
- Faster provisioning
- Reduced human errors
- Easy rollback capabilities
- Documentation as code

**Example Terraform:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"
  }
}

resource "aws_security_group" "web_sg" {
  name_prefix = "web-"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

## Cloud Computing

### Q11: Compare AWS, Azure, and Google Cloud Platform.

**Answer:**

| Feature | AWS | Azure | GCP |
|---------|-----|-------|-----|
| **Market Share** | Largest (32%) | Second (20%) | Third (9%) |
| **Compute** | EC2 | Virtual Machines | Compute Engine |
| **Storage** | S3 | Blob Storage | Cloud Storage |
| **Database** | RDS, DynamoDB | SQL Database | Cloud SQL |
| **Container** | EKS, ECS | AKS | GKE |
| **Serverless** | Lambda | Functions | Cloud Functions |
| **AI/ML** | SageMaker | Machine Learning | AI Platform |

**Strengths:**
- **AWS**: Mature ecosystem, extensive services
- **Azure**: Strong enterprise integration, hybrid cloud
- **GCP**: Advanced AI/ML, competitive pricing

### Q12: Explain AWS VPC and its components.

**Answer:**
Amazon VPC (Virtual Private Cloud) provides isolated network environment in AWS.

**Components:**
1. **Subnets**: Logical subdivision of IP network
   - Public subnet: Routes to Internet Gateway
   - Private subnet: No direct internet access

2. **Internet Gateway**: Connects VPC to internet

3. **NAT Gateway**: Allows outbound internet access for private subnets

4. **Route Tables**: Controls traffic routing

5. **Security Groups**: Instance-level firewall

6. **NACLs**: Subnet-level firewall

**Example VPC Setup:**
```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create subnets
aws ec2 create-subnet --vpc-id vpc-12345 --cidr-block 10.0.1.0/24  # Public
aws ec2 create-subnet --vpc-id vpc-12345 --cidr-block 10.0.2.0/24  # Private

# Create Internet Gateway
aws ec2 create-internet-gateway
aws ec2 attach-internet-gateway --vpc-id vpc-12345 --internet-gateway-id igw-12345
```

### Q13: What are AWS Auto Scaling Groups and Load Balancers?

**Answer:**
**Auto Scaling Groups (ASG):**
- Automatically adjust the number of EC2 instances
- Based on demand or schedule
- Ensures high availability

**Types of Load Balancers:**
1. **Application Load Balancer (ALB)**: Layer 7, HTTP/HTTPS
2. **Network Load Balancer (NLB)**: Layer 4, TCP/UDP
3. **Classic Load Balancer**: Legacy, Layer 4 and 7

**ASG Configuration:**
```json
{
  "AutoScalingGroupName": "web-asg",
  "MinSize": 2,
  "MaxSize": 10,
  "DesiredCapacity": 4,
  "LaunchTemplate": {
    "LaunchTemplateName": "web-template",
    "Version": "1"
  },
  "TargetGroupARNs": ["arn:aws:elasticloadbalancing:..."],
  "HealthCheckType": "ELB",
  "HealthCheckGracePeriod": 300
}
```

### Q14: Explain containerization and its benefits.

**Answer:**
Containerization packages applications with their dependencies into portable containers.

**Benefits:**
- Consistency across environments
- Resource efficiency
- Fast startup times
- Scalability
- Isolation
- Portability

**Docker vs Traditional VMs:**
| Aspect | Containers | VMs |
|--------|------------|-----|
| **Resource Usage** | Lower | Higher |
| **Startup Time** | Seconds | Minutes |
| **Isolation** | Process-level | Hardware-level |
| **Portability** | High | Medium |

---

## Docker and Containers

### Q15: Explain Docker architecture and components.

**Answer:**
**Docker Architecture:**
1. **Docker Client**: Command-line interface
2. **Docker Daemon**: Background service managing containers
3. **Docker Images**: Read-only templates
4. **Docker Containers**: Running instances of images
5. **Docker Registry**: Repository for images (Docker Hub)

**Key Commands:**
```bash
# Image management
docker build -t myapp:v1.0 .
docker images
docker pull nginx:latest
docker push myapp:v1.0

# Container management
docker run -d -p 8080:80 nginx
docker ps
docker ps -a
docker logs container_id
docker exec -it container_id bash
docker stop container_id
docker rm container_id

# Volume management
docker volume create myvolume
docker run -v myvolume:/data nginx

# Network management
docker network create mynetwork
docker run --network mynetwork nginx
```

### Q16: What is a Dockerfile and how do you optimize it?

**Answer:**
Dockerfile is a text file containing instructions to build Docker images.

**Best Practices:**
```dockerfile
# Use specific base image versions
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package files first (for layer caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Change ownership
RUN chown -R nextjs:nodejs /app
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
```

**Optimization Tips:**
- Use multi-stage builds
- Minimize layers
- Use .dockerignore
- Cache dependencies
- Use non-root users
- Include health checks

### Q17: What is Docker Compose and how do you use it?

**Answer:**
Docker Compose is a tool for defining multi-container applications.

**Example docker-compose.yml:**
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:80"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
      - redis
    volumes:
      - ./app:/usr/src/app
    networks:
      - app-network

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data
    networks:
      - app-network

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

**Commands:**
```bash
# Start services
docker-compose up -d

# Scale services
docker-compose up -d --scale web=3

# View logs
docker-compose logs -f web

# Stop services
docker-compose down

# Remove everything including volumes
docker-compose down -v
```

---

## Kubernetes Questions

### Q18: Explain Kubernetes architecture and components.

**Answer:**
**Master Node Components:**
1. **API Server**: Central management component
2. **etcd**: Distributed key-value store
3. **Controller Manager**: Manages controllers
4. **Scheduler**: Assigns pods to nodes

**Worker Node Components:**
1. **kubelet**: Node agent
2. **kube-proxy**: Network proxy
3. **Container Runtime**: Docker/containerd

**Key Resources:**
- **Pod**: Smallest deployable unit
- **Service**: Network endpoint for pods
- **Deployment**: Manages replica sets
- **ConfigMap**: Configuration data
- **Secret**: Sensitive data

### Q19: How do you deploy an application to Kubernetes?

**Answer:**
**Deployment Example:**
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi

---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```

**Deployment Commands:**
```bash
# Apply manifests
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Check status
kubectl get deployments
kubectl get pods
kubectl get services

# Scale deployment
kubectl scale deployment web-app --replicas=5

# Update deployment
kubectl set image deployment/web-app web=nginx:1.22

# View logs
kubectl logs -f deployment/web-app
```

### Q20: Explain Kubernetes networking and services.

**Answer:**
**Service Types:**
1. **ClusterIP**: Internal cluster communication (default)
2. **NodePort**: Exposes service on each node's IP
3. **LoadBalancer**: External load balancer
4. **ExternalName**: Maps to external DNS name

**Networking Components:**
- **CNI Plugin**: Container Network Interface (Flannel, Calico)
- **Ingress**: HTTP/HTTPS routing
- **Network Policies**: Traffic control between pods

**Example Ingress:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
```

### Q21: How do you manage configuration and secrets in Kubernetes?

**Answer:**
**ConfigMap Example:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://localhost:5432/mydb"
  log_level: "info"
  config.json: |
    {
      "api_endpoint": "https://api.example.com",
      "timeout": 30
    }
```

**Secret Example:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: MWYyZDFlMmU2N2Rm  # base64 encoded
```

**Using in Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: password
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

---

## CI/CD Pipeline Questions

### Q22: How do you implement a complete CI/CD pipeline?

**Answer:**
**Pipeline Structure:**
1. **Source**: Git repository with webhooks
2. **Build**: Compile, test, package
3. **Security**: Vulnerability scanning
4. **Deploy**: Staging and production deployment
5. **Monitor**: Application monitoring

**Jenkins Pipeline Example:**
```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'your-registry.com'
        APP_NAME = 'myapp'
        KUBECONFIG = credentials('kubeconfig')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    def app = docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm test'
                    }
                }
                stage('Security Scan') {
                    steps {
                        sh 'trivy image ${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}'
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'registry-credentials') {
                        docker.image("${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}").push()
                        docker.image("${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}").push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                sh """
                    kubectl set image deployment/${APP_NAME} \
                    ${APP_NAME}=${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER} \
                    -n staging
                """
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh 'npm run test:integration'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                sh """
                    kubectl set image deployment/${APP_NAME} \
                    ${APP_NAME}=${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER} \
                    -n production
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            emailext (
                subject: "Pipeline Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output.",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

### Q23: What is GitOps and how does it work?

**Answer:**
GitOps is a methodology that uses Git as the single source of truth for infrastructure and application deployment.

**Core Principles:**
1. **Declarative**: System state described declaratively
2. **Versioned**: All changes tracked in Git
3. **Pulled**: Changes pulled automatically
4. **Monitored**: System continuously monitored

**GitOps Workflow:**
```yaml
# Application Repository
.
├── src/
├── Dockerfile
├── .github/
│   └── workflows/
│       └── ci.yml
└── k8s/
    ├── deployment.yaml
    └── service.yaml

# GitOps Repository
.
├── environments/
│   ├── staging/
│   │   ├── app1/
│   │   └── app2/
│   └── production/
│       ├── app1/
│       └── app2/
└── infrastructure/
    ├── monitoring/
    └── ingress/
```

**ArgoCD Example:**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/company/gitops-repo
    targetRevision: HEAD
    path: environments/production/myapp
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## Infrastructure as Code

### Q24: Compare Terraform with other IaC tools.

**Answer:**
| Tool | Type | Cloud Support | Language |
|------|------|---------------|----------|
| **Terraform** | Provisioning | Multi-cloud | HCL |
| **Ansible** | Configuration | Any | YAML |
| **CloudFormation** | Provisioning | AWS only | JSON/YAML |
| **Pulumi** | Provisioning | Multi-cloud | Multiple languages |

**Terraform Example:**
```hcl
# variables.tf
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
    Type = "public"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}
```

### Q25: How do you manage Terraform state and handle team collaboration?

**Answer:**
**Remote State Backend:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "production/infrastructure.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

**Best Practices:**
1. **Remote State**: Store state in S3/Azure Storage
2. **State Locking**: Use DynamoDB for locking
3. **Workspaces**: Separate environments
4. **Modules**: Reusable components
5. **Version Pinning**: Lock provider versions

**Team Workflow:**
```bash
# Initialize
terraform init

# Plan changes
terraform plan -var-file=production.tfvars

# Apply changes
terraform apply -var-file=production.tfvars

# Use workspaces
terraform workspace new production
terraform workspace select production
```

---

## Monitoring and Logging

### Q26: How do you implement comprehensive monitoring for applications?

**Answer:**
**Monitoring Stack:**
1. **Metrics**: Prometheus + Grafana
2. **Logs**: ELK Stack (Elasticsearch, Logstash, Kibana)
3. **Traces**: Jaeger/Zipkin
4. **Alerting**: AlertManager + PagerDuty

**Prometheus Configuration:**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
```

**Alert Rules:**
```yaml
# alert_rules.yml
groups:
- name: application
  rules:
  - alert: HighCPUUsage
    expr: cpu_usage_percent > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      description: "CPU usage is above 80% for more than 5 minutes"

  - alert: ApplicationDown
    expr: up{job="myapp"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Application is down"
      description: "Application {{ $labels.instance }} is down"
```

### Q27: What is observability and how is it different from monitoring?

**Answer:**
**Monitoring vs Observability:**

| Monitoring | Observability |
|------------|---------------|
| Known unknowns | Unknown unknowns |
| Predefined metrics | Exploratory analysis |
| Reactive | Proactive |
| Dashboards | Ad-hoc queries |

**Three Pillars of Observability:**
1. **Metrics**: Numerical data over time
2. **Logs**: Discrete events with context
3. **Traces**: Request flow through systems

**Implementation Example:**
```yaml
# Application instrumentation
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:latest
        env:
        - name: JAEGER_AGENT_HOST
          value: "jaeger-agent"
        - name: JAEGER_SAMPLER_TYPE
          value: "const"
        - name: JAEGER_SAMPLER_PARAM
          value: "1"
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 8090
          name: metrics
```

---

## Security and Compliance

### Q28: What are security best practices for containerized applications?

**Answer:**
**Container Security Best Practices:**

1. **Image Security:**
```dockerfile
# Use specific, minimal base images
FROM alpine:3.18

# Don't run as root
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy only necessary files
COPY --chown=appuser:appgroup app/ /app/

# Use non-root user
USER appuser

# Set read-only filesystem
VOLUME ["/tmp"]
```

2. **Runtime Security:**
```yaml
# Pod Security Context
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    runAsGroup: 1001
    fsGroup: 1001
  containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 50m
        memory: 64Mi
```

3. **Network Security:**
```yaml
# Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-traffic
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### Q29: How do you implement secrets management?

**Answer:**
**Secrets Management Tools:**
1. **HashiCorp Vault**: Enterprise secret management
2. **AWS Secrets Manager**: AWS-native solution
3. **Azure Key Vault**: Azure-native solution
4. **Kubernetes Secrets**: Basic secret storage

**Vault Integration:**
```yaml
# Vault Agent Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: vault-agent-config
data:
  vault-agent.hcl: |
    exit_after_auth = true
    pid_file = "/tmp/pidfile"

    auto_auth {
      method "kubernetes" {
        mount_path = "auth/kubernetes"
        config = {
          role = "myapp"
        }
      }
      sink "file" {
        config = {
          path = "/vault/secrets/.vault-token"
        }
      }
    }

    template {
      source = "/vault/configs/database.tpl"
      destination = "/vault/secrets/database"
    }

---
# Pod with Vault Agent
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: vault-auth
  initContainers:
  - name: vault-agent
    image: vault:latest
    command: ['vault', 'agent', '-config=/vault/configs/vault-agent.hcl']
    volumeMounts:
    - name: vault-config
      mountPath: /vault/configs
    - name: vault-secrets
      mountPath: /vault/secrets
  containers:
  - name: app
    image: myapp:latest
    volumeMounts:
    - name: vault-secrets
      mountPath: /etc/secrets
  volumes:
  - name: vault-config
    configMap:
      name: vault-agent-config
  - name: vault-secrets
    emptyDir: {}
```

---

## Networking Questions

### Q30: Explain load balancing algorithms and when to use each.

**Answer:**
**Load Balancing Algorithms:**

1. **Round Robin**: Distributes requests evenly
   - Use: When all servers have equal capacity
   - Simple and fair distribution

2. **Least Connections**: Routes to server with fewest active connections
   - Use: When request processing time varies
   - Better for persistent connections

3. **Weighted Round Robin**: Assigns weights based on server capacity
   - Use: When servers have different capacities
   - Allows proportional distribution

4. **IP Hash**: Routes based on client IP hash
   - Use: When session affinity is needed
   - Ensures same client hits same server

5. **Least Response Time**: Routes to fastest responding server
   - Use: When server performance varies
   - Optimizes for response time

**HAProxy Configuration:**
```bash
# /etc/haproxy/haproxy.cfg
global
    daemon
    maxconn 4096

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend web_frontend
    bind *:80
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk GET /health
    server web1 10.0.1.10:8080 check
    server web2 10.0.1.11:8080 check
    server web3 10.0.1.12:8080 check weight 2
```

### Q31: How do you troubleshoot network connectivity issues?

**Answer:**
**Network Troubleshooting Steps:**

```bash
# 1. Check network interface
ip addr show
ifconfig

# 2. Check routing table
ip route show
route -n

# 3. Test connectivity
ping google.com
ping 8.8.8.8

# 4. Test DNS resolution
nslookup google.com
dig google.com

# 5. Check listening ports
netstat -tulpn
ss -tulpn

# 6. Test specific ports
telnet google.com 80
nc -zv google.com 80

# 7. Trace network path
traceroute google.com
mtr google.com

# 8. Check firewall rules
iptables -L
ufw status

# 9. Monitor network traffic
tcpdump -i eth0 -n
wireshark

# 10. Check network statistics
netstat -i
cat /proc/net/dev
```

**Kubernetes Network Troubleshooting:**
```bash
# Check pod networking
kubectl get pods -o wide
kubectl describe pod <pod-name>

# Check services
kubectl get svc
kubectl describe svc <service-name>

# Check endpoints
kubectl get endpoints

# Test pod-to-pod connectivity
kubectl exec -it <pod1> -- ping <pod2-ip>

# Check DNS resolution
kubectl exec -it <pod> -- nslookup kubernetes.default

# Check network policies
kubectl get networkpolicies
kubectl describe networkpolicy <policy-name>
```

---

## Database and Storage

### Q32: How do you manage databases in containerized environments?

**Answer:**
**Database Deployment Strategies:**

1. **StatefulSets for Databases:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: myapp
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - $(POSTGRES_USER)
          initialDelaySeconds: 30
          periodSeconds: 10
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

2. **Database Backup Strategy:**
```bash
#!/bin/bash
# Database backup script

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DB_NAME="myapp"

# Create backup
kubectl exec -it postgres-0 -- pg_dump -U postgres $DB_NAME > $BACKUP_DIR/backup_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/backup_$DATE.sql

# Upload to S3
aws s3 cp $BACKUP_DIR/backup_$DATE.sql.gz s3://my-backups/database/

# Cleanup old backups (keep last 7 days)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete
```

### Q33: Explain different storage types in Kubernetes.

**Answer:**
**Storage Types:**

1. **EmptyDir**: Temporary storage
2. **HostPath**: Node's filesystem
3. **PersistentVolume**: Cluster-wide storage
4. **ConfigMap**: Configuration data
5. **Secret**: Sensitive data

**Storage Classes:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  encrypted: "true"
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

**Persistent Volume Claim:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-storage
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 20Gi
```

---

## Troubleshooting Scenarios

### Q34: How do you troubleshoot a failing application in Kubernetes?

**Answer:**
**Troubleshooting Steps:**

1. **Check Pod Status:**
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>  # Multi-container pod
kubectl logs <pod-name> --previous  # Previous container logs
```

2. **Check Events:**
```bash
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl describe deployment <deployment-name>
```

3. **Debug Pod Issues:**
```bash
# Run debug container
kubectl run debug --image=busybox -it --rm -- sh

# Exec into running pod
kubectl exec -it <pod-name> -- /bin/bash

# Port forward for testing
kubectl port-forward pod/<pod-name> 8080:8080
```

4. **Network Troubleshooting:**
```bash
# Check service endpoints
kubectl get endpoints
kubectl describe service <service-name>

# Test service connectivity
kubectl run test --image=busybox -it --rm -- wget -qO- <service-name>:80
```

5. **Resource Issues:**
```bash
# Check resource usage
kubectl top pods
kubectl top nodes

# Check resource limits
kubectl describe pod <pod-name> | grep -i limits
kubectl describe node <node-name>
```

### Q35: Application performance is slow. How do you diagnose the issue?

**Answer:**
**Performance Diagnosis Process:**

1. **Application Metrics:**
```bash
# Check response times
curl -w "@curl-format.txt" -o /dev/null -s "http://app.example.com"

# curl-format.txt:
#     time_namelookup:  %{time_namelookup}\n
#        time_connect:  %{time_connect}\n
#     time_appconnect:  %{time_appconnect}\n
#    time_pretransfer:  %{time_pretransfer}\n
#       time_redirect:  %{time_redirect}\n
#  time_starttransfer:  %{time_starttransfer}\n
#                     ----------\n
#          time_total:  %{time_total}\n
```

2. **Resource Analysis:**
```bash
# CPU and memory usage
top -p $(pgrep -f myapp)
htop

# I/O analysis
iotop
iostat -x 1

# Network analysis
netstat -i
ss -tuln
```

3. **Database Performance:**
```sql
-- PostgreSQL slow queries
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- MySQL slow queries
SHOW PROCESSLIST;
SELECT * FROM information_schema.processlist 
WHERE time > 10;
```

4. **Application Profiling:**
```bash
# Java applications
jstack <pid>  # Thread dump
jmap -histo <pid>  # Memory usage

# Python applications
py-spy top --pid <pid>
py-spy record -o profile.svg --pid <pid>

# Node.js applications
clinic doctor -- node app.js
clinic bubbleprof -- node app.js
```

### Q36: How do you handle a production outage?

**Answer:**
**Incident Response Process:**

1. **Immediate Response (0-5 minutes):**
```bash
# Assess severity
# Critical: Revenue impacting, security breach
# High: Significant user impact
# Medium: Partial functionality affected
# Low: Minor issues

# Establish communication
# Slack war room: #incident-<timestamp>
# Bridge line for voice coordination

# Initial triage
kubectl get pods --all-namespaces | grep -v Running
kubectl get nodes
kubectl top nodes
```

2. **Investigation (5-30 minutes):**
```bash
# Check recent deployments
kubectl rollout history deployment/<app-name>
git log --oneline --since="2 hours ago"

# Monitor logs
kubectl logs -f deployment/<app-name>
tail -f /var/log/application.log

# Check infrastructure
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --start-time 2023-01-01T10:00:00Z \
  --end-time 2023-01-01T11:00:00Z \
  --period 300 \
  --statistics Sum
```

3. **Mitigation (30-60 minutes):**
```bash
# Quick fixes
# Rollback deployment
kubectl rollout undo deployment/<app-name>

# Scale up resources
kubectl scale deployment <app-name> --replicas=10

# Route traffic away
# Update load balancer weights
# Enable maintenance page
```

4. **Communication Template:**
```markdown
## Incident Update #1 - [Timestamp]

**Status**: Investigating
**Impact**: Users experiencing 500 errors on checkout
**Affected Services**: Payment API, User Dashboard
**Timeline**: 
- 10:15 AM: Alerts triggered for high error rate
- 10:18 AM: War room established
- 10:20 AM: Identified recent deployment as likely cause

**Actions Taken**:
- Rolled back payment API to previous version
- Increased monitoring on checkout flow

**Next Steps**:
- Monitor error rates for improvement
- Investigate deployment changes
- Update in 15 minutes or sooner if status changes

**Incident Commander**: @john.doe
```

5. **Post-Incident (After resolution):**
```markdown
## Post-Mortem: Payment API Outage

**Incident Summary**:
- Duration: 45 minutes (10:15 AM - 11:00 AM PST)
- Impact: 15% of checkout attempts failed
- Root Cause: Database connection pool exhaustion

**Timeline**:
- 09:45 AM: Deployment of payment API v2.1.3
- 10:15 AM: Error rate spike detected
- 10:18 AM: Incident response initiated
- 10:25 AM: Rollback completed
- 11:00 AM: Full service restoration confirmed

**Root Cause**:
New code introduced inefficient database queries that exhausted connection pool during peak traffic.

**Action Items**:
1. Implement query performance testing in CI pipeline (Owner: Dev Team, Due: 2023-01-15)
2. Add connection pool monitoring (Owner: SRE Team, Due: 2023-01-10)
3. Update deployment process to include performance gates (Owner: DevOps Team, Due: 2023-01-20)

**What Went Well**:
- Fast detection (3 minutes)
- Quick rollback capability
- Clear communication

**What Could Be Improved**:
- Earlier performance testing
- Better connection pool visibility
- Automated rollback triggers
```

### Q37: Database is running out of space. How do you handle it?

**Answer:**
**Database Space Management:**

1. **Immediate Assessment:**
```bash
# Check disk usage
df -h
du -sh /var/lib/postgresql/data/*

# Database-specific commands
# PostgreSQL
SELECT pg_size_pretty(pg_database_size('database_name'));
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC LIMIT 10;

# MySQL
SELECT table_schema, table_name, 
ROUND(((data_length + index_length) / 1024 / 1024), 2) AS "Size in MB"
FROM information_schema.TABLES ORDER BY (data_length + index_length) DESC;
```

2. **Quick Cleanup:**
```sql
-- PostgreSQL
VACUUM FULL;
REINDEX DATABASE database_name;

-- Clean up old WAL files
SELECT pg_switch_wal();

-- MySQL
OPTIMIZE TABLE table_name;

-- Clean binary logs
PURGE BINARY LOGS BEFORE DATE(NOW() - INTERVAL 7 DAY);
```

3. **Long-term Solutions:**
```yaml
# Increase storage (Kubernetes)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi  # Increased from 20Gi
```

4. **Data Archival Strategy:**
```sql
-- Archive old data
CREATE TABLE orders_archive AS 
SELECT * FROM orders WHERE created_at < NOW() - INTERVAL '1 year';

DELETE FROM orders WHERE created_at < NOW() - INTERVAL '1 year';

-- Partition tables
CREATE TABLE orders_2023 PARTITION OF orders
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
```

### Q38: How do you debug microservices communication issues?

**Answer:**
**Microservices Debugging Approach:**

1. **Distributed Tracing:**
```yaml
# Jaeger configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
spec:
  template:
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:latest
        env:
        - name: COLLECTOR_ZIPKIN_HTTP_PORT
          value: "9411"
        ports:
        - containerPort: 16686
        - containerPort: 14268
```

2. **Service Mesh Observability:**
```bash
# Istio service mesh
kubectl get vs,dr,se  # Virtual services, destination rules, service entries
istioctl proxy-config cluster <pod-name>
istioctl proxy-status

# Check Envoy configuration
kubectl exec <pod-name> -c istio-proxy -- curl localhost:15000/config_dump
```

3. **Network Testing:**
```bash
# Test service-to-service connectivity
kubectl exec -it <pod-a> -- curl -v http://service-b:8080/health

# Check DNS resolution
kubectl exec -it <pod> -- nslookup service-name.namespace.svc.cluster.local

# Test with debug pod
kubectl run debug --image=nicolaka/netshoot -it --rm -- bash
```

4. **API Gateway Debugging:**
```bash
# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Test routing
curl -H "Host: myapp.example.com" http://ingress-ip/api/users

# Check ingress configuration
kubectl describe ingress myapp-ingress
```

5. **Circuit Breaker Analysis:**
```yaml
# Hystrix dashboard
apiVersion: v1
kind: Service
metadata:
  name: hystrix-dashboard
spec:
  selector:
    app: hystrix-dashboard
  ports:
  - port: 7979
    targetPort: 7979
```

---

## Advanced Scenarios

### Q39: How do you implement blue-green deployment?

**Answer:**
**Blue-Green Deployment Strategy:**

1. **Infrastructure Setup:**
```yaml
# Blue environment (current production)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
  labels:
    version: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: app
        image: myapp:v1.0
        ports:
        - containerPort: 8080

---
# Green environment (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
  labels:
    version: green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: app
        image: myapp:v2.0
        ports:
        - containerPort: 8080
```

2. **Traffic Switching:**
```yaml
# Service pointing to blue initially
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: myapp
    version: blue  # Switch to green when ready
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

3. **Automated Script:**
```bash
#!/bin/bash
# blue-green-deploy.sh

NEW_VERSION=$1
CURRENT_COLOR=$(kubectl get service app-service -o jsonpath='{.spec.selector.version}')

if [ "$CURRENT_COLOR" = "blue" ]; then
    NEW_COLOR="green"
else
    NEW_COLOR="blue"
fi

echo "Current: $CURRENT_COLOR, Deploying to: $NEW_COLOR"

# Update deployment with new image
kubectl set image deployment/app-$NEW_COLOR app=myapp:$NEW_VERSION

# Wait for rollout
kubectl rollout status deployment/app-$NEW_COLOR

# Run smoke tests
./smoke-tests.sh app-$NEW_COLOR-service

if [ $? -eq 0 ]; then
    echo "Smoke tests passed. Switching traffic to $NEW_COLOR"
    kubectl patch service app-service -p '{"spec":{"selector":{"version":"'$NEW_COLOR'"}}}'
    echo "Deployment complete"
else
    echo "Smoke tests failed. Keeping traffic on $CURRENT_COLOR"
    exit 1
fi
```

### Q40: How do you implement disaster recovery for cloud infrastructure?

**Answer:**
**Disaster Recovery Strategy:**

1. **Multi-Region Setup:**
```hcl
# Terraform multi-region infrastructure
provider "aws" {
  alias  = "primary"
  region = "us-east-1"
}

provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
}

# Primary region infrastructure
resource "aws_instance" "primary" {
  provider      = aws.primary
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.medium"
  
  tags = {
    Name = "primary-app-server"
    DR   = "primary"
  }
}

# Secondary region infrastructure
resource "aws_instance" "secondary" {
  provider      = aws.secondary
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.medium"
  
  tags = {
    Name = "secondary-app-server"
    DR   = "secondary"
  }
}
```

2. **Database Replication:**
```yaml
# PostgreSQL streaming replication
# Primary database configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-primary-config
data:
  postgresql.conf: |
    wal_level = replica
    max_wal_senders = 3
    wal_keep_segments = 8
    archive_mode = on
    archive_command = 'cp %p /archive/%f'
  
  pg_hba.conf: |
    host replication replica 10.0.0.0/16 md5

---
# Secondary database configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-secondary-config
data:
  recovery.conf: |
    standby_mode = 'on'
    primary_conninfo = 'host=postgres-primary port=5432 user=replica'
    trigger_file = '/tmp/postgresql.trigger'
```

3. **Backup Strategy:**
```bash
#!/bin/bash
# comprehensive-backup.sh

# Database backup
pg_dump -h primary-db -U postgres myapp | gzip > backup-$(date +%Y%m%d).sql.gz

# Application data backup
rsync -av /app/data/ s3://dr-bucket/app-data/$(date +%Y%m%d)/

# Configuration backup
kubectl get all --all-namespaces -o yaml > k8s-backup-$(date +%Y%m%d).yaml
aws s3 cp k8s-backup-$(date +%Y%m%d).yaml s3://dr-bucket/k8s-configs/

# Cross-region replication
aws s3 sync s3://primary-bucket s3://secondary-bucket --region us-west-2
```

4. **Failover Automation:**
```python
# disaster-recovery.py
import boto3
import subprocess
import time

def check_primary_health():
    """Check if primary region is healthy"""
    try:
        response = requests.get('https://api.primary.example.com/health', timeout=10)
        return response.status_code == 200
    except:
        return False

def failover_to_secondary():
    """Execute failover to secondary region"""
    print("Starting failover to secondary region...")
    
    # Update DNS to point to secondary
    route53 = boto3.client('route53', region_name='us-west-2')
    route53.change_resource_record_sets(
        HostedZoneId='Z123456789',
        ChangeBatch={
            'Changes': [{
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'Name': 'api.example.com',
                    'Type': 'A',
                    'TTL': 60,
                    'ResourceRecords': [{'Value': secondary_ip}]
                }
            }]
        }
    )
    
    # Promote secondary database
    subprocess.run(['touch', '/tmp/postgresql.trigger'])
    
    # Scale up secondary infrastructure
    subprocess.run(['kubectl', 'scale', 'deployment/app', '--replicas=5'])
    
    print("Failover completed")

def main():
    while True:
        if not check_primary_health():
            print("Primary region unhealthy, initiating failover")
            failover_to_secondary()
            break
        time.sleep(30)

if __name__ == "__main__":
    main()
```

5. **Recovery Testing:**
```bash
#!/bin/bash
# dr-test.sh

echo "Starting DR test..."

# Simulate primary region failure
aws ec2 stop-instances --instance-ids i-primary123456

# Wait for failover
sleep 300

# Test secondary region
curl -f https://api.example.com/health

if [ $? -eq 0 ]; then
    echo "DR test successful"
else
    echo "DR test failed"
    exit 1
fi

# Restore primary region
aws ec2 start-instances --instance-ids i-primary123456

echo "DR test completed"
```

---

This comprehensive Q&A guide covers the most important topics in DevOps, Linux, and Cloud computing. Each answer provides practical examples, commands, and real-world scenarios that you're likely to encounter in interviews and daily work.

The questions range from basic concepts to advanced troubleshooting scenarios, making this guide suitable for both junior and senior engineers. Regular practice with these scenarios will help build confidence and expertise in modern infrastructure management.
