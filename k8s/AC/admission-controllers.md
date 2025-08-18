# Kubernetes Admission Controllers - Comprehensive Guide

## Table of Contents
1. [What are Admission Controllers?](#what-are-admission-controllers)
2. [How Admission Controllers Work](#how-admission-controllers-work)
3. [Types of Admission Controllers](#types-of-admission-controllers)
4. [Built-in Admission Controllers](#built-in-admission-controllers)
5. [Custom Admission Controllers](#custom-admission-controllers)
6. [Mutating vs Validating Admission Controllers](#mutating-vs-validating-admission-controllers)
7. [Common Use Cases](#common-use-cases)
8. [Hands-on Examples](#hands-on-examples)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## What are Admission Controllers?

**Admission Controllers** are plugins that govern and enforce how the Kubernetes cluster is used. They act as **gatekeepers** that intercept requests to the Kubernetes API server before the object is persisted to etcd (the cluster's data store).

### Think of it like Airport Security 🛂
- **You** = Kubernetes object (Pod, Service, etc.)
- **Airport Security** = Admission Controller
- **Airplane** = Kubernetes cluster
- **Security Check** = Validation/Mutation process

Before you can board the plane (enter the cluster), you must pass through security (admission controller) where they:
- Check your ticket (validate your configuration)
- Scan your luggage (mutate/modify your object if needed)
- Either allow you to board or reject you

---

## How Admission Controllers Work

```
┌─────────────┐    ┌──────────────────┐    ┌─────────────────┐    ┌─────────┐
│   kubectl   │───▶│   API Server     │───▶│   Admission     │───▶│  etcd   │
│   apply     │    │  Authentication  │    │  Controllers    │    │ Storage │
│             │    │  Authorization   │    │                 │    │         │
└─────────────┘    └──────────────────┘    └─────────────────┘    └─────────┘
                           │                        │
                           │                        │
                           ▼                        ▼
                    ✅ Who are you?           🔍 Is this allowed?
                    🔑 What can you do?       🔧 Should we modify it?
```

### Request Flow:
1. **Authentication**: Who are you?
2. **Authorization**: What are you allowed to do?
3. **Admission Control**: Should we allow/modify this request?
4. **Persistence**: Store in etcd

---

## Types of Admission Controllers

### 1. **Mutating Admission Controllers** 🔧
- **Purpose**: Modify/change the incoming request
- **When**: Run BEFORE validating controllers
- **Examples**: Add default values, inject sidecars, set resource limits

### 2. **Validating Admission Controllers** ✅
- **Purpose**: Validate the request (accept or reject)
- **When**: Run AFTER mutating controllers
- **Examples**: Enforce security policies, check resource quotas

```
Request Flow:
┌─────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Request   │───▶│    Mutating      │───▶│   Validating    │───▶ Accept/Reject
│             │    │  (Modify/Add)    │    │   (Check/Validate)│
└─────────────┘    └──────────────────┘    └─────────────────┘
```

---

## Built-in Admission Controllers

### Essential Built-in Controllers:

#### 1. **NamespaceLifecycle**
- **Purpose**: Prevents objects from being created in non-existent or terminating namespaces
- **Example**: Blocks pod creation in a namespace being deleted

#### 2. **ResourceQuota**
- **Purpose**: Enforces resource usage limits per namespace
- **Example**: Prevents creating pods that exceed CPU/memory limits

#### 3. **LimitRanger**
- **Purpose**: Enforces min/max resource usage on individual objects
- **Example**: Ensures every container has resource requests/limits

#### 4. **DefaultStorageClass**
- **Purpose**: Assigns default storage class to PVCs without one specified

#### 5. **PodSecurityPolicy** (Deprecated) / **PodSecurity** (New)
- **Purpose**: Enforces security policies on pods
- **Example**: Prevents privileged containers, enforces read-only root filesystems

#### 6. **NodeRestriction**
- **Purpose**: Limits what kubelets can modify
- **Example**: Prevents nodes from modifying other nodes' objects

### Check Enabled Admission Controllers:
```bash
# On the master node
kubectl describe pod kube-apiserver-<master-node> -n kube-system | grep admission-plugins
```

---

## Custom Admission Controllers

### 1. **Validating Admission Webhooks**

#### Example: Block pods without specific labels

```yaml
# validating-webhook-config.yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionWebhook
metadata:
  name: label-validator
webhooks:
- name: validate-pod-labels.example.com
  clientConfig:
    service:
      name: webhook-service
      namespace: webhook-system
      path: "/validate"
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  admissionReviewVersions: ["v1", "v1beta1"]
```

### 2. **Mutating Admission Webhooks**

#### Example: Inject sidecar containers

```yaml
# mutating-webhook-config.yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingAdmissionWebhook
metadata:
  name: sidecar-injector
webhooks:
- name: inject-sidecar.example.com
  clientConfig:
    service:
      name: sidecar-injector
      namespace: webhook-system
      path: "/mutate"
  rules:
  - operations: ["CREATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  admissionReviewVersions: ["v1"]
```

---

## Mutating vs Validating Admission Controllers

### Mutating Controllers Example:
```yaml
# Original Pod Spec
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: nginx

# After Mutating Controller (adds resource limits)
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: nginx
    resources:
      limits:
        cpu: "1"
        memory: "1Gi"
      requests:
        cpu: "100m"
        memory: "128Mi"
```

### Validating Controllers Example:
```yaml
# This would be REJECTED if security policy requires non-root user
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
spec:
  containers:
  - name: app
    image: nginx
    securityContext:
      runAsUser: 0  # Root user - REJECTED!
```

---

## Common Use Cases

### 1. **Security Enforcement**
```yaml
# Example: Ensure all pods run as non-root
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: app
    image: nginx
```

### 2. **Resource Management**
```yaml
# LimitRange example
apiVersion: v1
kind: LimitRange
metadata:
  name: resource-limits
  namespace: production
spec:
  limits:
  - default:
      cpu: "1"
      memory: "1Gi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

### 3. **Policy Compliance**
```yaml
# ResourceQuota example
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: development
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    persistentvolumeclaims: "10"
```

### 4. **Automatic Service Mesh Injection**
- Istio uses mutating webhooks to inject Envoy sidecar proxies
- Linkerd injects its proxy containers automatically

---

## Hands-on Examples

### Example 1: Create a Simple Validating Webhook

#### Step 1: Create the Webhook Server
```go
// webhook-server.go
package main

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    
    admissionv1 "k8s.io/api/admission/v1"
    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/runtime"
)

func validatePod(w http.ResponseWriter, r *http.Request) {
    var admissionReview admissionv1.AdmissionReview
    
    // Decode the admission review
    if err := json.NewDecoder(r.Body).Decode(&admissionReview); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }
    
    // Extract the pod
    var pod corev1.Pod
    if err := json.Unmarshal(admissionReview.Request.Object.Raw, &pod); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }
    
    // Validation logic: Check if pod has required label
    allowed := true
    message := ""
    
    if _, exists := pod.Labels["environment"]; !exists {
        allowed = false
        message = "Pod must have 'environment' label"
    }
    
    // Create admission response
    admissionResponse := &admissionv1.AdmissionResponse{
        UID:     admissionReview.Request.UID,
        Allowed: allowed,
        Result: &metav1.Status{
            Message: message,
        },
    }
    
    admissionReview.Response = admissionResponse
    
    // Return response
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(admissionReview)
}

func main() {
    http.HandleFunc("/validate", validatePod)
    fmt.Println("Webhook server starting on :8443")
    http.ListenAndServeTLS(":8443", "/etc/certs/tls.crt", "/etc/certs/tls.key", nil)
}
```

#### Step 2: Deploy the Webhook
```yaml
# webhook-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-validator
  namespace: webhook-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pod-validator
  template:
    metadata:
      labels:
        app: pod-validator
    spec:
      containers:
      - name: webhook
        image: pod-validator:latest
        ports:
        - containerPort: 8443
        volumeMounts:
        - name: certs
          mountPath: /etc/certs
          readOnly: true
      volumes:
      - name: certs
        secret:
          secretName: webhook-certs
---
apiVersion: v1
kind: Service
metadata:
  name: pod-validator
  namespace: webhook-system
spec:
  selector:
    app: pod-validator
  ports:
  - port: 443
    targetPort: 8443
```

### Example 2: Test the Admission Controller

#### Valid Pod (will be accepted):
```yaml
# valid-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: valid-pod
  labels:
    environment: production  # Required label present
spec:
  containers:
  - name: nginx
    image: nginx
```

#### Invalid Pod (will be rejected):
```yaml
# invalid-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: invalid-pod
  # Missing 'environment' label
spec:
  containers:
  - name: nginx
    image: nginx
```

```bash
# Test the webhook
kubectl apply -f valid-pod.yaml    # ✅ Should succeed
kubectl apply -f invalid-pod.yaml  # ❌ Should be rejected
```

---

## Best Practices

### 1. **Security**
- Always use TLS for webhook communications
- Validate certificates properly
- Implement proper authentication and authorization
- Use least privilege principle

### 2. **Performance**
- Keep validation logic fast (< 100ms recommended)
- Implement proper timeout handling
- Use efficient algorithms
- Cache frequently accessed data

### 3. **Reliability**
- Implement proper error handling
- Use `failurePolicy: Fail` for critical validations
- Test thoroughly in staging environments
- Monitor webhook performance and availability

### 4. **Maintainability**
- Keep admission logic simple and focused
- Document your policies clearly
- Version your webhooks properly
- Implement proper logging

### Example Configuration:
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionWebhook
metadata:
  name: security-validator
webhooks:
- name: security.example.com
  failurePolicy: Fail  # Fail closed for security
  timeoutSeconds: 10   # 10 second timeout
  admissionReviewVersions: ["v1", "v1beta1"]
  # ... rest of configuration
```

---

## Troubleshooting

### Common Issues and Solutions:

#### 1. **Webhook Not Being Called**
```bash
# Check if webhook is registered
kubectl get validatingadmissionwebhooks
kubectl get mutatingadmissionwebhooks

# Check webhook configuration
kubectl describe validatingadmissionwebhook <webhook-name>
```

#### 2. **Certificate Issues**
```bash
# Check certificate validity
openssl x509 -in /path/to/cert.crt -text -noout

# Check if service is reachable
kubectl get svc -n webhook-namespace
```

#### 3. **Timeout Issues**
```bash
# Check webhook pod logs
kubectl logs -n webhook-namespace deployment/webhook-deployment

# Check API server logs
sudo journalctl -u kubelet | grep admission
```

#### 4. **Debugging Admission Requests**
```yaml
# Add debug logging to your webhook
apiVersion: v1
kind: ConfigMap
metadata:
  name: webhook-config
data:
  config.yaml: |
    debug: true
    logLevel: "debug"
```

### Useful Debug Commands:
```bash
# Check admission controller plugins enabled
kube-apiserver --help | grep admission-plugins

# View API server configuration
kubectl get pods -n kube-system kube-apiserver-* -o yaml

# Test webhook connectivity
kubectl get --raw /api/v1/namespaces/webhook-system/services/webhook-service:443/proxy/health
```

---

## Advanced Topics

### 1. **Admission Controller Chains**
Multiple admission controllers can be chained together:
```
Request → MutatingController1 → MutatingController2 → ValidatingController1 → ValidatingController2 → etcd
```

### 2. **Bypass Mechanisms**
Some operations can bypass admission controllers:
- Direct etcd access
- Some system components
- Admission controller exemptions

### 3. **Performance Considerations**
```yaml
# Use namespaceSelector to limit scope
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionWebhook
metadata:
  name: selective-validator
webhooks:
- name: validate.example.com
  namespaceSelector:
    matchLabels:
      admission-webhook: enabled
  # This webhook only runs for labeled namespaces
```

---

## Quick Reference

### Enable/Disable Admission Controllers:
```bash
# In kube-apiserver configuration
--admission-plugins=NamespaceLifecycle,LimitRanger,ResourceQuota,DefaultStorageClass,PodSecurity

# Disable specific controller
--disable-admission-plugins=PodSecurityPolicy
```

### Common Admission Controller Flags:
- `--admission-plugins`: Enable specific controllers
- `--disable-admission-plugins`: Disable specific controllers
- `--admission-control-config-file`: Configuration file path

### Testing Commands:
```bash
# Dry-run to test admission controllers
kubectl apply --dry-run=server -f pod.yaml

# Check what would happen without actually creating
kubectl create --dry-run=server -o yaml pod test --image=nginx
```

---

## Summary

Admission Controllers are essential for:
- **Security**: Enforcing security policies and best practices
- **Resource Management**: Controlling resource allocation and usage
- **Compliance**: Ensuring organizational policies are followed
- **Automation**: Automatically modifying objects to meet standards

They act as the final gatekeepers before objects are stored in etcd, making them crucial for maintaining cluster security, stability, and compliance.

Remember: **Mutating controllers modify, Validating controllers verify!** 🔧✅
