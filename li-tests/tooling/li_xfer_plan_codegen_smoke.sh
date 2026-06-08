#!/usr/bin/env bash
# WP-PAR-87 — embedded __li_xfer_plan + program-first xfer statements codegen smoke.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/program_first_xfer_plan.li"
OUT="$ROOT/build/li_xfer_plan_codegen_smoke"

mkdir -p "$(dirname "$OUT")"
"$LIC" build "$SRC" -o "$OUT" --cores=4 --allow-open-vc
nm_out="$(nm "$OUT" 2>/dev/null || true)"
if [[ "$nm_out" != *"__li_xfer_plan"* ]]; then
  echo "li_xfer_plan_codegen_smoke: missing __li_xfer_plan symbol" >&2
  exit 1
fi
if [[ "$nm_out" != *"li_xfer_elide_copy"* ]]; then
  echo "li_xfer_plan_codegen_smoke: missing li_xfer_elide_copy symbol" >&2
  exit 1
fi
"$OUT"

echo "li_xfer_plan_codegen_smoke: ok"
