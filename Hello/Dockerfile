ARG BUILD_FROM
FROM $BUILD_FROM

# Installer les dépendances
RUN apk add --no-cache nginx nginx-rtmp nginx-mod-rtmp ffmpeg jq net-tools

RUN apk add --no-cache alpine-sdk pcre-dev zlib-dev openssl-dev \
    && wget http://nginx.org/download/nginx-1.22.1.tar.gz \
    && tar -zxvf nginx-1.22.1.tar.gz \
    && git clone https://github.com/arut/nginx-rtmp-module.git \
    && cd nginx-1.22.1 \
    && ./configure --add-module=../nginx-rtmp-module --with-http_ssl_module \
    && make \
    && make install

# Copy data for add-on
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /
RUN chmod a+x /run.sh

# Exposer les ports RTMP et HTTP
EXPOSE 1935 8070

CMD [ "/run.sh" ]