#!/usr/bin/env bash
# WP-PAR-15 — team(cores=N) scoped block + parallel for reduce(+:) lowers and runs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/team_block_reduce_f64.li"
OUT="$ROOT/build/li_team_block_reduce_codegen_smoke"

mkdir -p "$(dirname "$OUT")"
"$LIC" build "$SRC" -o "$OUT" --cores=4
nm_out="$(nm "$OUT" 2>/dev/null || true)"
if [[ "$nm_out" != *"li_exec_team_push"* ]]; then
  echo "li_team_block_reduce_codegen_smoke: missing li_exec_team_push" >&2
  exit 1
fi
if [[ "$nm_out" != *"li_parallel_for_reduce_add_f64"* ]]; then
  echo "li_team_block_reduce_codegen_smoke: missing li_parallel_for_reduce_add_f64" >&2
  exit 1
fi
"$OUT"
