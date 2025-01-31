Working with AWS Elastic Block Store (EBS) in Kubernetes using Storage Classes involves several steps. Below is a guide to help you set up and use AWS EBS volumes in a Kubernetes cluster. 
 
 ## to work with aws ebs You should use the following steps:
#################################################################
################### Demo - Install CSI Driver ###################
#################################################################

##  **Create User**:
- Attach Permissions "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"

- create access key

- create role and Add permissions "AmazonEBSCSIDriverPolicy"

- Add "IAM role" for each EC2  machines
 Instal CSI driver:
 ```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.14" 
```
- Show the installed pods in kube-system namespace:
```bash
kubectl get pods -n kube-system
```
- show the CSI Deriver:
```bash
 kubectl get csidriver
 kubectl get csinode
 ```

- Create sceret with credentials user AWS:
```bash
kubectl create secret generic aws-secret \
    --namespace kube-system \
    --from-literal "key_id=AKI**************" \
    --from-literal "access_key=uB************************"
```

---
ubuntu@master:~$ 
```bash
kubectl describe secret aws-secret -n kube-system
```



### Prerequisites 
 
1. **Kubernetes Cluster**: You should have a Kubernetes cluster running on AWS (EKS is recommended but any Kubernetes setup on AWS will work). 
2. **kubectl**: Ensure you have `kubectl` configured to interact with your Kubernetes cluster. 
3. **IAM Permissions**: Ensure that your Kubernetes nodes have the necessary IAM permissions to create and manage EBS volumes. 
 
### Steps to Work with AWS EBS and Storage Classes 
 
#### 1. Create a Storage Class 
 
You need to define a Storage Class that specifies the use of AWS EBS. Here’s an example YAML file for a Storage Class that provisions `gp2` type EBS volumes:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-storage-class
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  fsType: ext4
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```


- **type**: Specifies the type of EBS volume (e.g., `gp2`, `io1`, etc.). 
- **fsType**: The filesystem type to format the volume with. 
- **reclaimPolicy**: What happens to the volume when the PVC is deleted (e.g., `Delete` means the volume will be deleted). 
- **volumeBindingMode**: `WaitForFirstConsumer` means the volume will be created when a Pod that uses it is scheduled. 
 
#### 2. Apply the Storage Class 
 
Use the following command to create the Storage Class in your Kubernetes cluster:
kubectl apply -f storage-class.yaml
#### 3. Create a Persistent Volume Claim (PVC) 
 
Next, create a PVC that uses the Storage Class you just created. Here’s an example YAML file for a PVC:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: gp2-storage-class
```

