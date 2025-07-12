# AwsSetupShell
專門給AWS EC2 (Amazon Linux) 用的 安裝腳本檔


## 功能模組

### 系統配置腳本

- **Docker 安裝腳本** (`docker.sh`)
  - 自動安裝 Docker
  - 配置 Docker 開機自啟動
  - 設置使用者權限

- **Kubernetes 安裝腳本**
  - Amazon Linux 版本 (`k8s-amazon.sh`)
  - Ubuntu 版本 (`k8s-ubuntu.sh`)
  - 包含完整的 K8s 集群初始化流程

- **Fail2ban 安全配置** (`fail2ban/install_fail2ban.sh`)
  - 自動安裝和配置 Fail2ban
  - 設置 SSH 防護規則
  - 提供安全監控功能

### Web 服務配置

- **Nginx 示例專案** (`nginx-sample/`)
  - 基礎 Nginx 配置
  - Docker 容器化部署

- **Nginx 路由器** (`nginx-router/`)
  - 進階路由規則配置
  - URL 重寫功能
  - 錯誤頁面處理

- **Nginx 反向代理** (`nginx-proxy/`)
  - 多服務代理配置
  - 子域名路由
  - 與其他容器服務整合

### 代理與監控工具

- **Traefik 代理** (`traefik-proxy/`)
  - 現代化的反向代理和負載平衡
  - 自動 HTTPS 憑證管理
  - Docker 整合

### Docker 應用

- **Uptime Kuma** (`uptime-kuma/`)
  - 網站監控工具

- **PhotoStack** (`photostack/`)
  - 照片處理應用

- **FossFLOW** (`FossFLOW/`)
  - 圖形化流程設計工具

## 使用指南

### 系統配置

#### 安裝 Docker

#### Docker (Amazon Linux)
sudo ./docker-amazon.sh

#### Docker (Ubuntu)
sudo ./docker-ubuntu.sh

#### 安裝 Kubernetes (Amazon Linux)

sudo ./k8s-amazon.sh

#### 安裝 Kubernetes (Ubuntu)
sudo ./k8s-ubuntu.sh