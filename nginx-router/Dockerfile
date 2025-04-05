# 使用官方 Nginx 映像作為基底
FROM nginx:alpine

# 拷貝本地的 Nginx 設定檔到容器中
COPY conf/nginx.conf /etc/nginx/nginx.conf

# 拷貝靜態網站檔案（如果有的話）
COPY html /usr/share/nginx/html

# 設定工作目錄
WORKDIR /usr/share/nginx/html

# 開放 80 port
EXPOSE 80

# 啟動 Nginx
CMD ["nginx", "-g", "daemon off;"]
