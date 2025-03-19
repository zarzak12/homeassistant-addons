#!/bin/sh

# Lire l'URL RTMPS depuis la config
RTMPS_URL=$(jq --raw-output '.rtmps_url_input' /data/options.json)
RTMPS_URL_OUT=$(jq --raw-output '.rtmps_url_output' /data/options.json)

echo "Démarrage du flux RTMPS -> HTTP : $RTMPS_URL"

# Convertir RTMPS en HTTP avec FFmpeg
ffmpeg -i "$RTMPS_URL" -c:v copy -f mjpeg $RTMPS_URL_OUT

echo "HTTP : $RTMPS_URL_OUT"