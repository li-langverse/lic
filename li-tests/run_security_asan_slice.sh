#!/usr/bin/env bash
# ASan smoke slice for native HTTP/RNG/TLS cores touched by security-research tracks.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"

if [[ "${LI_SECURITY_ASAN:-0}" != "1" ]]; then
  echo "run_security_asan_slice: skip (set LI_SECURITY_ASAN=1 for ASan build)"
  exit 0
fi

BUILD="${LI_ASAN_BUILD:-$ROOT/build-asan}"
LIC="${LIC:-$BUILD/lic}"
if [[ ! -x "$LIC" ]]; then
  echo "run_security_asan_slice: skip (no ASan lic at $LIC)"
  exit 0
fi

pass=0
fail=0
run_smoke() {
  local label="$1"
  shift
  if "$@"; then
    echo "PASS $label"
    pass=$((pass + 1))
  else
    echo "FAIL $label" >&2
    fail=$((fail + 1))
  fi
}

# Malformed-input corpus (parse/check must not signal).
run_smoke "run_security.sh" "$ROOT/li-tests/run_security.sh"

# HTTP parse forward witness (closed Lean slice).
if [[ -f "$ROOT/li-tests/contracts_verify/http_parse_forward_closed.li" ]]; then
  run_smoke "http_parse_forward_closed parse" "$LIC" parse "$ROOT/li-tests/contracts_verify/http_parse_forward_closed.li"
fi

echo "--- run_security_asan_slice: pass=$pass fail=$fail"
[[ "$fail" -eq 0 ]]
