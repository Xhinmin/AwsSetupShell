#!/bin/bash

set -e

# 更新系統套件
sudo yum update -y

echo "==== 安裝 Docker ===="
sudo yum install -y docker

# 啟動 Docker 並設為開機自動啟動
sudo systemctl start docker
sudo systemctl enable docker

# 將使用者加入 docker 群組
sudo usermod -aG docker $USER

echo "Docker 安裝完成。"

echo "==== 關閉 Swap（K8s 需要）===="
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "==== 設定 Kubernetes 套件倉庫 ===="
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet
sudo systemctl start kubelet

echo "==== 關閉 SELinux（暫時關閉以避免問題）===="
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

echo "==== 安裝完成！===="
echo "請重新登出並登入以生效 docker 群組變更。"
echo "接下來可以使用 'sudo kubeadm init' 初始化 Kubernetes master node。"
