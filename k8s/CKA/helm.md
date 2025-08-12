# Helm Installation and Configuration Guide

## Overview
Helm is the package manager for Kubernetes that helps you manage Kubernetes applications. Helm Charts help you define, install, and upgrade even the most complex Kubernetes applications.

## What is Helm?
- **Package Manager**: Like apt/yum for Linux or npm for Node.js, but for Kubernetes
- **Charts**: Pre-configured Kubernetes resource templates
- **Releases**: Deployed instances of charts in your cluster
- **Repositories**: Collections of charts that can be shared

## Prerequisites
- Kubernetes cluster up and running
- kubectl configured and able to connect to your cluster
- Appropriate permissions to install applications in your cluster

---

## Method 1: Official Installation Script (Recommended)

### Step 1: Download the Helm Installation Script

```bash
# Download the official Helm installation script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
```

**Explanation:**
- `curl -fsSL`: Downloads the file silently with error handling
- `-o get_helm.sh`: Saves the output to a file named `get_helm.sh`
- The script automatically detects your OS and architecture

### Step 2: Make the Script Executable

```bash
# Give execute permissions to the script
chmod 700 get_helm.sh
```

**Explanation:**
- `chmod 700`: Gives read, write, and execute permissions to the owner only
- This ensures only you can run the script for security

### Step 3: Run the Installation Script

```bash
# Execute the installation script
./get_helm.sh
```

**What this script does:**
- Detects your operating system (Linux, macOS, Windows)
- Downloads the appropriate Helm binary for your architecture
- Installs Helm to `/usr/local/bin/helm` (or appropriate location)
- Makes Helm available in your system PATH

### Step 4: Verify Installation

```bash
# Check Helm version to verify successful installation
helm version

# Check Helm help to see available commands
helm help
```

**Expected output:**
```
version.BuildInfo{Version:"v3.12.3", GitCommit:"3a31588ad33fe3b89af5a2a54ee1d25bfe6eaa5e", GitTreeState:"clean", GoVersion:"go1.20.7"}
```

---

## Method 2: Package Manager Installation

### For Ubuntu/Debian Systems

```bash
# Update package index
sudo apt-get update

# Install prerequisite packages
sudo apt-get install -y apt-transport-https gnupg2 curl

# Add Helm's official GPG key
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

# Add Helm repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Update package index again
sudo apt-get update

# Install Helm
sudo apt-get install helm
```

### For CentOS/RHEL/Fedora Systems

```bash
# Add Helm repository
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

# Install Helm
sudo dnf install helm
```

### For macOS (using Homebrew)

```bash
# Install Helm using Homebrew
brew install helm
```

---

## Method 3: Manual Binary Installation

### Step 1: Download Helm Binary

```bash
# Set Helm version (check latest at https://github.com/helm/helm/releases)
HELM_VERSION="v3.12.3"

# Download Helm for your platform
wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz

# For other platforms, replace linux-amd64 with:
# - darwin-amd64 (macOS Intel)
# - darwin-arm64 (macOS Apple Silicon)
# - windows-amd64.zip (Windows)
```

### Step 2: Extract and Install

```bash
# Extract the downloaded archive
tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz

# Move helm binary to system PATH
sudo mv linux-amd64/helm /usr/local/bin/helm

# Make it executable
sudo chmod +x /usr/local/bin/helm

# Clean up downloaded files
rm -rf linux-amd64/ helm-${HELM_VERSION}-linux-amd64.tar.gz
```

---

## Post-Installation Configuration

### Step 1: Initialize Helm (if needed)

```bash
# Check if Helm can connect to your Kubernetes cluster
helm list

# If this is your first time using Helm, you might want to add some repositories
```

### Step 2: Add Popular Helm Repositories

```bash
# Add the official Helm stable repository
helm repo add stable https://charts.helm.sh/stable

# Add Bitnami repository (popular for applications)
helm repo add bitnami https://charts.bitnami.com/bitnami

# Add ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Add prometheus-community repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update repository index
helm repo update
```

**Explanation:**
- `helm repo add`: Adds a chart repository to your local Helm configuration
- `helm repo update`: Updates the local cache of available charts from all added repositories

### Step 3: Verify Repository Setup

```bash
# List all added repositories
helm repo list

# Search for charts in repositories
helm search repo nginx

# Show all available charts
helm search repo
```

---

## Basic Helm Operations

### Installing a Chart

```bash
# Install a chart (example: nginx)
helm install my-nginx bitnami/nginx

# Install with custom values
helm install my-nginx bitnami/nginx --set service.type=LoadBalancer

# Install from a values file
helm install my-nginx bitnami/nginx -f custom-values.yaml
```

### Managing Releases

```bash
# List all releases
helm list

# List releases in all namespaces
helm list --all-namespaces

# Get release status
helm status my-nginx

# Get release values
helm get values my-nginx
```

### Updating and Rolling Back

```bash
# Upgrade a release
helm upgrade my-nginx bitnami/nginx --set image.tag=1.21

# Rollback to previous version
helm rollback my-nginx 1

# View release history
helm history my-nginx
```

### Uninstalling Releases

```bash
# Uninstall a release
helm uninstall my-nginx

# Uninstall and keep history
helm uninstall my-nginx --keep-history
```

---

## Creating Your Own Charts

### Step 1: Create a New Chart

```bash
# Create a new chart scaffold
helm create my-app

# This creates a directory structure:
# my-app/
#   Chart.yaml          # Chart metadata
#   values.yaml         # Default configuration values
#   templates/          # Template files
#     deployment.yaml
#     service.yaml
#     ingress.yaml
#     ...
```

### Step 2: Customize Your Chart

```bash
# Edit Chart.yaml to update metadata
vim my-app/Chart.yaml

# Edit values.yaml to set default values
vim my-app/values.yaml

# Modify templates as needed
vim my-app/templates/deployment.yaml
```

### Step 3: Validate and Install Your Chart

```bash
# Validate chart syntax
helm lint my-app

# Dry run to see what would be installed
helm install my-app ./my-app --dry-run --debug

# Install your custom chart
helm install my-app ./my-app
```

---

## Troubleshooting Common Issues

### Issue 1: Permission Denied

```bash
# If you get permission denied errors, check cluster permissions
kubectl auth can-i create deployments
kubectl auth can-i create services

# Create a service account with appropriate permissions if needed
```

### Issue 2: Repository Issues

```bash
# If repository commands fail, try updating
helm repo update

# Remove and re-add problematic repositories
helm repo remove stable
helm repo add stable https://charts.helm.sh/stable
```

### Issue 3: Chart Installation Fails

```bash
# Check Kubernetes cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Verify available resources
kubectl top nodes
kubectl describe node <node-name>

# Check Helm release status and logs
helm status <release-name>
kubectl logs -l app=<your-app>
```

### Issue 4: Version Compatibility

```bash
# Check Helm version compatibility with Kubernetes
helm version

# Kubernetes version
kubectl version --short

# Refer to Helm compatibility matrix:
# https://helm.sh/docs/topics/version_skew/
```

---

## Security Best Practices

### 1. Use Specific Chart Versions

```bash
# Always specify chart versions in production
helm install my-app bitnami/nginx --version 13.2.4

# List available versions
helm search repo bitnami/nginx --versions
```

### 2. Review Charts Before Installation

```bash
# Inspect chart contents
helm show chart bitnami/nginx
helm show values bitnami/nginx
helm show readme bitnami/nginx

# Render templates locally to review
helm template my-app bitnami/nginx
```

### 3. Use Values Files for Configuration

```bash
# Create a values file instead of using --set
cat > my-values.yaml <<EOF
replicaCount: 3
service:
  type: LoadBalancer
resources:
  limits:
    cpu: 100m
    memory: 128Mi
EOF

# Install with values file
helm install my-app bitnami/nginx -f my-values.yaml
```

### 4. Namespace Isolation

```bash
# Install releases in specific namespaces
kubectl create namespace production
helm install my-app bitnami/nginx -n production

# Use namespace-specific values
helm install my-app bitnami/nginx -n production -f production-values.yaml
```

---

## Advanced Helm Features

### Helm Hooks

```yaml
# Example pre-install hook in a template
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ include "mychart.fullname" . }}-pre-install"
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
```

### Chart Dependencies

```yaml
# Chart.yaml with dependencies
dependencies:
  - name: mysql
    version: 9.4.1
    repository: https://charts.bitnami.com/bitnami
  - name: redis
    version: 17.3.7
    repository: https://charts.bitnami.com/bitnami
```

```bash
# Update dependencies
helm dependency update
```

### Chart Testing

```bash
# Run chart tests
helm test my-app

# Create test templates in templates/tests/
```

---

## Useful Commands Reference

### Information Commands
```bash
helm version                    # Show Helm version
helm env                       # Show Helm environment
helm list                      # List releases
helm history <release>         # Show release history
helm status <release>          # Show release status
helm get values <release>      # Show release values
helm get manifest <release>    # Show release manifests
```

### Repository Commands
```bash
helm repo add <name> <url>     # Add repository
helm repo list                 # List repositories
helm repo update               # Update repositories
helm repo remove <name>        # Remove repository
helm search repo <keyword>     # Search repositories
```

### Chart Commands
```bash
helm create <name>             # Create new chart
helm lint <chart>              # Validate chart
helm template <name> <chart>   # Render templates
helm package <chart>           # Package chart
helm dependency update         # Update dependencies
```

### Release Commands
```bash
helm install <name> <chart>    # Install release
helm upgrade <name> <chart>    # Upgrade release
helm rollback <name> <revision> # Rollback release
helm uninstall <name>          # Uninstall release
helm test <name>               # Test release
```

---

## Integration with CI/CD

### Example GitLab CI Pipeline

```yaml
deploy:
  stage: deploy
  script:
    - helm upgrade --install myapp ./charts/myapp 
      --set image.tag=$CI_COMMIT_SHA 
      --namespace production
  only:
    - main
```

### Example GitHub Actions

```yaml
- name: Deploy with Helm
  run: |
    helm upgrade --install myapp ./charts/myapp \
      --set image.tag=${{ github.sha }} \
      --namespace production
```

---

## Summary

This guide covered:
1. **Multiple installation methods** for different environments
2. **Basic Helm operations** for managing applications
3. **Repository management** for accessing charts
4. **Chart creation** for custom applications
5. **Security best practices** for production use
6. **Troubleshooting** common issues
7. **Advanced features** like hooks and dependencies

Helm is now ready to use for managing your Kubernetes applications efficiently!



