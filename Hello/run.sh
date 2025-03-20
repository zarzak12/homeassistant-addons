#!/bin/sh

# 🔐 Déchiffrer client_id et client_secret en Base64
client_id=$(echo -n "ODRlZGRmNDgtMmI4ZS0xMWU1LWIyYTUtMTI0Y2ZhYjI1NTk1XzQ3NWJ1cXJmOHY4a2d3b280Z293MDhna2tjMGNrODA0ODh3bzQ0czhvNDhzZzg0azQw" | base64 -d -w 0)
client_secret=$(echo -n "NGRzcWZudGlldTB3Y2t3d280MGt3ODQ4Z3c0bzBjOGs0b3djODBrNGdvMGNzMGs4NDQ=" | base64 -d -w 0)

# 🎯 Charger les paramètres de configuration
oauth_url="https://sso.myfox.io/oauth/oauth/v2/token"
username="$(jq -r .somfy_protect.username /data/options.json)"
password="$(jq -r .somfy_protect.password /data/options.json)"

# 🔑 Obtenir un access_token
echo "📡 Obtention du token OAuth2..."
response=$(curl -s -X POST "$oauth_url" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=password" \
    -d "client_id=$client_id" \
    -d "client_secret=$client_secret" \
    -d "username=$username" \
    -d "password=$password")

token=$(echo "$response" | jq -r .access_token)
if [ "$token" == "null" ] || [ -z "$token" ]; then
    echo "❌ Échec de l'authentification. Vérifiez vos identifiants."
    exit 1
fi

echo "✅ Token obtenu avec succès."

# 🌐 URL du WebSocket
#WS_URL="wss://websocket.myfox.io/events/websocket?token=$token"
WS_URL="wss://websocket.myfox.io/events/websocket?token=YzEzNjUzZjkxODU3MTE1ODI5ZThjOTliYzA4MzRmODY1NDAyZWZiMjhhZTY0YjgwMWI2ZWM1YTFlM2FmOWMwMA"
echo "🔌 Connexion au WebSocket..."

# 🚀 Lancer WebSocket en arrière-plan
websocat "$WS_URL" | while read -r message; do
    echo "📩 Message reçu : $message"

    # 🎥 Vérifier si l'événement est "video.stream.ready"
    if echo "$message" | jq -e '.key == "video.stream.ready"' > /dev/null; then
        RTMPS_URL=$(echo "$message" | jq -r '.stream_url')
        echo "🎥 Flux vidéo prêt : $RTMPS_URL"

        # 📂 Sauvegarder l'URL pour que le reste du script l’utilise
        echo "$RTMPS_URL" > /tmp/rtmps_url
        break  # ✅ Quitte la boucle dès qu'un flux est disponible
    fi
done &  # ⬅️ WebSocket tourne en arrière-plan

# 🕐 Pause pour s'assurer que le WebSocket est bien établi
sleep 2

# 📡 Demander le démarrage du flux vidéo via l'API
SITE_ID="itsYi0aEPEeS5EH6X1BESVQFGDWkfT6T"
DEVICE_ID="x3ZS7P0wwUFjOZ2gXtFyqdUWO8u3LkHK"
STREAM_URL="https://api.myfox.io/v3/site/$SITE_ID/device/$DEVICE_ID/action"

echo "📡 Demande de démarrage du flux vidéo..."
response=$(curl -s -X POST "$STREAM_URL" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d '{"action": "stream_start"}')

echo "📡 Réponse de l'API : $response"


# 🚀 Attendre l'arrivée du flux vidéo
while [ ! -s /tmp/rtmps_url ]; do
    echo "⌛ En attente d'un flux RTMPS..."
    sleep 1
done

# 📥 Lire l'URL RTMPS extraite
RTMPS_URL=$(cat /tmp/rtmps_url)
RTMPS_URL_OUT=$(jq --raw-output '.rtmps_url_output' /data/options.json)
HLS_PATH="/www/hls"

echo "🎯 Flux RTMPS détecté : $RTMPS_URL"

# 🔄 Nettoyer l'ancienne session
rm -rf "$HLS_PATH"
mkdir -p "$HLS_PATH"

# 🎞️ Lancer la conversion RTMPS → HLS
ffmpeg -i "$RTMPS_URL" \
    -c:v libx264 -preset ultrafast -tune zerolatency -threads 4 \
    -c:a aac -b:a 128k -f hls \
    -hls_time 5 -hls_list_size 10 -hls_flags delete_segments \
    -hls_segment_filename "$HLS_PATH/segment_%03d.ts" \
    "$HLS_PATH/index.m3u8" &

# 🖥️ Démarrer Nginx pour diffuser le flux
nginx -g "daemon off;"

# 🚀 Garder le conteneur actif
exec tail -f /dev/null
