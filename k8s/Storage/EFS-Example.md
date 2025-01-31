
Certainly! Here’s a straightforward guide to using Amazon Elastic File System (EFS) with a Storage Class in Kubernetes. 
 
### What is Amazon EFS? 
 
Amazon Elastic File System (EFS) is a scalable file storage service that can be used with AWS services. It allows multiple instances (or Pods in Kubernetes) to access the same file system simultaneously, making it suitable for scenarios where you need shared access. 
 
### Steps to Use EFS with Kubernetes 
 
#### 1. Create an EFS File System 
 
1. **Log in to the AWS Management Console**. 
2. Go to the **EFS** service. 
3. Click on **Create file system**. 
4. Follow the prompts to set up your EFS file system. Make sure to note the File System ID. 
 
#### 2. Install the EFS CSI Driver 
 
To use EFS with Kubernetes, you need to install the EFS Container Storage Interface (CSI) driver. You can do this using the following command:
```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/ecr/cluster.yaml"
```
- this command will deploy the EFS CSi driver in Your cluster.
### 3. Create a Storage Class for EFS
Next, you need to create a Storage Class that uses the EFS CSI driver. Here’s an example YAML file for the Storage Class:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com  # Specifies the EFS CSI driver
volumeBindingMode: Immediate   # Volumes are bound immediately when a PVC is created
```
- Apply the Storage Class with:
```bash
kubectl apply -f efs-storage-class.yaml
```
### 4. Create a Persistent Volume Claim (PVC)
Finally, create a Persistent Volume Claim that requests storage from the Storage Class you created earlier. Here’s
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-pvc
spec:
  accessModes:
    - ReadWriteMany  # Allows multiple Pods to read and write
  resources:
    requests:
      storage: 5Gi
  storageClassName: efs-sc  # Reference the Storage Class
```
- Apply the Persistent Volume Claim with:
```bash
kubectl apply -f efs-pvc.yaml
```
### 6. Create a Deployment with 3 replicas and use the Persistent Volume Claim 



## Prerequest:
- aws CLI

1. Create a user with permission "AmazonElasticFileSystemFullAccess"

2. Create a policy and role:


3. add IAM role "efs-role" to all instances:


4. Intsall EFS driver:
```bash
$ kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.5"
$ kubectl get po -n kube-system
$ kubectl get csidriver
kubectl get csinode

```
5. Create sceret with credentials user AWS:
kubectl create secret generic efs \
    --namespace kube-system \
    --from-literal "key_id=A*************" \
    --from-literal "access_key=L*****************"
