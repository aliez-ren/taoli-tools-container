FROM alpine:3.22.1

RUN apk add --no-cache \
  fluxbox \
  tigervnc \
  chromium \
  python3 \
  py3-pip \
  py3-xdg \
  ca-certificates \
  openssl \
  novnc \
  tailscale

RUN pip3 install --break-system-packages --no-cache-dir websockify

RUN addgroup -S taoli && adduser -S -G taoli -h /home/taoli -s /bin/sh taoli

ADD entrypoint.sh /usr/local/bin/entrypoint.sh

ADD favicon.ico /usr/share/novnc/
ADD index.html /usr/share/novnc/

ENV DISPLAY=:1 \
  NOVNC_PORT=443 \
  VNC_PORT=5900

RUN chmod +x /usr/local/bin/entrypoint.sh

ADD --chown=taoli:taoli extension /home/taoli/extension

RUN set -eux; \
  mkdir -p /home/taoli; \
  chown -R taoli:taoli /home/taoli; \
  mkdir -p /home/taoli/data; \
  chown -R taoli:taoli /home/taoli/data;

USER taoli

CMD ["/usr/local/bin/entrypoint.sh"]
