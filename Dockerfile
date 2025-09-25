FROM alpine:3.19

RUN apk add --no-cache \
  openbox \
  x11vnc \
  xvfb \
  firefox \
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

ADD profile/policies.json /usr/lib/firefox/distribution/
ADD profile/user.js /opt/taoli-tools/
ADD cors-relaxer.xpi /opt/

EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]
