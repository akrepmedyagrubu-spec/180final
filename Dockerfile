FROM alpine:latest

RUN apk add --no-cache ffmpeg bash curl

WORKDIR /app

# Bütün dosyaları tek repodan kopyala
COPY stream.sh /app/stream.sh
COPY playlist.txt /app/playlist.txt
RUN chmod +x /app/stream.sh && mkdir -p /app/hls

VOLUME /app/hls

CMD ["/bin/bash", "/app/stream.sh"]
