#!/usr/bin/env bash
# WP-PAR-08 — team(cores=N) scoped block lowers and runs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/team_block_par_for.li"
OUT="$ROOT/build/li_team_block_codegen_smoke"

mkdir -p "$(dirname "$OUT")"
"$LIC" build "$SRC" -o "$OUT" --cores=4 --allow-open-vc
"$OUT"
