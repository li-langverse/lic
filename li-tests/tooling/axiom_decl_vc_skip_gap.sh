#!/usr/bin/env bash
# BUG-C-13 partial: proof_db_* axiom catalog specimens emit Discharge cites (not True stubs).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
SAMPLE="$ROOT/proof-db/math/axioms/peano_succ_injective.li"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
VC_WITNESS="$ROOT/compiler/verify/vc_witness.cpp"
DISCHARGE="$ROOT/docs/semantics/Discharge.lean"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'is_proof_db_axiom_decl' "$VC_WITNESS"; then
  echo "FAIL: expected is_proof_db_axiom_decl in vc_witness.cpp" >&2
  exit 1
fi
if ! grep -q 'proof_db_axiom_discharge' "$VC_EMIT"; then
  echo "FAIL: expected proof_db_axiom_discharge in vc_emit_lean.cpp" >&2
  exit 1
fi
if ! grep -q 'proof_db_peano_succ_injective_ensures_0_proved' "$DISCHARGE"; then
  echo "FAIL: expected proof_db_peano_succ_injective discharge in Discharge.lean" >&2
  exit 1
fi
if ! grep -q 'Li.ProofDb.Math.peano_succ_injective' "$DISCHARGE"; then
  echo "FAIL: Discharge should cite Li.ProofDb.Math.peano_succ_injective" >&2
  exit 1
fi

"$LIC" check "$SAMPLE"
rm -f "$AUTOVC"
"$LIC" build --no-lean-verify "$SAMPLE" -o /dev/null 2>/dev/null

if ! grep -q 'vc_proof_db_peano_succ_injective_ensures_0' "$AUTOVC"; then
  echo "FAIL: AutoVC missing peano_succ_injective ensures VC" >&2
  exit 1
fi
if grep -q 'vc_proof_db_peano_succ_injective_ensures_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: axiom ensures should not be trivial True" >&2
  exit 1
fi
if ! grep -q 'Li.Discharge.proof_db_peano_succ_injective_ensures_0_proved' "$AUTOVC"; then
  echo "FAIL: AutoVC should discharge via Li.Discharge proof_db_* lemma" >&2
  exit 1
fi
if ! grep -q 'Li.ProofDb.Math.peano_succ_injective' "$DISCHARGE"; then
  echo "FAIL: discharge lemma should reference catalog axiom" >&2
  exit 1
fi

echo "PASS axiom_decl_vc_skip_gap: proof_db axiom ensures use Discharge (not True stub)"
