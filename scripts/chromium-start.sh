#!/bin/sh
set -eu

BROWSER="$(command -v chromium || command -v chromium-browser || true)"
if [ -z "$BROWSER" ]; then
    echo "Chromium executable not found" >&2
    exit 1
fi

PROFILE="${CHROMIUM_PROFILE:-/config/.config/chromium}"
mkdir -p "$PROFILE"

exec "$BROWSER" \
    --user-data-dir="$PROFILE" \
    --no-first-run \
    --no-default-browser-check \
    --disable-background-networking \
    --disable-component-update \
    --disable-sync \
    --disable-extensions \
    --disable-translate \
    --disable-breakpad \
    --disable-crash-reporter \
    --disable-default-apps \
    --renderer-process-limit=2 \
    --process-per-site \
    --disk-cache-size=16777216 \
    --media-cache-size=4194304 \
    --autoplay-policy=no-user-gesture-required \
    --window-size=1280,720 \
    "${START_URL:-https://www.youtube.com}"
