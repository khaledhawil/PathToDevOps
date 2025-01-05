1. Create user and enable console

with this permission "AdministratorAccess"



2. Create Role For EKS:
- Use case "EKS"

with permission:
AmazonEKSClusterPolicy
AmazonEKSServicePolicy

AmazonEC2FullAccess
AmazonEC2ContainerServiceAutoscaleRole

3. Go To create a "EKS-Cluster":


4. Install aws cli :


curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 54.8M  100 54.8M    0     0  97.7M      0 --:--:-- --:--:-- --:--:-- 97.6M


unzip awscliv2.zip
Archive:  awscliv2.zip
   creating: aws/
   creating: aws/dist/


sudo ./aws/install
You can now run: /usr/local/bin/aws --version

aws --version
aws-cli/2.11.6 Python/3.11.2 Linux/5.10.173-154.642.amzn2.x86_64 exe/x86_64.amzn.2 prompt/off




5. Install kubectl:

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.6/2023-01-30/bin/linux/amd64/kubectl


chmod +x ./kubectl

mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin


kubectl version
Client Version: version.Info{Major:"1", Minor:"25+", GitVersion:"v1.25.6-eks-48e63af", GitCommit:"9f22d4ae876173884749c0701f01340879ab3f95", GitTreeState:"clean", BuildDate:"2023-01-24T19:22:49Z", GoVersion:"go1.19.5", Compiler:"gc", Platform:"linux/amd64"}
Kustomize Version: v4.5.7


6. ADD user credentials:

aws configure
AWS Access Key ID [None]: A***************
AWS Secret Access Key [None]: J***********
Default region name [None]: us-east-1
Default output format [None]: json

aws eks update-kubeconfig --region us-east-1 --name eks-test
Added new context arn:aws:eks:us-east-1:944153906994:cluster/eks-test to /home/ec2-user/.kube/config


kubectl get svc


7- Create A Node Group For EKS Cluster With A New IAM Role:
AmazonEKS_CNI_Policy
AmazonEC2ContainerRegistryReadOnly
AmazonEKSWorkerNodePolicy 





