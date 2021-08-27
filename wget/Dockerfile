# alpine:3.13
ARG REPO=microblink/java:17
FROM $REPO AS base
ARG CRUSHFTP_VERSION=10.0.0_44
ENV SOURCE_ZIP=/tmp/crushftp10.zip \
  CRUSHFTP_VERSION=$CRUSHFTP_VERSION

FROM base AS deps
RUN apk upgrade --no-cache \
  && apk --no-cache add bash bash-completion bash-doc ca-certificates curl wget \
  && update-ca-certificates

FROM deps AS source
ENV ORIGIN_SOURCE_ZIP=$SOURCE_ZIP
# source CrushFTP10.zip without java included
ARG SOURCE_ZIP=https://www.crushftp.com/early10/CrushFTP10.zip
ARG CRUSHFTP_VERSION=10.0.0_44
# unzip to destination /tmp/CrushFTP10
WORKDIR /tmp
RUN wget $SOURCE_ZIP \
  && apk --no-cache add zip \
  && unzip -oq /tmp/CrushFTP10.zip
WORKDIR /src/tmp
RUN cd /tmp/CrushFTP10 \
  && zip -qr9 /src${ORIGIN_SOURCE_ZIP} * \
  && date '+%F %T %Z'>/src/tmp/__builddate.txt \
  && echo "CrushFTP Version = $CRUSHFTP_VERSION">>/src/tmp/__version.txt \
  && echo "Build Date Time  = `cat /src/tmp/__builddate.txt`">>/src/tmp/__version.txt \
  && echo "Java             = $JAVA_VERSION">>/src/tmp/__version.txt

FROM source as build
ARG STARTUP=startup.sh
ADD $STARTUP /src/var/opt/startup.sh

FROM deps as final
COPY --from=build /src /
WORKDIR /var/opt
ENTRYPOINT [ "/bin/bash", "startup.sh" ]
CMD ["-c"]

ENV ADMIN_USER=crushadmin \
  ADMIN_PASSWORD= \
  WEB_PROTOCOL=http \
  WEB_PORT=8080

HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl -f ${WEB_PROTOCOL}://localhost:${WEB_PORT}/favivon.ico -H 'Connection: close' || exit 1

ARG CRUSHFTP_VERSION=10.0.0_44
VOLUME [ "/var/opt/crushftp" ]
EXPOSE 21 20000-20100 2222 443 8080 9090
LABEL org.opencontainers.image.authors="https://github.com/NetLah"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/netlah/crushftp"
LABEL org.opencontainers.image.source="https://github.com/NetLah/docker-crushftp"
LABEL org.opencontainers.image.version="$CRUSHFTP_VERSION"
LABEL org.opencontainers.image.description="CrushFTP 10 server on Alpine Linux 3.13 and OpenJDK 17."
