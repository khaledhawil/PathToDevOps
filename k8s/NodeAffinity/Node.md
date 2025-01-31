# What is Node Affinity?
- Node affinity is similar to node selectors but provides more flexibility.
- It allows you to specify rules about which nodes a pod can be scheduled on based on
labels. 
- You can think of it as a way to express preferences or requirements for certain nodes.
- It can be used to ensure that pods are scheduled on nodes with specific characteristics.
- Node affinity is a more flexible and powerful way to manage pod placement than node selectors.

# Types of Node Affinity
- There are two types of node affinity:
- **RequiredDuringSchedulingIgnoredDuringExecution:**
    - ***What it means:*** 
The pod must be scheduled on a node that meets the specified criteria. If no suitable nodes are available, the pod will not be scheduled.
    - ***Example:*** 
If you require a pod to run only on nodes labeled with disktype=ssd, it will only be scheduled on those nodes.



- **PreferredDuringSchedulingIgnoredDuringExecution:**
    - ***What it means:*** 
The pod prefers to be scheduled on nodes that meet the specified criteria, but it can still be scheduled on other nodes if necessary.
    - ***Example:*** 
If you prefer to run a pod on nodes labeled with zone=us-west, it will be scheduled there if possible, but it can still run on other nodes if no suitable ones are available.

# How to Use Node Affinity
Here’s a simple example of how to use node affinity in a pod specification.

1- ***Label Your Nodes:***
 First, you need to label the nodes you want to use. For example, you could label a node with disktype=ssd:
 ```bash
kubectl label nodes <node-name> disktype=ssd
```
2- ***Create a Pod with Node Affinity:***
 Here’s an example YAML configuration for a pod that uses node affinity:
 ```yaml
apiVersion: v1
   kind: Pod
   metadata:
     name: my-pod
   spec:
     affinity:
       nodeAffinity:
         requiredDuringSchedulingIgnoredDuringExecution:
           nodeSelectorTerms:
           - matchExpressions:
             - key: disktype
               operator: In
               values:
               - ssd
     containers:
     - name: my-container
       image: my-image
   ```
### Explanation of the Example:
- **affinity:** 
 This section defines the affinity rules.
- **nodeAffinity:**  
 This specifies that you are using node affinity.
- **requiredDuringSchedulingIgnoredDuringExecution:** 
 This indicates that the pod must be scheduled on a node with the specified criteria.
- **nodeSelectorTerms:**
 This defines the criteria for selecting nodes.
- **matchExpressions:**
 This specifies the key (disktype), the operator (In), and the values (ssd) that the node must match.


## Example of Preferred Node Affinity
 If you want to use preferred node affinity instead, you can modify the YAML like this:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values:
            - us-west
  containers:
  - name: my-container
    image: my-image
```
### Explanation of the Preferred Example:
- **preferredDuringSchedulingIgnoredDuringExecution:**
 This indicates that the pod prefers to be scheduled on nodes matching the criteria but can still be scheduled elsewhere.
- **weight:**
 A value that indicates how important this preference is when scheduling (higher values are more preferred).
- **preference:**
 Similar to required, but it indicates a preference rather than a strict requiremen

 #### Always check node labels using
 ```bash
 kubectl get nodes --show-labels
 ```










docker images names:
polinux/stress

