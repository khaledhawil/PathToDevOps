# kubectl Setup Guide: Connecting to Vagrant Kubernetes Cluster

## 📋 Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Step-by-Step Setup](#step-by-step-setup)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)
- [Best Practices](#best-practices)
- [FAQ](#faq)

## 🎯 Overview

This guide explains how to configure `kubectl` on your main machine to manage a Kubernetes cluster running in Vagrant VMs. This setup allows you to interact with your Kubernetes cluster without needing to SSH into the virtual machines.

### What This Guide Covers
- Extracting kubeconfig from Vagrant VMs
- Configuring kubectl contexts
- Managing multiple clusters
- Troubleshooting connectivity issues

### Benefits
- ✅ Manage cluster from your main machine
- ✅ Switch between multiple clusters easily
- ✅ Use your favorite kubectl tools and plugins
- ✅ No need to SSH into VMs for cluster management

## 🔧 Prerequisites

### Required Software
- **Vagrant**: For managing VMs
- **kubectl**: Kubernetes command-line tool
- **VirtualBox**: Hypervisor for Vagrant VMs

### Verify Installation
```bash
# Check Vagrant
vagrant --version

# Check kubectl
kubectl version --client

# Check VirtualBox
vboxmanage --version
```

### Cluster Requirements
- Running Kubernetes cluster in Vagrant VMs
- Network connectivity between host and VMs
- Admin access to control plane node

## 🏗️ Architecture

### Network Setup
```
┌─────────────────┐    ┌──────────────────────────────────┐
│                 │    │         Vagrant Network          │
│   Main Machine  │    │        (192.168.56.0/24)        │
│                 │    │                                  │
│   kubectl ──────┼────┼──► 192.168.56.10 (controlplane) │
│                 │    │    192.168.56.11 (node01)       │
│                 │    │    192.168.56.12 (node02)       │
└─────────────────┘    └──────────────────────────────────┘
```

### Cluster Components
- **Control Plane**: 192.168.56.10
- **Worker Node 1**: 192.168.56.11  
- **Worker Node 2**: 192.168.56.12
- **API Server**: https://192.168.56.10:6443

## 📚 Step-by-Step Setup (Detailed)

### Step 1: Navigate to Vagrant Directory
**What this does**: Changes your working directory to where your Vagrant configuration files are located.

```bash
cd ~/Documents/kubeadm-cluster-vagrant
```

**Why this matters**: 
- Vagrant commands must be run from the directory containing the `Vagrantfile`
- This ensures you're working with the correct cluster configuration
- All subsequent Vagrant commands will apply to this specific cluster

**Verify you're in the right place**:
```bash
# Check if Vagrantfile exists
ls -la Vagrantfile

# Check current directory
pwd
```

### Step 2: Verify VMs are Running
**What this does**: Checks the current status of all virtual machines in your Vagrant environment.

```bash
vagrant status
```

**Expected output**:
```
Current machine states:

controlplane              running (virtualbox)
node01                    running (virtualbox)
node02                    running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

**What each status means**:
- `running`: VM is powered on and ready
- `poweroff`: VM is stopped (you need to start it)
- `saved`: VM is suspended (resume with `vagrant resume`)
- `not created`: VM doesn't exist yet (run `vagrant up`)

**If VMs are not running**:
```bash
# Start all VMs
vagrant up

# Or start specific VM
vagrant up controlplane

# Check VM resource usage
vagrant ssh controlplane -c "free -h && df -h"
```

### Step 3: Extract kubeconfig from Control Plane
**What this does**: Copies the Kubernetes admin configuration from the master node to your local machine.

```bash
# Copy kubeconfig from controlplane VM
vagrant ssh controlplane -c "sudo cat /etc/kubernetes/admin.conf" > kubeconfig

# Verify the file was created and check its size
ls -la kubeconfig
```

**Detailed explanation**:
- `vagrant ssh controlplane`: Connects to the control plane VM via SSH
- `-c "command"`: Executes the command without opening an interactive shell
- `sudo cat /etc/kubernetes/admin.conf`: Reads the admin kubeconfig file (requires sudo)
- `> kubeconfig`: Redirects the output to a local file named "kubeconfig"

**What's in the kubeconfig file**:
```bash
# View the structure (without sensitive data)
grep -E "(server|name|cluster)" kubeconfig
```

**If this step fails**:
```bash
# Alternative method - copy file manually
vagrant ssh controlplane
sudo cp /etc/kubernetes/admin.conf /vagrant/kubeconfig
sudo chmod 644 /vagrant/kubeconfig
exit

# Then on your host machine
cp kubeconfig kubeconfig.backup
```

### Step 4: Setup kubectl Configuration
**What this does**: Prepares your local kubectl to connect to the Vagrant cluster.

```bash
# Create .kube directory if it doesn't exist
mkdir -p ~/.kube

# Copy kubeconfig to a dedicated file
cp kubeconfig ~/.kube/config-vagrant

# Test connectivity
kubectl --kubeconfig ~/.kube/config-vagrant get nodes
```

**Detailed explanation**:
- `mkdir -p ~/.kube`: Creates the kubectl configuration directory (`-p` creates parent directories if needed)
- `cp kubeconfig ~/.kube/config-vagrant`: Copies the config with a descriptive name
- `kubectl --kubeconfig`: Uses a specific config file instead of the default

**Expected test output**:
```
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   65d   v1.31.0
node01         Ready    worker          65d   v1.31.0
node02         Ready    worker          65d   v1.31.0
```

**Understanding the output**:
- `NAME`: Node hostname
- `STATUS`: Ready means the node is healthy and can accept pods
- `ROLES`: control-plane (master) or worker (compute) nodes
- `AGE`: How long the node has been running
- `VERSION`: Kubernetes version installed on the node

### Step 5: Merge with Existing kubectl Config
**What this does**: Combines your new Vagrant cluster configuration with your existing kubectl configuration.

```bash
# Backup existing config (IMPORTANT!)
cp ~/.kube/config ~/.kube/config.backup

# Merge configurations
KUBECONFIG=~/.kube/config:~/.kube/config-vagrant kubectl config view --flatten > ~/.kube/config.tmp
mv ~/.kube/config.tmp ~/.kube/config

# Rename context for clarity
kubectl config rename-context kubernetes-admin@kubernetes vagrant-kubeadm
```

**Detailed explanation**:

**Step 5a - Backup existing config**:
```bash
cp ~/.kube/config ~/.kube/config.backup
```
- Creates a backup copy of your current kubectl configuration
- Essential for recovery if something goes wrong

**Step 5b - Merge configurations**:
```bash
KUBECONFIG=~/.kube/config:~/.kube/config-vagrant kubectl config view --flatten > ~/.kube/config.tmp
```
- `KUBECONFIG=file1:file2`: Temporarily combines multiple config files
- `kubectl config view --flatten`: Merges all configurations into a single file
- `> ~/.kube/config.tmp`: Saves to a temporary file

**Step 5c - Replace the config**:
```bash
mv ~/.kube/config.tmp ~/.kube/config
```
- Replaces your main config with the merged version
- Now you have access to all clusters in one config file

**Step 5d - Rename context**:
```bash
kubectl config rename-context kubernetes-admin@kubernetes vagrant-kubeadm
```
- Changes the context name from generic to descriptive
- Makes it easier to identify which cluster you're working with

### Step 6: Verify Setup
**What this does**: Confirms everything is working correctly and shows you how to use your new setup.

```bash
# List all contexts
kubectl config get-contexts

# Switch to vagrant cluster
kubectl config use-context vagrant-kubeadm

# Test cluster access
kubectl get nodes -o wide
```

**Expected contexts output**:
```
CURRENT   NAME                    CLUSTER         AUTHINFO            NAMESPACE
          eks-cluster            eks-cluster     eks-cluster         
          kind-my-cluster        kind-cluster    kind-user           
*         vagrant-kubeadm        kubernetes      kubernetes-admin    
```

**Understanding the contexts table**:
- `CURRENT`: `*` shows which cluster you're currently connected to
- `NAME`: Context name (what you use to switch clusters)
- `CLUSTER`: Cluster configuration name
- `AUTHINFO`: Authentication information
- `NAMESPACE`: Default namespace (empty means "default")

**Test detailed node information**:
```bash
kubectl get nodes -o wide
```

**Expected detailed output**:
```
NAME           STATUS   ROLES           AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
controlplane   Ready    control-plane   65d   v1.31.0   192.168.56.10   <none>        Ubuntu 24.04.2 LTS   6.8.0-53-generic   cri-o://1.33.0
node01         Ready    worker          65d   v1.31.0   192.168.56.11   <none>        Ubuntu 24.04.2 LTS   6.8.0-53-generic   cri-o://1.33.0
node02         Ready    worker          65d   v1.31.0   192.168.56.12   <none>        Ubuntu 24.04.2 LTS   6.8.0-53-generic   cri-o://1.33.0
```

**Additional verification commands**:
```bash
# Check cluster information
kubectl cluster-info

# Test API server access
kubectl get --raw='/healthz'

# List all system pods
kubectl get pods -n kube-system

# Check your permissions
kubectl auth can-i create pods
kubectl auth can-i get secrets
```

## 🌐 Connecting to Other Clusters (On-Premise & Cloud)

### Understanding Different Cluster Types

Before connecting to any cluster, it's important to understand the different types:

| Cluster Type | Description | Access Method | Typical Use Case |
|-------------|-------------|---------------|------------------|
| **Vagrant/Local** | VMs on your machine | Direct IP access | Development, Learning |
| **On-Premise** | Physical servers in your datacenter | VPN/Direct network | Production, Enterprise |
| **Cloud Managed** | EKS, GKE, AKS | Cloud provider CLI | Production, Scalable |
| **Cloud Self-Managed** | VMs in cloud with kubeadm | SSH + kubeconfig | Custom setups |
| **Kind/Minikube** | Local container clusters | Local tools | Testing, CI/CD |

### 1. Connecting to On-Premise Kubernetes Clusters

#### Scenario A: Physical Servers with kubeadm
**When you have**: Physical servers running Kubernetes installed with kubeadm

**Step-by-step process**:

1. **Get access to the master node**:
```bash
# SSH to the master node (replace with actual IP/hostname)
ssh username@master-node-ip

# Example
ssh admin@10.0.1.100
```

2. **Extract the kubeconfig**:
```bash
# On the master node
sudo cat /etc/kubernetes/admin.conf

# Or copy it to your home directory
sudo cp /etc/kubernetes/admin.conf ~/kubeconfig
sudo chown $(whoami):$(whoami) ~/kubeconfig
```

3. **Transfer to your local machine**:
```bash
# From your local machine
scp admin@10.0.1.100:~/kubeconfig ~/.kube/config-onprem

# Or copy the content manually
ssh admin@10.0.1.100 "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config-onprem
```

4. **Update server address** (if needed):
```bash
# Edit the kubeconfig to use external IP instead of internal
sed -i 's/https:\/\/.*:6443/https:\/\/10.0.1.100:6443/' ~/.kube/config-onprem
```

5. **Test and merge**:
```bash
# Test connection
kubectl --kubeconfig ~/.kube/config-onprem get nodes

# Merge with existing config
KUBECONFIG=~/.kube/config:~/.kube/config-onprem kubectl config view --flatten > ~/.kube/config.tmp
mv ~/.kube/config.tmp ~/.kube/config

# Rename context
kubectl config rename-context kubernetes-admin@kubernetes onprem-cluster
```

#### Scenario B: Enterprise Clusters with RBAC
**When you have**: Enterprise clusters with role-based access control

**Getting access**:
```bash
# Your admin will provide you with:
# 1. Certificate files
# 2. Private key
# 3. CA certificate
# 4. Server endpoint

# Example files you might receive:
# - user.crt (your certificate)
# - user.key (your private key)  
# - ca.crt (cluster CA certificate)
# - cluster-info.txt (server details)
```

**Setting up access**:
```bash
# Create a new context manually
kubectl config set-cluster enterprise-cluster \
  --server=https://k8s-api.company.com:6443 \
  --certificate-authority=ca.crt

kubectl config set-credentials my-user \
  --client-certificate=user.crt \
  --client-key=user.key

kubectl config set-context enterprise-cluster \
  --cluster=enterprise-cluster \
  --user=my-user \
  --namespace=my-team

# Test access
kubectl config use-context enterprise-cluster
kubectl get pods
```

### 2. Connecting to Cloud Kubernetes Services

#### Amazon EKS (Elastic Kubernetes Service)

**Prerequisites**:
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

**Step-by-step setup**:

1. **Configure AWS credentials**:
```bash
# Method 1: Using AWS configure
aws configure
# Enter your Access Key ID
# Enter your Secret Access Key  
# Enter your default region (e.g., us-east-1)
# Enter default output format (json)

# Method 2: Using environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

2. **List available EKS clusters**:
```bash
# See all clusters in your region
aws eks list-clusters

# Get cluster info
aws eks describe-cluster --name your-cluster-name
```

3. **Update kubeconfig for EKS**:
```bash
# This automatically adds the cluster to your kubeconfig
aws eks update-kubeconfig --region us-east-1 --name your-cluster-name

# Specify a custom context name
aws eks update-kubeconfig --region us-east-1 --name your-cluster-name --alias eks-production
```

4. **Test connection**:
```bash
# Switch to EKS cluster
kubectl config use-context arn:aws:eks:us-east-1:123456789:cluster/your-cluster-name

# Or use the alias you created
kubectl config use-context eks-production

# Test access
kubectl get nodes
kubectl get pods -A
```

#### Google GKE (Google Kubernetes Engine)

**Prerequisites**:
```bash
# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Initialize gcloud
gcloud init
```

**Step-by-step setup**:

1. **Authenticate with Google Cloud**:
```bash
# Login to your Google account
gcloud auth login

# Set your project
gcloud config set project your-project-id

# List available projects
gcloud projects list
```

2. **List and connect to GKE clusters**:
```bash
# List clusters
gcloud container clusters list

# Get credentials for a specific cluster
gcloud container clusters get-credentials cluster-name --region=us-central1-a

# Or for zonal clusters
gcloud container clusters get-credentials cluster-name --zone=us-central1-a
```

3. **Test connection**:
```bash
# Check the new context
kubectl config get-contexts

# The context name will be something like:
# gke_your-project_us-central1-a_cluster-name

kubectl get nodes
```

#### Microsoft AKS (Azure Kubernetes Service)

**Prerequisites**:
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installation
az --version
```

**Step-by-step setup**:

1. **Login to Azure**:
```bash
# Interactive login
az login

# List subscriptions
az account list

# Set subscription
az account set --subscription "your-subscription-id"
```

2. **List and connect to AKS clusters**:
```bash
# List resource groups
az group list

# List AKS clusters in a resource group
az aks list --resource-group your-resource-group

# Get credentials
az aks get-credentials --resource-group your-resource-group --name your-cluster-name

# Get credentials with custom context name
az aks get-credentials --resource-group your-resource-group --name your-cluster-name --context aks-production
```

3. **Test connection**:
```bash
# Check contexts
kubectl config get-contexts

# Test access
kubectl get nodes
```

### 3. Connecting to Container-based Local Clusters

#### Kind (Kubernetes in Docker)

**Setup**:
```bash
# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create a cluster
kind create cluster --name my-local-cluster

# Kind automatically updates your kubeconfig
kubectl config get-contexts

# Use the cluster
kubectl config use-context kind-my-local-cluster
kubectl get nodes
```

#### Minikube

**Setup**:
```bash
# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start --driver=docker

# Minikube automatically updates kubeconfig
kubectl config use-context minikube
kubectl get nodes
```

### 4. Managing Multiple Clusters Efficiently

#### Using kubectx and kubens (Recommended Tools)

**Installation**:
```bash
# Install kubectx and kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
```

**Usage**:
```bash
# List all contexts
kubectx

# Switch contexts easily
kubectx vagrant-kubeadm
kubectx eks-production
kubectx gke_project_us-central1-a_cluster-name

# Switch namespaces
kubens kube-system
kubens default
kubens my-app-namespace
```

#### Creating Cluster Profiles

Create a script to manage different cluster configurations:

```bash
# Create cluster management script
cat > ~/bin/cluster-manager << 'EOF'
#!/bin/bash

case $1 in
  "vagrant")
    kubectl config use-context vagrant-kubeadm
    echo "✅ Switched to Vagrant cluster"
    kubectl get nodes --no-headers | wc -l | xargs echo "Nodes:"
    ;;
  "eks")
    kubectl config use-context eks-production
    echo "✅ Switched to EKS production cluster"
    kubectl get nodes --no-headers | wc -l | xargs echo "Nodes:"
    ;;
  "gke")
    kubectl config use-context gke_myproject_us-central1-a_mycluster
    echo "✅ Switched to GKE cluster"
    kubectl get nodes --no-headers | wc -l | xargs echo "Nodes:"
    ;;
  "local")
    kubectl config use-context kind-my-cluster
    echo "✅ Switched to local Kind cluster"
    kubectl get nodes --no-headers | wc -l | xargs echo "Nodes:"
    ;;
  "list")
    echo "Available clusters:"
    kubectl config get-contexts
    ;;
  "current")
    echo "Current cluster:"
    kubectl config current-context
    kubectl cluster-info
    ;;
  *)
    echo "Usage: cluster-manager [vagrant|eks|gke|local|list|current]"
    ;;
esac
EOF

chmod +x ~/bin/cluster-manager
```

**Usage**:
```bash
# Switch to different clusters
cluster-manager vagrant
cluster-manager eks
cluster-manager gke
cluster-manager local

# List all available clusters
cluster-manager list

# Show current cluster info
cluster-manager current
```

### 5. Security Considerations for Multiple Clusters

#### Kubeconfig File Security
```bash
# Set proper permissions
chmod 600 ~/.kube/config
chmod 600 ~/.kube/config-*

# Create separate configs for different environments
mkdir -p ~/.kube/configs
mv ~/.kube/config-vagrant ~/.kube/configs/
mv ~/.kube/config-onprem ~/.kube/configs/

# Use specific configs when needed
kubectl --kubeconfig ~/.kube/configs/config-vagrant get nodes
```

#### Environment Separation
```bash
# Create separate kubeconfig files for different environments
export KUBECONFIG_DEV=~/.kube/config-dev
export KUBECONFIG_STAGING=~/.kube/config-staging  
export KUBECONFIG_PROD=~/.kube/config-prod

# Switch environments
export KUBECONFIG=$KUBECONFIG_DEV
kubectl get nodes

export KUBECONFIG=$KUBECONFIG_PROD
kubectl get nodes
```

#### Access Auditing
```bash
# Check what you can do in each cluster
kubectl auth can-i --list

# Check specific permissions
kubectl auth can-i create pods
kubectl auth can-i delete deployments
kubectl auth can-i get secrets --namespace=kube-system
```

### 6. Troubleshooting Multi-Cluster Setup

#### Common Issues and Solutions

**Issue 1: Certificate Errors Across Clusters**
```bash
# Problem: x509 certificate errors
# Solution: Check certificate expiration
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d | openssl x509 -dates -noout

# Renew certificates if needed (cluster-specific process)
```

**Issue 2: Context Confusion**
```bash
# Always verify which cluster you're connected to
kubectl config current-context
kubectl cluster-info

# Use aliases in your shell
alias k-vagrant='kubectl config use-context vagrant-kubeadm'
alias k-eks='kubectl config use-context eks-production'
alias k-gke='kubectl config use-context gke-cluster'
```

**Issue 3: Network Connectivity**
```bash
# Test network connectivity to different clusters
# For on-premise
ping master-node-ip
telnet master-node-ip 6443

# For cloud clusters
kubectl cluster-info
kubectl get --raw='/healthz'
```

**Issue 4: Authentication Problems**
```bash
# Check authentication for each cluster
kubectl config view --minify
kubectl auth whoami  # If supported by your cluster

# Re-authenticate if needed
# AWS EKS
aws eks update-kubeconfig --name cluster-name

# Google GKE  
gcloud container clusters get-credentials cluster-name

# Azure AKS
az aks get-credentials --name cluster-name --resource-group rg-name
```

## 💻 Usage Examples (Detailed)

### Understanding kubectl Contexts

Before diving into examples, it's crucial to understand that kubectl can manage multiple clusters through "contexts". Think of contexts as saved connection profiles for different clusters.

```bash
# Always check which cluster you're connected to
kubectl config current-context

# List all available clusters
kubectl config get-contexts

# The output shows:
# CURRENT   NAME              CLUSTER           AUTHINFO          NAMESPACE
# *         vagrant-kubeadm   kubernetes        kubernetes-admin  
#           eks-production    eks-cluster       eks-user          
#           gke-staging       gke-cluster       gke-user          
```

**Important**: The `*` indicates your current cluster. Always verify this before running commands!

### Basic Cluster Operations (Step by Step)

#### Switching Between Clusters

```bash
# Method 1: Using kubectl config
kubectl config use-context vagrant-kubeadm      # Switch to Vagrant cluster
kubectl config use-context eks-production       # Switch to EKS cluster
kubectl config use-context gke-staging          # Switch to GKE cluster

# Method 2: Using kubectx (if installed)
kubectx vagrant-kubeadm
kubectx eks-production
kubectx gke-staging

# Always verify after switching
kubectl config current-context
echo "Connected to: $(kubectl config current-context)"
```

#### Getting Cluster Information

```bash
# Switch to your vagrant cluster first
kubectl config use-context vagrant-kubeadm

# Get basic cluster info
kubectl cluster-info
# Output:
# Kubernetes control plane is running at https://192.168.56.10:6443
# CoreDNS is running at https://192.168.56.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

# Get detailed cluster info
kubectl cluster-info dump > cluster-info.txt  # Saves detailed info to file

# Check cluster version
kubectl version --short
# Output:
# Client Version: v1.31.0
# Server Version: v1.31.0
```

#### Exploring Nodes

```bash
# List all nodes (basic view)
kubectl get nodes
# Output:
# NAME           STATUS   ROLES           AGE   VERSION
# controlplane   Ready    control-plane   65d   v1.31.0
# node01         Ready    worker          65d   v1.31.0
# node02         Ready    worker          65d   v1.31.0

# Get detailed node information
kubectl get nodes -o wide
# Shows additional columns: INTERNAL-IP, EXTERNAL-IP, OS-IMAGE, KERNEL-VERSION, CONTAINER-RUNTIME

# Describe a specific node (very detailed)
kubectl describe node controlplane
# Shows: System info, conditions, capacity, allocatable resources, pods, events

# Check node resource usage (requires metrics-server)
kubectl top nodes
# Output:
# NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
# controlplane   156m         7%     1623Mi          41%       
# node01         45m          4%     892Mi           45%       
# node02         52m          5%     934Mi           47%  
```

#### Working with Namespaces

```bash
# List all namespaces
kubectl get namespaces
# or shorthand
kubectl get ns

# Typical output:
# NAME                   STATUS   AGE
# argocd                 Active   64d
# default                Active   65d
# ingress-nginx          Active   57d
# islamic-app            Active   57d
# kube-node-lease        Active   65d
# kube-public            Active   65d
# kube-system            Active   65d
# kubernetes-dashboard   Active   65d

# Get resources in all namespaces
kubectl get pods -A
kubectl get services -A
kubectl get deployments -A

# Work with a specific namespace
kubectl get pods -n kube-system
kubectl get pods -n argocd

# Set default namespace for your context
kubectl config set-context --current --namespace=islamic-app
# Now all commands will use islamic-app namespace by default

# Reset to default namespace
kubectl config set-context --current --namespace=default
```

### Working with Applications (Detailed Examples)

#### Example 1: Deploying a Simple Web Application

```bash
# Make sure you're on the right cluster
kubectl config use-context vagrant-kubeadm

# Step 1: Create a deployment
kubectl create deployment my-nginx --image=nginx:1.20
# This creates:
# - A deployment named "my-nginx"
# - A pod running nginx:1.20 image
# - A replica set managing the pod

# Step 2: Check what was created
kubectl get deployments
kubectl get pods
kubectl get replicasets

# Step 3: Scale the application
kubectl scale deployment my-nginx --replicas=3
kubectl get pods -l app=my-nginx

# Step 4: Expose the application
kubectl expose deployment my-nginx --port=80 --type=NodePort
# This creates a service that makes nginx accessible

# Step 5: Get service details
kubectl get service my-nginx
# Output shows:
# NAME       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# my-nginx   NodePort   10.96.123.45    <none>        80:32000/TCP   1m

# Step 6: Access the application
# Get the NodePort (32000 in example above)
kubectl get svc my-nginx -o jsonpath='{.spec.ports[0].nodePort}'

# Access via any node IP + NodePort
curl http://192.168.56.10:32000  # via control plane
curl http://192.168.56.11:32000  # via worker node 1
curl http://192.168.56.12:32000  # via worker node 2
```

#### Example 2: Working with ConfigMaps and Secrets

```bash
# Create a ConfigMap
kubectl create configmap my-config \
  --from-literal=database_url=postgres://localhost:5432 \
  --from-literal=api_key=dev-key-123

# Create a Secret
kubectl create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=supersecret

# View the ConfigMap
kubectl get configmap my-config -o yaml

# View the Secret (base64 encoded)
kubectl get secret my-secret -o yaml

# Decode secret values
kubectl get secret my-secret -o jsonpath='{.data.username}' | base64 -d
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 -d

# Use in a pod
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: config-demo
spec:
  containers:
  - name: demo
    image: nginx
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: my-config
          key: database_url
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: username
EOF

# Check the pod environment
kubectl exec config-demo -- env | grep -E "(DATABASE_URL|USERNAME)"
```

#### Example 3: Persistent Storage

```bash
# Create a PersistentVolumeClaim
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Check PVC status
kubectl get pvc

# Use the PVC in a pod
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: storage-demo
spec:
  containers:
  - name: demo
    image: nginx
    volumeMounts:
    - name: my-volume
      mountPath: /data
  volumes:
  - name: my-volume
    persistentVolumeClaim:
      claimName: my-pvc
EOF

# Test the storage
kubectl exec storage-demo -- sh -c "echo 'Hello World' > /data/test.txt"
kubectl exec storage-demo -- cat /data/test.txt
```

### Monitoring and Debugging

#### Checking Pod Status and Logs

```bash
# Get all pods with detailed status
kubectl get pods -o wide

# Common pod statuses:
# - Running: Pod is running normally
# - Pending: Pod is waiting to be scheduled
# - CrashLoopBackOff: Pod keeps crashing and restarting
# - ImagePullBackOff: Can't pull the container image
# - Terminating: Pod is being deleted

# Get detailed pod information
kubectl describe pod my-nginx-xxx-yyy

# View pod logs
kubectl logs my-nginx-xxx-yyy

# Follow logs in real-time
kubectl logs -f my-nginx-xxx-yyy

# View logs from previous container instance (if pod restarted)
kubectl logs my-nginx-xxx-yyy --previous

# For multi-container pods, specify container
kubectl logs my-nginx-xxx-yyy -c container-name
```

#### Debugging Techniques

```bash
# Execute commands inside a pod
kubectl exec my-nginx-xxx-yyy -- ls -la
kubectl exec my-nginx-xxx-yyy -- cat /etc/nginx/nginx.conf

# Interactive shell access
kubectl exec -it my-nginx-xxx-yyy -- /bin/bash

# Port forwarding for local access
kubectl port-forward pod/my-nginx-xxx-yyy 8080:80
# Now you can access via http://localhost:8080

# Copy files to/from pods
kubectl cp my-nginx-xxx-yyy:/etc/nginx/nginx.conf ./nginx.conf
kubectl cp ./new-config.conf my-nginx-xxx-yyy:/tmp/

# Check resource usage
kubectl top pod my-nginx-xxx-yyy
kubectl top pods -n kube-system
```

### Advanced Multi-Cluster Operations

#### Comparing Clusters

```bash
# Create a script to compare cluster resources
cat << 'EOF' > cluster-compare.sh
#!/bin/bash

clusters=("vagrant-kubeadm" "eks-production" "gke-staging")

for cluster in "${clusters[@]}"; do
    echo "=== Cluster: $cluster ==="
    kubectl config use-context $cluster
    echo "Nodes: $(kubectl get nodes --no-headers | wc -l)"
    echo "Namespaces: $(kubectl get ns --no-headers | wc -l)"
    echo "Pods: $(kubectl get pods -A --no-headers | wc -l)"
    echo "Services: $(kubectl get svc -A --no-headers | wc -l)"
    echo
done
EOF

chmod +x cluster-compare.sh
./cluster-compare.sh
```

#### Cross-Cluster Resource Management

```bash
# Deploy the same application to multiple clusters
deploy_to_all_clusters() {
    local app_name=$1
    local image=$2
    
    clusters=("vagrant-kubeadm" "gke-staging")
    
    for cluster in "${clusters[@]}"; do
        echo "Deploying $app_name to $cluster..."
        kubectl config use-context $cluster
        kubectl create deployment $app_name --image=$image
        kubectl scale deployment $app_name --replicas=2
        kubectl expose deployment $app_name --port=80 --type=NodePort
        echo "Deployed to $cluster ✅"
    done
}

# Usage
deploy_to_all_clusters my-app nginx:1.20
```

#### Cluster Resource Monitoring

```bash
# Create a monitoring script
cat << 'EOF' > cluster-monitor.sh
#!/bin/bash

CLUSTER_NAME=$(kubectl config current-context)
echo "🔍 Monitoring cluster: $CLUSTER_NAME"
echo "📅 Date: $(date)"
echo

# Node status
echo "🖥️  NODES:"
kubectl get nodes -o custom-columns="NAME:.metadata.name,STATUS:.status.conditions[?(@.type=='Ready')].status,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory"
echo

# Pod status by namespace
echo "📦 PODS BY NAMESPACE:"
kubectl get pods -A --field-selector=status.phase=Running | awk '{print $1}' | sort | uniq -c | sort -nr
echo

# Resource usage (if metrics-server is available)
echo "📊 RESOURCE USAGE:"
kubectl top nodes 2>/dev/null || echo "Metrics server not available"
echo

# Recent events
echo "📝 RECENT EVENTS:"
kubectl get events --sort-by='.lastTimestamp' | tail -10
EOF

chmod +x cluster-monitor.sh
./cluster-monitor.sh
```

### Working with Different Applications in Your Cluster

Based on your current cluster setup, here are specific examples:

#### Working with ArgoCD

```bash
# Switch to vagrant cluster
kubectl config use-context vagrant-kubeadm

# Check ArgoCD status
kubectl get pods -n argocd

# Get ArgoCD server service
kubectl get svc -n argocd

# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

#### Working with Kubernetes Dashboard

```bash
# Check dashboard status
kubectl get pods -n kubernetes-dashboard

# Port forward to access dashboard
kubectl port-forward svc/kubernetes-dashboard -n kubernetes-dashboard 8443:443

# Create a service account for dashboard access (if needed)
kubectl create serviceaccount dashboard-admin -n default
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin

# Get the token
kubectl create token dashboard-admin
```

#### Working with Your Islamic App

```bash
# Check the islamic-app namespace
kubectl get all -n islamic-app

# Check backend logs
kubectl logs -l app=islamic-app-backend -n islamic-app

# Check frontend logs  
kubectl logs -l app=islamic-app-frontend -n islamic-app

# Check database
kubectl exec -it postgres-0 -n islamic-app -- psql -U postgres

# Port forward to access the application
kubectl port-forward svc/nginx -n islamic-app 8080:80
```

### Cleanup and Maintenance

#### Cleaning Up Resources

```bash
# Delete specific resources
kubectl delete deployment my-nginx
kubectl delete service my-nginx
kubectl delete pod config-demo
kubectl delete pvc my-pvc

# Delete by label
kubectl delete pods -l app=my-nginx

# Delete everything in a namespace
kubectl delete all --all -n my-namespace

# Cleanup completed pods
kubectl delete pods --field-selector=status.phase=Succeeded
kubectl delete pods --field-selector=status.phase=Failed
```

#### Regular Maintenance Tasks

```bash
# Check cluster certificate expiration
kubeadm certs check-expiration  # Run on control plane

# View cluster events
kubectl get events --sort-by='.lastTimestamp'

# Check cluster component health
kubectl get componentstatuses

# Monitor resource usage
kubectl top nodes
kubectl top pods -A

# Backup important resources
kubectl get all -o yaml > cluster-backup.yaml
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### 1. Connection Timeout
**Problem**: `Unable to connect to the server`
```bash
# Check VM status
vagrant status

# Restart VMs if needed
vagrant reload

# Verify network connectivity
ping 192.168.56.10
```

#### 2. Certificate Errors
**Problem**: `x509: certificate signed by unknown authority`
```bash
# Re-extract kubeconfig
vagrant ssh controlplane -c "sudo cat /etc/kubernetes/admin.conf" > kubeconfig

# Update kubectl config
cp kubeconfig ~/.kube/config-vagrant
```

#### 3. Context Not Found
**Problem**: `error: context "vagrant-kubeadm" does not exist`
```bash
# List available contexts
kubectl config get-contexts

# Recreate context if needed
kubectl config set-context vagrant-kubeadm \
  --cluster=kubernetes \
  --user=kubernetes-admin
```

#### 4. Permission Denied
**Problem**: Access denied to cluster resources
```bash
# Check user permissions
kubectl auth can-i get pods
kubectl auth can-i create deployments

# Verify kubeconfig user
kubectl config view --minify
```

### Debug Commands
```bash
# Check kubectl configuration
kubectl config view

# Verify cluster connectivity
kubectl cluster-info dump

# Check API server health
kubectl get --raw='/healthz'

# Validate certificates
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d | openssl x509 -text
```

## ⚙️ Advanced Configuration

### Custom Context Names
```bash
# Create custom context with specific namespace
kubectl config set-context vagrant-dev \
  --cluster=kubernetes \
  --user=kubernetes-admin \
  --namespace=development

# Use the custom context
kubectl config use-context vagrant-dev
```

### Multiple Vagrant Clusters
```bash
# For multiple vagrant clusters, use different config files
cp kubeconfig ~/.kube/config-vagrant-cluster1
cp kubeconfig-cluster2 ~/.kube/config-vagrant-cluster2

# Merge multiple configs
KUBECONFIG=~/.kube/config:~/.kube/config-vagrant-cluster1:~/.kube/config-vagrant-cluster2 \
kubectl config view --flatten > ~/.kube/config.new
mv ~/.kube/config.new ~/.kube/config
```

### Automated Scripts
Create a helper script for easy cluster switching:

```bash
# Create script file
cat > ~/bin/k8s-switch << 'EOF'
#!/bin/bash
case $1 in
  vagrant)
    kubectl config use-context vagrant-kubeadm
    ;;
  kind)
    kubectl config use-context kind-my-cluster
    ;;
  do)
    kubectl config use-context do-fra1-k8s-hawil
    ;;
  *)
    echo "Usage: k8s-switch [vagrant|kind|do]"
    kubectl config get-contexts
    ;;
esac
EOF

# Make executable
chmod +x ~/bin/k8s-switch

# Usage
k8s-switch vagrant
```

## 📝 Best Practices

### Security
- ✅ Keep kubeconfig files secure (600 permissions)
- ✅ Regularly rotate certificates
- ✅ Use separate contexts for different environments
- ✅ Backup kubeconfig files

### Organization
- ✅ Use descriptive context names
- ✅ Set default namespaces for contexts
- ✅ Group similar clusters logically
- ✅ Document cluster purposes

### Maintenance
- ✅ Regularly update kubectl
- ✅ Monitor cluster health
- ✅ Keep Vagrant VMs updated
- ✅ Test connectivity periodically

### Performance
- ✅ Use kubectl completion for faster commands
- ✅ Leverage kubectl aliases
- ✅ Use efficient selectors
- ✅ Cache cluster information when possible

## ❓ FAQ

### Q: Can I access the cluster from multiple machines?
**A**: Yes, copy the kubeconfig file to other machines and configure kubectl similarly.

### Q: What happens if I destroy and recreate the Vagrant VMs?
**A**: You'll need to extract a new kubeconfig as certificates will change.

### Q: How do I access services running in the cluster?
**A**: Use port-forwarding or configure ingress:
```bash
# Port forward to a service
kubectl port-forward svc/my-service 8080:80

# Access via NodePort (if configured)
curl http://192.168.56.10:30080
```

### Q: Can I use kubectl plugins with this setup?
**A**: Yes, all kubectl plugins work normally once the context is configured.

### Q: How do I update the cluster configuration?
**A**: Make changes to the Vagrant cluster and re-extract the kubeconfig if needed.

### Q: What if I have networking issues?
**A**: Check VirtualBox network settings and ensure the host-only network is properly configured.

## 📊 Cluster Information

### Current Setup Details
- **Kubernetes Version**: v1.31.0
- **Container Runtime**: CRI-O 1.33.0
- **CNI Plugin**: Calico
- **Operating System**: Ubuntu 24.04.2 LTS
- **Kernel Version**: 6.8.0-53-generic

### Installed Components
- ✅ **ArgoCD**: GitOps continuous delivery
- ✅ **Ingress NGINX**: Ingress controller
- ✅ **Kubernetes Dashboard**: Web UI
- ✅ **Metrics Server**: Resource metrics
- ✅ **CoreDNS**: DNS server
- ✅ **Custom Applications**: Islamic App stack

### Resource Allocation
- **Control Plane**: 2 CPU, 4GB RAM
- **Worker Nodes**: 1 CPU, 2GB RAM each
- **Total**: 4 CPU, 8GB RAM

## 🔗 Useful Links

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [kubeconfig File Format](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section
2. Verify VM and network status
3. Re-extract kubeconfig if needed
4. Check kubectl and cluster versions

---

**Last Updated**: August 14, 2025  
**Author**: DevOps Team  
**Version**: 1.0
