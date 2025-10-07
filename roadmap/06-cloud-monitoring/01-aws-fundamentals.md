# AWS Complete Guide for DevOps

## What is AWS (Amazon Web Services)

AWS is a cloud computing platform that provides on-demand computing resources over the internet. Instead of buying and maintaining physical servers, you rent computing power, storage, and services from AWS.

**Why cloud computing:**
- No upfront hardware costs
- Pay only for what you use
- Scale up or down instantly
- Global infrastructure
- High availability and reliability

**How AWS connects to DevOps:**
- Hosts your applications (EC2, ECS, EKS)
- Stores your data (S3, RDS)
- Terraform provisions AWS resources
- Jenkins/GitHub Actions deploy to AWS
- Kubernetes runs on AWS (EKS)
- Docker containers run on AWS

## AWS Core Concepts

### Regions and Availability Zones

**Region:** A geographical area (e.g., us-east-1 is North Virginia).

**Availability Zone (AZ):** A data center within a region. Each region has multiple AZs.

```
Region: us-east-1 (North Virginia)
  ├─ Availability Zone: us-east-1a
  ├─ Availability Zone: us-east-1b
  └─ Availability Zone: us-east-1c
```

**Why multiple AZs:**
- High availability (if one fails, others continue)
- Disaster recovery
- Low latency

**Example: Deploy application across AZs**
```
Web Server 1 → us-east-1a
Web Server 2 → us-east-1b
Web Server 3 → us-east-1c

If us-east-1a goes down, servers in 1b and 1c continue working.
```

### IAM (Identity and Access Management)

IAM controls who can access AWS resources and what they can do.

**Key concepts:**

**Users:** Individual people who need AWS access.

**Groups:** Collection of users with same permissions.

**Roles:** Temporary permissions for applications or services.

**Policies:** JSON documents defining permissions.

**Example IAM policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

**Explanation:**
- `Effect`: Allow or Deny
- `Action`: What operations are permitted
- `Resource`: Which resources this applies to
- This policy allows viewing, starting, and stopping EC2 instances

## EC2 (Elastic Compute Cloud)

EC2 provides virtual servers in the cloud.

### Understanding EC2 Instances

An EC2 instance is a virtual machine running on AWS infrastructure.

**Instance types:**

```
t3.micro:  1 vCPU, 1 GB RAM    (Testing, small apps)
t3.small:  2 vCPU, 2 GB RAM    (Small web servers)
t3.medium: 2 vCPU, 4 GB RAM    (Medium workloads)
m5.large:  2 vCPU, 8 GB RAM    (Production apps)
c5.xlarge: 4 vCPU, 8 GB RAM    (CPU-intensive)
r5.large:  2 vCPU, 16 GB RAM   (Memory-intensive)
```

**Choose instance type based on:**
- CPU requirements
- Memory requirements
- Storage needs
- Cost

### Launching EC2 Instance via AWS CLI

**Step 1: Install AWS CLI**

```bash
# On Ubuntu/Debian
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

**Step 2: Configure AWS credentials**

```bash
aws configure
```

**Prompts:**
```
AWS Access Key ID [None]: YOUR_ACCESS_KEY
AWS Secret Access Key [None]: YOUR_SECRET_KEY
Default region name [None]: us-east-1
Default output format [None]: json
```

**Where to get credentials:**
1. Log in to AWS Console
2. Go to IAM service
3. Click "Users" → Your username
4. Click "Security credentials"
5. Click "Create access key"

**Step 3: Create key pair for SSH**

```bash
aws ec2 create-key-pair \
  --key-name my-key-pair \
  --query 'KeyMaterial' \
  --output text > my-key-pair.pem

# Set proper permissions
chmod 400 my-key-pair.pem
```

**Explanation:**
- Key pair allows SSH access to instance
- Private key saved locally (my-key-pair.pem)
- Public key stored in AWS

**Step 4: Create security group**

```bash
# Create security group
aws ec2 create-security-group \
  --group-name my-security-group \
  --description "Security group for web server"

# Allow SSH (port 22)
aws ec2 authorize-security-group-ingress \
  --group-name my-security-group \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Allow HTTP (port 80)
aws ec2 authorize-security-group-ingress \
  --group-name my-security-group \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Allow HTTPS (port 443)
aws ec2 authorize-security-group-ingress \
  --group-name my-security-group \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0
```

**Explanation:**
- Security group = firewall rules
- Controls inbound and outbound traffic
- `--cidr 0.0.0.0/0` means allow from anywhere (use specific IPs in production)

**Step 5: Launch EC2 instance**

```bash
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --count 1 \
  --instance-type t3.micro \
  --key-name my-key-pair \
  --security-groups my-security-group \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyWebServer}]'
```

**Explanation line by line:**
- `--image-id`: AMI (Amazon Machine Image) - Ubuntu 22.04 in this case
- `--count 1`: Launch one instance
- `--instance-type t3.micro`: Free tier eligible
- `--key-name`: SSH key for access
- `--security-groups`: Firewall rules
- `--tag-specifications`: Name for easy identification

**Step 6: Get instance public IP**

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=MyWebServer" \
  --query 'Reservations[].Instances[].PublicIpAddress' \
  --output text
```

**Step 7: Connect via SSH**

```bash
ssh -i my-key-pair.pem ubuntu@PUBLIC_IP_ADDRESS
```

**Step 8: Install web server**

```bash
# Update system
sudo apt update

# Install nginx
sudo apt install nginx -y

# Start nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create test page
echo "<h1>Hello from AWS EC2!</h1>" | sudo tee /var/www/html/index.html
```

Now visit `http://PUBLIC_IP_ADDRESS` in browser to see your web server!

### Managing EC2 Instances

**List all instances:**
```bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

**Stop instance:**
```bash
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
```

**Start instance:**
```bash
aws ec2 start-instances --instance-ids i-1234567890abcdef0
```

**Terminate (delete) instance:**
```bash
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
```

**Important:** Termination is permanent and cannot be undone!

## S3 (Simple Storage Service)

S3 stores files (objects) in buckets. Think of it as unlimited cloud storage.

### S3 Concepts

**Bucket:** A container for objects (like a folder).

**Object:** A file stored in S3 (can be any file type).

**Key:** The full path to an object (like filename).

```
Bucket: my-app-bucket
  ├─ images/logo.png
  ├─ videos/demo.mp4
  └─ documents/readme.txt
```

### Creating and Using S3

**Step 1: Create bucket**

```bash
aws s3 mb s3://my-unique-bucket-name-12345
```

**Note:** Bucket names must be globally unique across all AWS accounts.

**Step 2: Upload file**

```bash
# Upload single file
aws s3 cp myfile.txt s3://my-unique-bucket-name-12345/

# Upload directory
aws s3 cp mydir/ s3://my-unique-bucket-name-12345/mydir/ --recursive

# Upload with public read access
aws s3 cp myfile.txt s3://my-unique-bucket-name-12345/ --acl public-read
```

**Step 3: List objects**

```bash
aws s3 ls s3://my-unique-bucket-name-12345/
```

**Step 4: Download file**

```bash
aws s3 cp s3://my-unique-bucket-name-12345/myfile.txt ./downloaded.txt
```

**Step 5: Delete file**

```bash
aws s3 rm s3://my-unique-bucket-name-12345/myfile.txt
```

**Step 6: Delete bucket**

```bash
# Remove all objects first
aws s3 rm s3://my-unique-bucket-name-12345/ --recursive

# Then delete bucket
aws s3 rb s3://my-unique-bucket-name-12345
```

### S3 for Static Website Hosting

Host a static website on S3:

**Step 1: Create bucket**
```bash
aws s3 mb s3://my-website-bucket
```

**Step 2: Enable website hosting**
```bash
aws s3 website s3://my-website-bucket/ \
  --index-document index.html \
  --error-document error.html
```

**Step 3: Make bucket public**

Create file `bucket-policy.json`:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-website-bucket/*"
    }
  ]
}
```

Apply policy:
```bash
aws s3api put-bucket-policy \
  --bucket my-website-bucket \
  --policy file://bucket-policy.json
```

**Step 4: Upload website files**

**index.html:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>My Website</title>
</head>
<body>
    <h1>Welcome to my AWS S3 website!</h1>
    <p>This is hosted entirely on S3.</p>
</body>
</html>
```

Upload:
```bash
aws s3 cp index.html s3://my-website-bucket/
aws s3 cp error.html s3://my-website-bucket/
```

**Step 5: Access website**

URL format: `http://my-website-bucket.s3-website-us-east-1.amazonaws.com`

### S3 Storage Classes

Choose storage class based on access frequency:

**S3 Standard:**
- Frequent access
- Most expensive
- Use for: Active data, website assets

**S3 Intelligent-Tiering:**
- Automatically moves data between tiers
- Cost optimization
- Use for: Data with unknown access patterns

**S3 Standard-IA (Infrequent Access):**
- Less frequent access
- Cheaper than Standard
- Use for: Backups, disaster recovery

**S3 Glacier:**
- Archival storage
- Retrieval takes minutes to hours
- Very cheap
- Use for: Long-term archives, compliance data

**S3 Glacier Deep Archive:**
- Cheapest storage
- Retrieval takes 12+ hours
- Use for: Data rarely accessed (once a year or less)

**Example: Set storage class**
```bash
aws s3 cp myfile.txt s3://my-bucket/ --storage-class GLACIER
```

## RDS (Relational Database Service)

RDS provides managed databases. AWS handles backups, updates, and scaling.

### Supported Database Engines

- MySQL
- PostgreSQL
- MariaDB
- Oracle
- SQL Server
- Amazon Aurora (AWS's own engine)

### Creating RDS Database

**Step 1: Create database**

```bash
aws rds create-db-instance \
  --db-instance-identifier myapp-database \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password MySecurePassword123 \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-12345678 \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00" \
  --preferred-maintenance-window "sun:04:00-sun:05:00"
```

**Explanation:**
- `--db-instance-identifier`: Name for this database
- `--db-instance-class`: Instance size (t3.micro is free tier)
- `--engine`: Database type
- `--master-username/password`: Admin credentials
- `--allocated-storage`: Disk space in GB
- `--backup-retention-period`: Keep backups for 7 days
- `--preferred-backup-window`: When to back up (UTC time)

**Step 2: Wait for creation (takes 5-10 minutes)**

```bash
aws rds wait db-instance-available \
  --db-instance-identifier myapp-database
```

**Step 3: Get connection endpoint**

```bash
aws rds describe-db-instances \
  --db-instance-identifier myapp-database \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
```

**Output example:** `myapp-database.abcdef123456.us-east-1.rds.amazonaws.com`

**Step 4: Connect to database**

```bash
# Install PostgreSQL client
sudo apt install postgresql-client

# Connect
psql -h myapp-database.abcdef123456.us-east-1.rds.amazonaws.com \
     -U admin \
     -d postgres
```

**Step 5: Create application database**

```sql
-- Create database for your application
CREATE DATABASE ecommerce;

-- Create user
CREATE USER appuser WITH PASSWORD 'AppPassword123';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE ecommerce TO appuser;

-- Exit
\q
```

### Connecting Application to RDS

**Python application example:**

```python
import psycopg2
import os

# Database connection details
DB_HOST = os.getenv('DB_HOST', 'myapp-database.abcdef123456.us-east-1.rds.amazonaws.com')
DB_NAME = os.getenv('DB_NAME', 'ecommerce')
DB_USER = os.getenv('DB_USER', 'appuser')
DB_PASS = os.getenv('DB_PASS', 'AppPassword123')

# Connect to database
conn = psycopg2.connect(
    host=DB_HOST,
    database=DB_NAME,
    user=DB_USER,
    password=DB_PASS
)

# Create cursor
cur = conn.cursor()

# Execute query
cur.execute('SELECT version()')
version = cur.fetchone()
print(f'PostgreSQL version: {version}')

# Close connection
cur.close()
conn.close()
```

**How this connects to DevOps:**
- Environment variables set by Kubernetes
- Kubernetes secrets store DB credentials
- Terraform creates RDS instance
- Ansible configures database

## VPC (Virtual Private Cloud)

VPC is your private network in AWS. It isolates your resources from other AWS customers.

### VPC Components

**VPC:** The network itself (e.g., 10.0.0.0/16).

**Subnet:** A section of the VPC (e.g., 10.0.1.0/24).

**Internet Gateway:** Allows internet access.

**Route Table:** Directs network traffic.

**Security Group:** Firewall for instances.

**Diagram:**
```
VPC (10.0.0.0/16)
  ├─ Public Subnet (10.0.1.0/24) [has internet access]
  │    ├─ Web Server 1
  │    └─ Web Server 2
  │
  └─ Private Subnet (10.0.2.0/24) [no internet access]
       ├─ Database
       └─ Application Server
```

### Creating VPC

**Step 1: Create VPC**

```bash
aws ec2 create-vpc --cidr-block 10.0.0.0/16
```

**Step 2: Create public subnet**

```bash
aws ec2 create-subnet \
  --vpc-id vpc-12345678 \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a
```

**Step 3: Create private subnet**

```bash
aws ec2 create-subnet \
  --vpc-id vpc-12345678 \
  --cidr-block 10.0.2.0/24 \
  --availability-zone us-east-1b
```

**Step 4: Create internet gateway**

```bash
# Create gateway
aws ec2 create-internet-gateway

# Attach to VPC
aws ec2 attach-internet-gateway \
  --internet-gateway-id igw-12345678 \
  --vpc-id vpc-12345678
```

**Step 5: Create route table for public subnet**

```bash
# Create route table
aws ec2 create-route-table --vpc-id vpc-12345678

# Add route to internet gateway
aws ec2 create-route \
  --route-table-id rtb-12345678 \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id igw-12345678

# Associate with public subnet
aws ec2 associate-route-table \
  --route-table-id rtb-12345678 \
  --subnet-id subnet-12345678
```

**Why VPC matters for DevOps:**
- Isolates production from development
- Controls network access
- Enables hybrid cloud (connect to on-premise)
- Terraform manages VPC as code

## EKS (Elastic Kubernetes Service)

EKS runs managed Kubernetes clusters on AWS.

### Creating EKS Cluster

**Step 1: Install eksctl**

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version
```

**Step 2: Create cluster**

```bash
eksctl create cluster \
  --name my-cluster \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed
```

**Explanation:**
- Creates VPC, subnets, security groups automatically
- Launches 2 worker nodes
- Can scale from 1 to 3 nodes
- Takes 15-20 minutes to create

**Step 3: Configure kubectl**

```bash
aws eks update-kubeconfig --name my-cluster --region us-east-1
```

**Step 4: Verify cluster**

```bash
kubectl get nodes
```

**Step 5: Deploy application**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

```bash
kubectl apply -f nginx-deployment.yaml
```

**Step 6: Get load balancer URL**

```bash
kubectl get service nginx-service
```

**How EKS connects to DevOps:**
- Runs Docker containers
- Managed by Kubernetes
- Created by Terraform
- Deployed by Jenkins/GitHub Actions
- Monitored by Prometheus

## Complete AWS DevOps Architecture

Here's how everything fits together:

```
Developer
   ↓
GitHub (Git repository)
   ↓
GitHub Actions / Jenkins (CI/CD)
   ↓
Build Docker Image
   ↓
Push to ECR (AWS Container Registry)
   ↓
Deploy to EKS (Kubernetes)
   ↓
Application running in pods
   ↓
Load Balancer (distributes traffic)
   ↓
Users access application

Supporting services:
- RDS: Database
- S3: Static files, backups
- VPC: Network isolation
- IAM: Access control
- CloudWatch: Logging/monitoring
```

## AWS Cost Optimization

**Free tier services (12 months):**
- EC2: 750 hours/month of t2.micro or t3.micro
- S3: 5 GB storage
- RDS: 750 hours/month of db.t2.micro
- Lambda: 1 million requests/month

**Cost saving tips:**

**1. Stop unused EC2 instances**
```bash
# Stop all instances with tag "Environment=dev"
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=dev" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text | xargs aws ec2 stop-instances --instance-ids
```

**2. Use spot instances**
Spot instances are up to 90% cheaper but can be terminated.

```bash
aws ec2 request-spot-instances \
  --instance-count 1 \
  --type "one-time" \
  --launch-specification file://spot-spec.json
```

**3. Delete old snapshots**
```bash
# List snapshots older than 30 days
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[?StartTime<=`2024-01-01`].[SnapshotId,StartTime]' \
  --output table
```

**4. Use S3 lifecycle policies**
Automatically move old data to cheaper storage:

```json
{
  "Rules": [
    {
      "Id": "Move to Glacier after 90 days",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
```

**5. Set up billing alerts**
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name billing-alert \
  --alarm-description "Alert when bill exceeds $50" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 21600 \
  --evaluation-periods 1 \
  --threshold 50 \
  --comparison-operator GreaterThanThreshold
```

## Best Practices

**1. Use IAM roles instead of access keys**
```bash
# Attach role to EC2 instance
aws ec2 associate-iam-instance-profile \
  --instance-id i-1234567890abcdef0 \
  --iam-instance-profile Name=MyInstanceProfile
```

**2. Enable MFA (Multi-Factor Authentication)**
Protect your AWS account with two-factor authentication.

**3. Tag everything**
```bash
aws ec2 create-tags \
  --resources i-1234567890abcdef0 \
  --tags Key=Environment,Value=Production Key=Owner,Value=DevOps
```

**4. Use CloudWatch for monitoring**
```bash
# Get CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average
```

**5. Enable encryption**
```bash
# Create encrypted EBS volume
aws ec2 create-volume \
  --size 20 \
  --volume-type gp3 \
  --availability-zone us-east-1a \
  --encrypted
```

## Practice Exercises

**Exercise 1: Launch Web Server**
1. Launch EC2 instance
2. Install nginx
3. Create simple HTML page
4. Access from browser

**Exercise 2: S3 Website**
1. Create S3 bucket
2. Upload HTML files
3. Enable website hosting
4. Make bucket public
5. Access website

**Exercise 3: RDS Database**
1. Create PostgreSQL database
2. Connect via psql
3. Create tables
4. Insert sample data

**Exercise 4: Complete VPC**
1. Create VPC
2. Create public and private subnets
3. Set up internet gateway
4. Launch EC2 in public subnet
5. Launch RDS in private subnet
6. Connect EC2 to RDS

**Exercise 5: EKS Cluster**
1. Create EKS cluster
2. Deploy sample application
3. Expose with LoadBalancer
4. Scale deployment
5. Update application

## Next Steps

You now understand AWS fundamentals! Practice by:

1. Creating and managing EC2 instances
2. Storing files in S3
3. Setting up RDS databases
4. Building VPC networks
5. Running Kubernetes on EKS
6. Automating with Terraform
7. Deploying with Jenkins/GitHub Actions

AWS provides the infrastructure foundation for modern DevOps!
