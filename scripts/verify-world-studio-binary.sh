#!/usr/bin/env bash
# Build and smoke-run native world-studio binary (exit 0 expected).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
OUT="${1:-$ROOT/build/bin/world-studio}"

chmod +x "$ROOT/scripts/build-studio-binary.sh"
"$ROOT/scripts/build-studio-binary.sh" "$OUT"

if [[ ! -f "$OUT" ]]; then
  li_gate_fail "world-studio binary missing: $OUT"
  exit 1
fi

li_phase "run $OUT"
set +e
"$OUT"
rc=$?
set -e
if [[ "$rc" -ne 0 ]]; then
  li_gate_fail "world-studio exited $rc (expected 0)"
  exit 1
fi
li_gate_ok "world-studio binary smoke"
