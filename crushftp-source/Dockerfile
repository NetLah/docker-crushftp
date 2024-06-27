# alpine:3.19.1
# buildargs: REPO=alpine:3.19.1 CRUSHFTP_VERSION=11.2.0_5 SOURCE_METHOD=wget or add SOURCE_ZIP=https://www.crushftp.com/early11/CrushFTP11.zip
ARG REPO=alpine:3.19.1
ARG SOURCE_METHOD=wget

FROM $REPO AS base

FROM base AS base-source
RUN apk upgrade --no-cache \
  && apk --no-cache add ca-certificates curl wget zip
WORKDIR /tmp

FROM base-source AS source-wget
# source CrushFTP11.zip without java included
ARG SOURCE_ZIP=https://www.crushftp.com/early11/CrushFTP11.zip
ARG CRUSHFTP_VER=CrushFTP11
RUN wget -q -O ${CRUSHFTP_VER}.zip $SOURCE_ZIP

FROM base-source AS source-add
# source CrushFTP11.zip without java included
ARG SOURCE_ZIP=https://www.crushftp.com/early11/CrushFTP11.zip
ARG CRUSHFTP_VER=CrushFTP11
ADD $SOURCE_ZIP ${CRUSHFTP_VER}.zip

FROM source-$SOURCE_METHOD AS zip
# unzip to destination /tmp/CrushFTP11
ARG CRUSHFTP_VER=CrushFTP11
RUN unzip -oq ${CRUSHFTP_VER}.zip
# create folder /src if not exist
WORKDIR /src
RUN cd /tmp/CRUSHFTP_VER \
  && zip -qr9 /src/crushftp.zip * \
  && date '+%F %T %z'>/src/__builddate.txt

FROM base as final
WORKDIR /src
COPY --from=zip /src .

ARG CRUSHFTP_VERSION=11.2.0_5
ENV CRUSHFTP_VERSION=$CRUSHFTP_VERSION
LABEL org.opencontainers.image.authors="https://github.com/NetLah"\
  org.opencontainers.image.url="https://hub.docker.com/r/netlah/crushftp-source"\
  org.opencontainers.image.source="https://github.com/NetLah/docker-crushftp"\
  org.opencontainers.image.description="Intermediate docker image for crushftp.zip."\
  org.opencontainers.image.version="$CRUSHFTP_VERSION"\
  version="$CRUSHFTP_VERSION"
