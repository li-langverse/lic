#!/usr/bin/env bash
# WP-PAR-07–09 — team, @offload, reduce, overlap comm + embedded __li_exec_plan.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/program_first_exec_plan.li"
OUT="$ROOT/build/li_program_first_exec_plan_smoke"

mkdir -p "$(dirname "$OUT")"
"$LIC" build "$SRC" -o "$OUT" --cores=4 --allow-open-vc
nm_out="$(nm "$OUT" 2>/dev/null || true)"
if [[ "$nm_out" != *"__li_exec_plan"* ]]; then
  echo "li_program_first_exec_plan_smoke: missing __li_exec_plan symbol" >&2
  exit 1
fi
"$OUT"
