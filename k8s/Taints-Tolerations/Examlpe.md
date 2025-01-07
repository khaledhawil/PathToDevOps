# Scenario
Imagine you have a node that has a special GPU for machine learning tasks, and you want to ensure that only the pods that need GPU resources can run on this node. You can achieve this by using taints and tolerations.

## Step 1: Taint the Node:
First, you’ll taint the node that has the GPU. Let’s say the node is named node1. You can apply a taint with the key gpu, value env, and effect NoSchedule:
```bash
kubectl taint nodes node1 gpu=env:NoSchedule
```
### Explanation:
- Key: gpu
- Value: env
- Effect: NoSchedule (no new pods without a matching toleration can be scheduled on this node)
## Step 2: Create a Pod with a Toleration
Next, you need to create a pod that can tolerate this taint. Here’s an example YAML file for a pod that runs a machine learning application and includes a toleration for the GPU taint:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ml-pod
spec:
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "env"
    effect: "NoSchedule"
  containers:
  - name: ml-container
    image: my-ml-image
```
### Explanation:
The tolerations section allows this pod to be scheduled on the node1 , despite the taint.
The pod will be able to run on nodes with the gpu=env:NoSchedule taint.

## Step 3: Deploy the Pod
Save the above YAML to a file named ml-pod.yaml, and then apply it to your cluster:
```bash
kubectl apply -f ml-pod.yaml
```
## Step 4: Verify the Pod Scheduling
You can check if the pod is running on the node1 :
```bash
kubectl get pods -o wide
```
## Step 5: Test the Taint Effect
To see how the taint works, try creating another pod that does not have a toleration for the GPU taint. Here’s an example YAML for a regular pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: regular-pod
spec:
  containers:
  - name: regular-container
    image: nginx
```
Save it as regular-pod.yaml and apply it:
```bash
kubectl apply -f regular-pod.yaml
```
### Expected Result:
The regular-pod should not be scheduled on node1 because it does not have a toleration for the taint.
You can verify this by checking the pod's status and the nodes they are scheduled on.


