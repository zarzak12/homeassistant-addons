#!/bin/sh

# Lire les paramètres depuis Home Assistant
RTMPS_URL=$(jq --raw-output '.rtmps_url_input' /data/options.json)
RTMPS_URL_OUT=$(jq --raw-output '.rtmps_url_output' /data/options.json)
HLS_PATH="/www/hls"

echo "Input : $RTMPS_URL"

# Nettoyer l'URL RTMPS pour enlever les caractères d'échappement
RTMPS_URL=$(echo "$RTMPS_URL" | sed 's|\\||g')

echo "Démarrage du flux RTMPS -> HTTP : $RTMPS_URL"

# Vérifier que l'URL RTMPS est bien définie
if [ -z "$RTMPS_URL" ]; then
    echo "Erreur : L'URL RTMPS n'est pas définie"
    exit 1
fi

# Vérifier si le port 8070 est libre
if netstat -tulnp | grep ":7080"; then
    echo "Attention : Le port 7080 est déjà utilisé, vérifiez qu'il est bien libre."
fi

# Vérifier que NGINX RTMP fonctionne
echo "Démarrage du serveur RTMP..."
nginx

# Arrêter les anciens processus FFmpeg
pkill -f "ffmpeg"

echo "RTMPS Input: $RTMPS_URL"
echo "HLS Output Path: $HLS_PATH"

# Vérifier si l'URL RTMPS est bien définie
if [ -z "$RTMPS_URL" ]; then
    echo "Erreur : L'URL RTMPS n'est pas définie"
    exit 1
fi

# Nettoyer l'ancienne session
rm -rf "$HLS_PATH"
mkdir -p "$HLS_PATH"

# Lancer la conversion avec FFmpeg
ffmpeg -re -i "$RTMPS_URL" \
    -c:v copy -c:a aac -b:a 128k -f hls \
    -hls_time 5 -hls_list_size 10 -hls_flags delete_segments \
    -hls_segment_filename "$HLS_PATH/segment_%03d.ts" \
    "$HLS_PATH/index.m3u8" &

# Démarrer Nginx pour servir les fichiers HLS
nginx -g "daemon off;"

# Empêcher le conteneur de se fermer
exec tail -f /dev/null
