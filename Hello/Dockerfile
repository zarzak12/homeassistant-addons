ARG BUILD_FROM
FROM $BUILD_FROM

# Installer FFmpeg
RUN apk add --no-cache ffmpeg

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]