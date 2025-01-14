#####################################################################################
################### Demo - Create User(Khaled) And Give Permissions #################
#####################################################################################
#### Here are the steps to create a Kubernetes user:
- 1. Choose User Type: Decide whether to create a user with a client certificate or a service account.

- 2. Generate Credentials: 
        - For a client certificate: Generate a private key and a certificate signing request (CSR), and then sign it with a Certificate Authority (CA).
        - For a service account: Create a service account in the desired namespace.

- 3. Configure Kubeconfig: 
        - For a client certificate: Update your kubeconfig file with the new user’s certificate and key.
        - For a service account: Retrieve the service account token for authentication.
    - Option 1 : Generating a Client Certificate
        - 1. Generate a Private Key:
            - Create a private key for the user using a tool like OpenSSL.
```bash
openssl genrsa -out user.key 2048
```
        - 2. Create a Certificate Signing Request (CSR):
            -   Generate a CSR using the private key. 
```bash
openssl req -new -key user.key -out user.csr -subj "/CN=username"
```
            -   This request will include information about the user (e.g., Common Name).
        - 3. Sign the CSR:
            - Use a Certificate Authority (CA) to sign the CSR, creating a certificate for the user.
```bash
openssl x509 -req -in user.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out user.crt -days 365
```
        - 4. Obtain the CA Certificate:
            - Ensure you have the CA certificate that can be used to validate the user’s certificate.
    - Option 2: Creating a Service Account
        - Create the Service Account:
            - Use the Kubernetes API or command line to create a new service account in the desired namespace.
        - Retrieve the Service Account Token:
            - After creating the service account, obtain the token associated with it, which will be used for authentication.
        - Get the CA Certificate:
            - Ensure you have the CA certificate from the Kubernetes cluster to validate the token.

 2: Creating a Service Account
Create the Service Account:


Use the Kubernetes API or command line to create a new service account in the desired namespace.

Retrieve the Service Account Token:


After creating the service account, obtain the token associated with it, which will be used for authentication.

Get the CA Certificate:


Ensure you have the CA certificate from the Kubernetes cluster to validate the token.


- 4. Define Permissions: Create a Role (for namespace-specific permissions) or a ClusterRole (for cluster-wide permissions) that specifies what actions the user can perform.

- 5. Create RoleBinding or ClusterRoleBinding: Bind the Role or ClusterRole to the user (service account or client certificate) to grant the defined permissions.

- 6. Test Access: Verify that the user can perform the intended actions within the cluster.


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
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dhMmhoYkdWa01JSUJJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQVE4QU1JSUJDZ0tDQVFFQXhacitodGtTNXpRQjNxSzcyd1FiREpKaFUvWGJNYzQ4d1BJRitZaFB4VCtpCnBLSlNwSlorNEtHc1hxRUhaUldPUXJKS0RtZkRxeFRsd0ZvVVhpOFFGNkNORlM2citHNzdBMW0vM05TeHJMb1cKcjNjRW5SKzhFeFJlQmptcU83U1FlSnd6aTYzTE9xNWl1ZmVzaGdZVTU1a3cxeVVybllEZ2xWWjV2dUtObmRKeQpDcEE5NEZjRDlTRHBpbllmTCtlWm5obWZyYXEzZ05XVmZoWlhxYUtGeVRTNE1ETnk2RGdKY1hWeFBJaGJORk1uCm1mbW9la2NFbmZLSS91MlhnZ1NBZjhPbjJ6Mk1iOExrdjVCK3pUaFhFUUhFT2xlVzZENmpJWStwRnJnN0RUbFAKZ2w3ZHFVZnkvM2NrWVhQVktqYzNHZVlKMllxNnVVakI3MUxHWTc4MHp3SURBUUFCb0FBd0RRWUpLb1pJaHZjTgpBUUVMQlFBRGdnRUJBRWhNL2FlOSt5YS9MWG9Zend5TVJ0SmVnbkpMVVIvYlNKaHBxRk8yMVFiSTErK2lDUzdWCnFrNkxISWxiKy9DVGZ6cjlPY0M0dC9ZdUFpZlc4TVl5OWZhQzd4YldKdmI1WlFiNzRkMW5jczA0T09nRjdyc1oKTDlJZHZWaFRoUURqR0x4U282VFZGUC8weVc4NFI2b2NYcnR5RlJ3bVVGSmRmT2IrTm1ZMkNPTVNHMFpMNXB5WgpQNzZXd2hxNVhBa0VXdGZldGxBREZhN3k3Q3pPMklWRnpabW9aYWx0OE9uMzNxRlBWcExBU3Q0a3hlRVR6QXFyCnFJQzdteWgxaFhwS3dhbERyZGhlWk9LWU9jN0c5QWpSOEpOajByTEtud1hnSXNsNVJGOTBQcHI5cHdHbjdFL3cKVmx2NisvMVNESk1sckZZclRhcVJvTWNnZ3Fndzd3Z1lHUm89Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
---

```bash
$ kubectl get csr
NAME       AGE   SIGNERNAME                            REQUESTOR          CONDITION
khaled   74s   kubernetes.io/kube-apiserver-client   kubernetes-admin   Pending
# check the status
$ kubectl certificate approve khaled
certificatesigningrequest.certificates.k8s.io/khaled approved
$ kubectl get csr
NAME       AGE     SIGNERNAME                            REQUESTOR          CONDITION
khaled   3m13s   kubernetes.io/kube-apiserver-client   kubernetes-admin   Approved,Issued
$ kubectl get csr -o yaml

$ kubectl get csr khaled -o jsonpath='{.status.certificate}'| base64 -d > khaled.crt
$ ls
csr.yaml  khaled.crt  khaled.csr  khaled.key
```

### Connect user to the Cluster:
- Add to kubeconfig:
- The last step is to add this user into the kubeconfig file.:

First, you need to add new credentials:
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
