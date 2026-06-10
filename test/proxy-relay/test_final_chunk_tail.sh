#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
LIC=""
for cand in "$ROOT/build/compiler/lic/lic" "$ROOT/build-wsl/compiler/lic/lic" "$ROOT/build/lic" "$ROOT/lic"; do
  if [ -x "$cand" ]; then
    LIC=$cand
    break
  fi
done
[ -n "$LIC" ] || { echo "FAIL test_final_chunk_tail: no lic binary" >&2; exit 1; }
BIN="/tmp/proxy_final_chunk_$$"
"$LIC" build "$ROOT/li-tests/httpd/proxy_relay_selftest.li" -o "$BIN"
"$BIN"
rm -f "$BIN"
