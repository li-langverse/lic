#!/usr/bin/env bash
# Build packages/li-net-httpd → build/li-httpd (CLI main + Li epoll loop).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=llvm-env.sh
source "$ROOT/scripts/llvm-env.sh"
li_detect_compilers
export LI_REPO_ROOT="$ROOT"
export CC CXX
LIC="$("$ROOT/scripts/resolve-lic.sh")"
mkdir -p "$ROOT/build"
"$LIC" build --allow-open-vc --no-lean-verify \
  "$ROOT/packages/li-net-httpd/src/main.li" -o "$ROOT/build/li-httpd"
echo "build-li-httpd: ok → $ROOT/build/li-httpd"
