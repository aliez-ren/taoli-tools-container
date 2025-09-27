#!/bin/sh
set -eu

XVFB_PID=""
OPENBOX_PID=""
X11VNC_PID=""
WEBSOCKIFY_PID=""
BROWSER_PID=""
TAILSCALED_PID=""
TAILSCALE_PID=""

cleanup() {
  for pid in "$TAILSCALE_PID" "$TAILSCALED_PID" "$BROWSER_PID" "$WEBSOCKIFY_PID" "$X11VNC_PID" "$OPENBOX_PID" "$XVFB_PID"; do
    if [ -n "$pid" ]; then
      kill "$pid" 2>/dev/null || true
    fi
  done
}
trap cleanup INT TERM

Xvfb "$DISPLAY" -screen 0 "$SCREEN_RESOLUTION" &
XVFB_PID=$!

sleep 2

openbox-session &
OPENBOX_PID=$!

x11vnc -display "$DISPLAY" -forever -shared -nopw -repeat -xkb -rfbport "$VNC_PORT" -listen 127.0.0.1 &
X11VNC_PID=$!

cd $HOME
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -subj /CN=localhost -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1' -out CERT.pem -keyout KEY.pem
websockify --web /usr/share/novnc/ --cert CERT.pem --key KEY.pem 127.0.0.1:"$NOVNC_PORT" 127.0.0.1:"$VNC_PORT" &
WEBSOCKIFY_PID=$!

chromium --display=$DISPLAY --no-default-browser-check --no-first-run --disable-gpu --use-gl=disabled --kiosk --load-extension=/home/taoli/extension --user-data-dir=$HOME/data "https://taoli.tools" &
BROWSER_PID=$!

tailscaled --tun=userspace-networking --socket=/home/taoli/tailscale.socket &
TAILSCALED_PID=$!

tailscale --socket=/home/taoli/tailscale.socket up --hostname=taoli-tools-container --qr &
TAILSCALE_PID=$!

wait "$WEBSOCKIFY_PID"
