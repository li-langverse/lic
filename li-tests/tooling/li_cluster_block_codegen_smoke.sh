#!/usr/bin/env bash
# WP-PAR-08 — cluster() block lowers distributed for under exec plan.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/cluster_block_dpar.li"
OUT="$ROOT/build/li_cluster_block_codegen_smoke"

mkdir -p "$(dirname "$OUT")"
export LI_DPAR_RANK=0
export LI_DPAR_WORLD_SIZE=1
"$LIC" build "$SRC" -o "$OUT" --allow-open-vc
nm_out="$(nm "$OUT" 2>/dev/null || true)"
if [[ "$nm_out" != *"__li_exec_plan"* ]]; then
  echo "li_cluster_block_codegen_smoke: missing __li_exec_plan symbol" >&2
  exit 1
fi
"$OUT"
