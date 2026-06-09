#!/usr/bin/env bash
# Pull public images without Docker Desktop credsStore (breaks in WSL).
set -euo pipefail
NOCFG=$(mktemp -d)
echo '{}' > "$NOCFG/config.json"
export DOCKER_CONFIG="$NOCFG"
trap 'rm -rf "$NOCFG"' EXIT
for img in caddy:2.9.1-alpine haproxy:2.9-alpine ubuntu:24.04 nginx:1.27-alpine; do
  echo "pull: $img"
  docker pull "$img"
done
echo "pull: done"
