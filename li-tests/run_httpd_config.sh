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
/tmp/li_match_routes
test "$(/tmp/li_match_routes; echo $?)" -eq 0

echo "== routing (Li serve_routed_once oracle) =="
"$LIC" build "$ROOT/li-tests/httpd/serve_routed_once.li" -o /tmp/li_serve_routed_once
/tmp/li_serve_routed_once
test "$(/tmp/li_serve_routed_once; echo $?)" -eq 0

echo "== routing (Li TOML loader) =="
"$LIC" build "$ROOT/li-tests/routing/match_routes_toml.li" -o /tmp/li_match_routes_toml
/tmp/li_match_routes_toml
test "$(/tmp/li_match_routes_toml; echo $?)" -eq 0

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

echo "== explain-config (lic CLI + C/Python parity) =="
CFG="$ROOT/li-tests/config_desugar/good/agent_gateway.toml"
export LI_REPO_ROOT="$ROOT"
"$LIC" httpd explain-config "$CFG" | diff -u "$ROOT/li-tests/config_desugar/good/agent_gateway.explained.golden" -
chmod +x "$ROOT/scripts/check-httpd-explain-config.sh" "$ROOT/scripts/li-httpd-explain-config.sh"
"$ROOT/scripts/check-httpd-explain-config.sh" "$CFG"

echo "run_httpd_config: OK"
