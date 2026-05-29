#!/usr/bin/env bash
# G-oop / G-vc: method requires with self.field access opaque in Lean; call-site requires stubbed True.
# Typecheck folds w.balance const-local for E0304; certificate omits (self.balance ≥ amount) Props.
# Passes while gap is open; update when expr_to_lean FieldAccess + real call-site Props land (P-refine / 2j-f).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
SAMPLE="$ROOT/li-tests/contracts_verify/method_call_requires_ok.li"
FAIL="$ROOT/li-tests/contracts_verify/method_call_requires_fail.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if ! "$LIC" check "$SAMPLE" >/dev/null 2>&1; then
  echo "method_call_requires_lean_gap: specimen must pass lic check"
  exit 1
fi

fail_out="$("$LIC" build "$FAIL" -o /dev/null 2>&1)" || true
if echo "$fail_out" | grep -q 'build completed successfully'; then
  echo "method_call_requires_lean_gap: method_call_requires_fail must fail typecheck (E0304)"
  exit 1
fi
if ! echo "$fail_out" | grep -q 'E0304'; then
  echo "method_call_requires_lean_gap: expected E0304 on violated balance requires"
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$SAMPLE" -o /dev/null
test -f "$AUTOVC"

# Callee: field-access requires opaque → True stub (expr_to_lean has no FieldAccess case).
if ! grep -q 'VC requires (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "method_call_requires_lean_gap: expected opaque field-access requires comment"
  exit 1
fi
if ! grep -q 'def vc_Wallet_take_requires_0 (self : Int) (amount : Int) : Prop := True' "$AUTOVC"; then
  echo "method_call_requires_lean_gap: expected True stub for self.balance requires on callee"
  exit 1
fi
if ! grep -q 'def vc_Wallet_take_requires_1 (self : Int) (amount : Int) : Prop := (amount ≥ 0)' "$AUTOVC"; then
  echo "method_call_requires_lean_gap: expected real (amount ≥ 0) on callee param requires"
  exit 1
fi

# Call site: folded w.balance=10, amount=4 → witnessed True stubs (no substituted Props).
if ! grep -q 'def vc_main_call0_Wallet_take_requires_0 : Prop := True' "$AUTOVC"; then
  echo "method_call_requires_lean_gap: expected call-site True stub for balance requires"
  exit 1
fi
if ! grep -q 'def vc_main_call0_Wallet_take_requires_1 : Prop := True' "$AUTOVC"; then
  echo "method_call_requires_lean_gap: expected call-site True stub for amount requires"
  exit 1
fi
if grep -qE 'vc_main_call0_Wallet_take_requires_[01].*≥' "$AUTOVC"; then
  echo "method_call_requires_lean_gap: unexpected real bounds on call-site VC — gap may be closed; update script"
  exit 1
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"

echo "method_call_requires_lean_gap: ok (documented G-oop method requires Lean drift)"
