# Pv and PVC

In Kubernetes (k8s), PV and PVC are important concepts related to storage.
## Persistent Volume (PV) 
- What it is: A Persistent Volume (PV) is a piece of storage in the Kubernetes cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.

- How it works: Think of it as a physical disk or storage space that is available for use by applications running in the cluster. It can be backed by various storage systems (like NFS, AWS EBS, etc.).

- Lifecycle: PVs exist independently of the pods that use them. They can be reused by different pods as needed.

## PVC (Persistent Volume Claim)

- What it is: A Persistent Volume Claim (PVC) is a request for storage by a user or application.
- How it works: When an application needs storage, it creates a PVC, specifying the amount of storage it needs and the access modes (like read/write).

- Binding: Kubernetes will then match the PVC with a suitable PV that meets the requirements. Once bound, the PVC can be used by pods to access the storage.


# --------------------------------------------------------------------------------------------------------------------------


## Understanding PV and PVC
- **Persistent Volume (PV)**
- Definition: A PV is a piece of storage in your Kubernetes cluster that has been provisioned either manually by an administrator or automatically by the Kubernetes system.

### Characteristics:
- Capacity: The size of the storage.
- Access Modes: How the storage can be accessed (e.g., ReadWriteOnce, ReadOnlyMany).
- Reclaim Policy: What happens to the PV when it is released from its claim (e.g., Retain, Recycle, Delete).
- Storage Class: Defines the type of storage (e.g., SSD, HDD)

## Create a Persistent Volume (PV)
You need to define a PV in a YAML file. Here’s an example:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
``` 
### Explanation:
- capacity: This PV can hold 10 GiB of data.
- accessModes: It can be mounted as read/write by a single node.
- hostPath: This is a local path on the node (for testing purposes).



## Persistent Volume Claim (PVC)
- Definition: A PVC is a request for storage by a user or application. It specifies the desired size and access modes.
- Characteristics:
- Size: How much storage is requested.
- Access Modes: Similar to PV, it specifies how the storage can be accessed.

Next, create a PVC that requests storage. Here’s an example:
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
```

### Explanation:
This PVC requests 5 GiB of storage with read/write access.


###  Check the Status of Them

```bash 
kubectl get pv
kubectl get pvc
```

## Use PVC in a Pod

- To use a PVC in a pod, you need to reference the PVC in the pod’s configuration
- Here’s an example of a pod that uses a PVC:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: my-storage
  volumes:
    - name: my-storage
      persistentVolumeClaim:
        claimName: my-pvc
```

# Access Mode types for PV:
### 1. ReadWriteOnce (RWO) 
- **Description**: The volume can be mounted as read-write by a single node. 
- **Use Case**: This is suitable for workloads that require exclusive write access, such as databases. Only one pod can write to the volume at a time. 
- **Types that works for RWO**: hostpath 
### 2. ReadOnlyMany (ROX) 
- **Description**: The volume can be mounted as read-only by many nodes. 
- **Use Case**: This mode is useful for scenarios where multiple pods need to read the same data without modifying it, such as serving static content or configuration files.  
 
### 3. ReadWriteMany (RWX) 
- **Description**: The volume can be mounted as read-write by many nodes. 
- **Use Case**: This access mode is ideal for applications that need shared write access, such as clustered file systems or applications that require concurrent write capabilities. Not all storage backends support this mode. 
 
### Summary of Access Modes 
----------------------------------------------------------------------------------------------------
| Access Mode   | Description                                   | Mountable by Nodes               | 
|---------------|-----------------------------------------------|----------------------------------| 
| **ReadWriteOnce (RWO)** | Read-write by a single node         | 1                                | 
| **ReadOnlyMany (ROX)**  | Read-only by many nodes             | Many                             | 
| **ReadWriteMany (RWX)** | Read-write by many nodes            | Many                             |----------------------------------------------------------------------------------------------------

