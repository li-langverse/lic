#!/usr/bin/env bash
# WP-PAR-19 — team(cores=0) uses auto-detected core count.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/team_auto_cores.li"
OUT="$ROOT/build/li_team_auto_cores_codegen_smoke"

mkdir -p "$(dirname "$OUT")"
"$LIC" build "$SRC" -o "$OUT" --allow-open-vc
"$OUT"
