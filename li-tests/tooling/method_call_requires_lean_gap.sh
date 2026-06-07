#!/usr/bin/env bash
# G-oop / G-vc: method `requires self.field >= arg` opaque in AutoVC; call-site stubs True via
# C++ const folding — not Lean FieldAccess semantics (contrast plain `x >= 0` callee requires).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
OK="$ROOT/li-tests/contracts_verify/method_call_requires_ok.li"
FAIL="$ROOT/li-tests/contracts_verify/method_call_requires_fail.li"
PLAIN="$ROOT/li-tests/contracts_verify/caller_requires_ok.li"
VC_EMIT="$ROOT/compiler/verify/vc_emit_lean.cpp"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

if [[ ! -x "$LIC" ]]; then
  echo "SKIP: lic not built at $LIC" >&2
  exit 0
fi

if ! grep -q 'case Expr::Kind::Call' "$VC_EMIT"; then
  echo "FAIL: expected Call branch in vc_emit_lean.cpp" >&2
  exit 1
fi
if ! grep -A6 'case Expr::Kind::Call' "$VC_EMIT" | grep -q 'e.ident == "abs"'; then
  echo "FAIL: expr_to_lean Call handler should still be abs-only" >&2
  exit 1
fi
if grep -q 'case Expr::Kind::FieldAccess' "$VC_EMIT"; then
  echo "FAIL: expr_to_lean should not yet translate FieldAccess (gap open)" >&2
  exit 1
fi

if "$LIC" check "$FAIL" >/dev/null 2>&1; then
  echo "FAIL: method_call_requires_fail.li should reject at check (E0304)" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$OK" -o /dev/null 2>/dev/null
if ! grep -q 'VC requires (opaque): source expr not yet translated' "$AUTOVC"; then
  echo "FAIL: expected opaque marker for self.balance >= amount on Wallet_take" >&2
  exit 1
fi
if ! grep -q 'vc_Wallet_take_requires_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: field-access requires should stub True (G-vc Lean gap)" >&2
  exit 1
fi
if ! grep -q 'vc_Wallet_take_requires_1.*Prop := (amount ≥ 0)' "$AUTOVC"; then
  echo "FAIL: plain param requires should translate to Lean (contrast)" >&2
  exit 1
fi
if ! grep -q 'vc_main_call0_Wallet_take_requires_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: call-site field requires should stub True via C++ witness" >&2
  exit 1
fi
if ! grep -q 'vc_main_call0_Wallet_take_requires_0_proved.*:= trivial' "$AUTOVC"; then
  echo "FAIL: call-site field requires should discharge via trivial, not Lean" >&2
  exit 1
fi
if grep -Eq 'self\.balance|Li\.Wallet' "$AUTOVC" 2>/dev/null; then
  echo "FAIL: Lean AutoVC should not yet mention object field semantics" >&2
  exit 1
fi

rm -f "$AUTOVC"
"$LIC" build "$PLAIN" -o /dev/null 2>/dev/null
if ! grep -q 'vc_callee_requires_0 (x : Int) : Prop := (x ≥ 0)' "$AUTOVC"; then
  echo "FAIL: plain callee requires control should emit real Lean predicate" >&2
  exit 1
fi
if ! grep -q 'vc_caller_call0_callee_requires_0.*Prop := True' "$AUTOVC"; then
  echo "FAIL: literal call-site should still stub True (witness path)" >&2
  exit 1
fi

chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC" >/dev/null

echo "PASS method_call_requires_lean_gap: FieldAccess requires opaque; call-site C++ witness only"
