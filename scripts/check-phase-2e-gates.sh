#!/usr/bin/env bash
# Phase 2e v1 exit gates (G-vc partial): VC emit, MIR witness telemetry, closed-corpus open goals.
# See docs/superpowers/plans/2026-05-14-phase-02e-contracts.md
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
export LI_REPO_ROOT="$ROOT"
export LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"

fail() { li_gate_fail "$*"; exit 1; }

[[ -x "$LIC" ]] || fail "lic not built — run ./scripts/build.sh"

chmod +x \
  "$ROOT/li-tests/tooling/vc_emit_contracts.sh" \
  "$ROOT/li-tests/tooling/mir_vc_witness.sh" \
  "$ROOT/li-tests/tooling/contracts_discharge_corpus.sh" \
  "$ROOT/scripts/check-autovc-open-goals.sh"

li_phase "2e-a VC emit (typed AutoVC Props)"
"$ROOT/li-tests/tooling/vc_emit_contracts.sh" || fail "vc_emit_contracts"

li_phase "2e-b MIR witness telemetry (vc_witness.cpp)"
"$ROOT/li-tests/tooling/mir_vc_witness.sh" || fail "mir_vc_witness"

li_phase "2e-c closed corpus + open-goals checker"
"$ROOT/li-tests/tooling/contracts_discharge_corpus.sh" || fail "contracts_discharge_corpus"

li_gate_ok "phase 2e v1 gates (G-vc partial)"
