#!/bin/bash

# 檢查是否為 root 用戶
if [ "$EUID" -ne 0 ]; then 
    echo "請使用 root 權限運行此腳本"
    echo "使用方式: sudo $0"
    exit 1
fi

# 檢查系統是否為 RHEL/CentOS
if [ ! -f /etc/redhat-release ]; then
    echo "此腳本僅支援 RHEL/CentOS 系統"
    exit 1
fi

echo "開始安裝 fail2ban..."

# 安裝 fail2ban
yum install -y fail2ban

# 檢查安裝結果
if [ $? -eq 0 ]; then
    echo "fail2ban 安裝成功！"
    
    # 啟動 fail2ban 服務
    systemctl enable fail2ban
    systemctl start fail2ban
    
    # 顯示服務狀態
    echo "fail2ban 服務狀態："
    systemctl status fail2ban
else
    echo "fail2ban 安裝失敗，請檢查錯誤訊息"
    exit 1
fi 