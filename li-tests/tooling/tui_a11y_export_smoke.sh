#!/usr/bin/env bash
# Smoke: tui-a11y-export-v1 schema example validates (Vision-LLM TUI contract).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXAMPLE="$ROOT/docs/schemas/examples/tui-a11y-export-v1.example.json"

fail() {
  echo "tui_a11y_export_smoke: $*" >&2
  exit 1
}

[[ -f "$EXAMPLE" ]] || fail "missing example: $EXAMPLE"
grep -q 'tui-a11y-export-v1' "$EXAMPLE" || fail "missing schema id"
grep -q '"ok": true' "$EXAMPLE" || grep -q '"ok":true' "$EXAMPLE" || fail "example should be ok:true"
grep -q '"bindings"' "$EXAMPLE" || fail "missing bindings"
grep -q '"headings"' "$EXAMPLE" || fail "missing headings"

if command -v jq >/dev/null 2>&1; then
  jq -e '.version == 1 and .schema == "tui-a11y-export-v1" and .screen.status == "ok"' "$EXAMPLE" >/dev/null \
    || fail "jq envelope validation failed"
  jq -e '.screen.bindings | length >= 1' "$EXAMPLE" >/dev/null \
    || fail "expected at least one binding"
fi

echo "tui_a11y_export_smoke: ok"
