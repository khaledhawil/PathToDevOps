# Kubernetes Installation Guide - Multiple Methods

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Method 1: Minikube (Local Development)](#method-1-minikube-local-development)
3. [Method 2: Kind (Kubernetes in Docker)](#method-2-kind-kubernetes-in-docker)
4. [Method 3: kubeadm (Production Clusters)](#method-3-kubeadm-production-clusters)
5. [Method 4: Docker Desktop](#method-4-docker-desktop)
6. [Method 5: Cloud Providers](#method-5-cloud-providers)
7. [Method 6: K3s (Lightweight Kubernetes)](#method-6-k3s-lightweight-kubernetes)
8. [kubectl Installation](#kubectl-installation)
9. [Verification and Testing](#verification-and-testing)

## Prerequisites

### System Requirements
- **CPU**: 2 cores minimum
- **RAM**: 2GB minimum (4GB recommended)
- **Disk**: 20GB free space
- **Network**: Internet connectivity
- **OS**: Linux, macOS, or Windows

### Required Software
- Docker (for Kind, Minikube with Docker driver)
- VirtualBox or VMware (for Minikube with VM driver)
- Internet browser for dashboard access

## Method 1: Minikube (Local Development)

Minikube runs a single-node Kubernetes cluster inside a VM or container for development and testing.

### Install Minikube

#### Linux
```bash
# Download and install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Verify installation
minikube version
```

#### macOS
```bash
# Using Homebrew
brew install minikube

# Or download directly
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```

#### Windows
```powershell
# Using Chocolatey
choco install minikube

# Or download from: https://github.com/kubernetes/minikube/releases
```

### Start Minikube Cluster

```bash
# Start with default settings
minikube start

# Start with specific driver
minikube start --driver=docker
minikube start --driver=virtualbox
minikube start --driver=vmware

# Start with resource specifications
minikube start --cpus=4 --memory=8192 --disk-size=50g

# Start with specific Kubernetes version
minikube start --kubernetes-version=v1.28.0

# Start with addons
minikube start --addons=dashboard,ingress
```

### Minikube Management

```bash
# Check status
minikube status

# Stop cluster
minikube stop

# Delete cluster
minikube delete

# Pause/Unpause cluster
minikube pause
minikube unpause

# SSH into minikube node
minikube ssh

# Get minikube IP
minikube ip

# Open dashboard
minikube dashboard

# Enable addons
minikube addons enable dashboard
minikube addons enable ingress
minikube addons enable metrics-server

# List addons
minikube addons list
```

### Example: Deploy Application on Minikube

```bash
# Start minikube
minikube start

# Create deployment
kubectl create deployment nginx --image=nginx

# Expose deployment
kubectl expose deployment nginx --type=NodePort --port=80

# Get service URL
minikube service nginx --url

# Access in browser
minikube service nginx
```

## Method 2: Kind (Kubernetes in Docker)

Kind runs Kubernetes clusters using Docker containers as nodes.

### Install Kind

#### Linux/macOS
```bash
# Download and install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify installation
kind version
```

#### Using Go
```bash
go install sigs.k8s.io/kind@v0.20.0
```

### Create Kind Cluster

```bash
# Create default cluster
kind create cluster

# Create cluster with custom name
kind create cluster --name my-cluster

# Create cluster with specific Kubernetes version
kind create cluster --image kindest/node:v1.28.0

# List clusters
kind get clusters

# Delete cluster
kind delete cluster --name kind
```

### Kind Configuration File

Create a `kind-config.yaml` file:

```yaml
# Simple single-node cluster
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: my-cluster
nodes:
- role: control-plane
```

```yaml
# Multi-node cluster with load balancer
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: multi-node-cluster
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
- role: worker
```

```yaml
# Cluster with custom networking
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: custom-network
networking:
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443
  podSubnet: "10.240.0.0/16"
  serviceSubnet: "10.0.0.0/16"
nodes:
- role: control-plane
- role: worker
```

### Create Cluster with Configuration

```bash
# Create cluster with config file
kind create cluster --config=kind-config.yaml

# Load Docker image into Kind cluster
kind load docker-image nginx:latest --name my-cluster

# Get cluster kubeconfig
kind get kubeconfig --name my-cluster
```

## Method 3: kubeadm (Production Clusters)

kubeadm helps you bootstrap a minimum viable Kubernetes cluster.

### Prerequisites for All Nodes

```bash
# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

### Install Container Runtime (containerd)

```bash
# Install containerd
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install containerd
sudo apt-get update
sudo apt-get install containerd.io

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Edit config to use systemd cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
```

### Install kubeadm, kubelet, and kubectl

```bash
# Update package index
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add Kubernetes apt repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package index and install
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet
sudo systemctl enable kubelet
```

### Initialize Master Node

```bash
# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=YOUR_MASTER_IP

# Configure kubectl for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Pod network (Flannel)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Or install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### Join Worker Nodes

```bash
# On worker nodes, run the join command from master init output
sudo kubeadm join MASTER_IP:6443 --token TOKEN --discovery-token-ca-cert-hash sha256:HASH

# If you lost the join command, generate new token on master
kubeadm token create --print-join-command
```

### Cluster Configuration Examples

#### High Availability Setup
```yaml
# kubeadm-config.yaml for HA cluster
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "MASTER1_IP"
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.28.0
controlPlaneEndpoint: "LOAD_BALANCER_IP:6443"
networking:
  podSubnet: "10.244.0.0/16"
etcd:
  external:
    endpoints:
    - https://ETCD1_IP:2379
    - https://ETCD2_IP:2379
    - https://ETCD3_IP:2379
    caFile: /etc/kubernetes/pki/etcd/ca.crt
    certFile: /etc/kubernetes/pki/etcd/kubernetes.crt
    keyFile: /etc/kubernetes/pki/etcd/kubernetes.key
```

## Method 4: Docker Desktop

Docker Desktop includes a Kubernetes cluster for development.

### Enable Kubernetes in Docker Desktop

1. **Windows/macOS**: 
   - Open Docker Desktop
   - Go to Settings → Kubernetes
   - Check "Enable Kubernetes"
   - Click "Apply & Restart"

2. **Verify Installation**:
```bash
kubectl config current-context
# Should show: docker-desktop

kubectl get nodes
# Should show single node named docker-desktop
```

### Switch Between Contexts
```bash
# List contexts
kubectl config get-contexts

# Switch to Docker Desktop
kubectl config use-context docker-desktop

# Switch to other clusters
kubectl config use-context kind-kind
kubectl config use-context minikube
```

## Method 5: Cloud Providers

### Amazon EKS

```bash
# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Create EKS cluster
eksctl create cluster --name my-cluster --region us-west-2 --nodegroup-name my-nodes --node-type t3.medium --nodes 3

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name my-cluster

# Delete cluster
eksctl delete cluster --name my-cluster --region us-west-2
```

### Google GKE

```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
gcloud init

# Create GKE cluster
gcloud container clusters create my-cluster --zone us-central1-a --num-nodes 3

# Get credentials
gcloud container clusters get-credentials my-cluster --zone us-central1-a

# Delete cluster
gcloud container clusters delete my-cluster --zone us-central1-a
```

### Azure AKS

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Create resource group
az group create --name myResourceGroup --location eastus

# Create AKS cluster
az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 3 --enable-addons monitoring --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

# Delete cluster
az aks delete --resource-group myResourceGroup --name myAKSCluster
```

## Method 6: K3s (Lightweight Kubernetes)

K3s is a lightweight Kubernetes distribution designed for IoT and edge computing.

### Install K3s Server

```bash
# Install K3s server
curl -sfL https://get.k3s.io | sh -

# Check status
sudo systemctl status k3s

# Get node token for agents
sudo cat /var/lib/rancher/k3s/server/node-token

# Copy kubeconfig for kubectl
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
```

### Install K3s Agent

```bash
# Install agent on worker nodes
curl -sfL https://get.k3s.io | K3S_URL=https://SERVER_IP:6443 K3S_TOKEN=NODE_TOKEN sh -
```

### K3s Management

```bash
# Uninstall server
/usr/local/bin/k3s-uninstall.sh

# Uninstall agent
/usr/local/bin/k3s-agent-uninstall.sh

# Check logs
sudo journalctl -u k3s -f
```

## kubectl Installation

### Linux
```bash
# Download latest version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Validate binary
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### macOS
```bash
# Using Homebrew
brew install kubectl

# Or download directly
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### Windows
```powershell
# Using Chocolatey
choco install kubernetes-cli

# Or using Scoop
scoop install kubectl

# Or download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

### kubectl Configuration

```bash
# View current config
kubectl config view

# Get contexts
kubectl config get-contexts

# Switch context
kubectl config use-context context-name

# Set namespace
kubectl config set-context --current --namespace=my-namespace

# Create alias for kubectl
echo 'alias k=kubectl' >> ~/.bashrc
source ~/.bashrc
```

## Verification and Testing

### Basic Cluster Verification

```bash
# Check cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# Check cluster health
kubectl get componentstatuses

# Check API server
kubectl get --raw="/healthz"

# Check cluster version
kubectl version
```

### Deploy Test Application

```bash
# Create test deployment
kubectl create deployment nginx --image=nginx

# Scale deployment
kubectl scale deployment nginx --replicas=3

# Expose deployment
kubectl expose deployment nginx --port=80 --type=ClusterIP

# Get service details
kubectl get service nginx

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it -- wget -qO- nginx

# Port forward for local access
kubectl port-forward deployment/nginx 8080:80
```

### Troubleshooting Common Issues

#### Node Not Ready
```bash
# Check node status
kubectl describe node NODE_NAME

# Check kubelet logs
sudo journalctl -u kubelet -f

# Check container runtime
sudo systemctl status containerd
```

#### Pod Issues
```bash
# Check pod events
kubectl describe pod POD_NAME

# Check pod logs
kubectl logs POD_NAME

# Execute into pod
kubectl exec -it POD_NAME -- /bin/bash
```

#### Network Issues
```bash
# Check CNI pods
kubectl get pods -n kube-system | grep -E "flannel|calico|weave"

# Check DNS
kubectl run test-dns --image=busybox --rm -it -- nslookup kubernetes.default

# Check service endpoints
kubectl get endpoints
```

### Performance Testing

```bash
# Install metrics-server (for resource monitoring)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Check resource usage
kubectl top nodes
kubectl top pods

# Stress test cluster
kubectl run stress-test --image=progrium/stress --rm -it -- --cpu 2 --timeout 60s
```

This comprehensive installation guide covers all major methods for setting up Kubernetes clusters, from local development to production deployments.
