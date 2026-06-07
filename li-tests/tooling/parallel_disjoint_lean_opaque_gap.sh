#!/usr/bin/env bash
# G-par (#387): parallel-for disjoint_row/disjoint_elem/row_ok contracts emit Li.Discharge specs in AutoVC.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
EXPLICIT="$ROOT/li-tests/race_shared_memory/good_disjoint_parallel.li"
DECORATOR="$ROOT/li-tests/decorators/parallel_with_disjoint.li"
INHERIT="$ROOT/li-tests/decorators/parallel_def_disjoint_inherit.li"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'disjoint_row_spec\|disjoint_elem_spec\|row_ok_spec' "$VC_EMIT"; then
  echo "FAIL: vc_emit_lean should wire disjoint builtins" >&2
  exit 1
fi
for f in "$DISCHARGE"; do
  if ! grep -q 'disjoint_elem_spec\|disjoint_row_spec\|row_ok_spec' "$f"; then
    echo "FAIL: expected disjoint semantics in $(basename "$f")" >&2
    exit 1
  fi
done

rm -f "$AUTOVC"
"$LIC" build "$EXPLICIT" -o /dev/null 2>/dev/null
if grep -q 'VC requires (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "FAIL: disjoint_row requires should translate to Li.Discharge (not opaque)" >&2
  exit 1
fi
if ! grep -q 'Li.Discharge.disjoint_row_spec' "$AUTOVC"; then
  echo "FAIL: par requires should emit Li.Discharge.disjoint_row_spec" >&2
  exit 1
fi
if ! grep -q 'vc_good_parallel_par0_requires_0_proved.*disjoint_row_policy_witness' "$AUTOVC"; then
  echo "FAIL: par requires should discharge via disjoint_row_policy_witness" >&2
  exit 1
fi
if ! grep -q 'Li.Discharge.row_ok_spec' "$AUTOVC"; then
  echo "FAIL: par invariant should emit Li.Discharge.row_ok_spec" >&2
  exit 1
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

rm -f "$AUTOVC"
"$LIC" build "$INHERIT" -o /dev/null 2>/dev/null
if grep -q 'par0_requires' "$AUTOVC"; then
  echo "FAIL: decorator-inherited disjoint should not emit par requires VC" >&2
  exit 1
fi
if ! grep -q 'par0_decreases_0' "$AUTOVC"; then
  echo "FAIL: expected par loop decreases VC on inherit specimen" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$DECORATOR" -o /dev/null 2>/dev/null
if ! grep -q 'Li.Discharge.disjoint_elem_spec' "$AUTOVC"; then
  echo "FAIL: decorator disjoint_elem should emit Li.Discharge.disjoint_elem_spec" >&2
  exit 1
fi
if ! grep -q 'vc_par_decorated_par0_requires_0_proved.*disjoint_elem_policy_witness' "$AUTOVC"; then
  echo "FAIL: decorator disjoint_elem should discharge via disjoint_elem_policy_witness" >&2
  exit 1
fi
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

echo "PASS parallel_disjoint_lean_opaque_gap: disjoint contracts → Li.Discharge specs + policy witnesses"
