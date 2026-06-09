#!/bin/bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
LIC=""
for cand in "$ROOT/build/compiler/lic/lic" "$ROOT/build-wsl/compiler/lic/lic"; do
  [ -x "$cand" ] && LIC=$cand && break
done
[ -n "$LIC" ] || { echo "SKIP: no lic binary" >&2; exit 0; }
BIN="/tmp/proxy_final_chunk_$$"
"$LIC" build "$ROOT/li-tests/httpd/proxy_relay_selftest.li" -o "$BIN"
"$BIN"
rm -f "$BIN"
