#!/usr/bin/env bash
# G-par — @parallel(disjoint=...) on def inherits disjoint policy; nested parallel for builds/runs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/decorators/parallel_def_disjoint_inherit.li"
OUT="$ROOT/build/li_parallel_def_disjoint_inherit_smoke"

mkdir -p "$(dirname "$OUT")"
"$LIC" build "$SRC" -o "$OUT" --cores=4 --allow-open-vc
"$OUT"
