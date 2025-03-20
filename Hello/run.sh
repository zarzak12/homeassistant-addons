#!/bin/sh

client_id=$(echo -n "ODRlZGRmNDgtMmI4ZS0xMWU1LWIyYTUtMTI0Y2ZhYjI1NTk1XzQ3NWJ1cXJmOHY4a2d3b280Z293MDhna2tjMGNrODA0ODh3bzQ0czhvNDhzZzg0azQw" | base64 -d)
client_secret=$(echo -n "NGRzcWZudGlldTB3Y2t3d280MGt3ODQ4Z3c0bzBjOGs0b3djODBrNGdvMGNzMGs4NDQ=" | base64 -d)

# Charger les paramètres de configuration
oauth_url="https://sso.myfox.io/oauth/oauth/v2/token"
username="$(jq -r .somfy_protect.username /data/options.json)"
password="$(jq -r .somfy_protect.password /data/options.json)"

echo "Client ID: $client_id"
echo "Client Secret: $client_secret"
echo "Username: $username"
echo "Password: $password"

# Obtenir un access_token
echo "Obtenion du token OAuth2..."
response=$(curl -s -X POST "$oauth_url" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=password" \
    -d "client_id=$client_id" \
    -d "client_secret=$client_secret" \
    -d "username=$username" \
    -d "password=$password")

token=$(echo "$response" | jq -r .access_token)
if [ "$token" == "null" ] || [ -z "$token" ]; then
    echo "Échec de l'authentification. Vérifiez vos identifiants."
    exit 1
fi

echo "Token obtenu avec succès."

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
ffmpeg -i "$RTMPS_URL" \
    -c:v libx264 -preset ultrafast -tune zerolatency -threads 4 \
    -c:a aac -b:a 128k -f hls \
    -hls_time 5 -hls_list_size 10 -hls_flags delete_segments \
    -hls_segment_filename "$HLS_PATH/segment_%03d.ts" \
    "$HLS_PATH/index.m3u8" &

# Démarrer Nginx pour servir les fichiers HLS
nginx -g "daemon off;"

# Empêcher le conteneur de se fermer
exec tail -f /dev/null
