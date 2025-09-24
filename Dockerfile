# syntax=docker/dockerfile:1
FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  chromium \
  xvfb \
  x11vnc \
  fluxbox \
  x11-utils \
  ca-certificates \
  dbus-x11 \
  novnc \
  python3-websockify \
  tini \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash chromium

ADD docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV DISPLAY=:0 \
  VNC_PORT=5900 \
  NOVNC_PORT=80 \
  XVFB_WHD=1920x1080x24 \
  CHROMIUM_FLAGS="--start-maximized"
EXPOSE 80

USER chromium
WORKDIR /home/chromium

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
