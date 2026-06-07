#!/usr/bin/env bash
# WP-T10-04: run all *_gap.sh; require dot4 + axiom PASS; audit index present.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

test -f docs/reports/compiler-audit/README.md
bash scripts/proof-explorer-gates/wp-compiler-gap-regression.sh

# Mandatory passes beyond regression gate defaults
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
