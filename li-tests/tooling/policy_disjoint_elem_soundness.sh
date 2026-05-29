#!/usr/bin/env bash
# G-par: disjoint_elem(i, buf) + buf[0] write is unsound but passes lic check today.
# Control: disjoint_row + grid[0][0] is rejected (E0350); disjoint_elem constant-index is not.
# Keyword `parallel for` lowers to OpenMP (executable race); decorator `@parallel for` stays serial (latent).
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
BIN_KW="$(mktemp -t li_false_elem_kw.XXXXXX)"
BIN_DEC="$(mktemp -t li_false_elem_dec.XXXXXX)"
trap 'rm -f "$BIN_KW" "$BIN_DEC"' EXIT

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

ROW_ERR="$("$LIC" check "$FALSE_ROW" 2>&1)" || true
if [[ "$ROW_ERR" != *"E0350"* ]] || [[ "$ROW_ERR" != *"disjoint_row"* ]]; then
  echo "policy_disjoint_elem_soundness: false_disjoint_proof must fail E0350 disjoint_row control"
  echo "$ROW_ERR"
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

"$LIC" build "$FALSE_ELEM" -o "$BIN_KW"
"$LIC" build "$FALSE_ELEM_DEC" -o "$BIN_DEC"

if ! nm "$BIN_KW" | grep -q '__li_par_'; then
  echo "policy_disjoint_elem_soundness: keyword specimen must emit __li_par_* worker (OpenMP path)"
  exit 1
fi
if ! objdump -d "$BIN_KW" 2>/dev/null | grep 'call' | grep -q 'li_omp_parallel_for_i64'; then
  echo "policy_disjoint_elem_soundness: keyword false_elem_proof must call li_omp_parallel_for_i64"
  exit 1
fi
if nm "$BIN_DEC" | grep -q '__li_par_'; then
  echo "policy_disjoint_elem_soundness: decorator-for now emits __li_par_* — update script (7d-b lowered?)"
  exit 1
fi
if objdump -d "$BIN_DEC" 2>/dev/null | grep 'call' | grep -q 'li_omp_parallel_for_i64'; then
  echo "policy_disjoint_elem_soundness: decorator false_elem_decorator must not call omp yet"
  exit 1
fi

echo "policy_disjoint_elem_soundness: ok (documented G-par disjoint_elem constant-index hole + keyword OpenMP race surface)"
