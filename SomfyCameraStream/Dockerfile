ARG BUILD_FROM=ghcr.io/hassio-addons/base:17.2.2
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Copy root filesystem
COPY rootfs /

# Télécharger et installer MediaMTX
RUN wget -O /usr/bin/mediamtx https://github.com/bluenviron/mediamtx/releases/latest/download/mediamtx_linux_amd64 \
    && chmod +x /usr/bin/mediamtx

# Setup base
RUN apk add --no-cache \
    coreutils=9.5-r2 \
    wget=1.25.0-r0 \
    ffmpeg jq \
    jq python3 py3-pip \
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
    nginx \
    supervisor \
    yq websocketd websocat

# Créer un environnement virtuel Python
RUN python3 -m venv /opt/venv

# Activer le venv et installer les dépendances
RUN /opt/venv/bin/pip install --no-cache-dir websockets aiohttp

# Définir le venv comme environnement par défaut
ENV PATH="/opt/venv/bin:$PATH"

# Copier la configuration Nginx et Supervisord
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY mediamtx.conf /etc/mediamtx/mediamtx.yml

# Exposer le port utilisé par Nginx pour l'Ingress
EXPOSE 80

# Commande de démarrage : Supervisord lance Nginx et ton application
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
#LABEL \
#    io.hass.name="${BUILD_NAME}" \
#    io.hass.description="${BUILD_DESCRIPTION}" \
#    io.hass.arch="${BUILD_ARCH}" \
#    io.hass.type="addon" \
#    io.hass.version=${BUILD_VERSION} \
#    maintainer="Franck Nijhof <frenck@addons.community>" \
#    org.opencontainers.image.title="${BUILD_NAME}" \
#    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
#    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
#    org.opencontainers.image.authors="Zarzak \
#    org.opencontainers.image.licenses="MIT" \
#    org.opencontainers.image.url="https://addons.community" \
#    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
#    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
#    org.opencontainers.image.created=${BUILD_DATE} \
#    org.opencontainers.image.revision=${BUILD_REF} \
#    org.opencontainers.image.version=${BUILD_VERSION}
