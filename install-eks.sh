#!/bin/bash

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin

git clone https://github.com/sriramulasrinath/k8-eksctl.git

git clone https://github.com/sriramulasrinath/k8-resources.git



sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens


kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.32" #installing ebs drivers

cd k8-eksctl
eksctl create cluster --config-file=eks.yml
#https://raw.githubusercontent.com/sriramulasrinath/k8-eksctl/main/install-eks.sh
#eksctl create cluster --config-file=<ymlfile>