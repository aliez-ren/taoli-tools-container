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
  novnc

RUN pip3 install --break-system-packages --no-cache-dir websockify

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DISPLAY=:1 \
  NOVNC_PORT=80 \
  VNC_PORT=5900 \
  SCREEN_RESOLUTION=1504x1024x16

RUN chmod +x /usr/local/bin/entrypoint.sh

ADD extension /opt/extension

EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]
