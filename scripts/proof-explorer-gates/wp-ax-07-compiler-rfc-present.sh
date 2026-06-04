#!/usr/bin/env bash
# WP-AX-07: BUG-C-13 RFC present (no compiler diff required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
test -f docs/reports/compiler-audit/BUG-C-13-li-axiom-declarations.md
grep -q 'vc_emit' docs/reports/compiler-audit/BUG-C-13-li-axiom-declarations.md
grep -q 'kind=axiom' docs/reports/compiler-audit/BUG-C-13-li-axiom-declarations.md
grep -q 'lean_thm' docs/reports/compiler-audit/BUG-C-13-li-axiom-declarations.md
grep -q 'No `axiom proc`' docs/reports/compiler-audit/BUG-C-13-li-axiom-declarations.md
echo "wp-ax-07-compiler-rfc-present: OK"
