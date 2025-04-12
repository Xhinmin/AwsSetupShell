#!/bin/bash

set -e

echo "==== 更新系統 ===="
sudo dnf update -y

echo "==== 安裝 Docker ===="
sudo dnf install -y docker

sudo systemctl enable --now docker
sudo usermod -aG docker $USER

echo "==== 關閉 Swap（Kubernetes 要求）===="
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "==== 關閉 SELinux（K8s 相容性）===="
sudo setenforce 0 || true
sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

echo "==== 設定 Kubernetes 官方套件倉庫 ===="
sudo mkdir -p /etc/yum.repos.d

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
EOF

echo "==== 安裝 kubelet、kubeadm、kubectl ===="
sudo dnf install -y kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

echo "==== 安裝完成 ===="
echo "請重新登出再登入以讓 docker 群組權限生效"
echo "初始化 Kubernetes 可使用：sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
