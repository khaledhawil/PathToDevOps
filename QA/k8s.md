# Kubernetes Interview Questions and Answers for DevOps Engineers & System Administrators

## Table of Contents
1. [Kubernetes Basics](#kubernetes-basics)
2. [Kubernetes Architecture](#kubernetes-architecture)
3. [Pods and Workloads](#pods-and-workloads)
4. [Services and Networking](#services-and-networking)
5. [Storage and Persistent Volumes](#storage-and-persistent-volumes)
6. [ConfigMaps and Secrets](#configmaps-and-secrets)
7. [Deployments and ReplicaSets](#deployments-and-replicasets)
8. [StatefulSets and DaemonSets](#statefulsets-and-daemonsets)
9. [Ingress and Load Balancing](#ingress-and-load-balancing)
10. [RBAC and Security](#rbac-and-security)
11. [Monitoring and Logging](#monitoring-and-logging)
12. [Cluster Management](#cluster-management)
13. [Troubleshooting](#troubleshooting)
14. [Advanced Topics](#advanced-topics)

---

## Kubernetes Basics

### 1. What is Kubernetes and why is it needed?

**Short Answer:** Kubernetes is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications.

**Detailed Explanation:**

**Core Benefits:**
- **Container Orchestration**: Manages containers across multiple hosts
- **Auto-scaling**: Scales applications based on resource usage
- **Self-healing**: Automatically restarts failed containers
- **Load Balancing**: Distributes traffic across healthy containers
- **Rolling Updates**: Zero-downtime deployments
- **Service Discovery**: Automatic DNS resolution between services

**Key Features:**
```bash
# Kubernetes solves these problems:
# 1. Manual container management across multiple hosts
# 2. Service discovery and load balancing
# 3. Storage orchestration
# 4. Secret and configuration management
# 5. Automatic rollbacks and health checks
```

**Use Cases:**
- Microservices architecture
- CI/CD pipelines
- Multi-cloud deployments
- DevOps automation
- Container lifecycle management

### 2. Explain Kubernetes architecture and its components.

**Short Answer:** Kubernetes follows a master-worker architecture with control plane components managing worker nodes that run application pods.

**Detailed Explanation:**

**Control Plane Components:**

1. **API Server (kube-apiserver)**
   - REST API gateway for all cluster operations
   - Authentication and authorization
   - Validates and processes API requests

2. **etcd**
   - Distributed key-value store
   - Stores all cluster state and configuration
   - Provides strong consistency

3. **Controller Manager (kube-controller-manager)**
   - Node Controller: Monitors node health
   - Replication Controller: Maintains desired replica count
   - Endpoints Controller: Manages service endpoints
   - Service Account & Token Controllers

4. **Scheduler (kube-scheduler)**
   - Assigns pods to nodes based on resource requirements
   - Considers constraints, affinity rules, and policies

**Worker Node Components:**

1. **kubelet**
   - Node agent that communicates with API server
   - Manages pod lifecycle on the node
   - Reports node and pod status

2. **kube-proxy**
   - Network proxy implementing service abstraction
   - Maintains network rules for load balancing
   - Handles service discovery

3. **Container Runtime**
   - Runs containers (Docker, containerd, CRI-O)
   - Pulls images and manages container lifecycle

**Architecture Commands:**
```bash
# Check cluster components
kubectl get nodes
kubectl get pods -n kube-system
kubectl cluster-info

# Component status
kubectl get componentstatuses
kubectl get events --sort-by=.metadata.creationTimestamp

# Node information
kubectl describe node node-name
kubectl top nodes
```

### 3. What are the different types of Kubernetes objects?

**Short Answer:** Kubernetes objects include Pods, Services, Deployments, ConfigMaps, Secrets, and many others that define desired cluster state.

**Detailed Explanation:**

**Core Objects:**

1. **Pod**: Smallest deployable unit containing one or more containers
2. **Service**: Stable endpoint for accessing pods
3. **Deployment**: Manages pod replicas and rolling updates
4. **ReplicaSet**: Maintains specified number of pod replicas
5. **Namespace**: Virtual cluster for resource isolation

**Configuration Objects:**
```yaml
# ConfigMap - Configuration data
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://db:5432/myapp"
  log_level: "info"

# Secret - Sensitive data
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: cGFzc3dvcmQ=
```

**Storage Objects:**
```yaml
# PersistentVolume
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-storage
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: fast-ssd

# PersistentVolumeClaim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: fast-ssd
```

**Workload Objects:**
```bash
# List different object types
kubectl api-resources
kubectl api-versions

# Get objects
kubectl get all
kubectl get pods,services,deployments
kubectl get pv,pvc
kubectl get configmaps,secrets
```

---

## Pods and Workloads

### 4. What is a Pod and how does it work?

**Short Answer:** A Pod is the smallest deployable unit in Kubernetes, containing one or more tightly coupled containers that share network and storage.

**Detailed Explanation:**

**Pod Characteristics:**
- Containers in a pod share the same network (IP address and port space)
- Containers share storage volumes
- Containers are scheduled together on the same node
- Pods are ephemeral and replaceable

**Basic Pod Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-pod
  labels:
    app: webapp
    tier: frontend
spec:
  containers:
  - name: webapp
    image: nginx:1.20
    ports:
    - containerPort: 80
    env:
    - name: ENV
      value: "production"
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "200m"
    volumeMounts:
    - name: config-volume
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: config-volume
    configMap:
      name: nginx-config
```

**Multi-container Pod Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: webapp
    image: myapp:latest
    ports:
    - containerPort: 8080
  - name: sidecar-proxy
    image: nginx:alpine
    ports:
    - containerPort: 80
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  - name: log-collector
    image: fluentd:latest
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  volumes:
  - name: shared-data
    emptyDir: {}
  - name: log-volume
    hostPath:
      path: /var/log/pods
```

**Pod Management Commands:**
```bash
# Create and manage pods
kubectl create -f pod.yaml
kubectl apply -f pod.yaml
kubectl get pods
kubectl get pods -o wide
kubectl describe pod webapp-pod

# Pod logs and debugging
kubectl logs webapp-pod
kubectl logs webapp-pod -c container-name  # Multi-container pod
kubectl logs -f webapp-pod                 # Follow logs

# Execute commands in pods
kubectl exec -it webapp-pod -- /bin/bash
kubectl exec webapp-pod -- ls -la /app

# Port forwarding
kubectl port-forward webapp-pod 8080:80

# Delete pods
kubectl delete pod webapp-pod
kubectl delete -f pod.yaml
```

### 5. Explain Pod lifecycle and restart policies.

**Short Answer:** Pods go through phases (Pending, Running, Succeeded, Failed, Unknown) with restart policies controlling container restart behavior.

**Detailed Explanation:**

**Pod Phases:**
1. **Pending**: Pod accepted but containers not yet created
2. **Running**: Pod bound to node, at least one container running
3. **Succeeded**: All containers terminated successfully
4. **Failed**: All containers terminated, at least one failed
5. **Unknown**: Pod state cannot be determined

**Container States:**
- **Waiting**: Container not yet running (pulling image, etc.)
- **Running**: Container executing normally
- **Terminated**: Container finished execution

**Restart Policies:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: restart-policy-example
spec:
  restartPolicy: Always  # Always, OnFailure, Never
  containers:
  - name: webapp
    image: nginx:latest
    livenessProbe:
      httpGet:
        path: /health
        port: 80
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /ready
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
```

**Health Checks:**
```yaml
# Comprehensive health checks
spec:
  containers:
  - name: webapp
    image: myapp:latest
    # Liveness probe - restart container if fails
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
        httpHeaders:
        - name: Custom-Header
          value: Awesome
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
    
    # Readiness probe - remove from service if fails
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
      successThreshold: 1
      failureThreshold: 3
    
    # Startup probe - for slow-starting containers
    startupProbe:
      httpGet:
        path: /startup
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 10
      failureThreshold: 30
```

**Monitoring Pod Lifecycle:**
```bash
# Watch pod status
kubectl get pods -w
kubectl get pods --field-selector=status.phase=Running

# Pod events and details
kubectl describe pod webapp-pod
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get pods -o jsonpath='{.items[*].status.phase}'

# Pod conditions
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,CONDITIONS:.status.conditions[*].type
```

---

## Services and Networking

### 6. What are Kubernetes Services and their types?

**Short Answer:** Services provide stable endpoints for accessing pods, with types including ClusterIP, NodePort, LoadBalancer, and ExternalName.

**Detailed Explanation:**

**Service Types:**

1. **ClusterIP (Default)**
   - Internal cluster communication only
   - Provides stable internal IP and DNS name

2. **NodePort**
   - Exposes service on each node's IP at a static port
   - Accessible from outside cluster

3. **LoadBalancer**
   - Exposes service externally using cloud provider's load balancer
   - Automatically provisions external load balancer

4. **ExternalName**
   - Maps service to DNS name
   - Returns CNAME record

**Service Examples:**
```yaml
# ClusterIP Service
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  type: ClusterIP
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP

---
# NodePort Service
apiVersion: v1
kind: Service
metadata:
  name: webapp-nodeport
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080

---
# LoadBalancer Service
apiVersion: v1
kind: Service
metadata:
  name: webapp-lb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
spec:
  type: LoadBalancer
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 8080
```

**Service Discovery:**
```yaml
# Service with multiple ports
apiVersion: v1
kind: Service
metadata:
  name: multi-port-service
spec:
  selector:
    app: webapp
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8443
  - name: metrics
    port: 9090
    targetPort: 9090
```

**Service Management:**
```bash
# Service operations
kubectl create service clusterip webapp --tcp=80:8080
kubectl expose deployment webapp --port=80 --target-port=8080

# Get service information
kubectl get services
kubectl get svc -o wide
kubectl describe service webapp-service

# Service endpoints
kubectl get endpoints
kubectl get endpoints webapp-service

# Test service connectivity
kubectl run test-pod --image=busybox -it --rm -- /bin/sh
# Inside pod: wget -qO- webapp-service:80

# Port forwarding for testing
kubectl port-forward service/webapp-service 8080:80
```

### 7. Explain Kubernetes networking model and CNI.

**Short Answer:** Kubernetes uses a flat network model where every pod gets a unique IP, implemented through Container Network Interface (CNI) plugins.

**Detailed Explanation:**

**Networking Principles:**
1. **All pods can communicate** with all other pods without NAT
2. **All nodes can communicate** with all pods without NAT
3. **IP that a pod sees itself as** is the same IP that others see it as

**CNI Plugins:**
- **Flannel**: Simple overlay network using VXLAN
- **Calico**: L3 networking with BGP, includes network policies
- **Weave**: Mesh network with automatic discovery
- **Cilium**: eBPF-based networking with advanced features

**Network Policies:**
```yaml
# Network Policy Example
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: webapp-netpol
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: webapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
    - podSelector:
        matchLabels:
          app: nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: database
    ports:
    - protocol: TCP
      port: 5432
```

**DNS and Service Discovery:**
```yaml
# Pod accessing service by DNS
apiVersion: v1
kind: Pod
metadata:
  name: dns-test
spec:
  containers:
  - name: test
    image: busybox
    command: ['sh', '-c', 'sleep 3600']
```

```bash
# DNS resolution examples
kubectl exec dns-test -- nslookup webapp-service
kubectl exec dns-test -- nslookup webapp-service.default.svc.cluster.local

# DNS naming convention:
# service-name.namespace.svc.cluster.local
# webapp-service.production.svc.cluster.local
```

**Networking Troubleshooting:**
```bash
# Check CNI plugin
kubectl get nodes -o wide
kubectl get pods -n kube-system | grep -E '(flannel|calico|weave|cilium)'

# Network connectivity testing
kubectl run netshoot --image=nicolaka/netshoot -it --rm -- /bin/bash
# Inside netshoot:
# ping pod-ip
# telnet service-name port
# dig service-name

# Check network policies
kubectl get networkpolicies
kubectl describe networkpolicy webapp-netpol

# Node networking
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
```

---

## Storage and Persistent Volumes

### 8. Explain Kubernetes storage concepts: Volumes, PV, and PVC.

**Short Answer:** Kubernetes storage includes ephemeral volumes, Persistent Volumes (cluster storage resources), and Persistent Volume Claims (user requests for storage).

**Detailed Explanation:**

**Storage Hierarchy:**
1. **Volumes**: Directory accessible to containers in a pod
2. **Persistent Volumes (PV)**: Cluster-wide storage resources
3. **Persistent Volume Claims (PVC)**: User requests for storage
4. **Storage Classes**: Dynamic provisioning templates

**Volume Types:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-example
spec:
  containers:
  - name: webapp
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/nginx/conf.d
    - name: data-volume
      mountPath: /var/www/html
    - name: temp-volume
      mountPath: /tmp
  volumes:
  # ConfigMap volume
  - name: config-volume
    configMap:
      name: nginx-config
  # Persistent volume claim
  - name: data-volume
    persistentVolumeClaim:
      claimName: webapp-pvc
  # Temporary storage
  - name: temp-volume
    emptyDir: {}
```

**Persistent Volume Example:**
```yaml
# Persistent Volume
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs
  nfs:
    server: nfs-server.example.com
    path: /exports/data

---
# Persistent Volume Claim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: webapp-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: nfs
```

**Storage Classes:**
```yaml
# AWS EBS Storage Class
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true

---
# Usage in PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: webapp-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: fast-ssd
```

**StatefulSet with Persistent Storage:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: database
spec:
  serviceName: database
  replicas: 3
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: myapp
        - name: POSTGRES_USER
          value: admin
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Gi
      storageClassName: fast-ssd
```

### 9. How do you manage storage in production Kubernetes environments?

**Short Answer:** Use Storage Classes for dynamic provisioning, implement backup strategies, monitor storage usage, and plan for volume expansion.

**Detailed Explanation:**

**Production Storage Strategy:**
```yaml
# Production Storage Class with backup
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: production-ssd
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
  encrypted: "true"
  kmsKeyId: arn:aws:kms:region:account:key/key-id
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Retain
```

**Backup and Restore:**
```yaml
# Velero backup for persistent volumes
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: daily-backup
  namespace: velero
spec:
  includedNamespaces:
  - production
  - staging
  snapshotVolumes: true
  storageLocation: aws-s3
  ttl: 720h0m0s  # 30 days
```

**Storage Monitoring:**
```yaml
# Storage monitoring with Prometheus
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: kubelet-pv-stats
spec:
  endpoints:
  - interval: 30s
    path: /metrics/cadvisor
    port: https-metrics
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
  selector:
    matchLabels:
      k8s-app: kubelet
```

**Storage Commands:**
```bash
# Storage management
kubectl get pv
kubectl get pvc
kubectl get storageclass

# Storage details
kubectl describe pv pv-name
kubectl describe pvc pvc-name
kubectl get pv -o custom-columns=NAME:.metadata.name,SIZE:.spec.capacity.storage,STATUS:.status.phase

# Volume expansion
kubectl patch pvc webapp-pvc -p '{"spec":{"resources":{"requests":{"storage":"50Gi"}}}}'

# Storage troubleshooting
kubectl get events --field-selector involvedObject.kind=PersistentVolumeClaim
kubectl logs -n kube-system -l app=ebs-csi-controller
```

---

## ConfigMaps and Secrets

### 10. How do you manage configuration and secrets in Kubernetes?

**Short Answer:** Use ConfigMaps for non-sensitive configuration data and Secrets for sensitive information like passwords, tokens, and certificates.

**Detailed Explanation:**

**ConfigMap Examples:**
```yaml
# ConfigMap from literal values
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://db:5432/myapp"
  log_level: "info"
  max_connections: "100"
  config.yaml: |
    server:
      port: 8080
      timeout: 30s
    database:
      host: db.example.com
      port: 5432
      name: myapp

---
# Using ConfigMap in Pod
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: webapp
    image: myapp:latest
    env:
    # Single environment variable
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    # All keys as environment variables
    envFrom:
    - configMapRef:
        name: app-config
    volumeMounts:
    # Mount as file
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
      items:
      - key: config.yaml
        path: app-config.yaml
```

**Secret Examples:**
```yaml
# Secret with different types
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  username: YWRtaW4=  # admin (base64)
  password: cGFzc3dvcmQ=  # password (base64)

---
# TLS Secret for HTTPS
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTi... # base64 encoded certificate
  tls.key: LS0tLS1CRUdJTi... # base64 encoded private key

---
# Docker registry secret
apiVersion: v1
kind: Secret
metadata:
  name: registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ewogICJhdXRocyI6IH... # base64 encoded docker config
```

**Using Secrets in Pods:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-webapp
spec:
  imagePullSecrets:
  - name: registry-secret
  containers:
  - name: webapp
    image: private-registry.com/myapp:latest
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: password
    volumeMounts:
    - name: tls-certs
      mountPath: /etc/certs
      readOnly: true
  volumes:
  - name: tls-certs
    secret:
      secretName: tls-secret
```

**External Secret Management:**
```yaml
# External Secrets Operator
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: app-secrets
    creationPolicy: Owner
  data:
  - secretKey: username
    remoteRef:
      key: prod/database
      property: username
  - secretKey: password
    remoteRef:
      key: prod/database
      property: password
```

**Management Commands:**
```bash
# ConfigMap management
kubectl create configmap app-config --from-literal=key1=value1 --from-literal=key2=value2
kubectl create configmap app-config --from-file=config/
kubectl create configmap nginx-config --from-file=nginx.conf

# Secret management
kubectl create secret generic app-secrets --from-literal=username=admin --from-literal=password=secret
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key
kubectl create secret docker-registry registry-secret --docker-server=registry.com --docker-username=user --docker-password=pass

# View and edit
kubectl get configmaps
kubectl get secrets
kubectl describe configmap app-config
kubectl describe secret app-secrets
kubectl edit configmap app-config

# Base64 encoding/decoding
echo -n "password" | base64
echo "cGFzc3dvcmQ=" | base64 -d
```

---

## Deployments and ReplicaSets

### 11. Explain Deployments and how they manage application updates.

**Short Answer:** Deployments manage ReplicaSets to provide declarative updates, rolling deployments, and rollback capabilities for stateless applications.

**Detailed Explanation:**

**Deployment Structure:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-deployment
  labels:
    app: webapp
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
        version: v1
    spec:
      containers:
      - name: webapp
        image: myapp:1.0.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
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

**Update Strategies:**
```yaml
# Rolling Update (Default)
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 25%  # Can be number or percentage
      maxSurge: 25%        # Additional pods during update

# Recreate Strategy
spec:
  strategy:
    type: Recreate  # All pods terminated before new ones created
```

**Blue-Green Deployment Example:**
```yaml
# Blue deployment (current)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
      version: blue
  template:
    metadata:
      labels:
        app: webapp
        version: blue
    spec:
      containers:
      - name: webapp
        image: myapp:1.0.0

---
# Green deployment (new)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
      version: green
  template:
    metadata:
      labels:
        app: webapp
        version: green
    spec:
      containers:
      - name: webapp
        image: myapp:2.0.0

---
# Service (switch between blue and green)
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp
    version: blue  # Change to 'green' for switch
  ports:
  - port: 80
    targetPort: 8080
```

**Deployment Management:**
```bash
# Create and update deployments
kubectl create deployment webapp --image=myapp:1.0.0 --replicas=3
kubectl apply -f deployment.yaml

# Update deployment
kubectl set image deployment/webapp webapp=myapp:2.0.0
kubectl patch deployment webapp -p '{"spec":{"template":{"spec":{"containers":[{"name":"webapp","image":"myapp:2.0.0"}]}}}}'

# Scale deployment
kubectl scale deployment webapp --replicas=5
kubectl autoscale deployment webapp --min=3 --max=10 --cpu-percent=70

# Rollout management
kubectl rollout status deployment/webapp
kubectl rollout history deployment/webapp
kubectl rollout undo deployment/webapp
kubectl rollout undo deployment/webapp --to-revision=2

# Pause and resume rollouts
kubectl rollout pause deployment/webapp
kubectl rollout resume deployment/webapp

# Get deployment details
kubectl get deployments
kubectl describe deployment webapp
kubectl get rs  # ReplicaSets
kubectl get pods -l app=webapp
```

### 12. What are ReplicaSets and how do they differ from Deployments?

**Short Answer:** ReplicaSets ensure a specified number of pod replicas are running, while Deployments provide higher-level management including rolling updates and rollbacks.

**Detailed Explanation:**

**ReplicaSet Example:**
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: webapp-rs
  labels:
    app: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
      tier: frontend
  template:
    metadata:
      labels:
        app: webapp
        tier: frontend
    spec:
      containers:
      - name: webapp
        image: nginx:1.20
        ports:
        - containerPort: 80
```

**Key Differences:**

| Feature | ReplicaSet | Deployment |
|---------|------------|------------|
| Purpose | Maintains pod replicas | Manages ReplicaSets + updates |
| Updates | Manual replacement | Rolling updates |
| Rollbacks | Not supported | Built-in rollback |
| Scaling | Manual | Manual + Auto-scaling |
| Use Case | Direct pod management | Application deployment |

**Deployment vs ReplicaSet Relationship:**
```bash
# View the relationship
kubectl get deployment webapp -o yaml | grep -A 5 spec:
kubectl get rs -l app=webapp
kubectl describe deployment webapp

# Deployment creates and manages ReplicaSets
# webapp-deployment-abc123  (current version)
# webapp-deployment-def456  (previous version, scaled to 0)
```

**Advanced ReplicaSet Features:**
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: advanced-rs
spec:
  replicas: 5
  selector:
    matchLabels:
      app: webapp
    matchExpressions:
    - key: tier
      operator: In
      values:
      - frontend
      - cache
    - key: environment
      operator: NotIn
      values:
      - debug
  template:
    metadata:
      labels:
        app: webapp
        tier: frontend
        environment: production
    spec:
      containers:
      - name: webapp
        image: myapp:latest
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
```

---

## Monitoring and Logging

### 13. How do you implement monitoring and logging in Kubernetes?

**Short Answer:** Use Prometheus for metrics collection, Grafana for visualization, and ELK/EFK stack for centralized logging with proper instrumentation.

**Detailed Explanation:**

**Prometheus Monitoring Setup:**
```yaml
# Prometheus ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    rule_files:
      - /etc/prometheus/rules/*.yml
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

---
# Prometheus Deployment
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
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus
        - name: data-volume
          mountPath: /prometheus
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--web.enable-lifecycle'
      volumes:
      - name: config-volume
        configMap:
          name: prometheus-config
      - name: data-volume
        persistentVolumeClaim:
          claimName: prometheus-storage
```

**Application Instrumentation:**
```yaml
# Pod with Prometheus annotations
apiVersion: v1
kind: Pod
metadata:
  name: webapp
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
spec:
  containers:
  - name: webapp
    image: myapp:latest
    ports:
    - containerPort: 8080
    - containerPort: 9090  # metrics port
```

**Grafana Dashboard:**
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
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config
          mountPath: /etc/grafana/provisioning
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-storage
      - name: grafana-config
        configMap:
          name: grafana-config
```

**Centralized Logging with Fluentd:**
```yaml
# Fluentd DaemonSet for log collection
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      serviceAccountName: fluentd
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch
        env:
        - name: FLUENT_ELASTICSEARCH_HOST
          value: "elasticsearch.logging.svc.cluster.local"
        - name: FLUENT_ELASTICSEARCH_PORT
          value: "9200"
        - name: FLUENT_ELASTICSEARCH_SCHEME
          value: "http"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluentd-config
          mountPath: /fluentd/etc
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluentd-config
        configMap:
          name: fluentd-config
```

**Monitoring Commands:**
```bash
# Prometheus and metrics
kubectl port-forward svc/prometheus 9090:9090
kubectl get pods -l app=prometheus

# Check application metrics
kubectl exec webapp -- curl localhost:9090/metrics

# Grafana access
kubectl port-forward svc/grafana 3000:3000

# Log aggregation
kubectl logs -f daemonset/fluentd -n kube-system
kubectl logs webapp --previous  # Previous container logs

# Resource monitoring
kubectl top nodes
kubectl top pods
kubectl top pods --containers
```

---

## Troubleshooting

### 14. How do you troubleshoot common Kubernetes issues?

**Short Answer:** Use systematic approach: check pod status, examine logs, verify configurations, test networking, and analyze resource constraints.

**Detailed Explanation:**

**Pod Troubleshooting Workflow:**
```bash
# 1. Check pod status
kubectl get pods -o wide
kubectl describe pod webapp-pod

# 2. Check logs
kubectl logs webapp-pod
kubectl logs webapp-pod --previous
kubectl logs webapp-pod -c container-name  # Multi-container

# 3. Check events
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector involvedObject.name=webapp-pod

# 4. Debug pod interactively
kubectl exec -it webapp-pod -- /bin/bash
kubectl run debug-pod --image=busybox -it --rm -- /bin/sh
```

**Common Issues and Solutions:**

**1. ImagePullBackOff:**
```bash
# Check image name and registry access
kubectl describe pod webapp-pod
kubectl get events --field-selector reason=Failed

# Solutions:
# - Verify image name and tag
# - Check registry credentials
# - Ensure image exists
# - Check imagePullSecrets
```

**2. CrashLoopBackOff:**
```bash
# Check application logs
kubectl logs webapp-pod --previous
kubectl describe pod webapp-pod

# Common causes:
# - Application startup failures
# - Missing configuration
# - Resource constraints
# - Failed health checks
```

**3. Pending Pods:**
```bash
# Check node resources and scheduling
kubectl describe pod webapp-pod
kubectl get nodes
kubectl describe node node-name

# Common causes:
# - Insufficient resources
# - Node selectors/affinity
# - Taints and tolerations
# - PVC binding issues
```

**Network Troubleshooting:**
```bash
# Test network connectivity
kubectl run netshoot --image=nicolaka/netshoot -it --rm -- /bin/bash

# Inside netshoot container:
# Test DNS resolution
nslookup kubernetes.default.svc.cluster.local
nslookup webapp-service.default.svc.cluster.local

# Test connectivity
ping pod-ip
telnet service-name port
curl -v http://service-name:port/health

# Check network policies
kubectl get networkpolicies
kubectl describe networkpolicy policy-name
```

**Storage Troubleshooting:**
```bash
# Check PV/PVC status
kubectl get pv,pvc
kubectl describe pvc webapp-pvc

# Check storage class
kubectl get storageclass
kubectl describe storageclass gp2

# Volume mount issues
kubectl describe pod webapp-pod | grep -A 5 Volumes
kubectl describe pod webapp-pod | grep -A 10 Mounts
```

**Performance Issues:**
```bash
# Resource utilization
kubectl top nodes
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory

# Detailed resource analysis
kubectl describe node node-name
kubectl get pods --field-selector spec.nodeName=node-name

# Check resource quotas
kubectl get resourcequota
kubectl describe resourcequota
```

### 15. What are the essential kubectl commands for troubleshooting?

**Short Answer:** Master get, describe, logs, exec, port-forward, and debug commands for effective Kubernetes troubleshooting.

**Detailed Explanation:**

**Essential Diagnostic Commands:**
```bash
# Cluster overview
kubectl cluster-info
kubectl get nodes -o wide
kubectl get namespaces

# Resource inspection
kubectl get all
kubectl get pods -o wide --all-namespaces
kubectl get pods --field-selector=status.phase=Failed
kubectl get events --sort-by=.metadata.creationTimestamp

# Detailed investigation
kubectl describe pod webapp-pod
kubectl describe node node-name
kubectl describe service webapp-service

# Logs and debugging
kubectl logs webapp-pod -f --tail=100
kubectl logs -l app=webapp --max-log-requests=10
kubectl exec -it webapp-pod -- /bin/bash
kubectl exec webapp-pod -- ps aux
```

**Advanced Troubleshooting:**
```bash
# Resource usage and limits
kubectl top pods --containers
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU-REQUEST:.spec.containers[*].resources.requests.cpu,MEMORY-REQUEST:.spec.containers[*].resources.requests.memory

# Network debugging
kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash
kubectl port-forward pod/webapp-pod 8080:80
kubectl proxy --port=8080

# Configuration inspection
kubectl get configmap webapp-config -o yaml
kubectl get secret webapp-secret -o yaml
kubectl get deployment webapp -o yaml | grep -A 10 env

# API resource exploration
kubectl api-resources
kubectl api-versions
kubectl explain pod.spec.containers
kubectl explain deployment.spec.strategy.rollingUpdate
```

**Debugging Workflows:**
```bash
# Complete pod debugging workflow
debug_pod() {
    local pod_name=$1
    
    echo "=== Pod Status ==="
    kubectl get pod $pod_name -o wide
    
    echo "=== Pod Description ==="
    kubectl describe pod $pod_name
    
    echo "=== Pod Logs ==="
    kubectl logs $pod_name --tail=50
    
    echo "=== Recent Events ==="
    kubectl get events --field-selector involvedObject.name=$pod_name --sort-by=.metadata.creationTimestamp
    
    echo "=== Node Information ==="
    node=$(kubectl get pod $pod_name -o jsonpath='{.spec.nodeName}')
    kubectl describe node $node | head -20
}

# Service debugging workflow
debug_service() {
    local service_name=$1
    
    echo "=== Service Details ==="
    kubectl get service $service_name -o wide
    kubectl describe service $service_name
    
    echo "=== Endpoints ==="
    kubectl get endpoints $service_name
    
    echo "=== Pods behind service ==="
    kubectl get pods -l $(kubectl get service $service_name -o jsonpath='{.spec.selector}' | tr ',' ' ')
}
```

This comprehensive Kubernetes interview guide covers all essential topics for DevOps engineers and system administrators, providing both quick answers and detailed explanations with practical examples, real-world scenarios, and troubleshooting techniques.