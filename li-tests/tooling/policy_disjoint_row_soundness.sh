#!/usr/bin/env bash
# G-par soundness guard: documents known policy gap until disjoint_row + grid[i][*] is rejected.
# When policy_module.cpp gains row-index write detection, this script fails — flip manifest to compile_fail.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SPEC="$ROOT/li-tests/race_shared_memory/disjoint_row_writes_row_i.li"
if ! "$LIC" check "$SPEC" >/dev/null 2>&1; then
  echo "policy_disjoint_row_soundness: gap closed — $SPEC is now rejected; update manifest to compile_fail and remove this guard"
  exit 1
fi
echo "policy_disjoint_row_soundness: KNOWN GAP (G-par) — disjoint_row(i, grid) + grid[i][0] still accepted (see policy_module.cpp:183-188)"
exit 0
