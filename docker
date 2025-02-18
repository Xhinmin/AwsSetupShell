#!/bin/bash

# 安裝 Docker
sudo yum install -y docker

# 啟動 Docker
sudo systemctl start docker

# 設定 Docker 開機自動啟動
sudo systemctl enable docker

# 將當前使用者加入 docker 群組
sudo usermod -aG docker $USER

echo "Docker 安裝完成，請重新登出並登入以生效群組變更。"
