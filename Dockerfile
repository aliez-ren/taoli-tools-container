FROM alpine:3.19

RUN apk add --no-cache \
  openbox \
  chromium \
  python3 \
  py3-xdg \
  font-noto \
  font-noto-cjk \
  ca-certificates \
  libcap-utils \
  xdpyinfo \
  perl \
  perl-datetime \
  perl-datetime-timezone \
  perl-list-moreutils \
  perl-try-tiny \
  perl-yaml-tiny \
  perl-switch \
  perl-hash-merge-simple \
  mcookie \
  setxkbmap \
  xauth \
  xkbcomp \
  xkeyboard-config \
  xterm \
  mesa-gbm \
  mesa-gl \
  mesa-dri-gallium \
  libwebp \
  libjpeg-turbo \
  libxshmfence \
  libxtst \
  libxfont2 \
  libx11 \
  libxau \
  libxdmcp \
  libxcb \
  libxrender \
  libxfixes \
  libxdamage \
  libxcursor \
  libxi \
  libxinerama \
  libxcomposite \
  pixman \
  libgomp \
  libstdc++ \
  libxrandr \
  libpng \
  libdrm \
  openssl \
  pciutils-libs

ARG KASMVNC_VERSION="1.3.4"
ARG KASMVNC_APK="kasmvncserver_alpine_319_${KASMVNC_VERSION}_aarch64.apk"
RUN set -eux; \
  wget -O /tmp/kasmvnc.apk "https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/${KASMVNC_APK}"; \
  mkdir -p /tmp/kasmvnc; \
  tar -xzf /tmp/kasmvnc.apk -C /tmp/kasmvnc; \
  cp -a /tmp/kasmvnc/etc /tmp/kasmvnc/usr /; \
  if [ -f /tmp/kasmvnc/.post-install ]; then \
  sh /tmp/kasmvnc/.post-install; \
  fi; \
  rm -rf /tmp/kasmvnc /tmp/kasmvnc.apk

RUN addgroup -S taoli && adduser -S -G taoli -h /home/taoli -s /bin/sh taoli
RUN adduser taoli kasmvnc-cert

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DISPLAY=:1 \
  KASMVNC_PORT=80 \
  SCREEN_RESOLUTION=1504x1024x16 \
  KASMVNC_USER=kasm_user \
  KASMVNC_PASSWORD=password \
  TARGET_URL=https://taoli.tools

RUN chmod +x /usr/local/bin/entrypoint.sh

ADD --chown=taoli:taoli extension /home/taoli/extension

COPY config/kasmvnc.yaml /etc/kasmvnc/kasmvnc.yaml

RUN set -eux; \
  mkdir -p /home/taoli; \
  chown -R taoli:taoli /home/taoli; \
  mkdir -p /home/taoli/taoli-tools; \
  chown -R taoli:taoli /home/taoli/taoli-tools; \
  mkdir -p /home/taoli/.vnc; \
  chown -R taoli:taoli /home/taoli/.vnc; \
  for bin in /usr/bin/Xkasmvnc /usr/bin/kasmxproxy; do \
  if [ -x "$bin" ]; then \
  setcap 'cap_net_bind_service=+ep' "$bin"; \
  fi; \
  done

EXPOSE 80

USER taoli

CMD ["/usr/local/bin/entrypoint.sh"]
