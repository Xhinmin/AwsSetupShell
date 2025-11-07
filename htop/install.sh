#!/bin/bash
# htop-install.sh
# 自動安裝並啟動 htop 的簡單腳本
# 適用於 Ubuntu、Debian、Amazon Linux、CentOS、RHEL

echo "=== htop 安裝腳本 ==="

# 判斷系統版本
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "無法判斷作業系統版本"
    exit 1
fi

echo "偵測到系統: $OS"
echo "正在安裝 htop..."

case "$OS" in
    ubuntu|debian)
        sudo apt update -y
        sudo apt install -y htop
        ;;
    amzn)
        sudo yum install -y htop || {
            sudo amazon-linux-extras install epel -y
            sudo yum install -y htop
        }
        ;;
    centos|rhel)
        sudo yum install -y epel-release
        sudo yum install -y htop
        ;;
    *)
        echo "⚠️ 不支援的系統: $OS"
        exit 1
        ;;
esac

# 驗證安裝
if command -v htop >/dev/null 2>&1; then
    echo "✅ htop 安裝完成！"
    echo "啟動 htop 中..."
    sleep 1
    htop
else
    echo "❌ htop 安裝失敗，請手動檢查。"
    exit 1
fi
