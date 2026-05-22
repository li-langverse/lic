#!/usr/bin/env bash
# Verification gates for httpd master-plan loop (lic repo).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LIC="$("$ROOT/scripts/resolve-lic.sh")"
LIC_BUILD_FLAGS=(--allow-open-vc)

fail() { echo "httpd-plan-gates: $*" >&2; exit 1; }

echo "==> build lic"
"$ROOT/scripts/build.sh" >/dev/null

echo "==> match_routes compile + oracle"
"$LIC" build "${LIC_BUILD_FLAGS[@]}" "$ROOT/li-tests/routing/match_routes.li" -o /tmp/li_match_routes_gate
/tmp/li_match_routes_gate
test "$(/tmp/li_match_routes_gate; echo $?)" -eq 0

if [[ -x "$ROOT/li-tests/run_routing.sh" ]]; then
  echo "==> run_routing.sh (table cases + overlap config_reject)"
  chmod +x "$ROOT/li-tests/run_routing.sh"
  HTTPD_SKIP_LI_ROUTING_BIN="${HTTPD_SKIP_LI_ROUTING_BIN:-0}" "$ROOT/li-tests/run_routing.sh"
fi

if [[ -x "$ROOT/li-tests/run_httpd_config.sh" ]]; then
  echo "==> run_httpd_config.sh (desugar + validate + routing)"
  HTTPD_SKIP_LI_ROUTING_BIN="${HTTPD_SKIP_LI_ROUTING_BIN:-0}" \
    HTTPD_SKIP_SERVE_ROUTED_ONCE="${HTTPD_SKIP_SERVE_ROUTED_ONCE:-1}" \
    "$ROOT/li-tests/run_httpd_config.sh"
fi

if [[ -f "$ROOT/scripts/validate-httpd-config.py" ]]; then
  echo "==> validate-httpd-config.py (good config)"
  python3 "$ROOT/scripts/validate-httpd-config.py" \
    "$ROOT/packages/li-net-httpd/examples/auth_bearer.toml"
fi

if [[ "${HTTPD_RUN_BEARER_TEST:-1}" == "1" && -f "$ROOT/scripts/test-auth-bearer.sh" ]]; then
  if [[ ! -x "$ROOT/build/li-httpd" ]]; then
    echo "==> build-li-httpd.sh"
    chmod +x "$ROOT/scripts/build-li-httpd.sh"
    "$ROOT/scripts/build-li-httpd.sh" || fail "build-li-httpd.sh failed"
  fi
  if [[ -x "$ROOT/build/li-httpd" ]]; then
    echo "==> test-auth-bearer.sh"
    chmod +x "$ROOT/scripts/test-auth-bearer.sh"
    "$ROOT/scripts/test-auth-bearer.sh" || fail "test-auth-bearer.sh failed"
  fi
fi

echo "httpd-plan-gates: OK"
