# kubeadm Installation 
- Note: You can install the kubeadm cluster on any vm providers
- Use any vms to install the cluster U can use: (AWS ec2, Vagrant vms, Multipass vms)

# step by step
### step 1.
1. create 3 vms or 2 as needed 
2. make sure the vms in the same network

### step 2 on the Master Vm
- run master.sh file on master node 
```bash
chmod +x master.sh
./master.sh
```

### Step 3. on node1 Vm
- run node1.sh file on worker node1
```bash
chmod +x node1.sh
./node1.sh
```

### Step 4. on node2 Vm
- run node2.sh file on worker node2
```bash
chmod +x node2.sh
./node2.sh
```

## After U finish the installation of these files reboot the Vms master and worker nodes
```bash
sudo reboot # run this command on each VM
```

### Step 5. on master node run  these 
- 1. - create the cluster using this command
```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```
- 2. after the command done run these commands:
```bash
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
- **In the output, you can see the kubeadm join command and a unique token that you will run on the worker node and all other worker nodes that you want to join onto this cluster. Next, copy-paste this command as you will use it later in the worker node**

- 3. run this command : this command will install the network on the cluster
```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

- 4. after `kubeadm init` finishes successfully, it will there a unique token copy it to run on the worker nodes 
something like this:
```bash
 kubeadm join 10.249.205.197:6443 --token 0itzc1.9x9pnfv4g9z2yyab --discovery-token-ca-cert-hash sha256:dc1ab6166f961ee2e3c48de417d347909ff0b3e01182349716041992f28c4da4 
```
- 5. on Worker node1 and worker node2  run the Token by `sudo`
```bash
sudo YourToken
```
- 6. On the master node check if the worker nodes have joined
```bash
kubectl get nodes
```

# To enable auto completion for kubectl commands and make  alias k:
- put these lines in `~/.bashrc` file 
```bash
# Kubectl autocomplete
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
```


#  I hope this will help you. 