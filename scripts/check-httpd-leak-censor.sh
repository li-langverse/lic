#!/usr/bin/env bash
# M1.5 leak_censor config + setup-censor + flatten gates (Python).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"

echo "== schema catalog =="
"$ROOT/scripts/check-schema-catalog.sh"

echo "== leak_censor good config =="
python3 "$ROOT/scripts/httpd_config.py" "$ROOT/li-tests/config_desugar/good/leak_censor_m15.toml"

echo "== leak_censor reject =="
rej="$ROOT/li-tests/config_desugar/reject/leak_censor_bad_pattern.toml"
if python3 "$ROOT/scripts/httpd_config.py" "$rej" 2>/dev/null; then
  echo "expected reject: leak_censor_bad_pattern.toml" >&2
  exit 1
fi
echo "leak_censor_bad_pattern.toml: rejected OK"

echo "== flatten leak_censor_m15 =="
tmp="$(mktemp)"
python3 "$ROOT/scripts/flatten-httpd-config.py" \
  "$ROOT/li-tests/config_desugar/good/leak_censor_m15.toml" -o "$tmp"
grep -q 'leak_censor_enabled=1' "$tmp"
grep -q 'leak_censor_pattern=openai_sk' "$tmp"
grep -q 'leak_censor_deny_path=\$\.api_key' "$tmp"
grep -q 'leak_censor_deny_path=\$\.api_keys\[\*\]\.token' "$tmp"
rm -f "$tmp"

echo "check-httpd-leak-censor: OK"
