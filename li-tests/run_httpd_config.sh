#!/usr/bin/env bash
# M1 prep: easy TOML desugar, validate, routing cases (Python oracle until li-httpd ships).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PY="${ROOT}/scripts"
export PYTHONPATH="$PY${PYTHONPATH:+:$PYTHONPATH}"

echo "== httpd config desugar (good) =="
for f in "$ROOT/li-tests/config_desugar/good"/*.toml; do
  python3 "$PY/httpd_config.py" "$f"
done

echo "== routing overlap (same priority must reject) =="
python3 "$PY/check-httpd-overlap-reject.py"

echo "== httpd config reject =="
for rej in "$ROOT/li-tests/config_desugar/reject"/*.toml; do
  name="$(basename "$rej")"
  if python3 "$PY/httpd_config.py" "$rej" 2>/dev/null; then
    echo "expected reject to fail: $name" >&2
    exit 1
  fi
  echo "$name: rejected OK"
done

echo "== routing cases (Python oracle) =="
for cases in "$ROOT/li-tests/routing/cases"/*.toml; do
  python3 "$PY/httpd_match.py" "$ROOT/li-tests/httpd/fixtures/routing.toml" "$cases"
done

echo "== routing (Li compile + binary oracle) =="
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
export LI_ALLOW_OPEN_VC=1
export LI_REPO_ROOT="$ROOT"
"$LIC" build "$ROOT/li-tests/routing/match_routes.li" -o /tmp/li_match_routes
if [[ "${HTTPD_SKIP_LI_ROUTING_BIN:-0}" != "1" ]]; then
  /tmp/li_match_routes
  rc=$?
  test "$rc" -eq 0
else
  echo "skip Li routing binary run (HTTPD_SKIP_LI_ROUTING_BIN=1)"
fi

echo "== routing (Li serve_routed_once oracle) =="
"$LIC" build "$ROOT/li-tests/httpd/serve_routed_once.li" -o /tmp/li_serve_routed_once
if [[ "${HTTPD_SKIP_LI_ROUTING_BIN:-0}" != "1" ]]; then
  /tmp/li_serve_routed_once
  rc=$?
  test "$rc" -eq 0
fi

echo "== routing (Li TOML loader) =="
"$LIC" build "$ROOT/li-tests/routing/match_routes_toml.li" -o /tmp/li_match_routes_toml
if [[ "${HTTPD_SKIP_LI_ROUTING_BIN:-0}" != "1" ]]; then
  /tmp/li_match_routes_toml
  rc=$?
  test "$rc" -eq 0
fi

echo "== validate-config (lic CLI) =="
"$LIC" httpd validate-config "$ROOT/li-tests/config_desugar/good/agent_gateway.toml"
for rej in "$ROOT/li-tests/config_desugar/reject"/*.toml; do
  name="$(basename "$rej")"
  if "$LIC" httpd validate-config "$rej" 2>/dev/null; then
    echo "validate-config: expected reject for $name" >&2
    exit 1
  fi
  echo "validate-config $name: rejected OK"
done

echo "== validate-httpd-config (Python M1 schema) =="
"$ROOT/scripts/lic-validate-httpd-config.sh" "$ROOT/packages/li-net-httpd/examples/auth_bearer.toml"

echo "== explain-config (lic CLI + C/Python parity) =="
CFG="$ROOT/li-tests/config_desugar/good/agent_gateway.toml"
export LI_REPO_ROOT="$ROOT"
"$LIC" httpd explain-config "$CFG" | diff -u "$ROOT/li-tests/config_desugar/good/agent_gateway.explained.golden" -
chmod +x "$ROOT/scripts/check-httpd-explain-config.sh" "$ROOT/scripts/li-httpd-explain-config.sh"
"$ROOT/scripts/check-httpd-explain-config.sh" "$CFG"

echo "run_httpd_config: OK"
