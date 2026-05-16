#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
BAD="$ROOT/li-tests/typecheck/bad_array_index.li"
out="$("$LIC" check --format=json "$BAD" 2>/dev/null || true)"
echo "$out" | grep -q '"ok":false'
echo "$out" | grep -q '"schema":"diagnostic-v1"'
echo "$out" | grep -q '"code":"E0201"'
diag="$("$LIC" diagnose "$BAD" 2>/dev/null || true)"
echo "$diag" | grep -q '"command":"diagnose"'
ok="$("$LIC" check --format=json "$ROOT/li-tests/lexer_parser/fib.li" 2>/dev/null)"
echo "$ok" | grep -q '"ok":true'
human="$("$LIC" check "$BAD" 2>&1 || true)"
echo "$human" | grep -q 'error'
echo "diagnose_json_smoke: ok"
