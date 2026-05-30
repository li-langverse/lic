#!/usr/bin/env bash
# G-vc / G-oop: method requires with self.field not translated to Lean; object types erase to Int.
# Typecheck still rejects bad calls (E0304); AutoVC stubs field requires to Prop := True.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
OK="$ROOT/li-tests/contracts_verify/method_call_requires_ok.li"
FAIL="$ROOT/li-tests/contracts_verify/method_call_requires_fail.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

rm -f "$AUTOVC"
"$LIC" build "$OK" -o /dev/null
[[ -f "$AUTOVC" ]]

if ! grep -q 'VC requires (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "method_requires_lean_gap: expected opaque requires comment for self.field"
  exit 1
fi
if ! grep -q 'def vc_Wallet_take_requires_0 (self : Int) (amount : Int) : Prop := True' "$AUTOVC"; then
  echo "method_requires_lean_gap: expected self.field requires stubbed True"
  exit 1
fi
if ! grep -q 'def vc_Wallet_take_requires_1 (self : Int) (amount : Int) : Prop := (amount ≥ 0)' "$AUTOVC"; then
  echo "method_requires_lean_gap: expected plain param requires emitted as Lean predicate"
  exit 1
fi
if grep -qE 'balance|self\.' "$AUTOVC"; then
  echo "method_requires_lean_gap: unexpected field-access predicate in AutoVC (gap closed?)"
  exit 1
fi
if ! grep -q 'def vc_main_call0_Wallet_take_requires_0 : Prop := True' "$AUTOVC"; then
  echo "method_requires_lean_gap: expected witnessed call-site field requires stub"
  exit 1
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"

CHECK_OUT="$("$LIC" check "$FAIL" 2>&1)" || true
if ! printf '%s\n' "$CHECK_OUT" | grep -qF 'E0304'; then
  echo "method_requires_lean_gap: expected E0304 on method_call_requires_fail.li"
  echo "$CHECK_OUT"
  exit 1
fi

echo "method_requires_lean_gap: ok (documented G-vc/G-oop method field requires Lean hole)"
