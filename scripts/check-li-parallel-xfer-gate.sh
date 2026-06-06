#!/usr/bin/env bash
# WP-PAR-87–92 — transfer plan: elision, fusion, D2D, RDMA→GPU, dashboard xfer_sec / elided_copies.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel xfer gate (WP-PAR-87–92)"

for smoke in \
  li-tests/tooling/li_xfer_plan_codegen_smoke.sh \
  li-tests/tooling/li_xfer_elision_smoke.sh \
  li-tests/tooling/li_xfer_dashboard_smoke.sh
do
  chmod +x "$ROOT/$smoke"
  bash "$ROOT/$smoke"
done

li_ok "check-li-parallel-xfer-gate.sh: PASS (WP-PAR-87–92 __li_xfer_plan, elision + fusion + D2D + RDMA→GPU, dashboard xfer_sec/elided_copies)"
