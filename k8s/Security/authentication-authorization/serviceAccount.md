
##  ############################################################
##  ################### Demo - Service Account #################
##  ############################################################


#### create a new service account:
sa.yaml
```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dolfined-sa
  namespace: default
---
```
```bash
ubuntu@master:~$ kubectl apply -f sa.yaml
serviceaccount/dolfined-sa created
 
ubuntu@master:~$ kubectl get sa
NAME          SECRETS   AGE
default       1         46d
dolfined-sa   1         5s


ubuntu@master:~$ kubectl describe sa dolfined-sa
Name:                dolfined-sa
Namespace:           default
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   dolfined-sa-token-tr8rd
Tokens:              dolfined-sa-token-tr8rd
Events:              <none>
```
#### Create Role for SA
role.yaml
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: dolfined-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "get", "watch", "list"]
---
```
### Apply it 
```bash
ubuntu@master:~$ kubectl apply -f role.yaml
role.rbac.authorization.k8s.io/dolfined-role created

ubuntu@master:~$ kubectl get role
NAME            CREATED AT
dolfined-role   2023-03-20T12:52:41Z

```

#### Create RoleBinding for SA:
rb.yaml
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dolfined-rb
  namespace: default
subjects:
- kind: ServiceAccount
  name: dolfined-sa
  namespace: default
roleRef:
  kind: Role
  name: dolfined-role
  apiGroup: rbac.authorization.k8s.io
---
```
### Apply it
```bash
ubuntu@master:~$ kubectl apply -f rb.yaml
rolebinding.rbac.authorization.k8s.io/dolfined-rb created

ubuntu@master:~$ kubectl get rolebinding
NAME          ROLE                 AGE
dolfined-rb   Role/dolfined-role   10s

ubuntu@master:~$ kubectl describe rolebinding dolfined-rb
Name:         dolfined-rb
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  dolfined-role
Subjects:
  Kind            Name         Namespace
  ----            ----         ---------
  ServiceAccount  dolfined-sa  default
```

#### Create a Pod Using Service Account 

Pod.yaml
```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: dolfined-app
spec:
  containers:
  - name: nginx
    image: nginx
  serviceAccountName: dolfined-sa
---
```

### Apply it
```bash
ubuntu@master:~$ kubectl get po -o yaml
  spec:
    serviceAccountName: dolfined-sa
---
```


### Check out if the service account can do the actions required:
```bash
ubuntu@master:~$ kubectl auth can-i get pods  --as system:serviceaccount:default:dolfined-sa
yes

ubuntu@master:~$ kubectl auth can-i create pods  --as system:serviceaccount:default:dolfined-sa
yes

ubuntu@master:~$ kubectl auth can-i create deploy  --as system:serviceaccount:default:dolfined-sa
no

ubuntu@master:~$ kubectl auth can-i get deployment  --as system:serviceaccount:default:dolfined-sa
no
```