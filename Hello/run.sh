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

# Lancer FFmpeg avec des paramètres plus stables
ffmpeg -re -i "$RTMPS_URL" -an -vf "format=yuvj422p" -f mjpeg "$RTMPS_URL_OUT" &

# Afficher l'URL de sortie
echo "HTTP disponible à : $RTMPS_URL_OUT"
