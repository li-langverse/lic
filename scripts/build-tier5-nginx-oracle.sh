#!/usr/bin/env bash
# Build vendored nginx 1.26.x for tier5 exploit/bench oracle (no root install).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NGINX_SRC="$ROOT/benchmarks/tier5_http/third_party/nginx"
PREFIX="$ROOT/benchmarks/tier5_http/.nginx-prefix"

if [[ ! -d "$NGINX_SRC" ]]; then
  echo "build-tier5-nginx-oracle: init submodule first" >&2
  git -C "$ROOT" submodule update --init benchmarks/tier5_http/third_party/nginx
fi

cd "$NGINX_SRC"
if [[ ! -f objs/nginx ]]; then
  ./auto/configure --prefix="$PREFIX" --without-http_rewrite_module
  make -j"$(nproc)"
fi
mkdir -p "$PREFIX/sbin"
cp -f objs/nginx "$PREFIX/sbin/nginx"
echo "build-tier5-nginx-oracle: ok → $PREFIX/sbin/nginx"
