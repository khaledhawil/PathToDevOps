# Anything that helps with k8s cluster configuration
**to Show how many clusters**
```bash
    $ kubectl config get-contexts 
```
**to switch to a cluster**
```bash
$ kubectl config use-context <cluster_name>
```
**to delete a cluster**
```bash
$ kubectl delete cluster <cluster_name>
```
**to delete a node**
```bash
$ kubectl delete node <node_name>
```

- **To drain the pods from specific nodes**  # 
```bash
$ kubectl drain <node_name> --force --delete-local-data --ignore-daemonsets
$  kubectl drain node01 --ignore-daemonsets  # this will remove the pods from the node1 and put them in another node 
kubectl uncordon node01 # the node node01 to be schedulable again.
```
