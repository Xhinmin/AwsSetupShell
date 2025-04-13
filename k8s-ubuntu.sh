#!/bin/bash

set -e

echo "==== 更新系統 ===="
sudo apt update -y && sudo apt upgrade -y

echo "==== 安裝 Containerd ===="
sudo apt install -y containerd
# 初始化預設設定
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
# 修改 Cgroup driver 為 systemd（符合 kubelet）
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd


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

echo "等待 kubectl 初始化 (5秒)..."
sleep 5

echo "==== 安裝 Flannel 網路插件 ===="
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "==== 驗證 Kubernetes 安裝 ===="
kubectl get nodes
kubectl get pods -A

echo "==== 安裝完成 ===="
