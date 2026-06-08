#!/usr/bin/env bash
# WP-PAR-60–65 — FL hardening: partial ranks, stragglers, compressed halos, fault tolerance.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel FL gate (WP-PAR-60–65)"

chmod +x "$ROOT/li-tests/tooling/li_fl_smoke.sh"
bash "$ROOT/li-tests/tooling/li_fl_smoke.sh"

li_ok "check-li-parallel-fl-gate.sh: PASS (WP-PAR-60–65 partial ranks, stragglers, compressed halos, hetero, overlap, shrink)"
