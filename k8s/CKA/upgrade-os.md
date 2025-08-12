# Kubernetes Cluster Upgrade Guide

## Overview
This guide covers the process of upgrading Kubernetes cluster nodes from one version to another. The upgrade process must be performed in a specific order: control plane first, then worker nodes.

## Prerequisites

### Before You Begin
- Ensure you have administrative access to all cluster nodes
- Verify current cluster status and health
- Have a backup of your cluster configuration
- Understand the upgrade path (only upgrade one minor version at a time)
- Review the Kubernetes release notes for breaking changes

### Check Current Cluster Version
```bash
# Check cluster version
kubectl version --short

# Check node status
kubectl get nodes

# Check component status
kubectl get componentstatus
```

## Step 1: Prepare for Upgrade

### 1.1 Drain the Node (Make it Unschedulable)
Before upgrading any worker node, you must drain it to safely evict all pods:

```bash
# From the control plane node, drain the worker node
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data --force

# Verify the node is cordoned and pods are evicted
kubectl get nodes
kubectl get pods -o wide | grep node01
```

### 1.2 Access the Target Node
```bash
# SSH into the worker node from control plane
ssh node01

# Verify you're on the correct node
hostname
```

## Step 2: Update Package Repository

### 2.1 Update Kubernetes Repository
Update the Kubernetes apt repository to point to the target version:

```bash
# Edit the Kubernetes repository configuration
sudo vim /etc/apt/sources.list.d/kubernetes.list

# Update the version in the URL to the target release (e.g., v1.33)
# Change from: deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /
# To: deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /
```

**Note**: Replace `v1.33` with your actual target Kubernetes version.

### 2.2 Refresh Package Cache
```bash
# Update the package cache
sudo apt update

# Verify available kubeadm versions
apt-cache madison kubeadm | grep 1.33
```

## Step 3: Upgrade kubeadm

### 3.1 Install Updated kubeadm
```bash
# Hold kubelet and kubectl to prevent automatic updates
sudo apt-mark hold kubelet kubectl

# Install the specific kubeadm version
sudo apt-get install -y kubeadm=1.33.0-1.1

# Verify the installation
kubeadm version
```

### 3.2 Upgrade the Node Configuration
```bash
# Upgrade the node configuration
sudo kubeadm upgrade node

# This command will:
# - Download the new cluster configuration
# - Upgrade the local kubelet configuration
# - Update certificates if needed
```

## Step 4: Upgrade kubelet and kubectl

### 4.1 Install Updated kubelet
```bash
# Install the specific kubelet version
sudo apt-get install -y kubelet=1.33.0-1.1

# Optional: Also upgrade kubectl (recommended)
sudo apt-get install -y kubectl=1.33.0-1.1

# Verify versions
kubelet --version
kubectl version --client
```

### 4.2 Restart kubelet Service
```bash
# Reload systemd daemon to pick up new configurations
sudo systemctl daemon-reload

# Restart the kubelet service
sudo systemctl restart kubelet

# Verify kubelet is running
sudo systemctl status kubelet

# Check kubelet logs for any issues
sudo journalctl -xeu kubelet
```

## Step 5: Verify and Uncordon Node

### 5.1 Return to Control Plane
```bash
# Exit from the worker node
exit
# or
logout
# or press Ctrl+D
```

### 5.2 Verify Node Upgrade
```bash
# Check if the node is ready and shows the new version
kubectl get nodes

# Check detailed node information
kubectl describe node node01

# Verify the node is still drained
kubectl get node node01 -o yaml | grep -i taint
```

### 5.3 Uncordon the Node
```bash
# Make the node schedulable again
kubectl uncordon node01

# Verify the node is ready and schedulable
kubectl get nodes

# Check that pods can be scheduled on the node
kubectl get pods -o wide
```

## Step 6: Post-Upgrade Verification

### 6.1 Cluster Health Checks
```bash
# Check overall cluster status
kubectl cluster-info

# Verify all nodes are ready
kubectl get nodes

# Check system pods are running
kubectl get pods -n kube-system

# Run a test deployment to verify functionality
kubectl create deployment test-nginx --image=nginx
kubectl scale deployment test-nginx --replicas=3
kubectl get pods -o wide

# Clean up test deployment
kubectl delete deployment test-nginx
```

### 6.2 Application Health Checks
```bash
# Check your application namespaces
kubectl get namespaces

# Verify application pods are running
kubectl get pods --all-namespaces

# Test application connectivity (example)
kubectl get services
```

## Best Practices and Important Notes

### Upgrade Order
1. **Always upgrade the control plane first**
2. **Upgrade worker nodes one at a time**
3. **Never skip Kubernetes minor versions**
4. **Test the upgrade in a non-production environment first**

### Safety Measures
- **Backup your cluster** before starting any upgrade
- **Check application compatibility** with the new Kubernetes version
- **Monitor cluster metrics** during and after the upgrade
- **Have a rollback plan** ready in case of issues

### Common Issues and Troubleshooting

#### Issue: kubelet fails to start
```bash
# Check kubelet logs
sudo journalctl -xeu kubelet

# Common fixes:
# 1. Check if swap is disabled
sudo swapoff -a

# 2. Verify kubelet configuration
sudo systemctl cat kubelet

# 3. Reset and rejoin if necessary (last resort)
sudo kubeadm reset
```

#### Issue: Node remains NotReady
```bash
# Check node conditions
kubectl describe node node01

# Check network plugin status
kubectl get pods -n kube-system | grep -E "(calico|flannel|weave)"

# Restart network plugin if needed
kubectl delete pods -n kube-system -l k8s-app=calico-node
```

### Version Compatibility Matrix
Always refer to the official Kubernetes documentation for supported version skew policies:
- Control plane components can be one minor version newer than worker nodes
- kubelet can be one minor version older than kube-apiserver
- kubectl can be one minor version older or newer than kube-apiserver

## Additional Resources
- [Official Kubernetes Upgrade Documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
- [Kubernetes Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/)
- [Cluster Administration Documentation](https://kubernetes.io/docs/concepts/cluster-administration/)