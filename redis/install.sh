#!/bin/bash
# redis-install.sh
# 自動安裝與設定 Redis（支援 Amazon Linux 2 / Ubuntu）

echo "=== Redis 自動安裝腳本 ==="

# 檢查系統類型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ 無法判斷作業系統版本"
    exit 1
fi

echo "偵測到系統: $OS"
sleep 1

# Ubuntu 系統：從官方 repo 安裝 Redis 7
if [[ "$OS" == "ubuntu" ]]; then
    echo "➡ 偵測到 Ubuntu，使用 Redis 官方套件庫安裝 Redis 7..."
    sudo apt update -y
    sudo apt install -y curl lsb-release gpg

    # 匯入 Redis 官方簽章金鑰
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

    # 新增官方 repository
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

    # 安裝 Redis 7
    sudo apt update
    sudo apt install -y redis

    # 啟用 Redis
    sudo systemctl enable redis-server
    sudo systemctl start redis-server

# Amazon Linux 2：從原始碼安裝
elif [[ "$OS" == "amzn" ]]; then
    echo "➡ 偵測到 Amazon Linux 2，開始從原始碼編譯 Redis 7..."
    sudo yum update -y
    sudo yum groupinstall "Development Tools" -y
    sudo yum install -y jemalloc-devel tcl wget

    # 下載最新穩定版 Redis 7
    cd /usr/local/src
    sudo wget https://download.redis.io/releases/redis-7.2.5.tar.gz
    sudo tar xzf redis-7.2.5.tar.gz
    cd redis-7.2.5

    # 編譯與安裝
    sudo make
    sudo make install

    # 建立 Redis 用戶與資料夾
    sudo useradd -r -s /bin/false redis
    sudo mkdir -p /var/lib/redis
    sudo chown redis:redis /var/lib/redis
    sudo chmod 770 /var/lib/redis

    # 建立 systemd 服務檔案
    sudo tee /etc/systemd/system/redis.service > /dev/null <<EOL
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target
EOL

    # 建立設定檔
    sudo mkdir -p /etc/redis
    sudo cp redis.conf /etc/redis/redis.conf
    sudo sed -i 's/^supervised no/supervised systemd/' /etc/redis/redis.conf
    sudo sed -i 's/^dir .*/dir \/var\/lib\/redis/' /etc/redis/redis.conf

    # 啟動 Redis
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl enable redis
    sudo systemctl start redis

else
    echo "⚠️ 不支援的系統版本: $OS"
    exit 1
fi

# 驗證安裝
echo "=== 驗證 Redis 版本 ==="
if command -v redis-server >/dev/null 2>&1; then
    redis-server --version
else
    echo "❌ Redis 未正確安裝"
    exit 1
fi

# 測試是否可用
echo "=== 測試 Redis 運作狀態 ==="
if redis-cli ping | grep -q "PONG"; then
    echo "✅ Redis 7 安裝成功！"
else
    echo "⚠️ Redis 已安裝，但似乎未啟動，請執行："
    echo "   sudo systemctl status redis 或 redis-server"
fi