# ingress in k8s :
- **Ingress** is a resource that manages external access to services within a cluster, typically HTTP and HTTPS traffic. It provides a way to expose services to the outside world and can also manage routing rules, SSL termination, and more.
- **Ingress Controller** is a component that runs within the cluster and is responsible for managing th
- **Ingress** is a resource that manages external access to services within a cluster, typically HTTP


## Key Components of Ingress:
- **Ingress Resource**: This is a set of rules that define how external HTTP/S traffic should be routed to the services in your cluster. It specifies the hostnames, paths, and the backend services to which the traffic should be directed.

- **Ingress Controller**: his is the component that implements the Ingress rules. It listens for changes to Ingress resources and updates its configuration to reflect those changes. There are several popular Ingress controllers, such as:
- **NGINX Ingress Controller**: This is one of the most popular Ingress controllers
- **Istio Ingress Controller**: This is a part of the Istio service mesh
- **Gloo Ingress Controller**: This is a modern, cloud-native Ingress controller
- **Traefik Ingress Controller**: This is a popular, open-source Ingress controller
- **HAProxy Ingress Controller**: This is a high-performance Ingress controller
- **Amazon Elastic Load Balancer (ELB)**: This is a managed load balancer service

**Basic Example of Ingress:** Here’s a simple example of an Ingress resource that routes traffic to two different services based on the request path:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    name: example-ingress
spec:
    rules:
    - host: example.com
    http:
    paths:
    -   path: /api
    backend:
    serviceName: api-service
    servicePort: 80
    - path: /ui
    backend:
    serviceName: ui-service
    servicePort: 80
    - host: sub.example.com
```
