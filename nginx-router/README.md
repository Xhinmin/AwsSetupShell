# Nginx Router Project

這是一個專注於 URL 路由功能的 Nginx Docker 容器化專案。

這個專案展示了：
- Nginx URL 路由配置
- 路徑別名（Path Aliasing）
- 錯誤頁面處理
- 靜態檔案服務

## 專案結構 | Project Structure

```
nginx-router/
├── conf/
│   └── nginx.conf      # Nginx 路由配置文件
├── html/
│   ├── index.html      # 網站首頁
│   └── style.css       # CSS 樣式表
└── Dockerfile          # Docker 建構文件
```

## 路由配置 | Route Configuration

專案包含以下路由設定：
- `/` - 顯示根目錄的靜態頁面
- `/home` - 首頁別名，指向相同的靜態內容
- `/404.html` - 自定義 404 錯誤頁面

## 使用方法 | Usage

### 建構 Docker 映像 | Build Docker Image
```bash
docker build -t nginx-router .
```

### 運行容器 | Run Container
```bash
docker run -d -p 80:80 nginx-router
```

## 測試路由 | Testing Routes

建置完成後，可以測試以下 URL：
1. `http://localhost/` - 訪問首頁
2. `http://localhost/home` - 訪問首頁別名
3. 任意不存在的路徑將顯示 404 頁面

## 配置說明 | Configuration

- 使用 `nginx:alpine` 作為基礎映像
- 主要配置文件：`conf/nginx.conf`
  - 包含路由規則
  - URL 重寫規則
  - 錯誤頁面處理
- 靜態檔案位於 `html/` 目錄

## 開發指南 | Development Guide

1. 修改 `conf/nginx.conf` 來：
   - 添加新的路由規則
   - 設定 URL 重寫
   - 配置錯誤頁面
2. 在 `html/` 目錄中添加或修改靜態內容
3. 重新建構並運行容器以套用更改

## 注意事項 | Notes

- 確保 Docker 已正確安裝
- 預設使用 80 端口，如被占用可修改端口映射
- 路由規則修改後需要重新建構容器
- 建議在開發環境中測試配置更改後再部署到生產環境 