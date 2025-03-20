ARG BUILD_FROM
FROM $BUILD_FROM

# Installer les dépendances
RUN apk add --no-cache ffmpeg nginx jq python3 py3-pip \
   python3-dev musl-dev libffi-dev openssl-dev cargo gcc g++ make

# Installer les dépendances Python requises
RUN pip3 install --no-cache-dir \
    aiohttp \
    websockets

# Copier les fichiers nécessaires
COPY run.sh /run.sh
COPY websocket_listener.py srcipts/websocket_listener.py
COPY nginx.conf /etc/nginx/nginx.conf
RUN chmod a+x /run.sh
RUN chmod a+x srcipts/websocket_listener.py

# Exposer les ports HTTP pour HLS
EXPOSE 7080

# Lancer le script au démarrage
CMD [ "/run.sh" ]
