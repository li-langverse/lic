#!/usr/bin/env bash
# WP-PAR-23 — compiler distributed for lowers to li_distributed_for_i64.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/dpar_for_range.li"
OUT="$ROOT/build/li_dpar_for_codegen_smoke"

mkdir -p "$(dirname "$OUT")"
export LI_DPAR_RANK=0
export LI_DPAR_WORLD_SIZE=1
"$LIC" build "$SRC" -o "$OUT" --allow-open-vc
"$OUT"
