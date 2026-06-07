#!/usr/bin/env bash
# WP-PAR-18 — @parallel def callable with var array param + parallel for body.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" || exit 1

SRC="$ROOT/li-tests/parallel_codegen/parallel_def_callable.li"
OUT="$ROOT/build/li_parallel_def_callable_smoke"

mkdir -p "$(dirname "$OUT")"
"$LIC" build "$SRC" -o "$OUT" --cores=4 --allow-open-vc
"$OUT"
