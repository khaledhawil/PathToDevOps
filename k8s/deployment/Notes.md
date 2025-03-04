# Deployment in k8s :
Deployment is a higher level abstraction of Pods. 
It ensures that a specified number of pod replicas are running at any given time.
It is a way to scale pods automatically.
It is a way to manage pods in a cluster.

# StatefulSets in k8s :
StatefulSet is a higher level abstraction of Pods. 
It ensures that a specified number of pod replicas are running at any given time.
It is a way to scale pods automatically.


# how to create a deployment in k8s?
```yaml
apiVersion: apps/v1
2kind: Deployment
3metadata:
4  name: my-app
5  labels:
6    app: my-app
7spec:
8  replicas: 3
9  selector:
10    matchLabels:
11      app: my-app
12  template:
13    metadata:
14      labels:
15        app: my-app
16    spec:
17      containers:
18      - name: my-app-container
19        image: my-app-image:latest
20        ports:
21        - containerPort: 80
```

- kubectl create -f deployment-definition.yml

# how to update a deployment in k8s?
```bash
- kubectl replace -f deployment-definition.yml
- kubectl apply -f deployment-definition.yml
- kubectl set image deployment/my-app my-app-container=my-app-image:latest
- kubectl rollout status deployment/my-app
- kubectl rollout history deployment/my-app
- kubectl rollout undo deployment/my-app
- kubectl rollout undo deployment/my-app --to-revision=1
- kubectl rollout pause deployment/my-app
- kubectl rollout resume deployment/my-app
```
# to update the deployment image in k8s using sed command:
```bash
- sed -i 's/image: my-app-image:latest/image: my-app-image:latest/g' deployment.yaml
sed -i 's|image: ubuntu|image: nginx|' deployment.yaml
```
# update pod image : 
```bash
- kubectl set image deployment/my-app my-app-container=my-app-image:latest --record=true # 
- kubectl rollout status deployment/my-app
```
# how to scal the deployment :
```bash

- kubectl scale deployment/my-app --replicas=4
```

# to undo the update and back to last update :
```bash
- kubectl rollout undo deployment/my-app --to-revision=1
```

# to view thw history of rollout
```bash

- kubectl rollout history deployment/my-app
```
# to pause the rollout :
```bash

- kubectl rollout pause deployment/my-app
```




# how to delete a deployment in k8s?
```bash

- kubectl delete -f deployment-definition.yml
- kubectl delete deployment my-app
```


# how to get deployment details in k8s?
```bash
- kubectl get deployment
- kubectl describe deployment my-app
- kubectl get deployment -o yaml
```
# how to replace an image to deployment by imperative way :
```bash

- kubectl set image deployment/my-app my-app-container=my-app-image:latest #
# examlpe
- kubectl set image deployment/my-app my-app-container=my-app-image:latest --record
kubectl set image deployment/<deployment-name> <container-name>=<new-image>
```


# how to create service for deployment:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
    selector:
        app: my-app
    ports:
        - protocol: TCP
        port: 80
        targetPort: 80
    type: NodePort
```

# Deployment strategy :
- Recreate : terminate all the existing pods and create new pods
- RollingUpdate : update the pods one by one

# how to create a deployment with rolling update strategy :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
replicas: 3
selector:
  matchLabels:
    app: my-app
template:
metadata:
    labels:
        app: my-app
spec:
    containers:
    - name: my-app-container
      image: my-app-image:latest
      ports:
      - containerPort: 80
strategy:
    type: RollingUpdate
    rollingUpdate:
        maxSurge: 1
        maxUnavailable: 1
```
- RollingUpdate strategy is the default strategy in k8s.
- maxSurge: 1 means one pod can be created above the desired number of pods.
- maxUnavailable: 1 means one pod can be unavailable during the update process.
- The rolling update strategy will update the pods one by one, and the old pods will be terminated
    only after the new pods are running and ready.
    - The rolling update strategy will also handle the case where a pod is not available during the update process.
    
# how to create a deployment with recreate strategy :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
replicas: 3
selector:
  matchLabels:
    app: my-app
template:
metadata:
    labels:
        app: my-app
spec:
    containers:
    - name: my-app-container
      image: my-app-image:latest
      ports:
      - containerPort: 80
strategy:
    type: Recreate
```
- using of recreate strategy is not recommended because it will terminate all the existing pods and create new pods.
- it is not recommended to use recreate strategy in production environment.




# how to create a deployment with rolling update strategy and update the image :
```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: my-app
  labels:
    app: my-app
spec:
replicas: 3
selector:
  matchLabels:
    app: my-app
template:
metadata:
    labels:
        app: my-app
spec:
    containers:
    - name: my-app-container
      image: my-app-image:latest
      ports:
      - containerPort: 80
strategy:
    type: RollingUpdate
    rollingUpdate:
        maxSurge: 1
        maxUnavailable: 1
```



