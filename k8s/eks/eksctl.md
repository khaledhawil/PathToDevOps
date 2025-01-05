

1. Install aws cli 
2. Install kubectl
3. Install eksctl

$ mkdir eksctl
$ cd eksctl/


1. Install aws cli :


$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

$ unzip awscliv2.zip
Archive:  awscliv2.zip
   creating: aws/
   creating: aws/dist/


$ sudo ./aws/install
You can now run: /usr/local/bin/aws --version

$ aws --version
aws-cli/2.11.6 Python/3.11.2 Linux/5.10.173-154.642.amzn2.x86_64 exe/x86_64.amzn.2 prompt/off



2. Installing eksctl:


$ curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

$ sudo mv /tmp/eksctl /usr/local/bin

[ec2-user@ip-172-31-12-122 ~]$ eksctl version
0.135.0


3. Install kubectl:

$ curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.6/2023-01-30/bin/linux/amd64/kubectl
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 42.9M  100 42.9M    0     0  4860k      0  0:00:09  0:00:09 --:--:-- 5293k

$ chmod +x ./kubectl

$ mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin


$ kubectl version
Client Version: version.Info{Major:"1", Minor:"25+", GitVersion:"v1.25.6-eks-48e63af", GitCommit:"9f22d4ae876173884749c0701f01340879ab3f95", GitTreeState:"clean", BuildDate:"2023-01-24T19:22:49Z", GoVersion:"go1.19.5", Compiler:"gc", Platform:"linux/amd64"}
Kustomize Version: v4.5.7





Create Cluster:

$ eksctl create cluster --name dolfined-eks --region us-east-1 --version 1.25 --node-type t2.micro --nodes 2

$ eksctl delete cluster --name dolfined-eks

$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".


