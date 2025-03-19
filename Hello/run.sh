#!/bin/sh

# Lire l'URL RTMPS depuis la config
RTMPS_URL=$(jq --raw-output '.rtmps_url' /data/options.json)

echo "Démarrage du flux RTMPS -> HTTP : $RTMPS_URL"

# Convertir RTMPS en HTTP avec FFmpeg
ffmpeg -i "$RTMPS_URL" -c:v copy -f mjpeg http://172.17.0.1:8080/feed.mjpeg

echo "HTTP : http://172.17.0.1:8080/feed.mjpeg"