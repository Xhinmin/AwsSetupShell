#!/bin/bash

# 檢查是否為 root 用戶
if [ "$EUID" -ne 0 ]; then 
    echo "請使用 root 權限運行此腳本"
    echo "使用方式: sudo $0"
    exit 1
fi

# 檢查系統類型
if [ -f /etc/system-release ]; then
    OS=$(cat /etc/system-release)
else
    echo "無法確認系統類型"
    exit 1
fi

# 檢查是否為 Amazon Linux
if ! echo "$OS" | grep -q "Amazon Linux"; then
    echo "此腳本針對 AWS EC2 Amazon Linux 環境設計"
    echo "當前系統: $OS"
    exit 1
fi

echo "開始安裝 fail2ban..."

# 安裝 EPEL repository (Amazon Linux 需要)
amazon-linux-extras install epel -y

# 安裝 fail2ban
yum install -y fail2ban fail2ban-systemd

# 檢查安裝結果
if [ $? -eq 0 ]; then
    echo "fail2ban 安裝成功！"
    
    # 建立基本配置
    if [ ! -f /etc/fail2ban/jail.local ]; then
        echo "建立基本配置文件..."
        cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/secure
maxretry = 3
EOF
    fi
    
    # 啟動 fail2ban 服務
    systemctl enable fail2ban
    systemctl start fail2ban
    
    # 顯示服務狀態
    echo "fail2ban 服務狀態："
    systemctl status fail2ban
    
    echo -e "\n配置信息："
    echo "- SSH 防護已啟用"
    echo "- 最大重試次數: 3次"
    echo "- 封鎖時間: 1小時"
    echo "- 檢測時間窗口: 10分鐘"
    echo -e "\n查看 fail2ban 狀態: sudo fail2ban-client status"
    echo "查看 SSH 防護狀態: sudo fail2ban-client status sshd"
else
    echo "fail2ban 安裝失敗，請檢查錯誤訊息"
    exit 1
fi 