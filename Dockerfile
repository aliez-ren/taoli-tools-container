# syntax=docker/dockerfile:1.5
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

ARG RUSTDESK_VERSION=1.4.2

# ADD https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VERSION}/rustdesk-${RUSTDESK_VERSION}-x86_64.deb /tmp/rustdesk.deb
ADD https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VERSION}/rustdesk-${RUSTDESK_VERSION}-aarch64.deb /tmp/rustdesk.deb

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
  && apt-get install -y ./rustdesk.deb \
  && rm -rf /var/lib/apt/lists/* /tmp/*.deb

RUN useradd --create-home --shell /bin/bash app \
  && mkdir -p /run/dbus /run/lock

ADD docker/entrypoint.sh /usr/local/bin/entrypoint.sh
ADD docker/xorg.conf /etc/X11/xorg.conf

RUN chmod +x /usr/local/bin/entrypoint.sh \
  && chown app:app /usr/local/bin/entrypoint.sh

USER root
WORKDIR /home/app

ENV RUSTDESK_ID_SERVER=hbbs \
  RUSTDESK_RELAY_SERVER=hbbr:21117 \
  RUSTDESK_API_SERVER=http://hbbs:21114

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
