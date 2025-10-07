# Kubernetes Basics

## What is Kubernetes

Kubernetes (K8s) is a container orchestration platform that automates deployment, scaling, and management of containerized applications.

**Problems Kubernetes solves:**
- Manual container management at scale
- Load balancing across containers
- Automatic restart of failed containers
- Scaling applications up/down
- Rolling updates and rollbacks
- Service discovery
- Configuration management
- Storage orchestration

**Kubernetes vs Docker:**
- Docker: Runs containers on single host
- Kubernetes: Orchestrates containers across multiple hosts

## Kubernetes Architecture

**Master Node (Control Plane):**
- API Server: Frontend for Kubernetes
- Scheduler: Assigns pods to nodes
- Controller Manager: Maintains desired state
- etcd: Key-value store for cluster data

**Worker Nodes:**
- Kubelet: Runs on each node, manages pods
- Container Runtime: Docker, containerd, CRI-O
- Kube-proxy: Network proxy, handles networking

**Flow:**
```
kubectl -> API Server -> Scheduler -> Kubelet -> Container Runtime
```

## Installing Kubernetes

**Minikube (local development):**
```bash
# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start cluster
minikube start

# Check status
minikube status
```

**kubectl (Kubernetes CLI):**
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/

# Verify
kubectl version --client
```

**Verify cluster:**
```bash
kubectl cluster-info
kubectl get nodes
```

## Core Concepts

### Pods

Smallest deployable unit. Can contain one or more containers.

**Create pod:**
```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

**Apply:**
```bash
kubectl apply -f pod.yaml
```

**View pods:**
```bash
kubectl get pods
kubectl get pods -o wide
kubectl describe pod nginx-pod
```

**Logs:**
```bash
kubectl logs nginx-pod
kubectl logs -f nginx-pod
```

**Execute command:**
```bash
kubectl exec nginx-pod -- ls /usr/share/nginx/html
kubectl exec -it nginx-pod -- bash
```

**Delete pod:**
```bash
kubectl delete pod nginx-pod
```

### Deployments

Manages ReplicaSets and provides declarative updates.

**deployment.yaml:**
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
        image: nginx:1.21
        ports:
        - containerPort: 80
```

**Apply:**
```bash
kubectl apply -f deployment.yaml
```

**View deployments:**
```bash
kubectl get deployments
kubectl describe deployment nginx-deployment
```

**Scale deployment:**
```bash
kubectl scale deployment nginx-deployment --replicas=5
```

**Update image:**
```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.22
```

**Rollout status:**
```bash
kubectl rollout status deployment/nginx-deployment
```

**Rollback:**
```bash
kubectl rollout undo deployment/nginx-deployment
```

**Rollout history:**
```bash
kubectl rollout history deployment/nginx-deployment
```

### Services

Exposes pods to network traffic.

**Service types:**
- ClusterIP: Internal cluster IP (default)
- NodePort: Exposes on each node's IP
- LoadBalancer: Cloud load balancer
- ExternalName: Maps to external DNS

**ClusterIP service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

**NodePort service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
```

**Apply:**
```bash
kubectl apply -f service.yaml
```

**View services:**
```bash
kubectl get services
kubectl describe service nginx-service
```

**Test service:**
```bash
kubectl run test-pod --image=busybox -it --rm -- wget -O- nginx-service
```

### ConfigMaps

Store configuration data as key-value pairs.

**configmap.yaml:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "mysql://db:3306/myapp"
  log_level: "info"
  config.properties: |
    app.name=myapp
    app.env=production
```

**Use in pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
```

**Create from file:**
```bash
kubectl create configmap app-config --from-file=config.properties
```

### Secrets

Store sensitive data (passwords, tokens, keys).

**Create secret:**
```bash
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123
```

**secret.yaml:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: c2VjcmV0MTIz  # base64 encoded
```

**Use in pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

### Namespaces

Virtual clusters within physical cluster.

**Create namespace:**
```bash
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace production
```

**List namespaces:**
```bash
kubectl get namespaces
```

**Deploy to namespace:**
```bash
kubectl apply -f deployment.yaml -n dev
```

**Set default namespace:**
```bash
kubectl config set-context --current --namespace=dev
```

**View resources in namespace:**
```bash
kubectl get all -n dev
```

## Complete Application Example

**Directory structure:**
```
k8s/
  deployment.yaml
  service.yaml
  configmap.yaml
  ingress.yaml
```

**deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: myregistry/flask-app:1.0
        ports:
        - containerPort: 5000
        env:
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: environment
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5
```

**service.yaml:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-service
spec:
  selector:
    app: flask-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
  type: ClusterIP
```

**configmap.yaml:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  environment: "production"
  log_level: "info"
  database_url: "postgresql://db:5432/myapp"
```

**Deploy:**
```bash
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

## Useful Commands

**Cluster info:**
```bash
kubectl cluster-info
kubectl get nodes
kubectl top nodes
```

**Resources:**
```bash
kubectl get all
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get configmaps
kubectl get secrets
```

**Describe:**
```bash
kubectl describe pod pod-name
kubectl describe deployment deployment-name
```

**Logs:**
```bash
kubectl logs pod-name
kubectl logs -f pod-name
kubectl logs pod-name -c container-name
```

**Execute:**
```bash
kubectl exec pod-name -- command
kubectl exec -it pod-name -- bash
```

**Port forward:**
```bash
kubectl port-forward pod-name 8080:80
kubectl port-forward service/nginx-service 8080:80
```

**Delete:**
```bash
kubectl delete pod pod-name
kubectl delete deployment deployment-name
kubectl delete service service-name
kubectl delete -f deployment.yaml
```

**Edit:**
```bash
kubectl edit deployment nginx-deployment
```

**Apply:**
```bash
kubectl apply -f file.yaml
kubectl apply -f directory/
```

**Dry run:**
```bash
kubectl apply -f deployment.yaml --dry-run=client
```

## Best Practices

1. **Use namespaces** for environment separation
2. **Set resource limits** (CPU, memory)
3. **Use health checks** (liveness, readiness)
4. **Don't use latest tag**
5. **Use ConfigMaps** for configuration
6. **Use Secrets** for sensitive data
7. **Label everything** properly
8. **Use deployments**, not bare pods
9. **Implement monitoring**
10. **Document your manifests**

## Troubleshooting

**Pod not starting:**
```bash
kubectl describe pod pod-name
kubectl logs pod-name
kubectl get events --sort-by=.metadata.creationTimestamp
```

**Service not accessible:**
```bash
kubectl get endpoints service-name
kubectl describe service service-name
```

**Check pod connectivity:**
```bash
kubectl run test --image=busybox -it --rm -- wget -O- service-name
```

**Resource issues:**
```bash
kubectl top nodes
kubectl top pods
```

## Practice Exercises

1. Deploy nginx with 3 replicas
2. Create service to expose deployment
3. Scale deployment to 5 replicas
4. Perform rolling update
5. Create ConfigMap and use in pod
6. Create Secret and mount in pod
7. Set up namespace and deploy app
8. Configure resource limits

## Next Steps

Kubernetes is complex. Practice with minikube before moving to production clusters.

Continue to: `03-terraform-basics.md`
