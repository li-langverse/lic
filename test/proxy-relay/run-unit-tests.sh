#!/bin/bash
# Proxy relay unit tests (TDD harness). Run from lic/: bash test/proxy-relay/run-unit-tests.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"

LIC=""
for cand in ./build/compiler/lic/lic ./build-wsl/compiler/lic/lic ./build/lic; do
  if [ -x "$cand" ]; then LIC=$cand; break; fi
done
if [ -z "$LIC" ]; then
  echo "SKIP: lic binary not found (cmake --build build-wsl)" >&2
  exit 1
fi

echo "== proxy relay C selftest =="
SELFTEST_LI="$ROOT/li-tests/httpd/proxy_relay_selftest.li"
SELFTEST_BIN="/tmp/proxy_relay_selftest_$$"
"$LIC" build "$SELFTEST_LI" -o "$SELFTEST_BIN"
"$SELFTEST_BIN"
rm -f "$SELFTEST_BIN"
echo "PASS proxy_relay_selftest.li"

echo "== proxy relay shell fixtures =="
for t in test_proxy_cl_accounting.sh test_final_chunk_tail.sh; do
  bash "test/proxy-relay/$t"
  echo "PASS $t"
done

echo "ALL proxy-relay unit tests passed"
