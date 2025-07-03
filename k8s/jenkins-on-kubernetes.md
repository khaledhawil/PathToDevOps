# Jenkins on Kubernetes - Complete Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Method 1: Simple Jenkins Deployment](#method-1-simple-jenkins-deployment)
4. [Method 2: Jenkins with Persistent Storage](#method-2-jenkins-with-persistent-storage)
5. [Method 3: Jenkins with Helm Chart](#method-3-jenkins-with-helm-chart)
6. [Method 4: Jenkins with Custom Configuration](#method-4-jenkins-with-custom-configuration)
7. [Method 5: Jenkins with RBAC and Security](#method-5-jenkins-with-rbac-and-security)
8. [Accessing Jenkins](#accessing-jenkins)
9. [Scaling and Management](#scaling-and-management)
10. [Troubleshooting](#troubleshooting)

## Overview

This guide shows multiple ways to deploy Jenkins on Kubernetes, from basic deployment to production-ready setup with security, persistence, and scalability.

### Why Jenkins on Kubernetes?

- **Scalability**: Dynamic agent provisioning
- **Resource Efficiency**: Only use resources when needed
- **High Availability**: Multiple replicas and self-healing
- **Consistency**: Same environment across development and production
- **Integration**: Native Kubernetes CI/CD workflows

## Prerequisites

### Required Tools
```bash
# Ensure you have kubectl installed and configured
kubectl version --client

# Check cluster connectivity
kubectl cluster-info

# Verify you have admin access
kubectl auth can-i '*' '*'
```

### Cluster Requirements
- **Kubernetes**: v1.20+
- **CPU**: 2+ cores available
- **Memory**: 4GB+ available
- **Storage**: 20GB+ for persistent volumes
- **LoadBalancer**: For external access (cloud provider or MetalLB)

## Method 1: Simple Jenkins Deployment

This is the quickest way to get Jenkins running for testing purposes.

### 1.1 Basic Deployment

```yaml
# jenkins-basic.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: default
  labels:
    app: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 50000
          name: agent
        env:
        - name: JAVA_OPTS
          value: "-Xmx2048m -Dhudson.slaves.NodeProvisioner.MARGIN=50 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
      volumes:
      - name: jenkins-home
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  labels:
    app: jenkins
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080
    name: http
  - port: 50000
    targetPort: 50000
    nodePort: 30000
    name: agent
  selector:
    app: jenkins
```

### 1.2 Deploy Basic Jenkins

```bash
# Apply the configuration
kubectl apply -f jenkins-basic.yaml

# Check deployment status
kubectl get deployments
kubectl get pods -l app=jenkins

# Get service information
kubectl get services

# Check logs
kubectl logs deployment/jenkins
```

### 1.3 Access Jenkins

```bash
# Get the node IP
kubectl get nodes -o wide

# Access Jenkins at: http://NODE_IP:30080

# Get initial admin password
kubectl logs deployment/jenkins | grep -A 5 "Jenkins initial setup"
```

## Method 2: Jenkins with Persistent Storage

This method adds persistent storage to keep Jenkins data across pod restarts.

### 2.1 Create Namespace

```yaml
# jenkins-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins
  labels:
    name: jenkins
```

### 2.2 Persistent Volume Claim

```yaml
# jenkins-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard  # Change to your storage class
  resources:
    requests:
      storage: 20Gi
```

### 2.3 Jenkins Deployment with PVC

```yaml
# jenkins-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
  labels:
    app: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      securityContext:
        fsGroup: 1000
        runAsUser: 1000
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 50000
          name: agent
        env:
        - name: JAVA_OPTS
          value: "-Xmx2048m -Dhudson.slaves.NodeProvisioner.MARGIN=50"
        - name: JENKINS_OPTS
          value: "--httpPort=8080"
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        livenessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          failureThreshold: 5
        readinessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          failureThreshold: 3
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-pvc
```

### 2.4 Service with LoadBalancer

```yaml
# jenkins-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  namespace: jenkins
  labels:
    app: jenkins
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
  - name: agent
    port: 50000
    targetPort: 50000
    protocol: TCP
  selector:
    app: jenkins
```

### 2.5 Deploy Persistent Jenkins

```bash
# Create namespace
kubectl apply -f jenkins-namespace.yaml

# Create PVC
kubectl apply -f jenkins-pvc.yaml

# Deploy Jenkins
kubectl apply -f jenkins-deployment.yaml

# Create service
kubectl apply -f jenkins-service.yaml

# Check everything
kubectl get all -n jenkins

# Get external IP (if LoadBalancer is available)
kubectl get service jenkins-service -n jenkins

# Watch deployment progress
kubectl rollout status deployment/jenkins -n jenkins
```

## Method 3: Jenkins with Helm Chart

Helm provides the most flexible and feature-rich Jenkins deployment.

### 3.1 Install Helm

```bash
# Install Helm (if not already installed)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

### 3.2 Add Jenkins Helm Repository

```bash
# Add Jenkins Helm repository
helm repo add jenkins https://charts.jenkins.io

# Update repositories
helm repo update

# Search for Jenkins chart
helm search repo jenkins
```

### 3.3 Create Values File

```yaml
# jenkins-values.yaml
controller:
  image: "jenkins/jenkins"
  tag: "lts"
  
  # Resources
  resources:
    requests:
      cpu: "1000m"
      memory: "2Gi"
    limits:
      cpu: "2000m"
      memory: "4Gi"
  
  # Java options
  javaOpts: "-Xmx3g"
  
  # Service account
  serviceAccount:
    create: true
    name: jenkins
  
  # Admin user
  adminUser: "admin"
  adminPassword: "admin123"  # Change this!
  
  # Persistence
  persistence:
    enabled: true
    storageClass: "standard"
    size: "20Gi"
  
  # Service configuration
  serviceType: LoadBalancer
  servicePort: 80
  
  # Security
  securityRealm: |-
    <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
      <disableSignup>true</disableSignup>
      <enableCaptcha>false</enableCaptcha>
    </securityRealm>
  
  # Install plugins
  installPlugins:
    - kubernetes:3600.v144b_cd192ca_a_
    - workflow-aggregator:2.6
    - git:4.11.3
    - configuration-as-code:1463.v35f6ef0b_8207
    - blueocean:1.24.8
    - pipeline-stage-view:2.25
    - docker-workflow:1.29
  
  # Configuration as Code
  JCasC:
    defaultConfig: true
    configScripts:
      jenkins-config: |
        jenkins:
          systemMessage: "Jenkins configured automatically by Jenkins Configuration as Code plugin\n\n"
          globalNodeProperties:
          - envVars:
              env:
              - key: VARIABLE1
                value: foo
              - key: VARIABLE2
                value: bar
        
        security:
          queueItemAuthenticator:
            authenticators:
            - global:
                strategy: triggeringUsersAuthorizationStrategy

# Agent configuration
agent:
  enabled: true
  image: "jenkins/inbound-agent"
  tag: "4.11.2-4"
  
  # Resources for agents
  resources:
    requests:
      cpu: "500m"
      memory: "512Mi"
    limits:
      cpu: "1000m"
      memory: "1Gi"

# Persistence for agents
persistence:
  enabled: true
  storageClass: "standard"
  size: "8Gi"

# RBAC
rbac:
  create: true
  readSecrets: false

# Service Account
serviceAccount:
  create: true
  name: jenkins

# Network Policy
networkPolicy:
  enabled: false
```

### 3.4 Deploy with Helm

```bash
# Create namespace
kubectl create namespace jenkins

# Install Jenkins with Helm
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --values jenkins-values.yaml

# Check installation status
helm status jenkins -n jenkins

# Get the admin password
kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode

# Watch pods come up
kubectl get pods -n jenkins -w
```

### 3.5 Upgrade Jenkins

```bash
# Update Helm repo
helm repo update

# Upgrade Jenkins
helm upgrade jenkins jenkins/jenkins \
  --namespace jenkins \
  --values jenkins-values.yaml

# Check upgrade status
helm history jenkins -n jenkins
```

## Method 4: Jenkins with Custom Configuration

This method uses ConfigMaps for custom Jenkins configuration.

### 4.1 Jenkins Configuration

```yaml
# jenkins-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: jenkins-config
  namespace: jenkins
data:
  jenkins.yaml: |
    jenkins:
      systemMessage: "Jenkins configured automatically by JCasC"
      globalNodeProperties:
      - envVars:
          env:
          - key: "DOCKER_HOST"
            value: "tcp://docker:2376"
          - key: "DOCKER_TLS_VERIFY"
            value: "1"
      
      securityRealm:
        local:
          allowsSignup: false
          users:
           - id: "admin"
             password: "admin123"
      
      authorizationStrategy:
        globalMatrix:
          permissions:
            - "Overall/Administer:admin"
            - "Overall/Read:authenticated"
      
      remotingSecurity:
        enabled: true
    
    security:
      queueItemAuthenticator:
        authenticators:
        - global:
            strategy: triggeringUsersAuthorizationStrategy
    
    unclassified:
      location:
        url: "http://jenkins.example.com/"
      
      gitHubPluginConfig:
        hookUrl: "http://jenkins.example.com/github-webhook/"
  
  plugins.txt: |
    kubernetes:3600.v144b_cd192ca_a_
    workflow-aggregator:2.6
    git:4.11.3
    configuration-as-code:1463.v35f6ef0b_8207
    blueocean:1.24.8
    pipeline-stage-view:2.25
    docker-workflow:1.29
    github:1.34.3
    pipeline-github-lib:1.0
    ssh-slaves:1.34.0
    matrix-auth:3.1.5
    pam-auth:1.6
    ldap:2.12
    email-ext:2.93
    mailer:1.34
```

### 4.2 Custom Jenkins Image

Create a Dockerfile for custom Jenkins image:

```dockerfile
# Dockerfile
FROM jenkins/jenkins:lts

# Switch to root to install additional tools
USER root

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install additional tools
RUN apt-get update && \
    apt-get install -y git curl wget vim nano && \
    apt-get clean

# Switch back to jenkins user
USER jenkins

# Copy plugins list
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Install plugins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy JCasC configuration
COPY jenkins.yaml /var/jenkins_home/casc_configs/jenkins.yaml

# Set JCasC configuration path
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs
```

### 4.3 Build and Deploy Custom Image

```bash
# Build custom image
docker build -t my-jenkins:latest .

# Tag for registry (if using)
docker tag my-jenkins:latest your-registry.com/my-jenkins:latest

# Push to registry
docker push your-registry.com/my-jenkins:latest
```

### 4.4 Deployment with Custom Image

```yaml
# jenkins-custom-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-custom
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins-custom
  template:
    metadata:
      labels:
        app: jenkins-custom
    spec:
      securityContext:
        fsGroup: 1000
        runAsUser: 1000
      containers:
      - name: jenkins
        image: your-registry.com/my-jenkins:latest
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 50000
          name: agent
        env:
        - name: JAVA_OPTS
          value: "-Xmx3g -Dhudson.slaves.NodeProvisioner.MARGIN=50"
        - name: CASC_JENKINS_CONFIG
          value: "/var/jenkins_home/casc_configs"
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        - name: jenkins-config
          mountPath: /var/jenkins_home/casc_configs
          readOnly: true
        - name: docker-sock
          mountPath: /var/run/docker.sock
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-pvc
      - name: jenkins-config
        configMap:
          name: jenkins-config
      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock
```

## Method 5: Jenkins with RBAC and Security

This method implements proper RBAC and security configurations.

### 5.1 Service Account and RBAC

```yaml
# jenkins-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
```

### 5.2 Secrets for Sensitive Data

```yaml
# jenkins-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-secrets
  namespace: jenkins
type: Opaque
data:
  admin-password: YWRtaW4xMjM=  # base64 encoded "admin123"
  github-token: Z2hwX3h4eHh4eHh4eHh4eA==  # base64 encoded GitHub token
  docker-config: eyJhdXRocyI6e319  # base64 encoded Docker config
---
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJyZWdpc3RyeS5jb20iOnsidXNlcm5hbWUiOiJmb28iLCJwYXNzd29yZCI6ImJhciIsImF1dGgiOiJabTl2T21KaGNnPT0ifX19
```

### 5.3 Network Policy

```yaml
# jenkins-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: jenkins-network-policy
  namespace: jenkins
spec:
  podSelector:
    matchLabels:
      app: jenkins
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: jenkins
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 8080
    - protocol: TCP
      port: 50000
  - from: []  # Allow from anywhere
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to: []  # Allow to anywhere
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 22
    - protocol: TCP
      port: 2376
```

## Accessing Jenkins

### Get Jenkins URL and Credentials

```bash
# For NodePort service
kubectl get nodes -o wide
# Access: http://NODE_IP:30080

# For LoadBalancer service
kubectl get service jenkins-service -n jenkins
# Use EXTERNAL-IP

# For port-forward (temporary access)
kubectl port-forward service/jenkins-service 8080:80 -n jenkins
# Access: http://localhost:8080

# Get admin password (if using secrets)
kubectl get secret jenkins-secrets -n jenkins -o jsonpath="{.data.admin-password}" | base64 --decode

# Get admin password (from logs)
kubectl logs deployment/jenkins -n jenkins | grep -A 5 "Jenkins initial setup"
```

### Setup Jenkins

1. **Initial Setup**:
   - Navigate to Jenkins URL
   - Enter admin password
   - Install suggested plugins or select plugins

2. **Create Admin User**:
   - Set up admin user credentials
   - Configure Jenkins URL

3. **Install Additional Plugins**:
   - Kubernetes Plugin
   - Pipeline Plugins
   - Git Plugin
   - Docker Pipeline Plugin

## Scaling and Management

### Horizontal Pod Autoscaler

```yaml
# jenkins-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: jenkins-hpa
  namespace: jenkins
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: jenkins
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Jenkins Agent Configuration

```yaml
# jenkins-agent-template.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: jenkins-agent-template
  namespace: jenkins
data:
  agent-template.yaml: |
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        jenkins: agent
    spec:
      containers:
      - name: jnlp
        image: jenkins/inbound-agent:latest
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        env:
        - name: JENKINS_URL
          value: "http://jenkins-service:8080"
      - name: docker
        image: docker:dind
        securityContext:
          privileged: true
        volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock
      volumes:
      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock
```

### Backup Strategy

```yaml
# jenkins-backup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: jenkins-backup
  namespace: jenkins
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command:
            - /bin/sh
            - -c
            - |
              tar -czf /backup/jenkins-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /var/jenkins_home .
              find /backup -name "jenkins-backup-*.tar.gz" -mtime +7 -delete
            volumeMounts:
            - name: jenkins-home
              mountPath: /var/jenkins_home
              readOnly: true
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: jenkins-home
            persistentVolumeClaim:
              claimName: jenkins-pvc
          - name: backup-storage
            persistentVolumeClaim:
              claimName: jenkins-backup-pvc
          restartPolicy: OnFailure
```

## Troubleshooting

### Common Issues and Solutions

#### Pod Not Starting
```bash
# Check pod status
kubectl describe pod jenkins-xxx -n jenkins

# Check events
kubectl get events -n jenkins --sort-by=.metadata.creationTimestamp

# Check logs
kubectl logs deployment/jenkins -n jenkins
```

#### Persistent Volume Issues
```bash
# Check PVC status
kubectl get pvc -n jenkins

# Check PV
kubectl get pv

# Check storage class
kubectl get storageclass
```

#### Service Connection Issues
```bash
# Check service endpoints
kubectl get endpoints jenkins-service -n jenkins

# Test service connectivity
kubectl run test-pod --image=busybox --rm -it -n jenkins -- wget -qO- jenkins-service:8080

# Check network policy
kubectl describe networkpolicy -n jenkins
```

#### Plugin Issues
```bash
# Check plugin installation logs
kubectl logs deployment/jenkins -n jenkins | grep -i plugin

# Restart Jenkins
kubectl rollout restart deployment/jenkins -n jenkins

# Check disk space
kubectl exec deployment/jenkins -n jenkins -- df -h
```

### Debug Commands

```bash
# Get all resources in Jenkins namespace
kubectl get all -n jenkins

# Describe deployment
kubectl describe deployment jenkins -n jenkins

# Check resource usage
kubectl top pods -n jenkins

# Get detailed pod information
kubectl get pods -n jenkins -o yaml

# Check RBAC permissions
kubectl auth can-i create pods --as=system:serviceaccount:jenkins:jenkins -n jenkins
```

This comprehensive guide covers all aspects of deploying Jenkins on Kubernetes, from simple setups to production-ready configurations with security, persistence, and scalability features.
