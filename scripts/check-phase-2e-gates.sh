#!/usr/bin/env bash
# Phase 2e exit gates (G-vc closed slice): typed AutoVC, MIR witnesses, open-goals checker.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"

fail() { li_gate_fail "$*"; exit 1; }
ok() { li_gate_ok "$*"; }

[[ -x "$LIC" ]] || fail "lic not built"

li_banner
li_phase "2e-1 AutoVC emit on lic build"
rm -f "$ROOT/build/generated/AutoVC.lean"
"$LIC" build "$ROOT/li-tests/modules/greeter/greeter.li" -o /dev/null
[[ -f "$ROOT/build/generated/AutoVC.lean" ]] || fail "AutoVC.lean not emitted"

li_phase "2e-2 vc_emit_contracts (real Props)"
chmod +x "$ROOT/li-tests/tooling/vc_emit_contracts.sh"
"$ROOT/li-tests/tooling/vc_emit_contracts.sh"

li_phase "2e-3 mir_vc_witness (lic verify telemetry)"
chmod +x "$ROOT/li-tests/tooling/mir_vc_witness.sh"
"$ROOT/li-tests/tooling/mir_vc_witness.sh"

li_phase "2e-4 vc_witness.cpp present"
WITNESS="$ROOT/compiler/verify/vc_witness.cpp"
[[ -f "$WITNESS" ]] || fail "missing vc_witness.cpp"
grep -q 'compute_vc_witness_stats' "$WITNESS" || fail "compute_vc_witness_stats missing"
grep -q 'witness_' "$WITNESS" || fail "witness_* helpers missing"

li_phase "2e-5 contracts_discharge_corpus"
chmod +x "$ROOT/li-tests/tooling/contracts_discharge_corpus.sh"
"$ROOT/li-tests/tooling/contracts_discharge_corpus.sh"

li_phase "2e-6 check-autovc-open-goals (strict)"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
rm -f "$ROOT/build/generated/AutoVC.lean"
"$LIC" build "$ROOT/li-tests/contracts_verify/discharge_trivial.li" -o /dev/null
"$ROOT/scripts/check-autovc-open-goals.sh" "$ROOT/build/generated/AutoVC.lean"

li_phase "2e-7 contracts_verify + prove_reject manifest"
"$ROOT/li-tests/run_all.sh" contracts_verify prove_reject

ok "phase 2e gates (G-vc closed slice)"
