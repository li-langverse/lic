#!/usr/bin/env bash
# WP-PAR-15 Phase 1.2 — parallel for reduce(min:|max:) codegen smoke.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

for src in par_for_reduce_min_f64.li par_for_reduce_max_f64.li; do
  OUT="$ROOT/build/li_par_for_reduce_minmax_${src%.li}"
  mkdir -p "$(dirname "$OUT")"
  "$LIC" build "$ROOT/li-tests/parallel_codegen/$src" -o "$OUT" --cores=4
  "$OUT"
done
