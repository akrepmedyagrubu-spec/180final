#!/bin/bash

PLAYLIST_URL="${PLAYLIST_URL:-https://raw.githubusercontent.com/akrepmedyagrubu-spec/180final/refs/heads/main/playlist.txt}"
OUTPUT_DIR="/app/hls"

mkdir -p "$OUTPUT_DIR"

echo "=== Ultra Güvenli IPTV Motoru Baslatiliyor ==="

while true; do
    echo "[$(date '+%H:%M:%S')] Güncel playlist indiriliyor..."
    
    # GitHub'dan playlist'i çek
    curl -sSL "$PLAYLIST_URL" | grep -v '^#' | grep -v '^[[:space:]]*$' | sed "s/'/\\\\'/g" | sed "s/^/file '/" | sed "s/$/'/" > /app/ffmpeg_playlist.txt
    
    if [ ! -s /app/ffmpeg_playlist.txt ]; then
        echo "[HATA] Playlist indirilemedi veya bos! 5 saniye sonra tekrar deneniyor..."
        sleep 5
        continue
    fi

    echo "[$(date '+%H:%M:%S')] FFmpeg (540p 25fps) Baslatiliyor..."
    echo "[GÜVENLİK] Kilitlenmeyi ve siyah ekrani önleyen ag ayarları aktif edildi."
    
    # FFmpeg Ağ, Zaman Aşımı, Kilitlenme ve HLS Yayın Ayarları
    ffmpeg -hide_banner -loglevel warning -re \
        -protocol_whitelist file,http,https,tcp,tls,crypto \
        -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 42 \
        -probesize 10M -analyzeduration 10M -fflags +genpts \
        -f concat -safe 0 \
        -i /app/ffmpeg_playlist.txt \
        -vf "scale=960:540:force_original_aspect_ratio=decrease,pad=960:540:(ow-iw)/2:(oh-ih)/2,fps=25" \
        -c:v libx264 -preset ultrafast -tune zerolatency -crf 28 \
        -pix_fmt yuv420p \
        -g 50 -sc_threshold 0 \
        -c:a aac -b:a 64k -ac 2 -ar 44100 \
        -f hls \
        -hls_time 4 \
        -hls_list_size 5 \
        -hls_flags delete_segments+append_list+omit_endlist \
        -hls_segment_filename "$OUTPUT_DIR/segment_%03d.ts" \
        "$OUTPUT_DIR/live.m3u8"

    echo "[$(date '+%H:%M:%S')] Döngü bitti/koptu. 3 saniye sonra yeniden baslatiliyor..."
    sleep 3
done
