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


