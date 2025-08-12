
# Kubernetes Cluster Installation with kubeadm

## Overview
This guide provides step-by-step instructions for installing a Kubernetes cluster using kubeadm. The process includes setting up both control plane and worker nodes.

**Reference**: [Official kubeadm Installation Guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

## Prerequisites
- Ubuntu 20.04+ or compatible Linux distribution
- 2 GB+ RAM per machine
- 2+ CPUs for control plane nodes
- Full network connectivity between nodes
- Unique hostname, MAC address, and product_uuid for every node
- Container runtime already installed (assumed in this guide)

---

## Part 1: Node Preparation (Perform on ALL Nodes)

### Step 1: Configure Network Bridge Settings

Set up kernel modules and network parameters required for Kubernetes:

```bash
# Load br_netfilter module
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

# Configure network bridge settings
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply the settings
sudo sysctl --system
```

**Note**: The container runtime is already installed on both nodes, so we skip this step.

### Step 2: Install Kubernetes Components

Install kubeadm, kubectl, and kubelet on all nodes:

```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl containerd

# Create keyrings directory
sudo mkdir -p /etc/apt/keyrings

# Download Kubernetes signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package index again
sudo apt-get update

# Check available versions
sudo apt-cache madison kubeadm

# Install specific versions of Kubernetes components
sudo apt-get install -y kubelet=1.33.0-1.1 kubeadm=1.33.0-1.1 kubectl=1.33.0-1.1

# Prevent automatic updates
sudo apt-mark hold kubelet kubeadm kubectl
```

---

## Part 2: Control Plane Initialization (Control Plane Node Only)

### Step 3: Initialize the Kubernetes Cluster

Run the kubeadm init command to create the control plane:

```bash
# Get the control plane IP address
IP_ADDR=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Initialize the cluster with custom network settings
kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address $IP_ADDR --pod-network-cidr=172.17.0.0/16 --service-cidr=172.20.0.0/16
```

### Expected Output
When you run the init command, you should see output similar to:

```
[init] Using Kubernetes version: v1.33.1
[preflight] Running pre-flight checks
        [WARNING SystemVerification]: cgroups v1 support is in maintenance mode, please migrate to cgroups v2
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'

W0520 03:05:34.890872   11137 checks.go:846] detected that the sandbox image "registry.k8s.io/pause:3.6" of the container runtime is inconsistent with that used by kubeadm.It is recommended to use "registry.k8s.io/pause:3.10" as the CRI sandbox image.

[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [controlplane kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [172.20.0.1 192.168.9.95]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [controlplane localhost] and IPs [192.168.9.95 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [controlplane localhost] and IPs [192.168.9.95 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key

[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "super-admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file

[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"

[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet

[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests"
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 1.001862161s

[control-plane-check] Waiting for healthy control plane components. This can take up to 4m0s
[control-plane-check] Checking kube-apiserver at https://192.168.9.95:6443/livez
[control-plane-check] Checking kube-controller-manager at https://127.0.0.1:10257/healthz
[control-plane-check] Checking kube-scheduler at https://127.0.0.1:10259/livez
[control-plane-check] kube-scheduler is healthy after 12.743187359s
[control-plane-check] kube-controller-manager is healthy after 17.259346714s
[control-plane-check] kube-apiserver is healthy after 35.501756821s

[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs

[mark-control-plane] Marking the node controlplane as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node controlplane as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]

[bootstrap-token] Using token: 50bd8b.x003t0tq1fzmultg
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace

[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!
```

### Step 4: Configure kubectl for Regular User

After successful initialization, configure kubectl access:

```bash
# Create .kube directory
mkdir -p $HOME/.kube

# Copy admin configuration
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Change ownership
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## Part 3: Network Plugin Installation (Control Plane Node Only)

### Step 5: Install and Configure Flannel Network Plugin

Download and configure the Flannel network plugin:

```bash
# Download the Flannel manifest
curl -LO https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml
```

### Step 6: Modify Flannel Configuration

**Important**: We need to modify the Flannel configuration to match our custom Pod CIDR.

Open the `kube-flannel.yml` file with a text editor and make the following changes:

#### 6.1 Update Network CIDR

Find the `kube-flannel-cfg` ConfigMap section and update the Network field:

```yaml
net-conf.json: |
    {
      "Network": "172.17.0.0/16",  # Change from "10.244.0.0/16" to match our PodCIDR
      "Backend": {
        "Type": "vxlan"
      }
    }
```

#### 6.2 Add Interface Specification

Locate the `args` section within the kube-flannel container definition and add the `--iface=eth0` argument:

```yaml
args:
- --ip-masq
- --kube-subnet-mgr
- --iface=eth0  # Add this line
```

### Step 7: Apply the Modified Flannel Manifest

```bash
# Apply the modified Flannel configuration
kubectl apply -f kube-flannel.yml
```

### Step 8: Monitor Pod Status

Wait for all pods to become ready:

```bash
# Monitor all pods across all namespaces
watch kubectl get pods -A
```

**Expected output when all pods are ready:**

```bash
controlplane ~ ➜  kubectl get pods -A
NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
kube-flannel   kube-flannel-ds-gc5kf                  1/1     Running   0          54s
kube-flannel   kube-flannel-ds-mtjd6                  1/1     Running   0          54s
kube-system    coredns-668d6bf9bc-7lf7s               1/1     Running   0          3m31s
kube-system    coredns-668d6bf9bc-jl8t6               1/1     Running   0          3m31s
kube-system    etcd-controlplane                      1/1     Running   0          3m37s
kube-system    kube-apiserver-controlplane            1/1     Running   0          3m37s
kube-system    kube-controller-manager-controlplane   1/1     Running   0          3m37s
kube-system    kube-proxy-t5wrt                       1/1     Running   0          3m31s
kube-system    kube-proxy-trmhs                       1/1     Running   0          3m8s
kube-system    kube-scheduler-controlplane            1/1     Running   0          3m37s
```

---

## Part 4: Verification and Node Status

### Step 9: Verify Cluster Status

After all pods are in the Ready state, check that both nodes are ready:

```bash
# Check node status
kubectl get nodes
```

**Expected output:**

```bash
controlplane ~ ➜  kubectl get nodes 
NAME           STATUS   ROLES           AGE   VERSION 
controlplane   Ready    control-plane   15m   v1.33.0 
node01         Ready    <none>          15m   v1.33.0
```

### Step 10: Additional Verification Commands

```bash
# Check cluster information
kubectl cluster-info

# Verify all system components
kubectl get componentstatus

# Check all resources in kube-system namespace
kubectl get all -n kube-system

# Test basic functionality
kubectl create deployment test-nginx --image=nginx
kubectl get deployments
kubectl delete deployment test-nginx
```

---

## Part 5: Worker Node Setup (Worker Nodes Only)

### Step 11: Join Worker Nodes

The `kubeadm init` command will provide a join command. Run this command on worker nodes:

```bash
# Example join command (use the actual command from your init output)
kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

If you need to regenerate the join command:

```bash
# Run on control plane to get join command
kubeadm token create --print-join-command
```

---

## Troubleshooting

### Common Issues and Solutions

1. **Pods stuck in Pending state**
   - Check if network plugin is properly installed
   - Verify node resources with `kubectl describe nodes`

2. **CoreDNS pods not ready**
   - Usually resolves after network plugin installation
   - Check network plugin pod logs

3. **Node not joining cluster**
   - Verify network connectivity between nodes
   - Check if token is still valid
   - Ensure firewall ports are open

### Useful Commands

```bash
# Check kubelet logs
sudo journalctl -xeu kubelet

# Check kubeadm logs
sudo journalctl -xeu kubeadm

# Reset cluster (if needed)
sudo kubeadm reset

# Check pod logs
kubectl logs -n kube-system <pod-name>
```

---

## Summary

This guide covers:
1. **Node preparation** with kernel modules and network settings
2. **Kubernetes component installation** (kubeadm, kubelet, kubectl)
3. **Control plane initialization** with custom network CIDRs
4. **Network plugin installation** and configuration
5. **Cluster verification** and status checks
6. **Worker node joining** process

Your Kubernetes cluster is now ready for deploying applications!