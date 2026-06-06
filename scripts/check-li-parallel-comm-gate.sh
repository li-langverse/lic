#!/usr/bin/env bash
# WP-PAR-70–75 — compiler comm plan, overlap comm MIR, ghost overlap, RDMA hooks, latency + compressed halo benches.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel comm gate (WP-PAR-70–75)"

for smoke in \
  li-tests/tooling/li_comm_plan_codegen_smoke.sh \
  li-tests/tooling/li_comm_md_ghost_overlap_smoke.sh \
  li-tests/tooling/li_comm_compressed_halo_bench.sh \
  li-tests/tooling/li_comm_latency_bench.sh
do
  chmod +x "$ROOT/$smoke"
  bash "$ROOT/$smoke"
done

li_ok "check-li-parallel-comm-gate.sh: PASS (WP-PAR-70–75 __li_comm_plan, overlap comm MIR, MD ghost overlap ≥50%, RDMA hooks, latency + compressed halo benches)"
