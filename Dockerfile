FROM alpine:3.19

RUN apk add --no-cache \
  openbox \
  x11vnc \
  xvfb \
  chromium \
  python3 \
  py3-pip \
  py3-xdg \
  font-noto \
  font-noto-cjk \
  ca-certificates \
  novnc \
  libcap

RUN pip3 install --break-system-packages --no-cache-dir websockify

RUN addgroup -S taoli && adduser -S -G taoli -h /home/taoli -s /bin/sh taoli

ADD entrypoint.sh /usr/local/bin/entrypoint.sh

ADD favicon.ico /usr/share/novnc/
ADD index.html /usr/share/novnc/

ENV DISPLAY=:1 \
  NOVNC_PORT=80 \
  VNC_PORT=5900 \
  SCREEN_RESOLUTION=1504x1024x16

RUN chmod +x /usr/local/bin/entrypoint.sh

ADD --chown=taoli:taoli extension /home/taoli/extension

RUN set -eux; \
  mkdir -p /home/taoli; \
  chown -R taoli:taoli /home/taoli; \
  mkdir -p /home/taoli/taoli-tools; \
  chown -R taoli:taoli /home/taoli/taoli-tools; \
  PYTHON_BIN="$(python3 -c 'import os, sys; print(os.path.realpath(sys.executable))')"; \
  setcap 'cap_net_bind_service=+ep' "$PYTHON_BIN"

EXPOSE 80

USER taoli

CMD ["/usr/local/bin/entrypoint.sh"]
