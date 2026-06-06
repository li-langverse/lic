#!/usr/bin/env bash
# WP-PAR-70–75 — compiler comm plan, overlap comm MIR, RDMA, ghost overlap ≥50% on MD specimen.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel comm gate (WP-PAR-70–75)"
li_fail "WP-PAR-70–75 pending — __li_comm_plan embedding, overlap comm MIR, ghost overlap ≥50% on MD specimen, compressed halo bench"
exit 1
