# steps for how ingress works in k8s
**1-create a debloyment and create service type ClusterIp** 
**2- create ingress resource**
**3- create ingress controller**
**4- create aws LoadBalancer and connect it with ingress controller listen on the port of ingress controller**
        **4- ingress controller will listen on port 80**
        **5- ingress controller will forward traffic to service**
        **6- service will forward traffic to pod**
        **7- pod will handle the request**
        **8- ingress controller will return the response to the client**
        **9- client will receive the response**
        **10- ingress controller will log the request and response**
        **11- ingress controller will update the ingress resource**




## to install ingress controller by helm:
**install Helm**:
```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

helm version
```
**Install Ingress controller for Kubernetes:**
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx
```

**Create a new ingress**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dolfined-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: ingress-2044580522.us-east-1.elb.amazonaws.com
    http:
      paths:
      - pathType: Prefix
        path: /dolfined
        backend:
          service:
            name: app1-svc
            port:
              number: 2000
      - pathType: Prefix
        path: /mena

```