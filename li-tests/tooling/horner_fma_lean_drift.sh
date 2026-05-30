#!/usr/bin/env bash
# Negative control: horner_fma_drift_step.li uses ident addend → mul+add codegen (not FmaFloatF64).
# True FMA witness: horner_fma_literal_lean_drift.sh (literal addend; FmaFloatF64 ignores fp_numerically_stable).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LI_EXTRA_C="$ROOT/li-tests/math_linalg/horner_fma_drift_rt.c"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/math_linalg/horner_fma_drift_step.li"
RT_C="$ROOT/li-tests/math_linalg/horner_fma_drift_rt.c"
OUT_DBG="$(mktemp -t horner_fma_dbg.XXXXXX)"
OUT_REL="$(mktemp -t horner_fma_rel.XXXXXX)"
OUT_STABLE="$(mktemp -t horner_stable_rel.XXXXXX)"
trap 'rm -f "$OUT_DBG" "$OUT_REL" "$OUT_STABLE"' EXIT

test -f "$RT_C"

LEAN_EXPECT="$(python3 - <<'PY'
acc, x, addend = -482166.4994140733, 22549.44273721706, -190131.7250991714
print(f"{(acc * x) + addend:.17g}")
PY
)"

if ! "$LIC" check "$SAMPLE" >/dev/null 2>&1; then
  echo "horner_fma_lean_drift: witness must pass lic check"
  exit 1
fi

if ! "$LIC" build "$SAMPLE" -o "$OUT_DBG" --no-lean-verify >/dev/null 2>&1; then
  echo "horner_fma_lean_drift: debug build must succeed"
  exit 1
fi
DBG_OUT="$(LI_PRINT_SINK_F64=1 "$OUT_DBG" | tail -1 | tr -d '\r\n')"
if [[ "$DBG_OUT" != "$LEAN_EXPECT" ]]; then
  echo "horner_fma_lean_drift: debug codegen must match Lean mul+add eval (got $DBG_OUT expected $LEAN_EXPECT)"
  exit 1
fi

if ! "$LIC" build "$SAMPLE" -o "$OUT_REL" --no-lean-verify --release >/dev/null 2>&1; then
  echo "horner_fma_lean_drift: --release build must succeed"
  exit 1
fi
REL_OUT="$(LI_PRINT_SINK_F64=1 "$OUT_REL" | tail -1 | tr -d '\r\n')"

if ! "$LIC" build "$SAMPLE" -o "$OUT_STABLE" --no-lean-verify --release --numerically-stable >/dev/null 2>&1; then
  echo "horner_fma_lean_drift: --release --numerically-stable build must succeed"
  exit 1
fi
STABLE_OUT="$(LI_PRINT_SINK_F64=1 "$OUT_STABLE" | tail -1 | tr -d '\r\n')"
if [[ "$DBG_OUT" != "$LEAN_EXPECT" ]] || [[ "$STABLE_OUT" != "$LEAN_EXPECT" ]]; then
  echo "horner_fma_lean_drift: ident-addend control must match Lean in debug+stable (dbg=$DBG_OUT stable=$STABLE_OUT lean=$LEAN_EXPECT)"
  exit 1
fi

echo "horner_fma_lean_drift: ok (ident addend: debug+stable=lean; rel=$REL_OUT — no FmaFloatF64 MIR)"
