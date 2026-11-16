#!/bin/sh
set -e

# Build CLI args from environment variables so Docker users
# can configure the container without mounting a custom command.

ARGS=""

# Config path (persisted on volume)
if [ -n "$GPSS_CONFIG" ]; then
  ARGS="$ARGS --cfg $GPSS_CONFIG"
fi

# HTTP port
if [ -n "$GPSS_PORT" ]; then
  ARGS="$ARGS --port $GPSS_PORT"
fi

# WebSocket port
if [ -n "$GPSS_WEBSOCKET_PORT" ]; then
  ARGS="$ARGS --websocket-port $GPSS_WEBSOCKET_PORT"
fi

# Host (always 0.0.0.0 inside containers)
ARGS="$ARGS --host 0.0.0.0"

# Optional: one or more album URLs (comma-separated)
# Example: -e GPSS_URLS="https://photos.google.com/share/A?key=1,https://photos.google.com/share/B?key=2"
if [ -n "$GPSS_URLS" ]; then
  # Convert comma-separated list into multiple --urls values
  OLD_IFS="$IFS"
  IFS=","
  set -- $GPSS_URLS
  IFS="$OLD_IFS"
  ARGS="$ARGS --urls"
  for u in "$@"; do
    u=$(echo "$u" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -n "$u" ] && ARGS="$ARGS $u"
  done
fi

# Image duration (seconds)
if [ -n "$GPSS_IMAGE_DURATION" ]; then
  ARGS="$ARGS --image-duration $GPSS_IMAGE_DURATION"
fi

# Refresh interval (seconds)
if [ -n "$GPSS_REFRESH_INTERVAL" ]; then
  ARGS="$ARGS --refresh-interval $GPSS_REFRESH_INTERVAL"
fi

# Title
if [ -n "$GPSS_TITLE" ]; then
  ARGS="$ARGS --title $GPSS_TITLE"
fi

# Fresh start (ignore saved config)
if [ "$GPSS_FRESH" = "1" ] || [ "$GPSS_FRESH" = "true" ]; then
  ARGS="$ARGS --fresh"
fi

# If the user passed their own command (e.g. docker run ... gpss --help),
# just execute it. Otherwise run gpss with the assembled args.
if [ "$#" -gt 0 ] && [ "$1" != "gpss" ]; then
  exec "$@"
fi

# Drop the first "gpss" if present so we don't double it
if [ "$1" = "gpss" ]; then
  shift
fi

echo "Starting Google Photos Slideshow (Docker)"
echo "  Admin portal will be at http://localhost:${GPSS_PORT:-8080}/admin"
echo "  Slideshow at          http://localhost:${GPSS_PORT:-8080}/"
exec gpss $ARGS "$@"
