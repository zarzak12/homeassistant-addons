#!/bin/sh

# Lire les paramètres depuis Home Assistant
RTMPS_URL=$(jq --raw-output '.rtmps_url_input' /data/options.json)
RTMPS_URL_OUT=$(jq --raw-output '.rtmps_url_output' /data/options.json)

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
if netstat -tulnp | grep ":8070"; then
    echo "Attention : Le port 8070 est déjà utilisé, vérifiez qu'il est bien libre."
fi

# Lancer FFmpeg et rediriger les logs vers stdout pour Home Assistant
ffmpeg -re -loglevel debug -i "$RTMPS_URL" \
    -an -vf "format=yuvj422p" \
    -f mjpeg "$RTMPS_URL_OUT.feed.mjpeg" 2>&1 | tee /dev/stdout

mjpg_streamer -i "input_file.so -f /tmp -n feed.mjpeg" -o "output_http.so -w /usr/share/mjpg-streamer/www -p 8070" &


echo "HTTP disponible à : $RTMPS_URL_OUT.feed.mjpeg"

# Empêcher le conteneur de se fermer
exec tail -f /dev/null
