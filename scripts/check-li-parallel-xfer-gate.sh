#!/usr/bin/env bash
# WP-PAR-87–92 — transfer plan: elision, fusion, D2D, RDMA→GPU, dashboard xfer_sec / elided_copies.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel xfer gate (WP-PAR-87–92)"
li_fail "WP-PAR-87–92 pending — __li_xfer_plan embedding, copy elision + fusion + D2D + RDMA→GPU paths, dashboard xfer_sec/elided_copies columns"
exit 1
