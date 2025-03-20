ARG BUILD_FROM
FROM $BUILD_FROM

# Installer les dépendances
RUN apk update && apk add --no-cache ffmpeg nginx jq python3 py3-pip \
   ffmpeg-dev \
   libjxl \
   libjxl-tools \
   libsrtp \
   libsrtp-dev \
   libvpx \
   libvpx-dev \
   linux-headers \
   opus \
   opus-dev \
   py3-opencv \
   python3 \
   python3-dev \
   yq

COPY nginx.conf /etc/nginx/nginx.conf



WORKDIR /usr/bin

COPY requirements/addon.txt /requirements/addon.txt

# Copier les fichiers nécessaires
COPY run.sh /run.sh
COPY websocket_listener.py srcipts/websocket_listener.py

RUN chmod a+x /run.sh
RUN chmod a+x srcipts/websocket_listener.py

# Installer les dépendances Python requises
RUN pip3 install --no-cache-dir -r requirements/addon.txt

# Exposer les ports HTTP pour HLS
EXPOSE 7080

# Lancer le script au démarrage
CMD [ "/run.sh" ]
