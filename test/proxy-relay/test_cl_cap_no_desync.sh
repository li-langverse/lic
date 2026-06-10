#!/bin/sh
# CL cap must not desync body_left - rbuf tail (381B) must flush before finish.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
LIC=""
for cand in "$ROOT/build/compiler/lic/lic" "$ROOT/build-wsl/compiler/lic/lic" "$ROOT/build/lic" "$ROOT/lic"; do
  if [ -x "$cand" ]; then
    LIC=$cand
    break
  fi
done
[ -n "$LIC" ] || { echo "FAIL test_cl_cap_no_desync: no lic binary" >&2; exit 1; }
BIN="/tmp/proxy_cl_cap_no_desync_$$"
"$LIC" build "$ROOT/li-tests/httpd/proxy_relay_selftest.li" -o "$BIN"
"$BIN"
rm -f "$BIN"
