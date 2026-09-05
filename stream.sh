#!/bin/bash

PLAYLIST_URL="${PLAYLIST_URL:-https://raw.githubusercontent.com/akrepmedyagrubu-spec/180final/refs/heads/main/playlist.txt}"
OUTPUT_DIR="/app/hls"

mkdir -p "$OUTPUT_DIR"

echo "=== Hızlı IPTV Stream Motoru Başlatılıyor ==="

while true; do
    echo "[$(date '+%H:%M:%S')] Playlist güncelleniyor..."
    
    # GitHub'dan playlist'i çek
    curl -sSL "$PLAYLIST_URL" | grep -v '^#' | grep -v '^[[:space:]]*$' | sed "s/'/\\\\'/g" | sed "s/^/file '/" | sed "s/$/'/" > /app/ffmpeg_playlist.txt
    
    if [ ! -s /app/ffmpeg_playlist.txt ]; then
        echo "[HATA] Playlist boş! 5 saniye sonra tekrar deneniyor..."
        sleep 5
        continue
    fi

    echo "[$(date '+%H:%M:%S')] FFmpeg Yayını (Sıfır CPU Yükü) Başlatılıyor..."
    
    # -c copy ile işlemciyi hiç yormadan akıcı yayın yapılır
    ffmpeg -hide_banner -loglevel warning -re \
        -protocol_whitelist file,http,https,tcp,tls,crypto \
        -f concat -safe 0 \
        -i /app/ffmpeg_playlist.txt \
        -c:v copy \
        -c:a copy \
        -f hls \
        -hls_time 4 \
        -hls_list_size 5 \
        -hls_flags delete_segments+append_list+omit_endlist \
        -hls_segment_filename "$OUTPUT_DIR/segment_%03d.ts" \
        "$OUTPUT_DIR/live.m3u8"

    echo "[$(date '+%H:%M:%S')] Döngü bitti. 3 saniye sonra yenileniyor..."
    sleep 3
done
