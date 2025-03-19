FROM ghcr.io/home-assistant/amd64-base:latest

# Installer FFmpeg
RUN apk add --no-cache ffmpeg

# Copier le script de démarrage
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
