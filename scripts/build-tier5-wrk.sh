#!/usr/bin/env bash
# Build wrk for tier5_http timing gates (no root install).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PREFIX="$ROOT/benchmarks/tier5_http/.wrk-bin"
WRK="$PREFIX/wrk"

if [[ -x "$WRK" ]]; then
  echo "build-tier5-wrk: ok → $WRK"
  exit 0
fi

mkdir -p "$PREFIX"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 https://github.com/wg/wrk.git "$TMP/wrk"
make -C "$TMP/wrk" -j"$(nproc)"
cp -f "$TMP/wrk/wrk" "$WRK"
echo "build-tier5-wrk: ok → $WRK"
