#####################################################################################
################### Demo - Create User(Khaled) And Give Permissions #################
#####################################################################################
## see the contexts of config file
```bash
kubectl config get-contexts
```

#### check kubeConfig file:
```bash
 kubectl config view
```

### 1. Create a private key for your user (khaled): 
```bash
openssl genrsa -out khaled.key 2048
```
### 2. Create a certificate sign request test.csr using the private key you just created:
```bash
openssl req -new -key khaled.key -out khaled.csr -subj "/CN=khaled"
```

### 3.you should first make CSR to encoded using base64:
```bash
cat khaled.csr | base64 | tr -d "\n"
```
### 4. Create a CertificateSigningRequest and submit it to a Kubernetes Cluster:
csr.yaml
```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: khaled
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dhMmhoYkdWa01JSUJJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQVE4QU1JSUJDZ0tDQVFFQXpQdWJRU3ZEMTVtd3hiTnJIM3FpSEQrbWcxR2QwbVpVZkt3SkhoZ3RBUGdrCkVQQXc3Z1hYMWR4ZUpYRGZTWkxwRERJMm8ydFVjN1E3bHhsaEUwS0k4RHNhNWRtRXhFK1RuSFhOMzJYTVZqRUoKMkFIY09CQVhHL1VpR0pJMlRuWlF2ZGQrN0xNYkJQdHo2SWRxRVhRdDc1YW1CcnhWcGZwaHA1S0JLVHo1K0RHMApYOTlWemN6T2ZiVWE3QjlrcEQ2VDBuWTBnRkx4cjZSWVFhSEpzQllWSUEyS1Q4Y1A1MTZOS2EzbnJUTHNERFB0Cno0djQ5QVMvalZjYlllcmhLQXo3Nkk5a04zOUVja1RWRzNxengwLzJMZFM5ek1ZbUExZ2FMNi8rZWF3MjZvdTIKUXFwRnc4MU9haHRYNFRYZmlxSGROWUF0eTVYdllxMkpBbDNXNFFVczR3SURBUUFCb0FBd0RRWUpLb1pJaHZjTgpBUUVMQlFBRGdnRUJBSmV3OVRvVXdnTy9PZlUrazdyeE9oOU1tQnBZN0RwSmEvQ0N2QlQ3SXlKWi9mVTdDcERIClB1K0haVFVPTTJNRDVYOEF5a2p5elRFZlR2RnkvdFBaZGJnd0pGZlM1K3lEUkg2THdWYjJ5QzJBQzM2a096Q3oKcGc0OWx4VWdiTWluOFJIaWtVRzg3T0pjZzdyRUVYbjkxclNRSHFuT0RsdjFTWnNTUXVaY244QzAwaFpSUzg5eQpNeHdQWFJXaW8rZ2NuOHBZRDJtcUowNkdNSFJMM1JCdUsveFhRSFhLNUZ4VUlIZ2MvL3Exd0FMREMxUkVZSWFGCmh4aVh4Qys4eDVwNUFLa2dOdXJsQk1ZTSs4ZEhhRlNxc2RDYnZEa3FlWXAwci8reUU3YU80NTJKOERmbWJYbnYKNHRvMFI1UEZmSGtJT01aR1VKMWkzbmo0KzZ5bEcwMFV6UVk9Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
---

```bash
$ kubectl get csr
NAME       AGE    SIGNERNAME                            REQUESTOR            CONDITION
khaled   74s   kubernetes.io/kube-apiserver-client     kubernetes-admin      Pending
```

# check the status
```bash
$ kubectl certificate approve khaled
certificatesigningrequest.certificates.k8s.io/khaled approved
$ kubectl get csr
NAME       AGE     SIGNERNAME                            REQUESTOR          CONDITION
khaled   3m13s   kubernetes.io/kube-apiserver-client   kubernetes-admin   Approved,Issued
```
### 5. Get the certificate:
```bash
$ kubectl get csr -o yaml
$ kubectl get csr khaled -o jsonpath='{.status.certificate}'| base64 -d > khaled.crt
$ ls
csr.yaml  khaled.crt  khaled.csr  khaled.key
```  
### Connect user to the Cluster:
- Add to kubeconfig:
- The last step is to add this user into the kubeconfig file.:

- First, you need to add new credentials:
```bash
 kubectl config set-credentials khaled --client-key=/home/ubuntu/khaled.key --client-certificate=/home/ubuntu/khaled.crt --embed-certs=true
```
- Then, you need to add the context:
```bash
kubectl config set-context khaled --cluster=kubernetes --user=khaled
```
#### Try to get pod:
```bash
kubectl get po --context=khaled
output:
Error from server (Forbidden): pods is forbidden: User "dolfined" cannot list resource "pods" in API group "" in the namespace "default"
```
aouthontacation  aouthraisation 