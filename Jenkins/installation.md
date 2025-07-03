# Jenkins Installation by several ways
75c0ccaebc6e4e7a98503d6df57e32f7
## Jenkins Installation by Docker compose:
1. Create a new file named `docker-compose.yml` in the root of your project.
2. Add the following content to the `docker-compose.yml` file:

```yaml
version: '3'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    ports:
      - "8080:8080"
    volumes:
      - jenkins_home:/var/jenkins_home
     networks:
      - jenkins
volumes:
  jenkins_home:
networks:
  jenkins:
    driver: bridge
```

3. Run the following command to start Jenkins:

```bash
docker-compose up -d
```

4. Open your web browser and navigate to `http://localhost:8080`. You should see the Jenkins setup page.

## Jenkins Installation by Docker:
1. Run the following command to start Jenkins:

```bash
docker run -d -p 8080:8080 -v jenkins_home:/var/jenkins_home --name jenkins jenkins/jenkins:lts
```

2. Open your web browser and navigate to `http://localhost:8080`. You should see the Jenkins setup page.
3. To stop Jenkins, run the following command:

```bash
docker stop jenkins
```

4. To start Jenkins, run the following command:

```bash
docker start jenkins
```

5. To remove Jenkins, run the following command:

```bash
docker rm jenkins
```

## Jenkins Installation by Kubernetes:
1. Create a Kubernetes deployment YAML file (e.g., `jenkins-deployment.yaml`) with the following content :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  labels:
    app: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  labels:
    app: jenkins
spec:
  type: LoadBalancer
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    app: jenkins
```
2. Create a Kubernetes persistent volume claim YAML file (e.g., `jenkins-pvc.yaml`) with the following content :
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```
3. Apply the YAML files to your Kubernetes cluster:
```bash
kubectl apply -f jenkins-pvc.yaml
kubectl apply -f jenkins-deployment.yaml

```





