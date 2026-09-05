FROM alpine:latest

# FFmpeg, bash, curl ve Nginx yükle
RUN apk add --no-cache ffmpeg bash curl nginx

WORKDIR /app

# Nginx konfigürasyonunda Directory Listing (autoindex) aktif ediliyor
RUN mkdir -p /run/nginx /app/hls
RUN echo 'server { \
    listen 8080; \
    location / { \
        root /app; \
        autoindex on; \
        autoindex_exact_size off; \
        autoindex_localtime on; \
        add_header Access-Control-Allow-Origin *; \
    } \
}' > /etc/nginx/http.d/default.conf

COPY stream.sh /app/stream.sh
RUN chmod +x /app/stream.sh

EXPOSE 8080

CMD nginx && /bin/bash /app/stream.sh
