
# What are Taints and Tolerations?
- **Taints:** These are like "badges" you put on a node (a server) to say, "Only certain pods (applications) can run here."
- **Tolerations:** These are like "passes" that you give to pods to say, "I can go on nodes with these badges."


## How to Use Them
**1- Add a Taint to a Node:**
You tell Kubernetes to mark a node with a taint. For example, if you want to mark a node named node1, you can run this command:
```bash
$ kubectl taint nodes node1 key1=value1:NoSchedule
```
This means that no pods can be scheduled on node1 unless they have a matching toleration.

**2- Add a Toleration to a Pod:**
When you create a pod, you can give it a toleration so it can be scheduled on nodes with specific taints. Here’s a simple example of a pod definition:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  tolerations:
  - key: "key`"
    operator: "Equal"
    value: "value1"
    effect: "NoSchedule"
  containers:
  - name: my-container
    image: my-image
```
This pod can now be scheduled on node1 because it has the right toleration.

**3- Check Taints and Tolerations:** 
To see what taints are on a node, use:
```bash
kubectl describe node node1
k describe nodes master | grep Taint
```
***To see the tolerations on a pod, use:***
```bash
kubectl describe pod my-pod
```

## Why Use Taints and Tolerations?

- **Control Scheduling**: You can control which pods run on which nodes. 
For example, you might want to keep heavy workloads off of smaller nodes.

- **Resource Management**: It helps manage resources better by ensuring that only suitable pods run on certain nodes.
That’s it! Taints and tolerations help you manage where your applications run in your Kubernetes cluster.


# Taint Effects
- When you apply a taint to a node, you specify an effect, which tells Kubernetes how to treat pods that do not have matching tolerations. Here are the three main effects:

**1-NoSchedule:**
What it means: Pods without a matching toleration cannot be scheduled on this node.
Example: If you taint a node with key=value:NoSchedule, any pod that doesn’t have a toleration for that key/value will not be allowed to run on that node.
- ***Example:***
 If you taint a node with key=value:NoSchedule, any pod that doesn’t have a toleration for that key/value will not be allowed to run on that node.

**2-PreferNoSchedule:**
What it means: Kubernetes will try to avoid scheduling pods without a matching toleration on this node, but it may still schedule them there if no other options are available.
- ***Example:***
 If you taint a node with key=value:PreferNoSchedule, Kubernetes will prefer to place other pods elsewhere, but if there are no suitable nodes, it might still place some pods on this tainted node.

**3-NoExecute:**
What it means: Pods that are already running on the node and do not have a matching toleration will be evicted (kicked out) from that node.
- ***Example:***
 If you taint a node with key=value:NoExecute, any existing pods without a toleration for that taint will be removed from that node. New pods without tolerations won’t be scheduled there either. 
**4-Effect:**
 What it means: This is the default effect if you don’t specify one. It’s equivalent to NoSchedule.
- ***Example:***
 If you taint a node with key=value:Effect, it’s the same as tainting it with key=value:NoSchedule.


# Some commands that helpful with working with taints and tolerations:
```bash
kubectl taint node node1 key=value:NoSchedule # - adds a taint to
kubectl taint node node1 key=value:NoSchedule- # - removes a taint
kubectl describe node node1 # - shows the taints on a node
kubectl describe pod my-pod # - shows the tolerations on a pod
```

***2. Remove a Taint from a Node***
To remove a taint from a node, append a - to the taint key:
```bash
kubectl taint nodes <node-name> <key>:<effect>-
```
Example:
```bash
kubectl taint nodes node1 key1:NoSchedule-
```
***View All Nodes and Their Taints:***
To view all nodes and their taints in a concise format, use
```bash
kubectl get nodes -o jsonpath='{.items[*].spec.taints}'
```
