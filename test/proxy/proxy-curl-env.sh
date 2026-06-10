#!/bin/sh
# Export curl proxy targeting vars for PROXY_HOST (IP or docker service name).
# Usage: eval "$(sh test/proxy/proxy-curl-env.sh)"
set -eu
PHOST="${PROXY_HOST:-127.0.0.1}"
PPORT="${PROXY_PORT:-18443}"
PVHOST="${PROXY_VHOST:-gitlab.lilangverse.xyz}"
case "$PHOST" in
  *[!0-9.]*)
    printf 'export PROXY_USE_CONNECT=1 PROXY_CONNECT_HOST=%s PROXY_VHOST=%s PROXY_PORT=%s\n' \
      "$PHOST" "$PVHOST" "$PPORT"
    ;;
  *)
    RESOLVE="${PVHOST}:${PPORT}:${PHOST}"
    printf 'export PROXY_USE_CONNECT=0 PROXY_RESOLVE=%s PROXY_VHOST=%s PROXY_PORT=%s\n' \
      "$RESOLVE" "$PVHOST" "$PPORT"
    ;;
esac
