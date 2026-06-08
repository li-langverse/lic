#!/usr/bin/env bash
# Phase 2e / G-vc partial exit gates (PH-2e): VC emit, MIR witnesses, discharge corpus.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"

VC_WITNESS="$ROOT/compiler/verify/vc_witness.cpp"

[[ -x "$LIC" ]] || {
  echo "check-phase-2e-exit-gates: build lic first (./scripts/build.sh)" >&2
  exit 1
}

echo "==> vc_witness.cpp (MIR-linked ensures helpers)"
test -f "$VC_WITNESS"
grep -q 'collect_return_exprs_in_stmts' "$VC_WITNESS"
grep -q 'witness_' "$VC_WITNESS"

chmod +x \
  "$ROOT/li-tests/tooling/vc_emit_contracts.sh" \
  "$ROOT/li-tests/tooling/mir_vc_witness.sh" \
  "$ROOT/li-tests/tooling/contracts_discharge_corpus.sh" \
  "$ROOT/scripts/check-autovc-open-goals.sh"

echo "==> vc_emit_contracts.sh"
"$ROOT/li-tests/tooling/vc_emit_contracts.sh"

echo "==> mir_vc_witness.sh"
"$ROOT/li-tests/tooling/mir_vc_witness.sh"

echo "==> contracts_discharge_corpus.sh"
"$ROOT/li-tests/tooling/contracts_discharge_corpus.sh"

echo "check-phase-2e-exit-gates: ok (Phase 2e partial / G-vc CI slice)"
