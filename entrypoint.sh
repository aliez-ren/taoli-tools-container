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
export TARGET_URL EXTENSION_DIR PROFILE_DIR

IFS='x' read -r SCREEN_WIDTH SCREEN_HEIGHT SCREEN_DEPTH <<EOF_RES
$SCREEN_RESOLUTION
EOF_RES
if [ -z "${SCREEN_WIDTH:-}" ] || [ -z "${SCREEN_HEIGHT:-}" ]; then
  echo "Invalid SCREEN_RESOLUTION: $SCREEN_RESOLUTION" >&2
  exit 1
fi
SCREEN_DEPTH="${SCREEN_DEPTH:-24}"

mkdir -p "$HOME/.vnc"
touch "$HOME/.Xauthority"
touch "$HOME/.vnc/.de-was-selected"

if ! printf '%s\n%s\n' "$KASMVNC_PASSWORD" "$KASMVNC_PASSWORD" | kasmvncpasswd -u "$KASMVNC_USER" -w >/dev/null 2>&1; then
  echo "Warning: failed to provision KasmVNC credentials for $KASMVNC_USER" >&2
fi

cat > "$HOME/.vnc/xstartup" <<'EOF_STARTUP'
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
  --load-extension="${EXTENSION_DIR:-/home/taoli/extension}" \
  --user-data-dir="${PROFILE_DIR:-/home/taoli/taoli-tools}" \
  "${TARGET_URL:-https://taoli.tools}" &

wait
EOF_STARTUP
chmod +x "$HOME/.vnc/xstartup"

cat > "$HOME/.vnc/kasmvnc.yaml" <<EOF_CONFIG
command_line:
  prompt: false
user_session:
  session_type: shared
desktop:
  resolution:
    width: ${SCREEN_WIDTH}
    height: ${SCREEN_HEIGHT}
  pixel_depth: ${SCREEN_DEPTH}
EOF_CONFIG

DISPLAY_NUMBER="${DISPLAY#:}"
if [ -z "$DISPLAY_NUMBER" ]; then
  DISPLAY_NUMBER=1
fi

exec kasmvncserver ":$DISPLAY_NUMBER" \
  -geometry "${SCREEN_WIDTH}x${SCREEN_HEIGHT}" \
  -depth "$SCREEN_DEPTH" \
  -interface 0.0.0.0 \
  -websocketPort "$KASMVNC_PORT" \
  -config "$HOME/.vnc/kasmvnc.yaml" \
  -xstartup "$HOME/.vnc/xstartup" \
  -fg
