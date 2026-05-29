#!/usr/bin/env bash
# G-par: disjoint_elem(i, buf) + buf[0] write is unsound but passes lic check today.
# Control: disjoint_row + grid[0][0] is rejected (E0350); disjoint_elem constant-index is not.
# Passes while the gap is open; fails when false_disjoint_elem_constant_index.li is compile_fail.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
FALSE_ELEM="$ROOT/li-tests/race_shared_memory/false_disjoint_elem_constant_index.li"
FALSE_ELEM_DEC="$ROOT/li-tests/decorators/false_disjoint_elem_decorator_constant_index.li"
FALSE_ROW="$ROOT/li-tests/race_shared_memory/false_disjoint_proof.li"
GOOD_ELEM="$ROOT/li-tests/race_shared_memory/good_disjoint_elem_per_index.li"
GOOD_ROW="$ROOT/li-tests/race_shared_memory/good_disjoint_parallel.li"

if "$LIC" check "$FALSE_ELEM" >/dev/null 2>&1; then
  : # gap still open
else
  echo "policy_disjoint_elem_soundness: false_disjoint_elem_constant_index rejected — gap closed; update script + manifest"
  exit 1
fi

if "$LIC" check "$FALSE_ELEM_DEC" >/dev/null 2>&1; then
  : # decorator-for path shares the constant-index hole
else
  echo "policy_disjoint_elem_soundness: false_disjoint_elem_decorator_constant_index rejected — gap closed; update script"
  exit 1
fi

if "$LIC" check "$FALSE_ROW" >/dev/null 2>&1; then
  echo "policy_disjoint_elem_soundness: false_disjoint_proof must still fail (E0350 control)"
  exit 1
fi

if ! "$LIC" check "$GOOD_ELEM" >/dev/null 2>&1; then
  echo "policy_disjoint_elem_soundness: good_disjoint_elem_per_index must pass lic check"
  exit 1
fi

if ! "$LIC" check "$GOOD_ROW" >/dev/null 2>&1; then
  echo "policy_disjoint_elem_soundness: good_disjoint_parallel must pass lic check"
  exit 1
fi

echo "policy_disjoint_elem_soundness: ok (documented G-par disjoint_elem constant-index hole)"
