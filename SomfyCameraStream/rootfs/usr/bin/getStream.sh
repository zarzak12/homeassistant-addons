# 🚀 Attendre l'arrivée du flux vidéo
timeout=90
elapsed=0
while true; do
    while [ ! -s /tmp/rtmps_url ]; do
        bashio::log.info "⌛ En attente d'un flux RTMPS..."
        sleep 1
        elapsed=$((elapsed + 1))

        if [ $elapsed -ge $timeout ]; then
            bashio::log.info "📡 Demande de démarrage du flux vidéo /90s..."
            response=$(curl -s -X POST "$STREAM_URL" \
                -H "Authorization: Bearer $token" \
                -H "Content-Type: application/json" \
                -d '{"action": "stream_start"}')
            bashio::log.info "📡 Réponse de l'API : $response"
            elapsed=0
        fi
    done
    sleep 90
    elapsed=0
done &