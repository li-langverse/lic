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
  [[ "$name" == routing_overlap.toml ]] && continue
  if python3 "$PY/httpd_config.py" "$rej" 2>/dev/null; then
    echo "expected reject to fail: $name" >&2
    exit 1
  fi
  echo "$name: rejected OK"
done

echo "== routing cases =="
python3 "$PY/httpd_match.py" "$ROOT/li-tests/httpd/fixtures/routing.toml" \
  "$ROOT/li-tests/routing/cases/api_prefix.toml"
python3 "$PY/httpd_match.py" "$ROOT/li-tests/httpd/fixtures/routing.toml" \
  "$ROOT/li-tests/routing/cases/static_exact.toml"
python3 "$PY/httpd_match.py" "$ROOT/li-tests/httpd/fixtures/prefix_strip.toml" \
  "$ROOT/li-tests/routing/cases/prefix_strip.toml"

echo "== routing overlap reject =="
if python3 "$PY/httpd_config.py" --strict-overlap "$ROOT/li-tests/config_desugar/reject/routing_overlap.toml" 2>/dev/null; then
  echo "expected routing_overlap to fail" >&2
  exit 1
fi
echo "routing_overlap.toml: rejected OK"

echo "run_httpd_config: OK"
