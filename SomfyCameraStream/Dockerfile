# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM

# SomfyCameraStream version
ARG VERSION=1.0.0

# Copy root filesystem
COPY rootfs /

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
   python3-dev \
   yq

COPY nginx.conf /etc/nginx/nginx.conf

# Download source and untar
#WORKDIR /usr/bin
#ADD "https://github.com/zarzak12/SomfyCameraStream/archive/refs/tags/${VERSION}.tar.gz" ${VERSION}.tar.gz
#RUN tar -xvf ${VERSION}.tar.gz && mv /usr/bin/SomfyCameraStream-${VERSION} /usr/bin/SomfyCameraStream

# Install python3 requirements
#WORKDIR /usr/bin/SomfyCameraStream
#RUN pip3 install --no-cache-dir -r requirements/addon.txt

# Exposer les ports HTTP pour HLS
EXPOSE 7080