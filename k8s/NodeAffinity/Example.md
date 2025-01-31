# Scenario
### Imagine you have a Kubernetes cluster with two types of nodes:
- Some nodes have SSD storage (labeled as disktype=ssd).
- Some nodes have HDD storage (labeled as disktype=hdd).
- You want to ensure that a specific application pod runs only on nodes with SSD storage.

- ## Step 1: Label Your Nodes
First, you need to label your nodes. Here’s how you can do it:
    - 1.Label a node with SSD storage:
```bash
kubectl label nodes <ssd-node-name> disktype=ssd
```
    - 2.Label a node with HDD storage:
```bash
kubectl label nodes <hdd-node-name> disktype=hdd
```
- ## Step 2: Create a Pod with Node Affinity
Now, create a YAML file for your pod that specifies node affinity. Here’s an example:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-ssd-pod
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
  - name: webserver
    image: nginx
```
### Explanation of the YAML:
- affinity: This section defines the affinity rules.
- nodeAffinity: Specifies that you are using node affinity.
- requiredDuringSchedulingIgnoredDuringExecution: This means the pod must be scheduled on a node matching the criteria.
- nodeSelectorTerms: Defines the criteria for selecting nodes.
- matchExpressions: Specifies that the pod should only run on nodes with the label disktype=ssd.
- values: Specifies the value of the label that the node must have.


- ## Step 3: Deploy the Pod
Save the above YAML to a file named my-ssd-pod.yaml, and then apply it to your cluster:
```bash
kubectl apply -f my-ssd-pod.yaml
```
- ## Step 4: Verify the Pod Scheduling
You can check if the pod is running on the correct node by using:
```bash
kubectl get pods -o wide
```
This command will show you which node the pod is scheduled on. You should see that my-ssd-pod is running on a node with the label disktype=ssd.
- ## Step 5: Clean Up
When you are done with the pod, you can delete it with:
```bash
kubectl delete pod my-ssd-pod
```