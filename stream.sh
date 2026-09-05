#!/bin/bash

# Aynı repodaki playlist.txt'nin RAW linkini buraya yapıştır
PLAYLIST_URL="${PLAYLIST_URL:-https://github.com/akrepmedyagrubu-spec/180final/blob/main/playlist.txt}"
OUTPUT_DIR="/app/hls"

mkdir -p "$OUTPUT_DIR"

echo "=== IPTV Motoru Baslatiliyor ==="

while true; do
    echo "Playlist güncelleniyor..."
    curl -sSL "$PLAYLIST_URL" | grep -v '^#' | grep -v '^[[:space:]]*$' | sed "s/'/\\\\'/g" | sed "s/^/file '/" | sed "s/$/'/" > /app/ffmpeg_playlist.txt
    
    if [ ! -s /app/ffmpeg_playlist.txt ]; then
        echo "[HATA] Playlist boş! 10 saniye sonra tekrar deneniyor..."
        sleep 10
        continue
    fi

    echo "FFmpeg yayını başlatılıyor..."
    ffmpeg -hide_banner -loglevel warning -re \
        -f concat -safe 0 -protocol_whitelist file,http,https,tcp,tls,crypto \
        -i /app/ffmpeg_playlist.txt \
        -c:v libx264 -preset ultrafast -tune zerolatency \
        -g 60 -sc_threshold 0 \
        -c:a aac -b:a 128k -ac 2 -ar 44100 \
        -f hls \
        -hls_time 4 \
        -hls_list_size 6 \
        -hls_flags delete_segments+append_list+omit_endlist \
        -hls_segment_filename "$OUTPUT_DIR/segment_%03d.ts" \
        "$OUTPUT_DIR/live.m3u8"

    echo "Döngü bitti, yenileniyor..."
    sleep 3
done
