#!/usr/bin/env bash
# WP-PAR-15 Phase 1.1 — parallel for reduce(+:) lowers to li_parallel_for_reduce_add_f64.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/par_for_reduce_f64.li"
OUT="$ROOT/build/li_par_for_reduce_codegen_smoke"

mkdir -p "$(dirname "$OUT")"
"$LIC" build "$SRC" -o "$OUT" --cores=4
"$OUT"
