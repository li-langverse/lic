#!/usr/bin/env bash
# Phase 2e exit gates (G-vc closed slice) — see docs/superpowers/plans/2026-05-14-phase-02e-contracts.md
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
export LI_REPO_ROOT="$ROOT"
export LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"

fail() { li_gate_fail "$*"; exit 1; }
ok() { li_gate_ok "$*"; }

[[ -x "$LIC" ]] || fail "lic not built"
[[ -f "$ROOT/compiler/verify/vc_witness.cpp" ]] || fail "missing compiler/verify/vc_witness.cpp"

li_banner
li_phase "2e-a vc_emit_contracts"
chmod +x "$ROOT/li-tests/tooling/vc_emit_contracts.sh"
"$ROOT/li-tests/tooling/vc_emit_contracts.sh" || fail "vc_emit_contracts"

li_phase "2e-b mir_vc_witness"
chmod +x "$ROOT/li-tests/tooling/mir_vc_witness.sh"
"$ROOT/li-tests/tooling/mir_vc_witness.sh" || fail "mir_vc_witness"

li_phase "2e-d contracts_discharge_corpus"
chmod +x "$ROOT/li-tests/tooling/contracts_discharge_corpus.sh"
"$ROOT/li-tests/tooling/contracts_discharge_corpus.sh" || fail "contracts_discharge_corpus"

li_phase "2e-f contracts_verify manifest"
"$ROOT/li-tests/run_all.sh" contracts_verify || fail "contracts_verify suite"

li_phase "2e-g weak ensures reject (E0303)"
if "$LIC" build "$ROOT/li-tests/prove_reject/weak_ensures_true.li" -o /dev/null 2>/dev/null; then
  fail "weak_ensures_true.li should be rejected (E0303)"
fi

ok "phase 2e exit gates (G-vc closed slice)"
