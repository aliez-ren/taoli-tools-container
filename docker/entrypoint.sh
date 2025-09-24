#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=${DISPLAY:-:0}
export VNC_PORT=${VNC_PORT:-5900}
export NOVNC_PORT=${NOVNC_PORT:-80}
export XVFB_WHD=${XVFB_WHD:-1920x1080x24}

IFS=x read -r XVFB_WIDTH XVFB_HEIGHT XVFB_DEPTH <<< "$XVFB_WHD"
if [[ -z "${XVFB_WIDTH:-}" || -z "${XVFB_HEIGHT:-}" || -z "${XVFB_DEPTH:-}" ]]; then
  echo "Invalid XVFB_WHD format. Expected WIDTHxHEIGHTxDEPTH (e.g., 1920x1080x24)." >&2
  exit 1
fi

pids=()

cleanup() {
  trap - EXIT INT TERM
  for pid in "${pids[@]}"; do
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
  done
  wait || true
}

trap cleanup EXIT INT TERM

Xvfb "$DISPLAY" -screen 0 "${XVFB_WIDTH}x${XVFB_HEIGHT}x${XVFB_DEPTH}" -nolisten tcp -fbdir /tmp &
pids+=("$!")

for _ in {1..40}; do
  if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done

fluxbox &
pids+=("$!")

vnc_opts=(
  "-display" "$DISPLAY"
  "-rfbport" "$VNC_PORT"
  "-shared"
  "-forever"
  "-repeat"
  "-xkb"
)

if [[ -n "${VNC_PASSWORD:-}" ]]; then
  passfile="/tmp/x11vnc.pass"
  rm -f "$passfile"
  umask 077
  x11vnc -storepasswd "$VNC_PASSWORD" "$passfile" >/dev/null 2>&1
  vnc_opts+=("-rfbauth" "$passfile")
else
  vnc_opts+=("-nopw")
fi

x11vnc "${vnc_opts[@]}" -o /tmp/x11vnc.log &
pids+=("$!")
# Serve noVNC web client bound to the VNC server
websockify --web=/usr/share/novnc/ "0.0.0.0:$NOVNC_PORT" "localhost:$VNC_PORT" &
pids+=("$!")

chromium_flags=(
  "--no-sandbox"
  "--display=$DISPLAY"
  "--disable-dev-shm-usage"
  "--no-first-run"
  "--disable-setuid-sandbox"
  "--user-data-dir=/home/chromium/.config/chromium"
)

if [[ -n "${CHROMIUM_FLAGS:-}" ]]; then
  # shellcheck disable=SC2206
  chromium_flags+=( ${CHROMIUM_FLAGS} )
fi

chromium "${chromium_flags[@]}" &
pids+=("$!")

wait -n
