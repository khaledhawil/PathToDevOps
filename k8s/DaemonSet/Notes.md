# DaemonSet 
    A DaemonSet in Kubernetes (k8s) is a type of workload that ensures a copy of a specific pod runs on all (or a subset of) nodes in the cluster. 
    This is useful for running background tasks or services that need to be present on every node, such as logging agents, monitoring tools, or network proxies. 
 
### Key Points about DaemonSets: 
- **Purpose**: 
 DaemonSets are typically used for applications that need to run on every node or a specific group of nodes.
- **Automatic Management**: 
 When you add a new node to the cluster, the DaemonSet automatically schedules a pod on that new node. 
 If you remove a node, the pod for that node is also removed.

- **Selective Deployment:** 
 You can use node selectors, affinity, and tolerations to control which nodes the DaemonSet pods will run on.


### How to Create a DaemonSet:
Here's a simple example of how to create a DaemonSet using YAML:
```yaml 
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: my-daemonset
  namespace: default
spec:
  selector:
    matchLabels:
      name: my-daemon
  template:
    metadata:
      labels:
        name: my-daemon
    spec:
      containers:
      - name: my-container
        image: my-image:latest
```

- Steps to Apply the DaemonSet:

```bash
kubectl apply -f daemonset.yaml
kubectl get daemonsets
kubectl get pods -l name=my-daemon
```