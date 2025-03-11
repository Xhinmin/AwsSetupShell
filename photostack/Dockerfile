# 使用輕量級 Nginx 作為基礎映像
FROM nginx:alpine

# 安裝 git
RUN apk add --no-cache git

# 設定工作目錄
WORKDIR /usr/share/nginx/html

# 移除 Nginx 預設的 HTML 檔案
RUN rm -rf /usr/share/nginx/html/*

# Clone PhotoStack 原始碼
RUN git clone --depth 1 https://github.com/corbindavenport/photostack.git . 

# 暴露 80 端口
EXPOSE 80

# 啟動 Nginx
CMD ["nginx", "-g", "daemon off;"]
