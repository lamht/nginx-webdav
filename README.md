# nginx-webdav

docker run --name webdav1 \
  --restart=unless-stopped \
  -m 256m \
  -p 8082:80 \
  -v /storage/downloads:/data \
  -e TZ=Asia/Ho_Chi_Minh  \
  -e UDI=1000 \
  -e GID=1000 \
  -d  thanhlam00290/webdav:alpine
