#!/usr/bin/env bash
# WP-T10-04: run all *_gap.sh; require dot4 + axiom PASS; audit index present.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

test -f docs/reports/compiler-audit/README.md
bash scripts/proof-explorer-gates/wp-compiler-gap-regression.sh

# Mandatory passes beyond regression gate defaults (use host lic, not stale LIC env)
# shellcheck source=../lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
if lic_rel="$(li_pick_lic_bin "$ROOT" 2>/dev/null)"; then
  case "$lic_rel" in
    ./*) export LIC="$ROOT/${lic_rel#./}" ;;
    *) export LIC="$lic_rel" ;;
  esac
else
  echo "wp-t10-04: lic binary missing after regression gate" >&2
  exit 1
fi

for mandatory in dot4_loop_ensures_lean_stub_gap.sh axiom_decl_vc_skip_gap.sh; do
  script="li-tests/tooling/$mandatory"
  if [[ ! -f "$script" ]]; then
    echo "wp-t10-04: missing $script" >&2
    exit 1
  fi
  bash "$script" || { echo "wp-t10-04: mandatory FAIL $mandatory" >&2; exit 1; }
done

grep -q 'BUG-C-01' docs/reports/compiler-audit/README.md
grep -q 'BUG-C-13' docs/reports/compiler-audit/README.md
echo "wp-t10-04-compiler-gaps: OK"
