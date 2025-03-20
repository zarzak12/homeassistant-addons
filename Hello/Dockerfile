ARG BUILD_FROM
FROM $BUILD_FROM

# Installer les dépendances
RUN apk add --no-cache nginx nginx-mod-rtmp ffmpeg jq net-tools

# Copy data for add-on
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /
RUN chmod a+x /run.sh

# Exposer les ports RTMP et HTTP
EXPOSE 1935 8070

CMD [ "/run.sh" ]