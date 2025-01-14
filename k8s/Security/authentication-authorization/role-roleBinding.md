#################################################################
################### Demo - Role and RoleBinding #################
#################################################################

### to check if the user is allowed to access any resources:
```bash
kubectl config get-contexts
kubectl auth can-i list pods --as khaled
output:
no
```
### to check if the user is allowed to access a specific resource:
```bash
kubectl auth can-i <verb> <resource> --as=<user>
kubectl auth can-i list     pods        --as khaled --namespace default
```
# To create or delete role in imperative way :
```bash
 kubectl create role khaled-role --verb=list,create --resource=pod
 kubectl get role
 kubectl delete role khaled-role
```

### to create role in declarative way:
role.yaml:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: khaled-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "watch", "list"]
```

### To create RoleBinding in imperative way:
```bash
kubectl create rolebinding khaled-rb --role=khaled-role --user=khaled
 kubectl get rolebinding
  kubectl delete rolebinding khaled-rb
```
### To create RoleBinding in declarative way:

rb.yaml:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: khaled-rb
  namespace: default
subjects:
- kind: User
  name: khaled
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role 
  name: khaled-role
  apiGroup: rbac.authorization.k8s.io
```


### After you attach the  rolebinding to the user and the user can perform the action:
check:
```bash
kubectl get po --context=khaled 
k auth can-i  list pod --as khaled 
```

### Check on the resource you don't attach  it to the user:
```bash
kubectl get deploy --context=khaled
```
#### Now attach any  resources  to the user in role file:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: khaled-role
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods,services"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "watch", "list"]
```
#### check:
```bash
kubectl auth can-i list deployment --as khaled 
yes
kubectl auth can-i create  deployment --as khaled
no
```
## To switch the user U've created : 
```bash
kubectl config current-context
kubectl config use-context khaled
```
## To switch back to the default user:
```bash
kubectl config use-context defaultName
```




