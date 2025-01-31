# Project steps to installation on aws 


### 1. Create AWs user with  permissions (EBS, EFS) in Kubeadm Cluster:

- create three ec2 instances from the cluster:
     - create one instance for master and two for workers:
     - install kubeadm cluster on them
create user with permissions ("AmazonEBSCSIDriverPolicy", "AmazonElasticFileSystemFullAccess")

### 2. Create access key for user 


### Create a Police named "efs-dolfined" 
---
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeMountTargets",
                "ec2:DescribeAvailabilityZones"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:CreateAccessPoint"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/efs.csi.aws.com/cluster": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:TagResource"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "elasticfilesystem:DeleteAccessPoint",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
                }
            }
        }
    ]
}
---
```

### 3. create role and Add permissions (EBS, EFS):
create role and Add permissions "AmazonEBSCSIDriverPolicy"
 and ... `"efs-dolfined"` police 
 

#### 3. Check for CSIDriver:
This command will list all the CSI drivers installed in your cluster.

```bash
k get csidriver
```

#### Check if the CSIDriver is installed on each node : 
```bash
kubectl get csinode
```

#### 4. Create a Secret named "dolfined-project":
```bash
kubectl create secret generic dolfined-project \
     --namespace kube-system \
     --from-literal "key_id=AK************" \
     --from-literal "access_key=ie**********"
```


# Let's Create Mysql FIles:

- encrypt the secret using  openssl and base64:
```bash
 echo -n 'myrootpassword' | openssl base64
```
##### create a yaml file for secret:
```bash
vim secret.yaml
```
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-pass
type: Opaque
data:
  password: bXlzcWwtcGFzc3dvcmQ=
```
```bash
kubectl apply -f secret.yaml
kubectl get secret
```
#### create yaml file for a SC:
```bash
 vim mysql-sc.yaml
```
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: mysql-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
---
```
#### Create yaml file Pvc:
```bash
vim mysql-pvc.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: mysql-sc
  resources:
    requests:
      storage: 5Gi
```
- apply the file and check the volume:
```bash
kubectl apply -f mysql-pvc.yaml
kubectl get pvc
kubectl get pv
```

##### Create yaml file for Deployment:
```bash
vim mysql-app.yaml
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-app
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: mysql
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
---
```
- Apply and check the pod:
```bash
kubectl apply -f mysql-app.yaml
kubectl get deployments
kubectl get pods
```

### Now you can open AWS and check EBS volume:: 

##### Create SVC For sql:
```bash
vim mysql-svc.yaml
```
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-svc
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
---
```
-  apply and check svc:
```bash
kubectl apply -f mysql-svc.yaml
kubectl get svc
```

# Let's Create WordPress App files: 
## go to AWS EFS and create these steps:
1. Creste filesystem for "wordpress"
2. create "access point" Select your file system ID  for "wordpress" file system
3. Enter this values:
Root directory path: /wordpress

Posix User ID: 1000

Posix Group ID: 1000

Root Owner user ID: 1000

Root group ID: 1000

POSIX permissions: 777

Select Create access point

4. change security group for filesystem

- create Sc yaml file:
```bash
vim wordpress-sc.yaml
```
```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
```
- apply and check:
```bash
kubectl apply -f wordpress-sc.yaml
kubectl get sc
```
- create PV:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: wordpress-efs-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: efs-sc
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-079c8df4fe1f84069::fsap-039e81d78cbb409da
---
```
- apply and check:
```bash
kubectl apply -f wordpress-pv.yaml
kubectl get pv
```
- create PVC:
```bash
vim wordpress-pvc.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wordpress-efs-pvc
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
---
```
- apply and check:
```bash
kubectl apply -f wordpress-pvc.yaml
kubectl get pvc
```
- create deployment:
```bash
vim wordpress-app.yaml
```
```yaml
apiVersion: apps/v1 
kind: Deployment
metadata:
  name: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: frontend
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
      - image: wordpress:php7.1-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql-svc
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-storage
        persistentVolumeClaim:
          claimName: wordpress-efs-pvc
---
```
- apply and check :
```bash
kubectl apply -f wordpress-app.yaml
kubectl get deployments
kubectl get pods
```
- Scale the deployment to the specified number of replicas=2:
```bash
 kubectl scale deploy wordpress --replicas=2
 ```


- Create a svc for wordpress:
```bash
vim wordpress-svc.yaml
 ```
```yaml
         apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: LoadBalancer
---
```
- apply and check : 
```bash
kubectl apply -f wordpress-svc.yaml
kubectl get svc
```


>>> try to access wordpress app <Node-ip>:<svc-port>


