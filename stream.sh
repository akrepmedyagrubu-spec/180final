#!/bin/bash

PLAYLIST_URL="${PLAYLIST_URL:-https://raw.githubusercontent.com/akrepmedyagrubu-spec/180final/refs/heads/main/playlist.txt}"
OUTPUT_DIR="/app/hls"

mkdir -p "$OUTPUT_DIR"

while true; do
    curl -sSL "$PLAYLIST_URL" | grep -v '^#' | grep -v '^[[:space:]]*$' | sed "s/'/\\\\'/g" | sed "s/^/file '/" | sed "s/$/'/" > /app/ffmpeg_playlist.txt
    
    if [ ! -s /app/ffmpeg_playlist.txt ]; then
        sleep 5
        continue
    fi

    # En düşük CPU kullanımı: 480p, Ultrafast, Ultrafast Tune, Low Bitrate
    ffmpeg -hide_banner -loglevel warning -re \
        -protocol_whitelist file,http,https,tcp,tls,crypto \
        -f concat -safe 0 \
        -i /app/ffmpeg_playlist.txt \
        -vf "scale=854:480,fps=20" \
        -c:v libx264 -preset ultrafast -tune zerolatency -crf 32 \
        -c:a aac -b:a 48k -ac 1 -ar 22050 \
        -f hls \
        -hls_time 2 \
        -hls_list_size 10 \
        -hls_flags delete_segments+omit_endlist \
        -hls_segment_filename "$OUTPUT_DIR/segment_%03d.ts" \
        "$OUTPUT_DIR/live.m3u8"

    sleep 2
done
