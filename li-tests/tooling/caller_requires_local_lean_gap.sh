#!/usr/bin/env bash
# G-vc / G-lean: call-site callee requires witness folding discharges to True stub.
# Typecheck validates literal / const-local / path-guard facts; Lean certificate omits (x ≥ 0).
# Passes while gap is open; update when real call-site Props land (P-refine / 2f).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
LOCAL="$ROOT/li-tests/contracts_verify/caller_requires_local_ok.li"
LITERAL="$ROOT/li-tests/contracts_verify/caller_requires_ok.li"
GUARDED="$ROOT/li-tests/contracts_verify/caller_requires_guarded_ok.li"
FAIL="$ROOT/li-tests/contracts_verify/caller_requires_fail.li"
AUTOVC="$ROOT/build/generated/AutoVC.lean"

for sample in "$LOCAL" "$LITERAL" "$GUARDED"; do
  if ! "$LIC" check "$sample" >/dev/null 2>&1; then
    echo "caller_requires_local_lean_gap: $sample must pass lic check"
    exit 1
  fi
done

if "$LIC" check "$FAIL" >/dev/null 2>&1; then
  echo "caller_requires_local_lean_gap: caller_requires_fail must fail typecheck (E0304)"
  exit 1
fi

# Const-local witness: y = 5 → call-site requires stubbed True, callee def keeps real Prop.
rm -f "$AUTOVC"
"$LIC" build "$LOCAL" -o /dev/null
test -f "$AUTOVC"
if ! grep -q 'def vc_callee_requires_0 (x : Int) : Prop := (x ≥ 0)' "$AUTOVC"; then
  echo "caller_requires_local_lean_gap: expected real vc_callee_requires_0 on callee"
  exit 1
fi
if ! grep -q 'def vc_caller_local_call0_callee_requires_0 : Prop := True' "$AUTOVC"; then
  echo "caller_requires_local_lean_gap: expected call-site True stub — gap may be closed; update script"
  exit 1
fi
if grep -qE 'vc_caller_local_call0_callee_requires_0.*≥' "$AUTOVC"; then
  echo "caller_requires_local_lean_gap: unexpected real bounds on call-site VC — update script"
  exit 1
fi
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"

# Literal witness: same True stub pattern.
rm -f "$AUTOVC"
"$LIC" build "$LITERAL" -o /dev/null
if ! grep -q 'def vc_caller_call0_callee_requires_0 : Prop := True' "$AUTOVC"; then
  echo "caller_requires_local_lean_gap: expected literal call-site True stub"
  exit 1
fi
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"

# Path-guard witness: if n >= 0 branch — call-site still True stub (assum_nonneg folding).
rm -f "$AUTOVC"
"$LIC" build "$GUARDED" -o /dev/null
if ! grep -q 'def vc_caller_guarded_call0_callee_requires_0 (n : Int) : Prop := True' "$AUTOVC"; then
  echo "caller_requires_local_lean_gap: expected guarded call-site True stub"
  exit 1
fi
"$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"

echo "caller_requires_local_lean_gap: ok (documented G-vc call-site requires witness stub)"
