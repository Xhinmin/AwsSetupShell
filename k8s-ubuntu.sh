#!/bin/bash

set -e

echo "==== 更新系統 ===="
sudo apt update -y && sudo apt upgrade -y

echo "==== 安裝 Docker ===="
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

echo "==== 關閉 Swap（Kubernetes 要求）===="
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "==== 設定 Kubernetes 套件來源 ===="
sudo apt install -y apt-transport-https ca-certificates curl
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update

echo "==== 安裝 kubelet、kubeadm、kubectl ===="
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

echo "==== 初始化 Kubernetes ===="
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

echo "==== 設定 kubectl ===="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "==== 安裝 Flannel 網路插件 ===="
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "==== 驗證 Kubernetes 安裝 ===="
kubectl get nodes
kubectl get pods -A

echo "==== 安裝完成 ===="
echo "請重新登出再登入以讓 docker 群組權限生效"
