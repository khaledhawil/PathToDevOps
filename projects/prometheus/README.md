# Node.js App with Prometheus Monitoring and Kubernetes Deployment

## Overview
This project is a simple Node.js application using Express.js, instrumented with Prometheus for monitoring, and deployed on a Kubernetes cluster. The application exposes an endpoint that tracks the number of HTTP requests to the root path (/). Additionally, Prometheus monitoring and alerting are set up using ServiceMonitor and PrometheusRule

## Features
- Node.js Express App: Serves a simple message on / and exposes metrics on /metrics.

- Prometheus Monitoring: Collects default and custom metrics using prom-client.

- Dockerization: The app is containerized using Docker.

- Kubernetes Deployment: Deploys the app on Kubernetes with replication and service exposure.

- Alerting with Prometheus and Alertmanager: Alerts when the request rate exceeds a threshold.

- Load Simulation: A script (send.sh) generates HTTP requests to test monitoring and alerting.

## Prerequisites
- Docker installed

- Kubernetes cluster set up (e.g., Minikube, AWS EKS, GKE, or AKS)

- kubectl configured to access the cluster

- Prometheus and Alertmanager installed in the cluster

- A Docker Hub account (for pushing images)

## File Structure
```
.
├── Dockerfile
├── README.md
├── index.js
├── nodejs-app.yaml
├── nodejs-svc.yaml
├── nodejs-monitor.yaml
├── nodejs-alert.yaml
├── nodejs-alert-manager.yaml
├── send.sh
```
##  Before U start, install `Prometheus & Grafana`  with `Helm`
- 1. install helm 
```bash
$ curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
$ sudo apt-get install apt-transport-https --yes
$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
$ sudo apt-get update
$ sudo apt-get install helm
$ helm version
```
- 2. install prometheus & grafana 
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
 
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

```
# Steps after U installed `Prometheus and Grafana` Let's Start
- 1. create index.js file 
```bash
vim index.js
```
```js
const express = require('express');
const client = require('prom-client');

const app = express();
const port = 3000;

// Create a Registry to register the metrics
const register = new client.Registry();

// Add a default label which is added to all metrics
register.setDefaultLabels({
  app: 'nodejs_dolfined_app'
});

// Enable the collection of default metrics
client.collectDefaultMetrics({ register });

// Define a custom metric for total HTTP requests to the root path
const rootHttpRequestCounter = new client.Counter({
  name: 'http_requests_root_total',
  help: 'Total number of HTTP requests to the root path',
});

// Register the custom metric
register.registerMetric(rootHttpRequestCounter);

// Middleware to count every request to the root path
app.use((req, res, next) => {
  if (req.path === '/') {
    rootHttpRequestCounter.inc();
  }
  next();
});

// Define a route for Prometheus to scrape
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Define the root route
app.get('/', (req, res) => {
  res.send('Hello From DolfinED');
});

// Start the server
app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
```
- 2. create Dockerfile
```bash
vim Dockerfile
```
```Dockerfile
FROM node:lts
WORKDIR /usr/src/app
COPY . .

RUN npm install express prom-client

EXPOSE 3000
CMD ["node", "index.js"]
```
- 3. build docker image from Docker file 
```bash
docker build -t nodejs-app .
```

- 4. Tag the image with your Docker Hub username 
```bash
docker tag nodejs-app:latest khaledhawil/nodejs-app:v1
```

- 5. Login to Docker Hub
```bash
docker login -u khaledhawil 
```
- 6. Push the image to Docker Hub
```bash
docker push khaledhawil/nodejs-app:v1
```


- 7. Create a Kubernetes deployment YAML file

nodejs-app.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nodejs-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodejs
  template:
    metadata:
      labels:
        app: nodejs
    spec:
      containers:
        - name: nodejs
          image: khaledhawil/nodejs-app:v1
          ports:
            - containerPort: 3000 
```
- 8. Apply the YAML file to create the deployment
```bash
kubectl apply -f nodejs-app.yaml
```

- 9. Verify the deployment
```bash
kubectl get deployments
```

- 10. Create a Service YAML file
  - nodejs-svc.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodejs-svc
  labels:
    app: nodejs
  annotations:
    prometheus.io/scrape: 'true'
spec:
  type: NodePort
  selector:
    app: nodejs
  ports:
    - port: 3000
      targetPort: 3000
      name: nodejs
```

- 11. Apply the YAML file to create the Service
```bash
kubectl apply -f nodejs-svc.yaml

```
- 12. create ServiceMonitor file
  - nodejs-svc-monitor.yaml
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: nodejs-monitor1
  namespace: monitoring  
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: nodejs  
  namespaceSelector:
    matchNames:
      - default  
  endpoints:
    - port: nodejs
      path: /metrics
```
- 13. Apply the YAML file to create the ServiceMonitor
```bash
kubectl apply -f nodejs-svc-monitor.yaml
```

- 14. Create PrometheusRule
```bash
  vim nodejs-alert.yaml
```
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: nodejs-alert
  namespace: monitoring
  labels:
    app: kube-prometheus-stack
    release: prometheus
spec:
  groups:
  - name: nodejs-alert
    rules:
    - alert: HighRequestRate_NodeJS
      expr: rate(http_requests_root_total[5m]) > 10
      for: 0m
      labels:
        app: nodejs
        namespace: monitoring
      annotations: 
        description: "The request rate to the root path has exceeded 10 requests."
        summary: "High request rate on root path"
```

- 15. Apply the YAML file to create the PrometheusRule
```bash
kubectl apply -f nodejs-alert.yaml
```

- 16. Create Alertmanager yaml file 
```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: nodejs-alert-manager
  namespace: monitoring
spec:
  route:
    receiver: 'nodejs-slack'
    repeatInterval: 30m
    routes:
    - matchers:
      - name: alertname
        value: HighRequestRate_NodeJS
      repeatInterval: 10m
  receivers:
  - name: 'nodejs-slack'
    slackConfigs:
      - apiURL:
          key: webhook
          name: slack-secret
        channel: '#default'
        sendResolved: true
```
- 17. Apply the YAML file to create the AlertmanagerConfig
```bash
kubectl apply -f  nodejs-alert-manager.yaml
```

- 18. Create a send Request file for test the app :
```bash


#!/bin/bash

send_requests() {
    while true; do
        curl -sS http://54.224.98.184:32001 > /dev/null
        echo "Request sent"
        sleep 0.0667  
    done
}

for ((i=1; i<=15; i++)); do
    send_requests &
    pids[$i]=$!
done

trap 'echo "Exiting..."; kill ${pids[*]}; exit' INT

wait


```

- 19. Run the send request file in the background
  - change the file permission to executable

```bash
chmod +x  send_request.sh
./send_request.sh &
```

