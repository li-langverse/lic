#!/usr/bin/env bash
# P-linalg / G-lean: tier-1 IKJ matmul loop path (ArrayMatMul2DF64) has no loop≡ensures witness.
# Contrast: witness_dot4_int_loop in vc_witness.cpp + dot4_int_loop_eval_spec in Discharge.lean.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
PROBE="$ROOT/li-tests/math_linalg/matmul_25x25_at_codegen.li"
WITNESS_CPP="$ROOT/compiler/verify/vc_witness.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if grep -q 'witness_matmul' "$WITNESS_CPP" 2>/dev/null; then
  echo "FAIL: expected no witness_matmul* in vc_witness.cpp (P-linalg loop gap)" >&2
  exit 1
fi
if grep -qE 'matmul.*loop_eval|matmul2d.*loop' "$DISCHARGE" 2>/dev/null; then
  echo "FAIL: expected no matmul loop_eval lemma in Discharge.lean yet" >&2
  exit 1
fi

"$LIC" check "$PROBE"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

build_bin() {
  local out="$TMP/$1"
  shift
  "$LIC" build "$PROBE" -o "$out" --release "$@" >/dev/null 2>&1
  echo "$out"
}

count_main_insns() {
  objdump -d "$1" 2>/dev/null | awk '/<main>:/{f=1;next} /^[0-9a-f]+ <[^>]+>:/{if(f) exit} f' | wc -l
}

if ! grep -q 'witness_dot4_int_loop' "$WITNESS_CPP" 2>/dev/null; then
  echo "FAIL: expected witness_dot4_int_loop contrast in vc_witness.cpp" >&2
  exit 1
fi

BIN_FAST="$(build_bin fast)"

MAIN_FAST="$(count_main_insns "$BIN_FAST")"

if [[ "$MAIN_FAST" -lt 20 ]]; then
  echo "FAIL: release matmul main should retain @ codegen (got ${MAIN_FAST} insns; use volatile_sink)" >&2
  exit 1
fi

echo "PASS matmul_loop_codegen_witness_gap: no P-linalg matmul loop witness; @ codegen retained (main=${MAIN_FAST}ins)"
