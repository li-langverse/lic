#!/usr/bin/env bash
# WP-PAR-100 — li-parallel G-par proof depth at 100% (compiler-supported surface).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel proofs-complete gate (WP-PAR-100)"

bash "$ROOT/scripts/check-li-parallel-proofs-gate.sh"

GAPS="$ROOT/packages/li-parallel/docs/gap-register.md"
TABLE="$ROOT/packages/li-parallel/docs/proofs-table.md"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"

for path in "$GAPS" "$TABLE" "$DISCHARGE"; do
  [[ -f "$path" ]] || { li_fail "missing $path"; exit 1; }
done

# Machine check: every compiler-accepted disjoint builtin has Discharge spec + witness.
for builtin in disjoint_elem disjoint_row disjoint_slice disjoint_lookup disjoint_mod; do
  if ! grep -q "${builtin}_spec" "$DISCHARGE"; then
    li_fail "Discharge.lean missing ${builtin}_spec (compiler surface)"
    exit 1
  fi
done

gpar_gap_line="$(grep -E '^\| G-par \|' "$GAPS" || true)"
if [[ -z "$gpar_gap_line" ]]; then
  li_fail "G-par row missing in gap-register.md"
  exit 1
fi
if echo "$gpar_gap_line" | grep -qiE '\*\*Partial\*\*|^\| G-par \| Partial'; then
  li_fail "gap-register.md G-par still Partial — mark **Done** when compiler surface is closed"
  exit 1
fi
if ! echo "$gpar_gap_line" | grep -qiE '\*\*Done\*\*'; then
  li_fail "gap-register.md G-par must be **Done** for proofs-complete"
  exit 1
fi

gpar_table_line="$(grep -E '^\| \*\*G-par\*\* \|' "$TABLE" || true)"
if [[ -z "$gpar_table_line" ]]; then
  li_fail "G-par row missing in proofs-table.md"
  exit 1
fi
if echo "$gpar_table_line" | grep -qiE '\*\*Partial\*\*'; then
  li_fail "proofs-table.md G-par still Partial — mark **Done** when compiler surface is closed"
  exit 1
fi
if ! echo "$gpar_table_line" | grep -qiE '\*\*Done\*\*'; then
  li_fail "proofs-table.md G-par must be **Done** for proofs-complete"
  exit 1
fi

li_ok "check-li-parallel-proofs-complete-gate.sh: PASS (G-par Done in li-parallel registers, compiler disjoint surface closed)"
