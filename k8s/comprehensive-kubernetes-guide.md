# Comprehensive Kubernetes Guide

## Table of Contents
1. [Introduction to Kubernetes](#introduction-to-kubernetes)
2. [Kubernetes Architecture](#kubernetes-architecture)
3. [Installation and Setup](#installation-and-setup)
4. [Basic Concepts](#basic-concepts)
5. [Pods](#pods)
6. [Deployments](#deployments)
7. [Services](#services)
8. [ConfigMaps and Secrets](#configmaps-and-secrets)
9. [Storage (Volumes, PV, PVC)](#storage-volumes-pv-pvc)
10. [Namespaces](#namespaces)
11. [ReplicaSets](#replicasets)
12. [StatefulSets](#statefulsets)
13. [DaemonSets](#daemonsets)
14. [Jobs and CronJobs](#jobs-and-cronjobs)
15. [Ingress](#ingress)
16. [Network Policies](#network-policies)
17. [Security and RBAC](#security-and-rbac)
18. [Monitoring and Logging](#monitoring-and-logging)
19. [Troubleshooting](#troubleshooting)
20. [Best Practices](#best-practices)

## Introduction to Kubernetes

Kubernetes (K8s) is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications.

### Why Kubernetes?
- **Automated Deployment**: Deploy applications across multiple hosts
- **Scaling**: Automatically scale applications up or down
- **Self-Healing**: Replace failed containers automatically
- **Service Discovery**: Automatically discover and connect services
- **Load Balancing**: Distribute traffic across multiple instances
- **Rolling Updates**: Update applications without downtime

### Key Benefits
- **High Availability**: Ensures applications are always running
- **Scalability**: Handle varying loads efficiently
- **Portability**: Run anywhere (cloud, on-premises, hybrid)
- **Resource Efficiency**: Optimize resource utilization
- **DevOps Integration**: Supports CI/CD workflows

## Kubernetes Architecture

### Master Node Components
```
┌─────────────────────────────────────────┐
│              Master Node                │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │   API       │  │   Controller    │   │
│  │   Server    │  │   Manager       │   │
│  └─────────────┘  └─────────────────┘   │
│  ┌─────────────┐  ┌─────────────────┐   │
│  │    etcd     │  │   Scheduler     │   │
│  │             │  │                 │   │
│  └─────────────┘  └─────────────────┘   │
└─────────────────────────────────────────┘
```

#### API Server
- Entry point for all administrative tasks
- Validates and processes REST operations
- Updates etcd with cluster state

#### etcd
- Distributed key-value store
- Stores all cluster data
- Provides backup and restore capabilities

#### Controller Manager
- Runs controller processes
- Monitors cluster state
- Makes changes to achieve desired state

#### Scheduler
- Assigns pods to nodes
- Considers resource requirements
- Applies scheduling policies

### Worker Node Components
```
┌─────────────────────────────────────────┐
│              Worker Node                │
├─────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────────┐   │
│  │   kubelet   │  │   kube-proxy    │   │
│  │             │  │                 │   │
│  └─────────────┘  └─────────────────┘   │
│  ┌─────────────────────────────────────┐ │
│  │        Container Runtime            │ │
│  │        (Docker/containerd)          │ │
│  └─────────────────────────────────────┘ │
│  ┌─────────────────────────────────────┐ │
│  │             Pods                    │ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

#### kubelet
- Primary node agent
- Manages pod lifecycle
- Reports node status to master

#### kube-proxy
- Network proxy on each node
- Maintains network rules
- Enables service communication

#### Container Runtime
- Runs containers
- Examples: Docker, containerd, CRI-O

## Installation and Setup

### 1. Installing kubectl

#### Linux
```bash
# Download latest version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make executable and move to PATH
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

#### macOS
```bash
# Using Homebrew
brew install kubectl

# Or download directly
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### 2. Setting up Minikube (Local Development)

```bash
# Install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Start Minikube
minikube start

# Check status
minikube status

# Dashboard
minikube dashboard

# Stop Minikube
minikube stop

# Delete cluster
minikube delete
```

### 3. Setting up Kind (Kubernetes in Docker)

```bash
# Install Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create cluster
kind create cluster

# Create cluster with config
kind create cluster --config=kind-config.yaml

# Delete cluster
kind delete cluster
```

### 4. kubeadm Installation (Production)

#### Install kubeadm, kubelet, and kubectl
```bash
# Update system
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Add Kubernetes signing key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add Kubernetes repository
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

#### Initialize cluster (Master node)
```bash
# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for regular user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install pod network (Flannel)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

#### Join worker nodes
```bash
# Run on worker nodes (get token from master init output)
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## Basic Concepts

### Kubernetes Objects
Every Kubernetes object has:
- **apiVersion**: API version
- **kind**: Type of object
- **metadata**: Data about the object
- **spec**: Desired state
- **status**: Current state (managed by Kubernetes)

### Basic Object Structure
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: my-app
spec:
  containers:
  - name: my-container
    image: nginx:1.20
    ports:
    - containerPort: 80
```

### Essential kubectl Commands

#### Basic Operations
```bash
# Get cluster information
kubectl cluster-info
kubectl get nodes
kubectl get all

# Create resources
kubectl create -f file.yaml
kubectl apply -f file.yaml
kubectl apply -f directory/

# Get resources
kubectl get pods
kubectl get services
kubectl get deployments
kubectl get all -n namespace

# Describe resources
kubectl describe pod pod-name
kubectl describe service service-name
kubectl describe deployment deployment-name

# Delete resources
kubectl delete pod pod-name
kubectl delete -f file.yaml
kubectl delete deployment deployment-name

# Logs and debugging
kubectl logs pod-name
kubectl logs -f pod-name
kubectl exec -it pod-name -- /bin/bash
kubectl port-forward pod-name 8080:80
```

#### Advanced Operations
```bash
# Scale deployments
kubectl scale deployment nginx --replicas=5

# Update resources
kubectl set image deployment/nginx nginx=nginx:1.21

# Rollback
kubectl rollout undo deployment/nginx
kubectl rollout history deployment/nginx

# Edit resources
kubectl edit deployment nginx

# Labels and selectors
kubectl get pods -l app=nginx
kubectl label pods my-pod environment=production

# Resource usage
kubectl top nodes
kubectl top pods
```

## Pods

Pods are the smallest deployable units in Kubernetes. A pod can contain one or more containers that share storage and network.

### Simple Pod Example
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.20
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### Multi-Container Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: web-server
    image: nginx:1.20
    ports:
    - containerPort: 80
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  
  - name: log-processor
    image: busybox
    command: ['sh', '-c', 'while true; do echo "Processing logs..."; sleep 30; done']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  
  volumes:
  - name: shared-data
    emptyDir: {}
```

### Pod with Environment Variables
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
spec:
  containers:
  - name: app
    image: nginx:1.20
    env:
    - name: DATABASE_URL
      value: "postgresql://user:pass@db:5432/mydb"
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: api-secret
          key: api-key
    - name: CONFIG_VALUE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: config-value
```

### Pod Commands
```bash
# Create pod
kubectl apply -f pod.yaml

# Get pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods --show-labels

# Describe pod
kubectl describe pod nginx-pod

# Get pod logs
kubectl logs nginx-pod
kubectl logs -f nginx-pod
kubectl logs nginx-pod -c container-name

# Execute commands in pod
kubectl exec nginx-pod -- ls /
kubectl exec -it nginx-pod -- /bin/bash

# Port forwarding
kubectl port-forward nginx-pod 8080:80

# Delete pod
kubectl delete pod nginx-pod
```

## Deployments

Deployments provide declarative updates for pods and ReplicaSets. They handle rolling updates, rollbacks, and scaling.

### Basic Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
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
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### Deployment with Rolling Update Strategy
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: my-app:v1.0
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Deployment Commands
```bash
# Create deployment
kubectl apply -f deployment.yaml

# Get deployments
kubectl get deployments
kubectl get deploy -o wide

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5

# Update deployment image
kubectl set image deployment/nginx-deployment nginx=nginx:1.21

# Check rollout status
kubectl rollout status deployment/nginx-deployment

# View rollout history
kubectl rollout history deployment/nginx-deployment

# Rollback deployment
kubectl rollout undo deployment/nginx-deployment
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Pause/Resume rollout
kubectl rollout pause deployment/nginx-deployment
kubectl rollout resume deployment/nginx-deployment

# Delete deployment
kubectl delete deployment nginx-deployment
```

## Services

Services provide stable network endpoints for pods. They enable communication between different parts of your application.

### Service Types
1. **ClusterIP**: Internal cluster communication (default)
2. **NodePort**: Exposes service on each node's IP
3. **LoadBalancer**: Creates external load balancer
4. **ExternalName**: Maps service to external DNS name

### ClusterIP Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

### NodePort Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
```

### LoadBalancer Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

### Headless Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-headless
spec:
  clusterIP: None
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

### Service Commands
```bash
# Create service
kubectl apply -f service.yaml

# Get services
kubectl get services
kubectl get svc -o wide

# Describe service
kubectl describe service nginx-service

# Get endpoints
kubectl get endpoints

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it -- wget -qO- nginx-service

# Delete service
kubectl delete service nginx-service
```

## ConfigMaps and Secrets

ConfigMaps store non-confidential configuration data, while Secrets store sensitive information.

### ConfigMap Examples

#### Create ConfigMap from literal values
```bash
kubectl create configmap app-config \
  --from-literal=database.host=localhost \
  --from-literal=database.port=5432
```

#### ConfigMap YAML
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.host: "localhost"
  database.port: "5432"
  app.properties: |
    debug=true
    log.level=INFO
    max.connections=100
```

#### Using ConfigMap in Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
spec:
  containers:
  - name: app
    image: nginx
    env:
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database.host
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

### Secret Examples

#### Create Secret from command line
```bash
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secretpassword
```

#### Secret YAML
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded 'admin'
  password: c2VjcmV0cGFzc3dvcmQ=  # base64 encoded 'secretpassword'
```

#### TLS Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi...  # base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi...  # base64 encoded private key
```

#### Using Secret in Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: nginx
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: db-secret
```

### ConfigMap and Secret Commands
```bash
# Create ConfigMap
kubectl create configmap app-config --from-file=config.properties
kubectl create configmap app-config --from-literal=key=value

# Create Secret
kubectl create secret generic db-secret --from-literal=password=secret
kubectl create secret docker-registry myregistrykey \
  --docker-server=DOCKER_REGISTRY_SERVER \
  --docker-username=DOCKER_USER \
  --docker-password=DOCKER_PASSWORD \
  --docker-email=DOCKER_EMAIL

# Get ConfigMaps and Secrets
kubectl get configmaps
kubectl get secrets

# Describe
kubectl describe configmap app-config
kubectl describe secret db-secret

# Edit
kubectl edit configmap app-config
kubectl edit secret db-secret

# Delete
kubectl delete configmap app-config
kubectl delete secret db-secret
```

This completes the first part of the comprehensive Kubernetes guide. The documentation continues with storage, networking, and advanced topics in the next sections.
