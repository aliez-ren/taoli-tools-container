#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=${DISPLAY:-:0}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/xdg-runtime}
export DBUS_SYSTEM_BUS_ADDRESS=${DBUS_SYSTEM_BUS_ADDRESS:-unix:path=/run/dbus/system_bus_socket}
export RUSTDESK_ID_SERVER=${RUSTDESK_ID_SERVER:-127.0.0.1}
export RUSTDESK_RELAY_SERVER=${RUSTDESK_RELAY_SERVER:-127.0.0.1:21117}
export RUSTDESK_API_SERVER=${RUSTDESK_API_SERVER:-http://127.0.0.1:21114}
export RELAY_SERVERS=${RELAY_SERVERS:-$RUSTDESK_RELAY_SERVER}

mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
chown app:app "$XDG_RUNTIME_DIR"

rm -f /tmp/.X0-lock || true

if ! pgrep -x dbus-daemon >/dev/null 2>&1; then
  dbus-daemon --system --fork
fi

Xorg "$DISPLAY" -config /etc/X11/xorg.conf -noreset -nolisten tcp &
XORG_PID=$!

for _ in {1..20}; do
  if DISPLAY=$DISPLAY timeout 1s xdpyinfo >/dev/null 2>&1; then
    break
  fi
  sleep 0.5
done

runuser -u app -- env DISPLAY=$DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR openbox-session &
OPENBOX_PID=$!

runuser -u app -- mkdir -p /home/app/.config/rustdesk

hbbs &
HBBS_PID=$!

hbbr &
HBBR_PID=$!

runuser -u app -- env DISPLAY=$DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  RUSTDESK_ID_SERVER=$RUSTDESK_ID_SERVER \
  RUSTDESK_RELAY=$RUSTDESK_RELAY_SERVER \
  RUSTDESK_API=$RUSTDESK_API_SERVER \
  rustdesk --service &
RUSTDESK_PID=$!

runuser -u app -- env DISPLAY=$DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  chromium --disable-dev-shm-usage --disable-gpu --disable-web-security --user-data-dir="$HOME/Taoli Tools" &
CHROMIUM_PID=$!

pids=($XORG_PID $OPENBOX_PID $HBBS_PID $HBBR_PID $RUSTDESK_PID $CHROMIUM_PID)

cleanup() {
  for pid in "${pids[@]}"; do
    if kill -0 "$pid" >/dev/null 2>&1; then
      kill "$pid" >/dev/null 2>&1 || true
    fi
  done
  wait 2>/dev/null || true
}

trap cleanup EXIT TERM INT

wait -n
