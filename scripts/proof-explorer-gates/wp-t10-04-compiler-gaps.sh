#!/usr/bin/env bash
# WP-T10-04: run all *_gap.sh; require dot4 + axiom PASS; audit index present.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

test -f docs/reports/compiler-audit/README.md
# shellcheck source=../lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" "wp-t10-04: build lic (./scripts/build.sh)" || exit 1
bash scripts/proof-explorer-gates/wp-compiler-gap-regression.sh

# Mandatory passes beyond regression gate defaults (absolute LIC for worktrees/WSL)
li_export_lic "$ROOT" || exit 1
export LIC="$ROOT/build/compiler/lic/lic"
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
