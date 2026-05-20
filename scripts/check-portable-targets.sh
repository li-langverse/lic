#!/usr/bin/env bash
# PH-PORT-0 — verify targets/manifest.toml registry (World Studio CI).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/targets/manifest.toml"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

li_phase "portable targets manifest"
[[ -f "$MANIFEST" ]] || li_gate_fail "missing $MANIFEST"

count="$(grep -c '^\[\[target\]\]' "$MANIFEST" || true)"
if [[ "$count" -lt 5 ]]; then
  li_gate_fail "expected >= 5 targets, found $count"
fi

li_gate_ok "portable targets ($count triples)"
