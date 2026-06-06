#!/usr/bin/env bash
# WP-PAR-60–65 — FL hardening: partial ranks, stragglers, compressed halos, fault tolerance.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel FL gate (WP-PAR-60–65)"
li_fail "WP-PAR-60–65 pending — partial rank participation, straggler mitigation, compressed halo exchange, hetero ranks, fault shrink tests"
exit 1
