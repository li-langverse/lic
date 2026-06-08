#!/usr/bin/env bash
# WP-PAR-20–24 — 4-node localhost, programmed cluster, full MPI-class collectives.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel distributed gate"

chmod +x "$ROOT/li-tests/tooling/li_dpar_for_smoke.sh" "$ROOT/li-tests/tooling/li_dpar_for_codegen_smoke.sh"
bash "$ROOT/li-tests/tooling/li_dpar_for_smoke.sh"
bash "$ROOT/li-tests/tooling/li_dpar_for_codegen_smoke.sh"
chmod +x "$ROOT/li-tests/tooling/li_dpar_collective_smoke.sh"
bash "$ROOT/li-tests/tooling/li_dpar_collective_smoke.sh"
chmod +x "$ROOT/li-tests/tooling/li_dpar_md_weak_scaling_smoke.sh"
bash "$ROOT/li-tests/tooling/li_dpar_md_weak_scaling_smoke.sh"

li_ok "check-li-parallel-distributed-gate.sh: PASS (WP-PAR-20–22 programmed cluster + MD weak-scaling)"
