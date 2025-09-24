#!/bin/sh
set -eu

export DISPLAY="${DISPLAY:-:1}"
NOVNC_PORT="${NOVNC_PORT:-80}"
VNC_PORT="${VNC_PORT:-5900}"
SCREEN_RESOLUTION="${SCREEN_RESOLUTION:-1504x1024x8}"

XVFB_PID=""
OPENBOX_PID=""
X11VNC_PID=""
WEBSOCKIFY_PID=""

cleanup() {
  for pid in "$WEBSOCKIFY_PID" "$X11VNC_PID" "$OPENBOX_PID" "$XVFB_PID"; do
    if [ -n "$pid" ]; then
      kill "$pid" 2>/dev/null || true
    fi
  done
}
trap cleanup INT TERM

Xvfb "$DISPLAY" -screen 0 "$SCREEN_RESOLUTION" &
XVFB_PID=$!

# Give Xvfb a moment to initialise before starting clients
sleep 2

openbox-session &
OPENBOX_PID=$!

x11vnc -display "$DISPLAY" -forever -shared -nopw -rfbport "$VNC_PORT" -listen 0.0.0.0 &
X11VNC_PID=$!

websockify --web /usr/share/novnc/ 0.0.0.0:"$NOVNC_PORT" 127.0.0.1:"$VNC_PORT" &
WEBSOCKIFY_PID=$!

wait "$WEBSOCKIFY_PID"
