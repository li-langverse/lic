#!/usr/bin/env bash
# Smoke: lic JSON diagnostics for agents (Vision-LLM / agent-first).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
BAD="$ROOT/li-tests/typecheck/bad_array_index.li"
GOOD="$ROOT/li-tests/typecheck/fib.li"

fail() {
  echo "diagnose_json_smoke: $*" >&2
  exit 1
}

out="$("$LIC" check --format=json "$BAD" 2>&1 || true)"
echo "$out" | grep -q '"ok":false' || fail "expected ok:false — output: ${out:0:400}"
echo "$out" | grep -q '"schema":"diagnostic-v1"' || fail "missing schema"
echo "$out" | grep -Eq '"code":"(type\.index|E0201)"' || fail "expected type.index — output: ${out:0:400}"
echo "$out" | grep -q 'array index out of range' || fail "missing index diagnostic message: ${out:0:400}"

diag="$("$LIC" diagnose "$BAD" 2>&1 || true)"
echo "$diag" | grep -q '"command":"diagnose"' || fail "diagnose envelope: ${diag:0:400}"
echo "$diag" | grep -q '"diagnostics":\[' || fail "diagnose missing diagnostics array"

ok="$("$LIC" check --format=json "$GOOD" 2>&1 || true)"
echo "$ok" | grep -q '"ok":true' || fail "fib should be ok:true — ${ok:0:400}"
echo "$ok" | grep -q '"diagnostics":\[\]' || fail "fib should have empty diagnostics"

if command -v jq >/dev/null 2>&1; then
  echo "$out" | "$ROOT/scripts/lic-fix-suggest.sh" >/dev/null 2>&1 || true
fi

echo "diagnose_json_smoke: ok"
