# Will add an Example of Storage Class with EBS Storage :

#############################################################################
################### Demo - Dynamic Provisioning With EBS  ###################
#############################################################################



- We will create a Storage Class and Pvc  After That  

- Create storage.yaml file 
```yaml
apiVersion: storage.k8s.io/v1  # Specifies the API version for the StorageClass resource.
kind: StorageClass              # Indicates that this resource is a StorageClass.
metadata:                       # Metadata section for the StorageClass.
  name: my-sc                   # The name of the StorageClass, which can be referenced by PVCs.
provisioner: ebs.csi.aws.com    # Specifies the provisioner to use; in this case, it is the AWS EBS CSI driver.
volumeBindingMode: WaitForFirstConsumer  # Indicates that volume binding will wait until a Pod that uses this PVC is scheduled.
---
apiVersion: v1                  # Specifies the API version for the PersistentVolumeClaim resource.
kind: PersistentVolumeClaim      # Indicates that this resource is a PersistentVolumeClaim.
metadata:                       # Metadata section for the PVC.
  name: my-pvc                   # The name of the PersistentVolumeClaim.
spec:                           # Specification section for the PVC.
  accessModes:                   # Access modes for the PVC.
    - ReadWriteOnce              # Indicates that the volume can be mounted as read-write by a single node.
  resources:                     # Resource requests for the PVC.
    requests:                   # Requests section for storage resources.
      storage: 4Gi              # The amount of storage requested (4 GiB in this case).
  storageClassName: my-sc        # References the StorageClass to use for provisioning the volume.
---
apiVersion: v1                  # Specifies the API version for the Pod resource.
kind: Pod                        # Indicates that this resource is a Pod.
metadata:                       # Metadata section for the Pod.
  name: my-pod                   # The name of the Pod.
spec:                           # Specification section for the Pod.
  containers:                   # List of containers that will run in the Pod.
  - name: app                    # The name of the container.
    image: centos                # Specifies the container image to use (CentOS in this case).
    command: ["/bin/sh"]         # Command to run when starting the container.
    args: ["-c", "while true; do echo $(date) >> /data/out.txt; sleep 5; done"]  # Arguments for the command; appends the current date to out.txt every 5 seconds.
    volumeMounts:               # List of volume mounts for the container.
    - name: my-volume            # The name of the volume to mount.
      mountPath: /data          # The path inside the container where the volume will be mounted.
  volumes:                      # List of volumes that the Pod can use.
    - name: my-volume            # The name of the volume.
      persistentVolumeClaim:      # Indicates that this volume is backed by a PersistentVolumeClaim.
        claimName: my-pvc        # The name of the PVC to use for this volume.
```
- Apply the configuration to the cluster using the following command:
```bash
kubectl apply -f storage.yaml
```

- Verify that the StorageClass and PVC have been created:
```bash
kubectl get sc
kubectl get pvc
```

- Now Will see the PV Has been created after the Pod has been created
```bash
kubectl get pv
```
