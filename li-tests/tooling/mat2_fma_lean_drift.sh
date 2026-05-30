#!/usr/bin/env bash
# G-hw / G-meta: release FMA matmul can diverge from Lean mat2_at2_eval (mul+add IEEE model).
# Runtime fixtures via mat2_fma_drift_rt.c; expected lean eval from Python (not C fast-math literals).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LI_EXTRA_C="$ROOT/li-tests/math_linalg/mat2_fma_drift_rt.c"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/math_linalg/mat2_at2_fma_drift_cell.li"
RT_C="$ROOT/li-tests/math_linalg/mat2_fma_drift_rt.c"
OUT_DBG="$(mktemp -t mat2_fma_dbg.XXXXXX)"
OUT_REL="$(mktemp -t mat2_fma_rel.XXXXXX)"
OUT_STABLE="$(mktemp -t mat2_stable_rel.XXXXXX)"
trap 'rm -f "$OUT_DBG" "$OUT_REL" "$OUT_STABLE"' EXIT

test -f "$RT_C"

LEAN_EXPECT="$(python3 - <<'PY'
a0, b0, a1, b10 = -352334.47033367527, -698301.65215099615, 301868.94607970747, -855127.42666491447
print(f"{(a0*b0) + (a1*b10):.17g}")
PY
)"

if ! "$LIC" check "$SAMPLE" >/dev/null 2>&1; then
  echo "mat2_fma_lean_drift: witness must pass lic check"
  exit 1
fi

if ! "$LIC" build "$SAMPLE" -o "$OUT_DBG" --no-lean-verify >/dev/null 2>&1; then
  echo "mat2_fma_lean_drift: debug build must succeed"
  exit 1
fi
DBG_OUT="$(LI_PRINT_SINK_F64=1 "$OUT_DBG" | tail -1 | tr -d '\r\n')"
if [[ "$DBG_OUT" != "$LEAN_EXPECT" ]]; then
  echo "mat2_fma_lean_drift: debug codegen must match Lean mul+add eval (got $DBG_OUT expected $LEAN_EXPECT)"
  exit 1
fi

if ! "$LIC" build "$SAMPLE" -o "$OUT_REL" --no-lean-verify --release >/dev/null 2>&1; then
  echo "mat2_fma_lean_drift: --release build must succeed"
  exit 1
fi
REL_OUT="$(LI_PRINT_SINK_F64=1 "$OUT_REL" | tail -1 | tr -d '\r\n')"
if [[ "$REL_OUT" == "$LEAN_EXPECT" ]]; then
  echo "mat2_fma_lean_drift: release FMA runtime must differ from Lean eval (got $REL_OUT)"
  exit 1
fi

if ! "$LIC" build "$SAMPLE" -o "$OUT_STABLE" --no-lean-verify --release --numerically-stable >/dev/null 2>&1; then
  echo "mat2_fma_lean_drift: --release --numerically-stable build must succeed"
  exit 1
fi
STABLE_OUT="$(LI_PRINT_SINK_F64=1 "$OUT_STABLE" | tail -1 | tr -d '\r\n')"
if [[ "$STABLE_OUT" != "$LEAN_EXPECT" ]]; then
  echo "mat2_fma_lean_drift: release stable must match Lean eval (got $STABLE_OUT expected $LEAN_EXPECT)"
  exit 1
fi

echo "mat2_fma_lean_drift: ok (release FMA=$REL_OUT != lean=$LEAN_EXPECT; stable/debug match lean)"
