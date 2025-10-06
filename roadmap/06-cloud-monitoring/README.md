# Phase 6: Cloud and Monitoring

## Overview

Cloud platforms provide the infrastructure for modern applications. Monitoring ensures applications run reliably and issues are detected before users notice. This phase covers AWS cloud services and comprehensive monitoring with Prometheus and Grafana.

## Learning Objectives

- Master AWS core services
- Deploy applications to AWS
- Implement cloud networking and security
- Set up monitoring with Prometheus
- Create dashboards with Grafana
- Implement alerting strategies
- Understand observability principles
- Manage logs centrally

## Time Required

Estimated: 4-6 weeks with 5-6 hours daily practice

## Why Cloud and Monitoring?

### Cloud Computing Benefits

**Scalability:** Scale resources up or down instantly
**Cost:** Pay only for what you use
**Global Reach:** Deploy worldwide in minutes
**Reliability:** High availability and disaster recovery
**Innovation:** Access to latest technologies

### Monitoring Importance

**Without Monitoring:**
- Users report issues first
- No visibility into system health
- Troubleshooting takes hours or days
- Cannot predict failures
- No capacity planning data

**With Monitoring:**
- Detect issues before users notice
- Real-time visibility
- Quick troubleshooting with metrics and logs
- Predict and prevent failures
- Data-driven capacity planning

## AWS Core Services

### Compute Services

**EC2 (Elastic Compute Cloud):**
Virtual servers in the cloud.

**Use cases:**
- Web applications
- Batch processing
- Development/test environments

**Example: Launch EC2 instance with Terraform:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.public.id
  
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              EOF
  
  tags = {
    Name = "WebServer"
    Environment = "Production"
  }
}
```

**What this does:**
- Creates EC2 instance with specified AMI
- Instance type t2.micro (free tier eligible)
- Assigns security group and subnet
- Runs script on first boot to install Nginx
- Tags for organization

**ECS (Elastic Container Service):**
Managed container orchestration service.

**EKS (Elastic Kubernetes Service):**
Managed Kubernetes service.

**Lambda:**
Serverless compute - run code without managing servers.

**Example Lambda function:**
```python
import json
import boto3

def lambda_handler(event, context):
    """
    Process S3 upload event and send notification
    """
    s3 = boto3.client('s3')
    sns = boto3.client('sns')
    
    # Get bucket and file info from event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # Send SNS notification
    message = f'File uploaded: {key} to bucket {bucket}'
    sns.publish(
        TopicArn='arn:aws:sns:us-east-1:123456789012:FileUploads',
        Message=message,
        Subject='New File Upload'
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent')
    }
```

**Use case:** Trigger on S3 file upload, send notification.

### Storage Services

**S3 (Simple Storage Service):**
Object storage for any type of data.

**Use cases:**
- Static website hosting
- Backup and archive
- Data lake
- Application file storage

**Example: Create S3 bucket:**
```hcl
resource "aws_s3_bucket" "app_storage" {
  bucket = "myapp-storage-prod"
  
  tags = {
    Name        = "App Storage"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_versioning" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

**What this configures:**
- Creates S3 bucket with unique name
- Enables versioning (keep file history)
- Enables encryption at rest

**EBS (Elastic Block Store):**
Block storage for EC2 instances (like hard drives).

**EFS (Elastic File System):**
Managed NFS file system (shared storage).

### Database Services

**RDS (Relational Database Service):**
Managed relational databases (MySQL, PostgreSQL, etc).

**Example:**
```hcl
resource "aws_db_instance" "app_db" {
  identifier     = "myapp-db"
  engine         = "postgres"
  engine_version = "14.7"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  
  db_name  = "appdb"
  username = "admin"
  password = var.db_password  # Use variable, not hardcode
  
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  skip_final_snapshot    = false
  final_snapshot_identifier = "myapp-db-final-snapshot"
  
  tags = {
    Name = "Application Database"
  }
}
```

**DynamoDB:**
Managed NoSQL database.

**ElastiCache:**
Managed Redis/Memcached for caching.

### Networking Services

**VPC (Virtual Private Cloud):**
Isolated network for your AWS resources.

**Complete VPC setup:**
```hcl
# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "Main VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "Main IGW"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  map_public_ip_on_launch = true
  
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  
  tags = {
    Name = "Main NAT Gateway"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  
  tags = {
    Name = "Private Route Table"
  }
}
```

**What this architecture provides:**
- VPC with public and private subnets across 2 availability zones
- Internet Gateway for public subnet internet access
- NAT Gateway for private subnet outbound internet
- Route tables directing traffic appropriately

**ELB (Elastic Load Balancer):**
Distribute traffic across multiple targets.

**Route 53:**
DNS service and domain registration.

### Security Services

**IAM (Identity and Access Management):**
Control access to AWS services.

**Example IAM policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::myapp-storage-prod/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::myapp-storage-prod"
    }
  ]
}
```

**What this allows:**
- Read and write objects in specific S3 bucket
- List contents of bucket
- No other permissions (principle of least privilege)

**Security Groups:**
Virtual firewalls controlling inbound and outbound traffic.

**Example:**
```hcl
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Monitoring with Prometheus and Grafana

### Prometheus - Metrics Collection

**What is Prometheus?**
Open-source monitoring system that collects and stores metrics as time series data.

**Architecture:**
```
Applications → Exporters → Prometheus → Grafana
                              ↓
                         Alertmanager
```

**Key Concepts:**

**Metrics:** Numerical measurements over time
**Labels:** Key-value pairs for dimensionality
**Scraping:** Prometheus pulls metrics from targets
**PromQL:** Query language for metrics

**Example metrics:**
```
http_requests_total{method="GET", status="200"} 1234
http_request_duration_seconds{method="GET"} 0.042
cpu_usage_percent{core="0"} 45.2
memory_available_bytes 2147483648
```

**Installing Prometheus on Kubernetes:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
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
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
        - name: storage
          mountPath: /prometheus
      volumes:
      - name: config
        configMap:
          name: prometheus-config
      - name: storage
        emptyDir: {}
```

**Instrumenting application:**
```python
from prometheus_client import Counter, Histogram, start_http_server
import time
import random

# Define metrics
requests_total = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
request_duration = Histogram('http_request_duration_seconds', 'HTTP request duration', ['method', 'endpoint'])

def handle_request(method, endpoint):
    """Simulate request handling with metrics"""
    with request_duration.labels(method=method, endpoint=endpoint).time():
        # Simulate work
        time.sleep(random.uniform(0.01, 0.1))
        
        # Record request
        status = random.choice([200, 200, 200, 404, 500])
        requests_total.labels(method=method, endpoint=endpoint, status=status).inc()
        
        return status

if __name__ == '__main__':
    # Start metrics server
    start_http_server(8000)
    
    # Simulate traffic
    while True:
        handle_request('GET', '/api/users')
        handle_request('POST', '/api/users')
        time.sleep(1)
```

**Common PromQL queries:**
```promql
# Request rate per second
rate(http_requests_total[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) /
rate(http_requests_total[5m])

# Memory usage
container_memory_usage_bytes{pod="myapp"}

# CPU usage percentage
rate(container_cpu_usage_seconds_total{pod="myapp"}[5m]) * 100
```

### Grafana - Visualization

**What is Grafana?**
Open-source platform for monitoring and observability with beautiful dashboards.

**Key Features:**
- Multiple data sources (Prometheus, Elasticsearch, MySQL, etc)
- Templated dashboards
- Alerting
- User management
- Annotations

**Installing Grafana:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: grafana-secret
              key: admin-password
        volumeMounts:
        - name: storage
          mountPath: /var/lib/grafana
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: grafana-pvc
```

**Example Dashboard JSON (Application Overview):**
```json
{
  "dashboard": {
    "title": "Application Overview",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m]))",
            "legendFormat": "Requests/sec"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) * 100",
            "legendFormat": "Error %"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Response Time (p95)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
            "legendFormat": "p95 latency"
          }
        ],
        "type": "graph"
      }
    ]
  }
}
```

### Alerting

**Prometheus Alert Rules:**
```yaml
groups:
- name: application_alerts
  interval: 30s
  rules:
  - alert: HighErrorRate
    expr: |
      (
        sum(rate(http_requests_total{status=~"5.."}[5m]))
        /
        sum(rate(http_requests_total[5m]))
      ) > 0.05
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value | humanizePercentage }} (threshold: 5%)"
  
  - alert: HighLatency
    expr: |
      histogram_quantile(0.95,
        sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
      ) > 1.0
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "High latency detected"
      description: "95th percentile latency is {{ $value }}s (threshold: 1s)"
  
  - alert: PodDown
    expr: |
      up{job="kubernetes-pods"} == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Pod {{ $labels.pod }} is down"
      description: "Pod has been down for more than 5 minutes"
```

**Alertmanager Configuration:**
```yaml
global:
  resolve_timeout: 5m
  slack_api_url: 'https://hooks.slack.com/services/XXX/YYY/ZZZ'

route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'slack-notifications'
  routes:
  - match:
      severity: critical
    receiver: 'pagerduty'
    continue: true

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#alerts'
    title: '{{ .GroupLabels.alertname }}'
    text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

- name: 'pagerduty'
  pagerduty_configs:
  - service_key: 'YOUR_PAGERDUTY_KEY'
```

## Logging

### Centralized Logging with ELK Stack

**Components:**
- **Elasticsearch:** Store and search logs
- **Logstash/Fluentd:** Collect and process logs
- **Kibana:** Visualize logs

**Fluentd configuration for Kubernetes:**
```yaml
<source>
  @type tail
  path /var/log/containers/*.log
  pos_file /var/log/fluentd-containers.log.pos
  tag kubernetes.*
  format json
  time_key time
  time_format %Y-%m-%dT%H:%M:%S.%NZ
</source>

<filter kubernetes.**>
  @type kubernetes_metadata
</filter>

<match kubernetes.**>
  @type elasticsearch
  host elasticsearch.logging.svc.cluster.local
  port 9200
  logstash_format true
  logstash_prefix kubernetes
</match>
```

### Application Logging Best Practices

**Structured logging (JSON):**
```python
import logging
import json

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            'timestamp': self.formatTime(record),
            'level': record.levelname,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName
        }
        return json.dumps(log_record)

logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)

# Usage
logger.info('User logged in', extra={'user_id': 12345, 'ip': '192.168.1.1'})
```

## Success Criteria

You are ready for Phase 7 when you can:

- [ ] Deploy applications to AWS
- [ ] Configure VPC and networking
- [ ] Implement security best practices
- [ ] Set up Prometheus monitoring
- [ ] Create Grafana dashboards
- [ ] Configure alerting
- [ ] Implement centralized logging
- [ ] Troubleshoot using metrics and logs
- [ ] Design highly available architecture

## Next Steps

Begin with `01-aws-fundamentals.md` to learn cloud basics.

This is the final technical phase. Master cloud and monitoring to ensure your applications run reliably at scale.

Continue to Phase 7 for integration and complete workflow understanding.
