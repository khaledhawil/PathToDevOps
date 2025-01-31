# Static Example To create pv and pvc and connect to AWS EBS volume:

#############################################################################
################### Demo - Static Provisioning With EBS  ###################
#############################################################################


#### 1. Created an Amazon EBS volume --->  it must in the same availability zone with ec2
- Open Aws Console  create EBC volume 
- Copy EBC volume ID 


- Create PV.yaml file to Create Pv and Connect to Amazon EBS:
PV.yaml
```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: dolfined-pv
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 5Gi
  csi:
    driver: ebs.csi.aws.com
    fsType: ext4
    volumeHandle: vol-0d1bd6d3c8b7cee6b
---
```
- Create Pvc.yaml file After creating the Pv:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dolfined-pvc
spec:
  storageClassName: "" # Empty string must be explicitly set otherwise default StorageClass will be set
  volumeName: dolfined-pv
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```
- Checks if if pvc created successfully: 
```bash
kubectl get pvc
```
- Create Pod and Connect it with PVc: 
pod.yaml
```yaml 
apiVersion: v1
kind: Pod
metadata:
  name: dolfined-app1
spec:
  nodeName: node1
  containers:
  - name: app
    image: centos
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo $(date -u) >> /data/out.txt; sleep 5; done"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: my-pvc
```
- Checks if pod created successfully and Describe it:
```bash
kubectl get po -o wide
kubectl describe pod dolfined-app
```
- oped the Pod and Create files in /data Dir with the following command: 
```bash
kubectl exec -it dolfined-app -- /bin/bash
cd data/
touch file1.txt
touch file2.txt
echo "Hello World" > file1.txt
echo "Hello Kubernetes" > file2.txt
```
## Important Note:
- if U use EBS driver WRO and if you run two pods in deferent nodes they won't running one of them can be running
- if U want to run them together U should be running them on the same node .
- Create Another Pod in another node  and Attach it to the same Pvc to ensure that using the same Filesystem:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dolfined-app2
spec:
  nodeName: node2
  containers:
  - name: app
    image: centos
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo $(date -u) >> /data/out.txt; sleep 5; done"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: my-pvc
```
- **# the new pod created in "node2" but the first it created in "node1"**

- Open the Second Pod to check  that the Two Pods are using the same storage:
```bash
kubectl exec -it dolfined-app1 -- /bin/bash
cd data/
 ls
```
### you will find the same files

# Clean up 
- Delete  Pvc and pv after  deleting the pods:
```bash
kubectl delete po dolfined-app
kubectl delete po dolfined-app2
kubectl delete pvc dolfined-pvc
kubectl delete pv dolfined-pv 
```
- Delete the aws volume
```bash
aws ec2 delete-volume --volume-id <volume-id> 
```
###### Thanks to using my exercise:
- ***Khaled Hawil***