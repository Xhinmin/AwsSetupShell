#!/bin/bash

# 更新 apt 包索引
sudo apt-get update

# 安装 Docker
sudo apt-get install -y docker.io

# 启动 Docker 服务
sudo systemctl start docker

# 设置 Docker 开机自启
sudo systemctl enable docker

# 将当前用户加入 docker 组（如果需要）
sudo usermod -aG docker $USER

echo "Docker 安裝完成，請重新登出並登入以生效群組變更。"