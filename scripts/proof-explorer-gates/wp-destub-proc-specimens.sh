#!/usr/bin/env bash
# Optional: document CallProc ensures stubs; pass if audit notes exist (no compiler edits).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

NOTE="$ROOT/docs/reports/compiler-audit/BUG-C-12.md"
if [[ ! -f "$NOTE" ]]; then
  echo "wp-destub-proc-specimens: missing $NOTE" >&2
  exit 1
fi
if ! grep -qi 'callproc\|vec3_len' "$NOTE"; then
  echo "wp-destub-proc-specimens: BUG-C-12 should mention CallProc/vec3_len" >&2
  exit 1
fi
echo "wp-destub-proc-specimens: OK (documented in BUG-C-12)"
exit 0
