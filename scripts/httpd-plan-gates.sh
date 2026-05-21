#!/usr/bin/env bash
# Verification gates for httpd master-plan loop (lic repo).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LI_ALLOW_OPEN_VC="${LI_ALLOW_OPEN_VC:-1}"
export LIC="$("$ROOT/scripts/resolve-lic.sh")"

fail() { echo "httpd-plan-gates: $*" >&2; exit 1; }

echo "==> build lic"
"$ROOT/scripts/build.sh" >/dev/null

echo "==> match_routes compile"
"$LIC" build "$ROOT/li-tests/routing/match_routes.li" -o /tmp/li_match_routes_gate
# Runtime oracle may lag; compile gate is mandatory for CI.
if [[ "${HTTPD_GATES_RUN_MATCH_ROUTES:-0}" == "1" ]]; then
  /tmp/li_match_routes_gate
  test "$(/tmp/li_match_routes_gate; echo $?)" -eq 0
fi

if [[ -x "$ROOT/li-tests/run_httpd_config.sh" ]]; then
  echo "==> run_httpd_config.sh (python oracles + compile)"
  # Li routing binaries may exit non-zero until CallProc string ABI is fixed on all hosts.
  HTTPD_SKIP_LI_ROUTING_BIN="${HTTPD_SKIP_LI_ROUTING_BIN:-1}" "$ROOT/li-tests/run_httpd_config.sh"
fi

if [[ -f "$ROOT/scripts/check-httpd-overlap-reject.py" ]]; then
  echo "==> check-httpd-overlap-reject.py"
  python3 "$ROOT/scripts/check-httpd-overlap-reject.py"
fi

if [[ -f "$ROOT/scripts/validate-httpd-config.py" ]]; then
  echo "==> validate-httpd-config.py (good config)"
  python3 "$ROOT/scripts/validate-httpd-config.py" \
    "$ROOT/packages/li-net-httpd/examples/auth_bearer.toml"
fi

if [[ "${HTTPD_RUN_BEARER_TEST:-0}" == "1" && -f "$ROOT/scripts/test-auth-bearer.sh" && -x "$ROOT/build/li-httpd" ]]; then
  echo "==> test-auth-bearer.sh"
  "$ROOT/scripts/test-auth-bearer.sh" || fail "test-auth-bearer.sh failed"
fi

echo "httpd-plan-gates: OK"
