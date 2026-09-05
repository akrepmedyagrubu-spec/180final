FROM alpine:latest

# FFmpeg, bash, curl ve Nginx yükle
RUN apk add --no-cache ffmpeg bash curl nginx

WORKDIR /app

# Nginx konfigürasyonu
RUN mkdir -p /run/nginx /app/hls
RUN echo 'server { \
    listen 8080; \
    location / { \
        root /app; \
        add_header Access-Control-Allow-Origin *; \
    } \
}' > /etc/nginx/http.d/default.conf

COPY stream.sh /app/stream.sh
RUN chmod +x /app/stream.sh

EXPOSE 8080

# Hem Nginx hem de stream.sh betiğini aynı anda başlat
CMD nginx && /bin/bash /app/stream.sh
