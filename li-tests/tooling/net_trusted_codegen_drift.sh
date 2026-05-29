#!/usr/bin/env bash
# G-net / G-trust: codegen emit.cpp legacy C ABI vs trusted.lean Net axioms vs seam.li surface.
# Passes while the drift is open; update when emit/seam/trusted align on recv/send models.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
EMIT="$ROOT/compiler/codegen/emit.cpp"
TRUSTED="$ROOT/docs/semantics/trusted.lean"
SEAM="$ROOT/std/runtime/seam.li"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"

if ! grep -q 'axiom tcp_recv_stub : Nat → Nat → Net Nat' "$TRUSTED"; then
  echo "net_trusted_codegen_drift: expected tcp_recv_stub Nat→Nat→Net Nat in trusted.lean"
  exit 1
fi

if ! grep -q '"tcp_recv"' "$EMIT" || ! grep -A1 '"tcp_recv"' "$EMIT" | grep -q 'i8_ptr(context)'; then
  echo "net_trusted_codegen_drift: expected emit.cpp tcp_recv returning i8_ptr (legacy ptr ABI)"
  exit 1
fi

if grep -qE '^extern proc tcp_recv\b' "$SEAM"; then
  echo "net_trusted_codegen_drift: seam.li must not expose legacy tcp_recv while drift documented"
  exit 1
fi

if ! grep -q 'extern proc tcp_recv_slot' "$SEAM"; then
  echo "net_trusted_codegen_drift: expected tcp_recv_slot in seam.li (actual Li surface)"
  exit 1
fi

if grep -qE '^extern proc tcp_send\b' "$SEAM"; then
  echo "net_trusted_codegen_drift: seam.li must not expose legacy tcp_send while drift documented"
  exit 1
fi

if ! grep -q '"tcp_send"' "$EMIT" || ! grep -A1 '"tcp_send"' "$EMIT" | grep -q 'i8_ptr(context)'; then
  echo "net_trusted_codegen_drift: expected emit.cpp tcp_send(conn, i8_ptr) legacy ABI"
  exit 1
fi

if ! grep -q 'axiom tcp_send_stub : Nat → Nat → Net Nat' "$TRUSTED"; then
  echo "net_trusted_codegen_drift: expected tcp_send_stub Nat→Nat→Net Nat in trusted.lean"
  exit 1
fi

# No Li specimen should reference the legacy C symbol names (only C runtime + emit predecl).
if rg -q '\btcp_recv\s*\(' --glob '*.li' "$ROOT/li-tests" "$ROOT/std" "$ROOT/packages" 2>/dev/null; then
  echo "net_trusted_codegen_drift: unexpected tcp_recv( call in Li sources"
  exit 1
fi

"$LIC" check "$ROOT/li-tests/net_trusted/seam_policy_ok.li"
if "$LIC" check "$ROOT/li-tests/net_trusted/seam_missing_net.li" 2>/dev/null; then
  echo "net_trusted_codegen_drift: expected compile_fail seam_missing_net (raises Net policy)"
  exit 1
fi

echo "net_trusted_codegen_drift: ok (documented G-net trusted/codegen/seam ABI drift)"
