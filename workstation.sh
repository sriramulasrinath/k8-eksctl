#!/bin/bash
#https://raw.githubusercontent.com/sriramulasrinath/k8-eksctl/main/workstation.sh
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "$R$2...FAILED$N"
    exit 1
  else
    echo -e "$G$2...SUCCESS$N"
  fi
}

#install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin &>>$LOGFILE
VALIDATE $? "installed eksctl....$Y SKIPPING $N" 

#install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl
chmod +x ./kubectl &>>$LOGFILE
sudo mv kubectl /usr/local/bin
VALIDATE $? "installed kubectl....$Y SKIPPING $N" 


#installing kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx &>>$LOGFILE
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens
VALIDATE $? "kubens installed....$Y SKIPPING $N"

# extend disk
growpart /dev/nvme0n1 4 &>>$LOGFILE
lvextend -l +50%FREE /dev/RootVG/rootVol &>>$LOGFILE
lvextend -l +50%FREE /dev/RootVG/varVol &>>$LOGFILE
xfs_growfs / &>>$LOGFILE
xfs_growfs /var &>>$LOGFILE
VALIDATE $? "Disk Resized....$Y SKIPPING $N" 



#installing ebs drivers
# kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.32" #installing ebs drivers
# VALIDATE $? "installed ebs drivers....$Y SKIPPING $N"

# #installing efs drivers
# kubectl kustomize \
#     "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-2.0" > public-ecr-driver.yaml #installing eks drivers
# VALIDATE $? "installed efs drivers....$Y SKIPPING $N"

#installing k9s
curl -sS https://webinstall.dev/k9s | bash #k9s installing 
VALIDATE $? "installed k9s....$Y SKIPPING $N"

#cloning git repositories
git clone https://github.com/sriramulasrinath/k8-expense-volumes.git
git clone https://github.com/sriramulasrinath/k8-eksctl.git
git clone https://github.com/sriramulasrinath/k8-resources.git

#helm install
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
VALIDATE $? "installed HElM....$Y SKIPPING $N"

cd k8-eksctl &>>$LOGFILE
eksctl create cluster --config-file=eks.yml &>>$LOGFILE
VALIDATE $? "created eksctl cluster...$Y SKIPPING $N"

