#!/usr/bin/env bash
# G-par (#387): parallel-for disjoint_row/disjoint_elem/row_ok contracts emit opaque True stubs
# in AutoVC — expr_to_lean Call handler only translates abs(), not disjoint builtins.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
EXPLICIT="$ROOT/li-tests/race_shared_memory/good_disjoint_parallel.li"
INHERIT="$ROOT/li-tests/decorators/parallel_def_disjoint_inherit.li"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
CORE="$ROOT/docs/semantics/Core.lean"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'case Expr::Kind::Call' "$VC_EMIT"; then
  echo "FAIL: expected Call branch in vc_emit_lean.cpp" >&2
  exit 1
fi
if ! grep -A6 'case Expr::Kind::Call' "$VC_EMIT" | grep -q "e.ident == \"abs\""; then
  echo "FAIL: expected abs-only Call translation in vc_emit_lean.cpp" >&2
  exit 1
fi
if grep -q 'disjoint_elem\|disjoint_row\|row_ok' "$VC_EMIT" 2>/dev/null; then
  echo "FAIL: vc_emit_lean should not yet wire disjoint builtins (gap open)" >&2
  exit 1
fi
for f in "$CORE" "$DISCHARGE"; do
  if grep -q 'disjoint_elem\|disjoint_row\|row_ok\|disjoint_slice' "$f" 2>/dev/null; then
    echo "FAIL: expected no disjoint semantics in $(basename "$f") yet" >&2
    exit 1
  fi
done

rm -f "$AUTOVC"
"$LIC" build "$EXPLICIT" -o /dev/null 2>/dev/null
if ! grep -q 'VC requires (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "FAIL: expected opaque requires marker for disjoint_row in AutoVC" >&2
  exit 1
fi
if ! grep -q 'vc_good_parallel_par0_requires_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: par requires should stub True (G-par Lean gap)" >&2
  exit 1
fi
if ! grep -q 'vc_good_parallel_par0_requires_0_proved.*:= trivial' "$AUTOVC"; then
  echo "FAIL: par requires should discharge via trivial, not disjoint semantics" >&2
  exit 1
fi
if ! grep -q 'VC invariant (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "FAIL: expected opaque invariant marker for row_ok in AutoVC" >&2
  exit 1
fi
if grep -q 'disjoint_row\|disjoint_elem\|row_ok' "$AUTOVC"; then
  echo "FAIL: disjoint builtins should not appear in Lean AutoVC text yet" >&2
  exit 1
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

rm -f "$AUTOVC"
"$LIC" build "$INHERIT" -o /dev/null 2>/dev/null
if grep -q 'par0_requires' "$AUTOVC"; then
  echo "FAIL: decorator-inherited disjoint should not yet emit par requires VC" >&2
  exit 1
fi
if ! grep -q 'par0_decreases_0' "$AUTOVC"; then
  echo "FAIL: expected par loop decreases VC on inherit specimen" >&2
  exit 1
fi

echo "PASS parallel_disjoint_lean_opaque_gap: disjoint contracts → opaque True; no Lean disjoint semantics"
