#!/usr/bin/env bash
# WP-PAR-79–86 — li-gpu / li-tpu / li-asic packages probed; hetero orchestration from li-parallel only.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel hetero gate (WP-PAR-79–86)"

for pkg in li-gpu li-tpu li-asic; do
  if [[ ! -d "$ROOT/packages/$pkg" ]]; then
    li_fail "WP-PAR-79–86 pending — missing packages/$pkg"
    exit 1
  fi
done

li_fail "WP-PAR-80–86 pending — hetero pipeline CPU+GPU+TPU+ASIC probe benches and orchestration APIs"
exit 1
