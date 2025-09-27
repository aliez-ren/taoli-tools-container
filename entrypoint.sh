#!/bin/sh
set -eu

export DISPLAY="${DISPLAY:-:1}"
NOVNC_PORT="${NOVNC_PORT:-80}"
VNC_PORT="${VNC_PORT:-5900}"
SCREEN_RESOLUTION="${SCREEN_RESOLUTION:-1504x1024x16}"

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

websockify --web /usr/share/novnc/ 127.0.0.1:"$NOVNC_PORT" 127.0.0.1:"$VNC_PORT" &
WEBSOCKIFY_PID=$!

chromium --display=$DISPLAY --no-default-browser-check --no-first-run --disable-gpu --use-gl=disabled --kiosk --load-extension=/home/taoli/extension --user-data-dir=/home/taoli/data "https://taoli.tools" &
BROWSER_PID=$!

tailscaled --tun=userspace-networking --socket=/home/taoli/tailscale.socket &
TAILSCALED_PID=$!

tailscale --socket=/home/taoli/tailscale.socket up --hostname=taoli-tools-container --qr &
TAILSCALE_PID=$!

wait "$WEBSOCKIFY_PID"
