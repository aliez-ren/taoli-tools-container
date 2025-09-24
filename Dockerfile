# syntax=docker/dockerfile:1.5
FROM --platform=linux/amd64 debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

ARG RUSTDESK_VERSION=1.4.2
ARG RUSTDESK_SERVER_VERSION=1.1.14

ADD https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VERSION}/rustdesk-${RUSTDESK_VERSION}-x86_64.deb /tmp/rustdesk.deb
ADD https://github.com/rustdesk/rustdesk-server/releases/download/${RUSTDESK_SERVER_VERSION}/rustdesk-server-hbbs_${RUSTDESK_SERVER_VERSION}_amd64.deb /tmp/hbbs.deb
ADD https://github.com/rustdesk/rustdesk-server/releases/download/${RUSTDESK_SERVER_VERSION}/rustdesk-server-hbbr_${RUSTDESK_SERVER_VERSION}_amd64.deb /tmp/hbbr.deb

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      chromium \
      openbox \
      xserver-xorg-core \
      xserver-xorg-video-dummy \
      xserver-xorg-input-libinput \
      x11-xserver-utils \
      dbus \
      dbus-x11 \
      fontconfig \
      fonts-dejavu \
      libasound2 \
      libnss3 \
      libxss1 \
      xdg-utils \
      python3-xdg \
      procps \
      ca-certificates \
      curl \
      unzip \
      wget \
 && cd /tmp \
 && apt-get install -y ./rustdesk.deb ./hbbs.deb ./hbbr.deb \
 && rm -rf /var/lib/apt/lists/* /tmp/*.deb

RUN useradd --create-home --shell /bin/bash app \
 && mkdir -p /run/dbus /run/lock

ADD docker/entrypoint.sh /usr/local/bin/entrypoint.sh
ADD docker/xorg.conf /etc/X11/xorg.conf

RUN chmod +x /usr/local/bin/entrypoint.sh \
 && chown app:app /usr/local/bin/entrypoint.sh

USER root
WORKDIR /home/app

ENV RUSTDESK_ID_SERVER=127.0.0.1 \
    RUSTDESK_RELAY_SERVER=127.0.0.1:21117 \
    RUSTDESK_API_SERVER=http://127.0.0.1:21114

EXPOSE 21114 21115 21116 21117 21118

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
