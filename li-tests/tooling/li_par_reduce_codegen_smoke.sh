#!/usr/bin/env bash
# WP-PAR-15 — compiler par_sum lowers to li_par_reduce_sum_f64 (tree pool reduce).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/par_sum_f64.li"
OUT="$ROOT/build/li_par_reduce_codegen_smoke"

mkdir -p "$(dirname "$OUT")"
"$LIC" build "$SRC" -o "$OUT" --cores=4
"$OUT"
