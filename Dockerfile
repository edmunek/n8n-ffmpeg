ARG N8N_IMAGE=n8nio/n8n
ARG N8N_VERSION=latest
ARG ALPINE_VERSION=3.22

# apk jest wyciety z obrazu n8n - pozyczamy go z czystego Alpine
FROM alpine:${ALPINE_VERSION} AS apkdonor

FROM ${N8N_IMAGE}:${N8N_VERSION}

USER root

ARG FF_BASE=https://github.com/eugeneware/ffmpeg-static/releases/download/b6.0

RUN wget -q "${FF_BASE}/ffmpeg-linux-arm64"  -O /usr/local/bin/ffmpeg  \
 && wget -q "${FF_BASE}/ffprobe-linux-arm64" -O /usr/local/bin/ffprobe \
 && chmod +x /usr/local/bin/ffmpeg /usr/local/bin/ffprobe \
 && /usr/local/bin/ffmpeg  -version > /dev/null \
 && /usr/local/bin/ffprobe -version > /dev/null

COPY --from=apkdonor /sbin/apk /sbin/apk
COPY --from=apkdonor /usr/lib/libapk.so* /usr/lib/
COPY --from=apkdonor /etc/apk/keys /etc/apk/keys

# apk usuwany w tej samej warstwie - nie zostaje w gotowym obrazie
RUN apk add --no-cache imagemagick imagemagick-jpeg imagemagick-webp imagemagick-heic imagemagick-tiff \
 && rm -f /sbin/apk /usr/lib/libapk.so*

USER node
