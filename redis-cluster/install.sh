#!/bin/bash
# redis_cluster_setup.sh
# 目的：在 Linux 機器 (Amazon Linux / Ubuntu) 上自動安裝 Redis 並建立 3 個主節點的測試集群。

echo "========================================"
echo "🚀 Redis 測試集群 (3 Master) 自動部署腳本"
echo "========================================"

# --- 新增前置步驟：檢查可用記憶體 ---
echo "✅ 0. 檢查系統記憶體狀態..."
echo "----------------------------------------"
free -h
echo "----------------------------------------"

# 獲取可用記憶體 (MemAvailable，KB)
AVAILABLE_KB=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
# 轉換為 MB
AVAILABLE_MB=$((AVAILABLE_KB / 1024))
MIN_REQUIREMENT_MB=400 # 建議保留至少 400 MB 作為緩衝和 Redis 運行開銷

if [ "$AVAILABLE_MB" -lt "$MIN_REQUIREMENT_MB" ]; then
    echo "⚠️ 警告：目前可用記憶體只有 ${AVAILABLE_MB} MB，低於建議的 ${MIN_REQUIREMENT_MB} MB 最小值。"
    echo "       系統可能會使用 SWAP 空間，導致效能極慢或運行失敗。"
    read -r -p "是否仍然要繼續安裝？ (y/N): " response
    response=${response,,} # 轉為小寫
    if [[ "$response" != "y" ]]; then
        echo "❌ 安裝已取消。"
        exit 1
    fi
else
    echo "✅ 目前可用記憶體 ${AVAILABLE_MB} MB，足夠進行測試。繼續安裝..."
fi


# --- 1. 系統環境準備與依賴安裝 ---
echo "✅ 1. 檢查系統類型並安裝編譯依賴..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ 無法判斷作業系統版本。請手動安裝 GCC 和 Make。"
    exit 1
fi

if [[ "$OS" == "amzn" || "$OS" == "rhel" ]]; then
    # Amazon Linux / RHEL / CentOS
    sudo yum update -y
    sudo yum groupinstall "Development Tools" -y
    sudo yum install -y wget tcl
elif [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    # Ubuntu / Debian
    sudo apt update -y
    sudo apt install -y build-essential wget tcl
else
    echo "⚠️ 不支援的系統版本: $OS，嘗試安裝通用編譯工具..."
    sudo apt update -y 2>/dev/null || sudo yum update -y 2>/dev/null
    sudo apt install -y build-essential wget tcl 2>/dev/null || sudo yum groupinstall "Development Tools" -y && sudo yum install -y wget tcl 2>/dev/null
fi

# --- 2. 下載、編譯與安裝 Redis ---
REDIS_SRC_DIR="/tmp/redis_src"
REDIS_PORT_START=7001
MASTER_COUNT=3
REPLICA_PER_MASTER=1
CLUSTER_NODES=$((MASTER_COUNT * (REPLICA_PER_MASTER + 1))) # 3 主 + 3 從
IP_ADDRESS="127.0.0.1" # 在單機測試，使用本機迴路地址

echo "✅ 2. 下載並編譯 Redis 穩定版..."
mkdir -p "$REDIS_SRC_DIR"
cd "$REDIS_SRC_DIR"

# 下載最新穩定版
wget -q https://download.redis.io/redis-stable.tar.gz -O redis-stable.tar.gz
tar xzf redis-stable.tar.gz
cd redis-stable

echo "--- Redis 發布版本資訊 (00-RELEASENOTES 前 5 行) ---"
cat 00-RELEASENOTES | head -n 5
echo "--------------------------------------------------------"

# 編譯
make
if [ $? -ne 0 ]; then
    echo "❌ Redis 編譯失敗！請檢查依賴是否正確安裝。"
    exit 1
fi

# 安裝到 /usr/local/bin
sudo make install

# 檢查版本
echo "🎉 Redis 安裝成功！版本資訊："
redis-server --version

# --- 3. 準備集群配置與啟動 ---
CLUSTER_DIR="$HOME/redis-cluster"
echo "✅ 3. 準備集群節點配置檔於：$CLUSTER_DIR"

# 清理舊的測試環境
rm -rf "$CLUSTER_DIR"
mkdir -p "$CLUSTER_DIR"

for i in $(seq 1 $CLUSTER_NODES); do
    PORT=$((REDIS_PORT_START + i - 1))
    NODE_DIR="$CLUSTER_DIR/$PORT"
    mkdir -p "$NODE_DIR"
    
    # 建立設定檔
    cp redis.conf "$NODE_DIR/redis.conf"
    
    # 修改配置
    sed -i "s/^port .*/port $PORT/" "$NODE_DIR/redis.conf"
    sed -i "s/^bind 127.0.0.1/bind $IP_ADDRESS/" "$NODE_DIR/redis.conf"
    sed -i "s/^daemonize no/daemonize yes/" "$NODE_DIR/redis.conf"
    sed -i "s/^protected-mode yes/protected-mode no/" "$NODE_DIR/redis.conf"
    sed -i "s/^# cluster-enabled yes/cluster-enabled yes/" "$NODE_DIR/redis.conf"
    sed -i "s/^# cluster-config-file nodes.conf/cluster-config-file nodes-$PORT.conf/" "$NODE_DIR/redis.conf"
    sed -i "s/^# cluster-node-timeout 15000/cluster-node-timeout 5000/" "$NODE_DIR/redis.conf"
    
    # 設置資料目錄
    echo "dir $NODE_DIR" >> "$NODE_DIR/redis.conf"
    
    # 啟動節點
    echo "▶️ 啟動節點 $PORT..."
    redis-server "$NODE_DIR/redis.conf"
done

echo "等待 5 秒確認所有節點啟動..."
sleep 5
ps -ef | grep redis-server | grep cluster

# --- 4. 創建集群 ---
CLUSTER_STRING=""
for i in $(seq 1 $CLUSTER_NODES); do
    PORT=$((REDIS_PORT_START + i - 1))
    CLUSTER_STRING="$CLUSTER_STRING $IP_ADDRESS:$PORT"
done
# CLUSTER_STRING -> 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 ...

echo "✅ 4. 執行集群創建命令..."
# --cluster-replicas 0 表示只建立主節點 (Master)，不配置從節點 (Replica)
echo "redis-cli --cluster create $CLUSTER_STRING --cluster-replicas $REPLICA_PER_MASTER"

# 使用 yes 管道確保自動確認
redis-cli --cluster create $CLUSTER_STRING --cluster-replicas $REPLICA_PER_MASTER --cluster-yes

if [ $? -ne 0 ]; then
    echo "❌ 集群創建失敗！"
    exit 1
fi

# --- 5. 驗證 ---
echo "========================================"
echo "🎉 Redis 測試集群 (${MASTER_COUNT} Master, 每個 Master ${REPLICA_PER_MASTER} 個 Replica) 部署成功！"
echo "========================================"
echo "集群已啟動並運行於埠號範圍：$IP_ADDRESS:$REDIS_PORT_START ~ $((REDIS_PORT_START + CLUSTER_NODES - 1))"
echo ""
echo "💡 如何連接並驗證集群："
echo "   redis-cli -c -p 7001 cluster info"
echo "   redis-cli -c -p 7001 set testkey hello (測試自動重定向)"
echo ""
echo "💡 如何停止所有節點："
echo "   for p in \$(seq $REDIS_PORT_START \$((REDIS_PORT_START + CLUSTER_NODES - 1))); do"
echo "       redis-cli -p \$p shutdown nosave || true"
echo "   done"
echo "   # 或"
echo "   pkill -f \"redis-server 127.0.0.1:700\""