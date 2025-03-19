#!/bin/sh

# Lire l'URL RTMPS depuis la config
RTMPS_URL=$(jq --raw-output '.rtmps_url_input' /data/options.json)
RTMPS_URL_OUT=$(jq --raw-output '.rtmps_url_output' /data/options.json)

echo "Démarrage du flux RTMPS -> HTTP : $RTMPS_URL"

# Vérifier si l'URL est bien définie
if [ -z "$RTMPS_URL" ]; then
    echo "Erreur : L'URL RTMPS n'est pas définie"
    exit 1
fi

# Lancer FFmpeg en arrière-plan
ffmpeg -re -i "$RTMPS_URL" \
    -an -vf "format=yuvj422p" \
    -f mjpeg "$RTMPS_URL_OUT" > /dev/null 2>&1 &

echo "HTTP disponible à : $RTMPS_URL_OUT"

# Empêcher le conteneur de se fermer immédiatement
exec tail -f /dev/null
