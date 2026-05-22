#!/usr/bin/env bash
# Build packages/li-net-httpd → build/li-httpd (M1 runtime + Li epoll loop).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="$("$ROOT/scripts/resolve-lic.sh")"
mkdir -p "$ROOT/build"
"$LIC" build --allow-open-vc "$ROOT/packages/li-net-httpd/src/lib.li" -o "$ROOT/build/li-httpd"
echo "build-li-httpd: ok → $ROOT/build/li-httpd"
