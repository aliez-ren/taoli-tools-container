#!/bin/sh
set -eu

export DISPLAY="${DISPLAY:-:1}"
SCREEN_RESOLUTION="${SCREEN_RESOLUTION:-1504x1024x16}"
KASMVNC_PORT="${KASMVNC_PORT:-}"
if [ -z "$KASMVNC_PORT" ] && [ -n "${NOVNC_PORT:-}" ]; then
  KASMVNC_PORT="$NOVNC_PORT"
fi
KASMVNC_PORT="${KASMVNC_PORT:-80}"
KASMVNC_USER="${KASMVNC_USER:-taoli}"
KASMVNC_PASSWORD="${KASMVNC_PASSWORD:-taoli}"
TARGET_URL="${TARGET_URL:-https://taoli.tools}"
EXTENSION_DIR="${EXTENSION_DIR:-/home/taoli/extension}"
PROFILE_DIR="${PROFILE_DIR:-/home/taoli/taoli-tools}"

IFS='x' read -r SCREEN_WIDTH SCREEN_HEIGHT SCREEN_DEPTH <<EOF_RES
$SCREEN_RESOLUTION
EOF_RES
if [ -z "${SCREEN_WIDTH:-}" ] || [ -z "${SCREEN_HEIGHT:-}" ]; then
  echo "Invalid SCREEN_RESOLUTION: $SCREEN_RESOLUTION" >&2
  exit 1
fi
SCREEN_DEPTH="${SCREEN_DEPTH:-24}"

mkdir -p "$HOME/.vnc"

printf '%s\n%s\n' "$KASMVNC_PASSWORD" "$KASMVNC_PASSWORD" | kasmvncpasswd -u "$KASMVNC_USER" -w >/dev/null

export TAOLI_TARGET_URL="$TARGET_URL"
export TAOLI_EXTENSION_DIR="$EXTENSION_DIR"
export TAOLI_PROFILE_DIR="$PROFILE_DIR"

cat > "$HOME/.vnc/xstartup" <<'EOF'
#!/bin/sh
set -eu

openbox-session &

chromium \
  --display="${DISPLAY}" \
  --no-default-browser-check \
  --no-first-run \
  --disable-gpu \
  --use-gl=disabled \
  --start-fullscreen \
  --load-extension="${TAOLI_EXTENSION_DIR}" \
  --user-data-dir="${TAOLI_PROFILE_DIR}" \
  "${TAOLI_TARGET_URL}" &

wait
EOF
chmod +x "$HOME/.vnc/xstartup"

DISPLAY_NUMBER="${DISPLAY#:}"
if [ -z "$DISPLAY_NUMBER" ]; then
  DISPLAY_NUMBER=1
fi

exec kasmvncserver ":$DISPLAY_NUMBER" \
  -geometry "${SCREEN_WIDTH}x${SCREEN_HEIGHT}" \
  -depth "$SCREEN_DEPTH" \
  -interface 0.0.0.0 \
  -websocketPort "$KASMVNC_PORT" \
  -fg
