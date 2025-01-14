In Kubernetes, **ClusterRole** and **ClusterRoleBinding** are critical components of the Role-Based Access Control (RBAC) system. They are used to manage permissions at the cluster level, allowing you to define what actions users or service accounts can perform across the entire cluster. 
### ClusterRole
- Definition: A ClusterRole is a set of permissions that can be applied cluster-wide. It defines what actions (verbs) can be performed on specific resources or resource types.

- Usage:
    -  Can be used to grant permissions to users, groups, or service accounts across all namespaces in a Kubernetes cluster.
    -  Can also be used to define permissions for specific resources in a specific namespace.

- Example: A ClusterRole might allow a user to get, list, and watch all pods and deployments across all namespaces.


### ClusterRoleBinding
- Definition: A ClusterRoleBinding binds a ClusterRole to one or more subjects (users, groups, or service accounts). 
- This effectively grants the permissions defined in the ClusterRole to the specified subjects.

- Usage:
    - Allows you to associate a ClusterRole with a user or service account, enabling them to perform the actions defined in the ClusterRole.
    - Can reference multiple subjects, allowing you to grant the same permissions to multiple users or service accounts.

- Example: A ClusterRoleBinding might bind the cluster-admin ClusterRole to a specific user, giving that user full administrative access to the cluster.
## Imperative way :
```bash
kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods
```

## Example YAML Definitions
Here are simple examples of a ClusterRole and a ClusterRoleBinding:
ClusterRole Example.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

## ClusterRoleBinding Example

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-pods-binding
subjects:
- kind: User
  name: alice  # Specify the user or service account
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
## Imperative way :
```bash
kubectl create clusterrolebinding read-pods-binding --clusterrole=pod-reader --user=alice
```
